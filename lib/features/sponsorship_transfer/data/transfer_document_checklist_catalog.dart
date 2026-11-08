/// Verified checklist item — legal/procedural preparation only (not in-app filing).
class TransferChecklistItemDef {
  const TransferChecklistItemDef({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    this.informal = false,
    this.scannerRoute,
    this.vaultRoute,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;

  /// Informal practical checks — NOT verified legal requirements.
  final bool informal;
  final String? scannerRoute;
  final String? vaultRoute;
}

abstract final class TransferDocumentChecklistCatalog {
  static const verifiedItems = [
    TransferChecklistItemDef(
      id: 'previous_employer_contract',
      titleKey: 'st_doc_previous_contract',
      subtitleKey: 'st_doc_previous_contract_sub',
      scannerRoute: '/scanner/capture',
      vaultRoute: '/document-vault',
    ),
    TransferChecklistItemDef(
      id: 'change_employer_form',
      titleKey: 'st_doc_change_employer_form',
      subtitleKey: 'st_doc_change_employer_form_sub',
    ),
    TransferChecklistItemDef(
      id: 'formal_notice',
      titleKey: 'st_doc_formal_notice',
      subtitleKey: 'st_doc_formal_notice_sub',
    ),
    TransferChecklistItemDef(
      id: 'madlsa_notification',
      titleKey: 'st_doc_madlsa',
      subtitleKey: 'st_doc_madlsa_sub',
    ),
    TransferChecklistItemDef(
      id: 'new_employer_contract',
      titleKey: 'st_doc_new_contract',
      subtitleKey: 'st_doc_new_contract_sub',
      scannerRoute: '/scanner/capture',
      vaultRoute: '/document-vault',
    ),
    TransferChecklistItemDef(
      id: 'residence_permit_qid',
      titleKey: 'st_doc_permit_qid',
      subtitleKey: 'st_doc_permit_qid_sub',
      scannerRoute: '/scanner/capture',
      vaultRoute: '/document-vault',
    ),
  ];

  static const informalItems = [
    TransferChecklistItemDef(
      id: 'informal_wps',
      titleKey: 'st_doc_informal_wps',
      subtitleKey: 'st_doc_informal_wps_sub',
      informal: true,
    ),
    TransferChecklistItemDef(
      id: 'informal_fines',
      titleKey: 'st_doc_informal_fines',
      subtitleKey: 'st_doc_informal_fines_sub',
      informal: true,
    ),
  ];

  static List<TransferChecklistItemDef> get all => [
        ...verifiedItems,
        ...informalItems,
      ];
}
