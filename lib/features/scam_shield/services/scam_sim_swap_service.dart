import 'package:raabta/features/scam_shield/domain/scam_chain_correlator.dart';
import 'package:raabta/features/scam_shield/domain/scam_response_priority_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_safe_verification_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_sensitive_input_mask.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_analyzer.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';

class SimSwapAssessmentResult {
  const SimSwapAssessmentResult({
    required this.analysis,
    required this.chainNarrative,
    required this.incidentGroupId,
  });

  final SimSwapAnalyzerResult analysis;
  final String? chainNarrative;
  final String? incidentGroupId;
}

/// Phase 3 SIM-swap assessment — deterministic, local-only.
class ScamSimSwapService {
  SimSwapAssessmentResult assess({
    required SimSwapAnalyzerInput input,
    List<ScamShieldHistoryEntry> recentHistory = const [],
  }) {
    final sanitizedNotes = input.notes == null
        ? null
        : ScamSensitiveInputMask.mask(input.notes!.trim());

    final sanitizedInput = SimSwapAnalyzerInput(
      provider: input.provider,
      symptoms: input.symptoms,
      notes: sanitizedNotes?.isEmpty ?? true ? null : sanitizedNotes,
      yesAnswerCount: input.yesAnswerCount,
      selfReportAnswers: input.selfReportAnswers,
    );

    final analysis = ScamSimSwapAnalyzer.analyze(sanitizedInput);

    final groupId = ScamChainCorrelator.resolveGroupId(
      recentEntries: recentHistory,
      stage: analysis.attackStage,
    );

    final narrative = ScamChainCorrelator.buildNarrative(
      recentEntries: recentHistory,
      current: _incidentProxy(analysis, groupId),
    );

    return SimSwapAssessmentResult(
      analysis: analysis,
      chainNarrative: narrative,
      incidentGroupId: groupId,
    );
  }

  static ScamIncidentAssessmentResult _incidentProxy(
    SimSwapAnalyzerResult analysis,
    String? groupId,
  ) {
    final input = ScamSimSwapAnalyzer.incidentInputFromAnalysis(analysis);
    final chainConfidence = ScamResponsePriorityEngine.calculateChainConfidence(
      input: input,
    );
    final priority = ScamResponsePriorityEngine.calculatePriority(
      input: input,
      stage: analysis.attackStage,
      chainConfidence: chainConfidence,
    );

    return ScamIncidentAssessmentResult(
      stage: analysis.attackStage,
      responsePriority: priority,
      responseLevel: analysis.responseLevel,
      compoundRisk: ScamCompoundRiskResult(
        band: _compoundBand(analysis.band),
        multiplier: 1,
        reasonKeys: analysis.matchedSymptoms
            .map((s) => s.labelKey)
            .take(3)
            .toList(),
      ),
      checklistActionKeys: analysis.actionKeys,
      stageSummaryKeys: const ['ss_stage_sim_swap'],
      chainConfidence: chainConfidence,
      confidenceBand: ScamResponsePriorityEngine.confidenceBand(chainConfidence),
      safeVerificationKeys: ScamSafeVerificationEngine.guidanceKeysFor(
        impersonation: input.impersonationCategory,
      ),
      incidentGroupId: groupId,
    );
  }

  static ScamCompoundRiskBand _compoundBand(SimSwapRiskBand band) {
    return switch (band) {
      SimSwapRiskBand.low => ScamCompoundRiskBand.low,
      SimSwapRiskBand.moderate => ScamCompoundRiskBand.medium,
      SimSwapRiskBand.high => ScamCompoundRiskBand.high,
      SimSwapRiskBand.critical => ScamCompoundRiskBand.critical,
    };
  }
}
