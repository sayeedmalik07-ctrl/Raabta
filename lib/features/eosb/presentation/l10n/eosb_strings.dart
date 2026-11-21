/// EOSB localized strings — 9 locales via [AppLocale.supportedLocales].
/// TODO-TRANSLATE-REVIEW: Tamil legal terminology pending native review.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class EosbStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Tamil legal/labour strings need native review before production sign-off.
  static const keysNeedingProfessionalReview = <String>{
    'employer_track_record_body',
    'employer_track_record_velocity_line',
    'employer_track_record_disclaimer',
    'employer_track_record_insufficient',
    'employer_track_record_lookup_title',
    'employer_track_record_lookup_subtitle',
    'employer_track_record_lookup_hint',
    'employer_track_record_lookup_example_hint',
    'employer_track_record_lookup_action',
    'employer_track_record_home_link',
    'employer_track_record_check_employer_button',
    'employer_pre_offer_checklist_title',
    'employer_pre_offer_check_recruitment_costs',
    'employer_pre_offer_check_official_email',
    'employer_pre_offer_check_written_offer',
    'employer_pre_offer_check_take_time',
    'agency_verify_screen_title',
    'agency_verify_screen_subtitle',
    'agency_verify_country_heading',
    'agency_verify_open_portal',
    'agency_verify_disclaimer',
    'agency_verify_home_link',
    'agency_verify_generic_not_confirmed',
    'agency_verify_india_not_confirmed',
    'agency_verify_nepal_authority',
    'agency_verify_nepal_search',
    'agency_verify_nepal_good_standing',
    'agency_verify_nepal_vacancy',
    'agency_verify_ph_authority',
    'agency_verify_ph_search',
    'agency_verify_ph_good_standing',
    'agency_verify_checklist_title',
    'agency_verify_check_payment_before_contract',
    'agency_verify_check_recruitment_costs',
    'agency_verify_check_tourist_visa',
    'agency_verify_check_receipts',
    'agency_verify_check_messaging_only',
    'eosb_ai_assistant',
    'eosb_ai_disclaimer',
    'eosb_ai_error',
    'eosb_ai_key_risks',
    'eosb_ai_prompt_breakdown',
    'eosb_ai_prompt_dispute',
    'eosb_ai_prompt_fair',
    'eosb_ai_prompt_rights',
    'eosb_ai_regenerate',
    'eosb_ai_suggested_prompts',
    'eosb_ai_summary',
    'eosb_analyze_contract',
    'eosb_analyzing',
    'eosb_annual_bonus',
    'eosb_annual_bonus_example',
    'eosb_annual_bonus_formula',
    'eosb_annual_bonus_rule',
    'eosb_basic_salary',
    'eosb_breakdown_chart',
    'eosb_bys_collapse',
    'eosb_bys_expand',
    'eosb_bys_fee_heading',
    'eosb_bys_flags_heading',
    'eosb_bys_india_emigrate_link_desc',
    'eosb_bys_india_emigrate_link_title',
    'eosb_bys_india_fee',
    'eosb_bys_india_fee_bill_warning',
    'eosb_bys_india_flag_agency_not_emigrate',
    'eosb_bys_india_flag_emigration_not_cleared',
    'eosb_bys_india_flag_no_written_contract',
    'eosb_bys_india_flag_pay_before_contract',
    'eosb_bys_moi_desc',
    'eosb_bys_moi_title',
    'eosb_bys_nepal_fee',
    'eosb_bys_nepal_feims_link_desc',
    'eosb_bys_nepal_feims_link_title',
    'eosb_bys_nepal_flag_agency_not_feims',
    'eosb_bys_nepal_flag_no_orientation',
    'eosb_bys_nepal_flag_no_written_contract',
    'eosb_bys_nepal_flag_pay_before_permit',
    'eosb_bys_offer_comm_free_email',
    'eosb_bys_offer_comm_heading',
    'eosb_bys_offer_comm_messaging_only',
    'eosb_bys_offer_comm_no_call',
    'eosb_bys_offer_comm_pressure',
    'eosb_bys_offer_doc_heading',
    'eosb_bys_offer_doc_informal_only',
    'eosb_bys_offer_doc_no_contract',
    'eosb_bys_offer_doc_no_registration',
    'eosb_bys_offer_doc_vague_details',
    'eosb_bys_offer_pay_before_contract',
    'eosb_bys_offer_pay_fee_mismatch',
    'eosb_bys_offer_pay_heading',
    'eosb_bys_offer_pay_untraceable',
    'eosb_bys_offer_real_intro',
    'eosb_bys_offer_real_title',
    'eosb_bys_offer_verify_agency',
    'eosb_bys_offer_verify_contract',
    'eosb_bys_offer_verify_employer',
    'eosb_bys_offer_verify_heading',
    'eosb_bys_origin_verify_heading',
    'eosb_bys_ph_dmw_link_desc',
    'eosb_bys_ph_dmw_link_title',
    'eosb_bys_ph_fee',
    'eosb_bys_ph_flag_no_dmw_contract',
    'eosb_bys_ph_flag_pay_before_contract',
    'eosb_bys_ph_flag_salary_mismatch',
    'eosb_bys_ph_flag_unlicensed_agency',
    'eosb_bys_qatar_verify_heading',
    'eosb_bys_qvc_desc',
    'eosb_bys_qvc_title',
    'eosb_bys_section_subtitle',
    'eosb_bys_section_title',
    'eosb_bys_verify_disclaimer',
    'eosb_calculate_cta',
    'eosb_history_load_error_desc',
    'eosb_history_load_error',
    'eosb_salary_claude_consent_required',
    'eosb_history_metadata_only',
    'eosb_history_save_failed',
    'eosb_history_corrupt_write_blocked',
    'eosb_history_corrupt_empty_title',
    'eosb_history_corrupt_empty_desc',
    'eosb_history_corrupt_delete_blocked',
    'eosb_history_corrupt_banner',
    'ot_history_corrupt_banner',
    'ot_history_hydration_failed_desc',
    'ot_history_hydration_failed',
    'ot_history_corrupt_empty_desc',
    'ot_history_corrupt_empty_title',
    'eosb_history_consent_limited',
    'eosb_cloud_sync_failed',
    'eosb_commission',
    'eosb_commission_example',
    'eosb_commission_formula',
    'eosb_commission_rule',
    'eosb_company_name',
    'eosb_comparison',
    'eosb_comparison_details',
    'eosb_confidence',
    'eosb_continue_employee_info',
    'eosb_contract_analysis',
    'eosb_contract_analysis_desc',
    'eosb_contract_applied',
    'eosb_contract_paste_hint',
    'eosb_contract_paste_label',
    'eosb_contract_quality_garbled',
    'eosb_contract_quality_ocr',
    'eosb_contract_quality_short',
    'eosb_contract_quality_words',
    'eosb_contract_risks',
    'eosb_contract_text_short',
    'eosb_contract_type',
    'eosb_deadlines',
    'eosb_difference',
    'eosb_disclaimer',
    'eosb_disclaimer_law9',
    'eosb_dispute_action_request',
    'eosb_dispute_escalation_disclaimer',
    'eosb_dispute_escalation_subtitle',
    'eosb_dispute_escalation_title',
    'eosb_dispute_step1_desc',
    'eosb_dispute_step1_title',
    'eosb_dispute_step1_tracking',
    'eosb_dispute_step2_desc',
    'eosb_dispute_step2_title',
    'eosb_dispute_step3_desc',
    'eosb_dispute_step3_title',
    'eosb_dispute_step4_action',
    'eosb_dispute_step4_body',
    'eosb_dispute_step4_known',
    'eosb_dispute_step4_title',
    'eosb_dispute_step4_unknown',
    'eosb_dispute_step4_wsif_link',
    'eosb_document_type',
    'eosb_documents',
    'eosb_employee_info',
    'eosb_employer_offer',
    'eosb_employment_category',
    'eosb_employment_freelance',
    'eosb_employment_full_time',
    'eosb_employment_part_time',
    'eosb_empty_comparison_desc',
    'eosb_empty_comparison_title',
    'eosb_empty_history',
    'eosb_empty_history_desc',
    'eosb_empty_result_desc',
    'eosb_empty_result_title',
    'eosb_empty_warnings_desc',
    'eosb_empty_warnings_title',
    'eosb_estimated_total',
    'eosb_example_label',
    'eosb_explanation_default',
    'eosb_explanation_summary',
    'eosb_fab_description',
    'eosb_family_ticket',
    'eosb_family_ticket_example',
    'eosb_family_ticket_formula',
    'eosb_family_ticket_rule',
    'eosb_gratuity',
    'eosb_gratuity_example',
    'eosb_gratuity_example_none',
    'eosb_gratuity_example_strike_incitement',
    'eosb_gratuity_formula',
    'eosb_gratuity_formula_none',
    'eosb_gratuity_formula_strike_incitement_none',
    'eosb_gratuity_rule',
    'eosb_gratuity_rule_min_service',
    'eosb_gratuity_rule_strike_incitement_law9',
    'eosb_hcs_coming_soon',
    'eosb_hcs_contact_address',
    'eosb_hcs_contact_hotline',
    'eosb_hcs_contact_hours',
    'eosb_hcs_contact_labour_email',
    'eosb_hcs_contact_labour_phone',
    'eosb_hcs_contact_labour_phone_alt',
    'eosb_hcs_contact_phone',
    'eosb_hcs_country_india',
    'eosb_hcs_country_nepal',
    'eosb_hcs_country_philippines',
    'agency_verify_origin_country_heading',
    'agency_verify_origin_country_hint',
    'eosb_hcs_dismiss',
    'eosb_hcs_emigrate_desc',
    'eosb_hcs_emigrate_title',
    'eosb_hcs_india_embassy_desc',
    'eosb_hcs_india_embassy_title',
    'eosb_hcs_kerala_section_title',
    'eosb_hcs_madad_desc',
    'eosb_hcs_madad_title',
    'eosb_hcs_ndprem_desc',
    'eosb_hcs_ndprem_title',
    'eosb_hcs_nepal_dofa_desc',
    'eosb_hcs_nepal_dofa_title',
    'eosb_hcs_nepal_feb_desc',
    'eosb_hcs_nepal_feb_title',
    'eosb_hcs_nepal_pre_departure_desc',
    'eosb_hcs_nepal_pre_departure_title',
    'eosb_hcs_norka_care_desc',
    'eosb_hcs_norka_care_title',
    'eosb_hcs_pbsk_desc',
    'eosb_hcs_pbsk_hours_value',
    'eosb_hcs_pbsk_title',
    'eosb_hcs_ph_dmw_desc',
    'eosb_hcs_ph_dmw_title',
    'eosb_hcs_ph_mwo_desc',
    'eosb_hcs_ph_mwo_title',
    'eosb_hcs_ph_owwa_desc',
    'eosb_hcs_ph_owwa_title',
    'eosb_hcs_pravasi_legal_aid_desc',
    'eosb_hcs_pravasi_legal_aid_title',
    'eosb_hcs_section_subtitle',
    'eosb_hcs_section_title',
    'eosb_hcs_verify_badge',
    'eosb_history',
    'eosb_history_unnamed',
    'eosb_hub_explore',
    'eosb_hub_your_tools',
    'eosb_illegal_clauses',
    'eosb_import_vault',
    'eosb_joining_date',
    'eosb_labour_law_issues',
    'eosb_last_working_date',
    'eosb_leave',
    'eosb_leave_example',
    'eosb_leave_formula',
    'eosb_leave_formula_none',
    'eosb_leave_rule',
    'eosb_legal_freshness',
    'eosb_legal_freshness_loading',
    'eosb_legal_update_banner',
    'eosb_legal_update_recalculate',
    'eosb_legal_review',
    'eosb_load_error',
    'eosb_missing_benefits',
    'eosb_missing_payments',
    'eosb_negotiation_advice',
    'eosb_next_steps',
    'eosb_notice',
    'eosb_notice_example',
    'eosb_notice_formula',
    'eosb_notice_formula_none',
    'eosb_notice_rule',
    'eosb_notice_served',
    'eosb_notice_served_sub',
    'eosb_art67_section_title',
    'eosb_art67_section_sub',
    'eosb_art49_notice_question',
    'eosb_art49_notice_yes',
    'eosb_art49_notice_no',
    'eosb_art49_notice_unsure',
    'eosb_art62_optional_cta',
    'eosb_art62_skip',
    'eosb_art62_reopen',
    'eosb_art62_section_title',
    'eosb_art62_section_sub',
    'eosb_art62_disclaimer',
    'eosb_art62_q1_reason_given',
    'eosb_art62_q2_matches_art61',
    'eosb_art62_art61_grounds_list',
    'eosb_art62_q3_process_followed',
    'eosb_art62_yes',
    'eosb_art62_no',
    'eosb_art62_result_section_title',
    'eosb_art62_result_section_sub',
    'eosb_art62_known',
    'eosb_art62_possible',
    'eosb_art62_unknown',
    'eosb_art62_action',
    'eosb_dismissal_review_art61_info',
    'eosb_dismissal_review_art62_info',
    'eosb_dismissal_review_art64_info',
    'eosb_contract_termination_date',
    'eosb_date_of_leaving_work',
    'eosb_contract_termination_same_as_last',
    'eosb_date_of_leaving_same_as_last',
    'eosb_ot_calculate_precisely',
    'eosb_privacy_security',
    'eosb_ot_calculate_precisely_desc',
    'eosb_other_benefits',
    'eosb_other_benefits_example',
    'eosb_other_benefits_formula',
    'eosb_other_benefits_rule',
    'eosb_overtime',
    'eosb_overtime_example',
    'eosb_overtime_formula',
    'eosb_overtime_formula_none',
    'eosb_overtime_rule',
    'eosb_pdf_breakdown',
    'eosb_pdf_company',
    'eosb_pdf_date',
    'eosb_pdf_difference',
    'eosb_pdf_employee',
    'eosb_pdf_estimate',
    'eosb_pdf_offer',
    'eosb_pdf_share_text',
    'eosb_payslip_action_hr',
    'eosb_payslip_add_row',
    'eosb_payslip_add_timeline',
    'eosb_payslip_basic_salary',
    'eosb_payslip_contract_known',
    'eosb_payslip_disc_basic_both',
    'eosb_payslip_disc_basic_contract',
    'eosb_payslip_disc_basic_pair',
    'eosb_payslip_disc_employer_contract',
    'eosb_payslip_disc_employer_pair',
    'eosb_payslip_disc_housing',
    'eosb_payslip_disc_missing_month',
    'eosb_payslip_disc_transport',
    'eosb_payslip_employer',
    'eosb_payslip_hide_optional',
    'eosb_payslip_housing',
    'eosb_payslip_hub_button',
    'eosb_payslip_month',
    'eosb_payslip_need_more',
    'eosb_payslip_no_accusation',
    'eosb_payslip_no_contract',
    'eosb_payslip_no_discrepancies',
    'eosb_payslip_not_set',
    'eosb_payslip_possible_framing',
    'eosb_payslip_progress',
    'eosb_payslip_results_heading',
    'eosb_payslip_row_label',
    'eosb_payslip_run',
    'eosb_payslip_set_contract',
    'eosb_payslip_show_optional',
    'eosb_payslip_subtitle',
    'eosb_payslip_timeline_saved',
    'eosb_payslip_timeline_title',
    'eosb_payslip_title',
    'eosb_payslip_transport',
    'eosb_payslip_verify_suffix',
    'eosb_payslip_year',
    'eosb_pending_salary',
    'eosb_pending_salary_example',
    'eosb_pending_salary_formula',
    'eosb_pending_salary_rule',
    'eosb_possible_underpayment',
    'eosb_qatar_16008_desc',
    'eosb_qatar_16008_hours_value',
    'eosb_qatar_16008_title',
    'eosb_qatar_nas_desc',
    'eosb_qatar_nas_title',
    'eosb_qatar_section_subtitle',
    'eosb_qatar_section_title',
    'eosb_qatar_sms_desc',
    'eosb_qatar_sms_format_label',
    'eosb_qatar_sms_format_value',
    'eosb_qatar_sms_title',
    'eosb_qatar_ucp_desc',
    'eosb_qatar_ucp_title',
    'eosb_recalculate_cta',
    'eosb_required_documents',
    'eosb_results',
    'eosb_retention_bonus',
    'eosb_retention_bonus_example',
    'eosb_retention_bonus_formula',
    'eosb_retention_bonus_rule',
    'eosb_return_ticket',
    'eosb_return_ticket_contract',
    'eosb_risk_critical',
    'eosb_risk_high',
    'eosb_risk_medium',
    'eosb_save_consent',
    'eosb_scan_document',
    'eosb_scenario_base',
    'eosb_scenario_breakdown',
    'eosb_scenario_contract_expires',
    'eosb_scenario_contract_expires_desc',
    'eosb_scenario_employer_terminates',
    'eosb_scenario_employer_terminates_desc',
    'eosb_scenario_mutual',
    'eosb_scenario_mutual_desc',
    'eosb_scenario_resign_next_month',
    'eosb_scenario_resign_next_month_desc',
    'eosb_scenario_resign_today',
    'eosb_scenario_resign_today_desc',
    'eosb_scenario_salary_up',
    'eosb_scenario_salary_up_desc',
    'eosb_scenario_six_months',
    'eosb_scenario_six_months_desc',
    'eosb_scenario_tap_expand',
    'eosb_scenarios',
    'eosb_scenarios_desc',
    'eosb_scenarios_empty_desc',
    'eosb_scenarios_empty_title',
    'eosb_section_benefits',
    'eosb_section_benefits_sub',
    'eosb_section_employment',
    'eosb_section_employment_sub',
    'eosb_section_separation',
    'eosb_section_separation_sub',
    'eosb_select_date',
    'eosb_settings',
    'eosb_share',
    'eosb_status',
    'eosb_status_low_confidence',
    'eosb_status_ready',
    'eosb_status_underpayment',
    'eosb_step_compare_adlsa',
    'eosb_step_compare_document',
    'eosb_step_compare_fair',
    'eosb_step_compare_hr',
    'eosb_step_gratuity',
    'eosb_step_leave',
    'eosb_step_notice',
    'eosb_step_ticket',
    'eosb_subtitle',
    'eosb_summary_dismissal_confirm',
    'eosb_summary_dismissal_ground',
    'eosb_summary_dismissal_none',
    'eosb_summary_dismissal_strike',
    'eosb_termination_type',
    'eosb_ticket_example',
    'eosb_ticket_formula',
    'eosb_ticket_rule',
    'eosb_timeline',
    'eosb_timeline_confirmation',
    'eosb_timeline_confirmation_desc',
    'eosb_timeline_empty',
    'eosb_timeline_empty_desc',
    'eosb_timeline_empty_title',
    'eosb_timeline_eosb_calc',
    'eosb_timeline_eosb_calc_desc',
    'eosb_timeline_joining',
    'eosb_timeline_joining_desc',
    'eosb_timeline_last_day',
    'eosb_timeline_last_day_desc',
    'eosb_timeline_probation',
    'eosb_timeline_probation_desc',
    'eosb_timeline_settlement',
    'eosb_timeline_settlement_desc',
    'eosb_title',
    'eosb_total_salary',
    'eosb_validation_basic_salary',
    'eosb_validation_date_order',
    'eosb_validation_dates',
    'eosb_view_results',
    'eosb_violation_gratuity_missing',
    'eosb_violation_gratuity_missing_exp',
    'eosb_violation_min_service',
    'eosb_violation_min_service_exp',
    'eosb_violation_salary_basis',
    'eosb_violation_salary_basis_exp',
    'eosb_violation_salary_basis_rule',
    'eosb_warn_employment_coverage_law9',
    'eosb_warn_employment_coverage_law9_action',
    'eosb_warn_employment_coverage_law9_exp',
    'eosb_warn_leave_encashment',
    'eosb_warn_leave_encashment_action',
    'eosb_warn_leave_encashment_exp',
    'eosb_warn_notice_comp',
    'eosb_warn_notice_comp_action',
    'eosb_warn_notice_comp_exp',
    'eosb_warn_pending_salary',
    'eosb_warn_pending_salary_action',
    'eosb_warn_pending_salary_exp',
    'eosb_warn_strike_incitement_gratuity',
    'eosb_warn_strike_incitement_gratuity_action',
    'eosb_warn_strike_incitement_gratuity_exp',
    'eosb_warn_strike_incitement_unconfirmed',
    'eosb_warn_strike_incitement_unconfirmed_action',
    'eosb_warn_strike_incitement_unconfirmed_exp',
    'eosb_warn_strike_predates_law9',
    'eosb_warn_strike_predates_law9_action',
    'eosb_warn_strike_predates_law9_exp',
    'eosb_employment_coverage_scope_notice',
    'eosb_employment_reference_opt_in',
    'eosb_employment_reference_opt_in_sub',
    'eosb_employment_reference_required',
    'eosb_reference_total',
    'eosb_reference_banner_title',
    'eosb_reference_banner_body',
    'eosb_transition_bank_title',
    'eosb_transition_bank_body',
    'eosb_transition_health_title',
    'eosb_transition_health_body',
    'eosb_notice_rule_strike_incitement_law9',
    'eosb_warn_total_below_basic',
    'eosb_warn_total_below_basic_action',
    'eosb_warn_total_below_basic_exp',
    'eosb_warnings',
    'eosb_warnings_banner_body',
    'eosb_warnings_banner_title',
    'eosb_your_estimate',
    'ot_ai_calc_explain',
    'ot_ai_errors',
    'ot_ai_explain',
    'ot_ai_missing',
    'ot_ai_next',
    'ot_ai_questions',
    'ot_ai_refresh',
    'ot_ai_review',
    'ot_ai_summary',
    'ot_ai_tips',
    'ot_alert_hours_mismatch',
    'ot_alert_hours_mismatch_body',
    'ot_alert_missing_days',
    'ot_alert_missing_days_body',
    'ot_alert_no_overtime',
    'ot_alert_no_overtime_body',
    'ot_alert_no_salary',
    'ot_alert_no_salary_body',
    'ot_alert_overpaid',
    'ot_alert_overpaid_body',
    'ot_alert_ramadan',
    'ot_alert_ramadan_body',
    'ot_alert_unpaid',
    'ot_alert_unpaid_body',
    'ot_alert_weekly_cap',
    'ot_alert_weekly_cap_body',
    'ot_alerts',
    'ot_apply_eosb',
    'ot_apply_eosb_done',
    'ot_apply_month',
    'ot_avg_daily',
    'ot_basic_salary',
    'ot_breakdown',
    'ot_calendar_hint',
    'ot_calendar_mode',
    'ot_cat_custom',
    'ot_cat_emergency',
    'ot_cat_holiday',
    'ot_cat_night',
    'ot_cat_restday',
    'ot_cat_standby',
    'ot_cat_weekday',
    'ot_chart_categories',
    'ot_chart_daily',
    'ot_comparison_note',
    'ot_conf_factor_categories',
    'ot_conf_factor_employer',
    'ot_conf_factor_hours',
    'ot_conf_factor_name',
    'ot_conf_factor_salary',
    'ot_conf_factor_validation',
    'ot_confidence',
    'ot_confidence_explainer_body',
    'ot_confidence_explainer_empty',
    'ot_confidence_explainer_title',
    'ot_confidence_tap_hint',
    'ot_country',
    'ot_country_preview',
    'ot_country_preview_note',
    'ot_current_month',
    'ot_day_category',
    'ot_days_recorded',
    'ot_delete',
    'ot_detailed_mode',
    'ot_doc_type',
    'ot_duplicate',
    'ot_emp_id',
    'ot_emp_name',
    'ot_employee_info',
    'ot_employer_comparison',
    'ot_employer_hours',
    'ot_employer_paid',
    'ot_employment_type',
    'ot_empty_desc',
    'ot_empty_title',
    'ot_formula_holiday',
    'ot_formula_label',
    'ot_formula_restday',
    'ot_formula_weekday',
    'ot_highest_day',
    'ot_history',
    'ot_history_empty',
    'ot_history_empty_desc',
    'ot_holiday_hours',
    'ot_holiday_name',
    'ot_hourly_rate',
    'ot_hours',
    'ot_hours_gap',
    'ot_hours_per_day',
    'ot_hub_desc',
    'ot_import_analyze',
    'ot_import_applied',
    'ot_import_desc',
    'ot_import_docs',
    'ot_import_paste',
    'ot_import_text_short',
    'ot_job_title',
    'ot_joining_date',
    'ot_law_reference',
    'ot_legal_owed',
    'ot_minutes',
    'ot_missing_days',
    'ot_monthly_days',
    'ot_monthly_estimate',
    'ot_monthly_summary',
    'ot_new_calc',
    'ot_no_company',
    'ot_no_overtime',
    'ot_notes',
    'ot_pay_period',
    'ot_payment_fair',
    'ot_payment_short',
    'ot_period',
    'ot_period_end',
    'ot_period_start',
    'ot_profile_saved',
    'ot_project',
    'ot_quick_actions',
    'ot_ramadan',
    'ot_rate_breakdown',
    'ot_report_footer',
    'ot_report_share',
    'ot_report_title',
    'ot_restday_hours',
    'ot_rounding_add_timeline',
    'ot_rounding_check_link',
    'ot_rounding_comparison_link',
    'ot_rounding_explain',
    'ot_rounding_hub_button',
    'ot_rounding_need_more',
    'ot_rounding_need_more_hint',
    'ot_rounding_no_accusation',
    'ot_rounding_pattern_clock_in',
    'ot_rounding_pattern_clock_out',
    'ot_rounding_pattern_neutral',
    'ot_rounding_progress',
    'ot_rounding_qar_estimate',
    'ot_rounding_subtitle',
    'ot_rounding_summary_heading',
    'ot_rounding_timeline_note',
    'ot_rounding_timeline_saved',
    'ot_rounding_timeline_title',
    'ot_rounding_title',
    'ot_shift_employer_end',
    'ot_shift_employer_start',
    'ot_shift_times_section',
    'ot_shift_user_end',
    'ot_shift_user_start',
    'ot_rule_holiday',
    'ot_rule_label',
    'ot_rule_restday',
    'ot_rule_weekday',
    'ot_save_day',
    'ot_save_profile',
    'ot_search',
    'ot_section_compensation',
    'ot_section_compensation_sub',
    'ot_section_identity',
    'ot_section_identity_sub',
    'ot_section_jurisdiction',
    'ot_section_jurisdiction_sub',
    'ot_select_month',
    'ot_share_card',
    'ot_share_report',
    'ot_shift_night',
    'ot_shift_normal',
    'ot_shift_type',
    'ot_shift_type_label',
    'ot_simple_mode',
    'ot_standard_hours',
    'ot_start_calc',
    'ot_status_complete',
    'ot_status_pending',
    'ot_subtitle',
    'ot_tap_to_add',
    'ot_title',
    'ot_nav_title',
    'ot_locale_load_error',
    'ot_total_hours',
    'ot_total_ot_hours',
    'ot_total_salary',
    'ot_unpaid_gap',
    'ot_val_duplicate',
    'ot_val_impossible',
    'ot_val_negative',
    'ot_val_salary',
    'ot_weekday_hours',
    'ot_working_days',
    'tpl_eosb_compare_match',
    'tpl_eosb_compare_over',
    'tpl_eosb_compare_under',
    'tpl_eosb_component',
    'tpl_eosb_contract_limited',
    'tpl_eosb_contract_unlimited',
    'tpl_eosb_dispute',
    'tpl_eosb_doc_contract',
    'tpl_eosb_doc_payslip',
    'tpl_eosb_doc_settlement',
    'tpl_eosb_followup',
    'tpl_eosb_art62_explanation',
    'tpl_eosb_opening',
    'tpl_eosb_term_companyClosure',
    'tpl_eosb_term_contractExpiry',
    'tpl_eosb_term_employeeResignation',
    'tpl_eosb_term_employerTermination',
    'tpl_eosb_term_mutualSeparation',
    'tpl_eosb_term_retirement',
    'tpl_eosb_violation',
    'tpl_eosb_warning',
    'tpl_ot_calc_intro',
    'tpl_ot_calc_line',
    'tpl_ot_calc_total',
    'tpl_ot_missing_gap',
    'tpl_ot_next_match',
    'tpl_ot_next_payslip',
    'tpl_ot_q_hours',
    'tpl_ot_q_missing_days',
    'tpl_ot_q_night',
    'tpl_ot_q_overpaid',
    'tpl_ot_q_rest_holiday',
    'tpl_ot_q_unpaid',
    'tpl_ot_q_weekly_cap',
    'tpl_ot_summary',
    'tpl_ot_tip_payslip',
    'tpl_ot_tip_wps',
  };

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  /// Replace `{name}` placeholders in catalog strings.
  static String format(String key, String locale, Map<String, String> params) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static const _catalog = <String, Map<String, String>>{
    'eosb_title': {
      'English': 'End of service pay',
      'Arabic': 'مكافأة نهاية الخدمة',
      'Hindi': 'सेवा समाप्ति वेतन',
      'Urdu': 'خدمت کے اختتام پر ادائیگی',
      'Malayalam': 'സേവന അവസാന പേ',
      'Nepali': 'सेवा अन्त्य भुक्तानी',
      'Bengali': 'চাকরি শেষে পেমেন্ট',
      'Filipino': 'End of service pay',
      'Tamil': 'சேவை முடிவு ஊதியம்',
    },
    'eosb_subtitle': {
      'English': 'Gratuity and overtime check',
      'Arabic': 'فحص المكافأة والعمل الإضافي',
      'Hindi': 'ग्रेच्युटी और ओवरटाइम जाँच',
      'Urdu': 'گریچuity اور overtime چیک',
      'Malayalam': 'ഗ്രാച്ചuity, ഓവർടൈം പരിശോധന',
      'Nepali': 'ग्रेच्युटी र ओभरटाइम जाँच',
      'Bengali': 'গratuity ও overtime যাচাই',
      'Filipino': 'Gratuity and overtime check',
      'Tamil': 'Gratuity மற்றும் overtime சரிபார்ப்பு',
    },
    'eosb_disclaimer': {
      'English':
          'Informational estimate only — not legal advice. Law No. 9 of 2026 may affect your case — verify on Al Meezan. For disputes: call ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727. Consult a qualified lawyer for case-specific advice.',
      'Arabic':
          'تقدير إرشادي فقط — ليس استشارة قانونية. تحقق من القانون 9/2026 على الميزان. للنزاعات: اتصل بـ ADLSA 16008 (24/7)، بوابة الشكاوى الموحدة mol.gov.qa (تسجيل NAS)، أو SMS: 5 + رقم الهوية إلى 92727.',
      'Hindi':
          'केवल सूचनात्मक अनुमान — कानूनी सलाह नहीं। Law 9/2026 — Al Meezan पर verify करें। Disputes: ADLSA (16008), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727।',
      'Urdu':
          'केवल सूचनात्मक अनुमान — कानूनी सलाह नहीं। Law 9/2026 — Al Meezan पर verify करें। Disputes: ADLSA (16008), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727।',
      'Malayalam':
          'Informational estimate only — not legal advice. Law No. 9 of 2026 may affect your case — verify on Al Meezan. For disputes: call ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727. Consult a qualified lawyer for case-specific advice.',
      'Nepali':
          'Informational estimate only — not legal advice. Law No. 9 of 2026 may affect your case — verify on Al Meezan. For disputes: call ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727. Consult a qualified lawyer for case-specific advice.',
      'Bengali':
          'केवल सूचनात्मक अनुमान — कानूनी सलाह नहीं। Law 9/2026 — Al Meezan पर verify करें। Disputes: ADLSA (16008), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727।',
      'Filipino':
          'Informational estimate only — not legal advice. Law No. 9 of 2026 may affect your case — verify on Al Meezan. For disputes: call ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727. Consult a qualified lawyer for case-specific advice.',
      'Tamil':
          'தகவல் மதிப்பீடு மட்டும் — சட்ட ஆலோசனை அல்ல. 2026-ன் சட்டம் எண் 9 உங்கள் வழக்கை பாதிக்கலாம் — Al Meezan-ல் சரிபார்க்கவும். தகராறுகளுக்கு: ADLSA (16008), ஒருங்கிணைந்த புகார் portal (mol.gov.qa, NAS login), அல்லது SMS 5+QID to 92727. வழக்கு-குறிப்பிட்ட ஆலோசனைக்கு தகுதியுள்ள வழக்கறிஞரை அணுகவும்.',
    },
    'eosb_calculate_cta': {
      'English': 'Calculate My EOSB',
      'Arabic': 'احسب مكافأة نهاية الخدمة',
      'Hindi': 'मेरा EOSB गणना करें',
      'Urdu': 'मेरा EOSB गणना करें',
      'Malayalam': 'Calculate My EOSB',
      'Nepali': 'Calculate My EOSB',
      'Bengali': 'मेरा EOSB गणना करें',
      'Filipino': 'Calculate My EOSB',
      'Tamil': 'என் EOSB-ஐ கணக்கிடு',
    },
    'eosb_recalculate_cta': {
      'English': 'Update & Recalculate',
      'Arabic': 'تحديث وإعادة الحساب',
      'Hindi': 'Update & recalculate',
      'Urdu': 'Update & recalculate',
      'Malayalam': 'Update & Recalculate',
      'Nepali': 'Update & Recalculate',
      'Bengali': 'Update & recalculate',
      'Filipino': 'Update & Recalculate',
      'Tamil': 'புதுப்பித்து மீண்டும் கணக்கிடு',
    },
    'eosb_view_results': {
      'English': 'View Full Results',
      'Arabic': 'عرض النتائج الكاملة',
      'Hindi': 'View full results',
      'Urdu': 'View full results',
      'Malayalam': 'View Full Results',
      'Nepali': 'View Full Results',
      'Bengali': 'View full results',
      'Filipino': 'View Full Results',
      'Tamil': 'முழு முடிவுகளைப் பார்',
    },
    'eosb_hub_your_tools': {
      'English': 'Your tools',
      'Arabic': 'أدواتك',
      'Hindi': 'Your tools',
      'Urdu': 'Your tools',
      'Malayalam': 'Your tools',
      'Nepali': 'Your tools',
      'Bengali': 'Your tools',
      'Filipino': 'Your tools',
      'Tamil': 'உங்கள் கருவிகள்',
    },
    'eosb_hub_explore': {
      'English': 'Explore more',
      'Arabic': 'استكشاف المزيد',
      'Hindi': 'Explore more',
      'Urdu': 'Explore more',
      'Malayalam': 'Explore more',
      'Nepali': 'Explore more',
      'Bengali': 'Explore more',
      'Filipino': 'Explore more',
      'Tamil': 'மேலும் ஆராயுங்கள்',
    },
    'eosb_history_unnamed': {
      'English': 'Saved calculation',
      'Arabic': 'حساب محفوظ',
      'Hindi': 'Saved calculation',
      'Urdu': 'Saved calculation',
      'Malayalam': 'Saved calculation',
      'Nepali': 'Saved calculation',
      'Bengali': 'Saved calculation',
      'Filipino': 'Saved calculation',
      'Tamil': 'சேமிக்கப்பட்ட கணக்கீடு',
    },
    'eosb_contract_paste_label': {
      'English': 'Contract or offer text',
      'Arabic': 'نص العقد أو العرض',
      'Hindi': 'Contract text',
      'Urdu': 'Contract text',
      'Malayalam': 'Contract or offer text',
      'Nepali': 'Contract or offer text',
      'Bengali': 'Contract text',
      'Filipino': 'Contract or offer text',
      'Tamil': 'ஒப்பந்தம் அல்லது சலுகை உரை',
    },
    'eosb_ot_calculate_precisely': {
      'English': 'Calculate overtime precisely',
      'Arabic': 'احسب العمل الإضافي بدقة',
      'Hindi': 'Calculate OT precisely',
      'Urdu': 'Calculate OT precisely',
      'Malayalam': 'Calculate overtime precisely',
      'Nepali': 'Calculate overtime precisely',
      'Bengali': 'Calculate OT precisely',
      'Filipino': 'Calculate overtime precisely',
      'Tamil': 'கூடுதல் நேர வேலையை துல்லியமாக கணக்கிடு',
    },
    'eosb_ot_calculate_precisely_desc': {
      'English': 'Use Overtime Truth Engine for day-by-day rates',
      'Arabic': 'محرك الحقيقة للعمل الإضافي يوماً بيوم',
      'Hindi': 'Day-by-day OT Truth Engine',
      'Urdu': 'Day-by-day OT Truth Engine',
      'Malayalam': 'Use Overtime Truth Engine for day-by-day rates',
      'Nepali': 'Use Overtime Truth Engine for day-by-day rates',
      'Bengali': 'Day-by-day OT Truth Engine',
      'Filipino': 'Use Overtime Truth Engine for day-by-day rates',
      'Tamil':
          'நாள்தோறும் விகிதங்களுக்கு கூடுதல் நேர வேலை உண்மை இயந்திரத்தைப் பயன்படுத்துங்கள்',
    },
    'eosb_ai_summary': {
      'English': 'Summary',
      'Arabic': 'الملخص',
      'Hindi': 'Summary',
      'Urdu': 'Summary',
      'Malayalam': 'Summary',
      'Nepali': 'Summary',
      'Bengali': 'Summary',
      'Filipino': 'Summary',
      'Tamil': 'சுருக்கம்',
    },
    'eosb_ai_key_risks': {
      'English': 'Key risks',
      'Arabic': 'المخاطر الرئيسية',
      'Hindi': 'Key risks',
      'Urdu': 'Key risks',
      'Malayalam': 'Key risks',
      'Nepali': 'Key risks',
      'Bengali': 'Key risks',
      'Filipino': 'Key risks',
      'Tamil': 'முக்கிய அபாயங்கள்',
    },
    'eosb_ai_suggested_prompts': {
      'English': 'Suggested questions',
      'Arabic': 'أسئلة مقترحة',
      'Hindi': 'Suggested questions',
      'Urdu': 'Suggested questions',
      'Malayalam': 'Suggested questions',
      'Nepali': 'Suggested questions',
      'Bengali': 'Suggested questions',
      'Filipino': 'Suggested questions',
      'Tamil': 'பரிந்துரைக்கப்பட்ட கேள்விகள்',
    },
    'eosb_ai_prompt_fair': {
      'English': 'Is my employer offer fair?',
      'Arabic': 'هل عرض صاحب العمل عادل؟',
      'Hindi': 'Is employer offer fair?',
      'Urdu': 'Is employer offer fair?',
      'Malayalam': 'Is my employer offer fair?',
      'Nepali': 'Is my employer offer fair?',
      'Bengali': 'Is employer offer fair?',
      'Filipino': 'Is my employer offer fair?',
      'Tamil': 'என் முதலாளியின் சலுகை நியாயமானதா?',
    },
    'eosb_ai_prompt_rights': {
      'English': 'What are my legal rights?',
      'Arabic': 'ما هي حقوقي القانونية؟',
      'Hindi': 'What are my rights?',
      'Urdu': 'What are my rights?',
      'Malayalam': 'What are my legal rights?',
      'Nepali': 'What are my legal rights?',
      'Bengali': 'What are my rights?',
      'Filipino': 'What are my legal rights?',
      'Tamil': 'என் சட்ட உரிமைகள் என்ன?',
    },
    'eosb_ai_prompt_dispute': {
      'English': 'How do I dispute underpayment?',
      'Arabic': 'كيف أ disput نقص الدفع؟',
      'Hindi': 'How to dispute underpayment?',
      'Urdu': 'How to dispute underpayment?',
      'Malayalam': 'How do I dispute underpayment?',
      'Nepali': 'How do I dispute underpayment?',
      'Bengali': 'How to dispute underpayment?',
      'Filipino': 'How do I dispute underpayment?',
      'Tamil': 'குறைவான ஊதியத்தை எப்படி தகராறு செய்வது?',
    },
    'eosb_ai_prompt_breakdown': {
      'English': 'Explain my EOSB breakdown',
      'Arabic': 'اشرح تفصيل مكافأة نهاية الخدمة',
      'Hindi': 'Explain my breakdown',
      'Urdu': 'Explain my breakdown',
      'Malayalam': 'Explain my EOSB breakdown',
      'Nepali': 'Explain my EOSB breakdown',
      'Bengali': 'Explain my breakdown',
      'Filipino': 'Explain my EOSB breakdown',
      'Tamil': 'என் EOSB பிரிவினையை விளக்குங்கள்',
    },
    'eosb_estimated_total': {
      'English': 'Estimated Total Entitlement',
      'Arabic': 'إجمالي المستحقات التقديري',
      'Hindi': 'अनुमानित कुल entitlement',
      'Urdu': 'अनुमानित कुल entitlement',
      'Malayalam': 'Estimated Total Entitlement',
      'Nepali': 'Estimated Total Entitlement',
      'Bengali': 'अनुमानित कुल entitlement',
      'Filipino': 'Estimated Total Entitlement',
      'Tamil': 'மதிப்பிடப்பட்ட மொத்த உரிமை',
    },
    'eosb_gratuity': {
      'English': 'Gratuity',
      'Arabic': 'مكافأة نهاية الخدمة',
      'Hindi': 'Gratuity',
      'Urdu': 'Gratuity',
      'Malayalam': 'Gratuity',
      'Nepali': 'Gratuity',
      'Bengali': 'Gratuity',
      'Filipino': 'Gratuity',
      'Tamil': 'கிராஜுவிட்டி',
    },
    'eosb_leave': {
      'English': 'Annual Leave Encashment',
      'Arabic': 'بدل الإجازات',
      'Hindi': 'अवकाश encashment',
      'Urdu': 'अवकाश encashment',
      'Malayalam': 'Annual Leave Encashment',
      'Nepali': 'Annual Leave Encashment',
      'Bengali': 'अवकाश encashment',
      'Filipino': 'Annual Leave Encashment',
      'Tamil': 'ஆண்டு விடுப்பு encashment',
    },
    'eosb_notice': {
      'English': 'Notice Compensation',
      'Arabic': 'تعويض فترة الإشعار',
      'Hindi': 'Notice compensation',
      'Urdu': 'Notice compensation',
      'Malayalam': 'Notice Compensation',
      'Nepali': 'Notice Compensation',
      'Bengali': 'Notice compensation',
      'Filipino': 'Notice Compensation',
      'Tamil': 'அறிவிப்பு இழப்பீடு',
    },
    'eosb_return_ticket': {
      'English': 'Return Ticket',
      'Arabic': 'تذكرة العودة',
      'Hindi': 'Return ticket',
      'Urdu': 'Return ticket',
      'Malayalam': 'Return Ticket',
      'Nepali': 'Return Ticket',
      'Bengali': 'Return ticket',
      'Filipino': 'Return Ticket',
      'Tamil': 'திரும்பும் டிக்கெட்',
    },
    'eosb_family_ticket': {
      'English': 'Family Ticket',
      'Arabic': 'تickets العائلة',
      'Hindi': 'Family ticket',
      'Urdu': 'Family ticket',
      'Malayalam': 'Family Ticket',
      'Nepali': 'Family Ticket',
      'Bengali': 'Family ticket',
      'Filipino': 'Family Ticket',
      'Tamil': 'குடும்ப டிக்கெட்',
    },
    'eosb_pending_salary': {
      'English': 'Pending Salary',
      'Arabic': 'الراتب المستحق',
      'Hindi': 'Pending salary',
      'Urdu': 'Pending salary',
      'Malayalam': 'Pending Salary',
      'Nepali': 'Pending Salary',
      'Bengali': 'Pending salary',
      'Filipino': 'Pending Salary',
      'Tamil': 'நிலுவையில் உள்ள சம்பளம்',
    },
    'eosb_overtime': {
      'English': 'Overtime',
      'Arabic': 'العمل الإضافي',
      'Hindi': 'Overtime',
      'Urdu': 'Overtime',
      'Malayalam': 'Overtime',
      'Nepali': 'Overtime',
      'Bengali': 'Overtime',
      'Filipino': 'Overtime',
      'Tamil': 'கூடுதல் நேர வேலை',
    },
    'eosb_other_benefits': {
      'English': 'Other Contractual Benefits',
      'Arabic': 'مزايا تعاقدية أخرى',
      'Hindi': 'Other benefits',
      'Urdu': 'Other benefits',
      'Malayalam': 'Other Contractual Benefits',
      'Nepali': 'Other Contractual Benefits',
      'Bengali': 'Other benefits',
      'Filipino': 'Other Contractual Benefits',
      'Tamil': 'பிற ஒப்பந்த பலன்கள்',
    },
    'eosb_employer_offer': {
      'English': 'Employer Settlement Offer',
      'Arabic': 'عرض تسوية صاحب العمل',
      'Hindi': 'Employer offer',
      'Urdu': 'Employer offer',
      'Malayalam': 'Employer Settlement Offer',
      'Nepali': 'Employer Settlement Offer',
      'Bengali': 'Employer offer',
      'Filipino': 'Employer Settlement Offer',
      'Tamil': 'முதலாளி தீர்வு சலுகை',
    },
    'eosb_your_estimate': {
      'English': 'Your Estimated Entitlement',
      'Arabic': 'تقديرك القانوني',
      'Hindi': 'Your estimate',
      'Urdu': 'Your estimate',
      'Malayalam': 'Your Estimated Entitlement',
      'Nepali': 'Your Estimated Entitlement',
      'Bengali': 'Your estimate',
      'Filipino': 'Your Estimated Entitlement',
      'Tamil': 'உங்கள் மதிப்பிடப்பட்ட உரிமை',
    },
    'eosb_difference': {
      'English': 'Difference',
      'Arabic': 'الفرق',
      'Hindi': 'Difference',
      'Urdu': 'Difference',
      'Malayalam': 'Difference',
      'Nepali': 'Difference',
      'Bengali': 'Difference',
      'Filipino': 'Difference',
      'Tamil': 'வித்தியாசம்',
    },
    'eosb_missing_payments': {
      'English': 'Potential Missing Payments',
      'Arabic': 'مدفوعات محتملة مفقودة',
      'Hindi': 'Missing payments',
      'Urdu': 'Missing payments',
      'Malayalam': 'Potential Missing Payments',
      'Nepali': 'Potential Missing Payments',
      'Bengali': 'Missing payments',
      'Filipino': 'Potential Missing Payments',
      'Tamil': 'சாத்தியமான காணாமல் போன கட்டணங்கள்',
    },
    'eosb_next_steps': {
      'English': 'Suggested Next Steps',
      'Arabic': 'الخطوات المقترحة',
      'Hindi': 'Next steps',
      'Urdu': 'Next steps',
      'Malayalam': 'Suggested Next Steps',
      'Nepali': 'Suggested Next Steps',
      'Bengali': 'Next steps',
      'Filipino': 'Suggested Next Steps',
      'Tamil': 'பரிந்துரைக்கப்பட்ட அடுத்த படிகள்',
    },
    'eosb_employee_info': {
      'English': 'Employee Information',
      'Arabic': 'معلومات الموظف',
      'Hindi': 'Employee information',
      'Urdu': 'Employee information',
      'Malayalam': 'Employee Information',
      'Nepali': 'Employee Information',
      'Bengali': 'Employee information',
      'Filipino': 'Employee Information',
      'Tamil': 'தொழிலாளர் தகவல்',
    },
    'eosb_basic_salary': {
      'English': 'Basic Salary (QAR)',
      'Arabic': 'الراتب الأساسي',
      'Hindi': 'Basic salary',
      'Urdu': 'Basic salary',
      'Malayalam': 'Basic Salary (QAR)',
      'Nepali': 'Basic Salary (QAR)',
      'Bengali': 'Basic salary',
      'Filipino': 'Basic Salary (QAR)',
      'Tamil': 'அடிப்படை சம்பளம் (QAR)',
    },
    'eosb_total_salary': {
      'English': 'Total Salary (QAR)',
      'Arabic': 'إجمالي الراتب',
      'Hindi': 'Total salary',
      'Urdu': 'Total salary',
      'Malayalam': 'Total Salary (QAR)',
      'Nepali': 'Total Salary (QAR)',
      'Bengali': 'Total salary',
      'Filipino': 'Total Salary (QAR)',
      'Tamil': 'மொத்த சம்பளம் (QAR)',
    },
    'eosb_basic_salary_changed': {
      'English': 'Did your basic salary change during this job?',
      'Arabic': 'هل تغيّر راتبك الأساسي خلال هذه الوظيفة؟',
      'Hindi': 'Did your basic salary change during this job?',
      'Urdu': 'Did your basic salary change during this job?',
      'Malayalam': 'Did your basic salary change during this job?',
      'Nepali': 'Did your basic salary change during this job?',
      'Bengali': 'Did your basic salary change during this job?',
      'Filipino': 'Did your basic salary change during this job?',
      'Tamil': 'இந்த வேலையில் உங்கள் அடிப்படை சம்பளம் மாறியதா?',
    },
    'eosb_basic_salary_changed_sub': {
      'English':
          'Optional — gratuity uses your most recent basic wage for the whole service period (allowances excluded).',
      'Arabic':
          'اختياري — تُحسب نهاية الخدمة على آخر راتب أساسي (بدون البدلات).',
      'Hindi':
          'Optional — gratuity uses final basic wage only (allowances excluded).',
      'Urdu':
          'Optional — gratuity uses final basic wage only (allowances excluded).',
      'Malayalam':
          'Optional — gratuity uses your most recent basic wage for the whole service period (allowances excluded).',
      'Nepali':
          'Optional — gratuity uses your most recent basic wage for the whole service period (allowances excluded).',
      'Bengali':
          'Optional — gratuity uses final basic wage only (allowances excluded).',
      'Filipino':
          'Optional — gratuity uses your most recent basic wage for the whole service period (allowances excluded).',
      'Tamil':
          'விருப்பம் — கிராஜுவிட்டி முழு சேவைக்கும் உங்கள் இறுதி அடிப்படை சம்பளத்தில் கணக்கிடப்படும் (allowances தவிர).',
    },
    'eosb_basic_salary_change_date': {
      'English': 'Salary change date',
      'Arabic': 'تاريخ تغيير الراتب',
      'Hindi': 'Salary change date',
      'Urdu': 'Salary change date',
      'Malayalam': 'Salary change date',
      'Nepali': 'Salary change date',
      'Bengali': 'Salary change date',
      'Filipino': 'Salary change date',
      'Tamil': 'சம்பள மாற்ற தேதி',
    },
    'eosb_final_basic_salary': {
      'English': 'Final basic wage (most recent)',
      'Arabic': 'آخر راتب أساسي',
      'Hindi': 'Final basic wage (most recent)',
      'Urdu': 'Final basic wage (most recent)',
      'Malayalam': 'Final basic wage (most recent)',
      'Nepali': 'Final basic wage (most recent)',
      'Bengali': 'Final basic wage (most recent)',
      'Filipino': 'Final basic wage (most recent)',
      'Tamil': 'இறுதி அடிப்படை சம்பளம் (சமீபத்திய)',
    },
    'eosb_validation_salary_change': {
      'English':
          'Enter the salary change date and your final basic wage, or turn off the salary-change option.',
      'Arabic':
          'أدخل تاريخ التغيير وآخر راتب أساسي، أو أوقف خيار تغيير الراتب.',
      'Hindi':
          'Enter change date and final basic wage, or turn off salary change.',
      'Urdu':
          'Enter change date and final basic wage, or turn off salary change.',
      'Malayalam':
          'Enter the salary change date and your final basic wage, or turn off the salary-change option.',
      'Nepali':
          'Enter the salary change date and your final basic wage, or turn off the salary-change option.',
      'Bengali':
          'Enter change date and final basic wage, or turn off salary change.',
      'Filipino':
          'Enter the salary change date and your final basic wage, or turn off the salary-change option.',
      'Tamil':
          'சம்பள மாற்ற தேதியும் இறுதி அடிப்படை சம்பளத்தையும் உள்ளிடுங்கள், அல்லது விருப்பத்தை அணைக்கவும்.',
    },
    'eosb_joining_date': {
      'English': 'Joining Date',
      'Arabic': 'تاريخ الالتحاق',
      'Hindi': 'Joining date',
      'Urdu': 'Joining date',
      'Malayalam': 'Joining Date',
      'Nepali': 'Joining Date',
      'Bengali': 'Joining date',
      'Filipino': 'Joining Date',
      'Tamil': 'சேரும் தேதி',
    },
    'eosb_last_working_date': {
      'English': 'Last Working Date',
      'Arabic': 'آخر يوم عمل',
      'Hindi': 'Last working date',
      'Urdu': 'Last working date',
      'Malayalam': 'Last Working Date',
      'Nepali': 'Last Working Date',
      'Bengali': 'Last working date',
      'Filipino': 'Last Working Date',
      'Tamil': 'கடைசி வேலை நாள்',
    },
    'eosb_results': {
      'English': 'Your EOSB Result',
      'Arabic': 'نتيجة مكافأة نهاية الخدمة',
      'Hindi': 'EOSB result',
      'Urdu': 'EOSB result',
      'Malayalam': 'Your EOSB Result',
      'Nepali': 'Your EOSB Result',
      'Bengali': 'EOSB result',
      'Filipino': 'Your EOSB Result',
      'Tamil': 'உங்கள் EOSB முடிவு',
    },
    'eosb_comparison': {
      'English': 'Offer Comparison',
      'Arabic': 'مقارنة العرض',
      'Hindi': 'Comparison',
      'Urdu': 'Comparison',
      'Malayalam': 'Offer Comparison',
      'Nepali': 'Offer Comparison',
      'Bengali': 'Comparison',
      'Filipino': 'Offer Comparison',
      'Tamil': 'சலுகை ஒப்பீடு',
    },
    'eosb_warnings': {
      'English': 'Legal Warnings',
      'Arabic': 'تحذيرات قانونية',
      'Hindi': 'Warnings',
      'Urdu': 'Warnings',
      'Malayalam': 'Legal Warnings',
      'Nepali': 'Legal Warnings',
      'Bengali': 'Warnings',
      'Filipino': 'Legal Warnings',
      'Tamil': 'சட்ட எச்சரிக்கைகள்',
    },
    'eosb_warnings_banner_title': {
      'English': 'Legal warnings detected',
      'Arabic': 'تحذيرات قانونية',
      'Hindi': 'Legal warnings detected',
      'Urdu': 'Legal warnings detected',
      'Malayalam': 'Legal warnings detected',
      'Nepali': 'Legal warnings detected',
      'Bengali': 'Legal warnings detected',
      'Filipino': 'Legal warnings detected',
      'Tamil': 'சட்ட எச்சரிக்கைகள் கண்டறியப்பட்டன',
    },
    'eosb_warnings_banner_body': {
      'English': '{count} labour law issue(s) found — review before you act',
      'Arabic': 'تم العثور على {count} مشكلة — راجع قبل التصرف',
      'Hindi': '{count} issue(s) found — review details',
      'Urdu': '{count} issue(s) found — review details',
      'Malayalam': '{count} labour law issue(s) found — review before you act',
      'Nepali': '{count} labour law issue(s) found — review before you act',
      'Bengali': '{count} issue(s) found — review details',
      'Filipino': '{count} labour law issue(s) found — review before you act',
      'Tamil':
          '{count} தொழிலாளர் சட்டம் சிக்கல்(கள்) கண்டறியப்பட்டன — செயல்படுவதற்கு முன் மறுஆய்வு செய்யுங்கள்',
    },
    'eosb_comparison_details': {
      'English': 'Full comparison & next steps',
      'Arabic': 'المقارنة الكاملة والخطوات التالية',
      'Hindi': 'Full comparison details',
      'Urdu': 'Full comparison details',
      'Malayalam': 'Full comparison & next steps',
      'Nepali': 'Full comparison & next steps',
      'Bengali': 'Full comparison details',
      'Filipino': 'Full comparison & next steps',
      'Tamil': 'முழு ஒப்பீடு & அடுத்த படிகள்',
    },
    'eosb_ai_assistant': {
      'English': 'EOSB Explanation',
      'Arabic': 'شرح EOSB',
      'Hindi': 'EOSB व्याख्या',
      'Urdu': 'EOSB व्याख्या',
      'Malayalam': 'EOSB Explanation',
      'Nepali': 'EOSB Explanation',
      'Bengali': 'EOSB व्याख्या',
      'Filipino': 'EOSB Explanation',
      'Tamil': 'EOSB விளக்கம்',
    },
    'eosb_ai_disclaimer': {
      'English': 'AI summaries are informational only — not legal advice.',
      'Arabic': 'ملخصات الذكاء الاصطناعي إرشادية فقط.',
      'Hindi': 'AI not legal advice.',
      'Urdu': 'AI not legal advice.',
      'Malayalam': 'AI summaries are informational only — not legal advice.',
      'Nepali': 'AI summaries are informational only — not legal advice.',
      'Bengali': 'AI not legal advice.',
      'Filipino': 'AI summaries are informational only — not legal advice.',
      'Tamil': 'AI சுருக்கங்கள் தகவல் மட்டுமே — சட்ட ஆலோசனை அல்ல.',
    },
    'eosb_documents': {
      'English': 'Generate Documents',
      'Arabic': 'إنشاء المستندات',
      'Hindi': 'Documents',
      'Urdu': 'Documents',
      'Malayalam': 'Generate Documents',
      'Nepali': 'Generate Documents',
      'Bengali': 'Documents',
      'Filipino': 'Generate Documents',
      'Tamil': 'ஆவணங்களை உருவாக்கு',
    },
    'eosb_history': {
      'English': 'Calculation History',
      'Arabic': 'سجل الحسابات',
      'Hindi': 'History',
      'Urdu': 'History',
      'Malayalam': 'Calculation History',
      'Nepali': 'Calculation History',
      'Bengali': 'History',
      'Filipino': 'Calculation History',
      'Tamil': 'கணக்கீட்டு வரலாறு',
    },
    'eosb_settings': {
      'English': 'EOSB Settings',
      'Arabic': 'إعدادات EOSB',
      'Hindi': 'Settings',
      'Urdu': 'Settings',
      'Malayalam': 'EOSB Settings',
      'Nepali': 'EOSB Settings',
      'Bengali': 'Settings',
      'Filipino': 'EOSB Settings',
      'Tamil': 'EOSB அமைப்புகள்',
    },
    'eosb_warn_total_below_basic': {
      'English': 'Total salary below basic salary',
      'Arabic': 'إجمالي الراتب أقل من الأساسي',
      'Hindi': 'Total below basic',
      'Urdu': 'Total below basic',
      'Malayalam': 'Total salary below basic salary',
      'Nepali': 'Total salary below basic salary',
      'Bengali': 'Total below basic',
      'Filipino': 'Total salary below basic salary',
      'Tamil': 'மொத்த சம்பளம் அடிப்படை சம்பளத்தை விட குறைவு',
    },
    'eosb_warn_total_below_basic_exp': {
      'English':
          'Total salary should include basic plus allowances. Verify your payslip.',
      'Arabic': 'تحقق من كشف الراتب.',
      'Hindi': 'Verify payslip.',
      'Urdu': 'Verify payslip.',
      'Malayalam':
          'Total salary should include basic plus allowances. Verify your payslip.',
      'Nepali':
          'Total salary should include basic plus allowances. Verify your payslip.',
      'Bengali': 'Verify payslip.',
      'Filipino':
          'Total salary should include basic plus allowances. Verify your payslip.',
      'Tamil':
          'மொத்த சம்பளம் அடிப்படை + allowances உள்ளடக்க வேண்டும். உங்கள் payslip-ஐ சரிபார்க்கவும்.',
    },
    'eosb_warn_total_below_basic_action': {
      'English': 'Update salary fields',
      'Arabic': 'حدّث حقول الراتب',
      'Hindi': 'Update fields',
      'Urdu': 'Update fields',
      'Malayalam': 'Update salary fields',
      'Nepali': 'Update salary fields',
      'Bengali': 'Update fields',
      'Filipino': 'Update salary fields',
      'Tamil': 'சம்பள புலங்களை புதுப்பிக்கவும்',
    },
    'eosb_gratuity_formula': {
      'English': 'Basic Salary ÷ 30 × Eligible Days',
      'Arabic': 'الراتب الأساسي ÷ 30 × الأيام المستحقة',
      'Hindi': 'Basic ÷ 30 × days',
      'Urdu': 'Basic ÷ 30 × days',
      'Malayalam': 'Basic Salary ÷ 30 × Eligible Days',
      'Nepali': 'Basic Salary ÷ 30 × Eligible Days',
      'Bengali': 'Basic ÷ 30 × days',
      'Filipino': 'Basic Salary ÷ 30 × Eligible Days',
      'Tamil': 'அடிப்படை சம்பளம் ÷ 30 × தகுதியான நாட்கள்',
    },
    'eosb_gratuity_rule': {
      'English':
          'Qatar Labour Law Art. 54 — 21 days/year (<5 yrs), 30 days/year (5+ yrs)',
      'Arabic': 'قانون العمل القطري المادة 54',
      'Hindi': 'Art. 54',
      'Urdu': 'Art. 54',
      'Malayalam':
          'Qatar Labour Law Art. 54 — 21 days/year (<5 yrs), 30 days/year (5+ yrs)',
      'Nepali':
          'Qatar Labour Law Art. 54 — 21 days/year (<5 yrs), 30 days/year (5+ yrs)',
      'Bengali': 'Art. 54',
      'Filipino':
          'Qatar Labour Law Art. 54 — 21 days/year (<5 yrs), 30 days/year (5+ yrs)',
      'Tamil':
          'Qatar தொழிலாளர் சட்டம் பிரிவு 54 — 21 நாட்கள்/ஆண்டு (<5 ஆண்டு), 30 நாட்கள்/ஆண்டு (5+ ஆண்டு)',
    },
    'eosb_gratuity_example': {
      'English':
          'QAR 5,000 basic × 5 yrs ≈ QAR 17,500 gratuity (employer termination)',
      'Arabic': 'مثال: 5000 × 5 سنوات',
      'Hindi': 'Example calculation',
      'Urdu': 'Example calculation',
      'Malayalam':
          'QAR 5,000 basic × 5 yrs ≈ QAR 17,500 gratuity (employer termination)',
      'Nepali':
          'QAR 5,000 basic × 5 yrs ≈ QAR 17,500 gratuity (employer termination)',
      'Bengali': 'Example calculation',
      'Filipino':
          'QAR 5,000 basic × 5 yrs ≈ QAR 17,500 gratuity (employer termination)',
      'Tamil':
          'QAR 5,000 அடிப்படை × 5 ஆண்டு ≈ QAR 17,500 கிராஜுவிட்டி (முதலாளி முடிவு)',
    },
    'eosb_gratuity_formula_none': {
      'English': 'Minimum 1 year service required',
      'Arabic': 'يلزم سنة خدمة كحد أدنى',
      'Hindi': 'Min 1 year',
      'Urdu': 'Min 1 year',
      'Malayalam': 'Minimum 1 year service required',
      'Nepali': 'Minimum 1 year service required',
      'Bengali': 'Min 1 year',
      'Filipino': 'Minimum 1 year service required',
      'Tamil': 'குறைந்தது 1 ஆண்டு சேவை தேவை',
    },
    'eosb_gratuity_rule_min_service': {
      'English': 'Art. 54 — no gratuity before 1 year continuous service',
      'Arabic': 'المادة 54',
      'Hindi': 'Art. 54',
      'Urdu': 'Art. 54',
      'Malayalam': 'Art. 54 — no gratuity before 1 year continuous service',
      'Nepali': 'Art. 54 — no gratuity before 1 year continuous service',
      'Bengali': 'Art. 54',
      'Filipino': 'Art. 54 — no gratuity before 1 year continuous service',
      'Tamil': 'பிரிவு 54 — 1 ஆண்டு தொடர் சேவைக்கு முன் கிராஜுவிட்டி இல்லை',
    },
    'eosb_gratuity_example_none': {
      'English': 'Not eligible yet',
      'Arabic': 'غير مستحق بعد',
      'Hindi': 'Not eligible',
      'Urdu': 'Not eligible',
      'Malayalam': 'Not eligible yet',
      'Nepali': 'Not eligible yet',
      'Bengali': 'Not eligible',
      'Filipino': 'Not eligible yet',
      'Tamil': 'இன்னும் தகுதி இல்லை',
    },
    'eosb_leave_formula': {
      'English': 'Daily wage × unused leave days',
      'Arabic': 'الأجر اليومي × أيام الإجازة',
      'Hindi': 'Daily × days',
      'Urdu': 'Daily × days',
      'Malayalam': 'Daily wage × unused leave days',
      'Nepali': 'Daily wage × unused leave days',
      'Bengali': 'Daily × days',
      'Filipino': 'Daily wage × unused leave days',
      'Tamil': 'தினசரி ஊதியம் × பயன்படுத்தாத விடுப்பு நாட்கள்',
    },
    'eosb_leave_rule': {
      'English': 'Art. 79–83 — unused annual leave must be paid at EOS',
      'Arabic': 'المواد 79–83',
      'Hindi': 'Art. 79-83',
      'Urdu': 'Art. 79-83',
      'Malayalam': 'Art. 79–83 — unused annual leave must be paid at EOS',
      'Nepali': 'Art. 79–83 — unused annual leave must be paid at EOS',
      'Bengali': 'Art. 79-83',
      'Filipino': 'Art. 79–83 — unused annual leave must be paid at EOS',
      'Tamil':
          'பிரிவு 79–83 — பயன்படுத்தாத ஆண்டு விடுப்பு EOS-ல் செலுத்தப்பட வேண்டும்',
    },
    'eosb_leave_example': {
      'English': '15 days × daily rate',
      'Arabic': '15 يوم × الأجر اليومي',
      'Hindi': '15 days example',
      'Urdu': '15 days example',
      'Malayalam': '15 days × daily rate',
      'Nepali': '15 days × daily rate',
      'Bengali': '15 days example',
      'Filipino': '15 days × daily rate',
      'Tamil': '15 நாட்கள் × தினசரி விகிதம்',
    },
    'eosb_leave_formula_none': {
      'English': 'No unused leave entered',
      'Arabic': 'لا أيام إجازة',
      'Hindi': 'No leave',
      'Urdu': 'No leave',
      'Malayalam': 'No unused leave entered',
      'Nepali': 'No unused leave entered',
      'Bengali': 'No leave',
      'Filipino': 'No unused leave entered',
      'Tamil': 'பயன்படுத்தாத விடுப்பு நுழைக்கப்படவில்லை',
    },
    'eosb_notice_formula': {
      'English': '1–2 months basic salary if notice not served',
      'Arabic': '1–2 شهر راتب أساسي',
      'Hindi': '1-2 months basic',
      'Urdu': '1-2 months basic',
      'Malayalam': '1–2 months basic salary if notice not served',
      'Nepali': '1–2 months basic salary if notice not served',
      'Bengali': '1-2 months basic',
      'Filipino': '1–2 months basic salary if notice not served',
      'Tamil': 'அறிவிப்பு வழங்கப்படாவிட்டால் 1–2 மாத அடிப்படை சம்பளம்',
    },
    'eosb_notice_rule': {
      'English': 'Art. 49–53 — notice period compensation',
      'Arabic': 'المواد 49–53',
      'Hindi': 'Art. 49-53',
      'Urdu': 'Art. 49-53',
      'Malayalam': 'Art. 49–53 — notice period compensation',
      'Nepali': 'Art. 49–53 — notice period compensation',
      'Bengali': 'Art. 49-53',
      'Filipino': 'Art. 49–53 — notice period compensation',
      'Tamil': 'பிரிவு 49–53 — அறிவிப்பு கால இழப்பீடு',
    },
    'eosb_notice_example': {
      'English': '1 month basic if employer terminates without notice',
      'Arabic': 'شهر واحد',
      'Hindi': '1 month example',
      'Urdu': '1 month example',
      'Malayalam': '1 month basic if employer terminates without notice',
      'Nepali': '1 month basic if employer terminates without notice',
      'Bengali': '1 month example',
      'Filipino': '1 month basic if employer terminates without notice',
      'Tamil': 'அறிவிப்பு இல்லாமல் முதலாளி முடித்தால் 1 மாத அடிப்படை',
    },
    'eosb_notice_formula_none': {
      'English': 'Notice served or not applicable',
      'Arabic': 'تم serving الإشعار',
      'Hindi': 'N/A',
      'Urdu': 'N/A',
      'Malayalam': 'Notice served or not applicable',
      'Nepali': 'Notice served or not applicable',
      'Bengali': 'N/A',
      'Filipino': 'Notice served or not applicable',
      'Tamil': 'அறிவிப்பு வழங்கப்பட்டது அல்லது பொருந்தாது',
    },
    'eosb_ticket_formula': {
      'English': 'Contractual return ticket estimate',
      'Arabic': 'تقدير تذكرة العودة',
      'Hindi': 'Ticket estimate',
      'Urdu': 'Ticket estimate',
      'Malayalam': 'Contractual return ticket estimate',
      'Nepali': 'Contractual return ticket estimate',
      'Bengali': 'Ticket estimate',
      'Filipino': 'Contractual return ticket estimate',
      'Tamil': 'ஒப்பந்த திரும்பும் டிக்கெட் மதிப்பீடு',
    },
    'eosb_ticket_rule': {
      'English': 'Per employment contract / Qatar custom',
      'Arabic': 'حسب العقد',
      'Hindi': 'Per contract',
      'Urdu': 'Per contract',
      'Malayalam': 'Per employment contract / Qatar custom',
      'Nepali': 'Per employment contract / Qatar custom',
      'Bengali': 'Per contract',
      'Filipino': 'Per employment contract / Qatar custom',
      'Tamil': 'வேலை ஒப்பந்தம் / Qatar வழக்கம்',
    },
    'eosb_ticket_example': {
      'English': 'Economy fare estimate QAR 2,500',
      'Arabic': '2500 ريال تقريبي',
      'Hindi': 'QAR 2500',
      'Urdu': 'QAR 2500',
      'Malayalam': 'Economy fare estimate QAR 2,500',
      'Nepali': 'Economy fare estimate QAR 2,500',
      'Bengali': 'QAR 2500',
      'Filipino': 'Economy fare estimate QAR 2,500',
      'Tamil': 'பொருளாதார வகை மதிப்பீடு QAR 2,500',
    },
    'eosb_family_ticket_formula': {
      'English': 'Per dependent ticket estimate',
      'Arabic': 'لكل dependent',
      'Hindi': 'Per dependent',
      'Urdu': 'Per dependent',
      'Malayalam': 'Per dependent ticket estimate',
      'Nepali': 'Per dependent ticket estimate',
      'Bengali': 'Per dependent',
      'Filipino': 'Per dependent ticket estimate',
      'Tamil': 'ஒவ்வொரு dependent-க்கும் டிக்கெட் மதிப்பீடு',
    },
    'eosb_family_ticket_rule': {
      'English': 'Family repatriation per contract',
      'Arabic': 'حسب العقد',
      'Hindi': 'Contract',
      'Urdu': 'Contract',
      'Malayalam': 'Family repatriation per contract',
      'Nepali': 'Family repatriation per contract',
      'Bengali': 'Contract',
      'Filipino': 'Family repatriation per contract',
      'Tamil': 'ஒப்பந்தப்படி குடும்ப repatriation',
    },
    'eosb_family_ticket_example': {
      'English': 'QAR 1,800 × dependents',
      'Arabic': '1800 × المعالين',
      'Hindi': '1800 × deps',
      'Urdu': '1800 × deps',
      'Malayalam': 'QAR 1,800 × dependents',
      'Nepali': 'QAR 1,800 × dependents',
      'Bengali': '1800 × deps',
      'Filipino': 'QAR 1,800 × dependents',
      'Tamil': 'QAR 1,800 × dependents',
    },
    'eosb_pending_salary_formula': {
      'English': 'Unpaid salary amount entered',
      'Arabic': 'الراتب غير المدفوع',
      'Hindi': 'Unpaid amount',
      'Urdu': 'Unpaid amount',
      'Malayalam': 'Unpaid salary amount entered',
      'Nepali': 'Unpaid salary amount entered',
      'Bengali': 'Unpaid amount',
      'Filipino': 'Unpaid salary amount entered',
      'Tamil': 'செலுத்தப்படாத சம்பள தொகை நுழைக்கப்பட்டது',
    },
    'eosb_pending_salary_rule': {
      'English': 'WPS — salary must be paid within 7 days',
      'Arabic': 'نظام حماية الأجور',
      'Hindi': 'WPS',
      'Urdu': 'WPS',
      'Malayalam': 'WPS — salary must be paid within 7 days',
      'Nepali': 'WPS — salary must be paid within 7 days',
      'Bengali': 'WPS',
      'Filipino': 'WPS — salary must be paid within 7 days',
      'Tamil': 'WPS — சம்பளம் 7 நாட்களுக்குள் செலுத்தப்பட வேண்டும்',
    },
    'eosb_pending_salary_example': {
      'English': 'Last month unpaid salary',
      'Arabic': 'راتب الشهر الأخير',
      'Hindi': 'Last month',
      'Urdu': 'Last month',
      'Malayalam': 'Last month unpaid salary',
      'Nepali': 'Last month unpaid salary',
      'Bengali': 'Last month',
      'Filipino': 'Last month unpaid salary',
      'Tamil': 'கடைசி மாதம் செலுத்தப்படாத சம்பளம்',
    },
    'eosb_overtime_formula': {
      'English': 'OT hours × hourly rate × 125%',
      'Arabic': 'ساعات إضافية × 125%',
      'Hindi': 'OT × 125%',
      'Urdu': 'OT × 125%',
      'Malayalam': 'OT hours × hourly rate × 125%',
      'Nepali': 'OT hours × hourly rate × 125%',
      'Bengali': 'OT × 125%',
      'Filipino': 'OT hours × hourly rate × 125%',
      'Tamil': 'OT மணி × மணி விகிதம் × 125%',
    },
    'eosb_overtime_rule': {
      'English': 'Art. 73–74 — overtime at 125%',
      'Arabic': 'المواد 73–74',
      'Hindi': 'Art. 73-74',
      'Urdu': 'Art. 73-74',
      'Malayalam': 'Art. 73–74 — overtime at 125%',
      'Nepali': 'Art. 73–74 — overtime at 125%',
      'Bengali': 'Art. 73-74',
      'Filipino': 'Art. 73–74 — overtime at 125%',
      'Tamil': 'பிரிவு 73–74 — கூடுதல் நேர வேலை 125%-ல்',
    },
    'eosb_overtime_example': {
      'English': '20 hours × hourly × 1.25',
      'Arabic': '20 ساعة',
      'Hindi': '20 hrs',
      'Urdu': '20 hrs',
      'Malayalam': '20 hours × hourly × 1.25',
      'Nepali': '20 hours × hourly × 1.25',
      'Bengali': '20 hrs',
      'Filipino': '20 hours × hourly × 1.25',
      'Tamil': '20 மணி × மணி விகிதம் × 1.25',
    },
    'eosb_overtime_formula_none': {
      'English': 'No overtime entered',
      'Arabic': 'لا overtime',
      'Hindi': 'No OT',
      'Urdu': 'No OT',
      'Malayalam': 'No overtime entered',
      'Nepali': 'No overtime entered',
      'Bengali': 'No OT',
      'Filipino': 'No overtime entered',
      'Tamil': 'கூடுதல் நேர வேலை நுழைக்கப்படவில்லை',
    },
    'eosb_other_benefits_formula': {
      'English': 'Contractual benefits entered',
      'Arabic': 'مزايا تعاقدية',
      'Hindi': 'Benefits',
      'Urdu': 'Benefits',
      'Malayalam': 'Contractual benefits entered',
      'Nepali': 'Contractual benefits entered',
      'Bengali': 'Benefits',
      'Filipino': 'Contractual benefits entered',
      'Tamil': 'ஒப்பந்த பலன்கள் நுழைக்கப்பட்டன',
    },
    'eosb_other_benefits_rule': {
      'English': 'Per employment contract',
      'Arabic': 'حسب العقد',
      'Hindi': 'Contract',
      'Urdu': 'Contract',
      'Malayalam': 'Per employment contract',
      'Nepali': 'Per employment contract',
      'Bengali': 'Contract',
      'Filipino': 'Per employment contract',
      'Tamil': 'வேலை ஒப்பந்தப்படி',
    },
    'eosb_other_benefits_example': {
      'English': 'Bonus, allowances, etc.',
      'Arabic': 'مكافآت',
      'Hindi': 'Bonus',
      'Urdu': 'Bonus',
      'Malayalam': 'Bonus, allowances, etc.',
      'Nepali': 'Bonus, allowances, etc.',
      'Bengali': 'Bonus',
      'Filipino': 'Bonus, allowances, etc.',
      'Tamil': 'Bonus, allowances, முதலியன',
    },
    'eosb_explanation_summary': {
      'English':
          'Estimate based on Qatar Labour Law 2024 and your entered data.',
      'Arabic': 'تقدير بناءً على قانون العمل القطري',
      'Hindi': 'Qatar law estimate',
      'Urdu': 'Qatar law estimate',
      'Malayalam':
          'Estimate based on Qatar Labour Law 2024 and your entered data.',
      'Nepali':
          'Estimate based on Qatar Labour Law 2024 and your entered data.',
      'Bengali': 'Qatar law estimate',
      'Filipino':
          'Estimate based on Qatar Labour Law 2024 and your entered data.',
      'Tamil':
          'Qatar தொழிலாளர் சட்டம் 2024 மற்றும் உங்கள் உள்ளீட்டு தரவின் அடிப்படையில் மதிப்பீடு.',
    },
    'eosb_explanation_default': {
      'English': 'Complete employee information for a full estimate.',
      'Arabic': 'أكمل البيانات',
      'Hindi': 'Complete info',
      'Urdu': 'Complete info',
      'Malayalam': 'Complete employee information for a full estimate.',
      'Nepali': 'Complete employee information for a full estimate.',
      'Bengali': 'Complete info',
      'Filipino': 'Complete employee information for a full estimate.',
      'Tamil': 'முழு மதிப்பீட்டுக்கு தொழிலாளர் தகவலை நிரப்பவும்.',
    },
    'eosb_step_gratuity': {
      'English': 'Calculated gratuity on basic salary',
      'Arabic': 'حسبت المكافأة',
      'Hindi': 'Gratuity step',
      'Urdu': 'Gratuity step',
      'Malayalam': 'Calculated gratuity on basic salary',
      'Nepali': 'Calculated gratuity on basic salary',
      'Bengali': 'Gratuity step',
      'Filipino': 'Calculated gratuity on basic salary',
      'Tamil': 'அடிப்படை சம்பளத்தில் கிராஜுவிட்டி கணக்கிடப்பட்டது',
    },
    'eosb_step_leave': {
      'English': 'Added unused leave encashment',
      'Arabic': 'أضيف بدل الإجازات',
      'Hindi': 'Leave step',
      'Urdu': 'Leave step',
      'Malayalam': 'Added unused leave encashment',
      'Nepali': 'Added unused leave encashment',
      'Bengali': 'Leave step',
      'Filipino': 'Added unused leave encashment',
      'Tamil': 'பயன்படுத்தாத விடுப்பு encashment சேர்க்கப்பட்டது',
    },
    'eosb_step_notice': {
      'English': 'Evaluated notice compensation',
      'Arabic': 'قيمت فترة الإشعار',
      'Hindi': 'Notice step',
      'Urdu': 'Notice step',
      'Malayalam': 'Evaluated notice compensation',
      'Nepali': 'Evaluated notice compensation',
      'Bengali': 'Notice step',
      'Filipino': 'Evaluated notice compensation',
      'Tamil': 'அறிவிப்பு இழப்பீடு மதிப்பீடு செய்யப்பட்டது',
    },
    'eosb_step_ticket': {
      'English': 'Estimated ticket entitlements',
      'Arabic': 'قدّرت التذاكر',
      'Hindi': 'Ticket step',
      'Urdu': 'Ticket step',
      'Malayalam': 'Estimated ticket entitlements',
      'Nepali': 'Estimated ticket entitlements',
      'Bengali': 'Ticket step',
      'Filipino': 'Estimated ticket entitlements',
      'Tamil': 'டிக்கெட் உரிமைகள் மதிப்பிடப்பட்டன',
    },
    'eosb_step_compare_document': {
      'English': 'Document all discrepancies in writing to HR',
      'Arabic': 'وثّق الفروقات كتابياً',
      'Hindi': 'Document to HR',
      'Urdu': 'Document to HR',
      'Malayalam': 'Document all discrepancies in writing to HR',
      'Nepali': 'Document all discrepancies in writing to HR',
      'Bengali': 'Document to HR',
      'Filipino': 'Document all discrepancies in writing to HR',
      'Tamil':
          'HR-க்கு எழுத்துப்பூர்வமாக அனைத்து முரண்பாடுகளையும் ஆவணப்படுத்துங்கள்',
    },
    'eosb_step_compare_hr': {
      'English': 'Request itemised settlement breakdown',
      'Arabic': 'اطلب تفصيل التسوية',
      'Hindi': 'Request breakdown',
      'Urdu': 'Request breakdown',
      'Malayalam': 'Request itemised settlement breakdown',
      'Nepali': 'Request itemised settlement breakdown',
      'Bengali': 'Request breakdown',
      'Filipino': 'Request itemised settlement breakdown',
      'Tamil': 'பிரிவு-வாரியான தீர்வு பிரிவினையை கோருங்கள்',
    },
    'eosb_step_compare_adlsa': {
      'English':
          'File complaint: call ADLSA 16008 (24/7), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727',
      'Arabic':
          'قدّم شكوى: اتصل بـ ADLSA 16008 (24/7)، بوابة الشكاوى الموحدة mol.gov.qa (تسجيل NAS)، أو SMS: 5 + رقم الهوية إلى 92727',
      'Hindi':
          'Complaint: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727',
      'Urdu':
          'Complaint: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727',
      'Malayalam':
          'File complaint: call ADLSA 16008 (24/7), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727',
      'Nepali':
          'File complaint: call ADLSA 16008 (24/7), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727',
      'Bengali':
          'Complaint: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727',
      'Filipino':
          'File complaint: call ADLSA 16008 (24/7), Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727',
      'Tamil':
          'புகார் தாக்கல்: ADLSA 16008 (24/7), ஒருங்கிணைந்த புகார் portal (mol.gov.qa, NAS login), அல்லது SMS 5+QID to 92727',
    },
    'eosb_step_compare_fair': {
      'English': 'Offer appears fair — still verify in writing',
      'Arabic': 'العرض يبدو عادلاً',
      'Hindi': 'Offer fair',
      'Urdu': 'Offer fair',
      'Malayalam': 'Offer appears fair — still verify in writing',
      'Nepali': 'Offer appears fair — still verify in writing',
      'Bengali': 'Offer fair',
      'Filipino': 'Offer appears fair — still verify in writing',
      'Tamil':
          'சலுகை நியாயமாகத் தோன்றுகிறது — இருப்பினும் எழுத்தில் சரிபார்க்கவும்',
    },
    'eosb_dispute_action_request': {
      'English': 'Request this item in your settlement letter',
      'Arabic': 'اطلب هذا البند',
      'Hindi': 'Request item',
      'Urdu': 'Request item',
      'Malayalam': 'Request this item in your settlement letter',
      'Nepali': 'Request this item in your settlement letter',
      'Bengali': 'Request item',
      'Filipino': 'Request this item in your settlement letter',
      'Tamil': 'உங்கள் தீர்வு கடிதத்தில் இந்த உருப்படியை கோருங்கள்',
    },
    'eosb_dispute_escalation_title': {
      'English': 'If your employer will not pay — dispute escalation path',
      'Arabic': 'إذا امتنع صاحب العمل عن الدفع — مسار تصعيد النزاع',
      'Hindi': 'If employer will not pay — dispute escalation path',
      'Urdu': 'If employer will not pay — dispute escalation path',
      'Malayalam': 'If your employer will not pay — dispute escalation path',
      'Nepali': 'If your employer will not pay — dispute escalation path',
      'Bengali': 'If employer will not pay — dispute escalation path',
      'Filipino': 'If your employer will not pay — dispute escalation path',
      'Tamil': 'If your employer will not pay — dispute escalation path',
    },
    'eosb_dispute_escalation_subtitle': {
      'English':
          'What typically happens after you file a labour complaint in Qatar — informational only, not legal advice. Raabta does not file complaints for you.',
      'Arabic':
          'ما يحدث عادة بعد تقديم شكوى عمل — إرشادي فقط، وليس استشارة قانونية. Raabta لا تقدّم الشكاوى نيابة عنك.',
      'Hindi':
          'After filing a labour complaint — informational only. Raabta does not file for you.',
      'Urdu':
          'After filing a labour complaint — informational only. Raabta does not file for you.',
      'Malayalam':
          'What typically happens after you file a labour complaint in Qatar — informational only, not legal advice. Raabta does not file complaints for you.',
      'Nepali':
          'What typically happens after you file a labour complaint in Qatar — informational only, not legal advice. Raabta does not file complaints for you.',
      'Bengali':
          'After filing a labour complaint — informational only. Raabta does not file for you.',
      'Filipino':
          'What typically happens after you file a labour complaint in Qatar — informational only, not legal advice. Raabta does not file complaints for you.',
      'Tamil':
          'What typically happens after you file a labour complaint in Qatar — informational only, not legal advice. Raabta does not file complaints for you.',
    },
    'eosb_dispute_escalation_disclaimer': {
      'English':
          'Timelines and outcomes vary by case. This is not confirmation that you have a claim or that any fund will pay in full.',
      'Arabic':
          'الجداول الزمنية والنتائج تختلف. هذا ليس تأكيداً بوجود مطالبة أو دفع كامل.',
      'Hindi': 'Timelines vary. Not confirmation of a claim or full payment.',
      'Urdu': 'Timelines vary. Not confirmation of a claim or full payment.',
      'Malayalam':
          'Timelines and outcomes vary by case. This is not confirmation that you have a claim or that any fund will pay in full.',
      'Nepali':
          'Timelines and outcomes vary by case. This is not confirmation that you have a claim or that any fund will pay in full.',
      'Bengali': 'Timelines vary. Not confirmation of a claim or full payment.',
      'Filipino':
          'Timelines and outcomes vary by case. This is not confirmation that you have a claim or that any fund will pay in full.',
      'Tamil':
          'Timelines and outcomes vary by case. This is not confirmation that you have a claim or that any fund will pay in full.',
    },
    'eosb_dispute_step1_title': {
      'English': 'File a labour complaint',
      'Arabic': 'قدّم شكوى عمل',
      'Hindi': 'File labour complaint',
      'Urdu': 'File labour complaint',
      'Malayalam': 'File a labour complaint',
      'Nepali': 'File a labour complaint',
      'Bengali': 'File labour complaint',
      'Filipino': 'File a labour complaint',
      'Tamil': 'File a labour complaint',
    },
    'eosb_dispute_step1_desc': {
      'English':
          'Contact ADLSA (helpline 16008, 24/7), use the Unified Complaints Portal at mol.gov.qa (QID/visa + OTP or NAS login), or SMS 5 followed by your QID/visa number to 92727. Keep copies of everything you submit.',
      'Arabic':
          'اتصل بـ ADLSA (16008)، بوابة mol.gov.qa، أو SMS: 5 + رقم الهوية إلى 92727. احتفظ بنسخ من كل ما تقدّمه.',
      'Hindi':
          'ADLSA 16008, mol.gov.qa portal, or SMS 5+QID to 92727. Keep copies.',
      'Urdu':
          'ADLSA 16008, mol.gov.qa portal, or SMS 5+QID to 92727. Keep copies.',
      'Malayalam':
          'Contact ADLSA (helpline 16008, 24/7), use the Unified Complaints Portal at mol.gov.qa (QID/visa + OTP or NAS login), or SMS 5 followed by your QID/visa number to 92727. Keep copies of everything you submit.',
      'Nepali':
          'Contact ADLSA (helpline 16008, 24/7), use the Unified Complaints Portal at mol.gov.qa (QID/visa + OTP or NAS login), or SMS 5 followed by your QID/visa number to 92727. Keep copies of everything you submit.',
      'Bengali':
          'ADLSA 16008, mol.gov.qa portal, or SMS 5+QID to 92727. Keep copies.',
      'Filipino':
          'Contact ADLSA (helpline 16008, 24/7), use the Unified Complaints Portal at mol.gov.qa (QID/visa + OTP or NAS login), or SMS 5 followed by your QID/visa number to 92727. Keep copies of everything you submit.',
      'Tamil':
          'Contact ADLSA (helpline 16008, 24/7), use the Unified Complaints Portal at mol.gov.qa (QID/visa + OTP or NAS login), or SMS 5 followed by your QID/visa number to 92727. Keep copies of everything you submit.',
    },
    'eosb_dispute_step1_tracking': {
      'English':
          'Once you have filed, track status directly with the government — not through Raabta: log in at adlsa.gov.qa and open "My Complaints," use the Amerni mobile app, or call 16008 with your complaint reference number. Status is typically shown as Under Review, Mediation Scheduled, Resolved, or Referred to Labour Court.',
      'Arabic':
          'بعد تقديم الشكوى، تتبّع حالتها مباشرة لدى الجهة الحكومية — وليس عبر Raabta: سجّل الدخول إلى adlsa.gov.qa وافتح «شكاواي»، أو استخدم تطبيق أميري، أو اتصل على 16008 مع رقم مرجع الشكوى. تظهر الحالة عادةً كـ: قيد المراجعة، وساطة مجدولة، تم الحل، أو إحالة إلى المحكمة العمالية.',
      'Hindi':
          'After filing, track status via adlsa.gov.qa ("My Complaints"), Amerni app, or 16008 with reference number — government channels only, not Raabta.',
      'Urdu':
          'After filing, track status via adlsa.gov.qa ("My Complaints"), Amerni app, or 16008 with reference number — government channels only, not Raabta.',
      'Malayalam':
          'Once you have filed, track status directly with the government — not through Raabta: log in at adlsa.gov.qa and open "My Complaints," use the Amerni mobile app, or call 16008 with your complaint reference number. Status is typically shown as Under Review, Mediation Scheduled, Resolved, or Referred to Labour Court.',
      'Nepali':
          'Once you have filed, track status directly with the government — not through Raabta: log in at adlsa.gov.qa and open "My Complaints," use the Amerni mobile app, or call 16008 with your complaint reference number. Status is typically shown as Under Review, Mediation Scheduled, Resolved, or Referred to Labour Court.',
      'Bengali':
          'After filing, track via adlsa.gov.qa ("My Complaints"), Amerni app, or 16008 with reference — government only, not Raabta.',
      'Filipino':
          'Once you have filed, track status directly with the government — not through Raabta: log in at adlsa.gov.qa and open "My Complaints," use the Amerni mobile app, or call 16008 with your complaint reference number. Status is typically shown as Under Review, Mediation Scheduled, Resolved, or Referred to Labour Court.',
      'Tamil':
          'Once you have filed, track status directly with the government — not through Raabta: log in at adlsa.gov.qa and open "My Complaints," use the Amerni mobile app, or call 16008 with your complaint reference number. Status is typically shown as Under Review, Mediation Scheduled, Resolved, or Referred to Labour Court.',
    },
    'eosb_dispute_step2_title': {
      'English': 'Mediation and LDRC referral',
      'Arabic': 'الوساطة وإحالة لجنة فض المنازعات',
      'Hindi': 'Mediation and LDRC referral',
      'Urdu': 'Mediation and LDRC referral',
      'Malayalam': 'Mediation and LDRC referral',
      'Nepali': 'Mediation and LDRC referral',
      'Bengali': 'Mediation and LDRC referral',
      'Filipino': 'Mediation and LDRC referral',
      'Tamil': 'Mediation and LDRC referral',
    },
    'eosb_dispute_step2_desc': {
      'English':
          'MoL/ADLSA typically attempts mediation first. If the dispute is not resolved, it may be referred to the Labour Dispute Resolution Committees (LDRC) established under Cabinet Resolution No. 6 of 2018 — judge-led panels with appeal to the Court of Appeal.',
      'Arabic':
          'تحاول MoL/ADLSA الوساطة أولاً. إن لم تُحل، قد تُحال إلى لجان فض المنازعات العمالية (LDRC) بموجب قرار مجلس الوزراء 6/2018.',
      'Hindi':
          'MoL/ADLSA mediation first; unresolved cases may go to LDRC (Cabinet Res. 6/2018).',
      'Urdu':
          'MoL/ADLSA mediation first; unresolved cases may go to LDRC (Cabinet Res. 6/2018).',
      'Malayalam':
          'MoL/ADLSA typically attempts mediation first. If the dispute is not resolved, it may be referred to the Labour Dispute Resolution Committees (LDRC) established under Cabinet Resolution No. 6 of 2018 — judge-led panels with appeal to the Court of Appeal.',
      'Nepali':
          'MoL/ADLSA typically attempts mediation first. If the dispute is not resolved, it may be referred to the Labour Dispute Resolution Committees (LDRC) established under Cabinet Resolution No. 6 of 2018 — judge-led panels with appeal to the Court of Appeal.',
      'Bengali':
          'MoL/ADLSA mediation first; unresolved cases may go to LDRC (Cabinet Res. 6/2018).',
      'Filipino':
          'MoL/ADLSA typically attempts mediation first. If the dispute is not resolved, it may be referred to the Labour Dispute Resolution Committees (LDRC) established under Cabinet Resolution No. 6 of 2018 — judge-led panels with appeal to the Court of Appeal.',
      'Tamil':
          'MoL/ADLSA typically attempts mediation first. If the dispute is not resolved, it may be referred to the Labour Dispute Resolution Committees (LDRC) established under Cabinet Resolution No. 6 of 2018 — judge-led panels with appeal to the Court of Appeal.',
    },
    'eosb_dispute_step3_title': {
      'English': 'Committee issues a decision',
      'Arabic': 'تصدر اللجنة قراراً',
      'Hindi': 'Committee issues decision',
      'Urdu': 'Committee issues decision',
      'Malayalam': 'Committee issues a decision',
      'Nepali': 'Committee issues a decision',
      'Bengali': 'Committee issues decision',
      'Filipino': 'Committee issues a decision',
      'Tamil': 'Committee issues a decision',
    },
    'eosb_dispute_step3_desc': {
      'English':
          'The LDRC can issue a binding decision on your dispute — for example ordering payment of owed wages or gratuity. As reported in public MoL/ADLSA guidance, decisions are often issued within roughly three weeks, but statutory timelines can be longer and vary by case — not a guaranteed schedule.',
      'Arabic':
          'تصدر LDRC قراراً ملزماً. وفق إرشادات MoL/ADLSA العامة، غالباً خلال نحو ثلاثة أسابيع — لكن المدد قد تكون أطول وتختلف حسب الحالة؛ ليست ضماناً.',
      'Hindi':
          'LDRC binding decision. Often ~3 weeks per MoL guidance — not guaranteed.',
      'Urdu':
          'LDRC binding decision. Often ~3 weeks per MoL guidance — not guaranteed.',
      'Malayalam':
          'The LDRC can issue a binding decision on your dispute — for example ordering payment of owed wages or gratuity. As reported in public MoL/ADLSA guidance, decisions are often issued within roughly three weeks, but statutory timelines can be longer and vary by case — not a guaranteed schedule.',
      'Nepali':
          'The LDRC can issue a binding decision on your dispute — for example ordering payment of owed wages or gratuity. As reported in public MoL/ADLSA guidance, decisions are often issued within roughly three weeks, but statutory timelines can be longer and vary by case — not a guaranteed schedule.',
      'Bengali':
          'LDRC binding decision. Often ~3 weeks per MoL guidance — not guaranteed.',
      'Filipino':
          'The LDRC can issue a binding decision on your dispute — for example ordering payment of owed wages or gratuity. As reported in public MoL/ADLSA guidance, decisions are often issued within roughly three weeks, but statutory timelines can be longer and vary by case — not a guaranteed schedule.',
      'Tamil':
          'The LDRC can issue a binding decision on your dispute — for example ordering payment of owed wages or gratuity. As reported in public MoL/ADLSA guidance, decisions are often issued within roughly three weeks, but statutory timelines can be longer and vary by case — not a guaranteed schedule.',
    },
    'eosb_dispute_step4_title': {
      'English':
          'If the employer still will not pay — Workers\' Support and Insurance Fund (WSIF)',
      'Arabic':
          'إذا امتنع صاحب العمل عن الدفع — صندوق دعم العمال والتأمين (WSIF)',
      'Hindi': 'Employer still won\'t pay — WSIF (Law 17/2018)',
      'Urdu': 'Employer still won\'t pay — WSIF (Law 17/2018)',
      'Malayalam':
          'If the employer still will not pay — Workers\' Support and Insurance Fund (WSIF)',
      'Nepali':
          'If the employer still will not pay — Workers\' Support and Insurance Fund (WSIF)',
      'Bengali': 'Employer still won\'t pay — WSIF (Law 17/2018)',
      'Filipino':
          'If the employer still will not pay — Workers\' Support and Insurance Fund (WSIF)',
      'Tamil':
          'If the employer still will not pay — Workers\' Support and Insurance Fund (WSIF)',
    },
    'eosb_dispute_step4_body': {
      'English':
          'If the Committee rules in your favor but your employer cannot or will not pay, the Workers\' Support and Insurance Fund (established under Law No. 17 of 2018) may pay your awarded entitlements and separately pursue recovery from the employer. In practice, this typically requires a valid QID and a completed Committee ruling, and payment amounts are sometimes capped or issued as an interim amount rather than the full sum awarded. Contact MADLSA (hotline 16008) or visit wsif.gov.qa for current eligibility and process information.',
      'Arabic':
          'إذا حكمت اللجنة لصالحك وامتنع صاحب العمل عن الدفع، قد يدفع صندوق دعم العمال والتأمين (القانون 17/2018) المستحقات المقررة ويلاحق صاحب العمل. يتطلب عادة هوية قطرية سارية وحكماً نهائياً من اللجنة، وقد تُصرف مبالغ محدودة أو مؤقتة وليس بالضرورة المبلغ الكامل. اتصل بـ ADLSA (16008) أو زر wsif.gov.qa.',
      'Hindi':
          'If Committee rules for you but employer won\'t pay, WSIF (Law 17/2018) may pay awarded entitlements and pursue employer — typically needs valid QID and completed Committee ruling; payouts may be capped or interim, not necessarily full amount. ADLSA 16008 or wsif.gov.qa.',
      'Urdu':
          'If Committee rules for you but employer won\'t pay, WSIF (Law 17/2018) may pay awarded entitlements and pursue employer — typically needs valid QID and completed Committee ruling; payouts may be capped or interim, not necessarily full amount. ADLSA 16008 or wsif.gov.qa.',
      'Malayalam':
          'If the Committee rules in your favor but your employer cannot or will not pay, the Workers\' Support and Insurance Fund (established under Law No. 17 of 2018) may pay your awarded entitlements and separately pursue recovery from the employer. In practice, this typically requires a valid QID and a completed Committee ruling, and payment amounts are sometimes capped or issued as an interim amount rather than the full sum awarded. Contact MADLSA (hotline 16008) or visit wsif.gov.qa for current eligibility and process information.',
      'Nepali':
          'If the Committee rules in your favor but your employer cannot or will not pay, the Workers\' Support and Insurance Fund (established under Law No. 17 of 2018) may pay your awarded entitlements and separately pursue recovery from the employer. In practice, this typically requires a valid QID and a completed Committee ruling, and payment amounts are sometimes capped or issued as an interim amount rather than the full sum awarded. Contact MADLSA (hotline 16008) or visit wsif.gov.qa for current eligibility and process information.',
      'Bengali':
          'If Committee rules for you but employer won\'t pay, WSIF (Law 17/2018) may pay — QID and Committee ruling typically required; payouts may be capped or interim. ADLSA 16008 or wsif.gov.qa.',
      'Filipino':
          'If the Committee rules in your favor but your employer cannot or will not pay, the Workers\' Support and Insurance Fund (established under Law No. 17 of 2018) may pay your awarded entitlements and separately pursue recovery from the employer. In practice, this typically requires a valid QID and a completed Committee ruling, and payment amounts are sometimes capped or issued as an interim amount rather than the full sum awarded. Contact MADLSA (hotline 16008) or visit wsif.gov.qa for current eligibility and process information.',
      'Tamil':
          'If the Committee rules in your favor but your employer cannot or will not pay, the Workers\' Support and Insurance Fund (established under Law No. 17 of 2018) may pay your awarded entitlements and separately pursue recovery from the employer. In practice, this typically requires a valid QID and a completed Committee ruling, and payment amounts are sometimes capped or issued as an interim amount rather than the full sum awarded. Contact MADLSA (hotline 16008) or visit wsif.gov.qa for current eligibility and process information.',
    },
    'eosb_dispute_step4_known': {
      'English':
          'Known: The Workers\' Support and Insurance Fund exists, is government-run, and can pay entitlements already decided by the Labour Dispute Resolution Committee — separate from your employer.',
      'Arabic':
          'معروف: الصندوق حكومي ويمكنه دفع مستحقات محكوم بها من اللجنة — منفصل عن صاحب العمل.',
      'Hindi':
          'Known: WSIF is government-run and pays Committee-decided entitlements.',
      'Urdu':
          'Known: WSIF is government-run and pays Committee-decided entitlements.',
      'Malayalam':
          'Known: The Workers\' Support and Insurance Fund exists, is government-run, and can pay entitlements already decided by the Labour Dispute Resolution Committee — separate from your employer.',
      'Nepali':
          'Known: The Workers\' Support and Insurance Fund exists, is government-run, and can pay entitlements already decided by the Labour Dispute Resolution Committee — separate from your employer.',
      'Bengali':
          'Known: WSIF is government-run and pays Committee-decided entitlements.',
      'Filipino':
          'Known: The Workers\' Support and Insurance Fund exists, is government-run, and can pay entitlements already decided by the Labour Dispute Resolution Committee — separate from your employer.',
      'Tamil':
          'Known: The Workers\' Support and Insurance Fund exists, is government-run, and can pay entitlements already decided by the Labour Dispute Resolution Committee — separate from your employer.',
    },
    'eosb_dispute_step4_unknown': {
      'English':
          'Unknown: Exact current payout caps, processing time, and eligibility specifics for your situation — verify directly with MADLSA or wsif.gov.qa rather than relying on figures not independently verified here.',
      'Arabic':
          'غير معروف: سقوف الدفع الحالية ومدة المعالجة وشروط الأهلية لحالتك — تحقق مباشرة مع ADLSA أو wsif.gov.qa.',
      'Hindi':
          'Unknown: Current caps, processing time, and your eligibility — verify with ADLSA or wsif.gov.qa.',
      'Urdu':
          'Unknown: Current caps, processing time, and your eligibility — verify with ADLSA or wsif.gov.qa.',
      'Malayalam':
          'Unknown: Exact current payout caps, processing time, and eligibility specifics for your situation — verify directly with MADLSA or wsif.gov.qa rather than relying on figures not independently verified here.',
      'Nepali':
          'Unknown: Exact current payout caps, processing time, and eligibility specifics for your situation — verify directly with MADLSA or wsif.gov.qa rather than relying on figures not independently verified here.',
      'Bengali':
          'Unknown: Current caps, processing time, and your eligibility — verify with ADLSA or wsif.gov.qa.',
      'Filipino':
          'Unknown: Exact current payout caps, processing time, and eligibility specifics for your situation — verify directly with MADLSA or wsif.gov.qa rather than relying on figures not independently verified here.',
      'Tamil':
          'Unknown: Exact current payout caps, processing time, and eligibility specifics for your situation — verify directly with MADLSA or wsif.gov.qa rather than relying on figures not independently verified here.',
    },
    'eosb_dispute_step4_action': {
      'English':
          'Action: Once you have a Committee ruling in your favor and the employer still has not paid, contact MADLSA (16008) or visit wsif.gov.qa for current eligibility and process steps. Raabta does not file fund applications for you.',
      'Arabic':
          'إجراء: بعد صدور حكم اللجنة لصالحك دون دفع، اتصل بـ ADLSA (16008) أو زر wsif.gov.qa. Raabta لا تقدّم طلبات للصندوق نيابة عنك.',
      'Hindi':
          'Action: After Committee ruling, contact ADLSA 16008 or wsif.gov.qa. Raabta does not file for you.',
      'Urdu':
          'Action: After Committee ruling, contact ADLSA 16008 or wsif.gov.qa. Raabta does not file for you.',
      'Malayalam':
          'Action: Once you have a Committee ruling in your favor and the employer still has not paid, contact MADLSA (16008) or visit wsif.gov.qa for current eligibility and process steps. Raabta does not file fund applications for you.',
      'Nepali':
          'Action: Once you have a Committee ruling in your favor and the employer still has not paid, contact MADLSA (16008) or visit wsif.gov.qa for current eligibility and process steps. Raabta does not file fund applications for you.',
      'Bengali':
          'Action: After Committee ruling, contact ADLSA 16008 or wsif.gov.qa. Raabta does not file for you.',
      'Filipino':
          'Action: Once you have a Committee ruling in your favor and the employer still has not paid, contact MADLSA (16008) or visit wsif.gov.qa for current eligibility and process steps. Raabta does not file fund applications for you.',
      'Tamil':
          'Action: Once you have a Committee ruling in your favor and the employer still has not paid, contact MADLSA (16008) or visit wsif.gov.qa for current eligibility and process steps. Raabta does not file fund applications for you.',
    },
    'eosb_dispute_step4_wsif_link': {
      'English': 'Open wsif.gov.qa (official government site)',
      'Arabic': 'فتح wsif.gov.qa (موقع حكومي رسمي)',
      'Hindi': 'Open wsif.gov.qa',
      'Urdu': 'Open wsif.gov.qa',
      'Malayalam': 'Open wsif.gov.qa (official government site)',
      'Nepali': 'Open wsif.gov.qa (official government site)',
      'Bengali': 'Open wsif.gov.qa',
      'Filipino': 'Open wsif.gov.qa (official government site)',
      'Tamil': 'Open wsif.gov.qa (official government site)',
    },
    'eosb_risk_high': {
      'English': 'High risk',
      'Arabic': 'خطر عالي',
      'Hindi': 'High',
      'Urdu': 'High',
      'Malayalam': 'High risk',
      'Nepali': 'High risk',
      'Bengali': 'High',
      'Filipino': 'High risk',
      'Tamil': 'அதிக அபாயம்',
    },
    'eosb_risk_medium': {
      'English': 'Medium risk',
      'Arabic': 'خطر متوسط',
      'Hindi': 'Medium',
      'Urdu': 'Medium',
      'Malayalam': 'Medium risk',
      'Nepali': 'Medium risk',
      'Bengali': 'Medium',
      'Filipino': 'Medium risk',
      'Tamil': 'நடுத்தர அபாயம்',
    },
    'eosb_risk_critical': {
      'English': 'Critical',
      'Arabic': 'حرج',
      'Hindi': 'Critical',
      'Urdu': 'Critical',
      'Malayalam': 'Critical',
      'Nepali': 'Critical',
      'Bengali': 'Critical',
      'Filipino': 'Critical',
      'Tamil': 'முக்கியமான',
    },
    'eosb_empty_history': {
      'English': 'No saved calculations yet',
      'Arabic': 'لا حسابات محفوظة',
      'Hindi': 'No history',
      'Urdu': 'No history',
      'Malayalam': 'No saved calculations yet',
      'Nepali': 'No saved calculations yet',
      'Bengali': 'No history',
      'Filipino': 'No saved calculations yet',
      'Tamil': 'இன்னும் சேமிக்கப்பட்ட கணக்கீடுகள் இல்லை',
    },
    'eosb_empty_history_desc': {
      'English':
          'Run a calculation to save it here for later review and export.',
      'Arabic': 'قم بإجراء حساب لحفظه هنا للمراجعة لاحقاً.',
      'Hindi': 'Save calculations here after you run EOSB.',
      'Urdu': 'Save calculations here after you run EOSB.',
      'Malayalam':
          'Run a calculation to save it here for later review and export.',
      'Nepali':
          'Run a calculation to save it here for later review and export.',
      'Bengali': 'Save calculations here after you run EOSB.',
      'Filipino':
          'Run a calculation to save it here for later review and export.',
      'Tamil':
          'பின்னர் மறுஆய்வு மற்றும் ஏற்றுமதிக்காக இங்கே சேமிக்க ஒரு கணக்கீட்டை இயக்கவும்.',
    },
    'eosb_empty_result_title': {
      'English': 'No calculation yet',
      'Arabic': 'لا يوجد حساب بعد',
      'Hindi': 'No calculation',
      'Urdu': 'No calculation',
      'Malayalam': 'No calculation yet',
      'Nepali': 'No calculation yet',
      'Bengali': 'No calculation',
      'Filipino': 'No calculation yet',
      'Tamil': 'இன்னும் கணக்கீடு இல்லை',
    },
    'eosb_empty_result_desc': {
      'English':
          'Enter your employment details to estimate your End of Service Benefits.',
      'Arabic': 'أدخل بيانات عملك لتقدير مستحقات نهاية الخدمة.',
      'Hindi': 'Enter employment details to estimate EOSB.',
      'Urdu': 'Enter employment details to estimate EOSB.',
      'Malayalam':
          'Enter your employment details to estimate your End of Service Benefits.',
      'Nepali':
          'Enter your employment details to estimate your End of Service Benefits.',
      'Bengali': 'Enter employment details to estimate EOSB.',
      'Filipino':
          'Enter your employment details to estimate your End of Service Benefits.',
      'Tamil':
          'உங்கள் சேவை முடிவு பலன்களை மதிப்பிட உங்கள் வேலை விவரங்களை உள்ளிடவும்.',
    },
    'eosb_empty_comparison_title': {
      'English': 'No employer offer to compare',
      'Arabic': 'لا يوجد عرض للمقارنة',
      'Hindi': 'No offer to compare',
      'Urdu': 'No offer to compare',
      'Malayalam': 'No employer offer to compare',
      'Nepali': 'No employer offer to compare',
      'Bengali': 'No offer to compare',
      'Filipino': 'No employer offer to compare',
      'Tamil': 'ஒப்பிட முதலாளி சலுகை இல்லை',
    },
    'eosb_empty_comparison_desc': {
      'English':
          'Add your employer settlement offer in Employee Information to see the comparison.',
      'Arabic': 'أضف عرض التسوية في معلومات الموظف لعرض المقارنة.',
      'Hindi': 'Add employer offer in Employee Information.',
      'Urdu': 'Add employer offer in Employee Information.',
      'Malayalam':
          'Add your employer settlement offer in Employee Information to see the comparison.',
      'Nepali':
          'Add your employer settlement offer in Employee Information to see the comparison.',
      'Bengali': 'Add employer offer in Employee Information.',
      'Filipino':
          'Add your employer settlement offer in Employee Information to see the comparison.',
      'Tamil':
          'ஒப்பீட்டைப் பார்க்க தொழிலாளர் தகவலில் உங்கள் முதலாளி தீர்வு சலுகையைச் சேர்க்கவும்.',
    },
    'eosb_empty_warnings_title': {
      'English': 'No warnings for current data',
      'Arabic': 'لا تحذيرات للبيانات الحالية',
      'Hindi': 'No warnings',
      'Urdu': 'No warnings',
      'Malayalam': 'No warnings for current data',
      'Nepali': 'No warnings for current data',
      'Bengali': 'No warnings',
      'Filipino': 'No warnings for current data',
      'Tamil': 'தற்போதைய தரவுக்கு எச்சரிக்கைகள் இல்லை',
    },
    'eosb_empty_warnings_desc': {
      'English':
          'Run a calculation first — we will flag potential labour law issues automatically.',
      'Arabic': 'قم بالحساب أولاً — سنحدد مشكلات قانون العمل تلقائياً.',
      'Hindi': 'Calculate first to see labour law warnings.',
      'Urdu': 'Calculate first to see labour law warnings.',
      'Malayalam':
          'Run a calculation first — we will flag potential labour law issues automatically.',
      'Nepali':
          'Run a calculation first — we will flag potential labour law issues automatically.',
      'Bengali': 'Calculate first to see labour law warnings.',
      'Filipino':
          'Run a calculation first — we will flag potential labour law issues automatically.',
      'Tamil':
          'முதலில் கணக்கீடு செய்யுங்கள் — தொழிலாளர் சட்டம் சிக்கல்களை தானாகக் குறிப்பிடுவோம்.',
    },
    'eosb_save_consent': {
      'English': 'Store salary data securely (encrypted locally)',
      'Arabic': 'تخزين آمن للبيانات',
      'Hindi': 'Secure storage',
      'Urdu': 'Secure storage',
      'Malayalam': 'Store salary data securely (encrypted locally)',
      'Nepali': 'Store salary data securely (encrypted locally)',
      'Bengali': 'Secure storage',
      'Filipino': 'Store salary data securely (encrypted locally)',
      'Tamil': 'சம்பள தரவை பாதுகாப்பாக சேமிக்க (encrypted locally)',
    },
    'eosb_fab_description': {
      'English': 'EOSB calculator & employer offer comparison',
      'Arabic': 'حاسبة مكافأة نهاية الخدمة',
      'Hindi': 'EOSB calculator',
      'Urdu': 'EOSB calculator',
      'Malayalam': 'EOSB calculator & employer offer comparison',
      'Nepali': 'EOSB calculator & employer offer comparison',
      'Bengali': 'EOSB calculator',
      'Filipino': 'EOSB calculator & employer offer comparison',
      'Tamil': 'EOSB கணக்கிடி & முதலாளி சலுகை ஒப்பீடு',
    },
    'eosb_confidence': {
      'English': 'Confidence',
      'Arabic': 'الثقة',
      'Hindi': 'Confidence',
      'Urdu': 'Confidence',
      'Malayalam': 'Confidence',
      'Nepali': 'Confidence',
      'Bengali': 'Confidence',
      'Filipino': 'Confidence',
      'Tamil': 'நம்பிக்கை',
    },
    'eosb_status': {
      'English': 'Status',
      'Arabic': 'الحالة',
      'Hindi': 'Status',
      'Urdu': 'Status',
      'Malayalam': 'Status',
      'Nepali': 'Status',
      'Bengali': 'Status',
      'Filipino': 'Status',
      'Tamil': 'நிலை',
    },
    'eosb_status_underpayment': {
      'English': 'Underpayment Detected',
      'Arabic': 'نقص محتمل',
      'Hindi': 'Underpayment',
      'Urdu': 'Underpayment',
      'Malayalam': 'Underpayment Detected',
      'Nepali': 'Underpayment Detected',
      'Bengali': 'Underpayment',
      'Filipino': 'Underpayment Detected',
      'Tamil': 'குறைவான ஊதியம் கண்டறியப்பட்டது',
    },
    'eosb_status_low_confidence': {
      'English': 'More Data Needed',
      'Arabic': 'بيانات إضافية',
      'Hindi': 'More data needed',
      'Urdu': 'More data needed',
      'Malayalam': 'More Data Needed',
      'Nepali': 'More Data Needed',
      'Bengali': 'More data needed',
      'Filipino': 'More Data Needed',
      'Tamil': 'மேலும் தரவு தேவை',
    },
    'eosb_status_ready': {
      'English': 'Estimate Ready',
      'Arabic': 'التقدير جاهز',
      'Hindi': 'Ready',
      'Urdu': 'Ready',
      'Malayalam': 'Estimate Ready',
      'Nepali': 'Estimate Ready',
      'Bengali': 'Ready',
      'Filipino': 'Estimate Ready',
      'Tamil': 'மதிப்பீடு தயார்',
    },
    'eosb_contract_analysis': {
      'English': 'Analyze Contract',
      'Arabic': 'تحليل العقد',
      'Hindi': 'Analyze Contract',
      'Urdu': 'Analyze Contract',
      'Malayalam': 'Analyze Contract',
      'Nepali': 'Analyze Contract',
      'Bengali': 'Analyze Contract',
      'Filipino': 'Analyze Contract',
      'Tamil': 'ஒப்பந்தத்தை பகுப்பாய்வு செய்',
    },
    'eosb_contract_analysis_desc': {
      'English':
          'Paste or scan your employment contract, offer letter, or settlement letter. AI extracts salary, dates, and flags risky clauses.',
      'Arabic': 'الصق أو امسح عقد العمل لاستخراج البيانات تلقائياً.',
      'Hindi': 'Scan contract to auto-fill EOSB details.',
      'Urdu': 'Scan contract to auto-fill EOSB details.',
      'Malayalam':
          'Paste or scan your employment contract, offer letter, or settlement letter. AI extracts salary, dates, and flags risky clauses.',
      'Nepali':
          'Paste or scan your employment contract, offer letter, or settlement letter. AI extracts salary, dates, and flags risky clauses.',
      'Bengali': 'Scan contract to auto-fill EOSB details.',
      'Filipino':
          'Paste or scan your employment contract, offer letter, or settlement letter. AI extracts salary, dates, and flags risky clauses.',
      'Tamil':
          'உங்கள் வேலை ஒப்பந்தம், சலுகை கடிதம் அல்லது தீர்வு கடிதத்தை paste அல்லது scan செய்யுங்கள். AI சம்பளம், தேதிகளை பிரித்தெடுத்து ஆபத்தான பிரிவுகளைக் குறிக்கிறது.',
    },
    'eosb_document_type': {
      'English': 'Document type',
      'Arabic': 'نوع المستند',
      'Hindi': 'Document type',
      'Urdu': 'Document type',
      'Malayalam': 'Document type',
      'Nepali': 'Document type',
      'Bengali': 'Document type',
      'Filipino': 'Document type',
      'Tamil': 'ஆவண வகை',
    },
    'eosb_contract_paste_hint': {
      'English': 'Paste OCR text from contract or settlement letter...',
      'Arabic': 'الصق نص المستند...',
      'Hindi': 'Paste document text...',
      'Urdu': 'Paste document text...',
      'Malayalam': 'Paste OCR text from contract or settlement letter...',
      'Nepali': 'Paste OCR text from contract or settlement letter...',
      'Bengali': 'Paste document text...',
      'Filipino': 'Paste OCR text from contract or settlement letter...',
      'Tamil':
          'ஒப்பந்தம் அல்லது தீர்வு கடிதத்திலிருந்து OCR உரை paste செய்யுங்கள்...',
    },
    'eosb_scan_document': {
      'English': 'Scan',
      'Arabic': 'مسح',
      'Hindi': 'Scan',
      'Urdu': 'Scan',
      'Malayalam': 'Scan',
      'Nepali': 'Scan',
      'Bengali': 'Scan',
      'Filipino': 'Scan',
      'Tamil': 'Scan',
    },
    'eosb_import_vault': {
      'English': 'Vault',
      'Arabic': 'الخزنة',
      'Hindi': 'Vault',
      'Urdu': 'Vault',
      'Malayalam': 'Vault',
      'Nepali': 'Vault',
      'Bengali': 'Vault',
      'Filipino': 'Vault',
      'Tamil': 'Vault',
    },
    'eosb_analyzing': {
      'English': 'Analyzing...',
      'Arabic': 'جاري التحليل...',
      'Hindi': 'Analyzing...',
      'Urdu': 'Analyzing...',
      'Malayalam': 'Analyzing...',
      'Nepali': 'Analyzing...',
      'Bengali': 'Analyzing...',
      'Filipino': 'Analyzing...',
      'Tamil': 'பகுப்பாய்வு...',
    },
    'eosb_analyze_contract': {
      'English': 'Analyze with AI',
      'Arabic': 'تحليل بالذكاء',
      'Hindi': 'Analyze',
      'Urdu': 'Analyze',
      'Malayalam': 'Analyze with AI',
      'Nepali': 'Analyze with AI',
      'Bengali': 'Analyze',
      'Filipino': 'Analyze with AI',
      'Tamil': 'AI-யுடன் பகுப்பாய்வு',
    },
    'eosb_contract_applied': {
      'English': 'Fields applied — review Employee Information',
      'Arabic': 'تم تطبيق الحقول',
      'Hindi': 'Fields applied',
      'Urdu': 'Fields applied',
      'Malayalam': 'Fields applied — review Employee Information',
      'Nepali': 'Fields applied — review Employee Information',
      'Bengali': 'Fields applied',
      'Filipino': 'Fields applied — review Employee Information',
      'Tamil':
          'புலங்கள் பயன்படுத்தப்பட்டன — தொழிலாளர் தகவலை மறுஆய்வு செய்யுங்கள்',
    },
    'eosb_contract_text_short': {
      'English': 'Enter at least 20 characters of document text',
      'Arabic': 'أدخل 20 حرفاً على الأقل',
      'Hindi': 'Text too short',
      'Urdu': 'Text too short',
      'Malayalam': 'Enter at least 20 characters of document text',
      'Nepali': 'Enter at least 20 characters of document text',
      'Bengali': 'Text too short',
      'Filipino': 'Enter at least 20 characters of document text',
      'Tamil': 'குறைந்தது 20 எழுத்துகள் ஆவண உரையை உள்ளிடவும்',
    },
    'eosb_contract_quality_short': {
      'English':
          'Document text is too short — please rescan or paste the full contract.',
      'Arabic': 'النص قصير جداً — أعد المسح أو الصق العقد كاملاً.',
      'Hindi': 'Document too short — rescan please.',
      'Urdu': 'Document too short — rescan please.',
      'Malayalam': 'Document too short — rescan please.',
      'Nepali': 'Document too short — rescan please.',
      'Bengali': 'Document too short — rescan please.',
      'Filipino':
          'Document text is too short — please rescan or paste the full contract.',
      'Tamil':
          'ஆவண உரை மிகக் குறுகியது — முழு ஒப்பந்தத்தை rescan அல்லது paste செய்யுங்கள்.',
    },
    'eosb_contract_quality_words': {
      'English': 'Not enough readable text detected — try a clearer scan.',
      'Arabic': 'نص غير كافٍ — جرّب مسحاً أوضح.',
      'Hindi': 'Not enough text — rescan clearly.',
      'Urdu': 'Not enough text — rescan clearly.',
      'Malayalam': 'Not enough text — rescan clearly.',
      'Nepali': 'Not enough text — rescan clearly.',
      'Bengali': 'Not enough text — rescan clearly.',
      'Filipino': 'Not enough readable text detected — try a clearer scan.',
      'Tamil':
          'போதுமான வாசிக்கக்கூடிய உரை கண்டறியப்படவில்லை — தெளிவான scan முயற்சிக்கவும்.',
    },
    'eosb_contract_quality_garbled': {
      'English':
          'Scan quality looks poor (garbled text) — rescan in good lighting.',
      'Arabic': 'جودة المسح ضعيفة — أعد المسح بإضاءة جيدة.',
      'Hindi': 'Garbled scan — retry in good light.',
      'Urdu': 'Garbled scan — retry in good light.',
      'Malayalam': 'Garbled scan — retry in good light.',
      'Nepali': 'Garbled scan — retry in good light.',
      'Bengali': 'Garbled scan — retry in good light.',
      'Filipino':
          'Scan quality looks poor (garbled text) — rescan in good lighting.',
      'Tamil':
          'Scan தரம் மோசமாகத் தோன்றுகிறது (garbled text) — நல்ல வெளிச்சத்தில் rescan செய்யுங்கள்.',
    },
    'eosb_contract_quality_ocr': {
      'English': 'OCR confidence is too low — rescan the document.',
      'Arabic': 'ثقة OCR منخفضة — أعد مسح المستند.',
      'Hindi': 'Low OCR confidence — rescan.',
      'Urdu': 'Low OCR confidence — rescan.',
      'Malayalam': 'Low OCR confidence — rescan.',
      'Nepali': 'Low OCR confidence — rescan.',
      'Bengali': 'Low OCR confidence — rescan.',
      'Filipino': 'OCR confidence is too low — rescan the document.',
      'Tamil': 'OCR நம்பிக்கை மிகக் குறைவு — ஆவணத்தை rescan செய்யுங்கள்.',
    },
    'eosb_ai_regenerate': {
      'English': 'Regenerate explanation',
      'Arabic': 'إعادة توليد الشرح',
      'Hindi': 'Regenerate explanation',
      'Urdu': 'Regenerate explanation',
      'Malayalam': 'Regenerate explanation',
      'Nepali': 'Regenerate explanation',
      'Bengali': 'Regenerate explanation',
      'Filipino': 'Regenerate explanation',
      'Tamil': 'விளக்கத்தை மீண்டும் உருவாக்கு',
    },
    'eosb_illegal_clauses': {
      'English': 'Possible Illegal Clauses',
      'Arabic': 'بنود غير قانونية',
      'Hindi': 'Illegal clauses',
      'Urdu': 'Illegal clauses',
      'Malayalam': 'Possible Illegal Clauses',
      'Nepali': 'Possible Illegal Clauses',
      'Bengali': 'Illegal clauses',
      'Filipino': 'Possible Illegal Clauses',
      'Tamil': 'சாத்தியமான சட்டவிரோத பிரிவுகள்',
    },
    'eosb_missing_benefits': {
      'English': 'Missing Benefits',
      'Arabic': 'مزايا ناقصة',
      'Hindi': 'Missing benefits',
      'Urdu': 'Missing benefits',
      'Malayalam': 'Missing Benefits',
      'Nepali': 'Missing Benefits',
      'Bengali': 'Missing benefits',
      'Filipino': 'Missing Benefits',
      'Tamil': 'காணாமல் போன பலன்கள்',
    },
    'eosb_continue_employee_info': {
      'English': 'Review Employee Details',
      'Arabic': 'مراجعة البيانات',
      'Hindi': 'Review details',
      'Urdu': 'Review details',
      'Malayalam': 'Review Employee Details',
      'Nepali': 'Review Employee Details',
      'Bengali': 'Review details',
      'Filipino': 'Review Employee Details',
      'Tamil': 'தொழிலாளர் விவரங்களை மறுஆய்வு',
    },
    'eosb_scenarios': {
      'English': 'Scenario Simulator',
      'Arabic': 'محاكاة السيناريوهات',
      'Hindi': 'Scenarios',
      'Urdu': 'Scenarios',
      'Malayalam': 'Scenario Simulator',
      'Nepali': 'Scenario Simulator',
      'Bengali': 'Scenarios',
      'Filipino': 'Scenario Simulator',
      'Tamil': 'காட்சி Simulator',
    },
    'eosb_scenarios_desc': {
      'English':
          'Compare settlement if you resign today, next month, or if employer terminates.',
      'Arabic': 'قارن التسوية بين سيناريوهات مختلفة.',
      'Hindi': 'Compare resignation scenarios.',
      'Urdu': 'Compare resignation scenarios.',
      'Malayalam':
          'Compare settlement if you resign today, next month, or if employer terminates.',
      'Nepali':
          'Compare settlement if you resign today, next month, or if employer terminates.',
      'Bengali': 'Compare resignation scenarios.',
      'Filipino':
          'Compare settlement if you resign today, next month, or if employer terminates.',
      'Tamil':
          'இன்று, அடுத்த மாதம் resign செய்தால், அல்லது முதலாளி முடித்தால் தீர்வை ஒப்பிடுங்கள்.',
    },
    'eosb_scenario_base': {
      'English': 'Current estimate',
      'Arabic': 'التقدير الحالي',
      'Hindi': 'Current',
      'Urdu': 'Current',
      'Malayalam': 'Current estimate',
      'Nepali': 'Current estimate',
      'Bengali': 'Current',
      'Filipino': 'Current estimate',
      'Tamil': 'தற்போதைய மதிப்பீடு',
    },
    'eosb_scenarios_empty_title': {
      'English': 'No scenarios yet',
      'Arabic': 'لا سيناريوهات',
      'Hindi': 'No scenarios',
      'Urdu': 'No scenarios',
      'Malayalam': 'No scenarios yet',
      'Nepali': 'No scenarios yet',
      'Bengali': 'No scenarios',
      'Filipino': 'No scenarios yet',
      'Tamil': 'இன்னும் காட்சிகள் இல்லை',
    },
    'eosb_scenarios_empty_desc': {
      'English':
          'Enter salary and employment dates to compare what-if scenarios.',
      'Arabic': 'أدخل الراتب وتواريخ العمل.',
      'Hindi': 'Enter employment details first.',
      'Urdu': 'Enter employment details first.',
      'Malayalam':
          'Enter salary and employment dates to compare what-if scenarios.',
      'Nepali':
          'Enter salary and employment dates to compare what-if scenarios.',
      'Bengali': 'Enter employment details first.',
      'Filipino':
          'Enter salary and employment dates to compare what-if scenarios.',
      'Tamil':
          'what-if காட்சிகளை ஒப்பிட சம்பளம் மற்றும் வேலை தேதிகளை உள்ளிடவும்.',
    },
    'eosb_scenario_resign_today': {
      'English': 'Resign today',
      'Arabic': 'استقالة اليوم',
      'Hindi': 'Resign today',
      'Urdu': 'Resign today',
      'Malayalam': 'Resign today',
      'Nepali': 'Resign today',
      'Bengali': 'Resign today',
      'Filipino': 'Resign today',
      'Tamil': 'இன்று resign',
    },
    'eosb_scenario_resign_today_desc': {
      'English': 'Employee resignation with current service',
      'Arabic': 'استقالة الموظف',
      'Hindi': 'Resignation',
      'Urdu': 'Resignation',
      'Malayalam': 'Employee resignation with current service',
      'Nepali': 'Employee resignation with current service',
      'Bengali': 'Resignation',
      'Filipino': 'Employee resignation with current service',
      'Tamil': 'தற்போதைய சேவையுடன் தொழிலாளர் resign',
    },
    'eosb_scenario_resign_next_month': {
      'English': 'Resign in 30 days',
      'Arabic': 'استقالة بعد شهر',
      'Hindi': 'Resign +30 days',
      'Urdu': 'Resign +30 days',
      'Malayalam': 'Resign in 30 days',
      'Nepali': 'Resign in 30 days',
      'Bengali': 'Resign +30 days',
      'Filipino': 'Resign in 30 days',
      'Tamil': '30 நாட்களில் resign',
    },
    'eosb_scenario_resign_next_month_desc': {
      'English': 'Extra month of service and gratuity accrual',
      'Arabic': 'شهر إضافي',
      'Hindi': '+30 days service',
      'Urdu': '+30 days service',
      'Malayalam': 'Extra month of service and gratuity accrual',
      'Nepali': 'Extra month of service and gratuity accrual',
      'Bengali': '+30 days service',
      'Filipino': 'Extra month of service and gratuity accrual',
      'Tamil': 'கூடுதல் மாத சேவை மற்றும் கிராஜுவிட்டி accrual',
    },
    'eosb_scenario_employer_terminates': {
      'English': 'Employer terminates',
      'Arabic': 'إنهاء من صاحب العمل',
      'Hindi': 'Employer termination',
      'Urdu': 'Employer termination',
      'Malayalam': 'Employer terminates',
      'Nepali': 'Employer terminates',
      'Bengali': 'Employer termination',
      'Filipino': 'Employer terminates',
      'Tamil': 'முதலாளி முடிக்கிறார்',
    },
    'eosb_scenario_employer_terminates_desc': {
      'English': 'Full gratuity — no resignation reduction',
      'Arabic': 'مكافأة كاملة',
      'Hindi': 'Full gratuity',
      'Urdu': 'Full gratuity',
      'Malayalam': 'Full gratuity — no resignation reduction',
      'Nepali': 'Full gratuity — no resignation reduction',
      'Bengali': 'Full gratuity',
      'Filipino': 'Full gratuity — no resignation reduction',
      'Tamil': 'முழு கிராஜுவிட்டி — resign குறைப்பு இல்லை',
    },
    'eosb_scenario_mutual': {
      'English': 'Mutual separation',
      'Arabic': 'انفصال بالتراضي',
      'Hindi': 'Mutual separation',
      'Urdu': 'Mutual separation',
      'Malayalam': 'Mutual separation',
      'Nepali': 'Mutual separation',
      'Bengali': 'Mutual separation',
      'Filipino': 'Mutual separation',
      'Tamil': 'பரஸ்பர பிரிவு',
    },
    'eosb_scenario_mutual_desc': {
      'English': 'Agreed exit — verify contract terms',
      'Arabic': 'تحقق من العقد',
      'Hindi': 'Check contract',
      'Urdu': 'Check contract',
      'Malayalam': 'Agreed exit — verify contract terms',
      'Nepali': 'Agreed exit — verify contract terms',
      'Bengali': 'Check contract',
      'Filipino': 'Agreed exit — verify contract terms',
      'Tamil':
          'ஒப்புக்கொள்ளப்பட்ட வெளியேற்றம் — ஒப்பந்த விதிமுறைகளை சரிபார்க்கவும்',
    },
    'eosb_scenario_contract_expires': {
      'English': 'Contract expires',
      'Arabic': 'انتهاء العقد',
      'Hindi': 'Contract expiry',
      'Urdu': 'Contract expiry',
      'Malayalam': 'Contract expires',
      'Nepali': 'Contract expires',
      'Bengali': 'Contract expiry',
      'Filipino': 'Contract expires',
      'Tamil': 'ஒப்பந்தம் காலாவதி',
    },
    'eosb_scenario_contract_expires_desc': {
      'English': 'Limited contract end-of-term',
      'Arabic': 'نهاية عقد محدد',
      'Hindi': 'Limited contract',
      'Urdu': 'Limited contract',
      'Malayalam': 'Limited contract end-of-term',
      'Nepali': 'Limited contract end-of-term',
      'Bengali': 'Limited contract',
      'Filipino': 'Limited contract end-of-term',
      'Tamil': 'வரையறுக்கப்பட்ட ஒப்பந்த கால முடிவு',
    },
    'eosb_scenario_salary_up': {
      'English': '10% salary increase',
      'Arabic': 'زيادة 10%',
      'Hindi': 'Salary +10%',
      'Urdu': 'Salary +10%',
      'Malayalam': '10% salary increase',
      'Nepali': '10% salary increase',
      'Bengali': 'Salary +10%',
      'Filipino': '10% salary increase',
      'Tamil': '10% சம்பள உயர்வு',
    },
    'eosb_scenario_salary_up_desc': {
      'English': 'Higher basic salary increases gratuity',
      'Arabic': 'راتب أعلى',
      'Hindi': 'Higher salary',
      'Urdu': 'Higher salary',
      'Malayalam': 'Higher basic salary increases gratuity',
      'Nepali': 'Higher basic salary increases gratuity',
      'Bengali': 'Higher salary',
      'Filipino': 'Higher basic salary increases gratuity',
      'Tamil': 'அதிக அடிப்படை சம்பளம் கிராஜுவிட்டியை அதிகரிக்கிறது',
    },
    'eosb_scenario_six_months': {
      'English': 'Work 6 more months',
      'Arabic': '6 أشهر إضافية',
      'Hindi': '+6 months',
      'Urdu': '+6 months',
      'Malayalam': 'Work 6 more months',
      'Nepali': 'Work 6 more months',
      'Bengali': '+6 months',
      'Filipino': 'Work 6 more months',
      'Tamil': '6 மாதம் கூடுதலாக வேலை',
    },
    'eosb_scenario_six_months_desc': {
      'English': 'Extended service increases EOSB',
      'Arabic': 'خدمة أطول',
      'Hindi': 'More service',
      'Urdu': 'More service',
      'Malayalam': 'Extended service increases EOSB',
      'Nepali': 'Extended service increases EOSB',
      'Bengali': 'More service',
      'Filipino': 'Extended service increases EOSB',
      'Tamil': 'நீண்ட சேவை EOSB-ஐ அதிகரிக்கிறது',
    },
    'eosb_timeline': {
      'English': 'Employment Timeline',
      'Arabic': 'الجدول الزمني',
      'Hindi': 'Timeline',
      'Urdu': 'Timeline',
      'Malayalam': 'Employment Timeline',
      'Nepali': 'Employment Timeline',
      'Bengali': 'Timeline',
      'Filipino': 'Employment Timeline',
      'Tamil': 'வேலை காலவரிசை',
    },
    'eosb_timeline_empty': {
      'English': 'Add joining date to see timeline',
      'Arabic': 'أضف تاريخ الالتحاق',
      'Hindi': 'Add joining date',
      'Urdu': 'Add joining date',
      'Malayalam': 'Add joining date to see timeline',
      'Nepali': 'Add joining date to see timeline',
      'Bengali': 'Add joining date',
      'Filipino': 'Add joining date to see timeline',
      'Tamil': 'காலவரிசையைப் பார்க்க சேரும் தேதியைச் சேர்க்கவும்',
    },
    'eosb_timeline_empty_title': {
      'English': 'No timeline yet',
      'Arabic': 'لا جدول زمني',
      'Hindi': 'No timeline',
      'Urdu': 'No timeline',
      'Malayalam': 'No timeline yet',
      'Nepali': 'No timeline yet',
      'Bengali': 'No timeline',
      'Filipino': 'No timeline yet',
      'Tamil': 'இன்னும் காலவரிசை இல்லை',
    },
    'eosb_timeline_empty_desc': {
      'English': 'Enter joining and last working dates.',
      'Arabic': 'أدخل التواريخ',
      'Hindi': 'Enter dates',
      'Urdu': 'Enter dates',
      'Malayalam': 'Enter joining and last working dates.',
      'Nepali': 'Enter joining and last working dates.',
      'Bengali': 'Enter dates',
      'Filipino': 'Enter joining and last working dates.',
      'Tamil': 'சேரும் மற்றும் கடைசி வேலை தேதிகளை உள்ளிடவும்.',
    },
    'eosb_timeline_joining': {
      'English': 'Joined company',
      'Arabic': 'بدء العمل',
      'Hindi': 'Joined',
      'Urdu': 'Joined',
      'Malayalam': 'Joined company',
      'Nepali': 'Joined company',
      'Bengali': 'Joined',
      'Filipino': 'Joined company',
      'Tamil': 'நிறுவனத்தில் சேர்ந்தது',
    },
    'eosb_timeline_joining_desc': {
      'English': 'Employment start date',
      'Arabic': 'تاريخ البداية',
      'Hindi': 'Start date',
      'Urdu': 'Start date',
      'Malayalam': 'Employment start date',
      'Nepali': 'Employment start date',
      'Bengali': 'Start date',
      'Filipino': 'Employment start date',
      'Tamil': 'வேலை தொடக்க தேதி',
    },
    'eosb_timeline_probation': {
      'English': 'Probation ends',
      'Arabic': 'نهاية التجربة',
      'Hindi': 'Probation end',
      'Urdu': 'Probation end',
      'Malayalam': 'Probation ends',
      'Nepali': 'Probation ends',
      'Bengali': 'Probation end',
      'Filipino': 'Probation ends',
      'Tamil': 'பிரபேஷன் முடிவு',
    },
    'eosb_timeline_probation_desc': {
      'English': 'Typical 3-month probation (verify contract)',
      'Arabic': '3 أشهر',
      'Hindi': '3 months',
      'Urdu': '3 months',
      'Malayalam': 'Typical 3-month probation (verify contract)',
      'Nepali': 'Typical 3-month probation (verify contract)',
      'Bengali': '3 months',
      'Filipino': 'Typical 3-month probation (verify contract)',
      'Tamil': 'வழக்கமான 3 மாத பிரபேஷன் (ஒப்பந்தம் சரிபார்க்கவும்)',
    },
    'eosb_timeline_confirmation': {
      'English': 'Confirmed employee',
      'Arabic': 'تثبيت',
      'Hindi': 'Confirmed',
      'Urdu': 'Confirmed',
      'Malayalam': 'Confirmed employee',
      'Nepali': 'Confirmed employee',
      'Bengali': 'Confirmed',
      'Filipino': 'Confirmed employee',
      'Tamil': 'உறுதிப்படுத்தப்பட்ட தொழிலாளர்',
    },
    'eosb_timeline_confirmation_desc': {
      'English': 'Full employment rights apply',
      'Arabic': 'حقوق كاملة',
      'Hindi': 'Full rights',
      'Urdu': 'Full rights',
      'Malayalam': 'Full employment rights apply',
      'Nepali': 'Full employment rights apply',
      'Bengali': 'Full rights',
      'Filipino': 'Full employment rights apply',
      'Tamil': 'முழு வேலை உரிமைகள் பொருந்தும்',
    },
    'eosb_timeline_last_day': {
      'English': 'Last working day',
      'Arabic': 'آخر يوم عمل',
      'Hindi': 'Last day',
      'Urdu': 'Last day',
      'Malayalam': 'Last working day',
      'Nepali': 'Last working day',
      'Bengali': 'Last day',
      'Filipino': 'Last working day',
      'Tamil': 'கடைசி வேலை நாள்',
    },
    'eosb_timeline_last_day_desc': {
      'English': 'End of active employment',
      'Arabic': 'نهاية العمل',
      'Hindi': 'End employment',
      'Urdu': 'End employment',
      'Malayalam': 'End of active employment',
      'Nepali': 'End of active employment',
      'Bengali': 'End employment',
      'Filipino': 'End of active employment',
      'Tamil': 'செயலில் வேலை முடிவு',
    },
    'eosb_timeline_settlement': {
      'English': 'Expected settlement',
      'Arabic': 'التسوية المتوقعة',
      'Hindi': 'Settlement',
      'Urdu': 'Settlement',
      'Malayalam': 'Expected settlement',
      'Nepali': 'Expected settlement',
      'Bengali': 'Settlement',
      'Filipino': 'Expected settlement',
      'Tamil': 'எதிர்பார்க்கப்படும் தீர்வு',
    },
    'eosb_timeline_settlement_desc': {
      'English': 'Typical ~14 days after last day',
      'Arabic': '~14 يوم',
      'Hindi': '~14 days',
      'Urdu': '~14 days',
      'Malayalam': 'Typical ~14 days after last day',
      'Nepali': 'Typical ~14 days after last day',
      'Bengali': '~14 days',
      'Filipino': 'Typical ~14 days after last day',
      'Tamil': 'கடைசி நாளுக்குப் பிறகு ~14 நாட்கள்',
    },
    'eosb_timeline_eosb_calc': {
      'English': 'EOSB calculated',
      'Arabic': 'تم الحساب',
      'Hindi': 'Calculated',
      'Urdu': 'Calculated',
      'Malayalam': 'EOSB calculated',
      'Nepali': 'EOSB calculated',
      'Bengali': 'Calculated',
      'Filipino': 'EOSB calculated',
      'Tamil': 'EOSB கணக்கிடப்பட்டது',
    },
    'eosb_timeline_eosb_calc_desc': {
      'English': 'RAABTA estimate generated',
      'Arabic': 'تقدير RAABTA',
      'Hindi': 'RAABTA estimate',
      'Urdu': 'RAABTA estimate',
      'Malayalam': 'RAABTA estimate generated',
      'Nepali': 'RAABTA estimate generated',
      'Bengali': 'RAABTA estimate',
      'Filipino': 'RAABTA estimate generated',
      'Tamil': 'Raabta மதிப்பீடு உருவாக்கப்பட்டது',
    },
    'eosb_legal_review': {
      'English': 'AI Legal Review',
      'Arabic': 'مراجعة قانونية',
      'Hindi': 'Legal review',
      'Urdu': 'Legal review',
      'Malayalam': 'AI Legal Review',
      'Nepali': 'AI Legal Review',
      'Bengali': 'Legal review',
      'Filipino': 'AI Legal Review',
      'Tamil': 'AI சட்ட மறுஆய்வு',
    },
    'eosb_possible_underpayment': {
      'English': 'Possible Underpayments',
      'Arabic': 'نقص محتمل',
      'Hindi': 'Underpayments',
      'Urdu': 'Underpayments',
      'Malayalam': 'Possible Underpayments',
      'Nepali': 'Possible Underpayments',
      'Bengali': 'Underpayments',
      'Filipino': 'Possible Underpayments',
      'Tamil': 'சாத்தியமான குறைவான ஊதியம்',
    },
    'eosb_payslip_title': {
      'English': 'Payslip consistency check',
      'Arabic': 'فحص اتساق كشوف الرواتب',
      'Hindi': 'Payslip consistency check',
      'Urdu': 'Payslip consistency check',
      'Malayalam': 'Payslip consistency check',
      'Nepali': 'Payslip consistency check',
      'Bengali': 'Payslip consistency check',
      'Filipino': 'Payslip consistency check',
      'Tamil': 'Payslip consistency check',
    },
    'eosb_payslip_subtitle': {
      'English':
          'Enter basic salary figures from 2 or more payslips and compare them with each other and your contract on file.',
      'Arabic':
          'أدخل أرقام الراتب الأساسي من كشفين أو أكثر وقارنها ببعضها وبعقدك المسجل.',
      'Hindi':
          'Enter basic salary from 2+ payslips and compare with your contract on file.',
      'Urdu':
          'Enter basic salary from 2+ payslips and compare with your contract on file.',
      'Malayalam':
          'Enter basic salary figures from 2 or more payslips and compare them with each other and your contract on file.',
      'Nepali':
          'Enter basic salary figures from 2 or more payslips and compare them with each other and your contract on file.',
      'Bengali':
          'Enter basic salary from 2+ payslips and compare with your contract on file.',
      'Filipino':
          'Enter basic salary figures from 2 or more payslips and compare them with each other and your contract on file.',
      'Tamil':
          'Enter basic salary figures from 2 or more payslips and compare them with each other and your contract on file.',
    },
    'eosb_payslip_no_accusation': {
      'English': 'This is a factual comparison only — not proof of wrongdoing.',
      'Arabic': 'هذا مقارنة واقعية فقط — وليس دليلاً على سوء سلوك.',
      'Hindi': 'Factual comparison only — not proof of wrongdoing.',
      'Urdu': 'Factual comparison only — not proof of wrongdoing.',
      'Malayalam':
          'This is a factual comparison only — not proof of wrongdoing.',
      'Nepali': 'This is a factual comparison only — not proof of wrongdoing.',
      'Bengali': 'Factual comparison only — not proof of wrongdoing.',
      'Filipino':
          'This is a factual comparison only — not proof of wrongdoing.',
      'Tamil': 'This is a factual comparison only — not proof of wrongdoing.',
    },
    'eosb_payslip_hub_button': {
      'English': 'Compare payslip figures',
      'Arabic': 'قارن أرقام كشوف الرواتب',
      'Hindi': 'Compare payslip figures',
      'Urdu': 'Compare payslip figures',
      'Malayalam': 'Compare payslip figures',
      'Nepali': 'Compare payslip figures',
      'Bengali': 'Compare payslip figures',
      'Filipino': 'Compare payslip figures',
      'Tamil': 'Compare payslip figures',
    },
    'eosb_payslip_contract_known': {
      'English': 'On file: basic salary QAR {salary}, employer {employer}.',
      'Arabic': 'مسجل: الراتب الأساسي {salary} ر.ق، صاحب العمل {employer}.',
      'Hindi': 'On file: basic salary QAR {salary}, employer {employer}.',
      'Urdu': 'On file: basic salary QAR {salary}, employer {employer}.',
      'Malayalam': 'On file: basic salary QAR {salary}, employer {employer}.',
      'Nepali': 'On file: basic salary QAR {salary}, employer {employer}.',
      'Bengali': 'On file: basic salary QAR {salary}, employer {employer}.',
      'Filipino': 'On file: basic salary QAR {salary}, employer {employer}.',
      'Tamil': 'On file: basic salary QAR {salary}, employer {employer}.',
    },
    'eosb_payslip_no_contract': {
      'English':
          'No contract basic salary on file yet — add it in employee info to compare payslip figures against your contract.',
      'Arabic': 'لا يوجد راتب أساسي مسجل بعد — أضفه في بيانات الموظف للمقارنة.',
      'Hindi':
          'No contract basic salary on file — add in employee info to compare.',
      'Urdu':
          'No contract basic salary on file — add in employee info to compare.',
      'Malayalam':
          'No contract basic salary on file yet — add it in employee info to compare payslip figures against your contract.',
      'Nepali':
          'No contract basic salary on file yet — add it in employee info to compare payslip figures against your contract.',
      'Bengali':
          'No contract basic salary on file — add in employee info to compare.',
      'Filipino':
          'No contract basic salary on file yet — add it in employee info to compare payslip figures against your contract.',
      'Tamil':
          'No contract basic salary on file yet — add it in employee info to compare payslip figures against your contract.',
    },
    'eosb_payslip_not_set': {
      'English': '(not set)',
      'Arabic': '(غير محدد)',
      'Hindi': '(not set)',
      'Urdu': '(not set)',
      'Malayalam': '(not set)',
      'Nepali': '(not set)',
      'Bengali': '(not set)',
      'Filipino': '(not set)',
      'Tamil': '(not set)',
    },
    'eosb_payslip_need_more': {
      'English': 'More payslip entries needed',
      'Arabic': 'مطلوب المزيد من كشوف الرواتب',
      'Hindi': 'More payslip entries needed',
      'Urdu': 'More payslip entries needed',
      'Malayalam': 'More payslip entries needed',
      'Nepali': 'More payslip entries needed',
      'Bengali': 'More payslip entries needed',
      'Filipino': 'More payslip entries needed',
      'Tamil': 'More payslip entries needed',
    },
    'eosb_payslip_progress': {
      'English': '{current} of {required} payslips with basic salary entered',
      'Arabic': '{current} من {required} كشوف برواتب أساسية مدخلة',
      'Hindi': '{current} of {required} payslips with basic salary entered',
      'Urdu': '{current} of {required} payslips with basic salary entered',
      'Malayalam': '{current} of {required} payslips with basic salary entered',
      'Nepali': '{current} of {required} payslips with basic salary entered',
      'Bengali': '{current} of {required} payslips with basic salary entered',
      'Filipino': '{current} of {required} payslips with basic salary entered',
      'Tamil': '{current} of {required} payslips with basic salary entered',
    },
    'eosb_payslip_add_row': {
      'English': 'Add another month',
      'Arabic': 'أضف شهراً آخر',
      'Hindi': 'Add another month',
      'Urdu': 'Add another month',
      'Malayalam': 'Add another month',
      'Nepali': 'Add another month',
      'Bengali': 'Add another month',
      'Filipino': 'Add another month',
      'Tamil': 'Add another month',
    },
    'eosb_payslip_run': {
      'English': 'Compare figures',
      'Arabic': 'قارن الأرقام',
      'Hindi': 'Compare figures',
      'Urdu': 'Compare figures',
      'Malayalam': 'Compare figures',
      'Nepali': 'Compare figures',
      'Bengali': 'Compare figures',
      'Filipino': 'Compare figures',
      'Tamil': 'Compare figures',
    },
    'eosb_payslip_month': {
      'English': 'Month',
      'Arabic': 'الشهر',
      'Hindi': 'Month',
      'Urdu': 'Month',
      'Malayalam': 'Month',
      'Nepali': 'Month',
      'Bengali': 'Month',
      'Filipino': 'Month',
      'Tamil': 'Month',
    },
    'eosb_payslip_year': {
      'English': 'Year',
      'Arabic': 'السنة',
      'Hindi': 'Year',
      'Urdu': 'Year',
      'Malayalam': 'Year',
      'Nepali': 'Year',
      'Bengali': 'Year',
      'Filipino': 'Year',
      'Tamil': 'Year',
    },
    'eosb_payslip_basic_salary': {
      'English': 'Basic salary (QAR)',
      'Arabic': 'الراتب الأساسي (ر.ق)',
      'Hindi': 'Basic salary (QAR)',
      'Urdu': 'Basic salary (QAR)',
      'Malayalam': 'Basic salary (QAR)',
      'Nepali': 'Basic salary (QAR)',
      'Bengali': 'Basic salary (QAR)',
      'Filipino': 'Basic salary (QAR)',
      'Tamil': 'Basic salary (QAR)',
    },
    'eosb_payslip_housing': {
      'English': 'Housing allowance (QAR, optional)',
      'Arabic': 'بدل السكن (ر.ق، اختياري)',
      'Hindi': 'Housing allowance (optional)',
      'Urdu': 'Housing allowance (optional)',
      'Malayalam': 'Housing allowance (QAR, optional)',
      'Nepali': 'Housing allowance (QAR, optional)',
      'Bengali': 'Housing allowance (optional)',
      'Filipino': 'Housing allowance (QAR, optional)',
      'Tamil': 'Housing allowance (QAR, optional)',
    },
    'eosb_payslip_transport': {
      'English': 'Transport allowance (QAR, optional)',
      'Arabic': 'بدل النقل (ر.ق، اختياري)',
      'Hindi': 'Transport allowance (optional)',
      'Urdu': 'Transport allowance (optional)',
      'Malayalam': 'Transport allowance (QAR, optional)',
      'Nepali': 'Transport allowance (QAR, optional)',
      'Bengali': 'Transport allowance (optional)',
      'Filipino': 'Transport allowance (QAR, optional)',
      'Tamil': 'Transport allowance (QAR, optional)',
    },
    'eosb_payslip_employer': {
      'English': 'Employer name on payslip (optional)',
      'Arabic': 'اسم صاحب العمل على الكشف (اختياري)',
      'Hindi': 'Employer name on payslip (optional)',
      'Urdu': 'Employer name on payslip (optional)',
      'Malayalam': 'Employer name on payslip (optional)',
      'Nepali': 'Employer name on payslip (optional)',
      'Bengali': 'Employer name on payslip (optional)',
      'Filipino': 'Employer name on payslip (optional)',
      'Tamil': 'Employer name on payslip (optional)',
    },
    'eosb_payslip_show_optional': {
      'English': 'Add allowances / employer (optional)',
      'Arabic': 'أضف البدلات / صاحب العمل (اختياري)',
      'Hindi': 'Add allowances / employer (optional)',
      'Urdu': 'Add allowances / employer (optional)',
      'Malayalam': 'Add allowances / employer (optional)',
      'Nepali': 'Add allowances / employer (optional)',
      'Bengali': 'Add allowances / employer (optional)',
      'Filipino': 'Add allowances / employer (optional)',
      'Tamil': 'Add allowances / employer (optional)',
    },
    'eosb_payslip_hide_optional': {
      'English': 'Hide optional fields',
      'Arabic': 'إخفاء الحقول الاختيارية',
      'Hindi': 'Hide optional fields',
      'Urdu': 'Hide optional fields',
      'Malayalam': 'Hide optional fields',
      'Nepali': 'Hide optional fields',
      'Bengali': 'Hide optional fields',
      'Filipino': 'Hide optional fields',
      'Tamil': 'Hide optional fields',
    },
    'eosb_payslip_row_label': {
      'English': 'Payslip',
      'Arabic': 'كشف راتب',
      'Hindi': 'Payslip',
      'Urdu': 'Payslip',
      'Malayalam': 'Payslip',
      'Nepali': 'Payslip',
      'Bengali': 'Payslip',
      'Filipino': 'Payslip',
      'Tamil': 'Payslip',
    },
    'eosb_payslip_results_heading': {
      'English': 'Comparison results',
      'Arabic': 'نتائج المقارنة',
      'Hindi': 'Comparison results',
      'Urdu': 'Comparison results',
      'Malayalam': 'Comparison results',
      'Nepali': 'Comparison results',
      'Bengali': 'Comparison results',
      'Filipino': 'Comparison results',
      'Tamil': 'Comparison results',
    },
    'eosb_payslip_no_discrepancies': {
      'English':
          'Across the payslip figures you entered, basic salary and optional fields match each other and your contract on file.',
      'Arabic':
          'وفق الأرقام المدخلة، الراتب الأساسي والحقول الاختيارية متسقة مع بعضها ومع عقدك.',
      'Hindi':
          'Entered payslip figures match each other and your contract on file.',
      'Urdu':
          'Entered payslip figures match each other and your contract on file.',
      'Malayalam':
          'Across the payslip figures you entered, basic salary and optional fields match each other and your contract on file.',
      'Nepali':
          'Across the payslip figures you entered, basic salary and optional fields match each other and your contract on file.',
      'Bengali':
          'Entered payslip figures match each other and your contract on file.',
      'Filipino':
          'Across the payslip figures you entered, basic salary and optional fields match each other and your contract on file.',
      'Tamil':
          'Across the payslip figures you entered, basic salary and optional fields match each other and your contract on file.',
    },
    'eosb_payslip_possible_framing': {
      'English':
          'These figures differ across the records you entered — worth verifying with payroll or HR.',
      'Arabic':
          'هذه الأرقام تختلف بين السجلات المدخلة — يستحق التحقق من payroll أو HR.',
      'Hindi':
          'Figures differ across your entries — worth verifying with payroll or HR.',
      'Urdu':
          'Figures differ across your entries — worth verifying with payroll or HR.',
      'Malayalam':
          'These figures differ across the records you entered — worth verifying with payroll or HR.',
      'Nepali':
          'These figures differ across the records you entered — worth verifying with payroll or HR.',
      'Bengali':
          'Figures differ across your entries — worth verifying with payroll or HR.',
      'Filipino':
          'These figures differ across the records you entered — worth verifying with payroll or HR.',
      'Tamil':
          'These figures differ across the records you entered — worth verifying with payroll or HR.',
    },
    'eosb_payslip_verify_suffix': {
      'English':
          'This may be worth checking with your employer or keeping as a record if you were not informed of a change.',
      'Arabic':
          'قد يستحق التحقق مع صاحب العمل أو الاحتفاظ به كسجل إن لم تُبلَغ بالتغيير.',
      'Hindi':
          'Worth checking with your employer or keeping as a record if you were not informed.',
      'Urdu':
          'Worth checking with your employer or keeping as a record if you were not informed.',
      'Malayalam':
          'This may be worth checking with your employer or keeping as a record if you were not informed of a change.',
      'Nepali':
          'This may be worth checking with your employer or keeping as a record if you were not informed of a change.',
      'Bengali':
          'Worth checking with your employer or keeping as a record if you were not informed.',
      'Filipino':
          'This may be worth checking with your employer or keeping as a record if you were not informed of a change.',
      'Tamil':
          'This may be worth checking with your employer or keeping as a record if you were not informed of a change.',
    },
    'eosb_payslip_disc_basic_pair': {
      'English':
          'Basic salary on your {monthA} payslip (QAR {salaryA}) differs from your {monthB} payslip (QAR {salaryB}).',
      'Arabic':
          'الراتب الأساسي في كشف {monthA} ({salaryA} ر.ق) يختلف عن كشف {monthB} ({salaryB} ر.ق).',
      'Hindi':
          'Basic salary on {monthA} payslip (QAR {salaryA}) differs from {monthB} (QAR {salaryB}).',
      'Urdu':
          'Basic salary on {monthA} payslip (QAR {salaryA}) differs from {monthB} (QAR {salaryB}).',
      'Malayalam':
          'Basic salary on your {monthA} payslip (QAR {salaryA}) differs from your {monthB} payslip (QAR {salaryB}).',
      'Nepali':
          'Basic salary on your {monthA} payslip (QAR {salaryA}) differs from your {monthB} payslip (QAR {salaryB}).',
      'Bengali':
          'Basic salary on {monthA} payslip (QAR {salaryA}) differs from {monthB} (QAR {salaryB}).',
      'Filipino':
          'Basic salary on your {monthA} payslip (QAR {salaryA}) differs from your {monthB} payslip (QAR {salaryB}).',
      'Tamil':
          'Basic salary on your {monthA} payslip (QAR {salaryA}) differs from your {monthB} payslip (QAR {salaryB}).',
    },
    'eosb_payslip_disc_basic_contract': {
      'English':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your contract on file (QAR {contractSalary}).',
      'Arabic':
          'الراتب الأساسي في كشف {month} ({payslipSalary} ر.ق) يختلف عن عقدك ({contractSalary} ر.ق).',
      'Hindi':
          'Basic salary on {month} payslip (QAR {payslipSalary}) differs from contract (QAR {contractSalary}).',
      'Urdu':
          'Basic salary on {month} payslip (QAR {payslipSalary}) differs from contract (QAR {contractSalary}).',
      'Malayalam':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your contract on file (QAR {contractSalary}).',
      'Nepali':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your contract on file (QAR {contractSalary}).',
      'Bengali':
          'Basic salary on {month} payslip (QAR {payslipSalary}) differs from contract (QAR {contractSalary}).',
      'Filipino':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your contract on file (QAR {contractSalary}).',
      'Tamil':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your contract on file (QAR {contractSalary}).',
    },
    'eosb_payslip_disc_basic_both': {
      'English':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your {otherMonth} payslip (QAR {otherSalary}) and your contract on file (QAR {contractSalary}).',
      'Arabic':
          'الراتب الأساسي في كشف {month} ({payslipSalary} ر.ق) يختلف عن {otherMonth} ({otherSalary} ر.ق) وعن عقدك ({contractSalary} ر.ق).',
      'Hindi':
          'Basic salary on {month} (QAR {payslipSalary}) differs from {otherMonth} (QAR {otherSalary}) and contract (QAR {contractSalary}).',
      'Urdu':
          'Basic salary on {month} (QAR {payslipSalary}) differs from {otherMonth} (QAR {otherSalary}) and contract (QAR {contractSalary}).',
      'Malayalam':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your {otherMonth} payslip (QAR {otherSalary}) and your contract on file (QAR {contractSalary}).',
      'Nepali':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your {otherMonth} payslip (QAR {otherSalary}) and your contract on file (QAR {contractSalary}).',
      'Bengali':
          'Basic salary on {month} (QAR {payslipSalary}) differs from {otherMonth} (QAR {otherSalary}) and contract (QAR {contractSalary}).',
      'Filipino':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your {otherMonth} payslip (QAR {otherSalary}) and your contract on file (QAR {contractSalary}).',
      'Tamil':
          'Basic salary on your {month} payslip (QAR {payslipSalary}) differs from your {otherMonth} payslip (QAR {otherSalary}) and your contract on file (QAR {contractSalary}).',
    },
    'eosb_payslip_disc_missing_month': {
      'English':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
      'Arabic': 'لم يُدخل كشف لـ {month} — سجّلت {monthBefore} و{monthAfter}.',
      'Hindi':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
      'Urdu':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
      'Malayalam':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
      'Nepali':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
      'Bengali':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
      'Filipino':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
      'Tamil':
          'No payslip entered for {month} — you recorded {monthBefore} and {monthAfter}.',
    },
    'eosb_payslip_disc_employer_pair': {
      'English':
          'Employer name on your {monthA} payslip ({nameA}) differs from your {monthB} payslip ({nameB}).',
      'Arabic':
          'اسم صاحب العمل في كشف {monthA} ({nameA}) يختلف عن كشف {monthB} ({nameB}).',
      'Hindi':
          'Employer on {monthA} ({nameA}) differs from {monthB} ({nameB}).',
      'Urdu': 'Employer on {monthA} ({nameA}) differs from {monthB} ({nameB}).',
      'Malayalam':
          'Employer name on your {monthA} payslip ({nameA}) differs from your {monthB} payslip ({nameB}).',
      'Filipino':
          'Employer name on your {monthA} payslip ({nameA}) differs from your {monthB} payslip ({nameB}).',
      'Nepali':
          'Employer name on your {monthA} payslip ({nameA}) differs from your {monthB} payslip ({nameB}).',
      'Bengali':
          'Employer on {monthA} ({nameA}) differs from {monthB} ({nameB}).',
      'Tamil':
          'Employer name on your {monthA} payslip ({nameA}) differs from your {monthB} payslip ({nameB}).',
    },
    'eosb_payslip_disc_employer_contract': {
      'English':
          'Employer name on your {month} payslip ({payslipEmployer}) differs from your contract on file ({contractEmployer}).',
      'Arabic':
          'اسم صاحب العمل في كشف {month} ({payslipEmployer}) يختلف عن عقدك ({contractEmployer}).',
      'Hindi':
          'Employer on {month} ({payslipEmployer}) differs from contract ({contractEmployer}).',
      'Urdu':
          'Employer on {month} ({payslipEmployer}) differs from contract ({contractEmployer}).',
      'Malayalam':
          'Employer name on your {month} payslip ({payslipEmployer}) differs from your contract on file ({contractEmployer}).',
      'Nepali':
          'Employer name on your {month} payslip ({payslipEmployer}) differs from your contract on file ({contractEmployer}).',
      'Bengali':
          'Employer on {month} ({payslipEmployer}) differs from contract ({contractEmployer}).',
      'Filipino':
          'Employer name on your {month} payslip ({payslipEmployer}) differs from your contract on file ({contractEmployer}).',
      'Tamil':
          'Employer name on your {month} payslip ({payslipEmployer}) differs from your contract on file ({contractEmployer}).',
    },
    'eosb_payslip_disc_housing': {
      'English':
          'Housing allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Arabic':
          'بدل السكن في كشف {month} ({amount} ر.ق) يختلف عن كشف {refMonth} ({refAmount} ر.ق).',
      'Hindi':
          'Housing allowance on {month} (QAR {amount}) differs from {refMonth} (QAR {refAmount}).',
      'Urdu':
          'Housing allowance on {month} (QAR {amount}) differs from {refMonth} (QAR {refAmount}).',
      'Malayalam':
          'Housing allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Nepali':
          'Housing allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Bengali':
          'Housing allowance on {month} (QAR {amount}) differs from {refMonth} (QAR {refAmount}).',
      'Filipino':
          'Housing allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Tamil':
          'Housing allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
    },
    'eosb_payslip_disc_transport': {
      'English':
          'Transport allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Arabic':
          'بدل النقل في كشف {month} ({amount} ر.ق) يختلف عن كشف {refMonth} ({refAmount} ر.ق).',
      'Hindi':
          'Transport allowance on {month} (QAR {amount}) differs from {refMonth} (QAR {refAmount}).',
      'Urdu':
          'Transport allowance on {month} (QAR {amount}) differs from {refMonth} (QAR {refAmount}).',
      'Malayalam':
          'Transport allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Nepali':
          'Transport allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Bengali':
          'Transport allowance on {month} (QAR {amount}) differs from {refMonth} (QAR {refAmount}).',
      'Filipino':
          'Transport allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
      'Tamil':
          'Transport allowance on your {month} payslip (QAR {amount}) differs from your {refMonth} payslip (QAR {refAmount}).',
    },
    'eosb_payslip_action_hr': {
      'English':
          'Ask HR or payroll to confirm any salary or allowance changes, and keep your payslips as a personal record.',
      'Arabic':
          'اسأل HR أو payroll لتأكيد أي تغييرات في الراتب أو البدلات، واحتفظ بكشوفك كسجل شخصي.',
      'Hindi':
          'Ask HR/payroll to confirm changes and keep payslips as a personal record.',
      'Urdu':
          'Ask HR/payroll to confirm changes and keep payslips as a personal record.',
      'Malayalam':
          'Ask HR or payroll to confirm any salary or allowance changes, and keep your payslips as a personal record.',
      'Nepali':
          'Ask HR or payroll to confirm any salary or allowance changes, and keep your payslips as a personal record.',
      'Bengali':
          'Ask HR/payroll to confirm changes and keep payslips as a personal record.',
      'Filipino':
          'Ask HR or payroll to confirm any salary or allowance changes, and keep your payslips as a personal record.',
      'Tamil':
          'Ask HR or payroll to confirm any salary or allowance changes, and keep your payslips as a personal record.',
    },
    'eosb_payslip_add_timeline': {
      'English': 'Save comparison to Case Timeline',
      'Arabic': 'حفظ المقارنة في الجدول الزمني',
      'Hindi': 'Save to Case Timeline',
      'Urdu': 'Save to Case Timeline',
      'Malayalam': 'Save comparison to Case Timeline',
      'Nepali': 'Save comparison to Case Timeline',
      'Bengali': 'Save to Case Timeline',
      'Filipino': 'Save comparison to Case Timeline',
      'Tamil': 'Save comparison to Case Timeline',
    },
    'eosb_payslip_timeline_title': {
      'English': 'Payslip figure comparison',
      'Arabic': 'مقارنة أرقام كشوف الرواتب',
      'Hindi': 'Payslip figure comparison',
      'Urdu': 'Payslip figure comparison',
      'Malayalam': 'Payslip figure comparison',
      'Nepali': 'Payslip figure comparison',
      'Bengali': 'Payslip figure comparison',
      'Filipino': 'Payslip figure comparison',
      'Tamil': 'Payslip figure comparison',
    },
    'eosb_payslip_timeline_saved': {
      'English': 'Saved to Case Timeline',
      'Arabic': 'تم الحفظ في الجدول الزمني',
      'Hindi': 'Saved to Case Timeline',
      'Urdu': 'Saved to Case Timeline',
      'Malayalam': 'Saved to Case Timeline',
      'Nepali': 'Saved to Case Timeline',
      'Bengali': 'Saved to Case Timeline',
      'Filipino': 'Saved to Case Timeline',
      'Tamil': 'Saved to Case Timeline',
    },
    'eosb_payslip_set_contract': {
      'English': 'Add contract salary in employee info',
      'Arabic': 'أضف راتب العقد في بيانات الموظف',
      'Hindi': 'Add contract salary in employee info',
      'Urdu': 'Add contract salary in employee info',
      'Malayalam': 'Add contract salary in employee info',
      'Nepali': 'Add contract salary in employee info',
      'Bengali': 'Add contract salary in employee info',
      'Filipino': 'Add contract salary in employee info',
      'Tamil': 'Add contract salary in employee info',
    },
    'eosb_labour_law_issues': {
      'English': 'Labour Law Issues',
      'Arabic': 'قانون العمل',
      'Hindi': 'Labour law',
      'Urdu': 'Labour law',
      'Malayalam': 'Labour Law Issues',
      'Nepali': 'Labour Law Issues',
      'Bengali': 'Labour law',
      'Filipino': 'Labour Law Issues',
      'Tamil': 'தொழிலாளர் சட்டம் சிக்கல்கள்',
    },
    'eosb_contract_risks': {
      'English': 'Contract Risks',
      'Arabic': 'مخاطر العقد',
      'Hindi': 'Contract risks',
      'Urdu': 'Contract risks',
      'Malayalam': 'Contract Risks',
      'Nepali': 'Contract Risks',
      'Bengali': 'Contract risks',
      'Filipino': 'Contract Risks',
      'Tamil': 'ஒப்பந்த அபாயங்கள்',
    },
    'eosb_negotiation_advice': {
      'English': 'Negotiation Advice',
      'Arabic': 'نصائح التفاوض',
      'Hindi': 'Negotiation',
      'Urdu': 'Negotiation',
      'Malayalam': 'Negotiation Advice',
      'Nepali': 'Negotiation Advice',
      'Bengali': 'Negotiation',
      'Filipino': 'Negotiation Advice',
      'Tamil': 'பேரம் ஆலோசனை',
    },
    'eosb_required_documents': {
      'English': 'Required Documents',
      'Arabic': 'مستندات مطلوبة',
      'Hindi': 'Documents',
      'Urdu': 'Documents',
      'Malayalam': 'Required Documents',
      'Nepali': 'Required Documents',
      'Bengali': 'Documents',
      'Filipino': 'Required Documents',
      'Tamil': 'தேவையான ஆவணங்கள்',
    },
    'eosb_deadlines': {
      'English': 'Important Deadlines',
      'Arabic': 'مواعيد مهمة',
      'Hindi': 'Deadlines',
      'Urdu': 'Deadlines',
      'Malayalam': 'Important Deadlines',
      'Nepali': 'Important Deadlines',
      'Bengali': 'Deadlines',
      'Filipino': 'Important Deadlines',
      'Tamil': 'முக்கிய காலக்கெடுகள்',
    },
    'eosb_ai_error': {
      'English': 'Could not load AI review',
      'Arabic': 'خطأ',
      'Hindi': 'AI error',
      'Urdu': 'AI error',
      'Malayalam': 'Could not load AI review',
      'Nepali': 'Could not load AI review',
      'Bengali': 'AI error',
      'Filipino': 'Could not load AI review',
      'Tamil': 'AI மறுஆய்வை ஏற்ற முடியவில்லை',
    },
    'eosb_breakdown_chart': {
      'English': 'Settlement Breakdown',
      'Arabic': 'تفصيل التسوية',
      'Hindi': 'Breakdown',
      'Urdu': 'Breakdown',
      'Malayalam': 'Settlement Breakdown',
      'Nepali': 'Settlement Breakdown',
      'Bengali': 'Breakdown',
      'Filipino': 'Settlement Breakdown',
      'Tamil': 'தீர்வு பிரிவினை',
    },
    'eosb_share': {
      'English': 'Share',
      'Arabic': 'مشاركة',
      'Hindi': 'Share',
      'Urdu': 'Share',
      'Malayalam': 'Share',
      'Nepali': 'Share',
      'Bengali': 'Share',
      'Filipino': 'Share',
      'Tamil': 'பகிர்',
    },
    'eosb_annual_bonus': {
      'English': 'Annual Bonus',
      'Arabic': 'مكافأة سنوية',
      'Hindi': 'Bonus',
      'Urdu': 'Bonus',
      'Malayalam': 'Annual Bonus',
      'Nepali': 'Annual Bonus',
      'Bengali': 'Bonus',
      'Filipino': 'Annual Bonus',
      'Tamil': 'ஆண்டு Bonus',
    },
    'eosb_commission': {
      'English': 'Commission',
      'Arabic': 'عمولة',
      'Hindi': 'Commission',
      'Urdu': 'Commission',
      'Malayalam': 'Commission',
      'Nepali': 'Commission',
      'Bengali': 'Commission',
      'Filipino': 'Commission',
      'Tamil': 'Commission',
    },
    'eosb_retention_bonus': {
      'English': 'Retention Bonus',
      'Arabic': 'مكافأة الاحتفاظ',
      'Hindi': 'Retention bonus',
      'Urdu': 'Retention bonus',
      'Malayalam': 'Retention Bonus',
      'Nepali': 'Retention Bonus',
      'Bengali': 'Retention bonus',
      'Filipino': 'Retention Bonus',
      'Tamil': 'Retention Bonus',
    },
    'eosb_annual_bonus_formula': {
      'English': 'Contractual bonus due at exit',
      'Arabic': 'مكافأة تعاقدية',
      'Hindi': 'Bonus formula',
      'Urdu': 'Bonus formula',
      'Malayalam': 'Contractual bonus due at exit',
      'Nepali': 'Contractual bonus due at exit',
      'Bengali': 'Bonus formula',
      'Filipino': 'Contractual bonus due at exit',
      'Tamil': 'வெளியேற்றத்தில் செலுத்த வேண்டிய ஒப்பந்த bonus',
    },
    'eosb_annual_bonus_rule': {
      'English': 'Contract / company policy',
      'Arabic': 'العقد',
      'Hindi': 'Contract',
      'Urdu': 'Contract',
      'Malayalam': 'Contract / company policy',
      'Nepali': 'Contract / company policy',
      'Bengali': 'Contract',
      'Filipino': 'Contract / company policy',
      'Tamil': 'ஒப்பந்தம் / நிறுவன கொள்கை',
    },
    'eosb_annual_bonus_example': {
      'English': 'Unpaid annual bonus entered by user',
      'Arabic': 'مثال',
      'Hindi': 'Example',
      'Urdu': 'Example',
      'Malayalam': 'Unpaid annual bonus entered by user',
      'Nepali': 'Unpaid annual bonus entered by user',
      'Bengali': 'Example',
      'Filipino': 'Unpaid annual bonus entered by user',
      'Tamil': 'பயனர் நுழைத்த செலுத்தப்படாத ஆண்டு bonus',
    },
    'eosb_commission_formula': {
      'English': 'Outstanding commission',
      'Arabic': 'عمولة',
      'Hindi': 'Commission',
      'Urdu': 'Commission',
      'Malayalam': 'Outstanding commission',
      'Nepali': 'Outstanding commission',
      'Bengali': 'Commission',
      'Filipino': 'Outstanding commission',
      'Tamil': 'நிலுவையில் உள்ள commission',
    },
    'eosb_commission_rule': {
      'English': 'Contract / sales agreement',
      'Arabic': 'العقد',
      'Hindi': 'Contract',
      'Urdu': 'Contract',
      'Malayalam': 'Contract / sales agreement',
      'Nepali': 'Contract / sales agreement',
      'Bengali': 'Contract',
      'Filipino': 'Contract / sales agreement',
      'Tamil': 'ஒப்பந்தம் / விற்பனை ஒப்பந்தம்',
    },
    'eosb_commission_example': {
      'English': 'Pending commission at exit',
      'Arabic': 'مثال',
      'Hindi': 'Example',
      'Urdu': 'Example',
      'Malayalam': 'Pending commission at exit',
      'Nepali': 'Pending commission at exit',
      'Bengali': 'Example',
      'Filipino': 'Pending commission at exit',
      'Tamil': 'வெளியேற்றத்தில் நிலுவை commission',
    },
    'eosb_retention_bonus_formula': {
      'English': 'Retention bonus payable',
      'Arabic': 'مكافأة',
      'Hindi': 'Retention',
      'Urdu': 'Retention',
      'Malayalam': 'Retention bonus payable',
      'Nepali': 'Retention bonus payable',
      'Bengali': 'Retention',
      'Filipino': 'Retention bonus payable',
      'Tamil': 'செலுத்த வேண்டிய retention bonus',
    },
    'eosb_retention_bonus_rule': {
      'English': 'Contract clause',
      'Arabic': 'بند العقد',
      'Hindi': 'Contract',
      'Urdu': 'Contract',
      'Malayalam': 'Contract clause',
      'Nepali': 'Contract clause',
      'Bengali': 'Contract',
      'Filipino': 'Contract clause',
      'Tamil': 'ஒப்பந்த பிரிவு',
    },
    'eosb_retention_bonus_example': {
      'English': 'Unpaid retention bonus',
      'Arabic': 'مثال',
      'Hindi': 'Example',
      'Urdu': 'Example',
      'Malayalam': 'Unpaid retention bonus',
      'Nepali': 'Unpaid retention bonus',
      'Bengali': 'Example',
      'Filipino': 'Unpaid retention bonus',
      'Tamil': 'செலுத்தப்படாத retention bonus',
    },
    'eosb_company_name': {
      'English': 'Company name',
      'Arabic': 'اسم الشركة',
      'Hindi': 'Company',
      'Urdu': 'Company',
      'Malayalam': 'Company name',
      'Nepali': 'Company name',
      'Bengali': 'Company',
      'Filipino': 'Company name',
      'Tamil': 'நிறுவனப் பெயர்',
    },
    'ot_title': {
      'English': 'Overtime Truth Engine',
      'Arabic': 'محرك حقيقة العمل الإضافي',
      'Hindi': 'Overtime Truth Engine',
      'Urdu': 'Overtime Truth Engine',
      'Malayalam': 'Overtime Truth Engine',
      'Nepali': 'Overtime Truth Engine',
      'Bengali': 'Overtime Truth Engine',
      'Filipino': 'Overtime Truth Engine',
      'Tamil': 'கூடுதல் நேர வேலை உண்மை இயந்திரம்',
    },
    'ot_nav_title': {
      'English': 'Overtime',
      'Arabic': 'العمل الإضافي',
      'Hindi': 'Overtime',
      'Urdu': 'Overtime',
      'Malayalam': 'Overtime',
      'Nepali': 'Overtime',
      'Bengali': 'Overtime',
      'Filipino': 'Overtime',
      'Tamil': 'Overtime',
    },
    'ot_locale_load_error': {
      'English': 'Could not load overtime calculator',
      'Arabic': 'تعذر تحميل حاسبة العمل الإضافي',
      'Hindi': 'Could not load overtime calculator',
      'Urdu': 'Could not load overtime calculator',
      'Malayalam': 'Could not load overtime calculator',
      'Nepali': 'Could not load overtime calculator',
      'Bengali': 'Could not load overtime calculator',
      'Filipino': 'Could not load overtime calculator',
      'Tamil': 'Could not load overtime calculator',
    },
    'ot_subtitle': {
      'English': 'Verify your Qatar overtime pay — built for workers',
      'Arabic': 'تحقق من أجر العمل الإضافي في قطر',
      'Hindi': 'Verify your Qatar overtime pay',
      'Urdu': 'Verify your Qatar overtime pay',
      'Malayalam': 'Verify your Qatar overtime pay — built for workers',
      'Nepali': 'Verify your Qatar overtime pay — built for workers',
      'Bengali': 'Verify your Qatar overtime pay',
      'Filipino': 'Verify your Qatar overtime pay — built for workers',
      'Tamil':
          'உங்கள் Qatar கூடுதல் நேர ஊதியத்தை சரிபார்க்கவும் — தொழிலாளர்களுக்காக',
    },
    'ot_hub_desc': {
      'English':
          'Calculate what you should be paid, compare with your employer, and spot unpaid overtime.',
      'Arabic': 'احسب ما يجب أن تتقاضاه وقارن مع صاحب العمل',
      'Hindi': 'Calculate and compare overtime pay',
      'Urdu': 'Calculate and compare overtime pay',
      'Malayalam':
          'Calculate what you should be paid, compare with your employer, and spot unpaid overtime.',
      'Nepali':
          'Calculate what you should be paid, compare with your employer, and spot unpaid overtime.',
      'Bengali': 'Calculate and compare overtime pay',
      'Filipino':
          'Calculate what you should be paid, compare with your employer, and spot unpaid overtime.',
      'Tamil':
          'எவ்வளவு செலுத்தப்பட வேண்டும் என்பதை கணக்கிடுங்கள், முதலாளியுடன் ஒப்பிடுங்கள், செலுத்தப்படாத கூடுதல் நேர வேலையைக் கண்டறியுங்கள்.',
    },
    'ot_start_calc': {
      'English': 'Calculate My Overtime',
      'Arabic': 'احسب عملي الإضافي',
      'Hindi': 'Calculate overtime',
      'Urdu': 'Calculate overtime',
      'Malayalam': 'Calculate My Overtime',
      'Nepali': 'Calculate My Overtime',
      'Bengali': 'Calculate overtime',
      'Filipino': 'Calculate My Overtime',
      'Tamil': 'என் கூடுதல் நேர வேலையை கணக்கிடு',
    },
    'ot_simple_mode': {
      'English': 'Simple mode',
      'Arabic': 'الوضع البسيط',
      'Hindi': 'Simple mode',
      'Urdu': 'Simple mode',
      'Malayalam': 'Simple mode',
      'Nepali': 'Simple mode',
      'Bengali': 'Simple mode',
      'Filipino': 'Simple mode',
      'Tamil': 'எளிய பயன்முறை',
    },
    'ot_detailed_mode': {
      'English': 'Detailed mode',
      'Arabic': 'الوضع التفصيلي',
      'Hindi': 'Detailed mode',
      'Urdu': 'Detailed mode',
      'Malayalam': 'Detailed mode',
      'Nepali': 'Detailed mode',
      'Bengali': 'Detailed mode',
      'Filipino': 'Detailed mode',
      'Tamil': 'விரிவான பயன்முறை',
    },
    'ot_basic_salary': {
      'English': 'Basic salary (QAR/month)',
      'Arabic': 'الراتب الأساسي',
      'Hindi': 'Basic salary',
      'Urdu': 'Basic salary',
      'Malayalam': 'Basic salary (QAR/month)',
      'Nepali': 'Basic salary (QAR/month)',
      'Bengali': 'Basic salary',
      'Filipino': 'Basic salary (QAR/month)',
      'Tamil': 'அடிப்படை சம்பளம் (QAR/மாதம்)',
    },
    'ot_period': {
      'English': 'Pay period',
      'Arabic': 'فترة الدفع',
      'Hindi': 'Pay period',
      'Urdu': 'Pay period',
      'Malayalam': 'Pay period',
      'Nepali': 'Pay period',
      'Bengali': 'Pay period',
      'Filipino': 'Pay period',
      'Tamil': 'ஊதிய காலம்',
    },
    'ot_period_start': {
      'English': 'Period start',
      'Arabic': 'البداية',
      'Hindi': 'Start',
      'Urdu': 'Start',
      'Malayalam': 'Period start',
      'Nepali': 'Period start',
      'Bengali': 'Start',
      'Filipino': 'Period start',
      'Tamil': 'காலம் தொடக்கம்',
    },
    'ot_period_end': {
      'English': 'Period end',
      'Arabic': 'النهاية',
      'Hindi': 'End',
      'Urdu': 'End',
      'Malayalam': 'Period end',
      'Nepali': 'Period end',
      'Bengali': 'End',
      'Filipino': 'Period end',
      'Tamil': 'காலம் முடிவு',
    },
    'ot_total_hours': {
      'English': 'Total hours worked in period',
      'Arabic': 'إجمالي ساعات العمل',
      'Hindi': 'Total hours worked',
      'Urdu': 'Total hours worked',
      'Malayalam': 'Total hours worked in period',
      'Nepali': 'Total hours worked in period',
      'Bengali': 'Total hours worked',
      'Filipino': 'Total hours worked in period',
      'Tamil': 'காலத்தில் வேலை செய்த மொத்த மணி',
    },
    'ot_weekday_hours': {
      'English': 'Weekday overtime hours',
      'Arabic': 'ساعات إضافية أيام العمل',
      'Hindi': 'Weekday OT hours',
      'Urdu': 'Weekday OT hours',
      'Malayalam': 'Weekday overtime hours',
      'Nepali': 'Weekday overtime hours',
      'Bengali': 'Weekday OT hours',
      'Filipino': 'Weekday overtime hours',
      'Tamil': 'வார நாள் கூடுதல் நேர மணி',
    },
    'ot_restday_hours': {
      'English': 'Rest day / Friday hours',
      'Arabic': 'ساعات يوم الراحة / الجمعة',
      'Hindi': 'Rest day hours',
      'Urdu': 'Rest day hours',
      'Malayalam': 'Rest day / Friday hours',
      'Nepali': 'Rest day / Friday hours',
      'Bengali': 'Rest day hours',
      'Filipino': 'Rest day / Friday hours',
      'Tamil': 'ஓய்வு நாள் / வெள்ளி மணி',
    },
    'ot_rounding_title': {
      'English': 'Rounding pattern check',
      'Arabic': 'فحص نمط التقريب',
      'Hindi': 'Rounding pattern check',
      'Urdu': 'Rounding pattern check',
      'Malayalam': 'Rounding pattern check',
      'Nepali': 'Rounding pattern check',
      'Bengali': 'Rounding pattern check',
      'Filipino': 'Rounding pattern check',
      'Tamil': 'Rounding pattern check',
    },
    'ot_rounding_subtitle': {
      'English':
          'Compare your logged shift times with employer records to spot consistent minute-level differences.',
      'Arabic':
          'قارن أوقات دوامك مع سجلات صاحب العمل لاكتشاف فروقات دقيقة متكررة.',
      'Hindi':
          'Compare your shift times with employer records for minute-level patterns.',
      'Urdu':
          'Compare your shift times with employer records for minute-level patterns.',
      'Malayalam':
          'Compare your logged shift times with employer records to spot consistent minute-level differences.',
      'Nepali':
          'Compare your logged shift times with employer records to spot consistent minute-level differences.',
      'Bengali':
          'Compare your shift times with employer records for minute-level patterns.',
      'Filipino':
          'Compare your logged shift times with employer records to spot consistent minute-level differences.',
      'Tamil':
          'Compare your logged shift times with employer records to spot consistent minute-level differences.',
    },
    'ot_rounding_need_more': {
      'English': 'More shift pairs needed',
      'Arabic': 'مطلوب المزيد من أزواج الورديات',
      'Hindi': 'More shift pairs needed',
      'Urdu': 'More shift pairs needed',
      'Malayalam': 'More shift pairs needed',
      'Nepali': 'More shift pairs needed',
      'Bengali': 'More shift pairs needed',
      'Filipino': 'More shift pairs needed',
      'Tamil': 'More shift pairs needed',
    },
    'ot_rounding_progress': {
      'English': '{current} of {required} dual-sided shifts recorded',
      'Arabic': '{current} من {required} وردية مسجلة من الطرفين',
      'Hindi': '{current} of {required} dual-sided shifts recorded',
      'Urdu': '{current} of {required} dual-sided shifts recorded',
      'Malayalam': '{current} of {required} dual-sided shifts recorded',
      'Nepali': '{current} of {required} dual-sided shifts recorded',
      'Bengali': '{current} of {required} dual-sided shifts recorded',
      'Filipino': '{current} of {required} dual-sided shifts recorded',
      'Tamil': '{current} of {required} dual-sided shifts recorded',
    },
    'ot_rounding_need_more_hint': {
      'English':
          'Open the calendar, edit days, and enter both your times and employer times for each shift.',
      'Arabic':
          'افتح التقويم وعدّل الأيام وأدخل أوقاتك وأوقات صاحب العمل لكل وردية.',
      'Hindi':
          'Open the calendar and enter both your times and employer times per shift.',
      'Urdu':
          'Open the calendar and enter both your times and employer times per shift.',
      'Malayalam':
          'Open the calendar, edit days, and enter both your times and employer times for each shift.',
      'Nepali':
          'Open the calendar, edit days, and enter both your times and employer times for each shift.',
      'Bengali':
          'Open the calendar and enter both your times and employer times per shift.',
      'Filipino':
          'Open the calendar, edit days, and enter both your times and employer times for each shift.',
      'Tamil':
          'Open the calendar, edit days, and enter both your times and employer times for each shift.',
    },
    'ot_rounding_summary_heading': {
      'English': 'Pattern summary',
      'Arabic': 'ملخص النمط',
      'Hindi': 'Pattern summary',
      'Urdu': 'Pattern summary',
      'Malayalam': 'Pattern summary',
      'Nepali': 'Pattern summary',
      'Bengali': 'Pattern summary',
      'Filipino': 'Pattern summary',
      'Tamil': 'Pattern summary',
    },
    'ot_rounding_pattern_clock_in': {
      'English':
          'On {clockInCount} of {total} shifts, employer clock-in was later than yours by about {avgIn} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Arabic':
          'في {clockInCount} من {total} وردية، كان تسجيل الدخول لدى صاحب العمل متأخراً بحوالي {avgIn} دقيقة. متوسط الخسارة: {avgTotal} دقيقة.',
      'Hindi':
          'On {clockInCount} of {total} shifts, employer clock-in was later by ~{avgIn} min. Avg loss: {avgTotal} min.',
      'Urdu':
          'On {clockInCount} of {total} shifts, employer clock-in was later by ~{avgIn} min. Avg loss: {avgTotal} min.',
      'Malayalam':
          'On {clockInCount} of {total} shifts, employer clock-in was later than yours by about {avgIn} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Nepali':
          'On {clockInCount} of {total} shifts, employer clock-in was later than yours by about {avgIn} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Bengali':
          'On {clockInCount} of {total} shifts, employer clock-in was later by ~{avgIn} min. Avg loss: {avgTotal} min.',
      'Filipino':
          'On {clockInCount} of {total} shifts, employer clock-in was later than yours by about {avgIn} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Tamil':
          'On {clockInCount} of {total} shifts, employer clock-in was later than yours by about {avgIn} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
    },
    'ot_rounding_pattern_clock_out': {
      'English':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier than yours by about {avgOut} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Arabic':
          'في {clockOutCount} من {total} وردية، كان تسجيل الخروج لدى صاحب العمل أبكر بحوالي {avgOut} دقيقة. متوسط الخسارة: {avgTotal} دقيقة.',
      'Hindi':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier by ~{avgOut} min. Avg loss: {avgTotal} min.',
      'Urdu':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier by ~{avgOut} min. Avg loss: {avgTotal} min.',
      'Malayalam':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier than yours by about {avgOut} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Nepali':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier than yours by about {avgOut} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Bengali':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier by ~{avgOut} min. Avg loss: {avgTotal} min.',
      'Filipino':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier than yours by about {avgOut} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
      'Tamil':
          'On {clockOutCount} of {total} shifts, employer clock-out was earlier than yours by about {avgOut} minutes on average. Total average loss per affected shift: {avgTotal} minutes.',
    },
    'ot_rounding_pattern_neutral': {
      'English':
          'Across {total} dual-sided shifts, no strong minute-level rounding pattern was detected.',
      'Arabic': 'عبر {total} وردية، لم يُكتشف نمط تقريب دقائق واضح.',
      'Hindi': 'Across {total} shifts, no strong rounding pattern detected.',
      'Urdu': 'Across {total} shifts, no strong rounding pattern detected.',
      'Malayalam':
          'Across {total} dual-sided shifts, no strong minute-level rounding pattern was detected.',
      'Nepali':
          'Across {total} dual-sided shifts, no strong minute-level rounding pattern was detected.',
      'Bengali': 'Across {total} shifts, no strong rounding pattern detected.',
      'Filipino':
          'Across {total} dual-sided shifts, no strong minute-level rounding pattern was detected.',
      'Tamil':
          'Across {total} dual-sided shifts, no strong minute-level rounding pattern was detected.',
    },
    'ot_rounding_no_accusation': {
      'English':
          'This is a pattern summary only — not proof of wrongdoing. Keep your own records.',
      'Arabic': 'هذا ملخص للنمط فقط — وليس دليلاً على مخالفة. احتفظ بسجلاتك.',
      'Hindi': 'Pattern summary only — not proof. Keep your records.',
      'Urdu': 'Pattern summary only — not proof. Keep your records.',
      'Malayalam':
          'This is a pattern summary only — not proof of wrongdoing. Keep your own records.',
      'Nepali':
          'This is a pattern summary only — not proof of wrongdoing. Keep your own records.',
      'Bengali': 'Pattern summary only — not proof. Keep your records.',
      'Filipino':
          'This is a pattern summary only — not proof of wrongdoing. Keep your own records.',
      'Tamil':
          'This is a pattern summary only — not proof of wrongdoing. Keep your own records.',
    },
    'ot_rounding_qar_estimate': {
      'English': 'Estimated value of lost minutes: {amount} {currency}',
      'Arabic': 'القيمة التقديرية للدقائق المفقودة: {amount} {currency}',
      'Hindi': 'Estimated value of lost minutes: {amount} {currency}',
      'Urdu': 'Estimated value of lost minutes: {amount} {currency}',
      'Malayalam': 'Estimated value of lost minutes: {amount} {currency}',
      'Nepali': 'Estimated value of lost minutes: {amount} {currency}',
      'Bengali': 'Estimated value of lost minutes: {amount} {currency}',
      'Filipino': 'Estimated value of lost minutes: {amount} {currency}',
      'Tamil': 'Estimated value of lost minutes: {amount} {currency}',
    },
    'ot_rounding_explain': {
      'English': 'Explain in plain language',
      'Arabic': 'اشرح بلغة بسيطة',
      'Hindi': 'Explain in plain language',
      'Urdu': 'Explain in plain language',
      'Malayalam': 'Explain in plain language',
      'Nepali': 'Explain in plain language',
      'Bengali': 'Explain in plain language',
      'Filipino': 'Explain in plain language',
      'Tamil': 'Explain in plain language',
    },
    'ot_rounding_add_timeline': {
      'English': 'Add summary to case timeline',
      'Arabic': 'أضف الملخص إلى الجدول الزمني',
      'Hindi': 'Add summary to case timeline',
      'Urdu': 'Add summary to case timeline',
      'Malayalam': 'Add summary to case timeline',
      'Nepali': 'Add summary to case timeline',
      'Bengali': 'Add summary to case timeline',
      'Filipino': 'Add summary to case timeline',
      'Tamil': 'Add summary to case timeline',
    },
    'ot_rounding_timeline_title': {
      'English': 'Overtime rounding pattern',
      'Arabic': 'نمط تقريب العمل الإضافي',
      'Hindi': 'Overtime rounding pattern',
      'Urdu': 'Overtime rounding pattern',
      'Malayalam': 'Overtime rounding pattern',
      'Nepali': 'Overtime rounding pattern',
      'Bengali': 'Overtime rounding pattern',
      'Filipino': 'Overtime rounding pattern',
      'Tamil': 'Overtime rounding pattern',
    },
    'ot_rounding_timeline_note': {
      'English':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost per affected shift.',
      'Arabic':
          'تسجيل دخول متأخر في {clockIn} من {total} وردية؛ متوسط {avgMin} دقيقة خسارة.',
      'Hindi':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost.',
      'Urdu':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost.',
      'Malayalam':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost per affected shift.',
      'Nepali':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost per affected shift.',
      'Bengali':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost.',
      'Filipino':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost per affected shift.',
      'Tamil':
          'Clock-in later on {clockIn} of {total} shifts; avg {avgMin} min lost per affected shift.',
    },
    'ot_rounding_timeline_saved': {
      'English': 'Added to case timeline',
      'Arabic': 'تمت الإضافة إلى الجدول الزمني',
      'Hindi': 'Added to case timeline',
      'Urdu': 'Added to case timeline',
      'Malayalam': 'Added to case timeline',
      'Nepali': 'Added to case timeline',
      'Bengali': 'Added to case timeline',
      'Filipino': 'Added to case timeline',
      'Tamil': 'Added to case timeline',
    },
    'ot_rounding_comparison_link': {
      'English':
          'You also have an hours or payment gap — review employer comparison alongside this pattern.',
      'Arabic':
          'لديك أيضاً فجوة في الساعات أو الدفع — راجع الم comparison مع هذا النمط.',
      'Hindi':
          'You also have a payment/hours gap — review employer comparison.',
      'Urdu': 'You also have a payment/hours gap — review employer comparison.',
      'Malayalam':
          'You also have an hours or payment gap — review employer comparison alongside this pattern.',
      'Nepali':
          'You also have an hours or payment gap — review employer comparison alongside this pattern.',
      'Bengali':
          'You also have a payment/hours gap — review employer comparison.',
      'Filipino':
          'You also have an hours or payment gap — review employer comparison alongside this pattern.',
      'Tamil':
          'You also have an hours or payment gap — review employer comparison alongside this pattern.',
    },
    'ot_rounding_hub_button': {
      'English': 'Rounding pattern check',
      'Arabic': 'فحص نمط التقريب',
      'Hindi': 'Rounding pattern check',
      'Urdu': 'Rounding pattern check',
      'Malayalam': 'Rounding pattern check',
      'Nepali': 'Rounding pattern check',
      'Bengali': 'Rounding pattern check',
      'Filipino': 'Rounding pattern check',
      'Tamil': 'Rounding pattern check',
    },
    'ot_rounding_check_link': {
      'English': 'Check for minute-level rounding patterns',
      'Arabic': 'تحقق من أنماط تقريب الدقائق',
      'Hindi': 'Check for minute-level rounding patterns',
      'Urdu': 'Check for minute-level rounding patterns',
      'Malayalam': 'Check for minute-level rounding patterns',
      'Nepali': 'Check for minute-level rounding patterns',
      'Bengali': 'Check for minute-level rounding patterns',
      'Filipino': 'Check for minute-level rounding patterns',
      'Tamil': 'Check for minute-level rounding patterns',
    },
    'ot_shift_times_section': {
      'English': 'Shift clock times (for rounding check)',
      'Arabic': 'أوقات الدوام (لفحص التقريب)',
      'Hindi': 'Shift clock times (for rounding check)',
      'Urdu': 'Shift clock times (for rounding check)',
      'Malayalam': 'Shift clock times (for rounding check)',
      'Nepali': 'Shift clock times (for rounding check)',
      'Bengali': 'Shift clock times (for rounding check)',
      'Filipino': 'Shift clock times (for rounding check)',
      'Tamil': 'Shift clock times (for rounding check)',
    },
    'ot_shift_user_start': {
      'English': 'Your clock-in',
      'Arabic': 'تسجيل دخولك',
      'Hindi': 'Your clock-in',
      'Urdu': 'Your clock-in',
      'Malayalam': 'Your clock-in',
      'Nepali': 'Your clock-in',
      'Bengali': 'Your clock-in',
      'Filipino': 'Your clock-in',
      'Tamil': 'Your clock-in',
    },
    'ot_shift_user_end': {
      'English': 'Your clock-out',
      'Arabic': 'تسجيل خروجك',
      'Hindi': 'Your clock-out',
      'Urdu': 'Your clock-out',
      'Malayalam': 'Your clock-out',
      'Nepali': 'Your clock-out',
      'Bengali': 'Your clock-out',
      'Filipino': 'Your clock-out',
      'Tamil': 'Your clock-out',
    },
    'ot_shift_employer_start': {
      'English': 'Employer clock-in',
      'Arabic': 'تسجيل دخول صاحب العمل',
      'Hindi': 'Employer clock-in',
      'Urdu': 'Employer clock-in',
      'Malayalam': 'Employer clock-in',
      'Nepali': 'Employer clock-in',
      'Bengali': 'Employer clock-in',
      'Filipino': 'Employer clock-in',
      'Tamil': 'Employer clock-in',
    },
    'ot_shift_employer_end': {
      'English': 'Employer clock-out',
      'Arabic': 'تسجيل خروج صاحب العمل',
      'Hindi': 'Employer clock-out',
      'Urdu': 'Employer clock-out',
      'Malayalam': 'Employer clock-out',
      'Nepali': 'Employer clock-out',
      'Bengali': 'Employer clock-out',
      'Filipino': 'Employer clock-out',
      'Tamil': 'Employer clock-out',
    },
    'ot_holiday_hours': {
      'English': 'Public holiday hours',
      'Arabic': 'ساعات العطل الرسمية',
      'Hindi': 'Holiday hours',
      'Urdu': 'Holiday hours',
      'Malayalam': 'Public holiday hours',
      'Nepali': 'Public holiday hours',
      'Bengali': 'Holiday hours',
      'Filipino': 'Public holiday hours',
      'Tamil': 'பொது விடுமுறை மணி',
    },
    'ot_employer_paid': {
      'English': 'Employer paid (on payslip)',
      'Arabic': 'ما دفعه صاحب العمل',
      'Hindi': 'Employer paid',
      'Urdu': 'Employer paid',
      'Malayalam': 'Employer paid (on payslip)',
      'Nepali': 'Employer paid (on payslip)',
      'Bengali': 'Employer paid',
      'Filipino': 'Employer paid (on payslip)',
      'Tamil': 'முதலாளி செலுத்தியது (payslip-ல்)',
    },
    'ot_employer_hours': {
      'English': 'Overtime hours on payslip',
      'Arabic': 'ساعات إضافية في كشف الراتب',
      'Hindi': 'OT hours on payslip',
      'Urdu': 'OT hours on payslip',
      'Malayalam': 'Overtime hours on payslip',
      'Nepali': 'Overtime hours on payslip',
      'Bengali': 'OT hours on payslip',
      'Filipino': 'Overtime hours on payslip',
      'Tamil': 'Payslip-ல் கூடுதல் நேர மணி',
    },
    'ot_ramadan': {
      'English': 'Ramadan period (6h standard day)',
      'Arabic': 'رمضان (6 ساعات)',
      'Hindi': 'Ramadan period',
      'Urdu': 'Ramadan period',
      'Malayalam': 'Ramadan period (6h standard day)',
      'Nepali': 'Ramadan period (6h standard day)',
      'Bengali': 'Ramadan period',
      'Filipino': 'Ramadan period (6h standard day)',
      'Tamil': 'Ramadan காலம் (6h standard day)',
    },
    'ot_pay_period': {
      'English': 'Pay period',
      'Arabic': 'فترة الراتب',
      'Hindi': 'Pay period',
      'Urdu': 'Pay period',
      'Malayalam': 'Pay period',
      'Nepali': 'Pay period',
      'Bengali': 'Pay period',
      'Filipino': 'Pay period',
      'Tamil': 'ஊதிய காலம்',
    },
    'ot_select_month': {
      'English': 'Select month',
      'Arabic': 'اختر الشهر',
      'Hindi': 'Select month',
      'Urdu': 'Select month',
      'Malayalam': 'Select month',
      'Nepali': 'Select month',
      'Bengali': 'Select month',
      'Filipino': 'Select month',
      'Tamil': 'மாதத்தைத் தேர்ந்தெடு',
    },
    'ot_apply_month': {
      'English': 'Apply',
      'Arabic': 'تطبيق',
      'Hindi': 'Apply',
      'Urdu': 'Apply',
      'Malayalam': 'Apply',
      'Nepali': 'Apply',
      'Bengali': 'Apply',
      'Filipino': 'Apply',
      'Tamil': 'பயன்படுத்து',
    },
    'ot_working_days': {
      'English': 'Working days per week',
      'Arabic': 'أيام العمل في الأسبوع',
      'Hindi': 'Working days/week',
      'Urdu': 'Working days/week',
      'Malayalam': 'Working days per week',
      'Nepali': 'Working days per week',
      'Bengali': 'Working days/week',
      'Filipino': 'Working days per week',
      'Tamil': 'வாரத்தில் வேலை நாட்கள்',
    },
    'ot_hourly_rate': {
      'English': 'Hourly rate (basic ÷ 30 ÷ 8)',
      'Arabic': 'أجر الساعة',
      'Hindi': 'Hourly rate',
      'Urdu': 'Hourly rate',
      'Malayalam': 'Hourly rate (basic ÷ 30 ÷ 8)',
      'Nepali': 'Hourly rate (basic ÷ 30 ÷ 8)',
      'Bengali': 'Hourly rate',
      'Filipino': 'Hourly rate (basic ÷ 30 ÷ 8)',
      'Tamil': 'மணி விகிதம் (அடிப்படை ÷ 30 ÷ 8)',
    },
    'ot_legal_owed': {
      'English': 'Legal overtime owed',
      'Arabic': 'العمل الإضافي المستحق قانونياً',
      'Hindi': 'Legal OT owed',
      'Urdu': 'Legal OT owed',
      'Malayalam': 'Legal overtime owed',
      'Nepali': 'Legal overtime owed',
      'Bengali': 'Legal OT owed',
      'Filipino': 'Legal overtime owed',
      'Tamil': 'சட்டப்படி கூடுதல் நேர உரிமை',
    },
    'ot_unpaid_gap': {
      'English': 'Possible unpaid overtime',
      'Arabic': 'عمل إضافي possibly غير مدفوع',
      'Hindi': 'Unpaid gap',
      'Urdu': 'Unpaid gap',
      'Malayalam': 'Possible unpaid overtime',
      'Nepali': 'Possible unpaid overtime',
      'Bengali': 'Unpaid gap',
      'Filipino': 'Possible unpaid overtime',
      'Tamil': 'சாத்தியமான செலுத்தப்படாத கூடுதல் நேர வேலை',
    },
    'ot_employer_comparison': {
      'English': 'Employer payment comparison',
      'Arabic': 'م comparison الدفع',
      'Hindi': 'Payment comparison',
      'Urdu': 'Payment comparison',
      'Malayalam': 'Employer payment comparison',
      'Nepali': 'Employer payment comparison',
      'Bengali': 'Payment comparison',
      'Filipino': 'Employer payment comparison',
      'Tamil': 'முதலாளி கட்டண ஒப்பீடு',
    },
    'ot_payment_fair': {
      'English': 'Payment appears to match estimate',
      'Arabic': 'الدفع يطابق التقدير',
      'Hindi': 'Payment looks fair',
      'Urdu': 'Payment looks fair',
      'Malayalam': 'Payment appears to match estimate',
      'Nepali': 'Payment appears to match estimate',
      'Bengali': 'Payment looks fair',
      'Filipino': 'Payment appears to match estimate',
      'Tamil': 'கட்டணம் மதிப்பீட்டுடன் பொருந்துவது போல் தோன்றுகிறது',
    },
    'ot_payment_short': {
      'English': 'Employer may be {percent}% short on overtime',
      'Arabic': 'قد يكون النقص {percent}%',
      'Hindi': '{percent}% short',
      'Urdu': '{percent}% short',
      'Malayalam': 'Employer may be {percent}% short on overtime',
      'Nepali': 'Employer may be {percent}% short on overtime',
      'Bengali': '{percent}% short',
      'Filipino': 'Employer may be {percent}% short on overtime',
      'Tamil': 'முதலாளி கூடுதல் நேர வேலையில் {percent}% குறைவாக இருக்கலாம்',
    },
    'ot_hours_gap': {
      'English': '{hours}h more overtime worked than payslip shows',
      'Arabic': '{hours} ساعة أكثر من كشف الراتب',
      'Hindi': '{hours}h gap on payslip',
      'Urdu': '{hours}h gap on payslip',
      'Malayalam': '{hours}h more overtime worked than payslip shows',
      'Nepali': '{hours}h more overtime worked than payslip shows',
      'Bengali': '{hours}h gap on payslip',
      'Filipino': '{hours}h more overtime worked than payslip shows',
      'Tamil': 'Payslip-ல் காட்டுவதை விட {hours}h அதிக கூடுதல் நேர வேலை',
    },
    'ot_confidence': {
      'English': 'Confidence score',
      'Arabic': 'درجة الثقة',
      'Hindi': 'Confidence',
      'Urdu': 'Confidence',
      'Malayalam': 'Confidence score',
      'Nepali': 'Confidence score',
      'Bengali': 'Confidence',
      'Filipino': 'Confidence score',
      'Tamil': 'நம்பிக்கை மதிப்பெண்',
    },
    'ot_breakdown': {
      'English': 'Overtime breakdown',
      'Arabic': 'تفصيل العمل الإضافي',
      'Hindi': 'Breakdown',
      'Urdu': 'Breakdown',
      'Malayalam': 'Overtime breakdown',
      'Nepali': 'Overtime breakdown',
      'Bengali': 'Breakdown',
      'Filipino': 'Overtime breakdown',
      'Tamil': 'கூடுதல் நேர பிரிவினை',
    },
    'ot_alerts': {
      'English': 'Alerts & flags',
      'Arabic': 'تنبيهات',
      'Hindi': 'Alerts',
      'Urdu': 'Alerts',
      'Malayalam': 'Alerts & flags',
      'Nepali': 'Alerts & flags',
      'Bengali': 'Alerts',
      'Filipino': 'Alerts & flags',
      'Tamil': 'எச்சரிக்கைகள் & குறிகள்',
    },
    'ot_apply_eosb': {
      'English': 'Add to EOSB calculation',
      'Arabic': 'أضف إلى حساب نهاية الخدمة',
      'Hindi': 'Add to EOSB',
      'Urdu': 'Add to EOSB',
      'Malayalam': 'Add to EOSB calculation',
      'Nepali': 'Add to EOSB calculation',
      'Bengali': 'Add to EOSB',
      'Filipino': 'Add to EOSB calculation',
      'Tamil': 'EOSB கணக்கீட்டில் சேர்',
    },
    'ot_apply_eosb_done': {
      'English': 'Unpaid overtime added to EOSB',
      'Arabic': 'تمت الإضافة إلى EOSB',
      'Hindi': 'Added to EOSB',
      'Urdu': 'Added to EOSB',
      'Malayalam': 'Unpaid overtime added to EOSB',
      'Nepali': 'Unpaid overtime added to EOSB',
      'Bengali': 'Added to EOSB',
      'Filipino': 'Unpaid overtime added to EOSB',
      'Tamil': 'செலுத்தப்படாத கூடுதல் நேர வேலை EOSB-ல் சேர்க்கப்பட்டது',
    },
    'ot_share_report': {
      'English': 'Share PDF report',
      'Arabic': 'مشاركة التقرير',
      'Hindi': 'Share report',
      'Urdu': 'Share report',
      'Malayalam': 'Share PDF report',
      'Nepali': 'Share PDF report',
      'Bengali': 'Share report',
      'Filipino': 'Share PDF report',
      'Tamil': 'PDF அறிக்கையைப் பகிர்',
    },
    'ot_ai_explain': {
      'English': 'AI explain my overtime',
      'Arabic': 'شرح الذكاء الاصطناعي',
      'Hindi': 'AI explain',
      'Urdu': 'AI explain',
      'Malayalam': 'AI explain my overtime',
      'Nepali': 'AI explain my overtime',
      'Bengali': 'AI explain',
      'Filipino': 'AI explain my overtime',
      'Tamil': 'AI என் கூடுதல் நேர வேலையை விளக்கு',
    },
    'ot_cat_weekday': {
      'English': 'Weekday overtime',
      'Arabic': 'عمل إضافي أيام العمل',
      'Hindi': 'Weekday OT',
      'Urdu': 'Weekday OT',
      'Malayalam': 'Weekday overtime',
      'Nepali': 'Weekday overtime',
      'Bengali': 'Weekday OT',
      'Filipino': 'Weekday overtime',
      'Tamil': 'வார நாள் கூடுதல் நேர வேலை',
    },
    'ot_cat_restday': {
      'English': 'Rest day work',
      'Arabic': 'عمل يوم الراحة',
      'Hindi': 'Rest day',
      'Urdu': 'Rest day',
      'Malayalam': 'Rest day work',
      'Nepali': 'Rest day work',
      'Bengali': 'Rest day',
      'Filipino': 'Rest day work',
      'Tamil': 'ஓய்வு நாள் வேலை',
    },
    'ot_cat_holiday': {
      'English': 'Public holiday work',
      'Arabic': 'عمل العطل الرسمية',
      'Hindi': 'Holiday work',
      'Urdu': 'Holiday work',
      'Malayalam': 'Public holiday work',
      'Nepali': 'Public holiday work',
      'Bengali': 'Holiday work',
      'Filipino': 'Public holiday work',
      'Tamil': 'பொது விடுமுறை வேலை',
    },
    'ot_rule_weekday': {
      'English': 'Art. 74 — minimum 125% of hourly basic',
      'Arabic': 'المادة 74 — 125% كحد أدنى',
      'Hindi': 'Art. 74 — 125%',
      'Urdu': 'Art. 74 — 125%',
      'Malayalam': 'Art. 74 — minimum 125% of hourly basic',
      'Nepali': 'Art. 74 — minimum 125% of hourly basic',
      'Bengali': 'Art. 74 — 125%',
      'Filipino': 'Art. 74 — minimum 125% of hourly basic',
      'Tamil': 'பிரிவு 74 — அடிப்படை மணி விகிதத்தின் குறைந்தது 125%',
    },
    'ot_rule_restday': {
      'English': 'Rest day / Friday — typically 150% (verify contract)',
      'Arabic': 'يوم الراحة — عادة 150%',
      'Hindi': 'Rest day 150%',
      'Urdu': 'Rest day 150%',
      'Malayalam': 'Rest day / Friday — typically 150% (verify contract)',
      'Nepali': 'Rest day / Friday — typically 150% (verify contract)',
      'Bengali': 'Rest day 150%',
      'Filipino': 'Rest day / Friday — typically 150% (verify contract)',
      'Tamil': 'ஓய்வு நாள் / வெள்ளி — பொதுவாக 150% (ஒப்பந்தம் சரிபார்க்கவும்)',
    },
    'ot_rule_holiday': {
      'English': 'Public holiday — minimum 150% (contract may be higher)',
      'Arabic': 'عطلة رسمية — 150% كحد أدنى',
      'Hindi': 'Holiday 150%',
      'Urdu': 'Holiday 150%',
      'Malayalam': 'Public holiday — minimum 150% (contract may be higher)',
      'Nepali': 'Public holiday — minimum 150% (contract may be higher)',
      'Bengali': 'Holiday 150%',
      'Filipino': 'Public holiday — minimum 150% (contract may be higher)',
      'Tamil': 'பொது விடுமுறை — குறைந்தது 150% (ஒப்பந்தம் அதிகமாக இருக்கலாம்)',
    },
    'ot_formula_weekday': {
      'English': 'hours × hourly × 1.25',
      'Arabic': 'ساعات × أجر × 1.25',
      'Hindi': 'hours × rate × 1.25',
      'Urdu': 'hours × rate × 1.25',
      'Malayalam': 'hours × hourly × 1.25',
      'Nepali': 'hours × hourly × 1.25',
      'Bengali': 'hours × rate × 1.25',
      'Filipino': 'hours × hourly × 1.25',
      'Tamil': 'மணி × மணி விகிதம் × 1.25',
    },
    'ot_formula_restday': {
      'English': 'hours × hourly × 1.50',
      'Arabic': 'ساعات × أجر × 1.50',
      'Hindi': 'hours × rate × 1.50',
      'Urdu': 'hours × rate × 1.50',
      'Malayalam': 'hours × hourly × 1.50',
      'Nepali': 'hours × hourly × 1.50',
      'Bengali': 'hours × rate × 1.50',
      'Filipino': 'hours × hourly × 1.50',
      'Tamil': 'மணி × மணி விகிதம் × 1.50',
    },
    'ot_formula_holiday': {
      'English': 'hours × hourly × 1.50',
      'Arabic': 'ساعات × أجر × 1.50',
      'Hindi': 'hours × rate × 1.50',
      'Urdu': 'hours × rate × 1.50',
      'Malayalam': 'hours × hourly × 1.50',
      'Nepali': 'hours × hourly × 1.50',
      'Bengali': 'hours × rate × 1.50',
      'Filipino': 'hours × hourly × 1.50',
      'Tamil': 'மணி × மணி விகிதம் × 1.50',
    },
    'ot_alert_unpaid': {
      'English': 'Possible unpaid overtime detected',
      'Arabic': 'عمل إضافي possibly غير مدفوع',
      'Hindi': 'Unpaid OT detected',
      'Urdu': 'Unpaid OT detected',
      'Malayalam': 'Possible unpaid overtime detected',
      'Nepali': 'Possible unpaid overtime detected',
      'Bengali': 'Unpaid OT detected',
      'Filipino': 'Possible unpaid overtime detected',
      'Tamil': 'சாத்தியமான செலுத்தப்படாத கூடுதல் நேர வேலை கண்டறியப்பட்டது',
    },
    'ot_alert_unpaid_body': {
      'English':
          'Your employer paid less than the legal estimate. Save this report and request a payslip breakdown.',
      'Arabic': 'دفع أقل من التقدير القانوني. احفظ التقرير واطلب تفصيل الراتب.',
      'Hindi': 'Employer paid less than estimate.',
      'Urdu': 'Employer paid less than estimate.',
      'Malayalam':
          'Your employer paid less than the legal estimate. Save this report and request a payslip breakdown.',
      'Nepali':
          'Your employer paid less than the legal estimate. Save this report and request a payslip breakdown.',
      'Bengali': 'Employer paid less than estimate.',
      'Filipino':
          'Your employer paid less than the legal estimate. Save this report and request a payslip breakdown.',
      'Tamil':
          'உங்கள் முதலாளி சட்ட மதிப்பீட்டை விட குறைவாக செலுத்தியுள்ளார். இந்த அறிக்கையை சேமித்து payslip பிரிவினையை கோருங்கள்.',
    },
    'ot_alert_weekly_cap': {
      'English': 'Weekly hours exceed 48h limit',
      'Arabic': 'تجاوز 48 ساعة أسبوعياً',
      'Hindi': 'Over 48h/week',
      'Urdu': 'Over 48h/week',
      'Malayalam': 'Weekly hours exceed 48h limit',
      'Nepali': 'Weekly hours exceed 48h limit',
      'Bengali': 'Over 48h/week',
      'Filipino': 'Weekly hours exceed 48h limit',
      'Tamil': 'வார மணி 48h வரம்பை மீறுகிறது',
    },
    'ot_alert_weekly_cap_body': {
      'English':
          'Qatar law limits standard work to 48 hours/week. Extra hours should be compensated as overtime.',
      'Arabic': 'القانون يحدد 48 ساعة. الساعات الإضافية يجب compensating.',
      'Hindi': '48h/week limit per Qatar law.',
      'Urdu': '48h/week limit per Qatar law.',
      'Malayalam':
          'Qatar law limits standard work to 48 hours/week. Extra hours should be compensated as overtime.',
      'Nepali':
          'Qatar law limits standard work to 48 hours/week. Extra hours should be compensated as overtime.',
      'Bengali': '48h/week limit per Qatar law.',
      'Filipino':
          'Qatar law limits standard work to 48 hours/week. Extra hours should be compensated as overtime.',
      'Tamil':
          'Qatar சட்டம் standard வேலையை 48 மணி/வாரமாக வரம்பிடுகிறது. கூடுதல் மணி கூடுதல் நேர வேலையாக compensating செய்யப்பட வேண்டும்.',
    },
    'ot_alert_hours_mismatch': {
      'English': 'Payslip hours do not match your records',
      'Arabic': 'ساعات كشف الراتب لا تطابق سجلاتك',
      'Hindi': 'Hours mismatch',
      'Urdu': 'Hours mismatch',
      'Malayalam': 'Payslip hours do not match your records',
      'Nepali': 'Payslip hours do not match your records',
      'Bengali': 'Hours mismatch',
      'Filipino': 'Payslip hours do not match your records',
      'Tamil': 'Payslip மணி உங்கள் பதிவுகளுடன் பொருந்தவில்லை',
    },
    'ot_alert_hours_mismatch_body': {
      'English':
          'Your worked hours exceed what the employer recorded on the payslip.',
      'Arabic': 'ساعات عملك أكثر من الم recorded.',
      'Hindi': 'Worked hours exceed payslip.',
      'Urdu': 'Worked hours exceed payslip.',
      'Malayalam':
          'Your worked hours exceed what the employer recorded on the payslip.',
      'Nepali':
          'Your worked hours exceed what the employer recorded on the payslip.',
      'Bengali': 'Worked hours exceed payslip.',
      'Filipino':
          'Your worked hours exceed what the employer recorded on the payslip.',
      'Tamil': 'உங்கள் வேலை மணி முதலாளி payslip-ல் பதிவு செய்ததை விட அதிகம்.',
    },
    'ot_alert_no_salary': {
      'English': 'Basic salary required',
      'Arabic': 'الراتب الأساسي مطلوب',
      'Hindi': 'Salary required',
      'Urdu': 'Salary required',
      'Malayalam': 'Basic salary required',
      'Nepali': 'Basic salary required',
      'Bengali': 'Salary required',
      'Filipino': 'Basic salary required',
      'Tamil': 'அடிப்படை சம்பளம் தேவை',
    },
    'ot_alert_no_salary_body': {
      'English':
          'Enter your basic salary from your contract or payslip for accurate rates.',
      'Arabic': 'أدخل راتبك الأساسي من العقد.',
      'Hindi': 'Enter basic salary.',
      'Urdu': 'Enter basic salary.',
      'Malayalam':
          'Enter your basic salary from your contract or payslip for accurate rates.',
      'Nepali':
          'Enter your basic salary from your contract or payslip for accurate rates.',
      'Bengali': 'Enter basic salary.',
      'Filipino':
          'Enter your basic salary from your contract or payslip for accurate rates.',
      'Tamil':
          'துல்லியமான விகிதங்களுக்கு ஒப்பந்தம் அல்லது payslip-லிருந்து அடிப்படை சம்பளத்தை உள்ளிடவும்.',
    },
    'ot_alert_ramadan': {
      'English': 'Ramadan schedule applied',
      'Arabic': 'جدول رمضان مُفعّل',
      'Hindi': 'Ramadan schedule applied',
      'Urdu': 'Ramadan schedule applied',
      'Malayalam': 'Ramadan schedule applied',
      'Nepali': 'Ramadan schedule applied',
      'Bengali': 'Ramadan schedule applied',
      'Filipino': 'Ramadan schedule applied',
      'Tamil': 'Ramadan அட்டவணை பயன்படுத்தப்பட்டது',
    },
    'ot_alert_ramadan_body': {
      'English':
          'Standard hours use the reduced Ramadan day length in this calculation.',
      'Arabic': 'تُستخدم ساعات رمضان المخفّضة في هذا الحساب.',
      'Hindi': 'Reduced Ramadan hours used in calculation.',
      'Urdu': 'Reduced Ramadan hours used in calculation.',
      'Malayalam':
          'Standard hours use the reduced Ramadan day length in this calculation.',
      'Nepali':
          'Standard hours use the reduced Ramadan day length in this calculation.',
      'Bengali': 'Reduced Ramadan hours used in calculation.',
      'Filipino':
          'Standard hours use the reduced Ramadan day length in this calculation.',
      'Tamil':
          'இந்த கணக்கீட்டில் குறைக்கப்பட்ட Ramadan நாள் நீளம் standard மணிக்குப் பயன்படுத்தப்படுகிறது.',
    },
    'ot_formula_label': {
      'English': 'Formula',
      'Arabic': 'المعادلة',
      'Hindi': 'Formula',
      'Urdu': 'Formula',
      'Malayalam': 'Formula',
      'Nepali': 'Formula',
      'Bengali': 'Formula',
      'Filipino': 'Formula',
      'Tamil': 'சூத்திரம்',
    },
    'eosb_example_label': {
      'English': 'Example',
      'Arabic': 'مثال',
      'Hindi': 'Example',
      'Urdu': 'Example',
      'Malayalam': 'Example',
      'Nepali': 'Example',
      'Bengali': 'Example',
      'Filipino': 'Example',
      'Tamil': 'எடுத்துக்காட்டு',
    },
    'eosb_select_date': {
      'English': 'Select date',
      'Arabic': 'اختر التاريخ',
      'Hindi': 'Select date',
      'Urdu': 'Select date',
      'Malayalam': 'Select date',
      'Nepali': 'Select date',
      'Bengali': 'Select date',
      'Filipino': 'Select date',
      'Tamil': 'தேதியைத் தேர்ந்தெடு',
    },
    'eosb_section_employment': {
      'English': 'Employment details',
      'Arabic': 'تفاصيل التوظيف',
      'Hindi': 'Employment details',
      'Urdu': 'Employment details',
      'Malayalam': 'Employment details',
      'Nepali': 'Employment details',
      'Bengali': 'Employment details',
      'Filipino': 'Employment details',
      'Tamil': 'வேலை விவரங்கள்',
    },
    'eosb_section_employment_sub': {
      'English': 'Company, tenure, and contract type',
      'Arabic': 'الشركة والمدة ونوع العقد',
      'Hindi': 'Company, tenure, contract',
      'Urdu': 'Company, tenure, contract',
      'Malayalam': 'Company, tenure, and contract type',
      'Nepali': 'Company, tenure, and contract type',
      'Bengali': 'Company, tenure, contract',
      'Filipino': 'Company, tenure, and contract type',
      'Tamil': 'நிறுவனம், பணியாற்றும் காலம், ஒப்பந்த வகை',
    },
    'eosb_section_separation': {
      'English': 'Separation',
      'Arabic': 'إنهاء الخدمة',
      'Hindi': 'Separation',
      'Urdu': 'Separation',
      'Malayalam': 'Separation',
      'Nepali': 'Separation',
      'Bengali': 'Separation',
      'Filipino': 'Separation',
      'Tamil': 'பிரிவு',
    },
    'eosb_section_separation_sub': {
      'English': 'How employment ended',
      'Arabic': 'كيف انتهى التوظيف',
      'Hindi': 'How employment ended',
      'Urdu': 'How employment ended',
      'Malayalam': 'How employment ended',
      'Nepali': 'How employment ended',
      'Bengali': 'How employment ended',
      'Filipino': 'How employment ended',
      'Tamil': 'வேலை எப்படி முடிந்தது',
    },
    'eosb_section_benefits': {
      'English': 'Benefits & privacy',
      'Arabic': 'المزايا والخصوصية',
      'Hindi': 'Benefits & privacy',
      'Urdu': 'Benefits & privacy',
      'Malayalam': 'Benefits & privacy',
      'Nepali': 'Benefits & privacy',
      'Bengali': 'Benefits & privacy',
      'Filipino': 'Benefits & privacy',
      'Tamil': 'பலன்கள் & தனியுரிமை',
    },
    'eosb_section_benefits_sub': {
      'English': 'Contract perks and data consent',
      'Arabic': 'مزايا العقد وموافقة البيانات',
      'Hindi': 'Contract perks and consent',
      'Urdu': 'Contract perks and consent',
      'Malayalam': 'Contract perks and data consent',
      'Nepali': 'Contract perks and data consent',
      'Bengali': 'Contract perks and consent',
      'Filipino': 'Contract perks and data consent',
      'Tamil': 'ஒப்பந்த perks மற்றும் தரவு ஒப்புதல்',
    },
    'eosb_contract_type': {
      'English': 'Contract type',
      'Arabic': 'نوع العقد',
      'Hindi': 'Contract type',
      'Urdu': 'Contract type',
      'Malayalam': 'Contract type',
      'Nepali': 'Contract type',
      'Bengali': 'Contract type',
      'Filipino': 'Contract type',
      'Tamil': 'ஒப்பந்த வகை',
    },
    'eosb_termination_type': {
      'English': 'Termination type',
      'Arabic': 'نوع إنهاء الخدمة',
      'Hindi': 'Termination type',
      'Urdu': 'Termination type',
      'Malayalam': 'Termination type',
      'Nepali': 'Termination type',
      'Bengali': 'Termination type',
      'Filipino': 'Termination type',
      'Tamil': 'முடிவு வகை',
    },
    'eosb_notice_served': {
      'English': 'Notice served',
      'Arabic': 'تم تقديم الإشعار',
      'Hindi': 'Notice served',
      'Urdu': 'Notice served',
      'Malayalam': 'Notice served',
      'Nepali': 'Notice served',
      'Bengali': 'Notice served',
      'Filipino': 'Notice served',
      'Tamil': 'அறிவிப்பு வழங்கப்பட்டது',
    },
    'eosb_notice_served_sub': {
      'English': 'Required notice period was completed',
      'Arabic': 'اكتملت فترة الإشعار المطلوبة',
      'Hindi': 'Notice period completed',
      'Urdu': 'Notice period completed',
      'Malayalam': 'Required notice period was completed',
      'Nepali': 'Required notice period was completed',
      'Bengali': 'Notice period completed',
      'Filipino': 'Required notice period was completed',
      'Tamil': 'தேவையான அறிவிப்பு காலம் முடிந்தது',
    },
    'eosb_art67_section_title': {
      'English': 'Article 67 — employer payment deadline',
      'Arabic': 'المادة 67 — موعد دفع صاحب العمل',
      'Hindi': 'Article 67 — employer payment deadline',
      'Urdu': 'Article 67 — employer payment deadline',
      'Malayalam': 'Article 67 — employer payment deadline',
      'Nepali': 'Article 67 — employer payment deadline',
      'Bengali': 'Article 67 — employer payment deadline',
      'Filipino': 'Article 67 — employer payment deadline',
      'Tamil': 'Article 67 — employer payment deadline',
    },
    'eosb_art67_section_sub': {
      'English':
          'Separate from notice-period completion — records your Article 49 notice status for final settlement timing.',
      'Arabic': 'منفصل عن اكتمال فترة الإشعار — يسجل حالة إشعار المادة 49.',
      'Hindi':
          'Separate from notice period completion — Article 49 status for settlement timing.',
      'Urdu':
          'Separate from notice period completion — Article 49 status for settlement timing.',
      'Malayalam':
          'Separate from notice-period completion — records your Article 49 notice status for final settlement timing.',
      'Nepali':
          'Separate from notice-period completion — records your Article 49 notice status for final settlement timing.',
      'Bengali': 'Separate from notice period completion — Article 49 status.',
      'Filipino':
          'Separate from notice-period completion — records your Article 49 notice status for final settlement timing.',
      'Tamil': 'Article 49 notice status for final settlement timing.',
    },
    'eosb_art49_notice_question': {
      'English':
          'Did you give the notice required under Article 49 before leaving work?',
      'Arabic': 'هل قدمت الإشعار المطلوب بموجب المادة 49 قبل مغادرة العمل؟',
      'Hindi': 'Did you give Article 49 notice before leaving work?',
      'Urdu': 'Did you give Article 49 notice before leaving work?',
      'Malayalam':
          'Did you give the notice required under Article 49 before leaving work?',
      'Nepali':
          'Did you give the notice required under Article 49 before leaving work?',
      'Bengali': 'Did you give Article 49 notice before leaving work?',
      'Filipino':
          'Did you give the notice required under Article 49 before leaving work?',
      'Tamil':
          'Did you give the notice required under Article 49 before leaving work?',
    },
    'eosb_art49_notice_yes': {
      'English': 'Yes — Article 49 notice was given',
      'Arabic': 'نعم — تم تقديم إشعار المادة 49',
      'Hindi': 'Yes — Article 49 notice given',
      'Urdu': 'Yes — Article 49 notice given',
      'Malayalam': 'Yes — Article 49 notice was given',
      'Nepali': 'Yes — Article 49 notice was given',
      'Bengali': 'Yes — Article 49 notice given',
      'Filipino': 'Yes — Article 49 notice was given',
      'Tamil': 'Yes — Article 49 notice was given',
    },
    'eosb_art49_notice_no': {
      'English': 'No — left without Article 49 notice',
      'Arabic': 'لا — غادرت دون إشعار المادة 49',
      'Hindi': 'No — left without Article 49 notice',
      'Urdu': 'No — left without Article 49 notice',
      'Malayalam': 'No — left without Article 49 notice',
      'Nepali': 'No — left without Article 49 notice',
      'Bengali': 'No — left without Article 49 notice',
      'Filipino': 'No — left without Article 49 notice',
      'Tamil': 'No — left without Article 49 notice',
    },
    'eosb_art49_notice_unsure': {
      'English': 'Not sure',
      'Arabic': 'غير متأكد',
      'Hindi': 'Not sure',
      'Urdu': 'Not sure',
      'Malayalam': 'Not sure',
      'Nepali': 'Not sure',
      'Bengali': 'Not sure',
      'Filipino': 'Not sure',
      'Tamil': 'Not sure',
    },
    'eosb_art62_optional_cta': {
      'English': 'Optional: review dismissal grounds and procedure',
      'Arabic': 'اختياري: مراجعة أسباب الفصل والإجراء المتبع',
      'Hindi': 'Optional: review dismissal grounds and procedure',
      'Urdu': 'Optional: review dismissal grounds and procedure',
      'Malayalam': 'Optional: review dismissal grounds and procedure',
      'Nepali': 'Optional: review dismissal grounds and procedure',
      'Bengali': 'Optional: review dismissal grounds and procedure',
      'Filipino': 'Optional: review dismissal grounds and procedure',
      'Tamil': 'Optional: review dismissal grounds and procedure',
    },
    'eosb_art62_skip': {
      'English': 'Skip — not needed',
      'Arabic': 'تخطي — غير مطلوب',
      'Hindi': 'Skip — not needed',
      'Urdu': 'Skip — not needed',
      'Malayalam': 'Skip — not needed',
      'Nepali': 'Skip — not needed',
      'Bengali': 'Skip — not needed',
      'Filipino': 'Skip — not needed',
      'Tamil': 'Skip — not needed',
    },
    'eosb_art62_reopen': {
      'English': 'Reopen dismissal review',
      'Arabic': 'إعادة فتح مراجعة الفصل',
      'Hindi': 'Reopen dismissal review',
      'Urdu': 'Reopen dismissal review',
      'Malayalam': 'Reopen dismissal review',
      'Nepali': 'Reopen dismissal review',
      'Bengali': 'Reopen dismissal review',
      'Filipino': 'Reopen dismissal review',
      'Tamil': 'Reopen dismissal review',
    },
    'eosb_art62_section_title': {
      'English': 'Dismissal review (optional)',
      'Arabic': 'مراجعة الفصل (اختياري)',
      'Hindi': 'Dismissal review (optional)',
      'Urdu': 'Dismissal review (optional)',
      'Malayalam': 'Dismissal review (optional)',
      'Nepali': 'Dismissal review (optional)',
      'Bengali': 'Dismissal review (optional)',
      'Filipino': 'Dismissal review (optional)',
      'Tamil': 'Dismissal review (optional)',
    },
    'eosb_art62_section_sub': {
      'English':
          'Separate from your gratuity estimate — helps you note facts about your dismissal that may be worth reviewing with official channels.',
      'Arabic':
          'منفصل عن تقدير مكافأة نهاية الخدمة — يساعدك على تدوين وقائع عن الفصل قد تستحق المراجعة عبر القنوات الرسمية.',
      'Hindi':
          'Separate from gratuity estimate — note dismissal facts worth reviewing with official channels.',
      'Urdu':
          'Separate from gratuity estimate — note dismissal facts worth reviewing with official channels.',
      'Malayalam':
          'Separate from your gratuity estimate — helps you note facts about your dismissal that may be worth reviewing with official channels.',
      'Nepali':
          'Separate from your gratuity estimate — helps you note facts about your dismissal that may be worth reviewing with official channels.',
      'Bengali':
          'Separate from gratuity estimate — note dismissal facts for official review.',
      'Filipino':
          'Separate from your gratuity estimate — helps you note facts about your dismissal that may be worth reviewing with official channels.',
      'Tamil':
          'Separate from your gratuity estimate — helps you note facts about your dismissal that may be worth reviewing with official channels.',
    },
    'eosb_art62_disclaimer': {
      'English':
          'This is a self-assessment only — it does not determine whether your dismissal was arbitrary, unlawful, or whether you have any legal claim.',
      'Arabic':
          'هذا تقييم ذاتي فقط — ولا يحدد ما إذا كان الفصل تعسفياً أو مخالفاً للقانون أو ما إذا كان لديك أي مطالبة قانونية.',
      'Hindi':
          'Self-assessment only — not a determination of arbitrary dismissal or legal rights.',
      'Urdu':
          'Self-assessment only — not a determination of arbitrary dismissal or legal rights.',
      'Malayalam':
          'This is a self-assessment only — it does not determine whether your dismissal was arbitrary, unlawful, or whether you have any legal claim.',
      'Nepali':
          'This is a self-assessment only — it does not determine whether your dismissal was arbitrary, unlawful, or whether you have any legal claim.',
      'Bengali': 'Self-assessment only — not a legal determination.',
      'Filipino':
          'This is a self-assessment only — it does not determine whether your dismissal was arbitrary, unlawful, or whether you have any legal claim.',
      'Tamil':
          'This is a self-assessment only — it does not determine whether your dismissal was arbitrary, unlawful, or whether you have any legal claim.',
    },
    'eosb_art62_q1_reason_given': {
      'English': 'Was a specific reason given for your termination?',
      'Arabic': 'هل ذُكر سبب محدد لإنهاء خدمتك؟',
      'Hindi': 'Was a specific reason given for your termination?',
      'Urdu': 'Was a specific reason given for your termination?',
      'Malayalam': 'Was a specific reason given for your termination?',
      'Nepali': 'Was a specific reason given for your termination?',
      'Bengali': 'Was a specific reason given for your termination?',
      'Filipino': 'Was a specific reason given for your termination?',
      'Tamil': 'Was a specific reason given for your termination?',
    },
    'eosb_art62_q2_matches_art61': {
      'English':
          'Does that reason match one of the Article 61 grounds for dismissal without notice and without gratuity?',
      'Arabic':
          'هل يطابق ذلك أحد أسباب المادة 61 للفصل دون إشعار ودون مكافأة نهاية الخدمة؟',
      'Hindi':
          'Does that reason match an Article 61 ground for dismissal without notice and without gratuity?',
      'Urdu':
          'Does that reason match an Article 61 ground for dismissal without notice and without gratuity?',
      'Malayalam':
          'Does that reason match one of the Article 61 grounds for dismissal without notice and without gratuity?',
      'Nepali':
          'Does that reason match one of the Article 61 grounds for dismissal without notice and without gratuity?',
      'Bengali':
          'Does that reason match an Article 61 ground for dismissal without notice and without gratuity?',
      'Filipino':
          'Does that reason match one of the Article 61 grounds for dismissal without notice and without gratuity?',
      'Tamil':
          'Does that reason match one of the Article 61 grounds for dismissal without notice and without gratuity?',
    },
    'eosb_art62_art61_grounds_list': {
      'English':
          'Article 61 grounds (Law 14/2004): false identity or forged documents; gross financial loss with Labour Department notified within 24 hours; repeated written safety violations; repeated essential-duty failures after written warning; disclosure of establishment secrets; intoxication or drugs during working hours; assault on employer, manager, or supervisor; repeated assault on colleagues after written warning; unauthorised absence for more than 7 consecutive days or 15 days in one year; final sentence for immorality or dishonesty.',
      'Arabic':
          'أسباب المادة 61 (القانون 14/2004): هوية أو جنسية مزيفة أو مستندات مزورة؛ خسارة مالية جسيمة مع إبلاغ وزارة العمل خلال 24 ساعة؛ تكرار مخالفات تعليمات السلامة المكتوبة؛ تكرار الإخفاق في الواجبات الأساسية بعد إنذار كتابي؛ إفشاء أسرار المنشأة؛ تعاطي مسكرات أو مخدرات أثناء العمل؛ اعتداء على صاحب العمل أو المدير أو المشرف؛ تكرار الاعتداء على الزملاء بعد إنذار كتابي؛ غياب دون عذر أكثر من 7 أيام متتالية أو 15 يوماً في السنة؛ حكم نهائي بجريمة مخلة بالآداب أو الأمانة.',
      'Hindi':
          'Article 61 grounds: false identity/documents; gross financial loss + 24h Labour Dept notice; repeated safety violations; essential-duty failures after warning; secrets disclosure; intoxication at work; assault; repeated colleague assault; absence thresholds; criminal sentence for immorality/dishonesty.',
      'Urdu':
          'Article 61 grounds: false identity/documents; gross financial loss + 24h Labour Dept notice; repeated safety violations; essential-duty failures after warning; secrets disclosure; intoxication at work; assault; repeated colleague assault; absence thresholds; criminal sentence for immorality/dishonesty.',
      'Malayalam':
          'Article 61 grounds (Law 14/2004): false identity or forged documents; gross financial loss with Labour Department notified within 24 hours; repeated written safety violations; repeated essential-duty failures after written warning; disclosure of establishment secrets; intoxication or drugs during working hours; assault on employer, manager, or supervisor; repeated assault on colleagues after written warning; unauthorised absence thresholds; final sentence for immorality or dishonesty.',
      'Nepali':
          'Article 61 grounds (Law 14/2004): false identity or forged documents; gross financial loss with Labour Department notified within 24 hours; repeated written safety violations; repeated essential-duty failures after written warning; disclosure of establishment secrets; intoxication or drugs during working hours; assault on employer, manager, or supervisor; repeated assault on colleagues after written warning; unauthorised absence thresholds; final sentence for immorality or dishonesty.',
      'Bengali':
          'Article 61 grounds: false identity; gross financial loss + 24h notice; safety violations; duty failures; secrets; intoxication; assault; absence; criminal sentence.',
      'Filipino':
          'Article 61 grounds (Law 14/2004): false identity or forged documents; gross financial loss with Labour Department notified within 24 hours; repeated written safety violations; repeated essential-duty failures after written warning; disclosure of establishment secrets; intoxication or drugs during working hours; assault on employer, manager, or supervisor; repeated assault on colleagues after written warning; unauthorised absence thresholds; final sentence for immorality or dishonesty.',
      'Tamil':
          'Article 61 grounds (Law 14/2004): false identity or forged documents; gross financial loss with Labour Department notified within 24 hours; repeated written safety violations; repeated essential-duty failures after written warning; disclosure of establishment secrets; intoxication or drugs during working hours; assault on employer, manager, or supervisor; repeated assault on colleagues after written warning; unauthorised absence thresholds; final sentence for immorality or dishonesty.',
    },
    'eosb_art62_q3_process_followed': {
      'English':
          'From what you know, were written warnings, documented steps, or Labour Department notification (where applicable) followed before termination?',
      'Arabic':
          'بحسب علمك، هل صدرت إنذارات كتابية أو خطوات موثقة أو إبلاغ لوزارة العمل (حيث ينطبق) قبل الفصل؟',
      'Hindi':
          'From what you know, were written warnings, documented steps, or Labour Department notification (where applicable) followed before termination?',
      'Urdu':
          'From what you know, were written warnings, documented steps, or Labour Department notification (where applicable) followed before termination?',
      'Malayalam':
          'From what you know, were written warnings, documented steps, or Labour Department notification (where applicable) followed before termination?',
      'Nepali':
          'From what you know, were written warnings, documented steps, or Labour Department notification (where applicable) followed before termination?',
      'Bengali':
          'From what you know, were written warnings, documented steps, or Labour Department notification followed before termination?',
      'Filipino':
          'From what you know, were written warnings, documented steps, or Labour Department notification (where applicable) followed before termination?',
      'Tamil':
          'From what you know, were written warnings, documented steps, or Labour Department notification (where applicable) followed before termination?',
    },
    'eosb_art62_yes': {
      'English': 'Yes',
      'Arabic': 'نعم',
      'Hindi': 'Yes',
      'Urdu': 'Yes',
      'Malayalam': 'Yes',
      'Nepali': 'Yes',
      'Bengali': 'Yes',
      'Filipino': 'Yes',
      'Tamil': 'Yes',
    },
    'eosb_art62_no': {
      'English': 'No',
      'Arabic': 'لا',
      'Hindi': 'No',
      'Urdu': 'No',
      'Malayalam': 'No',
      'Nepali': 'No',
      'Bengali': 'No',
      'Filipino': 'No',
      'Tamil': 'No',
    },
    'eosb_art62_result_section_title': {
      'English': 'Dismissal dispute review',
      'Arabic': 'مراجعة نزاع الفصل',
      'Hindi': 'Dismissal dispute review',
      'Urdu': 'Dismissal dispute review',
      'Malayalam': 'Dismissal dispute review',
      'Nepali': 'Dismissal dispute review',
      'Bengali': 'Dismissal dispute review',
      'Filipino': 'Dismissal dispute review',
      'Tamil': 'Dismissal dispute review',
    },
    'eosb_art62_result_section_sub': {
      'English':
          'This is separate from your gratuity total below. Your answers identify facts worth reviewing — this is not a determination that your dismissal was arbitrary or that you have a legal claim.',
      'Arabic':
          'هذا منفصل عن إجمالي مكافأة نهاية الخدمة أدناه. إجاباتك تبرز وقائع قد تستحق المراجعة — وليس هذا تحديداً بأن الفصل كان تعسفياً أو أن لديك مطالبة قانونية.',
      'Hindi':
          'Separate from gratuity below. Facts worth reviewing — not a legal determination.',
      'Urdu':
          'Separate from gratuity below. Facts worth reviewing — not a legal determination.',
      'Malayalam':
          'This is separate from your gratuity total below. Your answers identify facts worth reviewing — this is not a determination that your dismissal was arbitrary or that you have a legal claim.',
      'Nepali':
          'This is separate from your gratuity total below. Your answers identify facts worth reviewing — this is not a determination that your dismissal was arbitrary or that you have a legal claim.',
      'Bengali':
          'Separate from gratuity below. Facts worth reviewing — not a legal determination.',
      'Filipino':
          'This is separate from your gratuity total below. Your answers identify facts worth reviewing — this is not a determination that your dismissal was arbitrary or that you have a legal claim.',
      'Tamil':
          'This is separate from your gratuity total below. Your answers identify facts worth reviewing — this is not a determination that your dismissal was arbitrary or that you have a legal claim.',
    },
    'eosb_art62_known': {
      'English':
          'Known: Your gratuity is calculated separately below (Article 54). It is generally owed after one year of service unless a valid Article 61 ground for forfeiture applies and is proven — verify on Al Meezan.',
      'Arabic':
          'معروف: تُحسب مكافأة نهاية الخدمة أدناه بشكل منفصل (المادة 54). تُستحق عادةً بعد سنة خدمة ما لم ينطبق سبب صحيح بموجب المادة 61 — تحقق على الميزان.',
      'Hindi':
          'Known: Gratuity below is separate (Art. 54). Generally owed after 1+ year unless valid Art. 61 forfeiture ground applies.',
      'Urdu':
          'Known: Gratuity below is separate (Art. 54). Generally owed after 1+ year unless valid Art. 61 forfeiture ground applies.',
      'Malayalam':
          'Known: Your gratuity is calculated separately below (Article 54). It is generally owed after one year of service unless a valid Article 61 ground for forfeiture applies and is proven.',
      'Nepali':
          'Known: Your gratuity is calculated separately below (Article 54). It is generally owed after one year of service unless a valid Article 61 ground for forfeiture applies and is proven.',
      'Bengali':
          'Known: Gratuity separate (Art. 54). Owed after 1+ year unless valid Art. 61 forfeiture.',
      'Filipino':
          'Known: Your gratuity is calculated separately below (Article 54). It is generally owed after one year of service unless a valid Article 61 ground for forfeiture applies and is proven.',
      'Tamil':
          'Known: Your gratuity is calculated separately below (Article 54). It is generally owed after one year of service unless a valid Article 61 ground for forfeiture applies and is proven.',
    },
    'eosb_art62_possible': {
      'English':
          'Your answers may relate to Article 61 grounds for dismissal without notice and without gratuity — verify the full statutory list on Al Meezan.',
      'Arabic':
          'قد ترتبط إجاباتك بأسباب المادة 61 للفصل دون إشعار ودون مكافأة — تحقق من القائمة الكاملة على الميزان.',
      'Hindi':
          'Answers may relate to Article 61 grounds — verify on Al Meezan.',
      'Urdu': 'Answers may relate to Article 61 grounds — verify on Al Meezan.',
      'Malayalam':
          'Your answers may relate to Article 61 grounds for dismissal without notice and without gratuity — verify the full statutory list on Al Meezan.',
      'Nepali':
          'Your answers may relate to Article 61 grounds for dismissal without notice and without gratuity — verify the full statutory list on Al Meezan.',
      'Bengali':
          'Answers may relate to Article 61 grounds — verify on Al Meezan.',
      'Filipino':
          'Your answers may relate to Article 61 grounds for dismissal without notice and without gratuity — verify the full statutory list on Al Meezan.',
      'Tamil':
          'Your answers may relate to Article 61 grounds for dismissal without notice and without gratuity — verify the full statutory list on Al Meezan.',
    },
    'eosb_dismissal_review_art61_info': {
      'English':
          'Article 61 (Law 14/2004): lists grounds where an employer may dismiss without notice and without end-of-service gratuity. Your answers may relate to whether a stated reason fits those grounds — this is not a legal finding.',
      'Arabic':
          'المادة 61 (القانون 14/2004): تُحدد أسباب الفصل دون إشعار ودون مكافأة نهاية الخدمة. قد ترتبط إجاباتك بمدى انطباق السبب المذكور — وليس هذا نتيجة قانونية.',
      'Hindi':
          'Article 61: grounds for dismissal without notice/gratuity. Your answers may relate — not a legal finding.',
      'Urdu':
          'Article 61: grounds for dismissal without notice/gratuity. Your answers may relate — not a legal finding.',
      'Malayalam':
          'Article 61 (Law 14/2004): lists grounds where an employer may dismiss without notice and without end-of-service gratuity. Your answers may relate to whether a stated reason fits those grounds — this is not a legal finding.',
      'Nepali':
          'Article 61 (Law 14/2004): lists grounds where an employer may dismiss without notice and without end-of-service gratuity. Your answers may relate to whether a stated reason fits those grounds — this is not a legal finding.',
      'Bengali':
          'Article 61: dismissal without notice/gratuity grounds. Not a legal finding.',
      'Filipino':
          'Article 61 (Law 14/2004): lists grounds where an employer may dismiss without notice and without end-of-service gratuity. Your answers may relate to whether a stated reason fits those grounds — this is not a legal finding.',
      'Tamil':
          'Article 61 (Law 14/2004): lists grounds where an employer may dismiss without notice and without end-of-service gratuity. Your answers may relate to whether a stated reason fits those grounds — this is not a legal finding.',
    },
    'eosb_dismissal_review_art62_info': {
      'English':
          'Article 62 (Law 14/2004): sets disciplinary penalty procedure — e.g. written inquiry, 15-day accusation limit, one penalty per violation. This self-check does not determine Article 62 compliance.',
      'Arabic':
          'المادة 62 (القانون 14/2004): الإجراء التأديبي لفرض الجزاءات — مثل التحقيق الكتابي، مهلة 15 يوماً، جزاء واحد لكل مخالفة. هذا الفحص لا يحدد الامتثال للمادة 62.',
      'Hindi':
          'Article 62: disciplinary penalty procedure. This check does not determine compliance.',
      'Urdu':
          'Article 62: disciplinary penalty procedure. This check does not determine compliance.',
      'Malayalam':
          'Article 62 (Law 14/2004): sets disciplinary penalty procedure — e.g. written inquiry, 15-day accusation limit, one penalty per violation. This self-check does not determine Article 62 compliance.',
      'Nepali':
          'Article 62 (Law 14/2004): sets disciplinary penalty procedure — e.g. written inquiry, 15-day accusation limit, one penalty per violation. This self-check does not determine Article 62 compliance.',
      'Bengali':
          'Article 62: disciplinary procedure. Does not determine compliance.',
      'Filipino':
          'Article 62 (Law 14/2004): sets disciplinary penalty procedure — e.g. written inquiry, 15-day accusation limit, one penalty per violation. This self-check does not determine Article 62 compliance.',
      'Tamil':
          'Article 62 (Law 14/2004): sets disciplinary penalty procedure — e.g. written inquiry, 15-day accusation limit, one penalty per violation. This self-check does not determine Article 62 compliance.',
    },
    'eosb_dismissal_review_art64_info': {
      'English':
          'Article 64 (Law 14/2004): governs dismissal penalty grievance and court/LDRC challenge. If a court finds dismissal arbitrary or unlawful, it may order reinstatement with back wages or appropriate compensation — no fixed formula; at court discretion. Raabta does not estimate any amount.',
      'Arabic':
          'المادة 64 (القانون 14/2004): تظلم جزاء الفصل والطعن أمام المحكمة أو لجنة فض المنازعات العمالية. إذا وجدت المحكمة الفصل تعسفياً أو مخالفاً للقانون قد تأمر بإعادة العامل مع الأجر أو تعويضاً مناسباً — دون صيغة ثابتة. Raabta لا تُقدّر أي مبلغ.',
      'Hindi':
          'Article 64: dismissal grievance and court/LDRC challenge. Court-discretionary remedy — no fixed amount. Raabta does not estimate.',
      'Urdu':
          'Article 64: dismissal grievance and court/LDRC challenge. Court-discretionary remedy — no fixed amount. Raabta does not estimate.',
      'Malayalam':
          'Article 64 (Law 14/2004): governs dismissal penalty grievance and court/LDRC challenge. If a court finds dismissal arbitrary or unlawful, it may order reinstatement with back wages or appropriate compensation — no fixed formula; at court discretion. Raabta does not estimate any amount.',
      'Nepali':
          'Article 64 (Law 14/2004): governs dismissal penalty grievance and court/LDRC challenge. If a court finds dismissal arbitrary or unlawful, it may order reinstatement with back wages or appropriate compensation — no fixed formula; at court discretion. Raabta does not estimate any amount.',
      'Bengali':
          'Article 64: dismissal grievance/court challenge. No fixed amount. Raabta does not estimate.',
      'Filipino':
          'Article 64 (Law 14/2004): governs dismissal penalty grievance and court/LDRC challenge. If a court finds dismissal arbitrary or unlawful, it may order reinstatement with back wages or appropriate compensation — no fixed formula; at court discretion. Raabta does not estimate any amount.',
      'Tamil':
          'Article 64 (Law 14/2004): governs dismissal penalty grievance and court/LDRC challenge. If a court finds dismissal arbitrary or unlawful, it may order reinstatement with back wages or appropriate compensation — no fixed formula; at court discretion. Raabta does not estimate any amount.',
    },
    'eosb_art62_unknown': {
      'English':
          'Unknown: Whether a court or LDRC would find your dismissal arbitrary or unlawful depends on evidence Raabta cannot assess. Raabta does not predict outcomes or estimate any Article 64 compensation.',
      'Arabic':
          'غير معروف: ما إذا كانت المحكمة أو لجنة فض المنازعات العمالية ستجد الفصل تعسفياً يعتمد على أدلة لا يمكن لـ Raabta تقييمها. لا تنبؤ بالنتيجة ولا تقدير لمبلغ بموجب المادة 64.',
      'Hindi':
          'Unknown: Court/LDRC outcome depends on evidence. No Article 64 compensation estimate.',
      'Urdu':
          'Unknown: Court/LDRC outcome depends on evidence. No Article 64 compensation estimate.',
      'Malayalam':
          'Unknown: Whether a court or LDRC would find your dismissal arbitrary or unlawful depends on evidence Raabta cannot assess. Raabta does not predict outcomes or estimate any Article 64 compensation.',
      'Nepali':
          'Unknown: Whether a court or LDRC would find your dismissal arbitrary or unlawful depends on evidence Raabta cannot assess. Raabta does not predict outcomes or estimate any Article 64 compensation.',
      'Bengali':
          'Unknown: Outcome depends on evidence. No Article 64 amount estimate.',
      'Filipino':
          'Unknown: Whether a court or LDRC would find your dismissal arbitrary or unlawful depends on evidence Raabta cannot assess. Raabta does not predict outcomes or estimate any Article 64 compensation.',
      'Tamil':
          'Unknown: Whether a court or LDRC would find your dismissal arbitrary or unlawful depends on evidence Raabta cannot assess. Raabta does not predict outcomes or estimate any Article 64 compensation.',
    },
    'eosb_art62_action': {
      'English':
          'Action: You may wish to contact ADLSA (helpline 16008) or use the mol.gov.qa Unified Complaints Portal for information on labour dispute routes including LDRC. Keep termination letters, written warnings, and correspondence — log evidence in Case Timeline. This is not confirmation that you have a claim.',
      'Arabic':
          'إجراء: يمكنك التواصل مع ADLSA (16008) أو بوابة mol.gov.qa للاستفسار عن مسارات نزاع العمل بما فيها لجنة فض المنازعات العمالية. احتفظ بمستندات الفصل — سجّل الأدلة في سجل القضية. هذا ليس تأكيداً بوجود مطالبة.',
      'Hindi':
          'Action: Contact ADLSA 16008 or mol.gov.qa for dispute route information. Keep documents; use Case Timeline. Not confirmation of a claim.',
      'Urdu':
          'Action: Contact ADLSA 16008 or mol.gov.qa for dispute route information. Keep documents; use Case Timeline. Not confirmation of a claim.',
      'Malayalam':
          'Action: You may wish to contact ADLSA (helpline 16008) or use the mol.gov.qa Unified Complaints Portal for information on labour dispute routes including LDRC. Keep termination letters, written warnings, and correspondence — log evidence in Case Timeline. This is not confirmation that you have a claim.',
      'Nepali':
          'Action: You may wish to contact ADLSA (helpline 16008) or use the mol.gov.qa Unified Complaints Portal for information on labour dispute routes including LDRC. Keep termination letters, written warnings, and correspondence — log evidence in Case Timeline. This is not confirmation that you have a claim.',
      'Bengali':
          'Action: ADLSA 16008 / mol.gov.qa for dispute info. Keep documents. Not confirmation of a claim.',
      'Filipino':
          'Action: You may wish to contact ADLSA (helpline 16008) or use the mol.gov.qa Unified Complaints Portal for information on labour dispute routes including LDRC. Keep termination letters, written warnings, and correspondence — log evidence in Case Timeline. This is not confirmation that you have a claim.',
      'Tamil':
          'Action: You may wish to contact ADLSA (helpline 16008) or use the mol.gov.qa Unified Complaints Portal for information on labour dispute routes including LDRC. Keep termination letters, written warnings, and correspondence — log evidence in Case Timeline. This is not confirmation that you have a claim.',
    },
    'eosb_art55_hub_section_title': {
      'English': 'For family members',
      'Arabic': 'لأفراد العائلة',
      'Hindi': 'For family members',
      'Urdu': 'For family members',
      'Malayalam': 'For family members',
      'Nepali': 'For family members',
      'Bengali': 'For family members',
      'Filipino': 'For family members',
      'Tamil': 'For family members',
    },
    'eosb_art55_hub_section_sub': {
      'English':
          'Information if a worker passed away during employment in Qatar.',
      'Arabic': 'معلومات إذا توفي عامل أثناء عمله في قطر.',
      'Hindi':
          'Information if a worker passed away during employment in Qatar.',
      'Urdu': 'Information if a worker passed away during employment in Qatar.',
      'Malayalam':
          'Information if a worker passed away during employment in Qatar.',
      'Nepali':
          'Information if a worker passed away during employment in Qatar.',
      'Bengali':
          'Information if a worker passed away during employment in Qatar.',
      'Filipino':
          'Information if a worker passed away during employment in Qatar.',
      'Tamil':
          'Information if a worker passed away during employment in Qatar.',
    },
    'eosb_art55_hub_link': {
      'English': 'Death during employment (Art. 55)',
      'Arabic': 'الوفاة أثناء العمل (المادة 55)',
      'Hindi': 'Death during employment (Art. 55)',
      'Urdu': 'Death during employment (Art. 55)',
      'Malayalam': 'Death during employment (Art. 55)',
      'Nepali': 'Death during employment (Art. 55)',
      'Bengali': 'Death during employment (Art. 55)',
      'Filipino': 'Death during employment (Art. 55)',
      'Tamil': 'Death during employment (Art. 55)',
    },
    'eosb_art55_screen_title': {
      'English': 'If a worker passes away during employment',
      'Arabic': 'إذا توفي عامل أثناء عمله',
      'Hindi': 'If a worker passes away during employment',
      'Urdu': 'If a worker passes away during employment',
      'Malayalam': 'If a worker passes away during employment',
      'Nepali': 'If a worker passes away during employment',
      'Bengali': 'If a worker passes away during employment',
      'Filipino': 'If a worker passes away during employment',
      'Tamil': 'If a worker passes away during employment',
    },
    'eosb_art55_screen_subtitle': {
      'English':
          'This page explains what Qatari labour law requires when a worker dies during their employment. It is written for family members who may be trying to understand the process from outside Qatar. This is general information only — not legal advice for your specific situation.',
      'Arabic':
          'تشرح هذه الصفحة ما يقتضيه قانون العمل القطري عند وفاة عامل أثناء عمله. كُتبت لأفراد العائلة الذين قد يحاولون فهم الإجراء من خارج قطر. هذه معلومات عامة فقط — وليست استشارة قانونية لحالتكم.',
      'Hindi':
          'Qatari labour law when a worker dies during employment — for family members abroad. General information only, not legal advice.',
      'Urdu':
          'Qatari labour law when a worker dies during employment — for family members abroad. General information only, not legal advice.',
      'Malayalam':
          'This page explains what Qatari labour law requires when a worker dies during their employment. It is written for family members who may be trying to understand the process from outside Qatar. This is general information only — not legal advice for your specific situation.',
      'Nepali':
          'This page explains what Qatari labour law requires when a worker dies during their employment. It is written for family members who may be trying to understand the process from outside Qatar. This is general information only — not legal advice for your specific situation.',
      'Bengali':
          'Qatari labour law when a worker dies during employment — for family members abroad. General information only, not legal advice.',
      'Filipino':
          'This page explains what Qatari labour law requires when a worker dies during their employment. It is written for family members who may be trying to understand the process from outside Qatar. This is general information only — not legal advice for your specific situation.',
      'Tamil':
          'This page explains what Qatari labour law requires when a worker dies during their employment. It is written for family members who may be trying to understand the process from outside Qatar. This is general information only — not legal advice for your specific situation.',
    },
    'eosb_art55_deposit_known': {
      'English':
          'Known: Under Article 55 of Qatar Labour Law No. 14 of 2004, if a worker dies during employment for any cause, the employer must deposit the worker\'s outstanding wages, any earned end-of-service gratuity, and other entitlements with the court within 15 days of the date of death.',
      'Arabic':
          'معروف: بموجب المادة 55 من قانون العمل رقم 14 لسنة 2004، إذا توفي عامل أثناء عمله لأي سبب، يجب على صاحب العمل إيداع الأجور المستحقة وأي مكافأة نهاية خدمة مكتسبة وسائر المستحقات لدى المحكمة خلال 15 يوماً من تاريخ الوفاة.',
      'Hindi':
          'Known: Art. 55 — employer must deposit wages, earned gratuity, and other entitlements with court within 15 days of death.',
      'Urdu':
          'Known: Art. 55 — employer must deposit wages, earned gratuity, and other entitlements with court within 15 days of death.',
      'Malayalam':
          'Known: Under Article 55 of Qatar Labour Law No. 14 of 2004, if a worker dies during employment for any cause, the employer must deposit the worker\'s outstanding wages, any earned end-of-service gratuity, and other entitlements with the court within 15 days of the date of death.',
      'Nepali':
          'Known: Under Article 55 of Qatar Labour Law No. 14 of 2004, if a worker dies during employment for any cause, the employer must deposit the worker\'s outstanding wages, any earned end-of-service gratuity, and other entitlements with the court within 15 days of the date of death.',
      'Bengali':
          'Known: Art. 55 — employer must deposit wages, gratuity, entitlements with court within 15 days of death.',
      'Filipino':
          'Known: Under Article 55 of Qatar Labour Law No. 14 of 2004, if a worker dies during employment for any cause, the employer must deposit the worker\'s outstanding wages, any earned end-of-service gratuity, and other entitlements with the court within 15 days of the date of death.',
      'Tamil':
          'Known: Under Article 55 of Qatar Labour Law No. 14 of 2004, if a worker dies during employment for any cause, the employer must deposit the worker\'s outstanding wages, any earned end-of-service gratuity, and other entitlements with the court within 15 days of the date of death.',
    },
    'eosb_art55_report_known': {
      'English':
          'Known: The deposit must include a detailed report showing exactly how each amount was calculated.',
      'Arabic':
          'معروف: يجب أن يتضمن الإيداع تقريراً مفصلاً يبيّن كيفية حساب كل مبلغ.',
      'Hindi': 'Known: Deposit must include a detailed calculation report.',
      'Urdu': 'Known: Deposit must include a detailed calculation report.',
      'Malayalam':
          'Known: The deposit must include a detailed report showing exactly how each amount was calculated.',
      'Nepali':
          'Known: The deposit must include a detailed report showing exactly how each amount was calculated.',
      'Bengali': 'Known: Deposit must include detailed calculation report.',
      'Filipino':
          'Known: The deposit must include a detailed report showing exactly how each amount was calculated.',
      'Tamil':
          'Known: The deposit must include a detailed report showing exactly how each amount was calculated.',
    },
    'eosb_art55_gratuity_known': {
      'English':
          'Known: End-of-service gratuity is calculated the same way as for any other end of employment — the worker\'s service is not reduced or penalized because of death. If they had completed one year of continuous service, gratuity applies in full under the standard formula (Article 54 area).',
      'Arabic':
          'معروف: تُحسب مكافأة نهاية الخدمة كما في أي انتهاء خدمة آخر — لا تُخفَّض الخدمة بسبب الوفاة. إذا أكمل عاماً متصلاً من الخدمة، تُستحق المكافأة كاملة وفق الصيغة المعتادة (نطاق المادة 54).',
      'Hindi':
          'Known: Gratuity calculated same as normal EOS — not reduced because of death. Full if 1+ year service (Art. 54).',
      'Urdu':
          'Known: Gratuity calculated same as normal EOS — not reduced because of death. Full if 1+ year service (Art. 54).',
      'Malayalam':
          'Known: End-of-service gratuity is calculated the same way as for any other end of employment — the worker\'s service is not reduced or penalized because of death. If they had completed one year of continuous service, gratuity applies in full under the standard formula (Article 54 area).',
      'Nepali':
          'Known: End-of-service gratuity is calculated the same way as for any other end of employment — the worker\'s service is not reduced or penalized because of death. If they had completed one year of continuous service, gratuity applies in full under the standard formula (Article 54 area).',
      'Bengali':
          'Known: Gratuity same as normal EOS — not reduced for death. Full if 1+ year (Art. 54).',
      'Filipino':
          'Known: End-of-service gratuity is calculated the same way as for any other end of employment — the worker\'s service is not reduced or penalized because of death. If they had completed one year of continuous service, gratuity applies in full under the standard formula (Article 54 area).',
      'Tamil':
          'Known: End-of-service gratuity is calculated the same way as for any other end of employment — the worker\'s service is not reduced or penalized because of death. If they had completed one year of continuous service, gratuity applies in full under the standard formula (Article 54 area).',
    },
    'eosb_art55_distribution_known': {
      'English':
          'Known: The court distributes the deposited funds to the worker\'s heirs. Distribution follows Islamic Sharia principles or the personal law applicable in the country of the deceased — meaning a non-Muslim expatriate worker\'s family inheritance rules from their home country may govern how funds are shared, not automatic Sharia. Families should ask which law applies in their case.',
      'Arabic':
          'معروف: توزّع المحكمة الأموال المودعة على ورثة العامل. يُطبَّق الشريعة الإسلامية أو القانون الشخصي المنطبق في بلد المتوفى — فقد تحكم قواعد الميراث في بلد مغترب غير مسلم، وليس الشريعة تلقائياً. على العائلة السؤال عن القانون المنطبق.',
      'Hindi':
          'Known: Court pays heirs under Sharia OR personal law applicable in the country of the deceased — not automatic Sharia for every worker.',
      'Urdu':
          'Known: Court pays heirs under Sharia OR personal law applicable in the country of the deceased — not automatic Sharia for every worker.',
      'Malayalam':
          'Known: The court distributes the deposited funds to the worker\'s heirs. Distribution follows Islamic Sharia principles or the personal law applicable in the country of the deceased — meaning a non-Muslim expatriate worker\'s family inheritance rules from their home country may govern how funds are shared, not automatic Sharia. Families should ask which law applies in their case.',
      'Nepali':
          'Known: The court distributes the deposited funds to the worker\'s heirs. Distribution follows Islamic Sharia principles or the personal law applicable in the country of the deceased — meaning a non-Muslim expatriate worker\'s family inheritance rules from their home country may govern how funds are shared, not automatic Sharia. Families should ask which law applies in their case.',
      'Bengali':
          'Known: Court pays heirs under Sharia OR personal law in deceased\'s country — not automatic Sharia.',
      'Filipino':
          'Known: The court distributes the deposited funds to the worker\'s heirs. Distribution follows Islamic Sharia principles or the personal law applicable in the country of the deceased — meaning a non-Muslim expatriate worker\'s family inheritance rules from their home country may govern how funds are shared, not automatic Sharia. Families should ask which law applies in their case.',
      'Tamil':
          'Known: The court distributes the deposited funds to the worker\'s heirs. Distribution follows Islamic Sharia principles or the personal law applicable in the country of the deceased — meaning a non-Muslim expatriate worker\'s family inheritance rules from their home country may govern how funds are shared, not automatic Sharia. Families should ask which law applies in their case.',
    },
    'eosb_art55_work_related_title': {
      'English': 'If the death was work-related',
      'Arabic': 'إذا كانت الوفاة بسبب العمل',
      'Hindi': 'If the death was work-related',
      'Urdu': 'If the death was work-related',
      'Malayalam': 'If the death was work-related',
      'Nepali': 'If the death was work-related',
      'Bengali': 'If the death was work-related',
      'Filipino': 'If the death was work-related',
      'Tamil': 'If the death was work-related',
    },
    'eosb_art55_work_related_body': {
      'English':
          'Possible: Article 55 covers wages, other employment entitlements, and end-of-service gratuity payable following death during employment. If the worker died by reason of the work, separate compensation rights may also apply under Articles 110 and 114 of the Labour Law. The applicable process and amount depend on the circumstances and the findings of the relevant investigation. Not every death during employment qualifies for work-injury compensation.',
      'Arabic':
          'محتمل: تغطي المادة 55 الأجور وسائر مستحقات العمل ومكافأة نهاية الخدمة عند الوفاة أثناء العمل. إذا توفي العامل بسبب العمل، قد تنطبق حقوق تعويض منفصلة بموجب المادتين 110 و114. الإجراء والمبلغ يعتمدان على الظروف ونتائج التحقيق. ليس كل وفاة أثناء العمل تستحق تعويض إصابة عمل.',
      'Hindi':
          'Possible: Art. 55 covers wages, entitlements, gratuity. If death by reason of work, Art. 110/114 may also apply — process/amount depend on investigation. Not every work death qualifies.',
      'Urdu':
          'Possible: Art. 55 covers wages, entitlements, gratuity. If death by reason of work, Art. 110/114 may also apply — process/amount depend on investigation. Not every work death qualifies.',
      'Malayalam':
          'Possible: Article 55 covers wages, other employment entitlements, and end-of-service gratuity payable following death during employment. If the worker died by reason of the work, separate compensation rights may also apply under Articles 110 and 114 of the Labour Law. The applicable process and amount depend on the circumstances and the findings of the relevant investigation. Not every death during employment qualifies for work-injury compensation.',
      'Nepali':
          'Possible: Article 55 covers wages, other employment entitlements, and end-of-service gratuity payable following death during employment. If the worker died by reason of the work, separate compensation rights may also apply under Articles 110 and 114 of the Labour Law. The applicable process and amount depend on the circumstances and the findings of the relevant investigation. Not every death during employment qualifies for work-injury compensation.',
      'Bengali':
          'Possible: Art. 55 covers wages, entitlements, gratuity. Work-caused death may also invoke Art. 110/114 — depends on investigation. Not every death qualifies.',
      'Filipino':
          'Possible: Article 55 covers wages, other employment entitlements, and end-of-service gratuity payable following death during employment. If the worker died by reason of the work, separate compensation rights may also apply under Articles 110 and 114 of the Labour Law. The applicable process and amount depend on the circumstances and the findings of the relevant investigation. Not every death during employment qualifies for work-injury compensation.',
      'Tamil':
          'Possible: Article 55 covers wages, other employment entitlements, and end-of-service gratuity payable following death during employment. If the worker died by reason of the work, separate compensation rights may also apply under Articles 110 and 114 of the Labour Law. The applicable process and amount depend on the circumstances and the findings of the relevant investigation. Not every death during employment qualifies for work-injury compensation.',
    },
    'eosb_art55_unclaimed_known': {
      'English':
          'Known: If heirs are not identified within three years of the court deposit, the funds transfer to the State\'s public fund.',
      'Arabic':
          'معروف: إذا لم يُحدَّد الورثة خلال ثلاث سنوات من الإيداع، تُحوَّل الأموال إلى الصندوق العام للدولة.',
      'Hindi':
          'Known: If heirs not identified within 3 years, funds go to State public fund.',
      'Urdu':
          'Known: If heirs not identified within 3 years, funds go to State public fund.',
      'Malayalam':
          'Known: If heirs are not identified within three years of the court deposit, the funds transfer to the State\'s public fund.',
      'Nepali':
          'Known: If heirs are not identified within three years of the court deposit, the funds transfer to the State\'s public fund.',
      'Bengali':
          'Known: If heirs not found within 3 years, funds go to State public fund.',
      'Filipino':
          'Known: If heirs are not identified within three years of the court deposit, the funds transfer to the State\'s public fund.',
      'Tamil':
          'Known: If heirs are not identified within three years of the court deposit, the funds transfer to the State\'s public fund.',
    },
    'eosb_art55_repatriation_known': {
      'English':
          'Known: Separately from the court deposit, the employer is responsible for the cost of preparing the deceased worker\'s remains and repatriation to their home country or agreed place of residence, when requested by the heirs.',
      'Arabic':
          'معروف: بشكل منفصل عن إيداع المحكمة، يتحمل صاحب العمل تكلفة تجهيز جثمان العامل وإعادته إلى بلده أو محل إقامته المتفق عليه، عند طلب الورثة.',
      'Hindi':
          'Known: Employer pays remains preparation and repatriation (separate from court deposit) when heirs request.',
      'Urdu':
          'Known: Employer pays remains preparation and repatriation (separate from court deposit) when heirs request.',
      'Malayalam':
          'Known: Separately from the court deposit, the employer is responsible for the cost of preparing the deceased worker\'s remains and repatriation to their home country or agreed place of residence, when requested by the heirs.',
      'Nepali':
          'Known: Separately from the court deposit, the employer is responsible for the cost of preparing the deceased worker\'s remains and repatriation to their home country or agreed place of residence, when requested by the heirs.',
      'Bengali':
          'Known: Employer pays remains prep and repatriation (separate from court deposit) when heirs request.',
      'Filipino':
          'Known: Separately from the court deposit, the employer is responsible for the cost of preparing the deceased worker\'s remains and repatriation to their home country or agreed place of residence, when requested by the heirs.',
      'Tamil':
          'Known: Separately from the court deposit, the employer is responsible for the cost of preparing the deceased worker\'s remains and repatriation to their home country or agreed place of residence, when requested by the heirs.',
    },
    'eosb_art55_repatriation_failure_known': {
      'English':
          'Known: If the employer does not carry out repatriation, the relevant government department may arrange it and recover the cost from the employer through administrative means.',
      'Arabic':
          'معروف: إذا لم ينفّذ صاحب العمل إعادة الجثمان، قد ترتّب الجهة الحكومية المعنية ذلك وتسترد التكلفة من صاحب العمل إدارياً.',
      'Hindi':
          'Known: If employer fails, government department may arrange repatriation and recover cost from employer.',
      'Urdu':
          'Known: If employer fails, government department may arrange repatriation and recover cost from employer.',
      'Malayalam':
          'Known: If the employer does not carry out repatriation, the relevant government department may arrange it and recover the cost from the employer through administrative means.',
      'Nepali':
          'Known: If the employer does not carry out repatriation, the relevant government department may arrange it and recover the cost from the employer through administrative means.',
      'Bengali':
          'Known: If employer fails, government may arrange repatriation and recover cost.',
      'Filipino':
          'Known: If the employer does not carry out repatriation, the relevant government department may arrange it and recover the cost from the employer through administrative means.',
      'Tamil':
          'Known: If the employer does not carry out repatriation, the relevant government department may arrange it and recover the cost from the employer through administrative means.',
    },
    'eosb_art55_family_section_title': {
      'English': 'Guidance for family members',
      'Arabic': 'إرشادات لأفراد العائلة',
      'Hindi': 'Guidance for family members',
      'Urdu': 'Guidance for family members',
      'Malayalam': 'Guidance for family members',
      'Nepali': 'Guidance for family members',
      'Bengali': 'Guidance for family members',
      'Filipino': 'Guidance for family members',
      'Tamil': 'Guidance for family members',
    },
    'eosb_art55_family_action': {
      'English':
          'Action: If you are a family member of a worker who passed away in Qatar, you can contact the Ministry of Labour (MADLSA, hotline 16008) for guidance on this process — including how to confirm the deposit was made and how to be recognized as an heir. If you are unsure where to start, the Qatari embassy or consulate for the worker\'s nationality, or the worker\'s home-country labour attaché in Qatar if one exists, may also help guide you.',
      'Arabic':
          'إجراء: إذا كنت من أفراد عائلة عامل توفي في قطر، يمكنك التواصل مع وزارة العمل (MADLSA، الخط الساخن 16008) للإرشاد — بما في ذلك التأكد من الإيداع والاعتراف بكم كورثة. إذا لم تكن متأكداً من البداية، قد يساعدكم سفارة أو قنصلية قطر ذات الصلة بجنسية العامل، أو الملحق العمالي لبلد العامل في قطر إن وُجد.',
      'Hindi':
          'Action: Contact MADLSA (16008) to confirm deposit and heir recognition. Embassy/consulate or home-country labour attaché in Qatar may also help.',
      'Urdu':
          'Action: Contact MADLSA (16008) to confirm deposit and heir recognition. Embassy/consulate or home-country labour attaché in Qatar may also help.',
      'Malayalam':
          'Action: If you are a family member of a worker who passed away in Qatar, you can contact the Ministry of Labour (MADLSA, hotline 16008) for guidance on this process — including how to confirm the deposit was made and how to be recognized as an heir. If you are unsure where to start, the Qatari embassy or consulate for the worker\'s nationality, or the worker\'s home-country labour attaché in Qatar if one exists, may also help guide you.',
      'Nepali':
          'Action: If you are a family member of a worker who passed away in Qatar, you can contact the Ministry of Labour (MADLSA, hotline 16008) for guidance on this process — including how to confirm the deposit was made and how to be recognized as an heir. If you are unsure where to start, the Qatari embassy or consulate for the worker\'s nationality, or the worker\'s home-country labour attaché in Qatar if one exists, may also help guide you.',
      'Bengali':
          'Action: Contact MADLSA (16008) for deposit and heir guidance. Embassy or labour attaché may help.',
      'Filipino':
          'Action: If you are a family member of a worker who passed away in Qatar, you can contact the Ministry of Labour (MADLSA, hotline 16008) for guidance on this process — including how to confirm the deposit was made and how to be recognized as an heir. If you are unsure where to start, the Qatari embassy or consulate for the worker\'s nationality, or the worker\'s home-country labour attaché in Qatar if one exists, may also help guide you.',
      'Tamil':
          'Action: If you are a family member of a worker who passed away in Qatar, you can contact the Ministry of Labour (MADLSA, hotline 16008) for guidance on this process — including how to confirm the deposit was made and how to be recognized as an heir. If you are unsure where to start, the Qatari embassy or consulate for the worker\'s nationality, or the worker\'s home-country labour attaché in Qatar if one exists, may also help guide you.',
    },
    'eosb_art55_wsif_crossref': {
      'English':
          'Possible: If the employer fails to make the required court deposit or pay other owed entitlements, broader labour dispute routes may apply. Raabta summarizes information about dispute escalation and the Workers\' Support and Insurance Fund (WSIF) separately — without replacing official guidance from MADLSA.',
      'Arabic':
          'محتمل: إذا لم ينفّذ صاحب العمل الإيداع المطلوب أو دفع مستحقات أخرى، قد تنطبق مسارات نزاع عمل أوسع. يلخّص Raabta معلومات التصعيد وصندوق دعم العمال (WSIF) بشكل منفصل — دون أن يحل محل إرشاد MADLSA الرسمي.',
      'Hindi':
          'Possible: If employer fails court deposit, dispute routes may apply — see separate WSIF/escalation info; verify with MADLSA.',
      'Urdu':
          'Possible: If employer fails court deposit, dispute routes may apply — see separate WSIF/escalation info; verify with MADLSA.',
      'Malayalam':
          'Possible: If the employer fails to make the required court deposit or pay other owed entitlements, broader labour dispute routes may apply. Raabta summarizes information about dispute escalation and the Workers\' Support and Insurance Fund (WSIF) separately — without replacing official guidance from MADLSA.',
      'Nepali':
          'Possible: If the employer fails to make the required court deposit or pay other owed entitlements, broader labour dispute routes may apply. Raabta summarizes information about dispute escalation and the Workers\' Support and Insurance Fund (WSIF) separately — without replacing official guidance from MADLSA.',
      'Bengali':
          'Possible: If employer fails deposit, dispute routes may apply — see WSIF info separately; verify with MADLSA.',
      'Filipino':
          'Possible: If the employer fails to make the required court deposit or pay other owed entitlements, broader labour dispute routes may apply. Raabta summarizes information about dispute escalation and the Workers\' Support and Insurance Fund (WSIF) separately — without replacing official guidance from MADLSA.',
      'Tamil':
          'Possible: If the employer fails to make the required court deposit or pay other owed entitlements, broader labour dispute routes may apply. Raabta summarizes information about dispute escalation and the Workers\' Support and Insurance Fund (WSIF) separately — without replacing official guidance from MADLSA.',
    },
    'eosb_art55_wsif_link': {
      'English': 'View dispute escalation and WSIF information',
      'Arabic': 'عرض معلومات التصعيد وWSIF',
      'Hindi': 'View dispute escalation and WSIF information',
      'Urdu': 'View dispute escalation and WSIF information',
      'Malayalam': 'View dispute escalation and WSIF information',
      'Nepali': 'View dispute escalation and WSIF information',
      'Bengali': 'View dispute escalation and WSIF information',
      'Filipino': 'View dispute escalation and WSIF information',
      'Tamil': 'View dispute escalation and WSIF information',
    },
    'eosb_art55_unknown': {
      'English':
          'Unknown: Court procedures, heir recognition documents, and timelines for your specific case — verify directly with MADLSA (16008), the court handling the deposit, or qualified legal counsel. Raabta does not verify deposits or represent heirs.',
      'Arabic':
          'غير معروف: إجراءات المحكمة ومستندات الوراثة والجداول الزمنية لحالتكم — تحققوا مباشرة مع MADLSA (16008) أو المحكمة أو مستشار قانوني. Raabta لا تتحقق من الإيداع ولا تمثل الورثة.',
      'Hindi':
          'Unknown: Court/heir procedures for your case — verify with MADLSA (16008), court, or counsel. Raabta does not verify deposits.',
      'Urdu':
          'Unknown: Court/heir procedures for your case — verify with MADLSA (16008), court, or counsel. Raabta does not verify deposits.',
      'Malayalam':
          'Unknown: Court procedures, heir recognition documents, and timelines for your specific case — verify directly with MADLSA (16008), the court handling the deposit, or qualified legal counsel. Raabta does not verify deposits or represent heirs.',
      'Nepali':
          'Unknown: Court procedures, heir recognition documents, and timelines for your specific case — verify directly with MADLSA (16008), the court handling the deposit, or qualified legal counsel. Raabta does not verify deposits or represent heirs.',
      'Bengali':
          'Unknown: Verify court/heir steps with MADLSA (16008), court, or counsel. Raabta does not verify deposits.',
      'Filipino':
          'Unknown: Court procedures, heir recognition documents, and timelines for your specific case — verify directly with MADLSA (16008), the court handling the deposit, or qualified legal counsel. Raabta does not verify deposits or represent heirs.',
      'Tamil':
          'Unknown: Court procedures, heir recognition documents, and timelines for your specific case — verify directly with MADLSA (16008), the court handling the deposit, or qualified legal counsel. Raabta does not verify deposits or represent heirs.',
    },
    'eosb_art55_disclaimer': {
      'English':
          'This page is for general information only. It does not confirm that a deposit was made, identify heirs, or provide legal advice. Official processes are handled by Qatari authorities and the courts.',
      'Arabic':
          'هذه الصفحة للمعلومات العامة فقط. لا تؤكد إجراء إيداع، ولا تحدد الورثة، ولا تقدّم استشارة قانونية. الإجراءات الرسمية تتم عبر السلطات والمحاكم القطرية.',
      'Hindi':
          'General information only — does not confirm deposits, identify heirs, or give legal advice.',
      'Urdu':
          'General information only — does not confirm deposits, identify heirs, or give legal advice.',
      'Malayalam':
          'This page is for general information only. It does not confirm that a deposit was made, identify heirs, or provide legal advice. Official processes are handled by Qatari authorities and the courts.',
      'Nepali':
          'This page is for general information only. It does not confirm that a deposit was made, identify heirs, or provide legal advice. Official processes are handled by Qatari authorities and the courts.',
      'Bengali':
          'General information only — does not confirm deposits or identify heirs.',
      'Filipino':
          'This page is for general information only. It does not confirm that a deposit was made, identify heirs, or provide legal advice. Official processes are handled by Qatari authorities and the courts.',
      'Tamil':
          'This page is for general information only. It does not confirm that a deposit was made, identify heirs, or provide legal advice. Official processes are handled by Qatari authorities and the courts.',
    },
    'eosb_contract_termination_date': {
      'English': 'Contract termination date',
      'Arabic': 'تاريخ إنهاء العقد',
      'Hindi': 'Contract termination date',
      'Urdu': 'Contract termination date',
      'Malayalam': 'Contract termination date',
      'Nepali': 'Contract termination date',
      'Bengali': 'Contract termination date',
      'Filipino': 'Contract termination date',
      'Tamil': 'Contract termination date',
    },
    'eosb_date_of_leaving_work': {
      'English': 'Date of leaving work',
      'Arabic': 'تاريخ مغادرة العمل',
      'Hindi': 'Date of leaving work',
      'Urdu': 'Date of leaving work',
      'Malayalam': 'Date of leaving work',
      'Nepali': 'Date of leaving work',
      'Bengali': 'Date of leaving work',
      'Filipino': 'Date of leaving work',
      'Tamil': 'Date of leaving work',
    },
    'eosb_contract_termination_same_as_last': {
      'English':
          'Contract termination date is the same as my last working date',
      'Arabic': 'تاريخ إنهاء العقد هو نفس آخر يوم عمل',
      'Hindi': 'Contract termination date same as last working date',
      'Urdu': 'Contract termination date same as last working date',
      'Malayalam':
          'Contract termination date is the same as my last working date',
      'Nepali': 'Contract termination date is the same as my last working date',
      'Bengali': 'Contract termination date same as last working date',
      'Filipino':
          'Contract termination date is the same as my last working date',
      'Tamil': 'Contract termination date is the same as my last working date',
    },
    'eosb_date_of_leaving_same_as_last': {
      'English': 'Date of leaving work is the same as my last working date',
      'Arabic': 'تاريخ مغادرة العمل هو نفس آخر يوم عمل',
      'Hindi': 'Date of leaving same as last working date',
      'Urdu': 'Date of leaving same as last working date',
      'Malayalam': 'Date of leaving work is the same as my last working date',
      'Nepali': 'Date of leaving work is the same as my last working date',
      'Bengali': 'Date of leaving same as last working date',
      'Filipino': 'Date of leaving work is the same as my last working date',
      'Tamil': 'Date of leaving work is the same as my last working date',
    },
    'eosb_return_ticket_contract': {
      'English': 'Return ticket in contract',
      'Arabic': 'تذكرة العودة في العقد',
      'Hindi': 'Return ticket in contract',
      'Urdu': 'Return ticket in contract',
      'Malayalam': 'Return ticket in contract',
      'Nepali': 'Return ticket in contract',
      'Bengali': 'Return ticket in contract',
      'Filipino': 'Return ticket in contract',
      'Tamil': 'ஒப்பந்தத்தில் திரும்பும் டிக்கெட்',
    },
    'eosb_validation_basic_salary': {
      'English': 'Please enter your basic salary',
      'Arabic': 'يرجى إدخال الراتب الأساسي',
      'Hindi': 'Enter basic salary',
      'Urdu': 'Enter basic salary',
      'Malayalam': 'Please enter your basic salary',
      'Nepali': 'Please enter your basic salary',
      'Bengali': 'Enter basic salary',
      'Filipino': 'Please enter your basic salary',
      'Tamil': 'உங்கள் அடிப்படை சம்பளத்தை உள்ளிடவும்',
    },
    'eosb_validation_dates': {
      'English': 'Please select joining and last working dates',
      'Arabic': 'يرجى اختيار تاريخ الالتحاق وآخر يوم عمل',
      'Hindi': 'Select joining and last working dates',
      'Urdu': 'Select joining and last working dates',
      'Malayalam': 'Please select joining and last working dates',
      'Nepali': 'Please select joining and last working dates',
      'Bengali': 'Select joining and last working dates',
      'Filipino': 'Please select joining and last working dates',
      'Tamil': 'சேரும் மற்றும் கடைசி வேலை தேதிகளைத் தேர்ந்தெடுக்கவும்',
    },
    'eosb_validation_date_order': {
      'English': 'Last working date must be after joining date',
      'Arabic': 'يجب أن يكون آخر يوم عمل بعد تاريخ الالتحاق',
      'Hindi': 'Last day must be after joining',
      'Urdu': 'Last day must be after joining',
      'Malayalam': 'Last working date must be after joining date',
      'Nepali': 'Last working date must be after joining date',
      'Bengali': 'Last day must be after joining',
      'Filipino': 'Last working date must be after joining date',
      'Tamil': 'கடைசி வேலை தேதி சேரும் தேதிக்குப் பிறகு இருக்க வேண்டும்',
    },
    'eosb_load_error': {
      'English': 'Could not load EOSB calculator',
      'Arabic': 'تعذر تحميل حاسبة مكافأة نهاية الخدمة',
      'Hindi': 'Could not load calculator',
      'Urdu': 'Could not load calculator',
      'Malayalam': 'Could not load EOSB calculator',
      'Nepali': 'Could not load EOSB calculator',
      'Bengali': 'Could not load calculator',
      'Filipino': 'Could not load EOSB calculator',
      'Tamil': 'EOSB கணக்கிடியை ஏற்ற முடியவில்லை',
    },
    'ot_section_identity': {
      'English': 'Identity',
      'Arabic': 'الهوية',
      'Hindi': 'Identity',
      'Urdu': 'Identity',
      'Malayalam': 'Identity',
      'Nepali': 'Identity',
      'Bengali': 'Identity',
      'Filipino': 'Identity',
      'Tamil': 'அடையாளம்',
    },
    'ot_section_identity_sub': {
      'English': 'Name, ID, and role',
      'Arabic': 'الاسم والرقم والدور',
      'Hindi': 'Name, ID, role',
      'Urdu': 'Name, ID, role',
      'Malayalam': 'Name, ID, and role',
      'Nepali': 'Name, ID, and role',
      'Bengali': 'Name, ID, role',
      'Filipino': 'Name, ID, and role',
      'Tamil': 'பெயர், ID, பங்கு',
    },
    'ot_section_jurisdiction': {
      'English': 'Jurisdiction',
      'Arabic': 'الاختصاص',
      'Hindi': 'Jurisdiction',
      'Urdu': 'Jurisdiction',
      'Malayalam': 'Jurisdiction',
      'Nepali': 'Jurisdiction',
      'Bengali': 'Jurisdiction',
      'Filipino': 'Jurisdiction',
      'Tamil': 'அதிகார வரம்பு',
    },
    'ot_section_jurisdiction_sub': {
      'English': 'Country rules for overtime rates',
      'Arabic': 'قواعد البلد لأسعار العمل الإضافي',
      'Hindi': 'Country OT rules',
      'Urdu': 'Country OT rules',
      'Malayalam': 'Country rules for overtime rates',
      'Nepali': 'Country rules for overtime rates',
      'Bengali': 'Country OT rules',
      'Filipino': 'Country rules for overtime rates',
      'Tamil': 'கூடுதல் நேர விகிதங்களுக்கான நாட்டு விதிகள்',
    },
    'ot_section_compensation': {
      'English': 'Compensation & schedule',
      'Arabic': 'التعويض والجدول',
      'Hindi': 'Compensation & schedule',
      'Urdu': 'Compensation & schedule',
      'Malayalam': 'Compensation & schedule',
      'Nepali': 'Compensation & schedule',
      'Bengali': 'Compensation & schedule',
      'Filipino': 'Compensation & schedule',
      'Tamil': 'இழப்பீடு & அட்டவணை',
    },
    'ot_section_compensation_sub': {
      'English': 'Salary and working pattern',
      'Arabic': 'الراتب ونمط العمل',
      'Hindi': 'Salary and schedule',
      'Urdu': 'Salary and schedule',
      'Malayalam': 'Salary and working pattern',
      'Nepali': 'Salary and working pattern',
      'Bengali': 'Salary and schedule',
      'Filipino': 'Salary and working pattern',
      'Tamil': 'சம்பளம் மற்றும் வேலை முறை',
    },
    'ot_employment_type': {
      'English': 'Employment type',
      'Arabic': 'نوع التوظيف',
      'Hindi': 'Employment type',
      'Urdu': 'Employment type',
      'Malayalam': 'Employment type',
      'Nepali': 'Employment type',
      'Bengali': 'Employment type',
      'Filipino': 'Employment type',
      'Tamil': 'வேலை வகை',
    },
    'ot_joining_date': {
      'English': 'Joining date',
      'Arabic': 'تاريخ الالتحاق',
      'Hindi': 'Joining date',
      'Urdu': 'Joining date',
      'Malayalam': 'Joining date',
      'Nepali': 'Joining date',
      'Bengali': 'Joining date',
      'Filipino': 'Joining date',
      'Tamil': 'சேரும் தேதி',
    },
    'ot_shift_type_label': {
      'English': 'Shift type',
      'Arabic': 'نوع الوردية',
      'Hindi': 'Shift type',
      'Urdu': 'Shift type',
      'Malayalam': 'Shift type',
      'Nepali': 'Shift type',
      'Bengali': 'Shift type',
      'Filipino': 'Shift type',
      'Tamil': 'Shift வகை',
    },
    'ot_shift_normal': {
      'English': 'Normal',
      'Arabic': 'عادي',
      'Hindi': 'Normal',
      'Urdu': 'Normal',
      'Malayalam': 'Normal',
      'Nepali': 'Normal',
      'Bengali': 'Normal',
      'Filipino': 'Normal',
      'Tamil': 'சாதாரண',
    },
    'ot_shift_night': {
      'English': 'Night',
      'Arabic': 'ليلي',
      'Hindi': 'Night',
      'Urdu': 'Night',
      'Malayalam': 'Night',
      'Nepali': 'Night',
      'Bengali': 'Night',
      'Filipino': 'Night',
      'Tamil': 'இரவு',
    },
    'ot_confidence_explainer_title': {
      'English': 'How confidence is calculated',
      'Arabic': 'كيف يُحسب مستوى الثقة',
      'Hindi': 'How confidence works',
      'Urdu': 'How confidence works',
      'Malayalam': 'How confidence is calculated',
      'Nepali': 'How confidence is calculated',
      'Bengali': 'How confidence works',
      'Filipino': 'How confidence is calculated',
      'Tamil': 'நம்பிக்கை எப்படி கணக்கிடப்படுகிறது',
    },
    'ot_confidence_explainer_body': {
      'English': 'Based on completeness of salary, hours, and employer data.',
      'Arabic': 'يعتمد على اكتمال بيانات الراتب والساعات وصاحب العمل.',
      'Hindi': 'Based on data completeness.',
      'Urdu': 'Based on data completeness.',
      'Malayalam': 'Based on completeness of salary, hours, and employer data.',
      'Nepali': 'Based on completeness of salary, hours, and employer data.',
      'Bengali': 'Based on data completeness.',
      'Filipino': 'Based on completeness of salary, hours, and employer data.',
      'Tamil': 'சம்பளம், மணி, முதலாளி தரவின் முழுமையின் அடிப்படையில்.',
    },
    'ot_confidence_explainer_empty': {
      'English': 'Add salary and overtime hours to improve confidence.',
      'Arabic': 'أضف الراتب وساعات العمل الإضافي لرفع الثقة.',
      'Hindi': 'Add salary and hours.',
      'Urdu': 'Add salary and hours.',
      'Malayalam': 'Add salary and overtime hours to improve confidence.',
      'Nepali': 'Add salary and overtime hours to improve confidence.',
      'Bengali': 'Add salary and hours.',
      'Filipino': 'Add salary and overtime hours to improve confidence.',
      'Tamil':
          'நம்பிக்கையை மேம்படுத்த சம்பளம் மற்றும் கூடுதல் நேர மணியைச் சேர்க்கவும்.',
    },
    'ot_conf_factor_salary': {
      'English': 'Basic salary provided',
      'Arabic': 'تم إدخال الراتب الأساسي',
      'Hindi': 'Basic salary entered',
      'Urdu': 'Basic salary entered',
      'Malayalam': 'Basic salary provided',
      'Nepali': 'Basic salary provided',
      'Bengali': 'Basic salary entered',
      'Filipino': 'Basic salary provided',
      'Tamil': 'அடிப்படை சம்பளம் வழங்கப்பட்டது',
    },
    'ot_conf_factor_name': {
      'English': 'Employee profile filled',
      'Arabic': 'تم تعبئة ملف الموظف',
      'Hindi': 'Profile filled',
      'Urdu': 'Profile filled',
      'Malayalam': 'Employee profile filled',
      'Nepali': 'Employee profile filled',
      'Bengali': 'Profile filled',
      'Filipino': 'Employee profile filled',
      'Tamil': 'தொழிலாளர் சுயவிவரம் நிரப்பப்பட்டது',
    },
    'ot_conf_factor_hours': {
      'English': 'Overtime hours logged',
      'Arabic': 'تم تسجيل ساعات إضافية',
      'Hindi': 'OT hours logged',
      'Urdu': 'OT hours logged',
      'Malayalam': 'Overtime hours logged',
      'Nepali': 'Overtime hours logged',
      'Bengali': 'OT hours logged',
      'Filipino': 'Overtime hours logged',
      'Tamil': 'கூடுதல் நேர மணி பதிவு செய்யப்பட்டது',
    },
    'ot_conf_factor_employer': {
      'English': 'Employer payment entered for comparison',
      'Arabic': 'تم إدخال دفع صاحب العمل للمقارنة',
      'Hindi': 'Employer payment entered',
      'Urdu': 'Employer payment entered',
      'Malayalam': 'Employer payment entered for comparison',
      'Nepali': 'Employer payment entered for comparison',
      'Bengali': 'Employer payment entered',
      'Filipino': 'Employer payment entered for comparison',
      'Tamil': 'ஒப்பீட்டுக்கு முதலாளி கட்டணம் நுழைக்கப்பட்டது',
    },
    'ot_conf_factor_categories': {
      'English': 'Multiple overtime categories detected',
      'Arabic': 'تم رصد فئات عمل إضافي متعددة',
      'Hindi': 'Multiple OT categories',
      'Urdu': 'Multiple OT categories',
      'Malayalam': 'Multiple overtime categories detected',
      'Nepali': 'Multiple overtime categories detected',
      'Bengali': 'Multiple OT categories',
      'Filipino': 'Multiple overtime categories detected',
      'Tamil': 'பல கூடுதல் நேர வகைகள் கண்டறியப்பட்டன',
    },
    'ot_conf_factor_validation': {
      'English': 'Validation issue may lower confidence',
      'Arabic': 'مشكلة تحقق قد تخفض الثقة',
      'Hindi': 'Validation issue noted',
      'Urdu': 'Validation issue noted',
      'Malayalam': 'Validation issue may lower confidence',
      'Nepali': 'Validation issue may lower confidence',
      'Bengali': 'Validation issue noted',
      'Filipino': 'Validation issue may lower confidence',
      'Tamil': 'சரிபார்ப்பு சிக்கல் நம்பிக்கையை குறைக்கலாம்',
    },
    'ot_confidence_tap_hint': {
      'English': 'Tap to see how confidence is calculated',
      'Arabic': 'اضغط لمعرفة كيفية حساب الثقة',
      'Hindi': 'Tap for confidence details',
      'Urdu': 'Tap for confidence details',
      'Malayalam': 'Tap to see how confidence is calculated',
      'Nepali': 'Tap to see how confidence is calculated',
      'Bengali': 'Tap for confidence details',
      'Filipino': 'Tap to see how confidence is calculated',
      'Tamil':
          'நம்பிக்கை எப்படி கணக்கிடப்படுகிறது என்பதைப் பார்க்க tap செய்யுங்கள்',
    },
    'eosb_scenario_breakdown': {
      'English': 'Entitlement breakdown',
      'Arabic': 'تفصيل المستحقات',
      'Hindi': 'Breakdown',
      'Urdu': 'Breakdown',
      'Malayalam': 'Entitlement breakdown',
      'Nepali': 'Entitlement breakdown',
      'Bengali': 'Breakdown',
      'Filipino': 'Entitlement breakdown',
      'Tamil': 'உரிமை பிரிவினை',
    },
    'eosb_scenario_tap_expand': {
      'English': 'Tap to expand breakdown',
      'Arabic': 'اضغط لعرض التفصيل',
      'Hindi': 'Tap to expand',
      'Urdu': 'Tap to expand',
      'Malayalam': 'Tap to expand breakdown',
      'Nepali': 'Tap to expand breakdown',
      'Bengali': 'Tap to expand',
      'Filipino': 'Tap to expand breakdown',
      'Tamil': 'பிரிவினையை expand செய்ய tap செய்யுங்கள்',
    },
    'ot_rule_label': {
      'English': 'Labour rule',
      'Arabic': 'القاعدة القانونية',
      'Hindi': 'Labour rule',
      'Urdu': 'Labour rule',
      'Malayalam': 'Labour rule',
      'Nepali': 'Labour rule',
      'Bengali': 'Labour rule',
      'Filipino': 'Labour rule',
      'Tamil': 'தொழிலாளர் விதி',
    },
    'ot_law_reference': {
      'English': 'Legal reference',
      'Arabic': 'المرجع القانوني',
      'Hindi': 'Legal reference',
      'Urdu': 'Legal reference',
      'Malayalam': 'Legal reference',
      'Nepali': 'Legal reference',
      'Bengali': 'Legal reference',
      'Filipino': 'Legal reference',
      'Tamil': 'சட்ட குறிப்பு',
    },
    'ot_country_preview': {
      'English': 'Preview',
      'Arabic': 'معاينة',
      'Hindi': 'Preview',
      'Urdu': 'Preview',
      'Malayalam': 'Preview',
      'Nepali': 'Preview',
      'Bengali': 'Preview',
      'Filipino': 'Preview',
      'Tamil': 'முன்னோட்டம்',
    },
    'ot_country_preview_note': {
      'English':
          'Rates for this country are not yet verified — Qatar rules used as placeholder.',
      'Arabic': 'الأسعار غير م verified بعد — قواعد قطر مؤقتة.',
      'Hindi': 'Rates not verified yet — placeholder rules.',
      'Urdu': 'Rates not verified yet — placeholder rules.',
      'Malayalam':
          'Rates for this country are not yet verified — Qatar rules used as placeholder.',
      'Nepali':
          'Rates for this country are not yet verified — Qatar rules used as placeholder.',
      'Bengali': 'Rates not verified yet — placeholder rules.',
      'Filipino':
          'Rates for this country are not yet verified — Qatar rules used as placeholder.',
      'Tamil':
          'இந்த நாட்டின் விகிதங்கள் இன்னும் சரிபார்க்கப்படவில்லை — Qatar விதிகள் placeholder-ஆக பயன்படுத்தப்படுகின்றன.',
    },
    'ot_alert_no_overtime': {
      'English': 'No overtime hours detected',
      'Arabic': 'لم يُ detected عمل إضافي',
      'Hindi': 'No OT detected',
      'Urdu': 'No OT detected',
      'Malayalam': 'No overtime hours detected',
      'Nepali': 'No overtime hours detected',
      'Bengali': 'No OT detected',
      'Filipino': 'No overtime hours detected',
      'Tamil': 'கூடுதல் நேர மணி கண்டறியப்படவில்லை',
    },
    'ot_alert_no_overtime_body': {
      'English':
          'Based on your inputs, no extra hours beyond the standard schedule were found.',
      'Arabic': 'لا ساعات إضافية beyond الجدول.',
      'Hindi': 'No extra hours found.',
      'Urdu': 'No extra hours found.',
      'Malayalam':
          'Based on your inputs, no extra hours beyond the standard schedule were found.',
      'Nepali':
          'Based on your inputs, no extra hours beyond the standard schedule were found.',
      'Bengali': 'No extra hours found.',
      'Filipino':
          'Based on your inputs, no extra hours beyond the standard schedule were found.',
      'Tamil':
          'உங்கள் உள்ளீட்டின் அடிப்படையில், standard அட்டவணைக்கு அப்பால் கூடுதல் மணி கண்டறியப்படவில்லை.',
    },
    'ot_report_title': {
      'English': 'Qatar Overtime Truth Report',
      'Arabic': 'تقرير العمل الإضافي',
      'Hindi': 'Overtime Report',
      'Urdu': 'Overtime Report',
      'Malayalam': 'Qatar Overtime Truth Report',
      'Nepali': 'Qatar Overtime Truth Report',
      'Bengali': 'Overtime Report',
      'Filipino': 'Qatar Overtime Truth Report',
      'Tamil': 'Qatar கூடுதல் நேர வேலை உண்மை அறிக்கை',
    },
    'ot_report_footer': {
      'English':
          'Generated by Raabta EOSB Truth Engine. Informational only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      'Arabic':
          'Raabta — ليس استشارة قانونية. للنزاعات: ADLSA 16008 (24/7)، بوابة الشكاوى الموحدة mol.gov.qa (NAS)، SMS: 5 + الهوية إلى 92727',
      'Hindi':
          'Not legal advice. Disputes: ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727.',
      'Urdu':
          'Not legal advice. Disputes: ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727.',
      'Malayalam':
          'Generated by Raabta EOSB Truth Engine. Informational only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      'Nepali':
          'Generated by Raabta EOSB Truth Engine. Informational only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      'Bengali':
          'Not legal advice. Disputes: ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727.',
      'Filipino':
          'Generated by Raabta EOSB Truth Engine. Informational only — not legal advice. Disputes: ADLSA 16008 (24/7), Unified Complaints Portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
      'Tamil':
          'Raabta EOSB உண்மை இயந்திரத்தால் உருவாக்கப்பட்டது. தகவல் மட்டும் — சட்ட ஆலோசனை அல்ல. தகராறுகள்: ADLSA 16008 (24/7), ஒருங்கிணைந்த புகார் portal mol.gov.qa (NAS login), SMS 5+QID to 92727.',
    },
    'ot_report_share': {
      'English': 'My Qatar overtime report from Raabta',
      'Arabic': 'تقرير العمل الإضافي',
      'Hindi': 'Overtime report',
      'Urdu': 'Overtime report',
      'Malayalam': 'My Qatar overtime report from Raabta',
      'Nepali': 'My Qatar overtime report from Raabta',
      'Bengali': 'Overtime report',
      'Filipino': 'My Qatar overtime report from Raabta',
      'Tamil': 'Raabta-விலிருந்து என் Qatar கூடுதல் நேர வேலை அறிக்கை',
    },
    'ot_empty_title': {
      'English': 'No overtime calculation yet',
      'Arabic': 'لا حساب بعد',
      'Hindi': 'No calculation',
      'Urdu': 'No calculation',
      'Malayalam': 'No overtime calculation yet',
      'Nepali': 'No overtime calculation yet',
      'Bengali': 'No calculation',
      'Filipino': 'No overtime calculation yet',
      'Tamil': 'இன்னும் கூடுதல் நேர கணக்கீடு இல்லை',
    },
    'ot_empty_desc': {
      'English': 'Enter your salary and hours to see what you should be paid.',
      'Arabic': 'أدخل راتبك وساعاتك',
      'Hindi': 'Enter salary and hours',
      'Urdu': 'Enter salary and hours',
      'Malayalam':
          'Enter your salary and hours to see what you should be paid.',
      'Nepali': 'Enter your salary and hours to see what you should be paid.',
      'Bengali': 'Enter salary and hours',
      'Filipino': 'Enter your salary and hours to see what you should be paid.',
      'Tamil':
          'எவ்வளவு செலுத்தப்பட வேண்டும் என்பதைப் பார்க்க சம்பளம் மற்றும் மணியை உள்ளிடவும்.',
    },
    'ot_total_ot_hours': {
      'English': 'Total overtime hours',
      'Arabic': 'إجمالي ساعات إضافية',
      'Hindi': 'Total OT hours',
      'Urdu': 'Total OT hours',
      'Malayalam': 'Total overtime hours',
      'Nepali': 'Total overtime hours',
      'Bengali': 'Total OT hours',
      'Filipino': 'Total overtime hours',
      'Tamil': 'மொத்த கூடுதல் நேர மணி',
    },
    'ot_standard_hours': {
      'English': 'Standard hours in period',
      'Arabic': 'ساعات العمل العادية',
      'Hindi': 'Standard hours',
      'Urdu': 'Standard hours',
      'Malayalam': 'Standard hours in period',
      'Nepali': 'Standard hours in period',
      'Bengali': 'Standard hours',
      'Filipino': 'Standard hours in period',
      'Tamil': 'காலத்தில் standard மணி',
    },
    'ot_monthly_estimate': {
      'English': 'Monthly estimated overtime',
      'Arabic': 'تقدير العمل الإضافي الشهري',
      'Hindi': 'Monthly OT estimate',
      'Urdu': 'Monthly OT estimate',
      'Malayalam': 'Monthly estimated overtime',
      'Nepali': 'Monthly estimated overtime',
      'Bengali': 'Monthly OT estimate',
      'Filipino': 'Monthly estimated overtime',
      'Tamil': 'மாதாந்திர மதிப்பிடப்பட்ட கூடுதல் நேர வேலை',
    },
    'ot_current_month': {
      'English': 'Current month',
      'Arabic': 'الشهر الحالي',
      'Hindi': 'Current month',
      'Urdu': 'Current month',
      'Malayalam': 'Current month',
      'Nepali': 'Current month',
      'Bengali': 'Current month',
      'Filipino': 'Current month',
      'Tamil': 'தற்போதைய மாதம்',
    },
    'ot_status_pending': {
      'English': 'Add calendar entries to calculate',
      'Arabic': 'أضف إدخالات التقويم',
      'Hindi': 'Add entries',
      'Urdu': 'Add entries',
      'Malayalam': 'Add calendar entries to calculate',
      'Nepali': 'Add calendar entries to calculate',
      'Bengali': 'Add entries',
      'Filipino': 'Add calendar entries to calculate',
      'Tamil': 'கணக்கிட காலண்டர் entries சேர்க்கவும்',
    },
    'ot_status_complete': {
      'English': 'Calculation ready',
      'Arabic': 'الحساب جاهز',
      'Hindi': 'Ready',
      'Urdu': 'Ready',
      'Malayalam': 'Calculation ready',
      'Nepali': 'Calculation ready',
      'Bengali': 'Ready',
      'Filipino': 'Calculation ready',
      'Tamil': 'கணக்கீடு தயார்',
    },
    'ot_quick_actions': {
      'English': 'Quick actions',
      'Arabic': 'إجراءات سريعة',
      'Hindi': 'Quick actions',
      'Urdu': 'Quick actions',
      'Malayalam': 'Quick actions',
      'Nepali': 'Quick actions',
      'Bengali': 'Quick actions',
      'Filipino': 'Quick actions',
      'Tamil': 'விரைவு செயல்கள்',
    },
    'ot_new_calc': {
      'English': 'New calculation',
      'Arabic': 'حساب جديد',
      'Hindi': 'New calc',
      'Urdu': 'New calc',
      'Malayalam': 'New calculation',
      'Nepali': 'New calculation',
      'Bengali': 'New calc',
      'Filipino': 'New calculation',
      'Tamil': 'புதிய கணக்கீடு',
    },
    'ot_history': {
      'English': 'Monthly history',
      'Arabic': 'السجل الشهري',
      'Hindi': 'History',
      'Urdu': 'History',
      'Malayalam': 'Monthly history',
      'Nepali': 'Monthly history',
      'Bengali': 'History',
      'Filipino': 'Monthly history',
      'Tamil': 'மாதாந்திர வரலாறு',
    },
    'ot_share_card': {
      'English': 'Share',
      'Arabic': 'مشاركة',
      'Hindi': 'Share',
      'Urdu': 'Share',
      'Malayalam': 'Share',
      'Nepali': 'Share',
      'Bengali': 'Share',
      'Filipino': 'Share',
      'Tamil': 'பகிர்',
    },
    'ot_ai_review': {
      'English': 'AI review',
      'Arabic': 'مراجعة الذكاء الاصطناعي',
      'Hindi': 'AI review',
      'Urdu': 'AI review',
      'Malayalam': 'AI review',
      'Nepali': 'AI review',
      'Bengali': 'AI review',
      'Filipino': 'AI review',
      'Tamil': 'AI மறுஆய்வு',
    },
    'ot_employee_info': {
      'English': 'Employee information',
      'Arabic': 'معلومات الموظف',
      'Hindi': 'Employee info',
      'Urdu': 'Employee info',
      'Malayalam': 'Employee information',
      'Nepali': 'Employee information',
      'Bengali': 'Employee info',
      'Filipino': 'Employee information',
      'Tamil': 'தொழிலாளர் தகவல்',
    },
    'ot_calendar_mode': {
      'English': 'Daily overtime calendar',
      'Arabic': 'تقويم العمل الإضافي اليومي',
      'Hindi': 'OT calendar',
      'Urdu': 'OT calendar',
      'Malayalam': 'Daily overtime calendar',
      'Nepali': 'Daily overtime calendar',
      'Bengali': 'OT calendar',
      'Filipino': 'Daily overtime calendar',
      'Tamil': 'தினசரி கூடுதல் நேர காலண்டர்',
    },
    'ot_import_docs': {
      'English': 'Import payslip / timesheet',
      'Arabic': 'استيراد قسيمة الراتب',
      'Hindi': 'Import docs',
      'Urdu': 'Import docs',
      'Malayalam': 'Import payslip / timesheet',
      'Nepali': 'Import payslip / timesheet',
      'Bengali': 'Import docs',
      'Filipino': 'Import payslip / timesheet',
      'Tamil': 'Payslip / timesheet import',
    },
    'ot_monthly_summary': {
      'English': 'Monthly summary',
      'Arabic': 'الملخص الشهري',
      'Hindi': 'Summary',
      'Urdu': 'Summary',
      'Malayalam': 'Monthly summary',
      'Nepali': 'Monthly summary',
      'Bengali': 'Summary',
      'Filipino': 'Monthly summary',
      'Tamil': 'மாதாந்திர சுருக்கம்',
    },
    'ot_emp_name': {
      'English': 'Employee name',
      'Arabic': 'اسم الموظف',
      'Hindi': 'Name',
      'Urdu': 'Name',
      'Malayalam': 'Employee name',
      'Nepali': 'Employee name',
      'Bengali': 'Name',
      'Filipino': 'Employee name',
      'Tamil': 'தொழிலாளர் பெயர்',
    },
    'ot_emp_id': {
      'English': 'Employee ID',
      'Arabic': 'رقم الموظف',
      'Hindi': 'ID',
      'Urdu': 'ID',
      'Malayalam': 'Employee ID',
      'Nepali': 'Employee ID',
      'Bengali': 'ID',
      'Filipino': 'Employee ID',
      'Tamil': 'தொழிலாளர் ID',
    },
    'ot_job_title': {
      'English': 'Job title',
      'Arabic': 'المسمى الوظيفي',
      'Hindi': 'Job title',
      'Urdu': 'Job title',
      'Malayalam': 'Job title',
      'Nepali': 'Job title',
      'Bengali': 'Job title',
      'Filipino': 'Job title',
      'Tamil': 'பணி பதவி',
    },
    'ot_project': {
      'English': 'Project',
      'Arabic': 'المشروع',
      'Hindi': 'Project',
      'Urdu': 'Project',
      'Malayalam': 'Project',
      'Nepali': 'Project',
      'Bengali': 'Project',
      'Filipino': 'Project',
      'Tamil': 'திட்டம்',
    },
    'ot_country': {
      'English': 'Country',
      'Arabic': 'الدولة',
      'Hindi': 'Country',
      'Urdu': 'Country',
      'Malayalam': 'Country',
      'Nepali': 'Country',
      'Bengali': 'Country',
      'Filipino': 'Country',
      'Tamil': 'நாடு',
    },
    'ot_total_salary': {
      'English': 'Total salary',
      'Arabic': 'الراتب الإجمالي',
      'Hindi': 'Total salary',
      'Urdu': 'Total salary',
      'Malayalam': 'Total salary',
      'Nepali': 'Total salary',
      'Bengali': 'Total salary',
      'Filipino': 'Total salary',
      'Tamil': 'மொத்த சம்பளம்',
    },
    'ot_hours_per_day': {
      'English': 'Working hours per day',
      'Arabic': 'ساعات العمل اليومية',
      'Hindi': 'Hours/day',
      'Urdu': 'Hours/day',
      'Malayalam': 'Working hours per day',
      'Nepali': 'Working hours per day',
      'Bengali': 'Hours/day',
      'Filipino': 'Working hours per day',
      'Tamil': 'நாளுக்கு வேலை மணி',
    },
    'ot_monthly_days': {
      'English': 'Monthly working days',
      'Arabic': 'أيام العمل الشهرية',
      'Hindi': 'Monthly days',
      'Urdu': 'Monthly days',
      'Malayalam': 'Monthly working days',
      'Nepali': 'Monthly working days',
      'Bengali': 'Monthly days',
      'Filipino': 'Monthly working days',
      'Tamil': 'மாதாந்திர வேலை நாட்கள்',
    },
    'ot_save_profile': {
      'English': 'Save profile',
      'Arabic': 'حفظ الملف',
      'Hindi': 'Save',
      'Urdu': 'Save',
      'Malayalam': 'Save profile',
      'Nepali': 'Save profile',
      'Bengali': 'Save',
      'Filipino': 'Save profile',
      'Tamil': 'சுயவிவரத்தை சேமி',
    },
    'ot_profile_saved': {
      'English': 'Employee profile saved',
      'Arabic': 'تم حفظ الملف',
      'Hindi': 'Saved',
      'Urdu': 'Saved',
      'Malayalam': 'Employee profile saved',
      'Nepali': 'Employee profile saved',
      'Bengali': 'Saved',
      'Filipino': 'Employee profile saved',
      'Tamil': 'தொழிலாளர் சுயவிவரம் சேமிக்கப்பட்டது',
    },
    'ot_day_category': {
      'English': 'Day category',
      'Arabic': 'نوع اليوم',
      'Hindi': 'Category',
      'Urdu': 'Category',
      'Malayalam': 'Day category',
      'Nepali': 'Day category',
      'Bengali': 'Category',
      'Filipino': 'Day category',
      'Tamil': 'நாள் வகை',
    },
    'ot_shift_type': {
      'English': 'Shift type',
      'Arabic': 'نوع الوردية',
      'Hindi': 'Shift',
      'Urdu': 'Shift',
      'Malayalam': 'Shift type',
      'Nepali': 'Shift type',
      'Bengali': 'Shift',
      'Filipino': 'Shift type',
      'Tamil': 'Shift வகை',
    },
    'ot_hours': {
      'English': 'Hours',
      'Arabic': 'ساعات',
      'Hindi': 'Hours',
      'Urdu': 'Hours',
      'Malayalam': 'Hours',
      'Nepali': 'Hours',
      'Bengali': 'Hours',
      'Filipino': 'Hours',
      'Tamil': 'மணி',
    },
    'ot_minutes': {
      'English': 'Minutes',
      'Arabic': 'دقائق',
      'Hindi': 'Minutes',
      'Urdu': 'Minutes',
      'Malayalam': 'Minutes',
      'Nepali': 'Minutes',
      'Bengali': 'Minutes',
      'Filipino': 'Minutes',
      'Tamil': 'நிமிடங்கள்',
    },
    'ot_holiday_name': {
      'English': 'Holiday name',
      'Arabic': 'اسم العطلة',
      'Hindi': 'Holiday',
      'Urdu': 'Holiday',
      'Malayalam': 'Holiday name',
      'Nepali': 'Holiday name',
      'Bengali': 'Holiday',
      'Filipino': 'Holiday name',
      'Tamil': 'விடுமுறை பெயர்',
    },
    'ot_notes': {
      'English': 'Notes',
      'Arabic': 'ملاحظات',
      'Hindi': 'Notes',
      'Urdu': 'Notes',
      'Malayalam': 'Notes',
      'Nepali': 'Notes',
      'Bengali': 'Notes',
      'Filipino': 'Notes',
      'Tamil': 'குறிப்புகள்',
    },
    'ot_save_day': {
      'English': 'Save day',
      'Arabic': 'حفظ اليوم',
      'Hindi': 'Save',
      'Urdu': 'Save',
      'Malayalam': 'Save day',
      'Nepali': 'Save day',
      'Bengali': 'Save',
      'Filipino': 'Save day',
      'Tamil': 'நாளை சேமி',
    },
    'ot_no_overtime': {
      'English': 'No OT',
      'Arabic': 'لا إضافي',
      'Hindi': 'No OT',
      'Urdu': 'No OT',
      'Malayalam': 'No OT',
      'Nepali': 'No OT',
      'Bengali': 'No OT',
      'Filipino': 'No OT',
      'Tamil': 'OT இல்லை',
    },
    'ot_chart_categories': {
      'English': 'Overtime categories',
      'Arabic': 'فئات العمل الإضافي',
      'Hindi': 'Categories',
      'Urdu': 'Categories',
      'Malayalam': 'Overtime categories',
      'Nepali': 'Overtime categories',
      'Bengali': 'Categories',
      'Filipino': 'Overtime categories',
      'Tamil': 'கூடுதல் நேர வகைகள்',
    },
    'ot_chart_daily': {
      'English': 'Daily trend',
      'Arabic': 'الاتجاه اليومي',
      'Hindi': 'Daily trend',
      'Urdu': 'Daily trend',
      'Malayalam': 'Daily trend',
      'Nepali': 'Daily trend',
      'Bengali': 'Daily trend',
      'Filipino': 'Daily trend',
      'Tamil': 'தினசரி trend',
    },
    'ot_avg_daily': {
      'English': 'Avg daily OT',
      'Arabic': 'متوسط يومي',
      'Hindi': 'Avg daily',
      'Urdu': 'Avg daily',
      'Malayalam': 'Avg daily OT',
      'Nepali': 'Avg daily OT',
      'Bengali': 'Avg daily',
      'Filipino': 'Avg daily OT',
      'Tamil': 'சராசரி தினசரி OT',
    },
    'ot_days_recorded': {
      'English': 'Days recorded',
      'Arabic': 'أيام مسجلة',
      'Hindi': 'Recorded',
      'Urdu': 'Recorded',
      'Malayalam': 'Days recorded',
      'Nepali': 'Days recorded',
      'Bengali': 'Recorded',
      'Filipino': 'Days recorded',
      'Tamil': 'பதிவு செய்யப்பட்ட நாட்கள்',
    },
    'ot_missing_days': {
      'English': 'Missing days',
      'Arabic': 'أيام مفقودة',
      'Hindi': 'Missing',
      'Urdu': 'Missing',
      'Malayalam': 'Missing days',
      'Nepali': 'Missing days',
      'Bengali': 'Missing',
      'Filipino': 'Missing days',
      'Tamil': 'காணாமல் போன நாட்கள்',
    },
    'ot_highest_day': {
      'English': 'Highest day',
      'Arabic': 'أعلى يوم',
      'Hindi': 'Highest',
      'Urdu': 'Highest',
      'Malayalam': 'Highest day',
      'Nepali': 'Highest day',
      'Bengali': 'Highest',
      'Filipino': 'Highest day',
      'Tamil': 'அதிகபட்ச நாள்',
    },
    'ot_rate_breakdown': {
      'English': 'Hourly rate calculation',
      'Arabic': 'حساب الأجر بالساعة',
      'Hindi': 'Rate breakdown',
      'Urdu': 'Rate breakdown',
      'Malayalam': 'Hourly rate calculation',
      'Nepali': 'Hourly rate calculation',
      'Bengali': 'Rate breakdown',
      'Filipino': 'Hourly rate calculation',
      'Tamil': 'மணி விகித கணக்கீடு',
    },
    'ot_search': {
      'English': 'Search months, companies, projects…',
      'Arabic': 'بحث…',
      'Hindi': 'Search…',
      'Urdu': 'Search…',
      'Malayalam': 'Search months, companies, projects…',
      'Nepali': 'Search months, companies, projects…',
      'Bengali': 'Search…',
      'Filipino': 'Search months, companies, projects…',
      'Tamil': 'மாதங்கள், நிறுவனங்கள், திட்டங்கள் தேடுங்கள்…',
    },
    'ot_history_empty': {
      'English': 'No saved months yet',
      'Arabic': 'لا سجل بعد',
      'Hindi': 'No history',
      'Urdu': 'No history',
      'Malayalam': 'No saved months yet',
      'Nepali': 'No saved months yet',
      'Bengali': 'No history',
      'Filipino': 'No saved months yet',
      'Tamil': 'இன்னும் சேமிக்கப்பட்ட மாதங்கள் இல்லை',
    },
    'ot_history_empty_desc': {
      'English': 'Save a calendar month to compare overtime over time.',
      'Arabic': 'احفظ شهراً للمقارنة',
      'Hindi': 'Save a month',
      'Urdu': 'Save a month',
      'Malayalam': 'Save a calendar month to compare overtime over time.',
      'Nepali': 'Save a calendar month to compare overtime over time.',
      'Bengali': 'Save a month',
      'Filipino': 'Save a calendar month to compare overtime over time.',
      'Tamil':
          'காலப்போக்கில் கூடுதல் நேர வேலையை ஒப்பிட ஒரு காலண்டர் மாதத்தை சேமிக்கவும்.',
    },
    'ot_no_company': {
      'English': 'No company',
      'Arabic': 'بدون شركة',
      'Hindi': 'No company',
      'Urdu': 'No company',
      'Malayalam': 'No company',
      'Nepali': 'No company',
      'Bengali': 'No company',
      'Filipino': 'No company',
      'Tamil': 'நிறுவனம் இல்லை',
    },
    'ot_duplicate': {
      'English': 'Duplicate',
      'Arabic': 'نسخ',
      'Hindi': 'Duplicate',
      'Urdu': 'Duplicate',
      'Malayalam': 'Duplicate',
      'Nepali': 'Duplicate',
      'Bengali': 'Duplicate',
      'Filipino': 'Duplicate',
      'Tamil': 'Duplicate',
    },
    'ot_delete': {
      'English': 'Delete',
      'Arabic': 'حذف',
      'Hindi': 'Delete',
      'Urdu': 'Delete',
      'Malayalam': 'Delete',
      'Nepali': 'Delete',
      'Bengali': 'Delete',
      'Filipino': 'Delete',
      'Tamil': 'நீக்கு',
    },
    'ot_ai_summary': {
      'English': 'AI summary',
      'Arabic': 'ملخص الذكاء الاصطناعي',
      'Hindi': 'Summary',
      'Urdu': 'Summary',
      'Malayalam': 'AI summary',
      'Nepali': 'AI summary',
      'Bengali': 'Summary',
      'Filipino': 'AI summary',
      'Tamil': 'AI சுருக்கம்',
    },
    'ot_ai_calc_explain': {
      'English': 'Calculation explanation',
      'Arabic': 'شرح الحساب',
      'Hindi': 'Explanation',
      'Urdu': 'Explanation',
      'Malayalam': 'Calculation explanation',
      'Nepali': 'Calculation explanation',
      'Bengali': 'Explanation',
      'Filipino': 'Calculation explanation',
      'Tamil': 'கணக்கீட்டு விளக்கம்',
    },
    'ot_ai_missing': {
      'English': 'Possible missing payments',
      'Arabic': 'مدفوعات محتملة مفقودة',
      'Hindi': 'Missing payments',
      'Urdu': 'Missing payments',
      'Malayalam': 'Possible missing payments',
      'Nepali': 'Possible missing payments',
      'Bengali': 'Missing payments',
      'Filipino': 'Possible missing payments',
      'Tamil': 'சாத்தியமான காணாமல் போன கட்டணங்கள்',
    },
    'ot_ai_errors': {
      'English': 'Potential errors',
      'Arabic': 'أخطاء محتملة',
      'Hindi': 'Errors',
      'Urdu': 'Errors',
      'Malayalam': 'Potential errors',
      'Nepali': 'Potential errors',
      'Bengali': 'Errors',
      'Filipino': 'Potential errors',
      'Tamil': 'சாத்தியமான பிழைகள்',
    },
    'ot_ai_questions': {
      'English': 'Questions for employer',
      'Arabic': 'أسئلة للشركة',
      'Hindi': 'Questions',
      'Urdu': 'Questions',
      'Malayalam': 'Questions for employer',
      'Nepali': 'Questions for employer',
      'Bengali': 'Questions',
      'Filipino': 'Questions for employer',
      'Tamil': 'முதலாளிக்கான கேள்விகள்',
    },
    'ot_ai_tips': {
      'English': 'Payroll review tips',
      'Arabic': 'نصائح مراجعة الرواتب',
      'Hindi': 'Tips',
      'Urdu': 'Tips',
      'Malayalam': 'Payroll review tips',
      'Nepali': 'Payroll review tips',
      'Bengali': 'Tips',
      'Filipino': 'Payroll review tips',
      'Tamil': 'Payroll மறுஆய்வு tips',
    },
    'ot_ai_next': {
      'English': 'Suggested next steps',
      'Arabic': 'الخطوات التالية',
      'Hindi': 'Next steps',
      'Urdu': 'Next steps',
      'Malayalam': 'Suggested next steps',
      'Nepali': 'Suggested next steps',
      'Bengali': 'Next steps',
      'Filipino': 'Suggested next steps',
      'Tamil': 'பரிந்துரைக்கப்பட்ட அடுத்த படிகள்',
    },
    'ot_ai_refresh': {
      'English': 'Refresh AI review',
      'Arabic': 'تحديث المراجعة',
      'Hindi': 'Refresh',
      'Urdu': 'Refresh',
      'Malayalam': 'Refresh AI review',
      'Nepali': 'Refresh AI review',
      'Bengali': 'Refresh',
      'Filipino': 'Refresh AI review',
      'Tamil': 'AI மறுஆய்வை refresh',
    },
    'ot_import_desc': {
      'English':
          'Scan or paste payslip, timesheet, or attendance data. Review extracted values before saving.',
      'Arabic': 'امسح أو الصق بيانات الراتب',
      'Hindi': 'Import payroll docs',
      'Urdu': 'Import payroll docs',
      'Malayalam':
          'Scan or paste payslip, timesheet, or attendance data. Review extracted values before saving.',
      'Nepali':
          'Scan or paste payslip, timesheet, or attendance data. Review extracted values before saving.',
      'Bengali': 'Import payroll docs',
      'Filipino':
          'Scan or paste payslip, timesheet, or attendance data. Review extracted values before saving.',
      'Tamil':
          'Payslip, timesheet, அல்லது attendance தரவை scan அல்லது paste செய்யுங்கள். சேமிப்பதற்கு முன் extracted மதிப்புகளை மறுஆய்வு செய்யுங்கள்.',
    },
    'ot_doc_type': {
      'English': 'Document type',
      'Arabic': 'نوع المستند',
      'Hindi': 'Doc type',
      'Urdu': 'Doc type',
      'Malayalam': 'Document type',
      'Nepali': 'Document type',
      'Bengali': 'Doc type',
      'Filipino': 'Document type',
      'Tamil': 'ஆவண வகை',
    },
    'ot_import_paste': {
      'English': 'Paste OCR text from payslip or timesheet…',
      'Arabic': 'الصق نص المستند…',
      'Hindi': 'Paste text…',
      'Urdu': 'Paste text…',
      'Malayalam': 'Paste OCR text from payslip or timesheet…',
      'Nepali': 'Paste OCR text from payslip or timesheet…',
      'Bengali': 'Paste text…',
      'Filipino': 'Paste OCR text from payslip or timesheet…',
      'Tamil': 'Payslip அல்லது timesheet-லிருந்து OCR உரை paste செய்யுங்கள்…',
    },
    'ot_import_analyze': {
      'English': 'Extract & apply',
      'Arabic': 'استخراج وتطبيق',
      'Hindi': 'Extract',
      'Urdu': 'Extract',
      'Malayalam': 'Extract & apply',
      'Nepali': 'Extract & apply',
      'Bengali': 'Extract',
      'Filipino': 'Extract & apply',
      'Tamil': 'Extract & apply',
    },
    'ot_import_text_short': {
      'English': 'Enter at least 20 characters of document text',
      'Arabic': 'أدخل 20 حرفاً على الأقل',
      'Hindi': 'Text too short',
      'Urdu': 'Text too short',
      'Malayalam': 'Enter at least 20 characters of document text',
      'Nepali': 'Enter at least 20 characters of document text',
      'Bengali': 'Text too short',
      'Filipino': 'Enter at least 20 characters of document text',
      'Tamil': 'குறைந்தது 20 எழுத்துகள் ஆவண உரையை உள்ளிடவும்',
    },
    'ot_import_applied': {
      'English': 'Document data applied — please review calendar entries',
      'Arabic': 'تم التطبيق — راجع التقويم',
      'Hindi': 'Applied',
      'Urdu': 'Applied',
      'Malayalam': 'Document data applied — please review calendar entries',
      'Nepali': 'Document data applied — please review calendar entries',
      'Bengali': 'Applied',
      'Filipino': 'Document data applied — please review calendar entries',
      'Tamil':
          'ஆவண தரவு பயன்படுத்தப்பட்டது — காலண்டர் entries-ஐ மறுஆய்வு செய்யுங்கள்',
    },
    'ot_cat_night': {
      'English': 'Night shift',
      'Arabic': 'وردية ليلية',
      'Hindi': 'Night',
      'Urdu': 'Night',
      'Malayalam': 'Night shift',
      'Nepali': 'Night shift',
      'Bengali': 'Night',
      'Filipino': 'Night shift',
      'Tamil': 'இரவு shift',
    },
    'ot_cat_emergency': {
      'English': 'Emergency call-out',
      'Arabic': 'استدعاء طارئ',
      'Hindi': 'Emergency',
      'Urdu': 'Emergency',
      'Malayalam': 'Emergency call-out',
      'Nepali': 'Emergency call-out',
      'Bengali': 'Emergency',
      'Filipino': 'Emergency call-out',
      'Tamil': 'Emergency call-out',
    },
    'ot_cat_standby': {
      'English': 'Standby hours',
      'Arabic': 'ساعات الاستعداد',
      'Hindi': 'Standby',
      'Urdu': 'Standby',
      'Malayalam': 'Standby hours',
      'Nepali': 'Standby hours',
      'Bengali': 'Standby',
      'Filipino': 'Standby hours',
      'Tamil': 'Standby மணி',
    },
    'ot_cat_custom': {
      'English': 'Custom category',
      'Arabic': 'فئة مخصصة',
      'Hindi': 'Custom',
      'Urdu': 'Custom',
      'Malayalam': 'Custom category',
      'Nepali': 'Custom category',
      'Bengali': 'Custom',
      'Filipino': 'Custom category',
      'Tamil': 'Custom வகை',
    },
    'ot_comparison_note': {
      'English':
          'Differences may arise from contract terms, approved records, or labour rules.',
      'Arabic': 'قد تختلف بسبب العقد أو السجلات المعتمدة',
      'Hindi': 'Differences may vary',
      'Urdu': 'Differences may vary',
      'Malayalam':
          'Differences may arise from contract terms, approved records, or labour rules.',
      'Nepali':
          'Differences may arise from contract terms, approved records, or labour rules.',
      'Bengali': 'Differences may vary',
      'Filipino':
          'Differences may arise from contract terms, approved records, or labour rules.',
      'Tamil':
          'ஒப்பந்த விதிமுறைகள், அங்கீகரிக்கப்பட்ட பதிவுகள், அல்லது தொழிலாளர் விதிகளால் வித்தியாசங்கள் ஏற்படலாம்.',
    },
    'ot_alert_overpaid': {
      'English': 'Possible overpayment',
      'Arabic': 'دفع زائد محتمل',
      'Hindi': 'Overpaid',
      'Urdu': 'Overpaid',
      'Malayalam': 'Possible overpayment',
      'Nepali': 'Possible overpayment',
      'Bengali': 'Overpaid',
      'Filipino': 'Possible overpayment',
      'Tamil': 'சாத்தியமான அதிக கட்டணம்',
    },
    'ot_alert_overpaid_body': {
      'English':
          'Employer paid more than estimated — verify contract premiums or bonuses.',
      'Arabic': 'الشركة دفعت أكثر — تحقق من العقد',
      'Hindi': 'Verify contract',
      'Urdu': 'Verify contract',
      'Malayalam':
          'Employer paid more than estimated — verify contract premiums or bonuses.',
      'Nepali':
          'Employer paid more than estimated — verify contract premiums or bonuses.',
      'Bengali': 'Verify contract',
      'Filipino':
          'Employer paid more than estimated — verify contract premiums or bonuses.',
      'Tamil':
          'முதலாளி மதிப்பீட்டை விட அதிகம் செலுத்தியுள்ளார் — ஒப்பந்த premiums அல்லது bonuses-ஐ சரிபார்க்கவும்.',
    },
    'ot_alert_missing_days': {
      'English': 'Many days without entries',
      'Arabic': 'أيام كثيرة بدون إدخالات',
      'Hindi': 'Missing entries',
      'Urdu': 'Missing entries',
      'Malayalam': 'Many days without entries',
      'Nepali': 'Many days without entries',
      'Bengali': 'Missing entries',
      'Filipino': 'Many days without entries',
      'Tamil': 'பல நாட்கள் entries இல்லாமல்',
    },
    'ot_alert_missing_days_body': {
      'English': 'Complete the calendar for a more accurate monthly estimate.',
      'Arabic': 'أكمل التقويم لدقة أفضل',
      'Hindi': 'Complete calendar',
      'Urdu': 'Complete calendar',
      'Malayalam':
          'Complete the calendar for a more accurate monthly estimate.',
      'Nepali': 'Complete the calendar for a more accurate monthly estimate.',
      'Bengali': 'Complete calendar',
      'Filipino': 'Complete the calendar for a more accurate monthly estimate.',
      'Tamil':
          'மேலும் துல்லியமான மாதாந்திர மதிப்பீட்டுக்கு காலண்டரை நிரப்பவும்.',
    },
    'ot_val_salary': {
      'English': 'Basic salary is required',
      'Arabic': 'الراتب الأساسي مطلوب',
      'Hindi': 'Salary required',
      'Urdu': 'Salary required',
      'Malayalam': 'Basic salary is required',
      'Nepali': 'Basic salary is required',
      'Bengali': 'Salary required',
      'Filipino': 'Basic salary is required',
      'Tamil': 'அடிப்படை சம்பளம் தேவை',
    },
    'ot_val_negative': {
      'English': 'Hours cannot be negative',
      'Arabic': 'لا يمكن أن تكون الساعات سالبة',
      'Hindi': 'No negative hours',
      'Urdu': 'No negative hours',
      'Malayalam': 'Hours cannot be negative',
      'Nepali': 'Hours cannot be negative',
      'Bengali': 'No negative hours',
      'Filipino': 'Hours cannot be negative',
      'Tamil': 'மணி எதிர்மறையாக இருக்க முடியாது',
    },
    'ot_val_impossible': {
      'English': 'Daily overtime exceeds 16 hours',
      'Arabic': 'تجاوز 16 ساعة يومياً',
      'Hindi': 'Too many hours',
      'Urdu': 'Too many hours',
      'Malayalam': 'Daily overtime exceeds 16 hours',
      'Nepali': 'Daily overtime exceeds 16 hours',
      'Bengali': 'Too many hours',
      'Filipino': 'Daily overtime exceeds 16 hours',
      'Tamil': 'தினசரி கூடுதல் நேர வேலை 16 மணியை மீறுகிறது',
    },
    'ot_val_duplicate': {
      'English': 'Duplicate date entries',
      'Arabic': 'تاريخ مكرر',
      'Hindi': 'Duplicate date',
      'Urdu': 'Duplicate date',
      'Malayalam': 'Duplicate date entries',
      'Nepali': 'Duplicate date entries',
      'Bengali': 'Duplicate date',
      'Filipino': 'Duplicate date entries',
      'Tamil': 'Duplicate தேதி entries',
    },
    'ot_calendar_hint': {
      'English': 'Tap any day to enter overtime hours',
      'Arabic': 'اضغط على أي يوم لإدخال ساعات العمل الإضافي',
      'Hindi': 'Tap a day to add hours',
      'Urdu': 'Tap a day to add hours',
      'Malayalam': 'Tap any day to enter overtime hours',
      'Nepali': 'Tap any day to enter overtime hours',
      'Bengali': 'Tap a day to add hours',
      'Filipino': 'Tap any day to enter overtime hours',
      'Tamil': 'கூடுதல் நேர மணியை உள்ளிட எந்த நாளையும் tap செய்யுங்கள்',
    },
    'ot_tap_to_add': {
      'English': 'Tap to add',
      'Arabic': 'اضغط للإضافة',
      'Hindi': 'Tap to add',
      'Urdu': 'Tap to add',
      'Malayalam': 'Tap to add',
      'Nepali': 'Tap to add',
      'Bengali': 'Tap to add',
      'Filipino': 'Tap to add',
      'Tamil': 'சேர்க்க tap செய்யுங்கள்',
    },
    'tpl_eosb_opening': {
      'English':
          'Based on your inputs, your estimated total End of Service entitlement is {total}. You have {years} years of service under an {contract} contract, ending due to {termination}.',
      'Arabic':
          'بناءً على بياناتك، إجمالي مستحقات نهاية الخدمة التقديرية {total}. لديك {years} سنوات خدمة بعقد {contract}، وانتهاء الخدمة بسبب {termination}.',
      'Hindi':
          'Your estimated EOSB total is {total} with {years} years on an {contract} contract ({termination}).',
      'Urdu':
          'Your estimated EOSB total is {total} with {years} years on an {contract} contract ({termination}).',
      'Malayalam':
          'Based on your inputs, your estimated total End of Service entitlement is {total}. You have {years} years of service under an {contract} contract, ending due to {termination}.',
      'Nepali':
          'Based on your inputs, your estimated total End of Service entitlement is {total}. You have {years} years of service under an {contract} contract, ending due to {termination}.',
      'Bengali':
          'Your estimated EOSB total is {total} with {years} years on an {contract} contract ({termination}).',
      'Filipino':
          'Based on your inputs, your estimated total End of Service entitlement is {total}. You have {years} years of service under an {contract} contract, ending due to {termination}.',
      'Tamil':
          'உங்கள் உள்ளீட்டின் அடிப்படையில், மதிப்பிடப்பட்ட மொத்த சேவை முடிவு உரிமை {total}. {contract} ஒப்பந்தத்தில் {years} ஆண்டு சேவை, {termination} காரணமாக முடிவு.',
    },
    'tpl_eosb_component': {
      'English':
          '{name}: {amount}. Calculated as {formula}. Rule applied: {rule}.',
      'Arabic': '{name}: {amount}. طريقة الحساب: {formula}. القاعدة: {rule}.',
      'Hindi': '{name}: {amount}. {formula}. Rule: {rule}.',
      'Urdu': '{name}: {amount}. {formula}. Rule: {rule}.',
      'Malayalam':
          '{name}: {amount}. Calculated as {formula}. Rule applied: {rule}.',
      'Nepali':
          '{name}: {amount}. Calculated as {formula}. Rule applied: {rule}.',
      'Bengali': '{name}: {amount}. {formula}. Rule: {rule}.',
      'Filipino':
          '{name}: {amount}. Calculated as {formula}. Rule applied: {rule}.',
      'Tamil':
          '{name}: {amount}. {formula} என கணக்கிடப்பட்டது. பயன்படுத்தப்பட்ட விதி: {rule}.',
    },
    'tpl_eosb_violation': {
      'English': '⚠ {title} ({risk}): {explanation}',
      'Arabic': '⚠ {title} ({risk}): {explanation}',
      'Hindi': '⚠ {title} ({risk}): {explanation}',
      'Urdu': '⚠ {title} ({risk}): {explanation}',
      'Malayalam': '⚠ {title} ({risk}): {explanation}',
      'Nepali': '⚠ {title} ({risk}): {explanation}',
      'Bengali': '⚠ {title} ({risk}): {explanation}',
      'Filipino': '⚠ {title} ({risk}): {explanation}',
      'Tamil': '⚠ {title} ({risk}): {explanation}',
    },
    'tpl_eosb_warning': {
      'English': 'Note — {title}: {explanation}',
      'Arabic': 'ملاحظة — {title}: {explanation}',
      'Hindi': 'Note — {title}: {explanation}',
      'Urdu': 'Note — {title}: {explanation}',
      'Malayalam': 'Note — {title}: {explanation}',
      'Nepali': 'Note — {title}: {explanation}',
      'Bengali': 'Note — {title}: {explanation}',
      'Filipino': 'Note — {title}: {explanation}',
      'Tamil': 'குறிப்பு — {title}: {explanation}',
    },
    'tpl_eosb_compare_under': {
      'English':
          'Your employer offer ({offer}) is lower than the estimate ({estimate}) by about {delta} ({percent}% below).',
      'Arabic':
          'عرض صاحب العمل ({offer}) أقل من التقدير ({estimate}) بفرق {delta} ({percent}%).',
      'Hindi':
          'Employer offer {offer} is {delta} below estimate {estimate} ({percent}%).',
      'Urdu':
          'Employer offer {offer} is {delta} below estimate {estimate} ({percent}%).',
      'Malayalam':
          'Your employer offer ({offer}) is lower than the estimate ({estimate}) by about {delta} ({percent}% below).',
      'Nepali':
          'Your employer offer ({offer}) is lower than the estimate ({estimate}) by about {delta} ({percent}% below).',
      'Bengali':
          'Employer offer {offer} is {delta} below estimate {estimate} ({percent}%).',
      'Filipino':
          'Your employer offer ({offer}) is lower than the estimate ({estimate}) by about {delta} ({percent}% below).',
      'Tamil':
          'உங்கள் முதலாளி சலுகை ({offer}) மதிப்பீட்டை ({estimate}) விட சுமார் {delta} ({percent}% குறைவு) குறைவாக உள்ளது.',
    },
    'tpl_eosb_compare_match': {
      'English':
          'Your employer offer ({offer}) is close to the estimate ({estimate}). Still verify each line item in writing.',
      'Arabic':
          'عرض صاحب العمل ({offer}) قريب من التقدير ({estimate}). تحقق كتابياً.',
      'Hindi': 'Offer {offer} matches estimate {estimate} — verify in writing.',
      'Urdu': 'Offer {offer} matches estimate {estimate} — verify in writing.',
      'Malayalam':
          'Your employer offer ({offer}) is close to the estimate ({estimate}). Still verify each line item in writing.',
      'Nepali':
          'Your employer offer ({offer}) is close to the estimate ({estimate}). Still verify each line item in writing.',
      'Bengali':
          'Offer {offer} matches estimate {estimate} — verify in writing.',
      'Filipino':
          'Your employer offer ({offer}) is close to the estimate ({estimate}). Still verify each line item in writing.',
      'Tamil':
          'உங்கள் முதலாளி சலுகை ({offer}) மதிப்பீட்டுக்கு ({estimate}) அருகில் உள்ளது. இருப்பினும் ஒவ்வொரு line item-ஐயும் எழுத்தில் சரிபார்க்கவும்.',
    },
    'tpl_eosb_compare_over': {
      'English':
          'Your employer offer ({offer}) exceeds the estimate ({estimate}) by about {delta}. Verify premiums or bonuses in your contract.',
      'Arabic': 'العرض ({offer}) أعلى من التقدير ({estimate}) بـ {delta}.',
      'Hindi': 'Offer {offer} exceeds estimate by {delta}.',
      'Urdu': 'Offer {offer} exceeds estimate by {delta}.',
      'Malayalam':
          'Your employer offer ({offer}) exceeds the estimate ({estimate}) by about {delta}. Verify premiums or bonuses in your contract.',
      'Nepali':
          'Your employer offer ({offer}) exceeds the estimate ({estimate}) by about {delta}. Verify premiums or bonuses in your contract.',
      'Bengali': 'Offer {offer} exceeds estimate by {delta}.',
      'Filipino':
          'Your employer offer ({offer}) exceeds the estimate ({estimate}) by about {delta}. Verify premiums or bonuses in your contract.',
      'Tamil':
          'உங்கள் முதலாளி சலுகை ({offer}) மதிப்பீட்டை ({estimate}) விட சுமார் {delta} அதிகம். ஒப்பந்தத்தில் premiums அல்லது bonuses-ஐ சரிபார்க்கவும்.',
    },
    'tpl_eosb_dispute': {
      'English':
          'Possible shortfall in {item}: about {gap} based on proportional share. ({rule})',
      'Arabic': 'نقص محتمل في {item}: حوالي {gap}. ({rule})',
      'Hindi': 'Possible gap in {item}: {gap}. ({rule})',
      'Urdu': 'Possible gap in {item}: {gap}. ({rule})',
      'Malayalam':
          'Possible shortfall in {item}: about {gap} based on proportional share. ({rule})',
      'Nepali':
          'Possible shortfall in {item}: about {gap} based on proportional share. ({rule})',
      'Bengali': 'Possible gap in {item}: {gap}. ({rule})',
      'Filipino':
          'Possible shortfall in {item}: about {gap} based on proportional share. ({rule})',
      'Tamil':
          '{item}-ல் சாத்தியமான குறைபாடு: விகிதாசார பங்கின் அடிப்படையில் சுமார் {gap}. ({rule})',
    },
    'tpl_eosb_followup': {
      'English':
          'This assistant explains your calculated estimate using Qatar Labour Law rules already applied in RAABTA. For case-specific advice, call ADLSA (16008), use the Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727 — or consult a qualified lawyer. Not formal legal advice.',
      'Arabic':
          'يشرح هذا المساعد تقديرك وفق قواعد قانون العمل القطري. للاستشارة الرسمية: ADLSA 16008 (24/7)، بوابة الشكاوى الموحدة mol.gov.qa (NAS)، أو SMS: 5 + الهوية إلى 92727.',
      'Hindi':
          'This explains your RAABTA estimate only. Disputes: ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727.',
      'Urdu':
          'This explains your RAABTA estimate only. Disputes: ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727.',
      'Malayalam':
          'This assistant explains your calculated estimate using Qatar Labour Law rules already applied in RAABTA. For case-specific advice, call ADLSA (16008), use the Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727 — or consult a qualified lawyer. Not formal legal advice.',
      'Nepali':
          'This assistant explains your calculated estimate using Qatar Labour Law rules already applied in RAABTA. For case-specific advice, call ADLSA (16008), use the Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727 — or consult a qualified lawyer. Not formal legal advice.',
      'Bengali':
          'This explains your RAABTA estimate only. Disputes: ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727.',
      'Filipino':
          'This assistant explains your calculated estimate using Qatar Labour Law rules already applied in RAABTA. For case-specific advice, call ADLSA (16008), use the Unified Complaints Portal (mol.gov.qa, NAS login), or SMS 5+QID to 92727 — or consult a qualified lawyer. Not formal legal advice.',
      'Tamil':
          'இந்த assistant RAABTA-வில் ஏற்கனவே பயன்படுத்தப்பட்ட Qatar தொழிலாளர் சட்டம் விதிகளைப் பயன்படுத்தி உங்கள் கணக்கிடப்பட்ட மதிப்பீட்டை விளக்குகிறது. வழக்கு-குறிப்பிட்ட ஆலோசனைக்கு ADLSA (16008), ஒருங்கிணைந்த புகார் portal (mol.gov.qa, NAS login), அல்லது SMS 5+QID to 92727 — அல்லது தகுதியுள்ள வழக்கறிஞரை அணுகவும். முறையான சட்ட ஆலோசனை அல்ல.',
    },
    'tpl_eosb_art62_explanation': {
      'English':
          'Article 54 end-of-service gratuity (your RAABTA estimate) is separate from dismissal disputes. Article 61 lists grounds for dismissal without notice and without gratuity. Article 62 sets disciplinary penalty procedure (written inquiry, 15-day limit, one penalty per violation). Article 64 governs dismissal penalty grievance and court/LDRC challenge — if dismissal is arbitrary or unlawful, a court may order reinstatement with back wages or appropriate compensation with no fixed formula. Raabta cannot estimate any amount or determine whether your dismissal was arbitrary. For information: ADLSA 16008, mol.gov.qa — not formal legal advice.',
      'Arabic':
          'مكافأة نهاية الخدمة (المادة 54) منفصلة عن نزاعات الفصل. المادة 61: أسباب الفصل دون إشعار ودون مكافأة. المادة 62: الإجراء التأديبي. المادة 64: تظلم الفصل والطعن أمام المحكمة/لجنة فض المنازعات — تعويض بتقدير المحكمة دون صيغة ثابتة. Raabta لا تُقدّر مبلغاً ولا تحدد التعسف. ADLSA 16008 — ليس استشارة قانونية.',
      'Hindi':
          'Art. 54 gratuity separate from dismissal disputes. Art. 61: without-notice grounds. Art. 62: discipline procedure. Art. 64: court/LDRC challenge — no fixed amount. Raabta does not estimate. ADLSA 16008.',
      'Urdu':
          'Art. 54 gratuity separate from dismissal disputes. Art. 61: without-notice grounds. Art. 62: discipline procedure. Art. 64: court/LDRC challenge — no fixed amount. Raabta does not estimate. ADLSA 16008.',
      'Malayalam':
          'Article 54 gratuity is separate from dismissal disputes. Article 61: without-notice grounds. Article 62: disciplinary procedure. Article 64: court/LDRC challenge — no fixed formula. Raabta does not estimate. ADLSA 16008 — not legal advice.',
      'Nepali':
          'Article 54 gratuity is separate from dismissal disputes. Article 61: without-notice grounds. Article 62: disciplinary procedure. Article 64: court/LDRC challenge — no fixed formula. Raabta does not estimate. ADLSA 16008 — not legal advice.',
      'Bengali':
          'Art. 54 separate. Art. 61 grounds. Art. 62 discipline. Art. 64 court challenge — no fixed amount. ADLSA 16008.',
      'Filipino':
          'Article 54 gratuity is separate from dismissal disputes. Article 61: without-notice grounds. Article 62: disciplinary procedure. Article 64: court/LDRC challenge — no fixed formula. Raabta does not estimate. ADLSA 16008 — not legal advice.',
      'Tamil':
          'Article 54 gratuity is separate from dismissal disputes. Article 61: without-notice grounds. Article 62: disciplinary procedure. Article 64: court/LDRC challenge — no fixed formula. Raabta does not estimate. ADLSA 16008 — not legal advice.',
    },
    'tpl_eosb_contract_unlimited': {
      'English': 'unlimited-term',
      'Arabic': 'غير محدد المدة',
      'Hindi': 'unlimited',
      'Urdu': 'unlimited',
      'Malayalam': 'unlimited-term',
      'Nepali': 'unlimited-term',
      'Bengali': 'unlimited',
      'Filipino': 'unlimited-term',
      'Tamil': 'வரம்பற்ற கால',
    },
    'tpl_eosb_contract_limited': {
      'English': 'limited-term',
      'Arabic': 'محدد المدة',
      'Hindi': 'limited',
      'Urdu': 'limited',
      'Malayalam': 'limited-term',
      'Nepali': 'limited-term',
      'Bengali': 'limited',
      'Filipino': 'limited-term',
      'Tamil': 'வரையறுக்கப்பட்ட கால',
    },
    'tpl_eosb_term_employerTermination': {
      'English': 'employer termination',
      'Arabic': 'إنهاء من صاحب العمل',
      'Hindi': 'employer termination',
      'Urdu': 'employer termination',
      'Malayalam': 'employer termination',
      'Nepali': 'employer termination',
      'Bengali': 'employer termination',
      'Filipino': 'employer termination',
      'Tamil': 'முதலாளி முடிவு',
    },
    'tpl_eosb_term_employeeResignation': {
      'English': 'your resignation',
      'Arabic': 'استقالتك',
      'Hindi': 'resignation',
      'Urdu': 'resignation',
      'Malayalam': 'your resignation',
      'Nepali': 'your resignation',
      'Bengali': 'resignation',
      'Filipino': 'your resignation',
      'Tamil': 'உங்கள் resign',
    },
    'tpl_eosb_term_mutualSeparation': {
      'English': 'mutual separation',
      'Arabic': 'انفصال بالتراضي',
      'Hindi': 'mutual separation',
      'Urdu': 'mutual separation',
      'Malayalam': 'mutual separation',
      'Nepali': 'mutual separation',
      'Bengali': 'mutual separation',
      'Filipino': 'mutual separation',
      'Tamil': 'பரஸ்பர பிரிவு',
    },
    'tpl_eosb_term_retirement': {
      'English': 'retirement',
      'Arabic': 'تقاعد',
      'Hindi': 'retirement',
      'Urdu': 'retirement',
      'Malayalam': 'retirement',
      'Nepali': 'retirement',
      'Bengali': 'retirement',
      'Filipino': 'retirement',
      'Tamil': 'ஓய்வூதியம்',
    },
    'tpl_eosb_term_companyClosure': {
      'English': 'company closure',
      'Arabic': 'إغلاق الشركة',
      'Hindi': 'company closure',
      'Urdu': 'company closure',
      'Malayalam': 'company closure',
      'Nepali': 'company closure',
      'Bengali': 'company closure',
      'Filipino': 'company closure',
      'Tamil': 'நிறுவன மூடல்',
    },
    'tpl_eosb_term_contractExpiry': {
      'English': 'contract expiry',
      'Arabic': 'انتهاء العقد',
      'Hindi': 'contract expiry',
      'Urdu': 'contract expiry',
      'Malayalam': 'contract expiry',
      'Nepali': 'contract expiry',
      'Bengali': 'contract expiry',
      'Filipino': 'contract expiry',
      'Tamil': 'ஒப்பந்த காலாவதி',
    },
    'tpl_eosb_doc_contract': {
      'English': 'Employment contract and amendments',
      'Arabic': 'عقد العمل والملحقات',
      'Hindi': 'Employment contract',
      'Urdu': 'Employment contract',
      'Malayalam': 'Employment contract and amendments',
      'Nepali': 'Employment contract and amendments',
      'Bengali': 'Employment contract',
      'Filipino': 'Employment contract and amendments',
      'Tamil': 'வேலை ஒப்பந்தம் மற்றும் திருத்தங்கள்',
    },
    'tpl_eosb_doc_payslip': {
      'English': 'Recent payslips and WPS records',
      'Arabic': 'كشوف الراتب وسجل حماية الأجور',
      'Hindi': 'Payslips and WPS',
      'Urdu': 'Payslips and WPS',
      'Malayalam': 'Recent payslips and WPS records',
      'Nepali': 'Recent payslips and WPS records',
      'Bengali': 'Payslips and WPS',
      'Filipino': 'Recent payslips and WPS records',
      'Tamil': 'சமீப payslips மற்றும் WPS பதிவுகள்',
    },
    'tpl_eosb_doc_settlement': {
      'English': 'Employer settlement letter or offer',
      'Arabic': 'خطاب التسوية أو العرض',
      'Hindi': 'Settlement letter',
      'Urdu': 'Settlement letter',
      'Malayalam': 'Employer settlement letter or offer',
      'Nepali': 'Employer settlement letter or offer',
      'Bengali': 'Settlement letter',
      'Filipino': 'Employer settlement letter or offer',
      'Tamil': 'முதலாளி தீர்வு கடிதம் அல்லது சலுகை',
    },
    'eosb_violation_salary_basis': {
      'English': 'Salary basis issue',
      'Arabic': 'مشكلة في أساس الراتب',
      'Hindi': 'Salary basis issue',
      'Urdu': 'Salary basis issue',
      'Malayalam': 'Salary basis issue',
      'Nepali': 'Salary basis issue',
      'Bengali': 'Salary basis issue',
      'Filipino': 'Salary basis issue',
      'Tamil': 'சம்பள அடிப்படை சிக்கல்',
    },
    'eosb_violation_salary_basis_exp': {
      'English':
          'Total salary appears lower than basic salary — gratuity and leave may be calculated on wrong basis.',
      'Arabic': 'إجمالي الراتب أقل من الأساسي — قد يؤثر على الحساب.',
      'Hindi': 'Total below basic — check payslip.',
      'Urdu': 'Total below basic — check payslip.',
      'Malayalam':
          'Total salary appears lower than basic salary — gratuity and leave may be calculated on wrong basis.',
      'Nepali':
          'Total salary appears lower than basic salary — gratuity and leave may be calculated on wrong basis.',
      'Bengali': 'Total below basic — check payslip.',
      'Filipino':
          'Total salary appears lower than basic salary — gratuity and leave may be calculated on wrong basis.',
      'Tamil':
          'மொத்த சம்பளம் அடிப்படை சம்பளத்தை விட குறைவாகத் தோன்றுகிறது — கிராஜுவிட்டி மற்றும் விடுப்பு தவறான அடிப்படையில் கணக்கிடப்படலாம்.',
    },
    'eosb_violation_salary_basis_rule': {
      'English': 'Art. 54 — gratuity based on basic salary',
      'Arabic': 'المادة 54',
      'Hindi': 'Art. 54',
      'Urdu': 'Art. 54',
      'Malayalam': 'Art. 54 — gratuity based on basic salary',
      'Nepali': 'Art. 54 — gratuity based on basic salary',
      'Bengali': 'Art. 54',
      'Filipino': 'Art. 54 — gratuity based on basic salary',
      'Tamil': 'பிரிவு 54 — அடிப்படை சம்பளத்தில் கிராஜுவிட்டி',
    },
    'eosb_violation_min_service': {
      'English': 'Minimum service not met for resignation gratuity',
      'Arabic': 'لم تستوفِ الحد الأدنى للخدمة عند الاستقالة',
      'Hindi': 'Min service not met',
      'Urdu': 'Min service not met',
      'Malayalam': 'Minimum service not met for resignation gratuity',
      'Nepali': 'Minimum service not met for resignation gratuity',
      'Bengali': 'Min service not met',
      'Filipino': 'Minimum service not met for resignation gratuity',
      'Tamil': 'Resign கிராஜுவிட்டிக்கு குறைந்தபட்ச சேவை பூர்த்தியாகவில்லை',
    },
    'eosb_violation_min_service_exp': {
      'English':
          'Resignation before 1 year continuous service typically means no gratuity under Art. 54.',
      'Arabic': 'الاستقالة قبل سنة — عادة لا مكافأة.',
      'Hindi': 'Under 1 year resignation — usually no gratuity.',
      'Urdu': 'Under 1 year resignation — usually no gratuity.',
      'Malayalam':
          'Resignation before 1 year continuous service typically means no gratuity under Art. 54.',
      'Nepali':
          'Resignation before 1 year continuous service typically means no gratuity under Art. 54.',
      'Bengali': 'Under 1 year resignation — usually no gratuity.',
      'Filipino':
          'Resignation before 1 year continuous service typically means no gratuity under Art. 54.',
      'Tamil':
          '1 ஆண்டு தொடர் சேவைக்கு முன் resign — பொதுவாக பிரிவு 54-ன் கீழ் கிராஜுவிட்டி இல்லை.',
    },
    'eosb_violation_gratuity_missing': {
      'English': 'Gratuity may be missing from estimate',
      'Arabic': 'المكافأة قد تكون مفقودة',
      'Hindi': 'Gratuity missing',
      'Urdu': 'Gratuity missing',
      'Malayalam': 'Gratuity may be missing from estimate',
      'Nepali': 'Gratuity may be missing from estimate',
      'Bengali': 'Gratuity missing',
      'Filipino': 'Gratuity may be missing from estimate',
      'Tamil': 'மதிப்பீட்டில் கிராஜுவிட்டி காணாமல் போகலாம்',
    },
    'eosb_violation_gratuity_missing_exp': {
      'English':
          'You appear eligible for gratuity but the calculated amount is zero — verify joining date and salary.',
      'Arabic':
          'يبدو أنك مستحق للمكافأة لكن المبلغ صفر — تحقق من التاريخ والراتب.',
      'Hindi': 'Eligible but zero gratuity — verify dates.',
      'Urdu': 'Eligible but zero gratuity — verify dates.',
      'Malayalam':
          'You appear eligible for gratuity but the calculated amount is zero — verify joining date and salary.',
      'Nepali':
          'You appear eligible for gratuity but the calculated amount is zero — verify joining date and salary.',
      'Bengali': 'Eligible but zero gratuity — verify dates.',
      'Filipino':
          'You appear eligible for gratuity but the calculated amount is zero — verify joining date and salary.',
      'Tamil':
          'நீங்கள் கிராஜுவிட்டிக்கு தகுதியாகத் தோன்றுகிறீர்கள் ஆனால் கணக்கிடப்பட்ட தொகை பூஜ்ஜியம் — சேரும் தேதி மற்றும் சம்பளத்தை சரிபார்க்கவும்.',
    },
    'eosb_warn_leave_encashment': {
      'English': 'Leave encashment may be owed',
      'Arabic': 'بدل الإجازات قد يكون مستحقاً',
      'Hindi': 'Leave encashment owed',
      'Urdu': 'Leave encashment owed',
      'Malayalam': 'Leave encashment may be owed',
      'Nepali': 'Leave encashment may be owed',
      'Bengali': 'Leave encashment owed',
      'Filipino': 'Leave encashment may be owed',
      'Tamil': 'விடுப்பு encashment செலுத்தப்பட வேண்டியிருக்கலாம்',
    },
    'eosb_warn_leave_encashment_exp': {
      'English':
          'You entered unused leave days but leave encashment calculated as zero.',
      'Arabic': 'أدخلت أيام إجازة لكن البدل صفر.',
      'Hindi': 'Unused leave entered but zero amount.',
      'Urdu': 'Unused leave entered but zero amount.',
      'Malayalam':
          'You entered unused leave days but leave encashment calculated as zero.',
      'Nepali':
          'You entered unused leave days but leave encashment calculated as zero.',
      'Bengali': 'Unused leave entered but zero amount.',
      'Filipino':
          'You entered unused leave days but leave encashment calculated as zero.',
      'Tamil':
          'பயன்படுத்தாத விடுப்பு நாட்களை நுழைத்தீர்கள் ஆனால் encashment பூஜ்ஜியமாக கணக்கிடப்பட்டது.',
    },
    'eosb_warn_leave_encashment_action': {
      'English': 'Verify leave balance with HR',
      'Arabic': 'تحقق من رصيد الإجازات',
      'Hindi': 'Verify with HR',
      'Urdu': 'Verify with HR',
      'Malayalam': 'Verify leave balance with HR',
      'Nepali': 'Verify leave balance with HR',
      'Bengali': 'Verify with HR',
      'Filipino': 'Verify leave balance with HR',
      'Tamil': 'HR-உடன் விடுப்பு balance சரிபார்க்கவும்',
    },
    'eosb_warn_notice_comp': {
      'English': 'Notice period compensation',
      'Arabic': 'تعويض فترة الإشعار',
      'Hindi': 'Notice compensation',
      'Urdu': 'Notice compensation',
      'Malayalam': 'Notice period compensation',
      'Nepali': 'Notice period compensation',
      'Bengali': 'Notice compensation',
      'Filipino': 'Notice period compensation',
      'Tamil': 'அறிவிப்பு கால இழப்பீடு',
    },
    'eosb_warn_notice_comp_exp': {
      'English':
          'Employer termination without served notice may entitle you to notice pay.',
      'Arabic': 'إنهاء بدون إشعار قد يستحق تعويضاً.',
      'Hindi': 'Notice pay may apply.',
      'Urdu': 'Notice pay may apply.',
      'Malayalam':
          'Employer termination without served notice may entitle you to notice pay.',
      'Nepali':
          'Employer termination without served notice may entitle you to notice pay.',
      'Bengali': 'Notice pay may apply.',
      'Filipino':
          'Employer termination without served notice may entitle you to notice pay.',
      'Tamil':
          'அறிவிப்பு வழங்காமல் முதலாளி முடித்தால் notice pay உரிமை இருக்கலாம்.',
    },
    'eosb_warn_notice_comp_action': {
      'English': 'Confirm notice terms in contract',
      'Arabic': 'تحقق من شروط الإشعار',
      'Hindi': 'Check contract',
      'Urdu': 'Check contract',
      'Malayalam': 'Confirm notice terms in contract',
      'Nepali': 'Confirm notice terms in contract',
      'Bengali': 'Check contract',
      'Filipino': 'Confirm notice terms in contract',
      'Tamil': 'ஒப்பந்தத்தில் notice விதிமுறைகளை உறுதிப்படுத்தவும்',
    },
    'eosb_warn_pending_salary': {
      'English': 'Pending salary included',
      'Arabic': 'راتب مستحق مضاف',
      'Hindi': 'Pending salary',
      'Urdu': 'Pending salary',
      'Malayalam': 'Pending salary included',
      'Nepali': 'Pending salary included',
      'Bengali': 'Pending salary',
      'Filipino': 'Pending salary included',
      'Tamil': 'நிலுவை சம்பளம் சேர்க்கப்பட்டது',
    },
    'eosb_warn_pending_salary_exp': {
      'English': 'Unpaid salary for worked days is part of your settlement.',
      'Arabic': 'الراتب غير المدفوع جزء من التسوية.',
      'Hindi': 'Unpaid salary in settlement.',
      'Urdu': 'Unpaid salary in settlement.',
      'Malayalam': 'Unpaid salary for worked days is part of your settlement.',
      'Nepali': 'Unpaid salary for worked days is part of your settlement.',
      'Bengali': 'Unpaid salary in settlement.',
      'Filipino': 'Unpaid salary for worked days is part of your settlement.',
      'Tamil':
          'வேலை செய்த நாட்களுக்கான செலுத்தப்படாத சம்பளம் உங்கள் தீர்வின் பகுதி.',
    },
    'eosb_warn_pending_salary_action': {
      'English': 'Keep WPS and bank records',
      'Arabic': 'احتفظ بسجل حماية الأجور',
      'Hindi': 'Keep WPS records',
      'Urdu': 'Keep WPS records',
      'Malayalam': 'Keep WPS and bank records',
      'Nepali': 'Keep WPS and bank records',
      'Bengali': 'Keep WPS records',
      'Filipino': 'Keep WPS and bank records',
      'Tamil': 'WPS மற்றும் வங்கி பதிவுகளை வைத்திருங்கள்',
    },
    'tpl_ot_summary': {
      'English':
          'For {month}, you logged {totalHours} overtime hours ({regular}h weekday, {rest}h rest day, {holiday}h holiday, {night}h night). Estimated legal value: {totalPay}.',
      'Arabic':
          'في {month}، سجلت {totalHours} ساعة إضافية. القيمة التقديرية: {totalPay}.',
      'Hindi': '{month}: {totalHours}h OT, estimated {totalPay}.',
      'Urdu': '{month}: {totalHours}h OT, estimated {totalPay}.',
      'Malayalam':
          'For {month}, you logged {totalHours} overtime hours ({regular}h weekday, {rest}h rest day, {holiday}h holiday, {night}h night). Estimated legal value: {totalPay}.',
      'Nepali':
          'For {month}, you logged {totalHours} overtime hours ({regular}h weekday, {rest}h rest day, {holiday}h holiday, {night}h night). Estimated legal value: {totalPay}.',
      'Bengali': '{month}: {totalHours}h OT, estimated {totalPay}.',
      'Filipino':
          'For {month}, you logged {totalHours} overtime hours ({regular}h weekday, {rest}h rest day, {holiday}h holiday, {night}h night). Estimated legal value: {totalPay}.',
      'Tamil':
          '{month}-ல், {totalHours} கூடுதல் நேர மணி பதிவு செய்தீர்கள் ({regular}h வார நாள், {rest}h ஓய்வு நாள், {holiday}h விடுமுறை, {night}h இரவு). மதிப்பிடப்பட்ட சட்ட மதிப்பு: {totalPay}.',
    },
    'tpl_ot_calc_intro': {
      'English':
          'Hourly rate derived from basic salary {basic} → {hourly}/hour (÷ working days ÷ hours).',
      'Arabic': 'الأجر بالساعة من الراتب {basic} → {hourly}.',
      'Hindi': 'Hourly rate from {basic}: {hourly}.',
      'Urdu': 'Hourly rate from {basic}: {hourly}.',
      'Malayalam':
          'Hourly rate derived from basic salary {basic} → {hourly}/hour (÷ working days ÷ hours).',
      'Nepali':
          'Hourly rate derived from basic salary {basic} → {hourly}/hour (÷ working days ÷ hours).',
      'Bengali': 'Hourly rate from {basic}: {hourly}.',
      'Filipino':
          'Hourly rate derived from basic salary {basic} → {hourly}/hour (÷ working days ÷ hours).',
      'Tamil':
          'அடிப்படை சம்பளம் {basic}-லிருந்து மணி விகிதம் → {hourly}/மணி (÷ வேலை நாட்கள் ÷ மணி).',
    },
    'tpl_ot_calc_line': {
      'English': '{category}: {hours}h × {rate} = {amount}',
      'Arabic': '{category}: {hours}س × {rate} = {amount}',
      'Hindi': '{category}: {hours}h × {rate} = {amount}',
      'Urdu': '{category}: {hours}h × {rate} = {amount}',
      'Malayalam': '{category}: {hours}h × {rate} = {amount}',
      'Nepali': '{category}: {hours}h × {rate} = {amount}',
      'Bengali': '{category}: {hours}h × {rate} = {amount}',
      'Filipino': '{category}: {hours}h × {rate} = {amount}',
      'Tamil': '{category}: {hours}h × {rate} = {amount}',
    },
    'tpl_ot_calc_total': {
      'English':
          'Total estimated overtime: {total}. Employer reported/paid: {employer}.',
      'Arabic': 'الإجمالي التقديري: {total}. دفعت الشركة: {employer}.',
      'Hindi': 'Total {total}, employer paid {employer}.',
      'Urdu': 'Total {total}, employer paid {employer}.',
      'Malayalam':
          'Total estimated overtime: {total}. Employer reported/paid: {employer}.',
      'Nepali':
          'Total estimated overtime: {total}. Employer reported/paid: {employer}.',
      'Bengali': 'Total {total}, employer paid {employer}.',
      'Filipino':
          'Total estimated overtime: {total}. Employer reported/paid: {employer}.',
      'Tamil':
          'மொத்த மதிப்பிடப்பட்ட கூடுதல் நேர வேலை: {total}. முதலாளி புகாரளித்த/செலுத்தியது: {employer}.',
    },
    'tpl_ot_missing_gap': {
      'English':
          'Employer payment appears short by about {gap} ({percent}% difference).',
      'Arabic': 'يبدو أن الدفع أقل بحوالي {gap} ({percent}%).',
      'Hindi': 'Short by {gap} ({percent}%).',
      'Urdu': 'Short by {gap} ({percent}%).',
      'Malayalam':
          'Employer payment appears short by about {gap} ({percent}% difference).',
      'Nepali':
          'Employer payment appears short by about {gap} ({percent}% difference).',
      'Bengali': 'Short by {gap} ({percent}%).',
      'Filipino':
          'Employer payment appears short by about {gap} ({percent}% difference).',
      'Tamil':
          'முதலாளி கட்டணம் சுமார் {gap} ({percent}% வித்தியாசம்) குறைவாகத் தோன்றுகிறது.',
    },
    'tpl_ot_tip_wps': {
      'English': 'Cross-check amounts on the WPS salary protection system.',
      'Arabic': 'قارن مع نظام حماية الأجور WPS.',
      'Hindi': 'Check WPS records.',
      'Urdu': 'Check WPS records.',
      'Malayalam': 'Cross-check amounts on the WPS salary protection system.',
      'Nepali': 'Cross-check amounts on the WPS salary protection system.',
      'Bengali': 'Check WPS records.',
      'Filipino': 'Cross-check amounts on the WPS salary protection system.',
      'Tamil':
          'WPS சம்பள பாதுகாப்பு அமைப்பில் தொகைகளை cross-check செய்யுங்கள்.',
    },
    'tpl_ot_tip_payslip': {
      'English': 'Request an itemised payslip showing overtime categories.',
      'Arabic': 'اطلب كشف راتب مفصل للعمل الإضافي.',
      'Hindi': 'Request itemised payslip.',
      'Urdu': 'Request itemised payslip.',
      'Malayalam': 'Request an itemised payslip showing overtime categories.',
      'Nepali': 'Request an itemised payslip showing overtime categories.',
      'Bengali': 'Request itemised payslip.',
      'Filipino': 'Request an itemised payslip showing overtime categories.',
      'Tamil': 'கூடுதல் நேர வகைகளைக் காட்டும் itemised payslip-ஐ கோருங்கள்.',
    },
    'tpl_ot_next_payslip': {
      'English': 'Ask HR/payroll for overtime breakdown for this month.',
      'Arabic': 'اطلب تفصيل العمل الإضافي لهذا الشهر.',
      'Hindi': 'Ask HR for OT breakdown.',
      'Urdu': 'Ask HR for OT breakdown.',
      'Malayalam': 'Ask HR/payroll for overtime breakdown for this month.',
      'Nepali': 'Ask HR/payroll for overtime breakdown for this month.',
      'Bengali': 'Ask HR for OT breakdown.',
      'Filipino': 'Ask HR/payroll for overtime breakdown for this month.',
      'Tamil':
          'இந்த மாதத்துக்கான கூடுதல் நேர பிரிவினையை HR/payroll-ஐ கேளுங்கள்.',
    },
    'tpl_ot_next_match': {
      'English':
          'Payment appears to match the estimate — still keep payslips for your records.',
      'Arabic': 'الدفع يطابق التقدير — احتفظ بالكشوف.',
      'Hindi': 'Payment matches — keep payslips.',
      'Urdu': 'Payment matches — keep payslips.',
      'Malayalam':
          'Payment appears to match the estimate — still keep payslips for your records.',
      'Nepali':
          'Payment appears to match the estimate — still keep payslips for your records.',
      'Bengali': 'Payment matches — keep payslips.',
      'Filipino':
          'Payment appears to match the estimate — still keep payslips for your records.',
      'Tamil':
          'கட்டணம் மதிப்பீட்டுடன் பொருந்துவது போல் — இருப்பினும் உங்கள் பதிவுகளுக்கு payslips வைத்திருங்கள்.',
    },
    'tpl_ot_q_unpaid': {
      'English':
          'Can you provide the overtime rate used for each category on my payslip?',
      'Arabic': 'ما نسبة العمل الإضافي لكل فئة في كشف الراتب؟',
      'Hindi': 'What OT rate was used per category?',
      'Urdu': 'What OT rate was used per category?',
      'Malayalam':
          'Can you provide the overtime rate used for each category on my payslip?',
      'Nepali':
          'Can you provide the overtime rate used for each category on my payslip?',
      'Bengali': 'What OT rate was used per category?',
      'Filipino':
          'Can you provide the overtime rate used for each category on my payslip?',
      'Tamil':
          'என் payslip-ல் ஒவ்வொரு வகைக்கும் பயன்படுத்தப்பட்ட கூடுதல் நேர விகிதத்தை வழங்க முடியுமா?',
    },
    'tpl_ot_q_overpaid': {
      'English':
          'Was a premium, bonus, or allowance included in the overtime line?',
      'Arabic': 'هل شمل البند علاوة أو مكافأة؟',
      'Hindi': 'Was a bonus included in OT pay?',
      'Urdu': 'Was a bonus included in OT pay?',
      'Malayalam':
          'Was a premium, bonus, or allowance included in the overtime line?',
      'Nepali':
          'Was a premium, bonus, or allowance included in the overtime line?',
      'Bengali': 'Was a bonus included in OT pay?',
      'Filipino':
          'Was a premium, bonus, or allowance included in the overtime line?',
      'Tamil':
          'கூடுதல் நேர வரியில் premium, bonus, அல்லது allowance சேர்க்கப்பட்டதா?',
    },
    'tpl_ot_q_hours': {
      'English':
          'Why do reported overtime hours differ from my attendance records?',
      'Arabic': 'لماذا تختلف الساعات المسجلة عن حضوري؟',
      'Hindi': 'Why do hours differ from attendance?',
      'Urdu': 'Why do hours differ from attendance?',
      'Malayalam':
          'Why do reported overtime hours differ from my attendance records?',
      'Nepali':
          'Why do reported overtime hours differ from my attendance records?',
      'Bengali': 'Why do hours differ from attendance?',
      'Filipino':
          'Why do reported overtime hours differ from my attendance records?',
      'Tamil':
          'பதிவு செய்யப்பட்ட கூடுதல் நேர மணி என் attendance பதிவுகளிலிருந்து ஏன் வேறுபடுகிறது?',
    },
    'tpl_ot_q_weekly_cap': {
      'English':
          'Were any hours above the weekly limit approved under labour rules?',
      'Arabic': 'هل ساعات فوق الحد الأسبوعي معتمدة؟',
      'Hindi': 'Were excess weekly hours approved?',
      'Urdu': 'Were excess weekly hours approved?',
      'Malayalam':
          'Were any hours above the weekly limit approved under labour rules?',
      'Nepali':
          'Were any hours above the weekly limit approved under labour rules?',
      'Bengali': 'Were excess weekly hours approved?',
      'Filipino':
          'Were any hours above the weekly limit approved under labour rules?',
      'Tamil':
          'வார வரம்புக்கு மேல் எந்த மணியும் தொழிலாளர் விதிகளின் கீழ் அங்கீகரிக்கப்பட்டதா?',
    },
    'tpl_ot_q_missing_days': {
      'English':
          'Can you confirm my attendance for days missing from my overtime log?',
      'Arabic': 'هل يمكن تأكيد حضور الأيام غير المسجلة؟',
      'Hindi': 'Confirm attendance for missing days?',
      'Urdu': 'Confirm attendance for missing days?',
      'Malayalam':
          'Can you confirm my attendance for days missing from my overtime log?',
      'Nepali':
          'Can you confirm my attendance for days missing from my overtime log?',
      'Bengali': 'Confirm attendance for missing days?',
      'Filipino':
          'Can you confirm my attendance for days missing from my overtime log?',
      'Tamil':
          'என் கூடுதல் நேர log-ல் காணாமல் போன நாட்களுக்கு என் attendance-ஐ உறுதிப்படுத்த முடியுமா?',
    },
    'tpl_ot_q_night': {
      'English':
          'What night-shift differential rate applies under my contract?',
      'Arabic': 'ما نسبة العمل الليلي في عقدي؟',
      'Hindi': 'What night differential applies?',
      'Urdu': 'What night differential applies?',
      'Malayalam':
          'What night-shift differential rate applies under my contract?',
      'Nepali': 'What night-shift differential rate applies under my contract?',
      'Bengali': 'What night differential applies?',
      'Filipino':
          'What night-shift differential rate applies under my contract?',
      'Tamil':
          'என் ஒப்பந்தத்தின் கீழ் எந்த இரவு-shift differential விகிதம் பொருந்தும்?',
    },
    'tpl_ot_q_rest_holiday': {
      'English':
          'What rates apply for rest-day and public-holiday work on my contract?',
      'Arabic': 'ما نسبة أيام الراحة والعطل في عقدي؟',
      'Hindi': 'Rest/holiday rates on my contract?',
      'Urdu': 'Rest/holiday rates on my contract?',
      'Malayalam':
          'What rates apply for rest-day and public-holiday work on my contract?',
      'Nepali':
          'What rates apply for rest-day and public-holiday work on my contract?',
      'Bengali': 'Rest/holiday rates on my contract?',
      'Filipino':
          'What rates apply for rest-day and public-holiday work on my contract?',
      'Tamil':
          'என் ஒப்பந்தத்தில் ஓய்வு நாள் மற்றும் பொது விடுமுறை வேலைக்கு எந்த விகிதங்கள் பொருந்தும்?',
    },
    'eosb_legal_freshness': {
      'English': 'Last legal update verified: {date}',
      'Arabic': 'آخر تحديث قانوني: {date}',
      'Hindi': 'Last legal update: {date}',
      'Urdu': 'Last legal update: {date}',
      'Malayalam': 'Last legal update verified: {date}',
      'Nepali': 'Last legal update verified: {date}',
      'Bengali': 'Last legal update: {date}',
      'Filipino': 'Last legal update verified: {date}',
      'Tamil': 'கடைசி சட்ட புதுப்பிப்பு சரிபார்க்கப்பட்டது: {date}',
    },
    'eosb_legal_freshness_loading': {
      'English': 'Checking legal source freshness…',
      'Arabic': 'جاري التحقق من تحديث المصادر القانونية…',
      'Hindi': 'Checking legal freshness…',
      'Urdu': 'Checking legal freshness…',
      'Malayalam': 'Checking legal source freshness…',
      'Nepali': 'Checking legal source freshness…',
      'Bengali': 'Checking legal freshness…',
      'Filipino': 'Checking legal source freshness…',
      'Tamil': 'சட்ட மூல freshness சரிபார்க்கப்படுகிறது…',
    },
    'eosb_legal_update_banner': {
      'English':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
      'Arabic':
          'تغيّر قانون العمل القطري منذ آخر تقدير — أعد الحساب لرؤية رقمك المحدّث.',
      'Hindi':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
      'Urdu':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
      'Malayalam':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
      'Nepali':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
      'Bengali':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
      'Filipino':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
      'Tamil':
          'Qatar Labour Law changed since your last estimate — recalculate to see your updated number.',
    },
    'eosb_legal_update_recalculate': {
      'English': 'Recalculate',
      'Arabic': 'إعادة الحساب',
      'Hindi': 'Recalculate',
      'Urdu': 'Recalculate',
      'Malayalam': 'Recalculate',
      'Nepali': 'Recalculate',
      'Bengali': 'Recalculate',
      'Filipino': 'Recalculate',
      'Tamil': 'Recalculate',
    },
    'eosb_disclaimer_law9': {
      'English':
          'Includes Law No. 9 of 2026 amendments — verify exact articles on Al Meezan before disputes.',
      'Arabic': 'يتضمن تعديلات القانون 9/2026 — تحقق من المواد على الميزان.',
      'Hindi': 'Includes Law 9/2026 — verify on Al Meezan.',
      'Urdu': 'Includes Law 9/2026 — verify on Al Meezan.',
      'Malayalam':
          'Includes Law No. 9 of 2026 amendments — verify exact articles on Al Meezan before disputes.',
      'Nepali':
          'Includes Law No. 9 of 2026 amendments — verify exact articles on Al Meezan before disputes.',
      'Bengali': 'Includes Law 9/2026 — verify on Al Meezan.',
      'Filipino':
          'Includes Law No. 9 of 2026 amendments — verify exact articles on Al Meezan before disputes.',
      'Tamil':
          '2026-ன் சட்டம் எண் 9 திருத்தங்கள் உள்ளடக்கியது — தகராறுகளுக்கு முன் Al Meezan-ல் சரியான பிரிவுகளை சரிபார்க்கவும்.',
    },
    'eosb_employment_category': {
      'English': 'Employment category',
      'Arabic': 'فئة التوظيف',
      'Hindi': 'Employment category',
      'Urdu': 'Employment category',
      'Malayalam': 'Employment category',
      'Nepali': 'Employment category',
      'Bengali': 'Employment category',
      'Filipino': 'Employment category',
      'Tamil': 'வேலை வகை',
    },
    'eosb_employment_full_time': {
      'English': 'Full-time (standard Labour Law coverage)',
      'Arabic': 'دوام كامل',
      'Hindi': 'Full-time',
      'Urdu': 'Full-time',
      'Malayalam': 'Full-time (standard Labour Law coverage)',
      'Nepali': 'Full-time (standard Labour Law coverage)',
      'Bengali': 'Full-time',
      'Filipino': 'Full-time (standard Labour Law coverage)',
      'Tamil': 'முழு நேரம் (standard தொழிலாளர் சட்டம் coverage)',
    },
    'eosb_employment_part_time': {
      'English':
          'Part-time (may fall outside default Labour Law scope — Law 9/2026)',
      'Arabic': 'دوام جزئي',
      'Hindi': 'Part-time',
      'Urdu': 'Part-time',
      'Malayalam':
          'Part-time (may fall outside default Labour Law scope — Law 9/2026)',
      'Nepali':
          'Part-time (may fall outside default Labour Law scope — Law 9/2026)',
      'Bengali': 'Part-time',
      'Filipino':
          'Part-time (may fall outside default Labour Law scope — Law 9/2026)',
      'Tamil':
          'பகுதி நேரம் (default தொழிலாளர் சட்டம் scope-க்கு வெளியே இருக்கலாம் — சட்டம் 9/2026)',
    },
    'eosb_employment_freelance': {
      'English':
          'Freelance / independent (may fall outside default Labour Law scope)',
      'Arabic': 'عمل حر',
      'Hindi': 'Freelance',
      'Urdu': 'Freelance',
      'Malayalam':
          'Freelance / independent (may fall outside default Labour Law scope)',
      'Nepali':
          'Freelance / independent (may fall outside default Labour Law scope)',
      'Bengali': 'Freelance',
      'Filipino':
          'Freelance / independent (may fall outside default Labour Law scope)',
      'Tamil':
          'Freelance / independent (default தொழிலாளர் சட்டம் scope-க்கு வெளியே இருக்கலாம்)',
    },
    'eosb_summary_dismissal_ground': {
      'English': 'Summary dismissal ground (employer only — rare)',
      'Arabic': 'سبب الفصل الملخص',
      'Hindi': 'Summary dismissal ground',
      'Urdu': 'Summary dismissal ground',
      'Malayalam': 'Summary dismissal ground (employer only — rare)',
      'Nepali': 'Summary dismissal ground (employer only — rare)',
      'Bengali': 'Summary dismissal ground',
      'Filipino': 'Summary dismissal ground (employer only — rare)',
      'Tamil': 'சுருக்க முடிவு காரணம் (முதலாளி மட்டும் — அரிது)',
    },
    'eosb_summary_dismissal_none': {
      'English': 'None / standard termination',
      'Arabic': 'لا ينطبق',
      'Hindi': 'None',
      'Urdu': 'None',
      'Malayalam': 'None / standard termination',
      'Nepali': 'None / standard termination',
      'Bengali': 'None',
      'Filipino': 'None / standard termination',
      'Tamil': 'எதுவும் இல்லை / standard முடிவு',
    },
    'eosb_summary_dismissal_strike': {
      'English':
          'Unlawful strike incitement disrupting operations (Law 9/2026 — verify)',
      'Arabic': 'تحريض على إضراب غير مشروع',
      'Hindi': 'Unlawful strike incitement',
      'Urdu': 'Unlawful strike incitement',
      'Malayalam':
          'Unlawful strike incitement disrupting operations (Law 9/2026 — verify)',
      'Nepali':
          'Unlawful strike incitement disrupting operations (Law 9/2026 — verify)',
      'Bengali': 'Unlawful strike incitement',
      'Filipino':
          'Unlawful strike incitement disrupting operations (Law 9/2026 — verify)',
      'Tamil':
          'செயல்பாடுகளை இடையூறு செய்யும் சட்டவிரோத strike incitement (சட்டம் 9/2026 — சரிபார்க்கவும்)',
    },
    'eosb_summary_dismissal_confirm': {
      'English':
          'I confirm this is the specific ground cited by the employer (not a general dismissal)',
      'Arabic': 'أؤكد أن هذا هو سبب الفصل المحدد',
      'Hindi': 'Confirm specific dismissal ground',
      'Urdu': 'Confirm specific dismissal ground',
      'Malayalam':
          'I confirm this is the specific ground cited by the employer (not a general dismissal)',
      'Nepali':
          'I confirm this is the specific ground cited by the employer (not a general dismissal)',
      'Bengali': 'Confirm specific dismissal ground',
      'Filipino':
          'I confirm this is the specific ground cited by the employer (not a general dismissal)',
      'Tamil':
          'முதலாளி குறிப்பிட்ட இந்த காரணத்தைக் குறிப்பிடுகிறார் என்பதை உறுதிப்படுத்துகிறேன் (பொது முடிவு அல்ல)',
    },
    'eosb_warn_employment_coverage_law9': {
      'English': 'Labour Law coverage may not apply to your employment type',
      'Arabic': 'قد لا ينطبق قانون العمل على فئتك',
      'Hindi': 'Labour Law may not apply',
      'Urdu': 'Labour Law may not apply',
      'Malayalam': 'Labour Law coverage may not apply to your employment type',
      'Nepali': 'Labour Law coverage may not apply to your employment type',
      'Bengali': 'Labour Law may not apply',
      'Filipino': 'Labour Law coverage may not apply to your employment type',
      'Tamil':
          'தொழிலாளர் சட்டம் coverage உங்கள் வேலை வகைக்கு பொருந்தாமல் போகலாம்',
    },
    'eosb_warn_employment_coverage_law9_exp': {
      'English':
          'Law No. 9 of 2026 excludes part-time and freelance workers from default Labour Law coverage. The Council of Ministers may extend coverage by decision. This estimate uses standard formulas — verify your category with MoL or a lawyer.',
      'Arabic': 'القانون 9/2026 يستثني بعض فئات العمل — تحقق من وزارة العمل.',
      'Hindi': 'Part-time/freelance may be excluded under Law 9/2026.',
      'Urdu': 'Part-time/freelance may be excluded under Law 9/2026.',
      'Malayalam':
          'Law No. 9 of 2026 excludes part-time and freelance workers from default Labour Law coverage. The Council of Ministers may extend coverage by decision. This estimate uses standard formulas — verify your category with MoL or a lawyer.',
      'Nepali':
          'Law No. 9 of 2026 excludes part-time and freelance workers from default Labour Law coverage. The Council of Ministers may extend coverage by decision. This estimate uses standard formulas — verify your category with MoL or a lawyer.',
      'Bengali': 'Part-time/freelance may be excluded under Law 9/2026.',
      'Filipino':
          'Law No. 9 of 2026 excludes part-time and freelance workers from default Labour Law coverage. The Council of Ministers may extend coverage by decision. This estimate uses standard formulas — verify your category with MoL or a lawyer.',
      'Tamil':
          '2026-ன் சட்டம் எண் 9 part-time மற்றும் freelance தொழிலாளர்களை default தொழிலாளர் சட்டம் coverage-லிருந்து விலக்குகிறது. அமைச்சரவை முடிவின் மூலம் coverage நீட்டிக்கலாம். இந்த மதிப்பீடு standard சூத்திரங்களைப் பயன்படுத்துகிறது — MoL அல்லது வழக்கறிஞருடன் உங்கள் வகையை சரிபார்க்கவும்.',
    },
    'eosb_warn_employment_coverage_law9_action': {
      'English': 'Confirm employment category with HR or MoL (16505)',
      'Arabic': 'تحقق من فئة التوظيف',
      'Hindi': 'Verify with MoL',
      'Urdu': 'Verify with MoL',
      'Malayalam': 'Confirm employment category with HR or MoL (16505)',
      'Nepali': 'Confirm employment category with HR or MoL (16505)',
      'Bengali': 'Verify with MoL',
      'Filipino': 'Confirm employment category with HR or MoL (16505)',
      'Tamil': 'HR அல்லது MoL (16505)-உடன் வேலை வகையை உறுதிப்படுத்தவும்',
    },
    'eosb_warn_strike_incitement_gratuity': {
      'English':
          'Gratuity excluded — narrow strike-incitement dismissal ground',
      'Arabic': 'استثناء مكافأة — تحريض على إضراب',
      'Hindi': 'Gratuity excluded — strike ground',
      'Urdu': 'Gratuity excluded — strike ground',
      'Malayalam':
          'Gratuity excluded — narrow strike-incitement dismissal ground',
      'Nepali': 'Gratuity excluded — narrow strike-incitement dismissal ground',
      'Bengali': 'Gratuity excluded — strike ground',
      'Filipino':
          'Gratuity excluded — narrow strike-incitement dismissal ground',
      'Tamil':
          'கிராஜுவிட்டி விலக்கப்பட்டது — குற narrow strike-incitement முடிவு காரணம்',
    },
    'eosb_warn_strike_incitement_gratuity_exp': {
      'English':
          'You indicated dismissal for unlawfully inciting a strike that disrupted operations (Law No. 9 of 2026 — exact article requires Al Meezan verification). Gratuity is shown as zero under this narrow ground. This is unusual and consequential — seek independent legal advice immediately.',
      'Arabic': 'فصل بسبب تحريض على إضراب — استشر محامياً.',
      'Hindi': 'Unusual dismissal ground — get legal advice.',
      'Urdu': 'Unusual dismissal ground — get legal advice.',
      'Malayalam':
          'You indicated dismissal for unlawfully inciting a strike that disrupted operations (Law No. 9 of 2026 — exact article requires Al Meezan verification). Gratuity is shown as zero under this narrow ground. This is unusual and consequential — seek independent legal advice immediately.',
      'Nepali':
          'You indicated dismissal for unlawfully inciting a strike that disrupted operations (Law No. 9 of 2026 — exact article requires Al Meezan verification). Gratuity is shown as zero under this narrow ground. This is unusual and consequential — seek independent legal advice immediately.',
      'Bengali': 'Unusual dismissal ground — get legal advice.',
      'Filipino':
          'You indicated dismissal for unlawfully inciting a strike that disrupted operations (Law No. 9 of 2026 — exact article requires Al Meezan verification). Gratuity is shown as zero under this narrow ground. This is unusual and consequential — seek independent legal advice immediately.',
      'Tamil':
          'செயல்பாடுகளை இடையூறு செய்யும் சட்டவிரோதமாக strike-ஐ incite செய்ததற்காக முடிவு என்று குறிப்பிட்டீர்கள் (2026-ன் சட்டம் எண் 9 — சரியான பிரிவு Al Meezan சரிபார்ப்பு தேவை). இந்த குற narrow காரணத்தின் கீழ் கிராஜுவிட்டி பூஜ்ஜியமாகக் காட்டப்படுகிறது. இது அசாதாரணமானது மற்றும் விளைவுள்ளது — உடனடியாக சுயாதீன சட்ட ஆலோசனை பெறுங்கள்.',
    },
    'eosb_warn_strike_incitement_gratuity_action': {
      'English':
          'Consult ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), SMS 5+QID to 92727, or a qualified labour lawyer',
      'Arabic':
          'استشر ADLSA 16008 (24/7)، بوابة الشكاوى الموحدة mol.gov.qa (NAS)، SMS: 5 + الهوية إلى 92727، أو محامياً',
      'Hindi':
          'Consult ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727, or a lawyer',
      'Urdu':
          'Consult ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727, or a lawyer',
      'Malayalam':
          'Consult ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), SMS 5+QID to 92727, or a qualified labour lawyer',
      'Nepali':
          'Consult ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), SMS 5+QID to 92727, or a qualified labour lawyer',
      'Bengali':
          'Consult ADLSA 16008, mol.gov.qa portal (NAS login), SMS 5+QID to 92727, or a lawyer',
      'Filipino':
          'Consult ADLSA (16008), Unified Complaints Portal (mol.gov.qa, NAS login), SMS 5+QID to 92727, or a qualified labour lawyer',
      'Tamil':
          'ADLSA (16008), ஒருங்கிணைந்த புகார் portal (mol.gov.qa, NAS login), SMS 5+QID to 92727, அல்லது தகுதியுள்ள தொழிலாளர் வழக்கறிஞரை அணுகவும்',
    },
    'eosb_warn_strike_incitement_unconfirmed': {
      'English': 'Strike-incitement ground selected but not confirmed',
      'Arabic': 'لم يتم تأكيد سبب الفصل',
      'Hindi': 'Ground not confirmed',
      'Urdu': 'Ground not confirmed',
      'Malayalam': 'Strike-incitement ground selected but not confirmed',
      'Nepali': 'Strike-incitement ground selected but not confirmed',
      'Bengali': 'Ground not confirmed',
      'Filipino': 'Strike-incitement ground selected but not confirmed',
      'Tamil':
          'Strike-incitement காரணம் தேர்ந்தெடுக்கப்பட்டது ஆனால் உறுதிப்படுத்தப்படவில்லை',
    },
    'eosb_warn_strike_incitement_unconfirmed_exp': {
      'English':
          'Confirm the checkbox only if this is the exact ground your employer cited. Standard gratuity still applies otherwise.',
      'Arabic': 'أكد فقط إذا كان هذا هو السبب المحدد.',
      'Hindi': 'Confirm only if employer cited this ground.',
      'Urdu': 'Confirm only if employer cited this ground.',
      'Malayalam':
          'Confirm the checkbox only if this is the exact ground your employer cited. Standard gratuity still applies otherwise.',
      'Nepali':
          'Confirm the checkbox only if this is the exact ground your employer cited. Standard gratuity still applies otherwise.',
      'Bengali': 'Confirm only if employer cited this ground.',
      'Filipino':
          'Confirm the checkbox only if this is the exact ground your employer cited. Standard gratuity still applies otherwise.',
      'Tamil':
          'முதலாளி குறிப்பிட்ட இந்த காரணத்தைக் குறிப்பிட்டால் மட்டுமே checkbox-ஐ உறுதிப்படுத்துங்கள். இல்லையெனில் standard கிராஜுவிட்டி பொருந்தும்.',
    },
    'eosb_warn_strike_incitement_unconfirmed_action': {
      'English': 'Review termination letter with a lawyer',
      'Arabic': 'راجع خطاب الفصل',
      'Hindi': 'Review termination letter',
      'Urdu': 'Review termination letter',
      'Malayalam': 'Review termination letter with a lawyer',
      'Nepali': 'Review termination letter with a lawyer',
      'Bengali': 'Review termination letter',
      'Filipino': 'Review termination letter with a lawyer',
      'Tamil': 'முடிவு கடிதத்தை வழக்கறிஞருடன் மறுஆய்வு செய்யுங்கள்',
    },
    'eosb_warn_strike_predates_law9': {
      'English': 'Strike-incitement ground did not exist before 25 June 2026',
      'Arabic': 'سبب التحريض على الإضراب لم يكن موجوداً قبل 25 يونيو 2026',
      'Hindi': 'Strike-incitement ground did not exist before 25 June 2026',
      'Urdu': 'Strike-incitement ground did not exist before 25 June 2026',
      'Malayalam': 'Strike-incitement ground did not exist before 25 June 2026',
      'Nepali': 'Strike-incitement ground did not exist before 25 June 2026',
      'Bengali': 'Strike-incitement ground did not exist before 25 June 2026',
      'Filipino': 'Strike-incitement ground did not exist before 25 June 2026',
      'Tamil': '25 ஜூன் 2026-க்கு முன் strike-incitement காரணம் இருக்கவில்லை',
    },
    'eosb_warn_strike_predates_law9_exp': {
      'English':
          'Law No. 9 of 2026 (in force 25 June 2026) introduced this summary-dismissal ground. If your last working day was before that date, this ground would not have applied at the time — your employer would need another lawful basis for any no-gratuity dismissal.',
      'Arabic':
          'القانون 9/2026 دخل حيز التنفيذ 25 يونيو 2026 — تحقق من أساس الفصل.',
      'Hindi': 'Law 9/2026 effective 25 June 2026 — verify dismissal basis.',
      'Urdu': 'Law 9/2026 effective 25 June 2026 — verify dismissal basis.',
      'Malayalam':
          'Law No. 9 of 2026 (in force 25 June 2026) introduced this summary-dismissal ground. If your last working day was before that date, this ground would not have applied at the time.',
      'Nepali':
          'Law No. 9 of 2026 (in force 25 June 2026) introduced this summary-dismissal ground. If your last working day was before that date, this ground would not have applied at the time.',
      'Bengali': 'Law 9/2026 effective 25 June 2026 — verify dismissal basis.',
      'Filipino':
          'Law No. 9 of 2026 (in force 25 June 2026) introduced this summary-dismissal ground. If your last working day was before that date, this ground would not have applied at the time.',
      'Tamil':
          '2026-ன் சட்டம் எண் 9 (25 ஜூன் 2026 முதல் நடைமுறை) இந்த summary-dismissal காரணத்தை அறிமுகப்படுத்தியது. உங்கள் கடைசி வேலை நாள் அதற்கு முன் என்றால், அந்த நேரத்தில் இந்த காரணம் பொருந்தாது.',
    },
    'eosb_warn_strike_predates_law9_action': {
      'English':
          'Consult a labour lawyer about whether your dismissal was lawful',
      'Arabic': 'استشر محامياً',
      'Hindi': 'Consult a labour lawyer',
      'Urdu': 'Consult a labour lawyer',
      'Malayalam':
          'Consult a labour lawyer about whether your dismissal was lawful',
      'Nepali':
          'Consult a labour lawyer about whether your dismissal was lawful',
      'Bengali': 'Consult a labour lawyer',
      'Filipino':
          'Consult a labour lawyer about whether your dismissal was lawful',
      'Tamil':
          'உங்கள் முடிவு சட்டப்பூர்வமானதா என்பதை தொழிலாளர் வழக்கறிஞரிடம் ஆலோசிக்கவும்',
    },
    'eosb_employment_coverage_scope_notice': {
      'English':
          'Qatar\'s Labour Law No. 9 of 2026 formally recognizes part-time and freelance work as separate categories. By default, these are not automatically covered by the same entitlements calculated for standard employees below — coverage depends on your specific contract terms and any Council of Ministers decisions extending Labour Law provisions to your category, which Raabta cannot verify per case.',
      'Arabic':
          'القانون 9/2026 يعترف بالعمل الجزئي والعمل الحر — التغطية تعتمد على عقدك.',
      'Hindi':
          'Part-time/freelance may not be covered by default under Law 9/2026.',
      'Urdu':
          'Part-time/freelance may not be covered by default under Law 9/2026.',
      'Malayalam':
          'Qatar\'s Labour Law No. 9 of 2026 formally recognizes part-time and freelance work as separate categories. By default, these are not automatically covered by the same entitlements calculated for standard employees below.',
      'Nepali':
          'Qatar\'s Labour Law No. 9 of 2026 formally recognizes part-time and freelance work as separate categories. By default, these are not automatically covered by the same entitlements calculated for standard employees below.',
      'Bengali':
          'Part-time/freelance may not be covered by default under Law 9/2026.',
      'Filipino':
          'Qatar\'s Labour Law No. 9 of 2026 formally recognizes part-time and freelance work as separate categories. By default, these are not automatically covered by the same entitlements calculated for standard employees below.',
      'Tamil':
          'Qatar-ன் 2026-ன் தொழிலாளர் சட்டம் எண் 9 part-time மற்றும் freelance வேலையை தனி வகைகளாக அ formally அ recognizes செய்கிறது. default-ஆக, standard employees-க்கு கணக்கிடப்படும் entitlements automatically பொருந்தாது.',
    },
    'eosb_employment_reference_opt_in': {
      'English': 'Show reference estimate for a standard employee',
      'Arabic': 'عرض تقدير مرجعي لموظف بدوام كامل',
      'Hindi': 'Show reference estimate for standard employee',
      'Urdu': 'Show reference estimate for standard employee',
      'Malayalam': 'Show reference estimate for a standard employee',
      'Nepali': 'Show reference estimate for a standard employee',
      'Bengali': 'Show reference estimate for standard employee',
      'Filipino': 'Show reference estimate for a standard employee',
      'Tamil': 'standard employee-க்கான reference estimate-ஐ காட்டு',
    },
    'eosb_employment_reference_opt_in_sub': {
      'English':
          'Optional — shows what a full-time employee in your situation might receive under standard Labour Law formulas. This may not reflect your actual legal entitlement.',
      'Arabic': 'اختياري — للمرجع فقط وليس حقاً مؤكداً.',
      'Hindi': 'Optional reference only — not confirmed entitlement.',
      'Urdu': 'Optional reference only — not confirmed entitlement.',
      'Malayalam':
          'Optional — shows what a full-time employee in your situation might receive under standard Labour Law formulas. This may not reflect your actual legal entitlement.',
      'Nepali':
          'Optional — shows what a full-time employee in your situation might receive under standard Labour Law formulas. This may not reflect your actual legal entitlement.',
      'Bengali': 'Optional reference only — not confirmed entitlement.',
      'Filipino':
          'Optional — shows what a full-time employee in your situation might receive under standard Labour Law formulas. This may not reflect your actual legal entitlement.',
      'Tamil':
          'விருப்பம் — standard தொழிலாளர் சட்ட சூத்திரங்களின் கீழ் உங்கள் சூழ்நிலையில் full-time employee பெறக்கூடியதைக் காட்டும். இது உங்கள் உண்மையான சட்ட entitlement-ஐ reflect செய்யாமல் போகலாம்.',
    },
    'eosb_employment_reference_required': {
      'English':
          'Enable the reference estimate toggle above to continue — Raabta will not present standard-employee figures as your confirmed entitlement for part-time or freelance work.',
      'Arabic': 'فعّل خيار التقدير المرجعي للمتابعة.',
      'Hindi': 'Enable reference estimate toggle to continue.',
      'Urdu': 'Enable reference estimate toggle to continue.',
      'Malayalam':
          'Enable the reference estimate toggle above to continue — Raabta will not present standard-employee figures as your confirmed entitlement.',
      'Nepali':
          'Enable the reference estimate toggle above to continue — Raabta will not present standard-employee figures as your confirmed entitlement.',
      'Bengali': 'Enable reference estimate toggle to continue.',
      'Filipino':
          'Enable the reference estimate toggle above to continue — Raabta will not present standard-employee figures as your confirmed entitlement.',
      'Tamil':
          'தொடர மேலே reference estimate toggle-ஐ enable செய்யுங்கள் — part-time/freelance-க்கு standard-employee figures-ஐ உறுதிப்படுத்தப்பட்ட entitlement-ஆக Raabta காட்டாது.',
    },
    'eosb_reference_total': {
      'English': 'Reference total (standard employee)',
      'Arabic': 'إجمالي مرجعي (موظف بدوام كامل)',
      'Hindi': 'Reference total (standard employee)',
      'Urdu': 'Reference total (standard employee)',
      'Malayalam': 'Reference total (standard employee)',
      'Nepali': 'Reference total (standard employee)',
      'Bengali': 'Reference total (standard employee)',
      'Filipino': 'Reference total (standard employee)',
      'Tamil': 'Reference total (standard employee)',
    },
    'eosb_reference_banner_title': {
      'English': 'Reference estimate — not your confirmed entitlement',
      'Arabic': 'تقدير مرجعي — ليس حقاً مؤكداً',
      'Hindi': 'Reference estimate — not confirmed entitlement',
      'Urdu': 'Reference estimate — not confirmed entitlement',
      'Malayalam': 'Reference estimate — not your confirmed entitlement',
      'Nepali': 'Reference estimate — not your confirmed entitlement',
      'Bengali': 'Reference estimate — not confirmed entitlement',
      'Filipino': 'Reference estimate — not your confirmed entitlement',
      'Tamil':
          'Reference estimate — உங்கள் உறுதிப்படுத்தப்பட்ட entitlement அல்ல',
    },
    'eosb_reference_banner_body': {
      'English':
          'You selected part-time or freelance work. Law No. 9 of 2026 excludes these categories from default Labour Law coverage unless extended by the Council of Ministers or your contract. The figures below use standard full-time employee formulas for comparison only.',
      'Arabic': 'الأرقام أدناه للمرجع فقط — تحقق من عقدك ووزارة العمل.',
      'Hindi': 'Figures below are reference only for part-time/freelance.',
      'Urdu': 'Figures below are reference only for part-time/freelance.',
      'Malayalam':
          'You selected part-time or freelance work. Law No. 9 of 2026 excludes these categories from default Labour Law coverage unless extended. Figures below are for comparison only.',
      'Nepali':
          'You selected part-time or freelance work. Law No. 9 of 2026 excludes these categories from default Labour Law coverage unless extended. Figures below are for comparison only.',
      'Bengali': 'Figures below are reference only for part-time/freelance.',
      'Filipino':
          'You selected part-time or freelance work. Law No. 9 of 2026 excludes these categories from default Labour Law coverage unless extended. Figures below are for comparison only.',
      'Tamil':
          'part-time அல்லது freelance வேலையைத் தேர்ந்தெடுத்துள்ளீர்கள். 2026-ன் சட்டம் எண் 9 default coverage-லிருந்து இந்த வகைகளை விலக்குகிறது. கீழே உள்ள figures ஒப்பீட்டிற்கு மட்டும்.',
    },
    'eosb_transition_bank_title': {
      'English':
          'If you have a bank loan, this amount may arrive smaller than shown',
      'Arabic': 'إن كان لديك قرض بنكي، قد يصل هذا المبلغ أصغر مما يظهر',
      'Hindi': 'Bank loan हो तो यह राशि दिखाए गए से कम आ सकती है',
      'Urdu': 'Bank loan ہو تو یہ رقم دکھائے سے کم آ سکتی ہے',
      'Malayalam':
          'If you have a bank loan, this amount may arrive smaller than shown',
      'Nepali':
          'If you have a bank loan, this amount may arrive smaller than shown',
      'Bengali':
          'If you have a bank loan, this amount may arrive smaller than shown',
      'Filipino':
          'If you have a bank loan, this amount may arrive smaller than shown',
      'Tamil':
          'If you have a bank loan, this amount may arrive smaller than shown',
    },
    'eosb_transition_bank_body': {
      'English':
          'Employers often send final settlement and end-of-service payments directly to your bank. If you have an outstanding loan, the bank may deduct what you owe before releasing the rest — and may restrict the account when it learns you are leaving. Request a Liability Letter from your bank early (in person at a branch) to know the exact amount at risk, settle any debt, then obtain a Clearance Letter/NOC confirming no further liability. Start account-closure paperwork 30–45 days before your expected final payment, not on your last day. Policies vary bank to bank. If a freeze or deduction seems incorrect or excessive, contact the QCB Banking Customer Services Protection Department on 4445 6412 or 4445 6456.',
      'Arabic':
          'غالباً يُرسل صاحب العمل التسوية النهائية إلى بنكك. إن كان عليك قرض، قد يخصم البنك المستحق قبل إطلاق الباقي — وقد يقيّد الحساب عند علمه بمغادرتك. اطلب خطاب مسؤولية مبكراً (زيارة فرع)، سدّد أي دين، ثم خطاب تخليص/NOC. ابدأ إجراءات الإغلاق قبل 30–45 يوماً من الدفعة النهائية. السياسات تختلف بين البنوك. للاعتراض: QCB Banking Customer Services Protection Department — 4445 6412 / 4445 6456.',
      'Hindi':
          'Employer अक्सर final settlement सीधे bank में भेजता है; loan हो तो bank बकाया काट सकता है। Liability Letter (branch visit), debt settle, Clearance/NOC — 30–45 दिन पहले शुरू करें। गलत freeze/deduction: QCB Banking Customer Services Protection Department — 4445 6412 / 4445 6456.',
      'Urdu':
          'Employer اکثر final settlement براہ راست bank میں بھیجتا ہے؛ loan ہو تو bank واجب الادا رقم کاٹ سکتا ہے۔ Liability Letter (branch visit)، debt settle، Clearance/NOC — 30–45 دن پہلے شروع کریں۔ غلط freeze/deduction: QCB Banking Customer Services Protection Department — 4445 6412 / 4445 6456.',
      'Malayalam':
          'Employers often send final settlement directly to your bank. Outstanding loans may be deducted first. Request a Liability Letter early, settle debt, get Clearance/NOC. Start 30–45 days ahead. QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
      'Nepali':
          'Employers often send final settlement directly to your bank. Outstanding loans may be deducted first. Request a Liability Letter early, settle debt, get Clearance/NOC. Start 30–45 days ahead. QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
      'Bengali':
          'Employer often sends final settlement to your bank; outstanding loans may be deducted. Liability Letter, settle debt, Clearance/NOC — start 30–45 days early. QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
      'Filipino':
          'Employers often send final settlement directly to your bank. Outstanding loans may be deducted first. Request a Liability Letter early, settle debt, get Clearance/NOC. Start 30–45 days ahead. QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
      'Tamil':
          'Employers often send final settlement directly to your bank. Outstanding loans may be deducted first. Request a Liability Letter early (branch visit), settle debt, get Clearance/NOC. Start 30–45 days ahead. QCB Banking Customer Services Protection Department: 4445 6412 / 4445 6456.',
    },
    'eosb_transition_health_title': {
      'English':
          'Your health coverage usually ends with your job — not on a date you choose',
      'Arabic': 'تغطيتك الصحية تنتهي عادةً مع وظيفتك — وليس في تاريخ تختاره',
      'Hindi':
          'Health coverage आमतौर पर job के साथ समाप्त — आपकी chosen date पर नहीं',
      'Urdu':
          'Health coverage عموماً job کے ساتھ ختم — آپ کی chosen date پر نہیں',
      'Malayalam':
          'Your health coverage usually ends with your job — not on a date you choose',
      'Nepali':
          'Your health coverage usually ends with your job — not on a date you choose',
      'Bengali':
          'Your health coverage usually ends with your job — not on a date you choose',
      'Filipino':
          'Your health coverage usually ends with your job — not on a date you choose',
      'Tamil':
          'உங்கள் health coverage பொதுவாக job முடிவில் நிற்கும் — நீங்கள் தேர்ந்தெடுக்கும் தேதியில் அல்ல',
    },
    'eosb_transition_health_body': {
      'English':
          'Employer-provided health insurance is typically tied to active employment, so coverage may lapse when your job ends — sometimes weeks before new coverage begins elsewhere. Confirm the exact gap dates with both your outgoing and incoming employer. If you or dependents have a chronic condition or ongoing care needs, plan for that gap carefully: look into short-term coverage options with your insurer or employer rather than assuming emergency-only cover will apply.',
      'Arabic':
          'التأمين الصحي من صاحب العمل مرتبط بالعمل النشط، وقد ينتهي مع انتهاء الوظيفة — أحياناً قبل أسابيع من تغطية جديدة. أكّد تواريخ الفجوة مع صاحب العمل الحالي والقادم. إن كان لديك أو لمعالين حالة مزمنة، خطط للفجوة وابحث عن تغطية قصيرة الأمد.',
      'Hindi':
          'Employer health insurance active employment से जुड़ा होता है — job end पर lapse हो सकता है, नए cover से पहले हफ्तों का gap। दोनों employers से exact dates confirm करें। chronic/ongoing care हो तो short-term coverage options देखें।',
      'Urdu':
          'Employer health insurance active employment سے جڑا ہوتا ہے — job end پر lapse ہو سکتا ہے، نئے cover سے پہلے ہفتوں کا gap۔ دونوں employers سے exact dates confirm کریں۔ chronic/ongoing care ہو تو short-term coverage options دیکھیں۔',
      'Malayalam':
          'Employer health insurance typically ends with employment. There may be weeks before new coverage starts. Confirm gap dates with both employers. For chronic or ongoing care, look into short-term coverage options.',
      'Nepali':
          'Employer health insurance typically ends with employment. There may be weeks before new coverage starts. Confirm gap dates with both employers. For chronic or ongoing care, look into short-term coverage options.',
      'Bengali':
          'Employer health insurance typically ends with employment. Confirm gap dates with both employers. For chronic/ongoing care, look into short-term coverage options.',
      'Filipino':
          'Employer health insurance typically ends with employment. There may be weeks before new coverage starts. Confirm gap dates with both employers. For chronic or ongoing care, look into short-term coverage options.',
      'Tamil':
          'Employer health insurance typically ends with employment. There may be weeks before new coverage starts. Confirm gap dates with both employers. For chronic or ongoing care, look into short-term coverage options.',
    },
    'eosb_notice_rule_strike_incitement_law9': {
      'English':
          'Law No. 9 of 2026 — no notice pay under confirmed strike-incitement dismissal',
      'Arabic': 'القانون 9/2026 — لا أجر إشعار تحت سبب التحريض على الإضراب',
      'Hindi': 'Law 9/2026 — no notice for strike dismissal',
      'Urdu': 'Law 9/2026 — no notice for strike dismissal',
      'Malayalam':
          'Law No. 9 of 2026 — no notice pay under confirmed strike-incitement dismissal',
      'Nepali':
          'Law No. 9 of 2026 — no notice pay under confirmed strike-incitement dismissal',
      'Bengali': 'Law 9/2026 — no notice for strike dismissal',
      'Filipino':
          'Law No. 9 of 2026 — no notice pay under confirmed strike-incitement dismissal',
      'Tamil':
          '2026-ன் சட்டம் எண் 9 — உறுதிப்படுத்தப்பட்ட strike-incitement முடிவின் கீழ் notice pay இல்லை',
    },
    'eosb_gratuity_rule_strike_incitement_law9': {
      'English':
          'Law No. 9 of 2026 — summary dismissal without gratuity (strike incitement)',
      'Arabic': 'القانون 9/2026 — فصل بدون مكافأة',
      'Hindi': 'Law 9/2026 strike dismissal',
      'Urdu': 'Law 9/2026 strike dismissal',
      'Malayalam':
          'Law No. 9 of 2026 — summary dismissal without gratuity (strike incitement)',
      'Nepali':
          'Law No. 9 of 2026 — summary dismissal without gratuity (strike incitement)',
      'Bengali': 'Law 9/2026 strike dismissal',
      'Filipino':
          'Law No. 9 of 2026 — summary dismissal without gratuity (strike incitement)',
      'Tamil':
          '2026-ன் சட்டம் எண் 9 — கிராஜுவிட்டி இல்லாமல் சுருக்க முடிவு (strike incitement)',
    },
    'eosb_gratuity_formula_strike_incitement_none': {
      'English': 'Gratuity = 0 under confirmed narrow dismissal ground',
      'Arabic': 'المكافأة = 0',
      'Hindi': 'Gratuity = 0',
      'Urdu': 'Gratuity = 0',
      'Malayalam': 'Gratuity = 0 under confirmed narrow dismissal ground',
      'Nepali': 'Gratuity = 0 under confirmed narrow dismissal ground',
      'Bengali': 'Gratuity = 0',
      'Filipino': 'Gratuity = 0 under confirmed narrow dismissal ground',
      'Tamil':
          'உறுதிப்படுத்தப்பட்ட குற narrow முடிவு காரணத்தின் கீழ் கிராஜுவிட்டி = 0',
    },
    'eosb_gratuity_example_strike_incitement': {
      'English':
          'Applies only when employer proves unlawful strike incitement — verify legally',
      'Arabic': 'ينطبق فقط عند ثبوت التحريض — تحقق قانونياً',
      'Hindi': 'Verify legally',
      'Urdu': 'Verify legally',
      'Malayalam':
          'Applies only when employer proves unlawful strike incitement — verify legally',
      'Nepali':
          'Applies only when employer proves unlawful strike incitement — verify legally',
      'Bengali': 'Verify legally',
      'Filipino':
          'Applies only when employer proves unlawful strike incitement — verify legally',
      'Tamil':
          'முதலாளி சட்டவிரோத strike incitement-ஐ நிரூபிக்கும்போது மட்டுமே பொருந்தும் — சட்டப்படி சரிபார்க்கவும்',
    },
    'eosb_hcs_section_title': {
      'English': 'Know Your Home-Country Support',
      'Arabic': 'اعرف دعم بلدك الأصلي',
      'Hindi': 'अपने देश के सहायता संसाधन जानें',
      'Urdu': 'اپنے وطن کی معاونت جانیں',
      'Malayalam': 'നിങ്ങളുടെ സ്വദേശ രാജ്യ സഹായം അറിയുക',
      'Nepali': 'आफ्नो देशको सहयोग जान्नुहोस्',
      'Bengali': 'আপনার দেশের সহায়তা জানুন',
      'Filipino': 'Kilalanin ang suporta mula sa inyong bansa',
      'Tamil': 'உங்கள் தாய்நாட்டு ஆதரவை அறியுங்கள்',
    },
    'eosb_hcs_section_subtitle': {
      'English':
          'Official government resources you may be entitled to as an expatriate in Qatar — informational only.',
      'Arabic': 'موارد حكومية رسمية قد تستحقها كمغترب في قطر — للمعلومات فقط.',
      'Hindi':
          'कतर में प्रवासी के रूप में आप जिन सरकारी संसाधनों के हकदार हो सकते हैं — केवल जानकारी।',
      'Urdu':
          'قطر میں expat کے طور پر آپ جن سرکاری وسائل کے مستحق ہو سکتے ہیں — صرف معلومات۔',
      'Malayalam':
          'Qatar-ൽ പ്രവാസിയായി നിങ്ങൾക്ക് ലഭ്യമായ ഔദ്യോഗിക സർക്കാർ വിഭവങ്ങൾ — വിവരങ്ങൾ മാത്രം.',
      'Nepali':
          'कatar मा expat को रूपमा तपाईंले पाउन सक्ने आधिकारिक सरकारी स्रोत — जानकारी मात्र।',
      'Bengali':
          'কatar-এ প্রবাসী হিসেবে আপনি যে সরকারি সহায়তা পেতে পারেন — শুধু তথ্য।',
      'Filipino':
          'Opisyal na suporta mula sa gobyerno na maaari ninyong makuha bilang expat sa Qatar — impormasyon lamang.',
      'Tamil':
          'Qatar-ல் expatriate-ஆக உங்களுக்கு உரிமையாக இருக்கக்கூடிய அதிகாரப்பூர்வ அரசு வளங்கள் — தகவல் மட்டும்.',
    },
    'eosb_hcs_dismiss': {
      'English': 'Dismiss',
      'Arabic': 'إخفاء',
      'Hindi': 'बंद करें',
      'Urdu': 'بند کریں',
      'Malayalam': 'ഒഴിവാക്കുക',
      'Nepali': 'हटाउनुहोस्',
      'Bengali': 'বন্ধ করুন',
      'Filipino': 'Isara',
      'Tamil': 'மறை',
    },
    'eosb_hcs_coming_soon': {
      'English': 'Home-country support for {country} is coming soon.',
      'Arabic': 'دعم {country} قادم قريباً.',
      'Hindi': '{country} के लिए देश-विशिष्ट सहायता जल्द आ रही है।',
      'Urdu': '{country} کے لیے وطنی معاونت جلد آ رہی ہے۔',
      'Malayalam': '{country} നാട്ടിലെ സഹായം ഉടൻ ലഭ്യമാകും.',
      'Nepali': '{country} को लागि देश-विशेष सहयोग चाँडै आउँदैछ।',
      'Bengali': '{country}-এর জন্য দেশ-নির্দিষ্ট সহায়তা শীঘ্রই আসছে।',
      'Filipino': 'Malapit nang idagdag ang suporta para sa {country}.',
      'Tamil': '{country}-க்கான தாய்நாட்டு ஆதரவு விரைவில் வருகிறது.',
    },
    'eosb_hcs_verify_badge': {
      'English': 'Verify before use',
      'Arabic': 'تحقق قبل الاستخدام',
      'Hindi': 'उपयोग से पहले verify करें',
      'Urdu': 'استعمال سے پہلے تصدیق کریں',
      'Malayalam': 'ഉപയോഗത്തിന് മുമ്പ് പരിശോധിക്കുക',
      'Nepali': 'प्रयोग अघि प्रमाणित गर्नुहोस्',
      'Bengali': 'ব্যবহারের আগে যাচাই করুন',
      'Filipino': 'I-verify bago gamitin',
      'Tamil': 'பயன்படுத்துவதற்கு முன் சரிபார்க்கவும்',
    },
    'eosb_hcs_emigrate_title': {
      'English': 'eMigrate (Ministry of External Affairs)',
      'Arabic': 'eMigrate (وزارة الشؤون الخارجية)',
      'Hindi': 'eMigrate (MEA)',
      'Urdu': 'eMigrate (MEA)',
      'Malayalam': 'eMigrate (MEA)',
      'Nepali': 'eMigrate (MEA)',
      'Bengali': 'eMigrate (MEA)',
      'Filipino': 'eMigrate (MEA)',
      'Tamil': 'eMigrate (Ministry of External Affairs)',
    },
    'eosb_hcs_emigrate_desc': {
      'English':
          'Pre-departure clearance and Recruiting Agent verification portal. Relaunched as V2.0 in October 2024 with a 24/7 multilingual helpline.',
      'Arabic':
          'بوابة تصريح المغادرة والتحقق من وكلاء التوظيف. أُعيد إطلاقها V2.0 في أكتوبر 2024 مع خط مساعدة متعدد اللغات.',
      'Hindi':
          'प्रस्थान पूर्व clearance और Recruiting Agent verification पोर्टल। अक्टूबर 2024 में V2.0 relaunch — 24/7 बहुभाषी helpline।',
      'Urdu':
          'رخصت سے پہلے clearance اور recruiting agent verification — اکتوبر 2024 میں V2.0، 24/7 helpline۔',
      'Malayalam':
          'പുറപ്പെടുന്നതിന് മുമ്പുള്ള clearance, Recruiting Agent verification പോർട്ടൽ. 2024 ഒക്ടോബറിൽ V2.0 — 24/7 multilingual helpline.',
      'Nepali':
          'प्रस्थान अघि clearance र Recruiting Agent verification पोर्टल। अक्टोबर 2024 मा V2.0 — 24/7 helpline।',
      'Bengali':
          'প্রস্থান-পূর্ব clearance ও Recruiting Agent verification পোর্টাল। অক্টোবর ২০২৪-এ V2.0 — ২৪/৭ helpline।',
      'Filipino':
          'Pre-departure clearance at Recruiting Agent verification portal. V2.0 noong Oktubre 2024 — 24/7 multilingual helpline.',
      'Tamil':
          'Pre-departure clearance மற்றும் Recruiting Agent சரிபார்ப்பு பортал. அக்டோபர் 2024-ல் V2.0 relaunch — 24/7 பன்மொழி helpline.',
    },
    'eosb_hcs_madad_title': {
      'English': 'MADAD (Consular Grievance Portal)',
      'Arabic': 'MADAD (بوابة الشكاوى القنصلية)',
      'Hindi': 'MADAD (Consular Grievance Portal)',
      'Urdu': 'MADAD (Consular Grievance Portal)',
      'Malayalam': 'MADAD (Consular Grievance Portal)',
      'Nepali': 'MADAD (Consular Grievance Portal)',
      'Bengali': 'MADAD (Consular Grievance Portal)',
      'Filipino': 'MADAD (Consular Grievance Portal)',
      'Tamil': 'MADAD (Consular Grievance Portal)',
    },
    'eosb_hcs_madad_desc': {
      'English':
          'Ministry of External Affairs consular grievance portal for Indian nationals abroad.',
      'Arabic': 'بوابة شكاوى قنصلية للهنود في الخارج.',
      'Hindi':
          'विदेश में भारतीय नागरिकों के लिए MEA consular grievance पोर्टल।',
      'Urdu': 'بیرون ملک بھارتی شہریوں کے لیے MEA consular grievance portal۔',
      'Malayalam':
          'വിദേശത്ത് താമസിക്കുന്ന ഇന്ത്യൻ പൗരന്മാർക്കുള്ള MEA consular grievance പോർട്ടൽ.',
      'Nepali':
          'विदेशमा रहेका भारतीय नागरिकका लागि MEA consular grievance portal।',
      'Bengali':
          'বিদেশে থাকা ভারতীয় নাগরিকদের জন্য MEA consular grievance portal।',
      'Filipino':
          'Consular grievance portal ng MEA para sa mga Indian sa abroad.',
      'Tamil':
          'வெளிநாட்டில் உள்ள இந்திய nationals-க்கான Ministry of External Affairs consular grievance பортал.',
    },
    'eosb_hcs_india_embassy_title': {
      'English': 'Indian Embassy Doha — Labour / Community Welfare',
      'Arabic': 'السفارة الهندية — العمل / الرعاية المجتمعية',
      'Hindi': 'Indian Embassy Doha — Labour / Community Welfare',
      'Urdu': 'Indian Embassy Doha — Labour / Community Welfare',
      'Malayalam': 'Indian Embassy Doha — Labour / Community Welfare',
      'Nepali': 'Indian Embassy Doha — Labour / Community Welfare',
      'Bengali': 'Indian Embassy Doha — Labour / Community Welfare',
      'Filipino': 'Indian Embassy Doha — Labour / Community Welfare',
      'Tamil': 'Indian Embassy Doha — Labour / Community Welfare',
    },
    'eosb_hcs_india_embassy_desc': {
      'English':
          'Qatar-specific labour and community welfare section of the Indian Embassy in Doha.',
      'Arabic': 'قسم العمل والرعاية المجتمعية في السفارة الهندية بالدوحة.',
      'Hindi': 'दोहा में Indian Embassy का labour/community welfare section।',
      'Urdu': 'دوحہ میں Indian Embassy کا labour/community welfare section۔',
      'Malayalam':
          'ദോഹയിലെ Indian Embassy-യുടെ labour/community welfare വിഭാഗം.',
      'Nepali': 'Doha मा Indian Embassy को labour/community welfare खण्ड।',
      'Bengali': 'দোহায় Indian Embassy-র labour/community welfare বিভাগ।',
      'Filipino':
          'Labour at community welfare section ng Indian Embassy sa Doha.',
      'Tamil':
          'தoha-வில் Indian Embassy-யின் Qatar-குறிப்பிட்ட labour மற்றும் community welfare பிரிவு.',
    },
    'eosb_hcs_pbsk_title': {
      'English': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
      'Arabic': 'PBSK — مكتب مساعدة الهنديين في الخارج',
      'Hindi': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
      'Urdu': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
      'Malayalam': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
      'Nepali': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
      'Bengali': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
      'Filipino': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
      'Tamil': 'Pravasi Bharatiya Sahayata Kendra (PBSK)',
    },
    'eosb_hcs_pbsk_desc': {
      'English': 'Dedicated welfare help desk at the Indian Embassy in Doha.',
      'Arabic': 'مكتب مساعدة رعاية مخصص في السفارة الهندية بالدوحة.',
      'Hindi': 'दोहा Indian Embassy में dedicated welfare help desk।',
      'Urdu': 'دوحہ Indian Embassy میں dedicated welfare help desk۔',
      'Malayalam': 'ദോഹ Indian Embassy-യിലെ dedicated welfare help desk.',
      'Nepali': 'Doha Indian Embassy मा dedicated welfare help desk।',
      'Bengali': 'দোহা Indian Embassy-তে dedicated welfare help desk।',
      'Filipino': 'Dedicated welfare help desk sa Indian Embassy sa Doha.',
      'Tamil': 'Doha Indian Embassy-யில் dedicated welfare help desk.',
    },
    'eosb_hcs_pbsk_hours_value': {
      'English': 'Saturday–Thursday, 8am–5pm',
      'Arabic': 'السبت–الخميس، 8ص–5م',
      'Hindi': 'शनिवार–गुरुवार, 8am–5pm',
      'Urdu': 'ہفتہ–جمعرات، 8am–5pm',
      'Malayalam': 'ശനി–വ്യാഴം, 8am–5pm',
      'Nepali': 'शनि–बिही, 8am–5pm',
      'Bengali': 'শনি–বৃহস্পতি, 8am–5pm',
      'Filipino': 'Sabado–Huwebes, 8am–5pm',
      'Tamil': 'சனி–வியா, 8am–5pm',
    },
    'eosb_hcs_kerala_section_title': {
      'English': 'Kerala state support (additional)',
      'Arabic': 'دعم ولاية كerala (إضافي)',
      'Hindi': 'Kerala राज्य सहायता (अतिरिक्त)',
      'Urdu': 'Kerala ریاستی معاونت (اضافی)',
      'Malayalam': 'കerala സംസ്ഥാന സഹായം (കൂടുതൽ)',
      'Nepali': 'Kerala राज्य सहयोग (थप)',
      'Bengali': 'Kerala রাজ্য সহায়তা (অতিরিক্ত)',
      'Filipino': 'Karagdagang suporta mula sa Kerala',
      'Tamil': 'Kerala மாநில ஆதரவு (கூடுதல்)',
    },
    'eosb_hcs_norka_care_title': {
      'English': 'NORKA CARE',
      'Arabic': 'NORKA CARE',
      'Hindi': 'NORKA CARE',
      'Urdu': 'NORKA CARE',
      'Malayalam': 'NORKA CARE',
      'Nepali': 'NORKA CARE',
      'Bengali': 'NORKA CARE',
      'Filipino': 'NORKA CARE',
      'Tamil': 'NORKA CARE',
    },
    'eosb_hcs_norka_care_desc': {
      'English':
          'Kerala state health and accident insurance for Non-Resident Keralites (NRKs). Advertised cover: ₹5 lakh health + ₹10 lakh accident — verify current enrolment eligibility and premium/fee before applying.',
      'Arabic':
          'تأمين صحي وحوادث لولاية Kerala للكeralites غير المقيمين — تحقق من الأهلية والرسوم.',
      'Hindi':
          'NRK के लिए Kerala state health/accident insurance। विज्ञापित: ₹5L health + ₹10L accident — enrolment eligibility और premium verify करें।',
      'Urdu':
          'NRK کے لیے Kerala state health/accident insurance — eligibility اور premium verify کریں۔',
      'Malayalam':
          'NRK-കൾക്കുള്ള Kerala state health/accident insurance. പരസ്യം: ₹5 lakh health + ₹10 lakh accident — enrolment eligibility, premium verify ചെയ്യുക.',
      'Nepali':
          'NRK का लागि Kerala state health/accident insurance — eligibility र premium verify गर्नुहोस्।',
      'Bengali':
          'NRK-দের জন্য Kerala state health/accident insurance — eligibility ও premium যাচাই করুন।',
      'Filipino':
          'Health at accident insurance ng Kerala para sa NRKs — i-verify ang eligibility at premium.',
      'Tamil':
          'Non-Resident Keralites (NRK)-க்கான Kerala மாநில health மற்றும் accident insurance. விளம்பர coverage: ₹5 lakh health + ₹10 lakh accident — enrolment eligibility மற்றும் premium/fee-ஐ apply செய்வதற்கு முன் சரிபார்க்கவும்.',
    },
    'eosb_hcs_ndprem_title': {
      'English': 'NDPREM',
      'Arabic': 'NDPREM',
      'Hindi': 'NDPREM',
      'Urdu': 'NDPREM',
      'Malayalam': 'NDPREM',
      'Nepali': 'NDPREM',
      'Bengali': 'NDPREM',
      'Filipino': 'NDPREM',
      'Tamil': 'NDPREM',
    },
    'eosb_hcs_ndprem_desc': {
      'English':
          'Kerala state returnee-entrepreneur loan scheme via SBI, up to ₹30 lakh — verify current eligibility criteria and application process before applying.',
      'Arabic':
          'قرض ريادة الأعمال للعائدين عبر SBI حتى ₹30 lakh — تحقق من الأهلية.',
      'Hindi':
          'SBI के माध्यम से Kerala returnee-entrepreneur loan, ₹30 lakh तक — eligibility और application process verify करें।',
      'Urdu':
          'SBI کے ذریعے Kerala returnee-entrepreneur loan، ₹30 lakh تک — eligibility verify کریں۔',
      'Malayalam':
          'SBI വഴി Kerala returnee-entrepreneur loan, ₹30 lakh വരെ — eligibility, application process verify ചെയ്യുക.',
      'Nepali':
          'SBI मार्फत Kerala returnee-entrepreneur loan, ₹30 lakh सम्म — eligibility verify गर्नुहोस्।',
      'Bengali':
          'SBI-র মাধ্যমে Kerala returnee-entrepreneur loan, ₹30 lakh পর্যন্ত — eligibility যাচাই করুন।',
      'Filipino':
          'Returnee-entrepreneur loan ng Kerala via SBI hanggang ₹30 lakh — i-verify ang eligibility.',
      'Tamil':
          'SBI வழியாக Kerala returnee-entrepreneur loan scheme, ₹30 lakh வரை — eligibility criteria மற்றும் application process-ஐ apply செய்வதற்கு முன் சரிபார்க்கவும்.',
    },
    'eosb_hcs_pravasi_legal_aid_title': {
      'English': 'Pravasi Legal Aid Cell',
      'Arabic': 'Pravasi Legal Aid Cell',
      'Hindi': 'Pravasi Legal Aid Cell',
      'Urdu': 'Pravasi Legal Aid Cell',
      'Malayalam': 'Pravasi Legal Aid Cell',
      'Nepali': 'Pravasi Legal Aid Cell',
      'Bengali': 'Pravasi Legal Aid Cell',
      'Filipino': 'Pravasi Legal Aid Cell',
      'Tamil': 'Pravasi Legal Aid Cell',
    },
    'eosb_hcs_pravasi_legal_aid_desc': {
      'English':
          'Free legal consultation service for Non-Resident Keralites (NRKs) — verify current contact method (URL/phone) before use.',
      'Arabic':
          'استشارة قانونية مجانية للكeralites غير المقيمين — تحقق من وسيلة الاتصال.',
      'Hindi':
          'NRK के लिए मुफ्त legal consultation — contact method (URL/phone) verify करें।',
      'Urdu': 'NRK کے لیے مفت legal consultation — contact method verify کریں۔',
      'Malayalam':
          'NRK-കൾക്ക് സൗജന്യ legal consultation — contact method (URL/phone) verify ചെയ്യുക.',
      'Nepali':
          'NRK का लागि नि:शुल्क legal consultation — contact method verify गर्नुहोस्।',
      'Bengali':
          'NRK-দের জন্য বিনামূল্যে legal consultation — contact method যাচাই করুন।',
      'Filipino':
          'Libreng legal consultation para sa NRKs — i-verify ang contact method.',
      'Tamil':
          'Non-Resident Keralites (NRK)-க்கான இலவச சட்ட ஆலோசனை — contact method (URL/phone)-ஐ பயன்படுத்துவதற்கு முன் சரிபார்க்கவும்.',
    },
    'eosb_hcs_contact_address': {
      'English': 'Address',
      'Arabic': 'العنوان',
      'Hindi': 'पता',
      'Urdu': 'پتہ',
      'Malayalam': 'വിലാസം',
      'Nepali': 'ठेगाना',
      'Bengali': 'ঠিকানা',
      'Filipino': 'Address',
      'Tamil': 'முகவரி',
    },
    'eosb_hcs_contact_labour_phone': {
      'English': 'Labour tel',
      'Arabic': 'هاتف العمل',
      'Hindi': 'Labour tel',
      'Urdu': 'Labour tel',
      'Malayalam': 'Labour tel',
      'Nepali': 'Labour tel',
      'Bengali': 'Labour tel',
      'Filipino': 'Labour tel',
      'Tamil': 'Labour tel',
    },
    'eosb_hcs_contact_labour_phone_alt': {
      'English': 'Labour tel (alt)',
      'Arabic': 'هاتف العمل (بديل)',
      'Hindi': 'Labour tel (alt)',
      'Urdu': 'Labour tel (alt)',
      'Malayalam': 'Labour tel (alt)',
      'Nepali': 'Labour tel (alt)',
      'Bengali': 'Labour tel (alt)',
      'Filipino': 'Labour tel (alt)',
      'Tamil': 'Labour tel (alt)',
    },
    'eosb_hcs_contact_labour_email': {
      'English': 'Labour email',
      'Arabic': 'بريد العمل',
      'Hindi': 'Labour email',
      'Urdu': 'Labour email',
      'Malayalam': 'Labour email',
      'Nepali': 'Labour email',
      'Bengali': 'Labour email',
      'Filipino': 'Labour email',
      'Tamil': 'Labour email',
    },
    'eosb_hcs_contact_phone': {
      'English': 'Tel',
      'Arabic': 'هاتف',
      'Hindi': 'Tel',
      'Urdu': 'Tel',
      'Malayalam': 'Tel',
      'Nepali': 'Tel',
      'Bengali': 'Tel',
      'Filipino': 'Tel',
      'Tamil': 'Tel',
    },
    'eosb_hcs_contact_hours': {
      'English': 'Hours',
      'Arabic': 'الساعات',
      'Hindi': 'Hours',
      'Urdu': 'Hours',
      'Malayalam': 'സമയം',
      'Nepali': 'Hours',
      'Bengali': 'Hours',
      'Filipino': 'Hours',
      'Tamil': 'நேரம்',
    },
    'eosb_hcs_contact_hotline': {
      'English': 'Hotline',
      'Arabic': 'الخط الساخن',
      'Hindi': 'Hotline',
      'Urdu': 'ہاٹ لائن',
      'Malayalam': 'Hotline',
      'Nepali': 'Hotline',
      'Bengali': 'Hotline',
      'Filipino': 'Hotline',
      'Tamil': 'Hotline',
    },
    'eosb_hcs_country_india': {
      'English': 'India',
      'Arabic': 'الهند',
      'Hindi': 'भारत',
      'Urdu': 'بھارت',
      'Malayalam': 'India',
      'Nepali': 'India',
      'Bengali': 'ভারত',
      'Filipino': 'India',
      'Tamil': 'India',
    },
    'eosb_hcs_country_nepal': {
      'English': 'Nepal',
      'Arabic': 'نيبال',
      'Hindi': 'Nepal',
      'Urdu': 'Nepal',
      'Malayalam': 'Nepal',
      'Nepali': 'नेपाल',
      'Bengali': 'Nepal',
      'Filipino': 'Nepal',
      'Tamil': 'Nepal',
    },
    'eosb_hcs_country_philippines': {
      'English': 'Philippines',
      'Arabic': 'الفلبين',
      'Hindi': 'Philippines',
      'Urdu': 'Philippines',
      'Malayalam': 'Philippines',
      'Nepali': 'Philippines',
      'Bengali': 'Philippines',
      'Filipino': 'Pilipinas',
      'Tamil': 'Philippines',
    },
    'agency_verify_origin_country_heading': {
      'English': 'Origin-country recruitment agencies',
      'Arabic': 'وكالات التوظيف في بلد المنشأ',
      'Hindi': 'मूल देश की भर्ती एजेंसियां',
      'Urdu': 'اصل ملک کی بھرتی ایجنسیز',
      'Malayalam': 'Origin-country recruitment agencies',
      'Nepali': 'Origin-country recruitment agencies',
      'Bengali': 'Origin-country recruitment agencies',
      'Filipino': 'Origin-country recruitment agencies',
      'Tamil': 'Origin-country recruitment agencies',
    },
    'agency_verify_origin_country_hint': {
      'English':
          'If you used a recruitment agency before arriving in Qatar, verify it through your home country\'s official portal below.',
      'Arabic':
          'إذا استخدمت وكالة توظيف قبل الوصول إلى قطر، تحقق منها عبر البوابة الرسمية لبلدك أدناه.',
      'Hindi':
          'कतर पहुंचने से पहले अगर आपने भर्ती एजेंसी का उपयोग किया, तो नीचे अपने देश के आधिकारिक पोर्टल से सत्यापित करें।',
      'Urdu':
          'اگر قطر پہنچنے سے پہلے آپ نے بھرتی ایجنسی استعمال کی، تو نیچے اپنے ملک کے سرکاری پورٹل سے تصدیق کریں۔',
      'Malayalam':
          'If you used a recruitment agency before arriving in Qatar, verify it through your home country\'s official portal below.',
      'Nepali':
          'If you used a recruitment agency before arriving in Qatar, verify it through your home country\'s official portal below.',
      'Bengali':
          'If you used a recruitment agency before arriving in Qatar, verify it through your home country\'s official portal below.',
      'Filipino':
          'If you used a recruitment agency before arriving in Qatar, verify it through your home country\'s official portal below.',
      'Tamil':
          'If you used a recruitment agency before arriving in Qatar, verify it through your home country\'s official portal below.',
    },
    'eosb_hcs_nepal_dofa_title': {
      'English': 'DOFE — Department of Foreign Employment',
      'Arabic': 'DOFE — إدارة التوظيف الخارجي',
      'Hindi': 'DOFE — Department of Foreign Employment',
      'Urdu': 'DOFE — Department of Foreign Employment',
      'Malayalam': 'DOFE — Department of Foreign Employment',
      'Nepali': 'DOFE — विदेश रोजगार विभाग',
      'Bengali': 'DOFE — Department of Foreign Employment',
      'Filipino': 'DOFE — Department of Foreign Employment',
      'Tamil': 'DOFE — Department of Foreign Employment',
    },
    'eosb_hcs_nepal_dofa_desc': {
      'English':
          'Government body overseeing foreign employment approval, licensing of recruitment agencies, and worker welfare. Verify current portal URL and services on official sources.',
      'Arabic':
          'الجهة الحكومية المشرفة على التوظيف الخارجي وترخيص الوكالات — تحقق من المصادر الرسمية.',
      'Hindi':
          'Foreign employment approval, agency licensing, worker welfare — official sources पर verify करें।',
      'Urdu':
          'Foreign employment approval, agency licensing — سرکاری ذرائع سے verify کریں۔',
      'Malayalam':
          'Foreign employment approval, agency licensing, worker welfare — official sources-ൽ verify ചെയ്യുക.',
      'Nepali':
          'विदेश रोजगार स्वीकृति, agency licensing, worker welfare — आधिकारिक स्रोतबाट verify गर्नुहोस्।',
      'Bengali':
          'Foreign employment approval, agency licensing — official sources-এ verify করুন।',
      'Filipino':
          'Foreign employment approval, agency licensing — i-verify sa opisyal na sources.',
      'Tamil':
          'Foreign employment approval, recruitment agencies licensing, worker welfare-ஐ மேற்பார்வையிடும் அரசு அமைப்பு. அதிகாரப்பூர்வ மூலங்களில் portal URL மற்றும் சேவைகளை சரிபார்க்கவும்.',
    },
    'eosb_hcs_nepal_feb_title': {
      'English': 'Foreign Employment Board (FEB)',
      'Arabic': 'مجلس التوظيف الخارجي',
      'Hindi': 'Foreign Employment Board (FEB)',
      'Urdu': 'Foreign Employment Board (FEB)',
      'Malayalam': 'Foreign Employment Board (FEB)',
      'Nepali': 'विदेश रोजगार बोर्ड (FEB)',
      'Bengali': 'Foreign Employment Board (FEB)',
      'Filipino': 'Foreign Employment Board (FEB)',
      'Tamil': 'Foreign Employment Board (FEB)',
    },
    'eosb_hcs_nepal_feb_desc': {
      'English':
          'Welfare fund and worker protection under Nepal\'s Foreign Employment Act. Verify current benefits and contact details on official sources.',
      'Arabic': 'صندوق رعاية وحماية العمال — تحقق من المصادر الرسمية.',
      'Hindi':
          'Welfare fund, worker protection — official sources पर verify करें।',
      'Urdu': 'Welfare fund, worker protection — سرکاری ذرائع سے verify کریں۔',
      'Malayalam':
          'Welfare fund, worker protection — official sources-ൽ verify ചെയ്യുക.',
      'Nepali':
          'कल्याण कोष, worker protection — आधिकारिक स्रोतबाट verify गर्नुहोस्।',
      'Bengali':
          'Welfare fund, worker protection — official sources-এ verify করুন।',
      'Filipino':
          'Welfare fund, worker protection — i-verify sa opisyal na sources.',
      'Tamil':
          'Nepal Foreign Employment Act-ன் கீழ் welfare fund மற்றும் worker protection. அதிகாரப்பூர்வ மூலங்களில் benefits மற்றும் contact details சரிபார்க்கவும்.',
    },
    'eosb_hcs_nepal_pre_departure_title': {
      'English': 'Pre-departure requirements (informational)',
      'Arabic': 'متطلبات ما قبل المغادرة (إرشادي)',
      'Hindi': 'Pre-departure requirements (informational)',
      'Urdu': 'Pre-departure requirements (informational)',
      'Malayalam': 'Pre-departure requirements (informational)',
      'Nepali': 'प्रस्थान अघि आवश्यकताहरू (जानकारी)',
      'Bengali': 'Pre-departure requirements (informational)',
      'Filipino': 'Pre-departure requirements (informational)',
      'Tamil': 'Pre-departure தேவைகள் (தகவல்)',
    },
    'eosb_hcs_nepal_pre_departure_desc': {
      'English':
          'Pre-departure orientation and labour permit are mandatory steps handled through DOFE before departure. Raabta does not verify your status — confirm with DOFE/FEIMS directly.',
      'Arabic':
          'التوجيه قبل المغادرة وتصريح العمل إلزاميان عبر DOFE — Raabta لا يتحقق من حالتك.',
      'Hindi':
          'Pre-departure orientation और labour permit DOFE के माध्यम से mandatory — Raabta status verify नहीं करता।',
      'Urdu':
          'Pre-departure orientation اور labour permit DOFE کے ذریعے لازمی — Raabta status verify نہیں کرتا۔',
      'Malayalam':
          'Pre-departure orientation, labour permit DOFE വഴി mandatory — Raabta status verify ചെയ്യില്ല.',
      'Nepali':
          'Pre-departure orientation, labour permit DOFE मार्फत अनिवार्य — Raabta ले status verify गर्दैन।',
      'Bengali':
          'Pre-departure orientation, labour permit DOFE-র মাধ্যমে বাধ্যতামূলক — Raabta status verify করে না।',
      'Filipino':
          'Pre-departure orientation at labour permit ay mandatory sa DOFE — hindi i-verify ng Raabta ang status mo.',
      'Tamil':
          'Pre-departure orientation மற்றும் labour permit புறப்படுவதற்கு முன் DOFE வழியாக கட்டாய படிகள். Raabta உங்கள் status-ஐ verify செய்யாது — DOFE/FEIMS-ஐ நேரடியாக உறுதிப்படுத்தவும்.',
    },
    'eosb_hcs_ph_dmw_title': {
      'English': 'DMW — Department of Migrant Workers',
      'Arabic': 'DMW — وزارة العمالة المغتربة',
      'Hindi': 'DMW — Department of Migrant Workers',
      'Urdu': 'DMW — Department of Migrant Workers',
      'Malayalam': 'DMW — Department of Migrant Workers',
      'Nepali': 'DMW — Department of Migrant Workers',
      'Bengali': 'DMW — Department of Migrant Workers',
      'Filipino': 'DMW — Department of Migrant Workers',
      'Tamil': 'DMW — Department of Migrant Workers',
    },
    'eosb_hcs_ph_dmw_desc': {
      'English':
          'Licensing authority for recruitment agencies, complaint-handling body. Hotline 1348 — verify current number and services on official DMW sources.',
      'Arabic': 'ترخيص الوكالات ومعالجة الشكاوى — تحقق من الرقم 1348 رسمياً.',
      'Hindi':
          'Agency licensing, complaints — hotline 1348 official sources पर verify करें।',
      'Urdu':
          'Agency licensing, complaints — hotline 1348 سرکاری ذرائع سے verify کریں۔',
      'Malayalam':
          'Agency licensing, complaints — hotline 1348 official sources-ൽ verify ചെയ്യുക.',
      'Nepali':
          'Agency licensing, complaints — hotline 1348 आधिकारिक स्रोतबाट verify गर्नुहोस्।',
      'Bengali':
          'Agency licensing, complaints — hotline 1348 official sources-এ verify করুন।',
      'Filipino':
          'Licensing ng agencies, complaint handling — i-verify ang hotline 1348 sa opisyal na DMW.',
      'Tamil':
          'Recruitment agencies licensing, complaint-handling அமைப்பு. Hotline 1348 — அதிகாரப்பூர்வ DMW மூலங்களில் எண் மற்றும் சேவைகளை சரிபார்க்கவும்.',
    },
    'eosb_hcs_ph_owwa_title': {
      'English': 'OWWA — Overseas Workers Welfare Administration',
      'Arabic': 'OWWA — إدارة رفاهية العمال في الخارج',
      'Hindi': 'OWWA — Overseas Workers Welfare Administration',
      'Urdu': 'OWWA — Overseas Workers Welfare Administration',
      'Malayalam': 'OWWA — Overseas Workers Welfare Administration',
      'Nepali': 'OWWA — Overseas Workers Welfare Administration',
      'Bengali': 'OWWA — Overseas Workers Welfare Administration',
      'Filipino': 'OWWA — Overseas Workers Welfare Administration',
      'Tamil': 'OWWA — Overseas Workers Welfare Administration',
    },
    'eosb_hcs_ph_owwa_desc': {
      'English':
          'Welfare benefits and repatriation assistance for OFWs. Verify current membership requirements and benefits on official OWWA sources.',
      'Arabic': 'مزايا الرفاهية وإعادة التوطين للعاملين — تحقق رسمياً.',
      'Hindi':
          'OFW welfare, repatriation — official OWWA sources पर verify करें।',
      'Urdu':
          'OFW welfare, repatriation — official OWWA sources سے verify کریں۔',
      'Malayalam':
          'OFW welfare, repatriation — official OWWA sources-ൽ verify ചെയ്യുക.',
      'Nepali':
          'OFW welfare, repatriation — official OWWA sources बाट verify गर्नुहोस्।',
      'Bengali':
          'OFW welfare, repatriation — official OWWA sources-এ verify করুন।',
      'Filipino':
          'Welfare benefits at repatriation para sa OFWs — i-verify sa opisyal na OWWA.',
      'Tamil':
          'OFW-க்கான welfare benefits மற்றும் repatriation assistance. அதிகாரப்பூர்வ OWWA மூலங்களில் membership requirements மற்றும் benefits சரிபார்க்கவும்.',
    },
    'eosb_hcs_ph_mwo_title': {
      'English': 'MWO — Migrant Workers Office (formerly POLO)',
      'Arabic': 'MWO — مكتب العمال المغتربين',
      'Hindi': 'MWO — Migrant Workers Office (formerly POLO)',
      'Urdu': 'MWO — Migrant Workers Office (formerly POLO)',
      'Malayalam': 'MWO — Migrant Workers Office (formerly POLO)',
      'Nepali': 'MWO — Migrant Workers Office (formerly POLO)',
      'Bengali': 'MWO — Migrant Workers Office (formerly POLO)',
      'Filipino': 'MWO — Migrant Workers Office (dating POLO)',
      'Tamil': 'MWO — Migrant Workers Office (formerly POLO)',
    },
    'eosb_hcs_ph_mwo_desc': {
      'English':
          'On-site consular assistance, legal aid, and mediation at Philippine embassies/consulates abroad. Verify current office contacts for your location on official sources.',
      'Arabic': 'مساعدة قنصلية وقانونية في السفارات — تحقق رسمياً.',
      'Hindi':
          'Embassy/consulate legal aid, mediation — official sources पर verify करें।',
      'Urdu': 'Embassy/consulate legal aid — سرکاری ذرائع سے verify کریں۔',
      'Malayalam':
          'Embassy/consulate legal aid — official sources-ൽ verify ചെയ്യുക.',
      'Nepali':
          'Embassy/consulate legal aid — आधिकारिक स्रोतबाट verify गर्नुहोस्।',
      'Bengali':
          'Embassy/consulate legal aid — official sources-এ verify করুন।',
      'Filipino':
          'Consular assistance, legal aid sa embassies — i-verify sa opisyal na sources.',
      'Tamil':
          'Philippine embassies/consulates-ல் on-site consular assistance, சட்ட உதவி, mediation. அதிகாரப்பூர்வ மூலங்களில் உங்கள் location-க்கான office contacts சரிபார்க்கவும்.',
    },
    'eosb_bys_section_title': {
      'English': 'Before You Sign',
      'Arabic': 'قبل التوقيع',
      'Hindi': 'हस्ताक्षर से पहले',
      'Urdu': 'دستخط سے پہلے',
      'Malayalam': 'ഒപ്പിടുന്നതിന് മുമ്പ്',
      'Nepali': 'हस्ताक्षर अघि',
      'Bengali': 'সই করার আগে',
      'Filipino': 'Bago Pumirma',
      'Tamil': 'கையெழுத்திடுவதற்கு முன்',
    },
    'eosb_bys_section_subtitle': {
      'English':
          'Checklist only — Raabta does not verify employers or agencies. Use official government channels below.',
      'Arabic':
          'قائمة إرشادية فقط — Raabta لا يتحقق من صاحب العمل. استخدم القنوات الرسمية.',
      'Hindi':
          'केवल checklist — Raabta employer verify नहीं करता। official channels उपयोग करें।',
      'Urdu':
          'صرف checklist — Raabta employer verify نہیں کرتا۔ سرکاری channels استعمال کریں۔',
      'Malayalam':
          'Checklist മാത്രം — Raabta employer verify ചെയ്യില്ല. official channels ഉപയോഗിക്കുക.',
      'Nepali':
          'Checklist मात्र — Raabta ले employer verify गर्दैन। official channels प्रयोग गर्नुहोस्।',
      'Bengali':
          'শুধু checklist — Raabta employer verify করে না। official channels ব্যবহার করুন।',
      'Filipino':
          'Checklist lamang — hindi i-verify ng Raabta ang employer. Gamitin ang opisyal na channels.',
      'Tamil':
          'Checklist மட்டும் — Raabta முதலாளிகள் அல்லது agencies-ஐ verify செய்யாது. கீழே உள்ள அதிகாரப்பூர்வ அரசு channels பயன்படுத்துங்கள்.',
    },
    'eosb_bys_expand': {
      'English': 'Show checklist',
      'Arabic': 'عرض القائمة',
      'Hindi': 'Checklist दिखाएं',
      'Urdu': 'Checklist دکھائیں',
      'Malayalam': 'Checklist കാണിക്കുക',
      'Nepali': 'Checklist देखाउनुहोस्',
      'Bengali': 'Checklist দেখান',
      'Filipino': 'Ipakita ang checklist',
      'Tamil': 'Checklist காட்டு',
    },
    'eosb_bys_collapse': {
      'English': 'Hide checklist',
      'Arabic': 'إخفاء القائمة',
      'Hindi': 'Checklist छुपाएं',
      'Urdu': 'Checklist چھپائیں',
      'Malayalam': 'Checklist മറയ്ക്കുക',
      'Nepali': 'Checklist लुकाउनुहोस्',
      'Bengali': 'Checklist লুকান',
      'Filipino': 'Itago ang checklist',
      'Tamil': 'Checklist மறை',
    },
    'eosb_bys_fee_heading': {
      'English': 'Legal placement/recruitment fee limit',
      'Arabic': 'حد رسوم التوظيف القانونية',
      'Hindi': 'Legal placement/recruitment fee limit',
      'Urdu': 'Legal placement/recruitment fee limit',
      'Malayalam': 'Legal placement/recruitment fee limit',
      'Nepali': 'Legal placement/recruitment fee limit',
      'Bengali': 'Legal placement/recruitment fee limit',
      'Filipino': 'Legal placement/recruitment fee limit',
      'Tamil': 'சட்ட placement/recruitment fee வரம்பு',
    },
    'eosb_bys_flags_heading': {
      'English': 'Common red flags',
      'Arabic': 'علامات تحذير شائعة',
      'Hindi': 'Common red flags',
      'Urdu': 'Common red flags',
      'Malayalam': 'Common red flags',
      'Nepali': 'Common red flags',
      'Bengali': 'Common red flags',
      'Filipino': 'Common red flags',
      'Tamil': 'பொதுவான red flags',
    },
    'eosb_bys_origin_verify_heading': {
      'English': 'Verify via your home country',
      'Arabic': 'تحقق عبر بلدك الأصلي',
      'Hindi': 'अपने देश के official channels से verify करें',
      'Urdu': 'اپنے ملک کے official channels سے verify کریں',
      'Malayalam': 'നിങ്ങളുടെ നാട്ടിലെ official channels-ൽ verify ചെയ്യുക',
      'Nepali': 'आफ्नो देशको official channels बाट verify गर्नुहोस्',
      'Bengali': 'আপনার দেশের official channels-এ verify করুন',
      'Filipino': 'I-verify sa opisyal na channels ng inyong bansa',
      'Tamil': 'உங்கள் தாய்நாட்டின் மூலம் சரிபார்க்கவும்',
    },
    'eosb_bys_qatar_verify_heading': {
      'English': 'Verify via Qatar (all nationalities)',
      'Arabic': 'تحقق عبر قطر (جميع الجنسيات)',
      'Hindi': 'Qatar channels से verify करें (सभी nationalities)',
      'Urdu': 'Qatar channels سے verify کریں',
      'Malayalam': 'Qatar channels-ൽ verify ചെയ്യുക',
      'Nepali': 'Qatar channels बाट verify गर्नुहोस्',
      'Bengali': 'Qatar channels-এ verify করুন',
      'Filipino': 'I-verify sa Qatar channels',
      'Tamil': 'Qatar வழியாக சரிபார்க்கவும் (அனைத்து nationals)',
    },
    'eosb_bys_verify_disclaimer': {
      'English':
          'Links go to official portals only. Raabta never confirms an employer or agency is legitimate.',
      'Arabic': 'روابط للبوابات الرسمية فقط — Raabta لا يؤكد شرعية صاحب العمل.',
      'Hindi':
          'Official portals के links — Raabta employer legitimacy confirm नहीं करता।',
      'Urdu': 'Official portals links — Raabta legitimacy confirm نہیں کرتا۔',
      'Malayalam':
          'Official portals links — Raabta legitimacy confirm ചെയ്യില്ല.',
      'Nepali': 'Official portals links — Raabta ले legitimacy confirm गर्दैन।',
      'Bengali': 'Official portals links — Raabta legitimacy confirm করে না।',
      'Filipino':
          'Links sa opisyal na portals — hindi kino-confirm ng Raabta ang legitimacy.',
      'Tamil':
          'Links அதிகாரப்பூர்வ portals-க்கு மட்டும். Raabta முதலாளி அல்லது agency legitimate என்பதை உறுதிப்படுத்தாது.',
    },
    'eosb_bys_offer_real_title': {
      'English': 'Is This Offer Real?',
      'Arabic': 'هل هذا العرض حقيقي؟',
      'Hindi': 'क्या यह ऑफ़र असली है?',
      'Urdu': 'کیا یہ آفر حقیقی ہے؟',
      'Malayalam': 'Is This Offer Real?',
      'Nepali': 'Is This Offer Real?',
      'Bengali': 'এই অফার কি আসল?',
      'Filipino': 'Totoo ba ang Offer na Ito?',
      'Tamil': 'இந்த சலுகை உண்மையா?',
    },
    'eosb_bys_offer_real_intro': {
      'English':
          'Checklist only — not a scam score or verdict. You apply these checks yourself. AI-generated recruitment scams are rising; poor grammar alone is no longer a reliable signal. Raabta does not verify any specific offer, agency, or employer.',
      'Arabic':
          'قائمة إرشادية فقط — ليست تقييماً للاحتيال. احتيالات التوظيف بالذكاء الاصطناعي في ازدياد؛ الأخطاء اللغوية وحدها لم تعد دليلاً موثوقاً. Raabta لا يتحقق من أي عرض.',
      'Hindi':
          'केवल checklist — scam score नहीं। AI recruitment scams बढ़ रहे हैं; grammar errors अब पर्याप्त signal नहीं। Raabta किसी offer/agency verify नहीं करता — आप खुद apply करें।',
      'Urdu':
          'صرف checklist — scam score نہیں۔ AI recruitment scams بڑھ رہے ہیں؛ grammar errors اب کافی signal نہیں۔ Raabta کسی offer verify نہیں کرتا — آپ خود apply کریں۔',
      'Malayalam':
          'Checklist only — not a scam score or verdict. AI recruitment scams are rising; poor grammar alone is no longer a reliable signal. Raabta does not verify any specific offer.',
      'Nepali':
          'Checklist only — not a scam score or verdict. AI recruitment scams are rising; poor grammar alone is no longer a reliable signal. Raabta does not verify any specific offer.',
      'Bengali':
          'শুধু checklist — scam score নয়। AI recruitment scams বাড়ছে; grammar errors আর নির্ভরযোগ্য signal নয়। Raabta কোনো offer verify করে না — আপনি নিজে apply করুন।',
      'Filipino':
          'Checklist lamang — hindi scam score o verdict. Tumataas ang AI recruitment scams; hindi na sapat ang maling grammar. Hindi i-verify ng Raabta ang anumang offer — ikaw ang mag-apply.',
      'Tamil':
          'Checklist மட்டும் — scam score அல்லது verdict அல்ல. இந்த checks-ஐ நீங்களே apply செய்யுங்கள். AI-generated recruitment scams அதிகரித்து வருகின்றன; மோசமான grammar alone reliable signal அல்ல. Raabta எந்த குறிப்பிட்ட offer, agency, அல்லது employer-ஐ verify செய்யாது.',
    },
    'eosb_bys_offer_comm_heading': {
      'English': 'Communication red flags',
      'Arabic': 'علامات تحذير في التواصل',
      'Hindi': 'Communication red flags',
      'Urdu': 'Communication red flags',
      'Malayalam': 'Communication red flags',
      'Nepali': 'Communication red flags',
      'Bengali': 'Communication red flags',
      'Filipino': 'Communication red flags',
      'Tamil': 'Communication red flags',
    },
    'eosb_bys_offer_pay_heading': {
      'English': 'Payment red flags',
      'Arabic': 'علامات تحذير في الدفع',
      'Hindi': 'Payment red flags',
      'Urdu': 'Payment red flags',
      'Malayalam': 'Payment red flags',
      'Nepali': 'Payment red flags',
      'Bengali': 'Payment red flags',
      'Filipino': 'Payment red flags',
      'Tamil': 'Payment red flags',
    },
    'eosb_bys_offer_doc_heading': {
      'English': 'Documentation red flags',
      'Arabic': 'علامات تحذير في المستندات',
      'Hindi': 'Documentation red flags',
      'Urdu': 'Documentation red flags',
      'Malayalam': 'Documentation red flags',
      'Nepali': 'Documentation red flags',
      'Bengali': 'Documentation red flags',
      'Filipino': 'Documentation red flags',
      'Tamil': 'Documentation red flags',
    },
    'eosb_bys_offer_verify_heading': {
      'English': 'What to do before signing',
      'Arabic': 'ماذا تفعل قبل التوقيع',
      'Hindi': 'Sign करने से पहले क्या करें',
      'Urdu': 'Sign کرنے سے پہلے کیا کریں',
      'Malayalam': 'What to do before signing',
      'Nepali': 'What to do before signing',
      'Bengali': 'Sign করার আগে কী করবেন',
      'Filipino': 'Ano ang gawin bago pumirma',
      'Tamil': 'கையெழுத்திடுவதற்கு முன் என்ன செய்வது',
    },
    'eosb_bys_offer_comm_no_call': {
      'English':
          'Recruiter refuses any phone or video call — will not speak on a verifiable channel',
      'Arabic': 'يرفض المُوظّف أي مكالمة هاتفية أو فيديو',
      'Hindi': 'Recruiter phone/video call refuse करता है',
      'Urdu': 'Recruiter phone/video call refuse کرتا ہے',
      'Malayalam': 'Recruiter refuses phone or video call',
      'Nepali': 'Recruiter refuses phone or video call',
      'Bengali': 'Recruiter phone/video call refuse করে',
      'Filipino': 'Tumanggi ang recruiter sa phone o video call',
      'Tamil':
          'Recruiter எந்த phone அல்லது video call-ஐயும் மறுக்கிறார் — verify செய்யக்கூடிய channel-ல் பேச மறுக்கிறார்',
    },
    'eosb_bys_offer_comm_messaging_only': {
      'English':
          'Insists on WhatsApp, Telegram, or messaging apps only — no official company email or office contact',
      'Arabic': 'يصر على WhatsApp/Telegram فقط — لا بريد رسمي للشركة',
      'Hindi':
          'केवल WhatsApp/Telegram — कोई official company email/office contact नहीं',
      'Urdu': 'صرف WhatsApp/Telegram — کوئی official company email نہیں',
      'Malayalam': 'WhatsApp/Telegram only — no official company contact',
      'Nepali': 'WhatsApp/Telegram only — no official company contact',
      'Bengali': 'শুধু WhatsApp/Telegram — official company contact নেই',
      'Filipino': 'WhatsApp/Telegram lang — walang opisyal na company email',
      'Tamil':
          'WhatsApp, Telegram, அல்லது messaging apps மட்டும் — அதிகாரப்பூர்வ company email அல்லது office contact இல்லை',
    },
    'eosb_bys_offer_comm_free_email': {
      'English':
          'Recruiter uses a free email domain (Gmail, Yahoo, Hotmail) instead of a company domain',
      'Arabic': 'يستخدم بريداً مجانياً (Gmail/Yahoo) بدلاً من نطاق الشركة',
      'Hindi': 'Free email (Gmail/Yahoo) — company domain नहीं',
      'Urdu': 'Free email (Gmail/Yahoo) — company domain نہیں',
      'Malayalam': 'Free email (Gmail/Yahoo) instead of company domain',
      'Nepali': 'Free email (Gmail/Yahoo) instead of company domain',
      'Bengali': 'Free email (Gmail/Yahoo) — company domain নেই',
      'Filipino': 'Free email (Gmail/Yahoo) imbes na company domain',
      'Tamil':
          'Recruiter free email domain (Gmail, Yahoo, Hotmail) பயன்படுத்துகிறார் — company domain அல்ல',
    },
    'eosb_bys_offer_comm_pressure': {
      'English':
          'Unusual urgency or pressure to sign, pay, or travel quickly — "limited slots" or "offer expires today"',
      'Arabic': 'ضغط غير عادي للتوقيع أو الدفع أو السفر بسرعة',
      'Hindi': 'Sign/pay/travel के लिए unusual urgency या pressure',
      'Urdu': 'Sign/pay/travel کے لیے unusual urgency یا pressure',
      'Malayalam': 'Unusual pressure to sign, pay, or travel quickly',
      'Nepali': 'Unusual pressure to sign, pay, or travel quickly',
      'Bengali': 'Sign/pay/travel-এর জন্য unusual pressure',
      'Filipino':
          'Hindi pangkaraniwang pressure na pumirma, magbayad, o bumiyahe agad',
      'Tamil':
          'கையெழுத்திட, pay, அல்லது travel செய்ய unusual urgency அல்லது pressure — "limited slots" அல்லது "offer expires today"',
    },
    'eosb_bys_offer_pay_before_contract': {
      'English':
          'Any request for payment before a written contract is signed — including "processing" or "visa" fees upfront',
      'Arabic':
          'طلب دفع قبل توقيع عقد written — بما في ذلك رسوم "processing" أو "visa"',
      'Hindi':
          'Written contract sign होने से पहले कोई payment — "processing" या "visa" fees सहित',
      'Urdu':
          'Written contract sign ہونے سے پہلے کوئی payment — "processing" یا "visa" fees سمیت',
      'Malayalam':
          'Payment before signed written contract — including upfront "processing" fees',
      'Nepali':
          'Payment before signed written contract — including upfront fees',
      'Bengali':
          'Signed written contract-এর আগে payment — upfront "processing"/"visa" fees সহ',
      'Filipino':
          'Anumang bayad bago may signed written contract — kasama ang upfront "processing" fees',
      'Tamil':
          'Written contract கையெழுத்திடுவதற்கு முன் எந்த payment-உம் — "processing" அல்லது "visa" fees upfront உட்பட',
    },
    'eosb_bys_offer_pay_untraceable': {
      'English':
          'Payment requested via crypto, gift cards, or informal/untraceable money transfer',
      'Arabic': 'دفع عبر crypto أو بطاقات هدايا أو تحويل غير رسمي',
      'Hindi':
          'Crypto, gift cards, या informal/untraceable transfer से payment',
      'Urdu': 'Crypto, gift cards، یا informal/untraceable transfer سے payment',
      'Malayalam': 'Payment via crypto, gift cards, or untraceable transfer',
      'Nepali': 'Payment via crypto, gift cards, or untraceable transfer',
      'Bengali': 'Crypto, gift cards, বা untraceable transfer-এ payment',
      'Filipino': 'Bayad sa crypto, gift cards, o hindi matrace na transfer',
      'Tamil':
          'Crypto, gift cards, அல்லது informal/untraceable money transfer வழியாக payment கோரப்படுகிறது',
    },
    'eosb_bys_offer_pay_fee_mismatch': {
      'English':
          'Fees that do not match the legal placement-fee guidance for your country (see section below)',
      'Arabic': 'رسوم لا تطابق الحد القانوني لبلدك (انظر القسم أدناه)',
      'Hindi':
          'Fees आपके देश के legal placement-fee guidance से match नहीं करती (नीचे देखें)',
      'Urdu':
          'Fees آپ کے ملک کے legal placement-fee guidance سے match نہیں (نیچے دیکھیں)',
      'Malayalam':
          'Fees do not match your country\'s legal placement-fee guidance (see below)',
      'Nepali':
          'Fees do not match your country\'s legal placement-fee guidance (see below)',
      'Bengali':
          'Fees আপনার দেশের legal placement-fee guidance-এর সাথে match করে না (নিচে দেখুন)',
      'Filipino':
          'Fees na hindi tumutugma sa legal placement-fee guidance ng inyong bansa (tingnan sa ibaba)',
      'Tamil':
          'உங்கள் நாட்டின் சட்ட placement-fee guidance-உடன் fees பொருந்தவில்லை (கீழே பார்க்கவும்)',
    },
    'eosb_bys_offer_doc_no_contract': {
      'English':
          'No formal written contract is offered before you are asked to pay or travel',
      'Arabic': 'لا يُقدَّم عقد written رسمي قبل طلب الدفع أو السفر',
      'Hindi': 'Pay/travel से पहले कोई formal written contract नहीं',
      'Urdu': 'Pay/travel سے پہلے کوئی formal written contract نہیں',
      'Malayalam': 'No formal written contract before pay or travel',
      'Nepali': 'No formal written contract before pay or travel',
      'Bengali': 'Pay/travel-এর আগে formal written contract নেই',
      'Filipino': 'Walang formal written contract bago magbayad o bumiyahe',
      'Tamil':
          'Pay அல்லது travel கோருவதற்கு முன் formal written contract வழங்கப்படவில்லை',
    },
    'eosb_bys_offer_doc_informal_only': {
      'English':
          'Offer exists only as verbal promises or informal chat messages — nothing you can keep and show',
      'Arabic': 'العرض verbal أو رسائل chat فقط — لا مستند تحتفظ به',
      'Hindi': 'Offer केवल verbal या informal chat में — कोई document नहीं',
      'Urdu': 'Offer صرف verbal یا informal chat میں — کوئی document نہیں',
      'Malayalam': 'Offer is verbal-only or informal chat messages only',
      'Nepali': 'Offer is verbal-only or informal chat messages only',
      'Bengali': 'Offer শুধু verbal বা informal chat — কোনো document নেই',
      'Filipino':
          'Offer ay verbal lang o sa chat — walang dokumentong maipapakita',
      'Tamil':
          'Offer verbal promises அல்லது informal chat messages-ஆக மட்டும் — வைத்திருக்கவும் காட்டவும் எதுவும் இல்லை',
    },
    'eosb_bys_offer_doc_no_registration': {
      'English':
          'Company or agency has no verifiable registration, license number, or physical address you can check',
      'Arabic': 'لا تسجيل أو رخصة أو عنوان فعلي يمكن التحقق منه',
      'Hindi':
          'Company/agency का verifiable registration, license, या address नहीं',
      'Urdu':
          'Company/agency کا verifiable registration، license، یا address نہیں',
      'Malayalam': 'No verifiable registration, license, or physical address',
      'Nepali': 'No verifiable registration, license, or physical address',
      'Bengali': 'Verifiable registration, license, বা physical address নেই',
      'Filipino': 'Walang verifiable registration, license, o physical address',
      'Tamil':
          'Company அல்லது agency-க்கு verify செய்யக்கூடிய registration, license number, அல்லது physical address இல்லை',
    },
    'eosb_bys_offer_doc_vague_details': {
      'English':
          'Job details are vague — employer name unclear, exact role undefined, or salary not stated in writing',
      'Arabic': 'تفاصيل الوظيفة غامضة — صاحب العمل أو الدور أو الراتب غير واضح',
      'Hindi':
          'Job details vague — employer, exact role, या salary writing में नहीं',
      'Urdu':
          'Job details vague — employer، exact role، یا salary writing میں نہیں',
      'Malayalam':
          'Vague job details — employer, role, or salary not in writing',
      'Nepali': 'Vague job details — employer, role, or salary not in writing',
      'Bengali': 'Vague job details — employer, role, বা salary writing-এ নেই',
      'Filipino':
          'Malabo ang job details — employer, role, o salary hindi nakasulat',
      'Tamil':
          'Job details vague — employer பெயர் unclear, exact role undefined, அல்லது salary writing-ல் stated இல்லை',
    },
    'eosb_bys_offer_verify_agency': {
      'English':
          'Cross-check the recruiting agency on your home country\'s official licensing portal — use the links under "Verify via your home country" below (e-Migrate for India, FEIMS for Nepal, DMW for Philippines). Raabta does not verify agencies for you.',
      'Arabic':
          'تحقق من وكالة التوظيف عبر البوابة الرسمية لبلدك — استخدم الروابط في "Verify via your home country" أدناه. Raabta لا يتحقق نيابة عنك.',
      'Hindi':
          'Recruiting agency को home country official portal पर cross-check करें — नीचे "Verify via your home country" links (India: e-Migrate, Nepal: FEIMS, Philippines: DMW)। Raabta verify नहीं करता।',
      'Urdu':
          'Recruiting agency کو home country official portal پر cross-check کریں — نیچے "Verify via your home country" links (India: e-Migrate, Nepal: FEIMS, Philippines: DMW)۔ Raabta verify نہیں کرتا۔',
      'Malayalam':
          'Cross-check agency on your home country official portal — use links under "Verify via your home country" below (e-Migrate, FEIMS, DMW). Raabta does not verify for you.',
      'Nepali':
          'Cross-check agency on your home country official portal — use links under "Verify via your home country" below. Raabta does not verify for you.',
      'Bengali':
          'Recruiting agency home country official portal-এ cross-check করুন — নিচে "Verify via your home country" links ব্যবহার করুন। Raabta verify করে না।',
      'Filipino':
          'I-cross-check ang agency sa opisyal na portal ng inyong bansa — gamitin ang links sa "Verify via your home country" sa ibaba (e-Migrate, FEIMS, DMW). Hindi i-verify ng Raabta para sa inyo.',
      'Tamil':
          'Recruiting agency-ஐ உங்கள் தாய்நாட்டின் அதிகாரப்பூர்வ licensing portal-ல் cross-check செய்யுங்கள் — கீழே "Verify via your home country" links (India: e-Migrate, Nepal: FEIMS, Philippines: DMW). Raabta agencies-ஐ verify செய்யாது.',
    },
    'eosb_bys_offer_verify_employer': {
      'English':
          'Independently verify the employer/company (official website, business registration, embassy advisories) before signing — do not rely on the recruiter\'s word alone',
      'Arabic':
          'تحقق مستقلاً من صاحب العمل قبل التوقيع — لا تعتمد على كلام المُوظّف فقط',
      'Hindi':
          'Sign से पहले employer independently verify करें — recruiter की बात पर alone भरोसा न करें',
      'Urdu':
          'Sign سے پہلے employer independently verify کریں — recruiter کی بات پر alone بھروسہ نہ کریں',
      'Malayalam':
          'Independently verify employer before signing — do not rely on recruiter alone',
      'Nepali':
          'Independently verify employer before signing — do not rely on recruiter alone',
      'Bengali':
          'Sign করার আগে employer independently verify করুন — recruiter-এর কথায় alone rely করবেন না',
      'Filipino':
          'I-verify nang independyente ang employer bago pumirma — huwag umasa sa recruiter lang',
      'Tamil':
          'கையெழுத்திடுவதற்கு முன் employer/company-ஐ independently verify செய்யுங்கள் (official website, business registration, embassy advisories) — recruiter-ன் வார்த்தையை alone நம்ப வேண்டாம்',
    },
    'eosb_bys_offer_verify_contract': {
      'English':
          'Insist on a written contract before any payment or travel commitment — read it fully and keep a copy',
      'Arabic': 'اشترط عقداً written قبل أي دفع أو سفر — اقرأه واحتفظ بنسخة',
      'Hindi':
          'किसी payment/travel commitment से पहले written contract insist करें — पूरा पढ़ें और copy रखें',
      'Urdu':
          'کisi payment/travel commitment سے پہلے written contract insist کریں — پورا پڑھیں اور copy رکھیں',
      'Malayalam':
          'Insist on written contract before any payment or travel — read fully and keep a copy',
      'Nepali':
          'Insist on written contract before any payment or travel — read fully and keep a copy',
      'Bengali':
          'যেকোনো payment/travel commitment-এর আগে written contract insist করুন — পুরো পড়ুন ও copy রাখুন',
      'Filipino':
          'Humiling ng written contract bago magbayad o bumiyahe — basahin buo at magtabi ng kopya',
      'Tamil':
          'எந்த payment அல்லது travel commitment-க்கும் முன் written contract insist செய்யுங்கள் — முழுமையாக படித்து copy வைத்திருங்கள்',
    },
    'eosb_bys_india_fee': {
      'English':
          'Under the Emigration Act 1983 (official Indian consular advisories, 2026): maximum legal placement/recruitment fee is ₹30,000 + 18% GST (~₹35,400 total). Older undated embassy pages citing ₹20,000 or 45 days\' wages are superseded — do not use that figure.',
      'Arabic':
          'بموجب قانون الهجرة 1983: الحد الأقصى ₹30,000 + 18% GST (~₹35,400). الرقم القديم ₹20,000 لم يعد سارياً.',
      'Hindi':
          'Emigration Act 1983 (2026 consular advisories): अधिकतम legal fee ₹30,000 + 18% GST (~₹35,400)। पुराना ₹20,000 या 45 days\' wages वाला figure superseded — उस पर भरोसा न करें।',
      'Urdu':
          'Emigration Act 1983: max legal fee ₹30,000 + 18% GST (~₹35,400)۔ پرانا ₹20,000 figure superseded ہے۔',
      'Malayalam':
          'Emigration Act 1983 (2026 consular advisories): max legal fee ₹30,000 + 18% GST (~₹35,400). പഴയ ₹20,000 / 45 days\' wages figure superseded — അത് ഉപയോഗിക്കരുത്.',
      'Nepali':
          'Emigration Act 1983: max legal fee ₹30,000 + 18% GST (~₹35,400)। पुरानो ₹20,000 figure superseded।',
      'Bengali':
          'Emigration Act 1983: max legal fee ₹30,000 + 18% GST (~₹35,400)। পুরোনো ₹20,000 figure superseded।',
      'Filipino':
          'Emigration Act 1983: max legal fee ₹30,000 + 18% GST (~₹35,400). Superseded na ang lumang ₹20,000 figure.',
      'Tamil':
          'Emigration Act 1983 (அதிகாரப்பூர்வ Indian consular advisories, 2026): அதிகபட்ச சட்ட placement/recruitment fee ₹30,000 + 18% GST (~₹35,400 total). பழைய undated embassy pages ₹20,000 அல்லது 45 days\' wages குறிப்பிடுவது superseded — அந்த figure பயன்படுத்த வேண்டாம்.',
    },
    'eosb_bys_india_fee_bill_warning': {
      'English':
          'Draft Overseas Mobility (Facilitation & Welfare) Bill, 2025 is before Parliament and would replace the Emigration Act 1983 framework (Recruiting Agents → Overseas Placement Agencies). Re-verify this fee limit if that bill passes — it may go stale on its own timeline.',
      'Arabic':
          'مشروع قانون 2025 قد يحل محل قانون 1983 — أعد التحقق من الحد إذا مُرّ.',
      'Hindi':
          'Overseas Mobility Bill, 2025 Parliament में है — Emigration Act 1983 replace कर सकता है। Bill pass होने पर fee limit दोबारा verify करें।',
      'Urdu':
          'Overseas Mobility Bill, 2025 — Emigration Act 1983 replace کر سکتا ہے۔ Bill pass ہونے پر fee limit دوبارہ verify کریں۔',
      'Malayalam':
          'Overseas Mobility Bill, 2025 Parliament-ൽ — Emigration Act 1983 replace ചെയ്യാം. Bill pass ആയാൽ fee limit വീണ്ടും verify ചെയ്യുക.',
      'Nepali':
          'Overseas Mobility Bill, 2025 — Emigration Act 1983 replace गर्न सक्छ। Bill pass भए fee limit पुन: verify गर्नुहोस्।',
      'Bengali':
          'Overseas Mobility Bill, 2025 — Emigration Act 1983 replace করতে পারে। Bill pass হলে fee limit আবার verify করুন।',
      'Filipino':
          'Overseas Mobility Bill, 2025 — puwedeng palitan ang Emigration Act 1983. I-verify ulit ang fee limit kung maipasa.',
      'Tamil':
          'Draft Overseas Mobility (Facilitation & Welfare) Bill, 2025 Parliament-ல் உள்ளது — Emigration Act 1983 framework-ஐ replace செய்யலாம் (Recruiting Agents → Overseas Placement Agencies). Bill pass ஆனால் fee limit-ஐ re-verify செய்யுங்கள்.',
    },
    'eosb_bys_india_flag_pay_before_contract': {
      'English':
          'Asked to pay above the legal cap (~₹35,400 incl. GST) or large fees before a written contract is provided',
      'Arabic': 'طلب دفع أكثر من ~₹35,400 أو رسوم كبيرة قبل عقد written',
      'Hindi':
          'Legal cap (~₹35,400 incl. GST) से अधिक या contract से पहले बड़ी fees',
      'Urdu': 'Legal cap (~₹35,400) سے زیادہ یا contract سے پہلے بڑی fees',
      'Malayalam':
          'Legal cap (~₹35,400) കവിഞ്ഞതോ written contract മുമ്പ് വലിയ fees',
      'Nepali': 'Legal cap (~₹35,400) भन्दा बढी वा contract अघि ठूलो fees',
      'Bengali': 'Legal cap (~₹35,400) এর বেশি বা contract-এর আগে বড় fees',
      'Filipino':
          'Hiningi ang higit sa ~₹35,400 o malaking bayad bago ang contract',
      'Tamil':
          'சட்ட cap (~₹35,400 incl. GST)க்கு மேல் pay கோரப்படுகிறதா அல்லது written contract வழங்குவதற்கு முன் பெரிய fees',
    },
    'eosb_bys_india_flag_no_written_contract': {
      'English': 'No written employment contract in a language you understand',
      'Arabic': 'لا يوجد عقد عمل written بلغة تفهمها',
      'Hindi': 'समझ की भाषा में written employment contract नहीं',
      'Urdu': 'سمجھ کی زبان میں written contract نہیں',
      'Malayalam': 'മനസ്സിലാകുന്ന ഭാഷയിൽ written contract ഇല്ല',
      'Nepali': 'बुझ्ने भाषामा written contract छैन',
      'Bengali': 'বোঝার ভাষায় written contract নেই',
      'Filipino': 'Walang written contract sa wikang nauunawaan mo',
      'Tamil':
          'நீங்கள் புரிந்துகொள்ளும் மொழியில் written employment contract இல்லை',
    },
    'eosb_bys_india_flag_agency_not_emigrate': {
      'English':
          'Recruiting agent (RA) not listed under "List of active RA" on emigrate.gov.in',
      'Arabic': 'الوكيل غير موجود في "List of active RA" على eMigrate',
      'Hindi': 'Agent emigrate.gov.in → "List of active RA" पर listed नहीं',
      'Urdu': 'Agent emigrate.gov.in → "List of active RA" پر listed نہیں',
      'Malayalam': 'Agent emigrate.gov.in → "List of active RA"-ൽ listed അല്ല',
      'Nepali': 'Agent emigrate.gov.in → "List of active RA" मा listed छैन',
      'Bengali': 'Agent emigrate.gov.in → "List of active RA"-এ listed নেই',
      'Filipino': 'Agent wala sa "List of active RA" sa emigrate.gov.in',
      'Tamil':
          'Recruiting agent (RA) emigrate.gov.in-ல் "List of active RA"-ல் listed இல்லை',
    },
    'eosb_bys_india_flag_emigration_not_cleared': {
      'English':
          'Told to travel without emigration clearance when it may be required',
      'Arabic': 'طُلب منك السفر دون تصريح الهجرة المطلوب',
      'Hindi': 'Emigration clearance के बिना travel करने को कहा जाए',
      'Urdu': 'Emigration clearance کے بغیر travel کہا جائے',
      'Malayalam': 'Emigration clearance ഇല്ലാതെ travel ചെയ്യാൻ പറയുന്നു',
      'Nepali': 'Emigration clearance बिना travel गर्न भनिन्छ',
      'Bengali': 'Emigration clearance ছাড়া travel বলা হয়',
      'Filipino': 'Pinapabiyahe nang walang emigration clearance',
      'Tamil':
          'Emigration clearance தேவைப்படும்போது அத 없이 travel செய்யச் சொல்லப்படுகிறீர்கள்',
    },
    'eosb_bys_india_emigrate_link_title': {
      'English': 'eMigrate — List of active RA (license check)',
      'Arabic': 'eMigrate — List of active RA',
      'Hindi': 'eMigrate — List of active RA (license check)',
      'Urdu': 'eMigrate — List of active RA (license check)',
      'Malayalam': 'eMigrate — List of active RA (license check)',
      'Nepali': 'eMigrate — List of active RA (license check)',
      'Bengali': 'eMigrate — List of active RA (license check)',
      'Filipino': 'eMigrate — List of active RA (license check)',
      'Tamil': 'eMigrate — List of active RA (license check)',
    },
    'eosb_bys_india_emigrate_link_desc': {
      'English':
          'Official MEA portal. Verify your recruiting agent\'s license via emigrate.gov.in → "List of active RA" before signing or paying.',
      'Arabic': 'بوابة MEA — تحقق من ترخيص الوكيل عبر "List of active RA".',
      'Hindi':
          'MEA portal — emigrate.gov.in → "List of active RA" से agent license verify करें।',
      'Urdu':
          'MEA portal — emigrate.gov.in → "List of active RA" سے license verify کریں۔',
      'Malayalam':
          'MEA portal — emigrate.gov.in → "List of active RA"-ൽ agent license verify ചെയ്യുക.',
      'Nepali':
          'MEA portal — emigrate.gov.in → "List of active RA" बाट license verify गर्नुहोस्।',
      'Bengali':
          'MEA portal — emigrate.gov.in → "List of active RA"-এ license verify করুন।',
      'Filipino':
          'MEA portal — i-verify ang license sa emigrate.gov.in → "List of active RA".',
      'Tamil':
          'அதிகாரப்பூர்வ MEA portal. கையெழுத்திடுவதற்கு அல்லது pay செய்வதற்கு முன் emigrate.gov.in → "List of active RA" வழியாக recruiting agent license verify செய்யுங்கள்.',
    },
    'eosb_bys_nepal_fee': {
      'English':
          'Nepal regulates foreign employment fees — verify current legal fee limits on DOFE/FEIMS official sources before paying any agent.',
      'Arabic': 'نيبال تنظم رسوم التوظيف — تحقق على DOFE/FEIMS.',
      'Hindi':
          'Nepal foreign employment fees regulated — DOFE/FEIMS पर verify करें।',
      'Urdu': 'Nepal fees regulated — DOFE/FEIMS سے verify کریں۔',
      'Malayalam': 'Nepal fees regulated — DOFE/FEIMS-ൽ verify ചെയ്യുക.',
      'Nepali':
          'Nepal ले foreign employment fees नियमन गर्छ — DOFE/FEIMS बाट verify गर्नुहोस्।',
      'Bengali': 'Nepal fees regulated — DOFE/FEIMS-এ verify করুন।',
      'Filipino': 'Nepal fees regulated — i-verify sa DOFE/FEIMS.',
      'Tamil':
          'Nepal foreign employment fees-ஐ regulate செய்கிறது — எந்த agent-க்கும் pay செய்வதற்கு முன் DOFE/FEIMS அதிகாரப்பூர்வ மூலங்களில் சட்ட fee limits சரிபார்க்கவும்.',
    },
    'eosb_bys_nepal_flag_pay_before_permit': {
      'English':
          'Asked to pay before labour permit and pre-departure orientation are complete',
      'Arabic': 'طلب الدفع قبل تصريح العمل والتوجيه',
      'Hindi': 'Labour permit/orientation पूर्ण होने से पहले payment',
      'Urdu': 'Labour permit/orientation سے پہلے payment',
      'Malayalam':
          'Labour permit/orientation പൂർത്തിയാകുന്നതിന് മുമ്പ് payment',
      'Nepali': 'Labour permit/orientation अघि payment',
      'Bengali': 'Labour permit/orientation-এর আগে payment',
      'Filipino': 'Bayad bago makumpleto ang labour permit/orientation',
      'Tamil':
          'Labour permit மற்றும் pre-departure orientation முடிவதற்கு முன் pay கோரப்படுகிறது',
    },
    'eosb_bys_nepal_flag_no_orientation': {
      'English': 'No pre-departure orientation certificate offered',
      'Arabic': 'لا شهادة توجيه قبل المغادرة',
      'Hindi': 'Pre-departure orientation certificate नहीं',
      'Urdu': 'Pre-departure orientation certificate نہیں',
      'Malayalam': 'Pre-departure orientation certificate ഇല്ല',
      'Nepali': 'Pre-departure orientation certificate छैन',
      'Bengali': 'Pre-departure orientation certificate নেই',
      'Filipino': 'Walang pre-departure orientation certificate',
      'Tamil': 'Pre-departure orientation certificate வழங்கப்படவில்லை',
    },
    'eosb_bys_nepal_flag_agency_not_feims': {
      'English': 'Agency not listed on the FEIMS/DOFE licensed-agency register',
      'Arabic': 'الوكالة غير مسجلة في FEIMS/DOFE',
      'Hindi': 'Agency FEIMS/DOFE register पर नहीं',
      'Urdu': 'Agency FEIMS/DOFE register پر نہیں',
      'Malayalam': 'Agency FEIMS/DOFE register-ൽ ഇല്ല',
      'Nepali': 'Agency FEIMS/DOFE register मा छैन',
      'Bengali': 'Agency FEIMS/DOFE register-এ নেই',
      'Filipino': 'Agency wala sa FEIMS/DOFE register',
      'Tamil': 'Agency FEIMS/DOFE licensed-agency register-ல் listed இல்லை',
    },
    'eosb_bys_nepal_flag_no_written_contract': {
      'English': 'No written foreign employment contract before departure',
      'Arabic': 'لا عقد توظيف خارجي written قبل المغادرة',
      'Hindi': 'Prasthan se pehle written foreign employment contract nahi',
      'Urdu': 'روانگی سے پہلے written contract نہیں',
      'Malayalam': 'പുറപ്പെടുന്നതിന് മുമ്പ് written contract ഇല്ല',
      'Nepali': 'प्रस्थान अघि written contract छैन',
      'Bengali': 'যাওয়ার আগে written contract নেই',
      'Filipino': 'Walang written contract bago umalis',
      'Tamil': 'புறப்படுவதற்கு முன் written foreign employment contract இல்லை',
    },
    'eosb_bys_nepal_feims_link_title': {
      'English': 'FEIMS / DOFE — verify licensed agency',
      'Arabic': 'FEIMS / DOFE — تحقق من الوكالة',
      'Hindi': 'FEIMS / DOFE — licensed agency verify',
      'Urdu': 'FEIMS / DOFE — licensed agency verify',
      'Malayalam': 'FEIMS / DOFE — licensed agency verify',
      'Nepali': 'FEIMS / DOFE — licensed agency verify',
      'Bengali': 'FEIMS / DOFE — licensed agency verify',
      'Filipino': 'FEIMS / DOFE — i-verify ang licensed agency',
      'Tamil': 'FEIMS / DOFE — licensed agency verify',
    },
    'eosb_bys_nepal_feims_link_desc': {
      'English':
          'Official Nepal foreign employment information management system.',
      'Arabic': 'النظام الرسمي للتوظيف الخارجي في نيبال.',
      'Hindi': 'Nepal official foreign employment portal.',
      'Urdu': 'Nepal official foreign employment portal.',
      'Malayalam': 'Nepal official foreign employment portal.',
      'Nepali': 'Nepal को आधिकारिक foreign employment portal.',
      'Bengali': 'Nepal official foreign employment portal.',
      'Filipino': 'Opisyal na foreign employment portal ng Nepal.',
      'Tamil':
          'அதிகாரப்பூர்வ Nepal foreign employment information management system.',
    },
    'eosb_bys_ph_fee': {
      'English':
          'Philippines law generally caps placement/recruitment fees at one month\'s salary for many deployments — verify current rules for your job category on official DMW sources before paying.',
      'Arabic': 'الفلبين تحد الرسوم — تحقق على DMW رسمياً.',
      'Hindi':
          'PH law में fee cap (often 1 month salary) — DMW पर verify करें।',
      'Urdu': 'PH fee cap (often 1 month salary) — DMW سے verify کریں۔',
      'Malayalam':
          'PH fee cap (often 1 month salary) — DMW-യിൽ verify ചെയ്യുക.',
      'Nepali': 'PH fee cap (often 1 month salary) — DMW बाट verify गर्नुहोस्।',
      'Bengali': 'PH fee cap (often 1 month salary) — DMW-তে verify করুন।',
      'Filipino':
          'Karaniwang hanggang isang buwan ang sahod ang fee cap — i-verify sa DMW.',
      'Tamil':
          'Philippines சட்டம் பல deployments-க்கு placement/recruitment fees-ஐ ஒரு மாத சம்பளமாக cap செய்கிறது — pay செய்வதற்கு முன் உங்கள் job category-க்கான current rules-ஐ அதிகாரப்பூர்வ DMW மூலங்களில் verify செய்யுங்கள்.',
    },
    'eosb_bys_ph_flag_pay_before_contract': {
      'English':
          'Asked to pay before signing a DMW-standard employment contract',
      'Arabic': 'طلب الدفع قبل توقيع عقد DMW',
      'Hindi': 'DMW-standard contract sign करने से पहले payment',
      'Urdu': 'DMW contract sign سے پہلے payment',
      'Malayalam': 'DMW contract sign ചെയ്യുന്നതിന് മുമ്പ് payment',
      'Nepali': 'DMW contract sign अघि payment',
      'Bengali': 'DMW contract sign-এর আগে payment',
      'Filipino': 'Bayad bago pumirma ng DMW contract',
      'Tamil':
          'DMW-standard employment contract கையெழுத்திடுவதற்கு முன் pay கோரப்படுகிறது',
    },
    'eosb_bys_ph_flag_unlicensed_agency': {
      'English': 'Recruitment agency not found on the DMW licensed-agency list',
      'Arabic': 'الوكالة غير مرخصة في DMW',
      'Hindi': 'Agency DMW licensed list पर नहीं',
      'Urdu': 'Agency DMW licensed list پر نہیں',
      'Malayalam': 'Agency DMW licensed list-ൽ ഇല്ല',
      'Nepali': 'Agency DMW licensed list मा छैन',
      'Bengali': 'Agency DMW licensed list-এ নেই',
      'Filipino': 'Agency wala sa DMW licensed list',
      'Tamil':
          'Recruitment agency DMW licensed-agency list-ல் கண்டறியப்படவில்லை',
    },
    'eosb_bys_ph_flag_no_dmw_contract': {
      'English':
          'No verifiable DMW/POEA contract or job order details provided',
      'Arabic': 'لا عقد DMW/POEA أو تفاصيل job order',
      'Hindi': 'DMW/POEA contract या job order details नहीं',
      'Urdu': 'DMW/POEA contract یا job order details نہیں',
      'Malayalam': 'DMW/POEA contract/job order details ഇല്ല',
      'Nepali': 'DMW/POEA contract/job order details छैन',
      'Bengali': 'DMW/POEA contract/job order details নেই',
      'Filipino': 'Walang DMW/POEA contract o job order details',
      'Tamil':
          'Verify செய்யக்கூடிய DMW/POEA contract அல்லது job order details வழங்கப்படவில்லை',
    },
    'eosb_bys_ph_flag_salary_mismatch': {
      'English':
          'Offered salary in contract differs from what the agent promised verbally',
      'Arabic': 'الراتب في العقد يختلف عما وعد به الوكيل',
      'Hindi': 'Contract salary agent ke verbal promise se alag',
      'Urdu': 'Contract salary agent کے verbal promise سے مختلف',
      'Malayalam': 'Contract salary agent verbal promise-ന് വ്യത്യാസം',
      'Nepali': 'Contract salary agent verbal promise भन्दा फरक',
      'Bengali': 'Contract salary agent-এর verbal promise থেকে আলাদা',
      'Filipino': 'Iba ang salary sa contract sa ipinangako ng agent',
      'Tamil':
          'Contract-ல் offered salary agent verbally promise செய்ததிலிருந்து வேறுபடுகிறது',
    },
    'eosb_bys_ph_dmw_link_title': {
      'English': 'DMW — licensed recruitment agency lookup',
      'Arabic': 'DMW — البحث عن وكالة مرخصة',
      'Hindi': 'DMW — licensed agency lookup',
      'Urdu': 'DMW — licensed agency lookup',
      'Malayalam': 'DMW — licensed agency lookup',
      'Nepali': 'DMW — licensed agency lookup',
      'Bengali': 'DMW — licensed agency lookup',
      'Filipino': 'DMW — licensed agency lookup',
      'Tamil': 'DMW — licensed recruitment agency lookup',
    },
    'eosb_bys_ph_dmw_link_desc': {
      'English': 'Official DMW portal to verify licensed recruitment agencies.',
      'Arabic': 'بوابة DMW الرسمية للتحقق من الوكالات.',
      'Hindi': 'DMW official portal — licensed agencies.',
      'Urdu': 'DMW official portal — licensed agencies.',
      'Malayalam': 'DMW official portal — licensed agencies.',
      'Nepali': 'DMW official portal — licensed agencies.',
      'Bengali': 'DMW official portal — licensed agencies.',
      'Filipino': 'Opisyal na DMW portal — licensed agencies.',
      'Tamil':
          'Licensed recruitment agencies verify செய்ய அதிகாரப்பூர்வ DMW portal.',
    },
    'eosb_qatar_section_title': {
      'English': 'In Qatar — Official Labour Channels',
      'Arabic': 'في قطر — قنوات العمل الرسمية',
      'Hindi': 'In Qatar — Official Labour Channels',
      'Urdu': 'In Qatar — Official Labour Channels',
      'Malayalam': 'In Qatar — Official Labour Channels',
      'Nepali': 'In Qatar — Official Labour Channels',
      'Bengali': 'In Qatar — Official Labour Channels',
      'Filipino': 'In Qatar — Official Labour Channels',
      'Tamil': 'Qatar-ல் — அதிகாரப்பூர்வ தொழிலாளர் Channels',
    },
    'eosb_qatar_section_subtitle': {
      'English':
          'MoL/ADLSA complaint and dispute channels while you work in Qatar — informational only, not legal advice.',
      'Arabic':
          'قنوات شكاوى وزارة العمل/ADLSA أثناء عملك في قطر — للمعلومات فقط وليست استشارة قانونية.',
      'Hindi':
          'MoL/ADLSA complaint channels in Qatar — informational only, not legal advice.',
      'Urdu':
          'MoL/ADLSA complaint channels in Qatar — informational only, not legal advice.',
      'Malayalam':
          'MoL/ADLSA complaint channels in Qatar — informational only, not legal advice.',
      'Nepali':
          'MoL/ADLSA complaint channels in Qatar — informational only, not legal advice.',
      'Bengali':
          'MoL/ADLSA complaint channels in Qatar — informational only, not legal advice.',
      'Filipino':
          'MoL/ADLSA complaint channels in Qatar — informational only, not legal advice.',
      'Tamil':
          'Qatar-ல் வேலை செய்யும்போது MoL/ADLSA புகார் மற்றும் தகராறு channels — தகவல் மட்டும், சட்ட ஆலோசனை அல்ல.',
    },
    'eosb_qatar_ucp_title': {
      'English': 'Unified Complaints Portal (MoL/ADLSA)',
      'Arabic': 'بوابة الشكاوى الموحدة (وزارة العمل/ADLSA)',
      'Hindi': 'Unified Complaints Portal (MoL/ADLSA)',
      'Urdu': 'Unified Complaints Portal (MoL/ADLSA)',
      'Malayalam': 'Unified Complaints Portal (MoL/ADLSA)',
      'Nepali': 'Unified Complaints Portal (MoL/ADLSA)',
      'Bengali': 'Unified Complaints Portal (MoL/ADLSA)',
      'Filipino': 'Unified Complaints Portal (MoL/ADLSA)',
      'Tamil': 'ஒருங்கிணைந்த புகார் portal (MoL/ADLSA)',
    },
    'eosb_qatar_ucp_desc': {
      'English':
          'File wage, contract, and labour complaints via the Ministry of Labour unified platform at mol.gov.qa. Log in with QID/visa + mobile OTP, or National Authentication System (NAS) credentials.',
      'Arabic':
          'قدّم شكاوى الأجور والعقود عبر منصة وزارة العمل الموحدة mol.gov.qa. سجّل الدخول بالهوية/التأشيرة + OTP، أو عبر NAS.',
      'Hindi':
          'File labour complaints at mol.gov.qa — QID/visa + OTP or NAS login.',
      'Urdu':
          'File labour complaints at mol.gov.qa — QID/visa + OTP or NAS login.',
      'Malayalam':
          'File labour complaints at mol.gov.qa — QID/visa + OTP or NAS login.',
      'Nepali':
          'File labour complaints at mol.gov.qa — QID/visa + OTP or NAS login.',
      'Bengali':
          'File labour complaints at mol.gov.qa — QID/visa + OTP or NAS login.',
      'Filipino':
          'File labour complaints at mol.gov.qa — QID/visa + OTP or NAS login.',
      'Tamil':
          'mol.gov.qa-ல் Ministry of Labour ஒருங்கிணைந்த platform வழியாக ஊதியம், ஒப்பந்தம், தொழிலாளர் புகார்களை தாக்கல் செய்யுங்கள். QID/visa + mobile OTP, அல்லது National Authentication System (NAS) credentials-உடன் login.',
    },
    'eosb_qatar_sms_title': {
      'English': 'SMS labour complaint',
      'Arabic': 'شكوى عمالية عبر SMS',
      'Hindi': 'SMS labour complaint',
      'Urdu': 'SMS labour complaint',
      'Malayalam': 'SMS labour complaint',
      'Nepali': 'SMS labour complaint',
      'Bengali': 'SMS labour complaint',
      'Filipino': 'SMS labour complaint',
      'Tamil': 'SMS தொழிலாளர் புகார்',
    },
    'eosb_qatar_sms_desc': {
      'English': 'Send an SMS complaint to MoL/ADLSA without internet access.',
      'Arabic': 'أرسل شكوى عمالية إلى MoL/ADLSA عبر SMS.',
      'Hindi': 'Send SMS complaint to MoL/ADLSA.',
      'Urdu': 'Send SMS complaint to MoL/ADLSA.',
      'Malayalam': 'Send SMS complaint to MoL/ADLSA.',
      'Nepali': 'Send SMS complaint to MoL/ADLSA.',
      'Bengali': 'Send SMS complaint to MoL/ADLSA.',
      'Filipino': 'Send SMS complaint to MoL/ADLSA.',
      'Tamil':
          'Internet access இல்லாமல் MoL/ADLSA-க்கு SMS புகார் அனுப்புங்கள்.',
    },
    'eosb_qatar_sms_format_label': {
      'English': 'SMS format',
      'Arabic': 'صيغة الرسالة',
      'Hindi': 'SMS format',
      'Urdu': 'SMS format',
      'Malayalam': 'SMS format',
      'Nepali': 'SMS format',
      'Bengali': 'SMS format',
      'Filipino': 'SMS format',
      'Tamil': 'SMS format',
    },
    'eosb_qatar_sms_format_value': {
      'English': 'Send 5 followed by your QID or visa number to 92727',
      'Arabic': 'أرسل 5 متبوعة برقم الهوية أو التأشيرة إلى 92727',
      'Hindi': 'Send 5 + QID or visa number to 92727',
      'Urdu': 'Send 5 + QID or visa number to 92727',
      'Malayalam': 'Send 5 + QID or visa number to 92727',
      'Nepali': 'Send 5 + QID or visa number to 92727',
      'Bengali': 'Send 5 + QID or visa number to 92727',
      'Filipino': 'Send 5 + QID or visa number to 92727',
      'Tamil': '5 + உங்கள் QID அல்லது visa number-ஐ 92727-க்கு அனுப்புங்கள்',
    },
    'eosb_qatar_16008_title': {
      'English': 'MoL/ADLSA labour helpline — 16008',
      'Arabic': 'خط مساعدة وزارة العمل — 16008',
      'Hindi': 'MoL/ADLSA labour helpline — 16008',
      'Urdu': 'MoL/ADLSA labour helpline — 16008',
      'Malayalam': 'MoL/ADLSA labour helpline — 16008',
      'Nepali': 'MoL/ADLSA labour helpline — 16008',
      'Bengali': 'MoL/ADLSA labour helpline — 16008',
      'Filipino': 'MoL/ADLSA labour helpline — 16008',
      'Tamil': 'MoL/ADLSA தொழிலாளர் helpline — 16008',
    },
    'eosb_qatar_16008_desc': {
      'English':
          '24/7 multilingual helpline for labour disputes, wage complaints, and workplace issues.',
      'Arabic': 'خط مساعدة 24/7 متعدد اللغات للنزاعات العمالية وشكاوى الأجور.',
      'Hindi': '24/7 multilingual labour helpline.',
      'Urdu': '24/7 multilingual labour helpline.',
      'Malayalam': '24/7 multilingual labour helpline.',
      'Nepali': '24/7 multilingual labour helpline.',
      'Bengali': '24/7 multilingual labour helpline.',
      'Filipino': '24/7 multilingual labour helpline.',
      'Tamil':
          'தொழிலாளர் தகராறுகள், ஊதிய புகார்கள், workplace issues-க்கு 24/7 பன்மொழி helpline.',
    },
    'eosb_qatar_16008_hours_value': {
      'English': '24/7',
      'Arabic': '24/7',
      'Hindi': '24/7',
      'Urdu': '24/7',
      'Malayalam': '24/7',
      'Nepali': '24/7',
      'Bengali': '24/7',
      'Filipino': '24/7',
      'Tamil': '24/7',
    },
    'eosb_qatar_nas_title': {
      'English': 'National Authentication System (NAS) login',
      'Arabic': 'تسجيل الدخول عبر نظام التوثيق الوطني (NAS)',
      'Hindi': 'National Authentication System (NAS) login',
      'Urdu': 'National Authentication System (NAS) login',
      'Malayalam': 'National Authentication System (NAS) login',
      'Nepali': 'National Authentication System (NAS) login',
      'Bengali': 'National Authentication System (NAS) login',
      'Filipino': 'National Authentication System (NAS) login',
      'Tamil': 'National Authentication System (NAS) login',
    },
    'eosb_qatar_nas_desc': {
      'English':
          'Use your NAS credentials to log in to mol.gov.qa services, including the Unified Complaints Portal, instead of QID/visa OTP where available.',
      'Arabic':
          'استخدم بيانات NAS لتسجيل الدخول إلى mol.gov.qa بما في ذلك بوابة الشكاوى الموحدة.',
      'Hindi': 'NAS login for mol.gov.qa including Unified Complaints Portal.',
      'Urdu': 'NAS login for mol.gov.qa including Unified Complaints Portal.',
      'Malayalam':
          'NAS login for mol.gov.qa including Unified Complaints Portal.',
      'Nepali': 'NAS login for mol.gov.qa including Unified Complaints Portal.',
      'Bengali':
          'NAS login for mol.gov.qa including Unified Complaints Portal.',
      'Filipino':
          'NAS login for mol.gov.qa including Unified Complaints Portal.',
      'Tamil':
          'QID/visa OTP-க்கு பதிலாக mol.gov.qa services-ல் login செய்ய NAS credentials பயன்படுத்துங்கள், ஒருங்கிணைந்த புகார் portal உட்பட.',
    },
    'eosb_bys_qvc_title': {
      'English': 'Qatar Visa Centre (QVC)',
      'Arabic': 'مركز تأشيرة قطر',
      'Hindi': 'Qatar Visa Centre (QVC)',
      'Urdu': 'Qatar Visa Centre (QVC)',
      'Malayalam': 'Qatar Visa Centre (QVC)',
      'Nepali': 'Qatar Visa Centre (QVC)',
      'Bengali': 'Qatar Visa Centre (QVC)',
      'Filipino': 'Qatar Visa Centre (QVC)',
      'Tamil': 'Qatar Visa Centre (QVC)',
    },
    'eosb_bys_qvc_desc': {
      'English':
          'Qatar-side visa processing centres for many origin countries. Verify your appointment and requirements on the official QVC site.',
      'Arabic': 'مراكز معالجة التأشيرة في قطر — تحقق رسمياً.',
      'Hindi':
          'Qatar visa processing centres — official QVC site पर verify करें।',
      'Urdu': 'Qatar visa centres — official QVC site سے verify کریں۔',
      'Malayalam': 'Qatar visa centres — official QVC site-ൽ verify ചെയ്യുക.',
      'Nepali': 'Qatar visa centres — official QVC site बाट verify गर्नुहोस्।',
      'Bengali': 'Qatar visa centres — official QVC site-এ verify করুন।',
      'Filipino': 'Qatar visa centres — i-verify sa opisyal na QVC site.',
      'Tamil':
          'பல origin countries-க்கான Qatar-side visa processing centres. அதிகாரப்பூர்வ QVC site-ல் appointment மற்றும் requirements verify செய்யுங்கள்.',
    },
    'eosb_bys_moi_title': {
      'English': 'MOI / Metrash visa & residency status',
      'Arabic': 'وزارة الداخلية / Metrash — حالة التأشيرة',
      'Hindi': 'MOI / Metrash visa status',
      'Urdu': 'MOI / Metrash visa status',
      'Malayalam': 'MOI / Metrash visa status',
      'Nepali': 'MOI / Metrash visa status',
      'Bengali': 'MOI / Metrash visa status',
      'Filipino': 'MOI / Metrash visa status',
      'Tamil': 'MOI / Metrash visa & residency status',
    },
    'eosb_bys_moi_desc': {
      'English':
          'Check Qatar visa, residency, and related MOI services via the official portal or Metrash app.',
      'Arabic': 'تحقق من التأشيرة والإقامة عبر MOI/Metrash رسمياً.',
      'Hindi': 'Qatar visa/residency — official MOI/Metrash से check करें।',
      'Urdu': 'Qatar visa/residency — official MOI/Metrash سے check کریں۔',
      'Malayalam':
          'Qatar visa/residency — official MOI/Metrash-ൽ check ചെയ്യുക.',
      'Nepali':
          'Qatar visa/residency — official MOI/Metrash बाट check गर्नुहोस्।',
      'Bengali': 'Qatar visa/residency — official MOI/Metrash-এ check করুন।',
      'Filipino': 'Qatar visa/residency — i-check sa opisyal na MOI/Metrash.',
      'Tamil':
          'அதிகாரப்பூர்வ portal அல்லது Metrash app வழியாக Qatar visa, residency, தொடர்புடைய MOI services check செய்யுங்கள்.',
    },
    'eosb_pdf_employee': {
      'English': 'Employee: {name}',
      'Arabic': 'الموظف: {name}',
      'Hindi': 'कर्मचारी: {name}',
      'Urdu': 'Employee: {name}',
      'Malayalam': 'Employee: {name}',
      'Nepali': 'Employee: {name}',
      'Bengali': 'Employee: {name}',
      'Filipino': 'Employee: {name}',
      'Tamil': 'தொழிலாளர்: {name}',
    },
    'eosb_pdf_company': {
      'English': 'Company: {name}',
      'Arabic': 'الشركة: {name}',
      'Hindi': 'कंपनी: {name}',
      'Urdu': 'Company: {name}',
      'Malayalam': 'Company: {name}',
      'Nepali': 'Company: {name}',
      'Bengali': 'Company: {name}',
      'Filipino': 'Company: {name}',
      'Tamil': 'நிறுவனம்: {name}',
    },
    'eosb_pdf_date': {
      'English': 'Date: {date}',
      'Arabic': 'التاريخ: {date}',
      'Hindi': 'तारीख: {date}',
      'Urdu': 'Date: {date}',
      'Malayalam': 'Date: {date}',
      'Nepali': 'Date: {date}',
      'Bengali': 'Date: {date}',
      'Filipino': 'Date: {date}',
      'Tamil': 'தேதி: {date}',
    },
    'eosb_pdf_breakdown': {
      'English': 'Breakdown',
      'Arabic': 'التفصيل',
      'Hindi': 'विवरण',
      'Urdu': 'Breakdown',
      'Malayalam': 'Breakdown',
      'Nepali': 'Breakdown',
      'Bengali': 'Breakdown',
      'Filipino': 'Breakdown',
      'Tamil': 'பிரிவினை',
    },
    'eosb_pdf_offer': {
      'English': 'Offer: {amount}',
      'Arabic': 'العرض: {amount}',
      'Hindi': 'प्रस्ताव: {amount}',
      'Urdu': 'Offer: {amount}',
      'Malayalam': 'Offer: {amount}',
      'Nepali': 'Offer: {amount}',
      'Bengali': 'Offer: {amount}',
      'Filipino': 'Offer: {amount}',
      'Tamil': 'சலுகை: {amount}',
    },
    'eosb_pdf_estimate': {
      'English': 'Estimate: {amount}',
      'Arabic': 'التقدير: {amount}',
      'Hindi': 'अनुमान: {amount}',
      'Urdu': 'Estimate: {amount}',
      'Malayalam': 'Estimate: {amount}',
      'Nepali': 'Estimate: {amount}',
      'Bengali': 'Estimate: {amount}',
      'Filipino': 'Estimate: {amount}',
      'Tamil': 'மதிப்பீடு: {amount}',
    },
    'eosb_pdf_difference': {
      'English': 'Difference: {amount}',
      'Arabic': 'الفرق: {amount}',
      'Hindi': 'अंतर: {amount}',
      'Urdu': 'Difference: {amount}',
      'Malayalam': 'Difference: {amount}',
      'Nepali': 'Difference: {amount}',
      'Bengali': 'Difference: {amount}',
      'Filipino': 'Difference: {amount}',
      'Tamil': 'வித்தியாசம்: {amount}',
    },
    'eosb_pdf_share_text': {
      'English': 'EOSB Calculation Report',
      'Arabic': 'تقرير حساب مكافأة نهاية الخدمة',
      'Hindi': 'EOSB गणना रिपोर्ट',
      'Urdu': 'EOSB Calculation Report',
      'Malayalam': 'EOSB Calculation Report',
      'Nepali': 'EOSB Calculation Report',
      'Bengali': 'EOSB Calculation Report',
      'Filipino': 'EOSB Calculation Report',
      'Tamil': 'EOSB கணக்கீட்டு அறிக்கை',
    },
    'employer_track_record_body': {
      'English':
          '{total} Raabta users have calculated entitlements for this employer. {violations} flagged a possible legal violation in their calculation, based on Qatar Labour Law.',
      'Arabic':
          'قام {total} مستخدمين في رابطة بحساب مستحقات هذا صاحب العمل. {violations} أشاروا إلى احتمال مخالفة قانونية في حسابهم، وفق قانون العمل القطري.',
      'Hindi':
          '{total} Raabta users ne is employer ke liye entitlements calculate kiye. {violations} ne apni calculation mein Qatar Labour Law ke tahat possible legal violation flag ki.',
      'Urdu':
          '{total} Raabta users ne is employer ke liye entitlements calculate kiye. {violations} ne apni calculation mein Qatar Labour Law ke tahat possible legal violation flag ki.',
      'Malayalam':
          '{total} Raabta users have calculated entitlements for this employer. {violations} flagged a possible legal violation in their calculation, based on Qatar Labour Law.',
      'Nepali':
          '{total} Raabta users have calculated entitlements for this employer. {violations} flagged a possible legal violation in their calculation, based on Qatar Labour Law.',
      'Bengali':
          '{total} Raabta users ne is employer ke liye entitlements calculate kiye. {violations} ne apni calculation mein Qatar Labour Law ke tahat possible legal violation flag ki.',
      'Filipino':
          '{total} Raabta users have calculated entitlements for this employer. {violations} flagged a possible legal violation in their calculation, based on Qatar Labour Law.',
      'Tamil':
          'இந்த முதலாளிக்கான entitlements-ஐ {total} Raabta users கணக்கிட்டுள்ளனர். {violations} Qatar தொழிலாளர் சட்டத்தின் அடிப்படையில் தங்கள் கணக்கீட்டில் சாத்தியமான சட்ட மீறலைக் குறித்துள்ளனர்.',
    },
    'employer_track_record_velocity_line': {
      'English':
          'Increased reports in the past {days} days compared to this employer\'s typical pattern.',
      'Arabic':
          'تقارير متزايدة خلال {days} يوماً الماضية مقارنة بالنمط المعتاد لهذا صاحب العمل.',
      'Hindi':
          'Is employer ke typical pattern ke mukable pichhle {days} dinon mein reports badhi hain.',
      'Urdu':
          'Is employer ke typical pattern ke mukable pichhle {days} dinon mein reports badhi hain.',
      'Malayalam':
          'Increased reports in the past {days} days compared to this employer\'s typical pattern.',
      'Nepali':
          'Increased reports in the past {days} days compared to this employer\'s typical pattern.',
      'Bengali':
          'Ei employer er typical pattern er tulonay gato {days} dine report bereche.',
      'Filipino':
          'Increased reports in the past {days} days compared to this employer\'s typical pattern.',
      'Tamil':
          'Indha employer-in typical pattern-ukku oppaga kazhinja {days} naatkalil reports athigam.',
    },
    'employer_track_record_disclaimer': {
      'English':
          'This reflects Raabta\'s own calculations only, not a rating or review of this employer, and is not legal advice.',
      'Arabic':
          'يعكس هذا حسابات رابطة فقط، وليس تقييماً أو مراجعة لصاحب العمل، وليس استشارة قانونية.',
      'Hindi':
          'Yeh sirf Raabta ke apne calculations dikhata hai — employer ki rating/review nahi, aur yeh legal advice nahi hai.',
      'Urdu':
          'Yeh sirf Raabta ke apne calculations dikhata hai — employer ki rating/review nahi, aur yeh legal advice nahi hai.',
      'Malayalam':
          'This reflects Raabta\'s own calculations only, not a rating or review of this employer, and is not legal advice.',
      'Nepali':
          'This reflects Raabta\'s own calculations only, not a rating or review of this employer, and is not legal advice.',
      'Bengali':
          'Yeh sirf Raabta ke apne calculations dikhata hai — employer ki rating/review nahi, aur yeh legal advice nahi hai.',
      'Filipino':
          'This reflects Raabta\'s own calculations only, not a rating or review of this employer, and is not legal advice.',
      'Tamil':
          'இது Raabta-வின் சொந்த கணக்கீடுகளை மட்டுமே பிரதிபலிக்கிறது — இந்த முதலாளியின் rating அல்லது review அல்ல, சட்ட ஆலோசனையும் அல்ல.',
    },
    'employer_track_record_insufficient': {
      'English':
          'Not enough Raabta calculation data for this employer name yet.',
      'Arabic': 'لا توجد بيانات كافية من حسابات رابطة لهذا اسم صاحب العمل بعد.',
      'Hindi':
          'Is employer name ke liye abhi tak kaafi Raabta calculation data nahi hai.',
      'Urdu':
          'Is employer name ke liye abhi tak kaafi Raabta calculation data nahi hai.',
      'Malayalam':
          'Not enough Raabta calculation data for this employer name yet.',
      'Nepali':
          'Not enough Raabta calculation data for this employer name yet.',
      'Bengali':
          'Is employer name er jonno ekhono jothesto Raabta calculation data nei.',
      'Filipino':
          'Not enough Raabta calculation data for this employer name yet.',
      'Tamil':
          'இந்த employer பெயருக்கு இன்னும் போதுமான Raabta calculation data இல்லை.',
    },
    'employer_track_record_lookup_title': {
      'English': 'Check an employer',
      'Arabic': 'تحقق من صاحب العمل',
      'Hindi': 'Employer check karein',
      'Urdu': 'Employer check karein',
      'Malayalam': 'Check an employer',
      'Nepali': 'Check an employer',
      'Bengali': 'Employer check korun',
      'Filipino': 'Check an employer',
      'Tamil': 'Employer-ai check seiyungal',
    },
    'employer_track_record_lookup_subtitle': {
      'English':
          'See aggregated entitlement calculation signals from other Raabta users before you accept an offer.',
      'Arabic':
          'اطلع على إشارات حساب المستحقات المجمّعة من مستخدمين آخرين في رابطة قبل قبول العرض.',
      'Hindi':
          'Offer accept karne se pehle doosre Raabta users ke aggregated entitlement calculation signals dekhein.',
      'Urdu':
          'Offer accept karne se pehle doosre Raabta users ke aggregated entitlement calculation signals dekhein.',
      'Malayalam':
          'See aggregated entitlement calculation signals from other Raabta users before you accept an offer.',
      'Nepali':
          'See aggregated entitlement calculation signals from other Raabta users before you accept an offer.',
      'Bengali':
          'Offer accept korar age onno Raabta users er aggregated entitlement calculation signals dekhen.',
      'Filipino':
          'See aggregated entitlement calculation signals from other Raabta users before you accept an offer.',
      'Tamil':
          'Offer accept seiya munbu matra Raabta users-in aggregated entitlement calculation signals-ai paarkkavum.',
    },
    'employer_track_record_lookup_hint': {
      'English': 'Employer name',
      'Arabic': 'اسم صاحب العمل',
      'Hindi': 'Employer ka naam',
      'Urdu': 'Employer ka naam',
      'Malayalam': 'Employer name',
      'Nepali': 'Employer name',
      'Bengali': 'Employer er naam',
      'Filipino': 'Employer name',
      'Tamil': 'Employer peyar',
    },
    'employer_track_record_lookup_example_hint': {
      'English': 'e.g. Qatar Energy',
      'Arabic': 'مثال: قطر للطاقة',
      'Hindi': 'jaise Qatar Energy',
      'Urdu': 'jaise Qatar Energy',
      'Malayalam': 'e.g. Qatar Energy',
      'Nepali': 'e.g. Qatar Energy',
      'Bengali': 'dhoron: Qatar Energy',
      'Filipino': 'e.g. Qatar Energy',
      'Tamil': 'udh.: Qatar Energy',
    },
    'employer_track_record_lookup_action': {
      'English': 'Check employer',
      'Arabic': 'تحقق من صاحب العمل',
      'Hindi': 'Employer check karein',
      'Urdu': 'Employer check karein',
      'Malayalam': 'Check employer',
      'Nepali': 'Check employer',
      'Bengali': 'Employer check korun',
      'Filipino': 'Check employer',
      'Tamil': 'Employer-ai check seiyungal',
    },
    'employer_track_record_home_link': {
      'English': 'Check an employer before you sign',
      'Arabic': 'تحقق من صاحب العمل قبل التوقيع',
      'Hindi': 'Sign karne se pehle employer check karein',
      'Urdu': 'Sign karne se pehle employer check karein',
      'Malayalam': 'Check an employer before you sign',
      'Nepali': 'Check an employer before you sign',
      'Bengali': 'Sign korar age employer check korun',
      'Filipino': 'Check an employer before you sign',
      'Tamil': 'Sign seiya munbu employer-ai check seiyungal',
    },
    'employer_track_record_check_employer_button': {
      'English': 'Check this employer',
      'Arabic': 'تحقق من هذا صاحب العمل',
      'Hindi': 'Is employer ko check karein',
      'Urdu': 'Is employer ko check karein',
      'Malayalam': 'Check this employer',
      'Nepali': 'Check this employer',
      'Bengali': 'Ei employer check korun',
      'Filipino': 'Check this employer',
      'Tamil': 'Indha employer-ai check seiyungal',
    },
    'employer_pre_offer_checklist_title': {
      'English': 'General job offer safety checklist',
      'Arabic': 'قائمة عامة لسلامة عرض العمل',
      'Hindi': 'General job offer safety checklist',
      'Urdu': 'General job offer safety checklist',
      'Malayalam': 'General job offer safety checklist',
      'Nepali': 'General job offer safety checklist',
      'Bengali': 'General job offer safety checklist',
      'Filipino': 'General job offer safety checklist',
      'Tamil': 'General job offer safety checklist',
    },
    'employer_pre_offer_check_recruitment_costs': {
      'English':
          'Recruitment, visa, and travel costs are legally required to be paid by the employer in Qatar — if you are asked to pay any of these, that is a red flag.',
      'Arabic':
          'التكاليف القانونية للت recruitment والتأشيرة والسفر يجب أن يدفعها صاحب العمل في قطر — إذا طُلب منك دفع أي منها، فهذا إشارة تحذيرية.',
      'Hindi':
          'Qatar mein recruitment, visa aur travel costs legally employer ko dene hote hain — agar aap se koi bhi payment maangi jaye, yeh red flag hai.',
      'Urdu':
          'Qatar mein recruitment, visa aur travel costs legally employer ko dene hote hain — agar aap se koi bhi payment maangi jaye, yeh red flag hai.',
      'Malayalam':
          'Recruitment, visa, and travel costs are legally required to be paid by the employer in Qatar — if you are asked to pay any of these, that is a red flag.',
      'Nepali':
          'Recruitment, visa, and travel costs are legally required to be paid by the employer in Qatar — if you are asked to pay any of these, that is a red flag.',
      'Bengali':
          'Qatar-e recruitment, visa, ebong travel costs legally employer-ke dite hoy — jodi apnar kache kono payment chaowa hoy, eta red flag.',
      'Filipino':
          'Recruitment, visa, and travel costs are legally required to be paid by the employer in Qatar — if you are asked to pay any of these, that is a red flag.',
      'Tamil':
          'Recruitment, visa, travel costs Qatar-il legally employer pay seyyanum — ivatrondaiyum neengal pay seiya sollinaal, athu oru red flag.',
    },
    'employer_pre_offer_check_official_email': {
      'English':
          'Verify communication is coming from an official company email domain, not a free webmail or messaging-only channel.',
      'Arabic':
          'تحقق أن التواصل يأتي من نطاق بريد إلكتروني رسمي للشركة، وليس من بريد مجاني أو قناة مراسلة فقط.',
      'Hindi':
          'Verify karein ki communication official company email domain se aa rahi hai, free webmail ya sirf messaging channel se nahi.',
      'Urdu':
          'Verify karein ki communication official company email domain se aa rahi hai, free webmail ya sirf messaging channel se nahi.',
      'Malayalam':
          'Verify communication is coming from an official company email domain, not a free webmail or messaging-only channel.',
      'Nepali':
          'Verify communication is coming from an official company email domain, not a free webmail or messaging-only channel.',
      'Bengali':
          'Verify korun communication official company email domain theke asche, free webmail ba messaging-only channel theke na.',
      'Filipino':
          'Verify communication is coming from an official company email domain, not a free webmail or messaging-only channel.',
      'Tamil':
          'Communication official company email domain-il irundhu varugirathu enbadhai verify seiyungal, free webmail allathu messaging-only channel alla.',
    },
    'employer_pre_offer_check_written_offer': {
      'English':
          'Ask for a formal written offer letter before making any decisions or sharing personal documents.',
      'Arabic':
          'اطلب خطاب عرض رسمي مكتوب قبل اتخاذ أي قرارات أو مشاركة مستندات شخصية.',
      'Hindi':
          'Koi decision lene ya personal documents share karne se pehle formal written offer letter maangein.',
      'Urdu':
          'Koi decision lene ya personal documents share karne se pehle formal written offer letter maangein.',
      'Malayalam':
          'Ask for a formal written offer letter before making any decisions or sharing personal documents.',
      'Nepali':
          'Ask for a formal written offer letter before making any decisions or sharing personal documents.',
      'Bengali':
          'Kono decision nawa ba personal documents share korar age formal written offer letter chaan.',
      'Filipino':
          'Ask for a formal written offer letter before making any decisions or sharing personal documents.',
      'Tamil':
          'Edhavadhu decision eduthal allathu personal documents share seiyum munbu formal written offer letter kekavum.',
    },
    'employer_pre_offer_check_take_time': {
      'English':
          'Take your time — legitimate employers do not pressure you to decide within hours.',
      'Arabic':
          'خذ وقتك — أصحاب العمل الجادون لا يضغطون عليك للقرار خلال ساعات.',
      'Hindi':
          'Apna time lein — legitimate employers aapko ghanton mein decide karne ke liye pressure nahi karte.',
      'Urdu':
          'Apna time lein — legitimate employers aapko ghanton mein decide karne ke liye pressure nahi karte.',
      'Malayalam':
          'Take your time — legitimate employers do not pressure you to decide within hours.',
      'Nepali':
          'Take your time — legitimate employers do not pressure you to decide within hours.',
      'Bengali':
          'Somoy nin — legitimate employers ghontar modhye decide korte pressure dey na.',
      'Filipino':
          'Take your time — legitimate employers do not pressure you to decide within hours.',
      'Tamil':
          'Ungalukku thevaiyaana neram edungal — legitimate employers pala manikoor-la decide seiya pressure seyyar.',
    },
    'agency_verify_screen_title': {
      'English': 'Verify a recruitment agency',
      'Arabic': 'التحقق من وكالة التوظيف',
      'Hindi': 'Recruitment agency verify karein',
      'Urdu': 'Recruitment agency verify karein',
      'Malayalam': 'Verify a recruitment agency',
      'Nepali': 'Recruitment agency verify garnuhos',
      'Bengali': 'Recruitment agency verify korun',
      'Filipino': 'Verify a recruitment agency',
      'Tamil': 'Recruitment agency-ai verify seiyungal',
    },
    'agency_verify_screen_subtitle': {
      'English':
          'Before you pay any fee or sign anything, use your home country\'s official government portal to check whether a recruitment agency is licensed. Raabta links you to the authority — Raabta does not verify agencies itself.',
      'Arabic':
          'قبل دفع أي رسوم أو التوقيع، استخدم البوابة الحكومية الرسمية في بلدك. رابطة توجهك إلى الجهة — ولا تتحقق من الوكالات بنفسها.',
      'Hindi':
          'Koi fee pay ya sign karne se pehle apne desh ke official government portal se agency licensed hai ya nahi check karein. Raabta aapko authority tak le jaata hai — khud verify nahi karta.',
      'Urdu':
          'Koi fee pay ya sign karne se pehle apne desh ke official government portal se check karein. Raabta authority tak le jaata hai — khud verify nahi karta.',
      'Malayalam':
          'Before you pay any fee or sign anything, use your home country\'s official government portal to check whether a recruitment agency is licensed. Raabta links you to the authority — Raabta does not verify agencies itself.',
      'Nepali':
          'Kunai fee tirna athaba sign garnu agi afno desh ko official government portal bata agency licensed chha ki chhaina hernuhos. Raabta le authority ma puryauchha — afai verify gardaina.',
      'Bengali':
          'Kono fee deoya ba sign korar age desher official government portal diye agency licensed kina check korun. Raabta authority-te niye jay — nijerai verify kore na.',
      'Filipino':
          'Before you pay any fee or sign anything, use your home country\'s official government portal to check whether a recruitment agency is licensed. Raabta links you to the authority — Raabta does not verify agencies itself.',
      'Tamil':
          'Edhavadhu fee pay seiya allathu sign seiya munbu unga home country official government portal use panni recruitment agency licensed-aa endru paarkkavum. Raabta authority-kku link seyyum — thaan verify seyyathu.',
    },
    'agency_verify_country_heading': {
      'English': 'Your nationality / home country',
      'Arabic': 'جنسيتك / بلدك الأصلي',
      'Hindi': 'Aapki nationality / home country',
      'Urdu': 'Aapki nationality / home country',
      'Malayalam': 'Your nationality / home country',
      'Nepali': 'Tapainko nationality / home country',
      'Bengali': 'Apnar nationality / home country',
      'Filipino': 'Your nationality / home country',
      'Tamil': 'Unga nationality / home country',
    },
    'agency_verify_open_portal': {
      'English': 'Open official government portal',
      'Arabic': 'فتح البوابة الحكومية الرسمية',
      'Hindi': 'Official government portal kholen',
      'Urdu': 'Official government portal kholen',
      'Malayalam': 'Open official government portal',
      'Nepali': 'Official government portal kholnuhos',
      'Bengali': 'Official government portal khulun',
      'Filipino': 'Open official government portal',
      'Tamil': 'Official government portal open seiyungal',
    },
    'agency_verify_disclaimer': {
      'English':
          'Raabta does not certify, rate, or verify any recruitment agency. Always confirm licensing status directly on the official government portal.',
      'Arabic':
          'رابطة لا تصادق ولا تقيّم ولا تتحقق من أي وكالة. أكّد الحالة مباشرة على البوابة الرسمية.',
      'Hindi':
          'Raabta kisi bhi agency ko certify, rate, ya verify nahi karta. Official government portal par seedha confirm karein.',
      'Urdu':
          'Raabta kisi bhi agency ko certify, rate, ya verify nahi karta. Official portal par seedha confirm karein.',
      'Malayalam':
          'Raabta does not certify, rate, or verify any recruitment agency. Always confirm licensing status directly on the official government portal.',
      'Nepali':
          'Raabta le kunai pani agency certify, rate, athaba verify gardaina. Official government portal ma seedha confirm garnuhos.',
      'Bengali':
          'Raabta kono agency certify, rate, ba verify kore na. Official government portal-e seedha confirm korun.',
      'Filipino':
          'Raabta does not certify, rate, or verify any recruitment agency. Always confirm licensing status directly on the official government portal.',
      'Tamil':
          'Raabta edhavadhu recruitment agency-ai certify, rate, allathu verify seyyathu. Official government portal-il seedha licensing status confirm seiyungal.',
    },
    'agency_verify_home_link': {
      'English': 'Verify a recruitment agency (before you pay)',
      'Arabic': 'تحقق من وكالة التوظيف (قبل الدفع)',
      'Hindi': 'Recruitment agency verify karein (pay karne se pehle)',
      'Urdu': 'Recruitment agency verify karein (pay karne se pehle)',
      'Malayalam': 'Verify a recruitment agency (before you pay)',
      'Nepali': 'Recruitment agency verify garnuhos (pay garnu agi)',
      'Bengali': 'Recruitment agency verify korun (pay korar age)',
      'Filipino': 'Verify a recruitment agency (before you pay)',
      'Tamil': 'Recruitment agency verify seiyungal (pay seiya munbu)',
    },
    'agency_verify_generic_not_confirmed': {
      'English':
          'An official self-service agency verification portal for your country has not yet been confirmed in Raabta. Do not rely on unofficial lists — check directly with your government\'s foreign employment or migrant worker authority.',
      'Arabic':
          'لم يتم تأكيد بوابة تحقق رسمية لبلدك في رابطة بعد. تحقق مباشرة مع الجهة الحكومية المختصة.',
      'Hindi':
          'Aapke desh ke liye official self-service agency verification portal abhi Raabta mein confirm nahi hua. Seedha sarkari foreign employment authority se check karein.',
      'Urdu':
          'Aapke desh ke liye official portal abhi confirm nahi. Seedha sarkari authority se check karein.',
      'Malayalam':
          'An official self-service agency verification portal for your country has not yet been confirmed in Raabta. Do not rely on unofficial lists — check directly with your government\'s foreign employment or migrant worker authority.',
      'Nepali':
          'Tapainko desh ko lagi official self-service agency verification portal Raabta ma abhi confirm bhayeko chaina. Seedha sarkari foreign employment authority sanga check garnuhos.',
      'Bengali':
          'Apnar desher jonno official self-service agency verification portal Raabta-te ekhono confirm hoyni. Seedha sarkari authority diye check korun.',
      'Filipino':
          'An official self-service agency verification portal for your country has not yet been confirmed in Raabta. Do not rely on unofficial lists — check directly with your government\'s foreign employment or migrant worker authority.',
      'Tamil':
          'Unga desathirkku official self-service agency verification portal Raabta-il innum confirm aagavillai. Unofficial lists-ai rely seiyathu — unga government foreign employment authority-oda seedha check seiyungal.',
    },
    'agency_verify_india_not_confirmed': {
      'English':
          'India\'s eMigrate system and Protector General of Emigrants licensing are known pre-departure systems, but Raabta has not yet confirmed a public self-service agency-search portal equivalent to Nepal\'s DOFE or the Philippines\' DMW in this research pass. Verification resource not yet confirmed for India — check directly with official MEA/Emigration sources before paying any agent.',
      'Arabic':
          'أنظمة eMigrate في الهند معروفة، لكن رابطة لم تؤكد بعد بوابة بحث عامة مماثلة — تحقق مباشرة من MEA.',
      'Hindi':
          'India ka eMigrate aur PGE licensing jaana jaata hai, lekin Nepal DOFE ya Philippines DMW jaisa public self-service agency-search portal is pass mein confirm nahi hua. Koi bhi agent ko pay karne se pehle official MEA/Emigration sources se check karein.',
      'Urdu':
          'India ka eMigrate jaana jaata hai, lekin public self-service agency-search portal is pass mein confirm nahi. Pay karne se pehle official MEA sources se check karein.',
      'Malayalam':
          'India\'s eMigrate system and Protector General of Emigrants licensing are known pre-departure systems, but Raabta has not yet confirmed a public self-service agency-search portal equivalent to Nepal\'s DOFE or the Philippines\' DMW in this research pass. Verification resource not yet confirmed for India — check directly with official MEA/Emigration sources before paying any agent.',
      'Nepali':
          'India ko eMigrate ra PGE licensing cha-in systems hun, tara Nepal DOFE wa Philippines DMW jasto public self-service agency-search portal yo pass ma confirm bhayeko chaina. Kunai pani agent lai pay garnu agi official MEA/Emigration sources bata check garnuhos.',
      'Bengali':
          'India-r eMigrate ebong PGE licensing porichito, kintu Nepal DOFE ba Philippines DMW-er moto public self-service agency-search portal ei pass-e confirm hoyni. Kono agent-ke pay korar age official MEA/Emigration source diye check korun.',
      'Filipino':
          'India\'s eMigrate system and Protector General of Emigrants licensing are known pre-departure systems, but Raabta has not yet confirmed a public self-service agency-search portal equivalent to Nepal\'s DOFE or the Philippines\' DMW in this research pass. Verification resource not yet confirmed for India — check directly with official MEA/Emigration sources before paying any agent.',
      'Tamil':
          'India eMigrate system um Protector General of Emigrants licensing um theriya systems, aanaal Nepal DOFE Philippines DMW maathiri public self-service agency-search portal indha research pass-il confirm aagavillai. Edhavadhu agent-kku pay seiya munbu official MEA/Emigration sources-oda seedha check seiyungal.',
    },
    'agency_verify_nepal_authority': {
      'English': 'Department of Foreign Employment (DOFE), Nepal',
      'Arabic': 'إدارة التوظيف الخارجي (DOFE)، نيبال',
      'Hindi': 'Department of Foreign Employment (DOFE), Nepal',
      'Urdu': 'Department of Foreign Employment (DOFE), Nepal',
      'Malayalam': 'Department of Foreign Employment (DOFE), Nepal',
      'Nepali': 'विदेश रोजगार विभाग (DOFE), नेपाल',
      'Bengali': 'Department of Foreign Employment (DOFE), Nepal',
      'Filipino': 'Department of Foreign Employment (DOFE), Nepal',
      'Tamil': 'Department of Foreign Employment (DOFE), Nepal',
    },
    'agency_verify_nepal_search': {
      'English':
          'On dofe.gov.np, use "Licensed Agencies" to search by agency name or license number.',
      'Arabic':
          'على dofe.gov.np، استخدم "Licensed Agencies" للبحث بالاسم أو رقم الترخيص.',
      'Hindi':
          'dofe.gov.np par "Licensed Agencies" se agency name ya license number search karein.',
      'Urdu':
          'dofe.gov.np par "Licensed Agencies" se agency name ya license number search karein.',
      'Malayalam':
          'On dofe.gov.np, use "Licensed Agencies" to search by agency name or license number.',
      'Nepali':
          'dofe.gov.np ma "Licensed Agencies" bata agency name athaba license number le khojnuhos.',
      'Bengali':
          'dofe.gov.np-e "Licensed Agencies" diye agency name ba license number search korun.',
      'Filipino':
          'On dofe.gov.np, use "Licensed Agencies" to search by agency name or license number.',
      'Tamil':
          'dofe.gov.np-il "Licensed Agencies" use panni agency name allathu license number search seiyungal.',
    },
    'agency_verify_nepal_good_standing': {
      'English':
          'Only proceed if the agency appears on the DOFE licensed-agency register for your search.',
      'Arabic': 'تابع فقط إذا ظهرت الوكالة في سجل الوكالات المرخصة لدى DOFE.',
      'Hindi':
          'Tabhi aage badhein jab agency DOFE licensed-agency register par dikhe.',
      'Urdu':
          'Tabhi aage barhein jab agency DOFE licensed-agency register par ho.',
      'Malayalam':
          'Only proceed if the agency appears on the DOFE licensed-agency register for your search.',
      'Nepali':
          'Agency DOFE licensed-agency register ma dekhiyo bhane matra agi badhnus.',
      'Bengali': 'Agency DOFE licensed-agency register-e thakle-i egiye jan.',
      'Filipino':
          'Only proceed if the agency appears on the DOFE licensed-agency register for your search.',
      'Tamil':
          'Agency unga search-il DOFE licensed-agency register-il irundha mattum proceed seiyungal.',
    },
    'agency_verify_nepal_vacancy': {
      'English':
          'Also verify the specific job vacancy has a Swikriti letter (pre-approval) number under "Approved Vacancies" on the same portal.',
      'Arabic':
          'تحقق أيضاً من أن الش vacancy لديها رقم Swikriti (موافقة مسبقة) تحت "Approved Vacancies".',
      'Hindi':
          'Specific job vacancy ka Swikriti letter (pre-approval) number "Approved Vacancies" mein bhi verify karein.',
      'Urdu':
          'Specific job vacancy ka Swikriti number "Approved Vacancies" mein verify karein.',
      'Malayalam':
          'Also verify the specific job vacancy has a Swikriti letter (pre-approval) number under "Approved Vacancies" on the same portal.',
      'Nepali':
          'Specific job vacancy ko Swikriti letter (pre-approval) number "Approved Vacancies" ma pani verify garnuhos.',
      'Bengali':
          'Specific job vacancy-r Swikriti letter (pre-approval) number "Approved Vacancies"-e verify korun.',
      'Filipino':
          'Also verify the specific job vacancy has a Swikriti letter (pre-approval) number under "Approved Vacancies" on the same portal.',
      'Tamil':
          'Specific job vacancy-kku "Approved Vacancies"-il Swikriti letter (pre-approval) number irukka endru verify seiyungal.',
    },
    'agency_verify_ph_authority': {
      'English': 'Department of Migrant Workers (DMW), Philippines',
      'Arabic': 'وزارة العمالة المغتربة (DMW)، الفلبين',
      'Hindi': 'Department of Migrant Workers (DMW), Philippines',
      'Urdu': 'Department of Migrant Workers (DMW), Philippines',
      'Malayalam': 'Department of Migrant Workers (DMW), Philippines',
      'Nepali': 'Department of Migrant Workers (DMW), Philippines',
      'Bengali': 'Department of Migrant Workers (DMW), Philippines',
      'Filipino': 'Department of Migrant Workers (DMW), Philippines',
      'Tamil': 'Department of Migrant Workers (DMW), Philippines',
    },
    'agency_verify_ph_search': {
      'English':
          'On dmw.gov.ph, use "Licensed Recruitment Agencies" to search by agency name or license number.',
      'Arabic': 'على dmw.gov.ph، استخدم "Licensed Recruitment Agencies" للبحث.',
      'Hindi':
          'dmw.gov.ph par "Licensed Recruitment Agencies" se search karein.',
      'Urdu':
          'dmw.gov.ph par "Licensed Recruitment Agencies" se search karein.',
      'Malayalam':
          'On dmw.gov.ph, use "Licensed Recruitment Agencies" to search by agency name or license number.',
      'Nepali':
          'dmw.gov.ph ma "Licensed Recruitment Agencies" bata search garnuhos.',
      'Bengali':
          'dmw.gov.ph-e "Licensed Recruitment Agencies" diye search korun.',
      'Filipino':
          'Sa dmw.gov.ph, gamitin ang "Licensed Recruitment Agencies" para maghanap.',
      'Tamil':
          'dmw.gov.ph-il "Licensed Recruitment Agencies" use panni search seiyungal.',
    },
    'agency_verify_ph_good_standing': {
      'English':
          'On the portal, only proceed if the agency status shows "Valid/Good Standing". Do not proceed if status is Suspended, Cancelled, or Expired.',
      'Arabic':
          'تابع فقط إذا كانت الحالة "Valid/Good Standing". لا تتابع إذا كانت Suspended أو Cancelled أو Expired.',
      'Hindi':
          'Portal par status "Valid/Good Standing" ho tabhi aage badhein. Suspended, Cancelled, ya Expired par nahi.',
      'Urdu':
          'Status "Valid/Good Standing" ho tabhi aage barhein. Suspended, Cancelled, ya Expired par nahi.',
      'Malayalam':
          'On the portal, only proceed if the agency status shows "Valid/Good Standing". Do not proceed if status is Suspended, Cancelled, or Expired.',
      'Nepali':
          'Portal ma status "Valid/Good Standing" dekhe matra agi badhnus. Suspended, Cancelled, wa Expired ma badhnu hos.',
      'Bengali':
          'Portal-e status "Valid/Good Standing" hole-i egiye jan. Suspended, Cancelled, ba Expired hole na.',
      'Filipino':
          'Magpatuloy lang kung ang status ay "Valid/Good Standing". Huwag kung Suspended, Cancelled, o Expired.',
      'Tamil':
          'Portal-il agency status "Valid/Good Standing" endraal mattum proceed seiyungal. Suspended, Cancelled, allathu Expired aanaal proceed seiyathu.',
    },
    'agency_verify_checklist_title': {
      'English': 'Universal recruitment safety checklist',
      'Arabic': 'قائمة سلامة التوظيف العامة',
      'Hindi': 'Universal recruitment safety checklist',
      'Urdu': 'Universal recruitment safety checklist',
      'Malayalam': 'Universal recruitment safety checklist',
      'Nepali': 'Universal recruitment safety checklist',
      'Bengali': 'Universal recruitment safety checklist',
      'Filipino': 'Universal recruitment safety checklist',
      'Tamil': 'Universal recruitment safety checklist',
    },
    'agency_verify_check_payment_before_contract': {
      'English':
          'A legitimate agency never asks for payment before you have a signed, written contract in your possession, in a language you understand.',
      'Arabic':
          'الوكالة المشروعة لا تطلب الدفع قبل حصولك على عقد مكتوب موقّع بلغة تفهمها.',
      'Hindi':
          'Legitimate agency kabhi payment tab nahi maangti jab tak aapke paas signed written contract na ho, aisi language mein jo aap samjhein.',
      'Urdu':
          'Legitimate agency payment tab nahi maangti jab tak signed written contract na ho.',
      'Malayalam':
          'A legitimate agency never asks for payment before you have a signed, written contract in your possession, in a language you understand.',
      'Nepali':
          'Imandar agency le tapain sanga signed, written contract nahuda samma payment magdaina.',
      'Bengali':
          'Bishwasgho agency signed written contract chara age payment chaay na.',
      'Filipino':
          'A legitimate agency never asks for payment before you have a signed, written contract in your possession, in a language you understand.',
      'Tamil':
          'Niyayamaana agency ungalidam signed, written contract irukkum varai payment kekkaathu — ungalukku puriyaatha mozhiyil.',
    },
    'agency_verify_check_recruitment_costs': {
      'English':
          'Recruitment, visa, and travel costs are legally required to be paid by the employer in Gulf countries including Qatar — if you are asked to pay these yourself, that is a serious red flag.',
      'Arabic':
          'رسوم الت recruitment والتأشيرة والسفر يجب أن يدفعها صاحب العمل في دول الخليج بما فيها قطر — طلبك دفعها بنفسك إشارة خطيرة.',
      'Hindi':
          'Gulf countries including Qatar mein recruitment, visa, travel costs legally employer deta hai — khud pay karne ko kaha jaye to serious red flag.',
      'Urdu':
          'Gulf countries mein yeh costs employer deta hai — khud pay karne ko kaha jaye to serious red flag.',
      'Malayalam':
          'Recruitment, visa, and travel costs are legally required to be paid by the employer in Gulf countries including Qatar — if you are asked to pay these yourself, that is a serious red flag.',
      'Nepali':
          'Gulf countries ma recruitment, visa, travel costs legally employer le tirnu parcha — afai tirna bhannu bhane serious red flag ho.',
      'Bengali':
          'Gulf countries-e recruitment, visa, travel costs legally employer debe — nijerai dite bola serious red flag.',
      'Filipino':
          'Recruitment, visa, and travel costs are legally required to be paid by the employer in Gulf countries including Qatar — if you are asked to pay these yourself, that is a serious red flag.',
      'Tamil':
          'Gulf countries including Qatar-il recruitment, visa, travel costs legally employer pay seyyanum — neengal pay seiya sollinaal serious red flag.',
    },
    'agency_verify_check_tourist_visa': {
      'English':
          'Being told to travel on a tourist/visit visa "to be converted to a work visa later" is illegal in Qatar and every other Gulf destination — do not proceed under this arrangement under any circumstances.',
      'Arabic':
          'السفر بتأشيرة سياحية "لتحويلها لاحقاً" غير قانوني في قطر ودول الخليج — لا تتابع.',
      'Hindi':
          'Tourist/visit visa par jaakar "baad mein work visa" convert karne ko kehna Qatar aur Gulf mein illegal hai — kabhi proceed na karein.',
      'Urdu':
          'Tourist visa par ja kar baad mein work visa convert karna illegal hai — proceed na karein.',
      'Malayalam':
          'Being told to travel on a tourist/visit visa "to be converted to a work visa later" is illegal in Qatar and every other Gulf destination — do not proceed under this arrangement under any circumstances.',
      'Nepali':
          'Tourist/visit visa ma gayera "pachi work visa" convert garne bhannu Qatar ra Gulf ma illegal cha — kahilyai proceed nagarnus.',
      'Bengali':
          'Tourist/visit visa-te giye pore work visa convert korar kotha illegal — kokhono proceed korben na.',
      'Filipino':
          'Being told to travel on a tourist/visit visa "to be converted to a work visa later" is illegal in Qatar and every other Gulf destination — do not proceed under this arrangement under any circumstances.',
      'Tamil':
          'Tourist/visit visa-il poi "piragu work visa convert aagum" endru solrathu Qatar matrum Gulf-il illegal — edhavadhu circumstance-ilum proceed seiyathu.',
    },
    'agency_verify_check_receipts': {
      'English':
          'Ask for and keep a receipt for every payment made, no matter how it is described (processing fee, training deposit, etc.) — a legitimate transaction always produces one.',
      'Arabic':
          'اطلب واحتفظ بإيصال لكل دفعة — المعاملة المشروعة تنتج دائماً إيصالاً.',
      'Hindi':
          'Har payment ka receipt maangein aur rakhein (processing fee, training deposit, etc.) — legitimate transaction mein receipt milta hai.',
      'Urdu':
          'Har payment ka receipt maangein aur rakhein — legitimate transaction mein receipt milta hai.',
      'Malayalam':
          'Ask for and keep a receipt for every payment made, no matter how it is described (processing fee, training deposit, etc.) — a legitimate transaction always produces one.',
      'Nepali':
          'Har payment ko receipt magera rakhnus — imandar transaction ma receipt huncha.',
      'Bengali':
          'Proti payment-er receipt chaan ebong rakhen — bishwasgho transaction-e receipt thake.',
      'Filipino':
          'Ask for and keep a receipt for every payment made, no matter how it is described (processing fee, training deposit, etc.) — a legitimate transaction always produces one.',
      'Tamil':
          'Edhavadhu payment-kkum receipt kekavum, vaithu kollungal — legitimate transaction-la receipt irukkum.',
    },
    'agency_verify_check_messaging_only': {
      'English':
          'Be cautious if all communication happens only through WhatsApp/Telegram/personal social media with no verifiable office address or company-domain email.',
      'Arabic':
          'كن حذراً إذا كان كل التواصل عبر WhatsApp/Telegram فقط دون عنوان مكتب أو بريد رسمي.',
      'Hindi':
          'Agar sirf WhatsApp/Telegram/personal social media par baat ho, bina verifiable office address ya company email ke, savdhan rahein.',
      'Urdu':
          'Agar sirf WhatsApp/Telegram par baat ho, bina office address ya company email ke, savdhan rahein.',
      'Malayalam':
          'Be cautious if all communication happens only through WhatsApp/Telegram/personal social media with no verifiable office address or company-domain email.',
      'Nepali':
          'Sabai kura WhatsApp/Telegram matra ma huncha, office address wa company email bina, sabadhan rahos.',
      'Bengali':
          'Shudhu WhatsApp/Telegram-e kotha hole, office address ba company email chara, sabadhan thakun.',
      'Filipino':
          'Be cautious if all communication happens only through WhatsApp/Telegram/personal social media with no verifiable office address or company-domain email.',
      'Tamil':
          'Ellaa communication-um WhatsApp/Telegram-la mattum, verify panna mudiya office address allathu company-domain email illamal nadandha, jagaathiraiyaaga irungal.',
    },
    'eosb_cloud_sync_failed': {
      'English':
          'Saved on this device. Cloud backup for Employer Track Record did not complete — check your connection and try again later.',
      'Arabic':
          'تم الحفظ على هذا الجهاز. لم يكتمل النسخ الاحتياطي السحابي لسجل صاحب العمل — تحقق من الاتصال وحاول لاحقاً.',
      'Hindi':
          'इस डिवाइस पर सेव हो गया। Employer Track Record का क्लाउड बैकअप पूरा नहीं हुआ — कनेक्शन जाँचें और बाद में फिर कोशिश करें।',
      'Urdu':
          'اس ڈیوائس پر محفوظ ہو گیا۔ Employer Track Record کے کلاؤڈ بیک اپ مکمل نہیں ہوا — کنکشن چیک کریں اور بعد میں دوبارہ کوشش کریں۔',
      'Malayalam':
          'ഈ ഉപകരണത്തിൽ സേവ് ചെയ്തു. Employer Track Record ക്ലൗഡ് ബാക്കപ്പ് പൂർത്തിയായില്ല — കണക്ഷൻ പരിശോധിച്ച് പിന്നീട് വീണ്ടും ശ്രമിക്കുക.',
      'Nepali':
          'यो उपकरणमा सेभ भयो। Employer Track Record क्लाउड ब्याकअप पूरा भएन — जडान जाँच गरी पछि फेरि प्रयास गर्नुहोस्।',
      'Bengali':
          'এই ডিভাইসে সংরক্ষিত হয়েছে। Employer Track Record ক্লাউড ব্যাকআপ সম্পন্ন হয়নি — সংযোগ পরীক্ষা করে পরে আবার চেষ্টা করুন।',
      'Filipino':
          'Saved on this device. Cloud backup for Employer Track Record did not finish — check your connection and try again later.',
      'Tamil':
          'இந்த சாதனத்தில் சேமிக்கப்பட்டது. Employer Track Record மேகக் காப்பு முடிக்கப்படவில்லை — இணைப்பைச் சரிபார்த்து பிறகு மீண்டும் முயற்சிக்கவும்.',
    },
    'eosb_history_consent_limited': {
      'English':
          '''Calculation saved. Turn on “Store salary data securely” in Privacy to save salary details to history.''',
      'Arabic':
          '''تم حفظ الحساب. فعّل «تخزين بيانات الراتب بأمان» في الخصوصية لحفظ تفاصيل الراتب في السجل.''',
      'Hindi':
          '''गणना सहेजी गई। इतिहास में वेतन विवरण सहेजने के लिए गोपनीयता में “वेतन डेटा सुरक्षित रूप से संग्रहीत करें” चालू करें।''',
      'Urdu':
          '''حساب محفوظ کر لیا گیا۔ ہسٹری میں تنخواہ کی تفصیلات محفوظ کرنے کے لیے پرائیویسی میں “تنخواہ کا ڈیٹا محفوظ طریقے سے اسٹور کریں” آن کریں۔''',
      'Malayalam':
          '''കണക്കുകൂട്ടൽ സംരക്ഷിച്ചു. ചരിത്രത്തിൽ ശമ്പള വിവരങ്ങൾ സംരക്ഷിക്കാൻ പ്രൈവസിയിൽ “ശമ്പള വിവരങ്ങൾ സുരക്ഷിതമായി സൂക്ഷിക്കുക” ഓണാക്കുക.''',
      'Nepali':
          '''गणना सुरक्षित गरियो। इतिहासमा तलब विवरण सुरक्षित गर्न गोपनीयतामा “तलब डेटा सुरक्षित रूपमा भण्डारण गर्नुहोस्” खोल्नुहोस्।''',
      'Bengali':
          '''হিসাব সংরক্ষিত হয়েছে। ইতিহাসে বেতনের বিবরণ সংরক্ষণ করতে গোপনীয়তা সেটিংসে “বেতনের তথ্য নিরাপদে সংরক্ষণ করুন” চালু করুন।''',
      'Tamil':
          '''கணக்கீடு சேமிக்கப்பட்டது. வரலாற்றில் சம்பள விவரங்களைச் சேமிக்க தனியுரிமை அமைப்பில் “சம்பளத் தரவைப் பாதுகாப்பாகச் சேமி” என்பதை இயக்கவும்.''',
      'Filipino':
          '''Na-save ang pagkalkula. I-on ang “I-store nang ligtas ang datos ng suweldo” sa Privacy upang ma-save ang mga detalye ng suweldo sa history.''',
    },
    'eosb_history_corrupt_banner': {
      'English':
          'Some history entries could not be loaded. Recovered items are shown below; saving or deleting history is blocked until storage is healthy.',
      'Arabic':
          'تعذّر تحميل بعض إدخالات السجل. العناصر المستردة أدناه؛ الحفظ والحذف متوقفان حتى يُصحَّح التخزين.',
      'Hindi':
          'कुछ इतिहास प्रविष्टियाँ लोड नहीं हो सकीं। नीचे बरामद आइटम दिखाए गए हैं; संग्रहण ठीक होने तक सहेजना या हटाना रोका गया है।',
      'Urdu':
          'کچھ ہسٹری اندراجات لوڈ نہیں ہو سکیں۔ نیچے بحال آئٹمز دکھائے گئے ہیں؛ اسٹوریج درست ہونے تک محفوظ یا حذف کرنا روک دیا گیا ہے۔',
      'Malayalam':
          'ചില ചരിത്ര എൻട്രികൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല. തിരിച്ചെടുത്ത ഇനങ്ങൾ താഴെ കാണിക്കുന്നു; സംഗ്രഹണം ശരിയാകുന്ന വരെ സേവ് ചെയ്യാനും ഇല്ലാതാക്കാനും പാടില്ല.',
      'Nepali':
          'केही इतिहास प्रविष्टिहरू लोड हुन सकेनन्। तल पुनः प्राप्त वस्तुहरू देखाइएका छन्; भण्डारण स्वस्थ नभएसम्म सेभ र मेटाउन रोकिएको छ।',
      'Bengali':
          'কিছু ইতিহাস এন্ট্রি লোড হয়নি। নিচে উদ্ধার করা আইটেম দেখানো হয়েছে; সংরক্ষণ ঠিক না হওয়া পর্যন্ত সংরক্ষণ বা মুছে ফেলা বন্ধ আছে।',
      'Filipino':
          'Hindi ma-load ang ilang entry sa history. Makikita sa ibaba ang na-recover; hanggang maging maayos ang storage, naka-block ang pag-save o pag-delete.',
      'Tamil':
          'சில வரலாற்று உள்ளீடுகளை ஏற்ற முடியவில்லை. மீட்டெடுக்கப்பட்ட உருப்படிகள் கீழே காட்டப்படுகின்றன; சேமிப்பு சரியாகும் வரை சேமித்தல் அல்லது நீக்குதல் தடுக்கப்பட்டுள்ளது.',
    },
    'eosb_history_corrupt_delete_blocked': {
      'English':
          'History storage is damaged. Deleting entries is blocked until storage is healthy.',
      'Arabic': 'تخزين السجل تالف. حذف الإدخالات متوقف حتى يُصحَّح التخزين.',
      'Hindi':
          'इतिहास संग्रहण क्षतिग्रस्त है। संग्रहण ठीक होने तक प्रविष्टियाँ हटाना रोका गया है।',
      'Urdu':
          'ہسٹری اسٹوریج خراب ہے۔ اسٹوریج درست ہونے تک اندراجات حذف کرنا روک دیا گیا ہے۔',
      'Malayalam':
          'ചരിത്ര സംഗ്രഹണം കേടായി. സംഗ്രഹണം ശരിയാകുന്ന വരെ എൻട്രികൾ ഇല്ലാതാക്കാൻ പാടില്ല.',
      'Nepali':
          'इतिहास भण्डारण बिग्रिएको छ। भण्डारण स्वस्थ नभएसम्म प्रविष्टि मेटाउन रोकिएको छ।',
      'Bengali':
          'ইতিহাস সংরক্ষণ ক্ষতিগ্রস্ত। সংরক্ষণ ঠিক না হওয়া পর্যন্ত এন্ট্রি মুছে ফেলা বন্ধ আছে।',
      'Filipino':
          'May sira ang history storage. Hanggang maging maayos ang storage, naka-block ang pag-delete ng mga entry.',
      'Tamil':
          'வரலாற்று சேமிப்பு சேதமடைந்துள்ளது. சேமிப்பு சரியாகும் வரை உள்ளீடுகளை நீக்க முடியாது.',
    },
    'eosb_history_corrupt_empty_desc': {
      'English':
          'No saved calculations could be recovered from this device. Saving new calculations to history is blocked until storage is healthy.',
      'Arabic':
          'تعذّر استرداد أي حسابات محفوظة من هذا الجهاز. حفظ حسابات جديدة في السجل متوقف حتى يُصحَّح التخزين.',
      'Hindi':
          'इस डिवाइस से कोई सहेजी गई गणना पुनर्प्राप्त नहीं हो सकी। संग्रहण ठीक होने तक नई गणनाएँ इतिहास में सहेजी नहीं जा सकतीं।',
      'Urdu':
          'اس ڈیوائس سے کوئی محفوظ حساب بحال نہیں ہو سکا۔ اسٹوریج درست ہونے تک نئی حسابیں ہسٹری میں محفوظ نہیں کی جا سکتیں۔',
      'Malayalam':
          'ഈ ഉപകരണത്തിൽ നിന്ന് ഒരു സേവ്ഡ് കണക്കും തിരിച്ചെടുക്കാൻ കഴിഞ്ഞില്ല. സംഗ്രഹണം ശരിയാകുന്ന വരെ പുതിയ കണക്കുകൾ ചരിത്രത്തിൽ സേവ് ചെയ്യാൻ പാടില്ല.',
      'Nepali':
          'यो उपकरणबाट कुनै सुरक्षित गणना पुनः प्राप्त गर्न सकिएन। भण्डारण स्वस्थ नभएसम्म नयाँ गणनाहरू इतिहासमा सेभ गर्न रोकिएको छ।',
      'Bengali':
          'এই ডিভাইস থেকে কোনো সংরক্ষিত গণনা উদ্ধার করা যায়নি। সংরক্ষণ ঠিক না হওয়া পর্যন্ত ইতিহাসে নতুন গণনা সংরক্ষণ বন্ধ আছে।',
      'Filipino':
          'Walang na-recover na naka-save na kalkulasyon mula sa device na ito. Hanggang maging maayos ang storage, hindi maaaring mag-save ng bagong kalkulasyon sa history.',
      'Tamil':
          'இந்த சாதனத்திலிருந்து எந்த சேமிக்கப்பட்ட கணக்கீடும் மீட்டெடுக்க முடியவில்லை. சேமிப்பு சரியாகும் வரை புதிய கணக்கீடுகளை வரலாற்றில் சேமிக்க முடியாது.',
    },
    'eosb_history_corrupt_empty_title': {
      'English': 'Calculation history is damaged',
      'Arabic': 'سجل الحسابات تالف',
      'Hindi': 'गणना इतिहास क्षतिग्रस्त है',
      'Urdu': 'حساب کی ہسٹری خراب ہے',
      'Malayalam': 'കണക്കുകൂടൽ ചരിത്രം കേടായി',
      'Nepali': 'गणना इतिहास बिग्रिएको छ',
      'Bengali': 'গণনার ইতিহাস ক্ষতিগ্রস্ত',
      'Filipino': 'May sira ang history ng kalkulasyon',
      'Tamil': 'கணக்கீட்டு வரலாறு சேதமடைந்துள்ளது',
    },
    'eosb_history_corrupt_write_blocked': {
      'English':
          'History storage is damaged. Saving changes is blocked until storage is healthy.',
      'Arabic': 'تخزين السجل تالف. حفظ التغييرات متوقف حتى يُصحَّح التخزين.',
      'Hindi':
          'इतिहास संग्रहण क्षतिग्रस्त है। संग्रहण ठीक होने तक बदलाव सहेजना रोका गया है।',
      'Urdu':
          'ہسٹری اسٹوریج خراب ہے۔ اسٹوریج درست ہونے تک تبدیلیاں محفوظ کرنا روک دیا گیا ہے۔',
      'Malayalam':
          'ചരിത്ര സംഗ്രഹണം കേടായി. സംഗ്രഹണം ശരിയാകുന്ന വരെ മാറ്റങ്ങൾ സേവ് ചെയ്യാൻ പാടില്ല.',
      'Nepali':
          'इतिहास भण्डारण बिग्रिएको छ। भण्डारण स्वस्थ नभएसम्म परिवर्तन सेभ गर्न रोकिएको छ।',
      'Bengali':
          'ইতিহাস সংরক্ষণ ক্ষতিগ্রস্ত। সংরক্ষণ ঠিক না হওয়া পর্যন্ত পরিবর্তন সংরক্ষণ বন্ধ আছে।',
      'Filipino':
          'May sira ang history storage. Hanggang maging maayos ang storage, naka-block ang pag-save ng mga pagbabago.',
      'Tamil':
          'வரலாற்று சேமிப்பு சேதமடைந்துள்ளது. சேமிப்பு சரியாகும் வரை மாற்றங்களை சேமிக்க முடியாது.',
    },
    'eosb_history_save_failed': {
      'English': 'Could not save calculation history. Sign in and try again.',
      'Arabic': 'تعذر حفظ سجل الحساب. سجّل الدخول وحاول مرة أخرى.',
      'Hindi':
          'गणना इतिहास सहेजा नहीं जा सका। साइन इन करें और फिर से प्रयास करें।',
      'Urdu':
          'حساب کی ہسٹری محفوظ نہیں ہو سکی۔ سائن ان کریں اور دوبارہ کوشش کریں۔',
      'Malayalam':
          '''കണക്കുകൂട്ടൽ ചരിത്രം സംരക്ഷിക്കാനായില്ല. സൈൻ ഇൻ ചെയ്ത് വീണ്ടും ശ്രമിക്കുക.''',
      'Nepali':
          'गणना इतिहास सुरक्षित गर्न सकिएन। साइन इन गरी पुनः प्रयास गर्नुहोस्।',
      'Bengali':
          'হিসাবের ইতিহাস সংরক্ষণ করা যায়নি। সাইন ইন করে আবার চেষ্টা করুন।',
      'Tamil':
          '''கணக்கீட்டு வரலாற்றைச் சேமிக்க முடியவில்லை. உள்நுழைந்து மீண்டும் முயற்சிக்கவும்.''',
      'Filipino':
          'Hindi ma-save ang history ng pagkalkula. Mag-sign in at subukan muli.',
    },
    'eosb_history_metadata_only': {
      'English': 'Metadata only',
      'Arabic': 'بيانات وصفية فقط',
      'Hindi': 'केवल मेटाडेटा',
      'Urdu': 'صرف میٹا ڈیٹا',
      'Malayalam': 'മെറ്റാഡാറ്റ മാത്രം',
      'Nepali': 'मेटाडेटा मात्र',
      'Bengali': 'শুধু মেটাডেটা',
      'Filipino': 'Metadata lamang',
      'Tamil': 'மெட்டாடேட்டா மட்டும்',
    },
    'eosb_salary_claude_consent_required': {
      'English':
          '''Turn on “Store salary data securely” in Privacy before using AI features that process salary information.''',
      'Arabic':
          '''فعّل «تخزين بيانات الراتب بأمان» في الخصوصية قبل استخدام ميزات الذكاء الاصطناعي التي تعالج معلومات الراتب.''',
      'Hindi':
          '''AI features जो वेतन जानकारी संसाधित करते हैं, उनसे पहले Privacy में “Store salary data securely” चालू करें।''',
      'Urdu':
          '''اے آئی اے کی ایسی خصوصیات استعمال کرنے سے پہلے "اسٹری مزدوری کے اعداد و شمار محفوظ" پر نظر ڈالیں جو ادائیگی کی معلومات انجام دیتی ہیں۔''',
      'Malayalam':
          '''“Store salary data securely” in Privacy before using AI features that process salary information” എന്ന പേരിൽ തുറക്കുക.''',
      'Nepali':
          '''AI features जो वेतन जानकारी संसाधित करते हैं, उनसे पहले Privacy में “Store salary data securely” चालू करें।''',
      'Bengali':
          'AI বৈশিষ্ট্য ব্যবহার করে "সেবার বেতন সুরক্ষার ডাটা" চালু করুন।',
      'Tamil':
          '''சம்பள தகவலைச் செயலாக்கும் AI அம்சங்களுக்கு முன் தனியுரிமையில் “Store salary data securely” இயக்கவும்.''',
      'Filipino':
          '''Baligtarin ang data ng “Store sweldo sa Privacy bago gamitin ang AI tampok na proseso ng sweldo information.''',
    },
    'eosb_history_load_error': {
      'English': 'Could not load history',
      'Arabic': 'تعذّر تحميل السجل',
      'Hindi': 'इतिहास लोड नहीं हो सका',
      'Urdu': 'ہسٹری لوڈ نہیں ہو سکی',
      'Malayalam': 'ചരിത്രം ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല',
      'Nepali': 'इतिहास लोड हुन सकेन',
      'Bengali': 'ইতিহাস লোড করা যায়নি',
      'Filipino': 'Hindi ma-load ang history',
      'Tamil': 'வரலாற்றை ஏற்ற முடியவில்லை',
    },
    'eosb_history_load_error_desc': {
      'English':
          'Close and reopen this screen. If it persists, sign in again and retry.',
      'Arabic':
          'أغلق الشاشة وأعد فتحها. إن استمرت المشكلة، سجّل الدخول وحاول مجدداً.',
      'Hindi':
          'यह स्क्रीन बंद करके दोबारा खोलें। समस्या बनी रहे तो फिर साइन इन करके कोशिश करें।',
      'Urdu':
          'اس اسکرین کو بند کر کے دوبارہ کھولیں۔ اگر مسئلہ رہے تو دوبارہ سائن اِن کر کے کوشش کریں۔',
      'Malayalam':
          'ഈ സ്ക്രീൻ അടച്ച് വീണ്ടും തുറക്കുക. തുടരുകയാണെങ്കിൽ വീണ്ടും സൈൻ ഇൻ ചെയ്ത് ശ്രമിക്കുക.',
      'Nepali':
          'यो स्क्रिन बन्द गरी फेरि खोल्नुहोस्। समस्या रह्यो भने पुनः साइन इन गरी प्रयास गर्नुहोस्।',
      'Bengali':
          'এই স্ক্রিন বন্ধ করে আবার খুলুন। সমস্যা থাকলে আবার সাইন ইন করে চেষ্টা করুন।',
      'Filipino':
          'Isara at buksan muli ang screen na ito. Kung tuloy pa rin, mag-sign in muli at subukan.',
      'Tamil':
          'இந்த திரையை மூடி மீண்டும் திறக்கவும். தொடர்ந்தால், மீண்டும் உள்நுழைந்து முயற்சிக்கவும்.',
    },
    'eosb_privacy_security': {
      'English': 'Privacy & security',
      'Arabic': 'الخصوصية والأمان',
      'Hindi': 'निजता एवं सुरक्षा',
      'Urdu': 'نظامت اور حفاظت',
      'Malayalam': 'സ്വകാര്യതയും സുരക്ഷയും',
      'Nepali': 'गोपनीयता र सुरक्षा',
      'Bengali': 'গোপনীয়তা এবং নিরাপত্তা',
      'Tamil': 'தனியுரிமை & பாதுகாப்பு',
      'Filipino': 'Privacy at seguridad',
    },
    'ot_history_corrupt_empty_title': {
      'English': 'Overtime history is damaged',
      'Arabic': 'سجل العمل الإضافي تالف',
      'Hindi': 'ओवरटाइम इतिहास क्षतिग्रस्त है',
      'Urdu': 'اوور ٹائم ہسٹری خراب ہے',
      'Malayalam': 'ഓവർടൈം ചരിത്രം കേടായി',
      'Nepali': 'ओभरटाइम इतिहास बिग्रिएको छ',
      'Bengali': 'ওভারটাইম ইতিহাস ক্ষতিগ্রস্ত',
      'Filipino': 'May sira ang overtime history',
      'Tamil': 'கூடுதல் நேர வேலை வரலாறு சேதமடைந்துள்ளது',
    },
    'ot_history_corrupt_empty_desc': {
      'English':
          'No saved months could be recovered from this device. Saving overtime history is blocked until storage is healthy.',
      'Arabic':
          'تعذّر استرداد أي أشهر محفوظة من هذا الجهاز. حفظ سجل العمل الإضافي متوقف حتى يُصحَّح التخزين.',
      'Hindi':
          'इस डिवाइस से कोई सहेजा गया महीना पुनर्प्राप्त नहीं हो सका। संग्रहण ठीक होने तक ओवरटाइम इतिहास सहेजना रोका गया है।',
      'Urdu':
          'اس ڈیوائس سے کوئی محفوظ مہینہ بحال نہیں ہو سکا۔ اسٹوریج درست ہونے تک اوور ٹائم ہسٹری محفوظ کرنا روک دیا گیا ہے۔',
      'Malayalam':
          'ഈ ഉപകരണത്തിൽ നിന്ന് ഒരു സേവ്ഡ് മാസവും തിരിച്ചെടുക്കാൻ കഴിഞ്ഞില്ല. സംഗ്രഹണം ശരിയാകുന്ന വരെ ഓവർടൈം ചരിത്രം സേവ് ചെയ്യാൻ പാടില്ല.',
      'Nepali':
          'यो उपकरणबाट कुनै सुरक्षित महिना पुनः प्राप्त गर्न सकिएन। भण्डारण स्वस्थ नभएसम्म ओभरटाइम इतिहास सेभ गर्न रोकिएको छ।',
      'Bengali':
          'এই ডিভাইস থেকে কোনো সংরক্ষিত মাস উদ্ধার করা যায়নি। সংরক্ষণ ঠিক না হওয়া পর্যন্ত ওভারটাইম ইতিহাস সংরক্ষণ বন্ধ আছে।',
      'Filipino':
          'Walang na-recover na naka-save na buwan mula sa device na ito. Hanggang maging maayos ang storage, naka-block ang pag-save ng overtime history.',
      'Tamil':
          'இந்த சாதனத்திலிருந்து எந்த சேமிக்கப்பட்ட மாதமும் மீட்டெடுக்க முடியவில்லை. சேமிப்பு சரியாகும் வரை கூடுதல் நேர வரலாற்றை சேமிக்க முடியாது.',
    },
    'ot_history_corrupt_banner': {
      'English':
          'Some overtime history entries could not be loaded. Recovered months are shown below; saving changes is blocked until storage is healthy.',
      'Arabic':
          'تعذّر تحميل بعض أشهر السجل. الأشهر المستردة أدناه؛ حفظ التغييرات متوقف حتى يُصحَّح التخزين.',
      'Hindi':
          'कुछ ओवरटाइम प्रविष्टियाँ लोड नहीं हो सकीं। नीचे बरामद महीने दिखाए गए हैं; संग्रहण ठीक होने तक बदलाव सहेजना रोका गया है।',
      'Urdu':
          'کچھ اوور ٹائم اندراجات لوڈ نہیں ہو سکیں۔ نیچے بحال مہینے دکھائے گئے ہیں؛ اسٹوریج درست ہونے تک تبدیلیاں محفوظ کرنا روک دیا گیا ہے۔',
      'Malayalam':
          'ചില ഓവർടൈം ചരിത്ര എൻട്രികൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല. തിരിച്ചെടുത്ത മാസങ്ങൾ താഴെ കാണിക്കുന്നു; സംഗ്രഹണം ശരിയാകുന്ന വരെ മാറ്റങ്ങൾ സേവ് ചെയ്യാൻ പാടില്ല.',
      'Nepali':
          'केही ओभरटाइम इतिहास प्रविष्टिहरू लोड हुन सकेनन्। तल पुनः प्राप्त महिनाहरू देखाइएका छन्; भण्डारण स्वस्थ नभएसम्म परिवर्तन सेभ गर्न रोकिएको छ।',
      'Bengali':
          'কিছু ওভারটাইম ইতিহাস এন্ট্রি লোড হয়নি। নিচে উদ্ধার করা মাস দেখানো হয়েছে; সংরক্ষণ ঠিক না হওয়া পর্যন্ত পরিবর্তন সংরক্ষণ বন্ধ আছে।',
      'Filipino':
          'Hindi ma-load ang ilang overtime history entry. Makikita sa ibaba ang na-recover na buwan; hanggang maging maayos ang storage, naka-block ang pag-save ng mga pagbabago.',
      'Tamil':
          'சில கூடுதல் நேர வரலாற்று உள்ளீடுகளை ஏற்ற முடியவில்லை. மீட்டெடுக்கப்பட்ட மாதங்கள் கீழே காட்டப்படுகின்றன; சேமிப்பு சரியாகும் வரை மாற்றங்களை சேமிக்க முடியாது.',
    },
    'ot_history_hydration_failed': {
      'English': 'Could not load overtime history',
      'Arabic': 'تعذّر تحميل سجل العمل الإضافي',
      'Hindi': 'ओवरटाइम इतिहास लोड नहीं हो सका',
      'Urdu': 'اوور ٹائم ہسٹری لوڈ نہیں ہو سکی',
      'Malayalam': 'ഓവർടൈം ചരിത്രം ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല',
      'Nepali': 'ओभरटाइम इतिहास लोड हुन सकेन',
      'Bengali': 'ওভারটাইম ইতিহাস লোড করা যায়নি',
      'Filipino': 'Hindi ma-load ang overtime history',
      'Tamil': 'கூடுதல் நேர வரலாற்றை ஏற்ற முடியவில்லை',
    },
    'ot_history_hydration_failed_desc': {
      'English':
          'Close and reopen this screen, or tap Retry. If it persists, sign in again.',
      'Arabic':
          'أغلق الشاشة وأعد فتحها، أو اضغط «إعادة المحاولة». إن استمرت المشكلة، سجّل الدخول مجدداً.',
      'Hindi':
          'यह स्क्रीन बंद करके दोबारा खोलें, या «Retry» दबाएँ। समस्या बनी रहे तो फिर साइन इन करें।',
      'Urdu':
          'اس اسکرین کو بند کر کے دوبارہ کھولیں، یا «Retry» دبائیں۔ اگر مسئلہ رہے تو دوبارہ سائن اِن کریں۔',
      'Malayalam':
          'ഈ സ്ക്രീൻ അടച്ച് വീണ്ടും തുറക്കുക, അല്ലെങ്കിൽ Retry അമർത്തുക. തുടരുകയാണെങ്കിൽ വീണ്ടും സൈൻ ഇൻ ചെയ്യുക.',
      'Nepali':
          'यो स्क्रिन बन्द गरी फेरि खोल्नुहोस्, वा Retry थिच्नुहोस्। समस्या रह्यो भने पुनः साइन इन गर्नुहोस्।',
      'Bengali':
          'এই স্ক্রিন বন্ধ করে আবার খুলুন, অথবা Retry ট্যাপ করুন। সমস্যা থাকলে আবার সাইন ইন করুন।',
      'Filipino':
          'Isara at buksan muli ang screen na ito, o pindutin ang Retry. Kung tuloy pa rin, mag-sign in muli.',
      'Tamil':
          'இந்த திரையை மூடி மீண்டும் திறக்கவும், அல்லது Retry ஐத் தட்டவும். தொடர்ந்தால், மீண்டும் உள்நுழையவும்.',
    },
  };
}

String formatEosbCurrency(double amount, {String symbol = 'QAR'}) {
  final formatted = amount
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$symbol $formatted';
}

double eosbToUsd(double qar) => qar / 3.64;
double eosbToInr(double qar) => qar * 22.9;
