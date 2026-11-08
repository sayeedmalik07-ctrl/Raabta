/// Verified labour dispute escalation steps for EOSB — informational only.
///
/// Do not add claims-filing flows; steps direct users to official channels.
class EosbLabourDisputeEscalationStepDef {
  const EosbLabourDisputeEscalationStepDef({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.supplementKey,
    this.isWsifStep = false,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  /// Optional follow-up copy shown immediately after [descriptionKey].
  final String? supplementKey;
  final bool isWsifStep;
}

abstract final class EosbLabourDisputeEscalationCatalog {
  static const step1FileComplaint = 'step_1_file_complaint';
  static const step2LdrcReferral = 'step_2_ldrc_referral';
  static const step3CommitteeDecision = 'step_3_committee_decision';
  static const step4WsifNonPayment = 'step_4_wsif_non_payment';

  static const all = [
    EosbLabourDisputeEscalationStepDef(
      id: step1FileComplaint,
      titleKey: 'eosb_dispute_step1_title',
      descriptionKey: 'eosb_dispute_step1_desc',
      supplementKey: 'eosb_dispute_step1_tracking',
    ),
    EosbLabourDisputeEscalationStepDef(
      id: step2LdrcReferral,
      titleKey: 'eosb_dispute_step2_title',
      descriptionKey: 'eosb_dispute_step2_desc',
    ),
    EosbLabourDisputeEscalationStepDef(
      id: step3CommitteeDecision,
      titleKey: 'eosb_dispute_step3_title',
      descriptionKey: 'eosb_dispute_step3_desc',
    ),
    EosbLabourDisputeEscalationStepDef(
      id: step4WsifNonPayment,
      titleKey: 'eosb_dispute_step4_title',
      descriptionKey: 'eosb_dispute_step4_body',
      isWsifStep: true,
    ),
  ];
}
