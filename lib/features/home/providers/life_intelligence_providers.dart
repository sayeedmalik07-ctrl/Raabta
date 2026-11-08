import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/home/providers/life_events_providers.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/life_intelligence_health_insurance_employer_reader.dart';
import 'package:raabta/services/life_intelligence_signals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Active Life Intelligence signal for the current Home session (derived, not persisted).
final lifeIntelligenceActiveSignalProvider =
    StateProvider<LifeIntelligenceSignal?>((ref) => null);

DateTime? _readPromptAt(SharedPreferences prefs, LifeIntelligenceSignalType type) {
  final raw = prefs.getString(LifeIntelligenceSignalsService.promptAtKeyFor(type));
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

Future<void> _recordPromptShown(
  SharedPreferences prefs,
  LifeIntelligenceSignalType type, {
  DateTime? when,
}) async {
  await prefs.setString(
    LifeIntelligenceSignalsService.promptAtKeyFor(type),
    (when ?? DateTime.now()).toIso8601String(),
  );
}

/// Evaluates Life Intelligence signals on Home open — in-app only, no notifications.
Future<void> evaluateLifeIntelligenceSignalsOnHomeLoad(WidgetRef ref) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) {
    ref.read(lifeIntelligenceActiveSignalProvider.notifier).state = null;
    return;
  }

  final eosbHistory = await ref.read(eosbHistoryProvider.future);
  final sponsorshipRepo =
      await ref.read(sponsorshipTransferRepositoryProvider.future);
  final hiEmployerKey =
      await LifeIntelligenceHealthInsuranceEmployerReader
          .loadLatestNormalizedEmployerKey();

  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final lifeEventActive =
      ref.read(lifeEventHealthCoverageActiveProvider) != null;

  final signal = LifeIntelligenceSignalsService.evaluateActiveSignal(
    sponsorshipTransferCompleted: sponsorshipRepo.hasCompletedCheck(),
    eosbHistory: eosbHistory,
    healthInsuranceEmployerKey: hiEmployerKey,
    lifeEventHealthCoverageActive: lifeEventActive,
    now: now,
    employerTransferLastPromptAt: _readPromptAt(
      prefs,
      LifeIntelligenceSignalType.employerTransferStarted,
    ),
    employerMismatchLastPromptAt: _readPromptAt(
      prefs,
      LifeIntelligenceSignalType.employerNameMismatch,
    ),
  );

  if (signal == null) {
    ref.read(lifeIntelligenceActiveSignalProvider.notifier).state = null;
    return;
  }

  ref.read(lifeIntelligenceActiveSignalProvider.notifier).state = signal;
  await _recordPromptShown(prefs, signal.type, when: now);
}

Future<void> dismissLifeIntelligenceSignal(WidgetRef ref) async {
  final signal = ref.read(lifeIntelligenceActiveSignalProvider);
  if (signal == null) return;

  ref.read(lifeIntelligenceActiveSignalProvider.notifier).state = null;
  final prefs = await SharedPreferences.getInstance();
  await _recordPromptShown(prefs, signal.type);
}
