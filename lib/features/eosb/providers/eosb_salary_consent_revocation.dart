import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_rounding_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

typedef _EosbConsentRead = T Function<T>(ProviderListenable<T> provider);

/// Shared revocation steps (order preserved for parity across call sites).
void _runEosbSalaryConsentRevocation(_EosbConsentRead read) {
  read(eosbProvider.notifier).applySalaryConsentRevocation();
  read(overtimeTruthProvider.notifier).applySalaryConsentRevocation();
  read(eosbContractAnalysisProvider.notifier).state = null;
  read(overtimeRoundingAiExplanationProvider.notifier).state = null;
  read(
    claudeAIServiceProvider,
  ).clearCacheForRequestTypes(EosbSalarySensitiveClaudeRequestTypes.all);
}

/// Clears in-memory salary-bearing engine state (tests, [ProviderContainer]).
void applyEosbSalaryConsentRevocation(Ref ref) {
  _runEosbSalaryConsentRevocation(ref.read);
}

/// Same cleanup without a [WidgetRef] (safe after the originating widget disposes).
void applyEosbSalaryConsentRevocationForProviderContainer(
  ProviderContainer container,
) {
  _runEosbSalaryConsentRevocation(container.read);
}

/// Persists salary consent and refreshes providers using [container] only.
Future<void> persistEosbSalaryConsentChange(
  ProviderContainer container,
  bool value,
) async {
  final repo = await container.read(eosbRepositoryProvider.future);
  await repo.setSalaryConsent(value);
  container.invalidate(eosbSalaryConsentProvider);
  if (!value) {
    applyEosbSalaryConsentRevocationForProviderContainer(container);
  }
}

/// Same cleanup from widget / [ConsumerState] scope ([WidgetRef]).
void applyEosbSalaryConsentRevocationWithWidgetRef(WidgetRef ref) {
  _runEosbSalaryConsentRevocation(ref.read);
}
