import 'package:raabta/features/scam_shield/domain/scam_chain_correlator.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';

/// Correlation window for incident chain scoring (Section 8).
const Duration kIncidentCorrelationWindow = ScamChainCorrelator.correlationWindow;

/// Deterministic priority + chain-confidence scoring (Phase 1B).
abstract final class ScamResponsePriorityEngine {
  // ── Section 5 — RESPONSE PRIORITY DECISION TABLE ───────────────────────────
  // Evaluated top-to-bottom; first matching rule wins (= highest urgency).
  //
  // RULE 1 — EMERGENCY:
  //   IF any financial exposure reported (unauthorized transaction, money
  //      transferred, card charged, cash withdrawal)
  //   OR chainConfidence >= 0.75 AND stage >= accountTakeoverRisk
  //   THEN priority = emergency
  //
  // RULE 2 — URGENT:
  //   IF stage == simSwapRisk OR stage == accountTakeoverRisk
  //   OR (otp exposure reported AND (sim/eSIM event reported OR
  //      account-change event reported))
  //   THEN priority = urgent
  //
  // RULE 3 — SECURE:
  //   IF any authentication-relevant exposure reported (otp, password,
  //      username, cardInformation, bankAccountInformation)
  //   OR stage == otpHarvesting OR stage == credentialHarvesting
  //   THEN priority = secure
  //
  // RULE 4 — PROTECT:
  //   IF any identity-relevant exposure reported (qid, passport,
  //      drivingLicence, dateOfBirth, address, phoneNumber,
  //      employerInformation, salaryInformation)
  //   OR stage == informationHarvesting
  //   THEN priority = protect
  //
  // RULE 5 — OBSERVE (default):
  //   IF none of the above match
  //   THEN priority = observe
  //
  // Always escalates to the highest matching rule — never downgrades based on
  // evidence status. reportedByUser financial exposure still fires RULE 1.
  static ScamResponsePriority calculatePriority({
    required ScamIncidentInput input,
    required ScamAttackStage stage,
    required double chainConfidence,
  }) {
    if (_hasFinancialExposure(input.outcomes) ||
        (chainConfidence >= 0.75 &&
            stage.rank >= ScamAttackStage.accountTakeoverRisk.rank)) {
      return ScamResponsePriority.emergency;
    }

    if (stage == ScamAttackStage.simSwapRisk ||
        stage == ScamAttackStage.accountTakeoverRisk ||
        (_hasOtpExposure(input.sharedData) &&
            (_hasSimEvent(input) || _hasAccountChangeEvent(input.outcomes)))) {
      return ScamResponsePriority.urgent;
    }

    if (_hasAuthenticationExposure(input.sharedData) ||
        stage == ScamAttackStage.otpHarvesting ||
        stage == ScamAttackStage.credentialHarvesting) {
      return ScamResponsePriority.secure;
    }

    if (_hasIdentityExposure(input.sharedData) ||
        stage == ScamAttackStage.informationHarvesting) {
      return ScamResponsePriority.protect;
    }

    return ScamResponsePriority.observe;
  }

  // ── Section 6 — ATTACK-CHAIN CONFIDENCE SCORING TABLE ──────────────────────
  // Not a probability — display Low / Moderate / High bands only.
  //
  // + 0.15  identity information exposure reported
  // + 0.15  authentication exposure reported (otp/password/username)
  // + 0.20  unexpected SIM/eSIM event reported
  // + 0.15  account change reported (password changed, email changed,
  //         account locked, unknown login)
  // + 0.25  unauthorized financial event reported
  // + 0.10  three or more distinct events correlated within the
  //         correlation window (72 hours)
  //
  // Sum, cap at 1.0. Bands: 0.0–0.39 Low, 0.40–0.69 Moderate, 0.70–1.0 High.
  static double calculateChainConfidence({
    required ScamIncidentInput input,
    List<ScamShieldHistoryEntry> recentHistory = const [],
    DateTime? now,
  }) {
    var score = 0.0;

    if (_hasIdentityExposure(input.sharedData)) score += 0.15;
    if (_hasAuthenticationExposure(input.sharedData)) score += 0.15;
    if (_hasSimEvent(input)) score += 0.20;
    if (_hasAccountChangeEvent(input.outcomes)) score += 0.15;
    if (_hasFinancialExposure(input.outcomes)) score += 0.25;

    final distinctEvents = _distinctCorrelatedEvents(
      input: input,
      recentHistory: recentHistory,
      now: now,
    );
    if (distinctEvents >= 3) score += 0.10;

    return score.clamp(0.0, 1.0);
  }

