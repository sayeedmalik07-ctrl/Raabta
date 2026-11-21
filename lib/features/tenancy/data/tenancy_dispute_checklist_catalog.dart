/// Rental Dispute Committee filing checklist — verified document list only.
class DisputeChecklistItemDef {
  const DisputeChecklistItemDef({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    this.optional = false,
    this.scannerRoute,
    this.vaultRoute,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final bool optional;
  final String? scannerRoute;
  final String? vaultRoute;
}

abstract final class TenancyDisputeChecklistCatalog {
  static const items = [
    DisputeChecklistItemDef(
      id: 'claim_form_ar',
      titleKey: 'tenancy_doc_claim_form',
      subtitleKey: 'tenancy_doc_claim_form_sub',
    ),
    DisputeChecklistItemDef(
      id: 'explanatory_memo',
      titleKey: 'tenancy_doc_memo',
      subtitleKey: 'tenancy_doc_memo_sub',
    ),
    DisputeChecklistItemDef(
      id: 'registered_lease',
      titleKey: 'tenancy_doc_lease',
      subtitleKey: 'tenancy_doc_lease_sub',
      scannerRoute: '/scanner/capture',
      vaultRoute: '/document-vault',
    ),
    DisputeChecklistItemDef(
      id: 'property_condition_record',
      titleKey: 'tenancy_doc_condition',
      subtitleKey: 'tenancy_doc_condition_sub',
      scannerRoute: '/tenancy/condition',
    ),
    DisputeChecklistItemDef(
      id: 'ownership_deed',
      titleKey: 'tenancy_doc_ownership',
      subtitleKey: 'tenancy_doc_ownership_sub',
    ),
    DisputeChecklistItemDef(
      id: 'id_copies',
      titleKey: 'tenancy_doc_ids',
      subtitleKey: 'tenancy_doc_ids_sub',
    ),
    DisputeChecklistItemDef(
      id: 'power_of_attorney',
      titleKey: 'tenancy_doc_poa',
      subtitleKey: 'tenancy_doc_poa_sub',
      optional: true,
    ),
    DisputeChecklistItemDef(
      id: 'arabic_translation',
      titleKey: 'tenancy_doc_translation',
      subtitleKey: 'tenancy_doc_translation_sub',
    ),
  ];
}
