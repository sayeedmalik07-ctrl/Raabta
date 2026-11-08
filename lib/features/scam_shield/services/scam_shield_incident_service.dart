import 'package:raabta/features/scam_shield/domain/scam_attack_stage_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_chain_correlator.dart';
import 'package:raabta/features/scam_shield/domain/scam_compound_risk_detector.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_response_priority_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_safe_verification_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_self_report.dart';
import 'package:raabta/features/scam_shield/domain/scam_sensitive_input_mask.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';

/// Deterministic incident assessment — no AI in the critical path.
class ScamShieldIncidentService {
  ScamIncidentAssessmentResult assess({
    required ScamIncidentInput input,
    List<ScamShieldHistoryEntry> recentHistory = const [],
  }) {
    final sanitizedNotes = input.freeTextNotes == null
        ? null
        : ScamSensitiveInputMask.mask(input.freeTextNotes!.trim());

    final sanitizedInput = ScamIncidentInput(
      impersonationCategory: input.impersonationCategory,
      contactChannels: input.contactChannels,
      timing: input.timing,
      occurredAt: input.occurredAt,
      sharedData: input.sharedData,
      outcomes: input.outcomes,
      freeTextNotes: sanitizedNotes?.isEmpty ?? true ? null : sanitizedNotes,
      evidenceStatus: input.evidenceStatus,
      simSelfReportAnswers: input.simSelfReportAnswers,
    );

    final compound = ScamCompoundRiskDetector.evaluate(sanitizedInput.sharedData);
    final stage = ScamAttackStageEngine.detectStage(sanitizedInput);
    final chainConfidence = ScamResponsePriorityEngine.calculateChainConfidence(
      input: sanitizedInput,
      recentHistory: recentHistory,
    );
    final responsePriority = ScamResponsePriorityEngine.calculatePriority(
      input: sanitizedInput,
      stage: stage,
      chainConfidence: chainConfidence,
    );
    final responseLevel = ScamResponsePriorityEngine.checklistLevelFor(
      responsePriority,
    );
    final confidenceBand = ScamResponsePriorityEngine.confidenceBand(
      chainConfidence,
    );
    final safeVerificationKeys = ScamSafeVerificationEngine.guidanceKeysFor(
      impersonation: sanitizedInput.impersonationCategory,
    );

    final groupId = ScamChainCorrelator.resolveGroupId(
      recentEntries: recentHistory,
      stage: stage,
    );

    final preliminary = ScamIncidentAssessmentResult(
      stage: stage,
      responsePriority: responsePriority,
      responseLevel: responseLevel,
      compoundRisk: compound,
      checklistActionKeys:
          ScamAttackStageEngine.checklistKeysFor(responseLevel),
      stageSummaryKeys: ScamAttackStageEngine.stageSummaryKeys(stage),
      chainConfidence: chainConfidence,
      confidenceBand: confidenceBand,
      evidenceStatus: sanitizedInput.evidenceStatus,
      safeVerificationKeys: safeVerificationKeys,
      incidentGroupId: groupId,
    );

    final narrative = ScamChainCorrelator.buildNarrative(
      recentEntries: recentHistory,
      current: preliminary,
    );

    final yesCount = sanitizedInput.simSelfReportAnswers?.yesCount ?? 0;
    final assessed = ScamIncidentAssessmentResult(
      stage: stage,
      responsePriority: responsePriority,
      responseLevel: responseLevel,
      compoundRisk: compound,
      checklistActionKeys:
          ScamAttackStageEngine.checklistKeysFor(responseLevel),
      stageSummaryKeys: ScamAttackStageEngine.stageSummaryKeys(stage),
      chainConfidence: chainConfidence,
      confidenceBand: confidenceBand,
      evidenceStatus: sanitizedInput.evidenceStatus,
      safeVerificationKeys: safeVerificationKeys,
      chainNarrative: narrative,
      incidentGroupId: groupId,
    );

    return SimSwapSelfReportEscalation.applyToIncidentResult(assessed, yesCount);
  }
}
