import 'package:raabta/features/scam_shield/data/scam_telecom_channels_config.dart';
import 'package:raabta/features/scam_shield/domain/scam_attack_stage_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_response_priority_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:raabta/features/scam_shield/domain/scam_signal_detector.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_self_report.dart';

/// Deterministic SIM/eSIM self-report engine — no AI, no telecom API calls.
abstract final class ScamSimSwapAnalyzer {
  static SimSwapAnalyzerResult analyze(SimSwapAnalyzerInput input) {
    final symptoms = input.symptoms;
    final textSignals = _signalsFromNotes(input.notes);
    var band = _bandFor(symptoms, textSignals);
    final stage = _stageFor(symptoms, textSignals);
    var responseLevel = _responseLevelFor(stage, band, symptoms);
    final yesCount = input.yesAnswerCount;

    if (yesCount >= 2) {
      band = _escalateBandForMultiYes(band);
      responseLevel = SimSwapSelfReportEscalation.bumpResponseLevel(
        responseLevel,
        yesCount,
      );
    }

    final urgency = SimSwapSelfReportMapper.urgencyFor(yesCount);

    return SimSwapAnalyzerResult(
      band: band,
      attackStage: stage,
      responseLevel: responseLevel,
      matchedSymptoms: symptoms,
      actionKeys: _actionKeysFor(band, responseLevel, urgency),
      telecomChannels: ScamTelecomChannelsConfig.channelsFor(input.provider),
      textSignals: textSignals,
      suggestIncidentMode: band == SimSwapRiskBand.critical ||
          stage.rank >= ScamAttackStage.suspectedCompromise.rank ||
          yesCount >= 2,
      selfReportUrgency: urgency,
      selfReportAnswers: input.selfReportAnswers,
      yesAnswerCount: yesCount,
    );
  }

