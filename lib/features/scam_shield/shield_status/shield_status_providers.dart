import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/notification_preferences/presentation/screens/notification_preferences_screen.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_providers.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_secure_store.dart';
import 'package:raabta/features/scam_shield/providers/scam_advisory_providers.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_repository.dart';
import 'package:raabta/features/scam_shield/shield_status/admin_shield_freshness_models.dart';
import 'package:raabta/features/scam_shield/shield_status/admin_shield_freshness_service.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_status_deriver.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_status_models.dart';

final shieldStatusSnapshotProvider =
    FutureProvider.autoDispose<ShieldStatusSnapshot>((ref) async {
  await ref.watch(officialDirectoryBootstrapProvider.future);
  final proactive =
      await ref.watch(scamProactiveProtectionStatusProvider.future);
  final progress = await ref.watch(scamCheckupProgressProvider.future);
  final notifService =
      await ref.watch(notificationPreferencesServiceProvider.future);
  final settings = await notifService.getSettings();
  final osStatus = await Permission.notification.status;
  final osGranted = osStatus.isGranted || osStatus.isLimited;

  final hint = await FamilyVerificationSecureStore.readHint();
  final contacts = await FamilyVerificationSecureStore.readContacts();
  final familyConfigured =
      (hint != null && hint.trim().isNotEmpty) || contacts.isNotEmpty;

  final draft = await ReportPackRepository.loadDraft();
  final bankSaved = draft.bankFraudLine.trim().isNotEmpty;

  final repo = ref.watch(scamAdvisoryRepositoryProvider);
  final cachedAdvisories = await repo.readCachedAdvisoriesOnly();
  DateTime? latestPublish;
  for (final a in cachedAdvisories) {
    final p = a.publishedAt;
    if (p != null && (latestPublish == null || p.isAfter(latestPublish))) {
      latestPublish = p;
    }
  }

  return ShieldStatusDeriver.derive(
    proactive: proactive,
    osNotificationsGranted: osGranted,
    scamAdvisoryAlertEnabled: settings.scamAdvisoryAlert,
    securityTipEnabled: settings.securityTip,
    securityTodayCardsEnabled: settings.securityTodayCards,
    checkupDone: progress.done,
    checkupTotal: progress.total,
    familyKitConfigured: familyConfigured,
    myBankSaved: bankSaved,
    directoryEntries: OfficialDirectory.snapshot.entries,
    latestAdvisoryPublished: latestPublish,
    legalSourcesUpdated: LegalSourcesSeedCatalog.seedLatestVerified,
    clock: DateTime.now(),
  );
});

final adminShieldFreshnessReportProvider =
    FutureProvider.autoDispose<AdminShieldFreshnessReport>((ref) async {
  final config = await ref.watch(adminAppConfigProvider.future);
  final repo = ref.watch(scamAdvisoryRepositoryProvider);
  final cached = await repo.readCachedAdvisoriesOnly();
  return AdminShieldFreshnessService().build(
    config: config,
    cachedAdvisories: cached,
  );
});
