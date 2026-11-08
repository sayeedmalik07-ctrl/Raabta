import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:raabta/features/health_insurance/domain/models/insurer_regulatory_body.dart';

/// Verified escalation steps — do not add steps beyond this catalog.
class ClaimDisputeStepDef {
  const ClaimDisputeStepDef({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.citationKey,
    this.tipKey,
    this.employerOnly = false,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String? citationKey;
  final String? tipKey;
  final bool employerOnly;
}

abstract final class ClaimDisputeStepCatalog {
  static const step1WrittenLetter = 'step_1_written_letter';
  static const step2InsurerComplaints = 'step_2_insurer_complaints';
  static const step3Regulator = 'step_3_regulator';
  static const step4MophEmployer = 'step_4_moph_employer';

  static const all = [
    ClaimDisputeStepDef(
      id: step1WrittenLetter,
      titleKey: 'hi_denial_step1_title',
      descriptionKey: 'hi_denial_step1_desc',
    ),
    ClaimDisputeStepDef(
      id: step2InsurerComplaints,
      titleKey: 'hi_denial_step2_title',
      descriptionKey: 'hi_denial_step2_desc',
      tipKey: 'hi_denial_step2_medical_tip',
    ),
    ClaimDisputeStepDef(
      id: step3Regulator,
      titleKey: 'hi_denial_step3_qcb_title',
      descriptionKey: 'hi_denial_step3_qcb_desc',
      citationKey: 'hi_denial_step3_qcb_cite',
    ),
    ClaimDisputeStepDef(
      id: step4MophEmployer,
      titleKey: 'hi_denial_step4_title',
      descriptionKey: 'hi_denial_step4_desc',
      employerOnly: true,
    ),
  ];

  static List<ClaimDisputeStepDef> stepsFor({
    required InsurerRegulatoryBody regulatoryBody,
    required bool employerProvidedCoverage,
    required ClaimDenialReasonCategory denialReason,
  }) {
    final steps = <ClaimDisputeStepDef>[];
    for (final step in all) {
      if (step.employerOnly && !employerProvidedCoverage) continue;
      if (step.id == step3Regulator) {
        steps.add(
          ClaimDisputeStepDef(
            id: step.id,
            titleKey: regulatoryBody == InsurerRegulatoryBody.qfcra
                ? 'hi_denial_step3_qfcra_title'
                : 'hi_denial_step3_qcb_title',
            descriptionKey: regulatoryBody == InsurerRegulatoryBody.qfcra
                ? 'hi_denial_step3_qfcra_desc'
                : 'hi_denial_step3_qcb_desc',
            citationKey: regulatoryBody == InsurerRegulatoryBody.qfcra
                ? 'hi_denial_step3_qfcra_cite'
                : 'hi_denial_step3_qcb_cite',
          ),
        );
      } else if (step.id == step2InsurerComplaints &&
          denialReason == ClaimDenialReasonCategory.medicalNecessity) {
        steps.add(step);
      } else if (step.id == step2InsurerComplaints) {
        steps.add(
          ClaimDisputeStepDef(
            id: step.id,
            titleKey: step.titleKey,
            descriptionKey: step.descriptionKey,
          ),
        );
      } else {
        steps.add(step);
      }
    }
    return steps;
  }

  static bool isLocked({
    required ClaimDisputeStepDef step,
    required HealthInsuranceClaimDispute dispute,
    required List<ClaimDisputeStepDef> orderedSteps,
  }) {
    if (!dispute.hasWrittenDenialLetter &&
        !dispute.isStepComplete(step1WrittenLetter)) {
      final step1Index =
          orderedSteps.indexWhere((s) => s.id == step1WrittenLetter);
      final thisIndex = orderedSteps.indexWhere((s) => s.id == step.id);
      if (thisIndex > step1Index && step1Index >= 0) return true;
    }
    return false;
  }
}