  static Set<ScamRiskSignal> _signalsFromNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return const {};
    return ScamSignalDetector.detect(notes.trim())
        .map((d) => d.signal)
        .toSet();
  }

  static SimSwapRiskBand _bandFor(
    Set<SimSwapSymptom> symptoms,
    Set<ScamRiskSignal> textSignals,
  ) {
    if (symptoms.isEmpty && textSignals.isEmpty) {
      return SimSwapRiskBand.low;
    }

    if (symptoms.contains(SimSwapSymptom.financialActivityAfterSignalLoss)) {
      return SimSwapRiskBand.critical;
    }

    if ((symptoms.contains(SimSwapSymptom.noSignal) ||
            symptoms.contains(SimSwapSymptom.cannotReceiveSms)) &&
        (symptoms.contains(SimSwapSymptom.unexpectedOtp) ||
            textSignals.contains(ScamRiskSignal.otpRequest))) {
      return SimSwapRiskBand.critical;
    }

    if (symptoms.contains(SimSwapSymptom.esimChangeDiscussed) ||
        symptoms.contains(SimSwapSymptom.simChangeDiscussed) ||
        symptoms.contains(SimSwapSymptom.numberPortDiscussed) ||
        textSignals.contains(ScamRiskSignal.esimChange) ||
        textSignals.contains(ScamRiskSignal.simChange) ||
        textSignals.contains(ScamRiskSignal.numberPortRequest)) {
      return SimSwapRiskBand.high;
    }

    if (symptoms.contains(SimSwapSymptom.noSignal) ||
        symptoms.contains(SimSwapSymptom.unexpectedOtp) ||
        symptoms.contains(SimSwapSymptom.accountLoginIssues)) {
      return SimSwapRiskBand.high;
    }

    if (symptoms.contains(SimSwapSymptom.telecomImpersonationCall) ||
        symptoms.contains(SimSwapSymptom.cannotReceiveSms)) {
      return SimSwapRiskBand.moderate;
    }

    return SimSwapRiskBand.moderate;
  }

  static ScamAttackStage _stageFor(
    Set<SimSwapSymptom> symptoms,
    Set<ScamRiskSignal> textSignals,
  ) {
    final stages = <ScamAttackStage>[];

    if (symptoms.contains(SimSwapSymptom.telecomImpersonationCall) ||
        textSignals.any((s) => _impersonationSignals.contains(s))) {
      stages.add(ScamAttackStage.impersonation);
    }

    if (symptoms.contains(SimSwapSymptom.simChangeDiscussed) ||
        symptoms.contains(SimSwapSymptom.esimChangeDiscussed) ||
        symptoms.contains(SimSwapSymptom.numberPortDiscussed) ||
        symptoms.contains(SimSwapSymptom.noSignal) ||
        symptoms.contains(SimSwapSymptom.cannotReceiveSms) ||
        textSignals.contains(ScamRiskSignal.simChange) ||
        textSignals.contains(ScamRiskSignal.esimChange) ||
        textSignals.contains(ScamRiskSignal.numberPortRequest)) {
      stages.add(ScamAttackStage.simSwapRisk);
    }

    if (symptoms.contains(SimSwapSymptom.unexpectedOtp) ||
        symptoms.contains(SimSwapSymptom.accountLoginIssues) ||
        textSignals.contains(ScamRiskSignal.otpRequest) ||
        textSignals.contains(ScamRiskSignal.passwordReset)) {
      stages.add(ScamAttackStage.accountTakeoverRisk);
    }

    if (symptoms.contains(SimSwapSymptom.financialActivityAfterSignalLoss)) {
      stages.add(ScamAttackStage.simSwapRisk);
      stages.add(ScamAttackStage.financialAction);
    }

    if (stages.contains(ScamAttackStage.simSwapRisk) &&
        stages.contains(ScamAttackStage.financialAction)) {
      stages.add(ScamAttackStage.suspectedCompromise);
    }

    if (stages.isEmpty) return ScamAttackStage.contact;
    return ScamAttackStageX.highest(stages);
  }

  static ScamIncidentResponseLevel _responseLevelFor(
    ScamAttackStage stage,
    SimSwapRiskBand band,
    Set<SimSwapSymptom> symptoms,
  ) {
    final input = _incidentInputFromSymptoms(stage, symptoms);
    final chainConfidence = ScamResponsePriorityEngine.calculateChainConfidence(
      input: input,
    );
    final priority = ScamResponsePriorityEngine.calculatePriority(
      input: input,
      stage: stage,
      chainConfidence: chainConfidence,
    );
    var level = ScamResponsePriorityEngine.checklistLevelFor(priority);

    if (band == SimSwapRiskBand.critical &&
        level.rank < ScamIncidentResponseLevel.level4.rank) {
      level = ScamIncidentResponseLevel.level4;
    }

    return level;
  }

  static ScamIncidentInput _incidentInputFromSymptoms(
    ScamAttackStage stage,
    Set<SimSwapSymptom> symptoms,
  ) {
    final shared = <ScamSharedDataCategory>{};
    final outcomes = <ScamIncidentOutcome>{};

    if (symptoms.contains(SimSwapSymptom.simChangeDiscussed) ||
        symptoms.contains(SimSwapSymptom.esimChangeDiscussed) ||
        symptoms.contains(SimSwapSymptom.numberPortDiscussed)) {
      shared.add(ScamSharedDataCategory.simEsimInfo);
    }
    if (symptoms.contains(SimSwapSymptom.noSignal) ||
        symptoms.contains(SimSwapSymptom.cannotReceiveSms)) {
      outcomes.add(ScamIncidentOutcome.simPhoneStopped);
    }
    if (symptoms.contains(SimSwapSymptom.unexpectedOtp)) {
      shared.add(ScamSharedDataCategory.otp);
      outcomes.add(ScamIncidentOutcome.unexpectedOtp);
    }
    if (symptoms.contains(SimSwapSymptom.accountLoginIssues)) {
      outcomes.add(ScamIncidentOutcome.accountLocked);
    }
    if (symptoms.contains(SimSwapSymptom.financialActivityAfterSignalLoss)) {
      outcomes.add(ScamIncidentOutcome.unknownTransaction);
    }

    return ScamIncidentInput(
      impersonationCategory:
          symptoms.contains(SimSwapSymptom.telecomImpersonationCall)
              ? ScamImpersonationCategory.telecom
              : ScamImpersonationCategory.other,
      contactChannels: symptoms.contains(SimSwapSymptom.telecomImpersonationCall)
          ? {ScamContactChannel.phoneCall}
          : const {},
      sharedData: shared,
      outcomes: outcomes.isEmpty
          ? {ScamIncidentOutcome.nothingYet}
          : outcomes,
    );
  }

  static ScamIncidentInput incidentInputFromAnalysis(
    SimSwapAnalyzerResult analysis,
  ) {
    return _incidentInputFromSymptoms(
      analysis.attackStage,
      analysis.matchedSymptoms,
    );
  }

  static List<String> _actionKeysFor(
    SimSwapRiskBand band,
    ScamIncidentResponseLevel responseLevel,
    SimSwapSelfReportUrgency urgency,
  ) {
    final checklist = ScamAttackStageEngine.checklistKeysFor(responseLevel);
    if (band == SimSwapRiskBand.low && urgency == SimSwapSelfReportUrgency.calm) {
      return const [
        'ss_sim_action_monitor',
        'ss_sim_action_verify_operator',
      ];
    }
    if (urgency == SimSwapSelfReportUrgency.promptAction) {
      return [
        'ss_sim_action_contact_operator',
        'ss_sim_action_secure_accounts',
        ...checklist,
      ];
    }
    return [
      'ss_sim_action_contact_operator',
      ...checklist,
    ];
  }

  static SimSwapRiskBand _escalateBandForMultiYes(SimSwapRiskBand band) {
    return switch (band) {
      SimSwapRiskBand.low => SimSwapRiskBand.moderate,
      SimSwapRiskBand.moderate => SimSwapRiskBand.high,
      SimSwapRiskBand.high => SimSwapRiskBand.critical,
      SimSwapRiskBand.critical => SimSwapRiskBand.critical,
    };
  }

  static const _impersonationSignals = {
    ScamRiskSignal.authorityImpersonation,
    ScamRiskSignal.financialImpersonation,
    ScamRiskSignal.telecomImpersonation,
  };
}
