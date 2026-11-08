import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/scam_shield/data/official_directory_repository.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_bootstrap.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_academy_progress_repository.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_alert_ack_repository.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_history_repository.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_usage_repository.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_active_alert.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_active_alert_evaluator.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_assessment_service.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_incident_service.dart';
import 'package:raabta/features/scam_shield/data/scam_evidence_repository.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';
import 'package:raabta/features/scam_shield/services/scam_evidence_locker_service.dart';
import 'package:raabta/features/scam_shield/platform/scam_proactive_protection_platform.dart';
import 'package:raabta/features/scam_shield/services/scam_proactive_history_sync.dart';
import 'package:raabta/features/scam_shield/services/scam_sim_swap_service.dart';
import 'package:raabta/features/scam_shield/services/scam_web_risk_service.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

final officialDirectoryRepositoryProvider =
    Provider<OfficialDirectoryRepository>((ref) {
  return OfficialDirectoryRepository();
});

/// Loads bundled directory + optional cached Firestore override (one doc, 24h TTL).
final officialDirectoryBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(officialDirectoryRepositoryProvider).loadEffectiveSnapshot();
  await PersonalContextBootstrap.loadOutdatedBrandCatalog();
});

final officialDirectoryVerifiedCountProvider = Provider<int>((ref) {
  ref.watch(officialDirectoryBootstrapProvider);
  return OfficialDirectory.snapshot.verifiedEntries.length;
});

final scamShieldUsageRepositoryProvider =
    FutureProvider<ScamShieldUsageRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ScamShieldUsageRepository(prefs);
});

final scamShieldAssessmentServiceProvider =
    Provider<ScamShieldAssessmentService>((ref) {
  return defaultScamShieldAssessmentService(ref.watch(claudeAIServiceProvider));
});

final scamShieldIncidentServiceProvider = Provider<ScamShieldIncidentService>(
  (ref) => ScamShieldIncidentService(),
);

final scamSimSwapServiceProvider = Provider<ScamSimSwapService>(
  (ref) => ScamSimSwapService(),
);

final scamEvidenceLockerServiceProvider = Provider<ScamEvidenceLockerService>(
  (ref) => ScamEvidenceLockerService(),
);

final scamEvidenceRepositoryProvider = Provider<ScamEvidenceRepository>(
  (ref) => ScamEvidenceRepository.instance,
);

final scamEvidenceRecordsProvider =
    FutureProvider<List<ScamEvidenceRecord>>((ref) async {
  return ref.watch(scamEvidenceLockerServiceProvider).loadAll();
});

final scamShieldHistoryRepositoryProvider =
    Provider<ScamShieldHistoryRepository>(
  (ref) => ScamShieldHistoryRepository.instance,
);

final scamShieldHistoryProvider =
    FutureProvider<List<ScamShieldHistoryEntry>>((ref) async {
  final repo = ref.watch(scamShieldHistoryRepositoryProvider);
  return repo.loadAll();
});

final scamShieldAlertAckRepositoryProvider =
    FutureProvider<ScamShieldAlertAckRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ScamShieldAlertAckRepository(prefs);
});

/// Read-only Home anchor signal — Option A acknowledgment model.
///
/// Elevated when Hive history has an unacknowledged row that is either:
/// - [ScamShieldHistoryEntryKind.incident] (within 30 days), or
/// - a high-risk scan (within 30 days).
///
/// Acknowledged when the user opens `/scam-shield` or `/scam-shield/incident`.
final scamShieldActiveAlertProvider =
    FutureProvider<ScamShieldActiveAlertState>((ref) async {
  final history = await ref.watch(scamShieldHistoryProvider.future);
  final ackRepo = await ref.watch(scamShieldAlertAckRepositoryProvider.future);
  final acknowledged = await ackRepo.loadAcknowledgedIds();
  return ScamShieldActiveAlertEvaluator.evaluate(
    history: history,
    acknowledgedEntryIds: acknowledged,
  );
});

/// Convenience bool for Home anchor styling.
final scamShieldHasActiveAlertProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(scamShieldActiveAlertProvider).whenData((state) {
    return state.isElevated;
  });
});

final scamShieldRemainingAiProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(scamShieldUsageRepositoryProvider.future);
  final isPremium = await ref.watch(isPremiumUserProvider.future);
  final limit = isPremium
      ? ScamShieldConfig.premiumMonthlyAiLimit
      : ScamShieldConfig.freeMonthlyAiLimit;
  return (limit - repo.getLocalMonthlyCount()).clamp(0, limit);
});

Future<bool> scamShieldCanUseAi(WidgetRef ref) async {
  final repo = await ref.read(scamShieldUsageRepositoryProvider.future);
  final isPremium = await ref.read(isPremiumUserProvider.future);
  return repo.canUseAiLocally(isPremium: isPremium);
}

Future<void> scamShieldRecordAiUsage(WidgetRef ref) async {
  final repo = await ref.read(scamShieldUsageRepositoryProvider.future);
  await repo.incrementLocalMonthlyCount();
  ref.invalidate(scamShieldRemainingAiProvider);
}

String? scamShieldUserId(WidgetRef ref) {
  return ref.read(currentUserProvider)?.uid;
}

final scamShieldAcademyProgressRepositoryProvider =
    Provider<ScamShieldAcademyProgressRepository>(
  (ref) => ScamShieldAcademyProgressRepository(),
);

final scamWebRiskServiceProvider = Provider<ScamWebRiskService>(
  (ref) => ScamWebRiskService(),
);

final scamProactiveProtectionPlatformProvider =
    Provider<ScamProactiveProtectionPlatform>(
  (ref) => ScamProactiveProtectionPlatform(),
);

final scamProactiveProtectionStatusProvider =
    FutureProvider<ScamProactiveProtectionStatus>((ref) async {
  final platform = ref.watch(scamProactiveProtectionPlatformProvider);
  final status = await platform.loadStatus();
  if (status.pendingFlaggedCalls.isNotEmpty) {
    final repo = ref.read(scamShieldHistoryRepositoryProvider);
    for (final entry in ScamProactiveHistorySync.entriesFromFlaggedCalls(
      status.pendingFlaggedCalls,
    )) {
      await repo.saveEntry(entry);
    }
    ref.invalidate(scamShieldHistoryProvider);
  }
  return status;
});

/// Remote kill switch — default off until `admin_config.featureFlags.scam_domain_age`.
final scamDomainAgeEnabledProvider = Provider<bool>((ref) {
  final config = ref.watch(adminAppConfigProvider).valueOrNull ??
      const AdminAppConfig();
  return config.featureFlags['scam_domain_age'] == true;
});

/// Remote kill switch — default off until `admin_config.featureFlags.scam_link_unroll`.
final scamLinkUnrollEnabledProvider = Provider<bool>((ref) {
  final config = ref.watch(adminAppConfigProvider).valueOrNull ??
      const AdminAppConfig();
  return config.featureFlags['scam_link_unroll'] == true;
});
