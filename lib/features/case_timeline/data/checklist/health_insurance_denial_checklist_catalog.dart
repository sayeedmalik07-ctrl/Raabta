import 'package:raabta/features/case_timeline/domain/case_timeline_checklist_item.dart';

/// Part C claim denial dispute — document checklist (deterministic).
abstract final class HealthInsuranceDenialChecklistCatalog {
  static const items = [
    CaseTimelineChecklistItemDef(
      id: 'hi_denial_letter',
      titleKey: 'hi_denial_doc_letter',
      subtitleKey: 'hi_denial_doc_letter_sub',
    ),
    CaseTimelineChecklistItemDef(
      id: 'hi_policy_card',
      titleKey: 'hi_denial_doc_policy',
      subtitleKey: 'hi_denial_doc_policy_sub',
    ),
    CaseTimelineChecklistItemDef(
      id: 'hi_premium_proof',
      titleKey: 'hi_denial_doc_premium',
      subtitleKey: 'hi_denial_doc_premium_sub',
    ),
    CaseTimelineChecklistItemDef(
      id: 'hi_medical_reports',
      titleKey: 'hi_denial_doc_medical',
      subtitleKey: 'hi_denial_doc_medical_sub',
    ),
    CaseTimelineChecklistItemDef(
      id: 'hi_insurer_correspondence',
      titleKey: 'hi_denial_doc_correspondence',
      subtitleKey: 'hi_denial_doc_correspondence_sub',
    ),
    CaseTimelineChecklistItemDef(
      id: 'hi_complaint_proof',
      titleKey: 'hi_denial_doc_complaint',
      subtitleKey: 'hi_denial_doc_complaint_sub',
    ),
    CaseTimelineChecklistItemDef(
      id: 'hi_regulator_escalation',
      titleKey: 'hi_denial_doc_regulator',
      subtitleKey: 'hi_denial_doc_regulator_sub',
      optional: true,
    ),
  ];
}

/// Milestone steps for denial dispute — "Mark as done" can spawn timeline rows.
class HealthInsuranceDenialStepDef {
  const HealthInsuranceDenialStepDef({
    required this.id,
    required this.titleKey,
    required this.timelineTitleKey,
    required this.checklistItemId,
  });

  final String id;
  final String titleKey;
  final String timelineTitleKey;
  final String checklistItemId;
}

abstract final class HealthInsuranceDenialStepCatalog {
  static const steps = [
    HealthInsuranceDenialStepDef(
      id: 'denial_received',
      titleKey: 'hi_denial_step_denial',
      timelineTitleKey: 'hi_denial_timeline_denial',
      checklistItemId: 'hi_denial_letter',
    ),
    HealthInsuranceDenialStepDef(
      id: 'complaint_filed',
      titleKey: 'hi_denial_step_complaint',
      timelineTitleKey: 'hi_denial_timeline_complaint',
      checklistItemId: 'hi_complaint_proof',
    ),
    HealthInsuranceDenialStepDef(
      id: 'regulator_escalation',
      titleKey: 'hi_denial_step_regulator',
      timelineTitleKey: 'hi_denial_timeline_regulator',
      checklistItemId: 'hi_regulator_escalation',
    ),
  ];
}
