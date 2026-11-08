import 'package:scam_shield_core/features/scam_shield/domain/scam_incident_models.dart';

/// Deterministic attack-stage detection — highest stage reached wins.
abstract final class ScamAttackStageEngine {
  static ScamAttackStage detectStage(ScamIncidentInput input) {
    final stages = <ScamAttackStage>[];

    final shared = input.sharedData;
    final outcomes = input.outcomes;

    if (shared.isEmpty &&
        (outcomes.isEmpty || outcomes.every(_isBenignOutcome))) {
      stages.add(ScamAttackStage.contact);
    } else {
      stages.add(ScamAttackStage.impersonation);
    }

    if (_hasInformationHarvesting(shared)) {
      stages.add(ScamAttackStage.informationHarvesting);
    }

    if (_hasCredentialHarvesting(shared)) {
      stages.add(ScamAttackStage.credentialHarvesting);
    }

    if (shared.contains(ScamSharedDataCategory.otp)) {
      stages.add(ScamAttackStage.otpHarvesting);
    }

    if (shared.contains(ScamSharedDataCategory.simEsimInfo) ||
        outcomes.contains(ScamIncidentOutcome.simPhoneStopped)) {
      stages.add(ScamAttackStage.simSwapRisk);
    }

    if (outcomes.contains(ScamIncidentOutcome.passwordChanged) ||
        outcomes.contains(ScamIncidentOutcome.unexpectedOtp) ||
        outcomes.contains(ScamIncidentOutcome.accountLocked)) {
      stages.add(ScamAttackStage.accountTakeoverRisk);
    }

    if (outcomes.contains(ScamIncidentOutcome.unknownTransaction) ||
        outcomes.contains(ScamIncidentOutcome.moneyTransferred) ||
        outcomes.contains(ScamIncidentOutcome.cardCharged)) {
      stages.add(ScamAttackStage.financialAction);
    }

    if (_isSuspectedCompromise(stages, shared, outcomes)) {
      stages.add(ScamAttackStage.suspectedCompromise);
    }

    if (stages.contains(ScamAttackStage.financialAction) &&
        (stages.contains(ScamAttackStage.simSwapRisk) ||
            stages.contains(ScamAttackStage.accountTakeoverRisk) ||
            stages.contains(ScamAttackStage.otpHarvesting))) {
      stages.add(ScamAttackStage.incidentResponse);
    }

    if (stages.isEmpty) return ScamAttackStage.contact;
    return ScamAttackStageX.highest(stages);
  }

  static List<String> checklistKeysFor(ScamIncidentResponseLevel level) {
    return switch (level) {
      ScamIncidentResponseLevel.level1 => [
          'ss_ir_l1_stop',
          'ss_ir_l1_no_links',
          'ss_ir_l1_verify',
        ],
      ScamIncidentResponseLevel.level2 => [
          'ss_ir_l2_stop',
          'ss_ir_l2_secure',
          'ss_ir_l2_monitor',
        ],
      ScamIncidentResponseLevel.level3 => [
          'ss_ir_l3_stop',
          'ss_ir_l3_institution',
          'ss_ir_l3_credentials',
          'ss_ir_l3_review',
        ],
      ScamIncidentResponseLevel.level4 => [
          'ss_ir_l4_stop',
          'ss_ir_l4_telecom',
          'ss_ir_l4_email',
          'ss_ir_l4_financial',
          'ss_ir_l4_auth',
        ],
      ScamIncidentResponseLevel.level5 => [
          'ss_ir_l5_stop',
          'ss_ir_l5_bank',
          'ss_ir_l5_preserve',
          'ss_ir_l5_report',
          'ss_ir_l5_no_recovery',
        ],
    };
  }

  static List<String> stageSummaryKeys(ScamAttackStage stage) {
    return switch (stage) {
      ScamAttackStage.contact => ['ss_stage_contact'],
      ScamAttackStage.impersonation => ['ss_stage_impersonation'],
      ScamAttackStage.informationHarvesting => ['ss_stage_info_harvest'],
      ScamAttackStage.credentialHarvesting => ['ss_stage_cred_harvest'],
      ScamAttackStage.otpHarvesting => ['ss_stage_otp_harvest'],
      ScamAttackStage.simSwapRisk => ['ss_stage_sim_swap'],
      ScamAttackStage.accountTakeoverRisk => ['ss_stage_account_takeover'],
      ScamAttackStage.financialAction => ['ss_stage_financial'],
      ScamAttackStage.suspectedCompromise => ['ss_stage_suspected_compromise'],
      ScamAttackStage.incidentResponse => ['ss_stage_incident_response'],
    };
  }

  static bool _isBenignOutcome(ScamIncidentOutcome outcome) =>
      outcome == ScamIncidentOutcome.nothingYet;

  static bool _hasInformationHarvesting(Set<ScamSharedDataCategory> shared) {
    return shared.contains(ScamSharedDataCategory.qid) ||
        shared.contains(ScamSharedDataCategory.passport) ||
        shared.contains(ScamSharedDataCategory.drivingLicence) ||
        shared.contains(ScamSharedDataCategory.phoneConfirmation);
  }

  static bool _hasCredentialHarvesting(Set<ScamSharedDataCategory> shared) {
    return shared.contains(ScamSharedDataCategory.password) ||
        shared.contains(ScamSharedDataCategory.bankDetails) ||
        shared.contains(ScamSharedDataCategory.cardDetails);
  }

  static bool _isSuspectedCompromise(
    List<ScamAttackStage> stages,
    Set<ScamSharedDataCategory> shared,
    Set<ScamIncidentOutcome> outcomes,
  ) {
    final hasSim =
        stages.contains(ScamAttackStage.simSwapRisk) ||
            shared.contains(ScamSharedDataCategory.simEsimInfo);
    final hasFinancial = outcomes.contains(ScamIncidentOutcome.unknownTransaction) ||
        outcomes.contains(ScamIncidentOutcome.moneyTransferred) ||
        outcomes.contains(ScamIncidentOutcome.cardCharged);
    final hasTakeover = stages.contains(ScamAttackStage.accountTakeoverRisk);

    return (hasSim && hasFinancial) ||
        (hasTakeover && hasFinancial) ||
        (shared.contains(ScamSharedDataCategory.otp) && hasFinancial);
  }
}
