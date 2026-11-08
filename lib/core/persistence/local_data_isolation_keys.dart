/// Base SharedPreferences keys for P0 local data isolation (namespace: `{uid}::{key}`).
abstract final class LocalDataIsolationKeys {
  // EOSB
  static const eosbOfflineCache = 'eosb_offline_cache';
  static const eosbCalculationHistory = 'eosb_calculation_history';
  static const eosbSalaryConsent = 'eosb_salary_consent';
  static const eosbLocale = 'eosb_locale';
  static const eosbReengagementTrigger = 'eosb_reengagement_session_trigger';
  static const eosbOvertimeInput = 'eosb_overtime_input';
  static const eosbOvertimeResult = 'eosb_overtime_result';
  static const eosbOvertimeHistory = 'eosb_overtime_history';

  // Sponsorship Transfer
  static const sponsorshipInput = 'sponsorship_transfer_input_v1';
  static const sponsorshipResult = 'sponsorship_transfer_result_v1';
  static const sponsorshipLocale = 'sponsorship_transfer_locale_v1';
  static const sponsorshipCheckDone = 'sponsorship_transfer_check_done_v1';
  static const sponsorshipChecklist = 'sponsorship_transfer_checklist_v1';

  // Tenancy
  static const tenancyLeaseInput = 'tenancy_lease_input_v1';
  static const tenancyComplianceResult = 'tenancy_compliance_result_v1';
  static const tenancyLocale = 'tenancy_locale_v1';
  static const tenancyCheckCompleted = 'tenancy_check_completed_v1';
  static const tenancyChecklist = 'tenancy_checklist_collected_v1';
  static const tenancyPacketMeta = 'tenancy_dispute_packet_meta_v1';

  static String tenancyConditionRecords(String leaseId) =>
      'tenancy_condition_records_v1_$leaseId';

  // Health Insurance
  static const hiComplianceInput = 'health_insurance_compliance_input_v1';
  static const hiComplianceResult = 'health_insurance_compliance_result_v1';
  static const hiInsurerHistory = 'health_insurance_insurer_history_v1';
  static const hiComplianceDone = 'health_insurance_compliance_done_v1';
  static const hiLastOpened = 'health_insurance_last_opened_v1';
  static const hiLocale = 'health_insurance_locale_v1';
  static const hiClaimDispute = 'health_insurance_claim_dispute_v1';
  static const hiClaimDisputeActiveId =
      'health_insurance_claim_dispute_active_id_v1';

  // Warranty
  static const warrantyItems = 'warranty_shield_items';

  // CV Maker (SharedPreferences layer)
  static const cvDocumentIds = 'cv_document_ids';
  static const cvLatestId = 'cv_latest_id';
  static const cvDocumentPrefix = 'cv_document_';

  static const allEosbKeys = [
    eosbOfflineCache,
    eosbCalculationHistory,
    eosbSalaryConsent,
    eosbLocale,
    eosbReengagementTrigger,
    eosbOvertimeInput,
    eosbOvertimeResult,
    eosbOvertimeHistory,
  ];

  static const allSponsorshipKeys = [
    sponsorshipInput,
    sponsorshipResult,
    sponsorshipLocale,
    sponsorshipCheckDone,
    sponsorshipChecklist,
  ];

  static const allTenancyKeys = [
    tenancyLeaseInput,
    tenancyComplianceResult,
    tenancyLocale,
    tenancyCheckCompleted,
    tenancyChecklist,
    tenancyPacketMeta,
  ];

  static const allHealthInsuranceKeys = [
    hiComplianceInput,
    hiComplianceResult,
    hiInsurerHistory,
    hiComplianceDone,
    hiLastOpened,
    hiLocale,
    hiClaimDispute,
    hiClaimDisputeActiveId,
  ];

  static const allWarrantyKeys = [warrantyItems];

  static const allCvIndexKeys = [cvDocumentIds, cvLatestId];
}
