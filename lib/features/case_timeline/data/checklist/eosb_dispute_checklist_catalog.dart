import 'package:raabta/features/case_timeline/domain/case_timeline_checklist_item.dart';

/// EOSB dispute document checklist — stable ids for gap detection.
abstract final class EosbDisputeChecklistCatalog {
  static const contract = CaseTimelineChecklistItemDef(
    id: 'eosb_contract',
    titleKey: 'tpl_eosb_doc_contract',
    subtitleKey: 'ct_eosb_doc_contract_sub',
  );

  static const payslipsWps = CaseTimelineChecklistItemDef(
    id: 'eosb_payslips_wps',
    titleKey: 'tpl_eosb_doc_payslip',
    subtitleKey: 'ct_eosb_doc_payslip_sub',
  );

  static const settlementLetter = CaseTimelineChecklistItemDef(
    id: 'eosb_settlement_letter',
    titleKey: 'tpl_eosb_doc_settlement',
    subtitleKey: 'ct_eosb_doc_settlement_sub',
    optional: true,
  );

  static const qidPassport = CaseTimelineChecklistItemDef(
    id: 'eosb_qid_passport',
    titleKey: 'ct_eosb_doc_qid',
    subtitleKey: 'ct_eosb_doc_qid_sub',
  );

  static const correspondence = CaseTimelineChecklistItemDef(
    id: 'eosb_correspondence',
    titleKey: 'ct_eosb_doc_correspondence',
    subtitleKey: 'ct_eosb_doc_correspondence_sub',
  );

  static const photosVideos = CaseTimelineChecklistItemDef(
    id: 'eosb_photos_videos',
    titleKey: 'ct_eosb_doc_photos',
    subtitleKey: 'ct_eosb_doc_photos_sub',
  );

  static const witnessContacts = CaseTimelineChecklistItemDef(
    id: 'eosb_witness_contacts',
    titleKey: 'ct_eosb_doc_witness',
    subtitleKey: 'ct_eosb_doc_witness_sub',
  );

  static List<CaseTimelineChecklistItemDef> items({bool includeSettlement = true}) {
    return [
      contract,
      payslipsWps,
      if (includeSettlement) settlementLetter,
      qidPassport,
      correspondence,
      photosVideos,
      witnessContacts,
    ];
  }
}