  static ScamChainConfidenceBand confidenceBand(double chainConfidence) {
    if (chainConfidence >= 0.70) return ScamChainConfidenceBand.high;
    if (chainConfidence >= 0.40) return ScamChainConfidenceBand.moderate;
    return ScamChainConfidenceBand.low;
  }

  /// Maps priority to existing Level 1–5 checklist copy (Section 4).
  static ScamIncidentResponseLevel checklistLevelFor(
    ScamResponsePriority priority,
  ) {
    return switch (priority) {
      ScamResponsePriority.observe => ScamIncidentResponseLevel.level1,
      ScamResponsePriority.protect => ScamIncidentResponseLevel.level2,
      ScamResponsePriority.secure => ScamIncidentResponseLevel.level3,
      ScamResponsePriority.urgent => ScamIncidentResponseLevel.level4,
      ScamResponsePriority.emergency => ScamIncidentResponseLevel.level5,
    };
  }

  static bool showsSecondaryScamWarning(ScamResponsePriority priority) {
    return priority == ScamResponsePriority.secure ||
        priority == ScamResponsePriority.urgent ||
        priority == ScamResponsePriority.emergency;
  }

  static bool _hasFinancialExposure(Set<ScamIncidentOutcome> outcomes) {
    return outcomes.contains(ScamIncidentOutcome.unknownTransaction) ||
        outcomes.contains(ScamIncidentOutcome.moneyTransferred) ||
        outcomes.contains(ScamIncidentOutcome.cardCharged);
  }

  static bool _hasOtpExposure(Set<ScamSharedDataCategory> shared) =>
      shared.contains(ScamSharedDataCategory.otp);

  static bool _hasSimEvent(ScamIncidentInput input) {
    return input.sharedData.contains(ScamSharedDataCategory.simEsimInfo) ||
        input.outcomes.contains(ScamIncidentOutcome.simPhoneStopped);
  }

  static bool _hasAccountChangeEvent(Set<ScamIncidentOutcome> outcomes) {
    return outcomes.contains(ScamIncidentOutcome.passwordChanged) ||
        outcomes.contains(ScamIncidentOutcome.unexpectedOtp) ||
        outcomes.contains(ScamIncidentOutcome.accountLocked);
  }

  static bool _hasAuthenticationExposure(Set<ScamSharedDataCategory> shared) {
    return shared.contains(ScamSharedDataCategory.otp) ||
        shared.contains(ScamSharedDataCategory.password) ||
        shared.contains(ScamSharedDataCategory.bankDetails) ||
        shared.contains(ScamSharedDataCategory.cardDetails);
  }

  static bool _hasIdentityExposure(Set<ScamSharedDataCategory> shared) {
    return shared.contains(ScamSharedDataCategory.qid) ||
        shared.contains(ScamSharedDataCategory.passport) ||
        shared.contains(ScamSharedDataCategory.drivingLicence) ||
        shared.contains(ScamSharedDataCategory.phoneConfirmation);
  }

  static int _distinctCorrelatedEvents({
    required ScamIncidentInput input,
    required List<ScamShieldHistoryEntry> recentHistory,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final windowStart = clock.subtract(kIncidentCorrelationWindow);
    final tags = <String>{};

    void tag(String value) => tags.add(value);

    for (final category in input.sharedData) {
      tag('shared:${category.name}');
    }
    for (final outcome in input.outcomes) {
      if (outcome != ScamIncidentOutcome.nothingYet) {
        tag('outcome:${outcome.name}');
      }
    }
    for (final channel in input.contactChannels) {
      tag('channel:${channel.name}');
    }
    if (input.impersonationCategory != ScamImpersonationCategory.other) {
      tag('impersonation:${input.impersonationCategory.name}');
    }

    for (final entry in recentHistory) {
      if (entry.scannedAt.isBefore(windowStart)) continue;
      if (entry.attackStage != null) {
        tag('history_stage:${entry.attackStage!.name}');
      }
      tag('history:${entry.kind.name}:${entry.id}');
    }

    return tags.length;
  }
}
