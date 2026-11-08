import 'package:raabta/features/eosb/domain/models/eosb_result.dart';

/// Deterministic Life Intelligence signal kinds (V1).
enum LifeIntelligenceSignalType {
  employerTransferStarted,
  employerNameMismatch,
}

/// In-app nudge payload — derived live, never persisted as a label.
class LifeIntelligenceSignal {
  const LifeIntelligenceSignal({
    required this.type,
    required this.route,
    required this.headlineKey,
    required this.bodyKey,
    required this.ctaKey,
  });

  final LifeIntelligenceSignalType type;
  final String route;
  final String headlineKey;
  final String bodyKey;
  final String ctaKey;
}

/// Pure evaluation for Home Today Life Intelligence signals (V1).
abstract final class LifeIntelligenceSignalsService {
  static const kCooldownDays = 30;
  static const employerTransferPromptAtKey =
      'life_intelligence_employer_transfer_prompt_at_v1';
  static const employerMismatchPromptAtKey =
      'life_intelligence_employer_mismatch_prompt_at_v1';
  static const eosbRoute = '/eosb';
  static const healthInsuranceRoute = '/health-insurance';

  static String promptAtKeyFor(LifeIntelligenceSignalType type) =>
      switch (type) {
        LifeIntelligenceSignalType.employerTransferStarted =>
          employerTransferPromptAtKey,
        LifeIntelligenceSignalType.employerNameMismatch =>
          employerMismatchPromptAtKey,
      };

  /// Trigger A — completed Sponsorship Transfer readiness + EOSB history.
  static bool evaluateEmployerTransferStarted({
    required bool sponsorshipTransferCompleted,
    required bool hasEosbHistory,
  }) =>
      sponsorshipTransferCompleted && hasEosbHistory;

  /// Trigger B — newest saved EOSB employer key differs from HI compliance key.
  static bool evaluateEmployerNameMismatch({
    required String eosbEmployerKey,
    required String? healthInsuranceEmployerKey,
  }) {
    final eosb = eosbEmployerKey.trim();
    final hi = healthInsuranceEmployerKey?.trim() ?? '';
    if (eosb.isEmpty || hi.isEmpty) return false;
    return eosb != hi;
  }

  static bool wasPromptedRecently(DateTime? lastPromptAt, DateTime now) {
    if (lastPromptAt == null) return false;
    return !lastPromptAt
        .isBefore(now.subtract(const Duration(days: kCooldownDays)));
  }

  /// Resolves at most one eligible signal with fatigue coordination applied.
  static LifeIntelligenceSignal? evaluateActiveSignal({
    required bool sponsorshipTransferCompleted,
    required List<CalculationHistoryEntry> eosbHistory,
    required String? healthInsuranceEmployerKey,
    required bool lifeEventHealthCoverageActive,
    required DateTime now,
    DateTime? employerTransferLastPromptAt,
    DateTime? employerMismatchLastPromptAt,
  }) {
    final hasEosbHistory = eosbHistory.isNotEmpty;

    final transferCondition = evaluateEmployerTransferStarted(
      sponsorshipTransferCompleted: sponsorshipTransferCompleted,
      hasEosbHistory: hasEosbHistory,
    );

    final eosbKey = hasEosbHistory
        ? eosbHistory.first.input.effectiveNormalizedEmployerKey
        : '';

    final mismatchCondition = evaluateEmployerNameMismatch(
      eosbEmployerKey: eosbKey,
      healthInsuranceEmployerKey: healthInsuranceEmployerKey,
    );

    final transferEligible = transferCondition &&
        !wasPromptedRecently(employerTransferLastPromptAt, now);

    final mismatchEligible = mismatchCondition &&
        !lifeEventHealthCoverageActive &&
        !wasPromptedRecently(employerMismatchLastPromptAt, now);

    if (transferEligible) {
      return const LifeIntelligenceSignal(
        type: LifeIntelligenceSignalType.employerTransferStarted,
        route: eosbRoute,
        headlineKey: 'life_intelligence_employer_transfer_headline',
        bodyKey: 'life_intelligence_employer_transfer_body',
        ctaKey: 'life_intelligence_employer_transfer_cta',
      );
    }

    if (mismatchEligible) {
      return const LifeIntelligenceSignal(
        type: LifeIntelligenceSignalType.employerNameMismatch,
        route: healthInsuranceRoute,
        headlineKey: 'life_intelligence_employer_mismatch_headline',
        bodyKey: 'life_intelligence_employer_mismatch_body',
        ctaKey: 'life_intelligence_employer_mismatch_cta',
      );
    }

    return null;
  }

  /// Newest saved EOSB employer key for Trigger B.
  static String latestEosbEmployerKey(List<CalculationHistoryEntry> history) {
    if (history.isEmpty) return '';
    return history.first.input.effectiveNormalizedEmployerKey;
  }
}
