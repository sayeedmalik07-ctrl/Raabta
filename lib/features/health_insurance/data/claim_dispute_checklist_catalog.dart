import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';

class ClaimDisputeChecklistItemDef {
  const ClaimDisputeChecklistItemDef({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
}

/// Deterministic document checklist — varies by denial reason and coverage type.
abstract final class ClaimDisputeChecklistCatalog {
  static const writtenDenialLetter = ClaimDisputeChecklistItemDef(
    id: 'claim_denial_letter',
    titleKey: 'hi_denial_doc_letter',
    subtitleKey: 'hi_denial_doc_letter_sub',
  );

  static const policySchedule = ClaimDisputeChecklistItemDef(
    id: 'claim_policy_schedule',
    titleKey: 'hi_denial_doc_policy',
    subtitleKey: 'hi_denial_doc_policy_sub',
  );

  static const employerCoverage = ClaimDisputeChecklistItemDef(
    id: 'claim_employer_coverage',
    titleKey: 'hi_denial_doc_employer',
    subtitleKey: 'hi_denial_doc_employer_sub',
  );

  static const treatmentNotes = ClaimDisputeChecklistItemDef(
    id: 'claim_treatment_notes',
    titleKey: 'hi_denial_doc_medical',
    subtitleKey: 'hi_denial_doc_medical_sub',
  );

  static const preAuth = ClaimDisputeChecklistItemDef(
    id: 'claim_pre_auth',
    titleKey: 'hi_denial_doc_preauth',
    subtitleKey: 'hi_denial_doc_preauth_sub',
  );

  static const correspondence = ClaimDisputeChecklistItemDef(
    id: 'claim_correspondence',
    titleKey: 'hi_denial_doc_correspondence',
    subtitleKey: 'hi_denial_doc_correspondence_sub',
  );

  static List<ClaimDisputeChecklistItemDef> itemsFor({
    required ClaimDenialReasonCategory denialReason,
    required bool employerProvidedCoverage,
  }) {
    final items = <ClaimDisputeChecklistItemDef>[
      writtenDenialLetter,
      policySchedule,
    ];
    if (employerProvidedCoverage) {
      items.add(employerCoverage);
    }
    if (denialReason == ClaimDenialReasonCategory.medicalNecessity) {
      items.add(treatmentNotes);
    }
    if (denialReason == ClaimDenialReasonCategory.preAuthNotObtained) {
      items.add(preAuth);
    }
    items.add(correspondence);
    return items;
  }
}
