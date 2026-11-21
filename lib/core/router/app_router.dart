import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';
import 'package:raabta/screens/ai_chat/ai_chat_screen.dart';
import 'package:raabta/screens/businesses/businesses_screen.dart';
import 'package:raabta/features/business/presentation/screens/business_request_appointment_screen.dart';
import 'package:raabta/features/business/presentation/screens/business_request_quote_screen.dart';
import 'package:raabta/features/buddy/presentation/screens/buddy_chat_screen.dart';
import 'package:raabta/features/buddy/presentation/screens/buddy_hub_screen.dart';
import 'package:raabta/features/buddy/presentation/screens/buddy_opt_in_screen.dart';
import 'package:raabta/screens/community/community_screen.dart';
import 'package:raabta/screens/community/news_screen.dart';
import 'package:raabta/screens/expat_score/expat_score_screen.dart';
import 'package:raabta/screens/home_screen.dart';
import 'package:raabta/features/home/screens/home_all_services_screen.dart';
import 'package:raabta/screens/housing/housing_screen.dart';
import 'package:raabta/screens/housing/housing_detail_screen.dart';
import 'package:raabta/screens/housing/my_housing_listings_screen.dart';
import 'package:raabta/screens/housing/post_listing_screen.dart';
import 'package:raabta/features/housing/presentation/screens/housing_chat_screen.dart';
import 'package:raabta/features/housing/presentation/screens/housing_request_viewing_screen.dart';
import 'package:raabta/screens/jobs/job_application_chat_screen.dart';
import 'package:raabta/screens/jobs/job_listing_applications_screen.dart';
import 'package:raabta/screens/jobs/job_my_applications_screen.dart';
import 'package:raabta/screens/jobs/job_saved_jobs_screen.dart';
import 'package:raabta/screens/jobs/jobs_screen.dart';
import 'package:raabta/screens/services/my_service_listings_screen.dart';
import 'package:raabta/screens/services/post_service_listing_screen.dart';
import 'package:raabta/screens/services/service_category_screen.dart';
import 'package:raabta/screens/services/presentation/screens/service_quote_chat_screen.dart';
import 'package:raabta/screens/services/presentation/screens/service_submit_quote_screen.dart';
import 'package:raabta/screens/services/service_listing_detail_screen.dart';
import 'package:raabta/screens/services/services_all_services_screen.dart';
import 'package:raabta/screens/services/services_home_screen.dart';
import 'package:raabta/features/gold_intelligence/presentation/screens/gold_dashboard_screen.dart';
import 'package:raabta/features/cost_of_living/presentation/screens/cost_of_living_screen.dart';
import 'package:raabta/features/personal_budget/presentation/screens/personal_budget_screen.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/screens/cv_builder_screen.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/screens/cv_start_screen.dart';
import 'package:raabta/features/jobs/offer_calculator/presentation/screens/job_offer_calculator_screen.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/screens/cv_preview_screen.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:raabta/screens/login_screen.dart';
import 'package:raabta/features/marketplace/presentation/screens/marketplace_chat_screen.dart';
import 'package:raabta/features/marketplace/presentation/screens/marketplace_make_offer_screen.dart';
import 'package:raabta/screens/marketplace/marketplace_screen.dart';
import 'package:raabta/screens/marketplace/category_listings_screen.dart';
import 'package:raabta/screens/marketplace/marketplace_listing_detail_screen.dart';
import 'package:raabta/screens/marketplace/post_ad_screen.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/screens/monetization/business_advertise_screen.dart';
import 'package:raabta/screens/monetization/boost_listing_screen.dart';
import 'package:raabta/screens/monetization/premium_subscription_screen.dart';
import 'package:raabta/features/money_comparator/presentation/screens/corridor_comparator_screen.dart';
import 'package:raabta/features/money_comparator/presentation/screens/submit_transfer_report_screen.dart';
import 'package:raabta/screens/money/money_screen.dart';
import 'package:raabta/screens/notifications/notification_center_screen.dart';
import 'package:raabta/features/notification_preferences/presentation/screens/notification_preferences_screen.dart';
import 'package:raabta/screens/profile/appearance_screen.dart';
import 'package:raabta/screens/profile/personal_info_screen.dart';
import 'package:raabta/screens/profile/progressive_profile_capture_screen.dart';
import 'package:raabta/screens/profile/profile_language_screen.dart';
import 'package:raabta/screens/profile/profile_notification_preferences_screen.dart';
import 'package:raabta/screens/profile/help_center_screen.dart';
import 'package:raabta/screens/profile/legal_document_screen.dart';
import 'package:raabta/features/profile/privacy/screens/blocked_users_screen.dart';
import 'package:raabta/features/profile/privacy/screens/privacy_dashboard_screen.dart';
import 'package:raabta/screens/profile/report_issue_screen.dart';
import 'package:raabta/screens/profile/data/legal_content.dart';
import 'package:raabta/features/saved_search/presentation/saved_searches_screen.dart';
import 'package:raabta/screens/profile/my_activity_screen.dart';
import 'package:raabta/screens/profile/profile_screen.dart';
import 'package:raabta/screens/splash_screen.dart';
import 'package:raabta/screens/visa/visa_screen.dart';
import 'package:raabta/screens/visahelp/visa_guide_screen.dart';
import 'package:raabta/features/arabic_companion/presentation/arabic_companion_screen.dart';
import 'package:raabta/features/quick_actions/landmark_translator_screen.dart';
import 'package:raabta/features/quick_actions/bill_splitter/my_splits_screen.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/receipt_split_draft.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';
import 'package:raabta/features/quick_actions/bill_splitter/screens/receipt_assignment_screen.dart';
import 'package:raabta/features/quick_actions/bill_splitter/screens/receipt_review_screen.dart';
import 'package:raabta/features/quick_actions/bill_splitter_screen.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';
import 'package:raabta/features/quick_actions/barcode_scanner/dietary_profile_screen.dart';
import 'package:raabta/features/quick_actions/barcode_scanner_screen.dart';
import 'package:raabta/features/quick_actions/doc_scanner_screen.dart';
import 'package:raabta/features/quick_actions/scanner/scanner_studio_screen.dart';
import 'package:raabta/features/quick_actions/scanner/pdf_studio_screen.dart';
import 'package:raabta/features/quick_actions/scanner/ocr_studio_screen.dart';
import 'package:raabta/features/quick_actions/scanner/scanner_ai_screen.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/features/quick_actions/warranty_shield/screens/warranty_claim_assistant_screen.dart';
import 'package:raabta/features/quick_actions/warranty_shield/screens/warranty_detail_screen.dart';
import 'package:raabta/features/quick_actions/warranty_shield/screens/warranty_review_screen.dart';
import 'package:raabta/features/quick_actions/warranty_shield_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_proactive_protection_screens.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_academy_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_incident_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_in_call_assistant_screen.dart';
import 'package:raabta/features/scam_shield/in_call/in_call_claimed_caller.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_directory_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_official_directory_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_advisories_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_advisory_detail_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_payment_check_screen.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_sim_swap_screen.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_settings_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_checkup_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_shield_status_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_investment_check_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_security_tip_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_check_number_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_report_ready_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_evidence_locker_screen.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/scam_shield_sensitive_route_shell.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_type_library_screens.dart';
import 'package:raabta/features/scam_shield/presentation/screens/family_verification_kit_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/family_verification_share_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/family_verification_scenario_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_screen.dart';
import 'package:raabta/features/scam_shield/presentation/screens/scam_shield_share_review_screen.dart';
import 'package:raabta/features/quick_actions/climate_navigator_screen.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';
import 'package:raabta/features/telecom_decoder/presentation/screens/telecom_decoder_screen.dart';
import 'package:raabta/features/buying_car/presentation/screens/buying_car_screen.dart';
import 'package:raabta/features/freelance_visa/presentation/screens/freelance_visa_screen.dart';
import 'package:raabta/features/consumer_protection/presentation/screens/consumer_complaint_screen.dart';
import 'package:raabta/features/civic_report/presentation/screens/civic_report_screen.dart';
import 'package:raabta/features/leaving_qatar/presentation/screens/leaving_qatar_screen.dart';
import 'package:raabta/features/welcome_home/presentation/screens/welcome_home_screen.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_readiness_models.dart';
import 'package:raabta/features/disruption_readiness/presentation/screens/disruption_readiness_screen.dart';
import 'package:raabta/features/disruption_readiness/presentation/screens/disruption_understand_alert_screen.dart';
import 'package:raabta/features/quick_actions/queue_avoidance_screen.dart';
import 'package:raabta/features/quick_actions/bill_tracker/screens/bill_review_screen.dart';
import 'package:raabta/features/quick_actions/bill_tracker/screens/bill_text_import_screen.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/bill_tracker_screen.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/screens/add_loan_screen.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/screens/person_loan_detail_screen.dart';
import 'package:raabta/features/daily_utilities/ussd/ussd_codes_screen.dart';
import 'package:raabta/features/daily_utilities/driving/presentation/driving_hub_screen.dart';
import 'package:raabta/features/daily_utilities/driving/presentation/driving_fee_calculator_screen.dart';
import 'package:raabta/features/daily_utilities/driving/presentation/driving_fine_status_screen.dart';
import 'package:raabta/features/daily_utilities/driving/presentation/driving_theory_quiz_screen.dart';
import 'package:raabta/features/global_search/presentation/global_search_screen.dart';
import 'package:raabta/features/global_search/presentation/search_ask_ai_screen.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/document_vault/document_detail_screen.dart';
import 'package:raabta/features/document_vault/document_vault_screen.dart';
import 'package:raabta/features/intelligence/presentation/screens/evidence_trail_screen.dart';
import 'package:raabta/features/ramadan/ramadan_hub_screen.dart';
import 'package:raabta/features/ramadan/zakat_calculator_screen.dart';
import 'package:raabta/features/concierge_90_day/presentation/screens/concierge_journey_screen.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/screens/case_timeline_screen.dart';
import 'package:raabta/features/health_insurance/domain/models/insurance_compliance_history_entry.dart';
import 'package:raabta/features/health_insurance/presentation/screens/health_insurance_scenario_simulator_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/insurance_compliance_history_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/health_insurance_denial_dispute_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/compliance_check_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/compliance_results_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/health_insurance_dashboard_screen.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_ai_assistant_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_condition_capture_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_condition_compare_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_condition_hub_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_condition_report_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_dashboard_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_dispute_checklist_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_documents_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/listing_verification_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_lease_entry_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_history_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_scenario_simulator_screen.dart';
import 'package:raabta/features/tenancy/presentation/screens/tenancy_result_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/sponsorship_transfer_dashboard_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/transfer_ai_assistant_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/transfer_checklist_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/transfer_documents_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/transfer_readiness_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/transfer_history_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/transfer_scenario_simulator_screen.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/screens/transfer_result_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/coverage_reality_check_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/policy_explainer_screen.dart';
import 'package:raabta/features/health_insurance/presentation/screens/policy_upload_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/employer_track_record_lookup_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/eosb_certificate_verify_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/eosb_death_benefits_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/eosb_dashboard_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/employee_information_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/eosb_result_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/employer_comparison_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/legal_warnings_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/ai_assistant_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/generate_documents_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/calculation_history_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/contract_analysis_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/scenario_simulator_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/employment_timeline_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/legal_review_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_rounding_pattern_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/payslip_consistency_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_truth_hub_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_input_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_result_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_calendar_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_employee_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_summary_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_history_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_ai_review_screen.dart';
import 'package:raabta/features/eosb/presentation/screens/overtime_import_screen.dart';
import 'package:raabta/features/prospective_migrant/presentation/screens/prospective_checklist_screen.dart';
import 'package:raabta/features/prospective_migrant/presentation/screens/prospective_contract_screen.dart';
import 'package:raabta/features/prospective_migrant/presentation/screens/prospective_country_screen.dart';
import 'package:raabta/features/prospective_migrant/presentation/screens/prospective_hub_screen.dart';
import 'package:raabta/features/prospective_migrant/presentation/screens/prospective_preview_screen.dart';
import 'package:raabta/features/prospective_migrant/presentation/screens/prospective_qvc_tracker_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/prayer_dashboard_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/prayer_times_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/qibla_compass_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/nearby_mosques_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/mosque_details_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/islamic_calendar_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/jumuah_reminder_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/prayer_settings_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/prayer_notification_settings_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/prayer_history_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/prayer_assistant_screen.dart';
import 'package:raabta/features/prayer_mosque/presentation/screens/travel_prayer_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_planner_home_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_generating_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_preferences_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/generated_itinerary_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/daily_schedule_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/place_details_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_subscreens.dart';
import 'package:raabta/features/trip_planner/presentation/screens/saved_trips_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/explore_qatar_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/catalog_place_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/local_life_screens.dart';
import 'package:raabta/features/trip_planner/presentation/screens/travel_emergency_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/travel_search_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/travel_wallet_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/fair_price_guide_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_bill_scan_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_booking_import_screen.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_readiness_screen.dart';
import 'package:raabta/features/admin/admin_access.dart';
import 'package:raabta/features/admin/screens/admin_dashboard_screen.dart';
import 'package:raabta/features/admin/screens/admin_users_screen.dart';
import 'package:raabta/features/admin/screens/admin_moderation_screen.dart';
import 'package:raabta/features/admin/screens/admin_config_screen.dart';
import 'package:raabta/features/admin/screens/admin_ai_usage_screen.dart';
import 'package:raabta/features/admin/screens/admin_legal_sources_screen.dart';
import 'package:raabta/features/admin/screens/admin_legal_change_monitor_screen.dart';
import 'package:raabta/features/admin/screens/admin_shield_freshness_screen.dart';
import 'package:raabta/features/admin/screens/admin_moph_insurers_screen.dart';
import 'package:raabta/features/admin/screens/admin_gate_screens.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/features/admin/services/app_startup_guard.dart';
import 'package:raabta/features/global_search/domain/search_route_builder.dart';
import 'package:raabta/features/global_search/presentation/search_route_parameter_consumer.dart';
import 'package:raabta/features/exchange_locator/presentation/screens/company_detail_screen.dart';
import 'package:raabta/features/exchange_locator/presentation/screens/branch_detail_screen.dart';
import 'package:raabta/features/exchange_locator/presentation/screens/admin_exchange_locator_screen.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/presentation/screens/post_category_picker_screen.dart';
import 'package:raabta/features/post_engine/presentation/post_flow_actions.dart';
import 'package:raabta/features/post_engine/presentation/screens/post_flow_screen.dart';
import 'package:raabta/features/post_engine/presentation/screens/post_job_flow_screen.dart';
import 'package:raabta/features/post_engine/presentation/screens/my_posts_hub_screen.dart';
import 'package:raabta/features/post_engine/presentation/screens/post_schema_preview_screen.dart';
import 'package:raabta/features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import 'package:raabta/features/onboarding/presentation/screens/onboarding_qualifier_screen.dart';
import 'package:raabta/core/l10n/app_locale_refresh.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/onboarding/widgets/onboarding_eosb_result_gate.dart';
import 'package:raabta/features/referral/presentation/screens/referral_invite_redirect_screen.dart';
import 'package:raabta/core/router/ai_chat_entrance_orb.dart';
import 'package:raabta/core/router/ai_chat_living_entrance_page.dart';

CustomTransitionPage<void> _profileSubPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppSpacing.contentAnimation,
    reverseTransitionDuration: AppSpacing.contentAnimation,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

Widget _corridorComparatorScreen(GoRouterState state) {
  final country = state.uri.queryParameters['country'];
  final amount = double.tryParse(state.uri.queryParameters['amount'] ?? '');
  return CorridorComparatorScreen(
    initialCountryCode: country,
    initialAmount: amount,
  );
}

String _withQuery(String path, String query) {
  if (query.isEmpty) return path;
  return '$path?$query';
}

String? _appRouteRedirect(GoRouterState state) {
  final location = state.matchedLocation;

  if (location.startsWith('/admin')) {
    if (!AdminAccess.isCurrentUserAdmin()) return '/home';
  }

  // Exchange Locator root → Money Hub **Branches** (embedded panel). Detail routes stay `/exchange-locator/...`.
  if (state.uri.path == '/exchange-locator') {
    final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
    final locatorTab = tab.clamp(0, 3);
    return '/money?tab=2&locatorTab=$locatorTab';
  }

  const quickActionPrefixes = [
    '/scanner',
    '/barcode-scanner',
    '/arabic-companion',
    '/bill-splitter',
    '/warranty-shield',
    '/scam-shield',
    '/climate-navigator',
    '/queue-avoidance',
    '/bill-tracker',
    '/know-qatar',
  ];

  for (final prefix in quickActionPrefixes) {
    if (location.startsWith(prefix) &&
        !AppStartupGuard.isQuickActionRouteEnabled(prefix)) {
      return '/feature-disabled';
    }
  }

  return ComplianceFlagsGate.redirectIfGated(location);
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: appLocaleRefreshListenable,
  redirect: (context, state) => _appRouteRedirect(state),
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/prospective',
      builder: (context, state) => const ProspectiveHubScreen(),
      routes: [
        GoRoute(
          path: 'country',
          builder: (context, state) => const ProspectiveCountryScreen(),
        ),
        GoRoute(
          path: 'contract',
          builder: (context, state) => const ProspectiveContractScreen(),
        ),
        GoRoute(
          path: 'preview',
          builder: (context, state) => const ProspectivePreviewScreen(),
        ),
        GoRoute(
          path: 'checklist',
          builder: (context, state) => const ProspectiveChecklistScreen(),
        ),
        GoRoute(
          path: 'qvc',
          builder: (context, state) => const ProspectiveQvcTrackerScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/onboarding/welcome',
      builder: (context, state) => const OnboardingWelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding/qualifier',
      builder: (context, state) => const OnboardingQualifierScreen(),
    ),
    GoRoute(
      path: '/home',
      redirect: (context, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        if (tab == ShellNavConfig.legacyMarketplaceTabIndex) {
          return '/marketplace';
        }
        return null;
      },
      builder: (context, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        final launch = ShellNavConfig.resolveLegacyHomeTabQuery(tab);
        final shell = state.uri.queryParameters['shell'];
        ShellTab? initialShellTab;
        if (shell == 'documents') {
          initialShellTab = ShellTab.documents;
        }
        return HomeScreen(
          initialTab: tab,
          initialShellTab: initialShellTab,
          openAiChatOnLaunch: launch.openAiChat,
        );
      },
      routes: [
        GoRoute(
          path: 'all-services',
          builder: (context, state) => const HomeAllServicesScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => JobsScreen(
        routeParameters: SearchRouteBuilder.fromRouterState(state),
      ),
      routes: [
        GoRoute(
          path: 'post',
          builder: (context, state) {
            final category = PostFlowActions.categoryPathFromQuery(
              state.uri.queryParameters,
            );
            return PostJobFlowScreen(categoryPath: category);
          },
        ),
        GoRoute(
          path: 'my-posts',
          builder: (context, state) => const MyPostsHubScreen(),
        ),
        GoRoute(
          path: 'my-applications',
          builder: (context, state) => const JobMyApplicationsScreen(),
        ),
        GoRoute(
          path: 'saved',
          builder: (context, state) => const JobSavedJobsScreen(),
        ),
        GoRoute(
          path: 'listing/:jobId/applications',
          builder: (context, state) {
            final extra = state.extra;
            var title = 'Job listing';
            if (extra is String && extra.isNotEmpty) title = extra;
            return JobListingApplicationsScreen(
              jobId: state.pathParameters['jobId']!,
              jobTitle: title,
            );
          },
        ),
        GoRoute(
          path: 'chat/:jobId/:applicantUid',
          builder: (context, state) {
            final extra = state.extra;
            var title = 'Job listing';
            if (extra is String && extra.isNotEmpty) title = extra;
            return JobApplicationChatScreen(
              jobId: state.pathParameters['jobId']!,
              applicantUid: state.pathParameters['applicantUid']!,
              jobTitle: title,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/jobs/cv-start',
      builder: (context, state) => const CvStartScreen(),
    ),
    GoRoute(
      path: '/jobs/cv-builder',
      builder: (context, state) =>
          CvBuilderScreen(cvId: state.uri.queryParameters['id']),
    ),
    GoRoute(
      path: '/jobs/cv-preview',
      builder: (context, state) => CvPreviewScreen(
        cvId: state.uri.queryParameters['id'],
        attachJobId: state.uri.queryParameters['attachJob'],
      ),
    ),
    GoRoute(
      path: JobOfferCalculatorScreen.routePath,
      builder: (context, state) {
        final salaryRaw = state.uri.queryParameters['salary'];
        final salary = double.tryParse(salaryRaw ?? '');
        return JobOfferCalculatorScreen(
          initialSalary: salary != null && salary > 0 ? salary : null,
        );
      },
    ),
    GoRoute(
      path: '/housing',
      builder: (context, state) => HousingScreen(
        routeParameters: SearchRouteBuilder.fromRouterState(state),
      ),
      routes: [
        GoRoute(
          path: 'post',
          builder: (context, state) {
            final category = PostFlowActions.categoryPathFromQuery(
              state.uri.queryParameters,
            );
            return PostFlowScreen(
              vertical: PostVertical.housing,
              categoryPath: category,
            );
          },
        ),
        GoRoute(
          path: 'listing/:listingId',
          builder: (context, state) => HousingDetailScreen(
            listingId: state.pathParameters['listingId']!,
          ),
          routes: [
            GoRoute(
              path: 'viewing',
              builder: (context, state) {
                final extra = state.extra;
                final map = extra is Map ? extra : const {};
                return HousingRequestViewingScreen(
                  listingId: state.pathParameters['listingId']!,
                  ownerId: map['ownerId']?.toString() ?? '',
                  listingTitle: map['title']?.toString() ?? 'Listing',
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'chat/:listingId',
          builder: (context, state) {
            final extra = state.extra;
            var title = 'Listing';
            if (extra is Map && extra['title'] != null) {
              title = extra['title'].toString();
            } else if (extra is String && extra.isNotEmpty) {
              title = extra;
            }
            return HousingChatScreen(
              listingId: state.pathParameters['listingId']!,
              listingTitle: title,
            );
          },
        ),
        GoRoute(
          path: 'my-listings',
          builder: (context, state) => const MyHousingListingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/businesses',
      builder: (context, state) {
        final params = SearchRouteBuilder.fromRouterState(state);
        final tag = state.uri.queryParameters['tag'] ?? params?.businessTag;
        return BusinessesScreen(
          initialTagFilter: tag,
          routeParameters: params,
          initialListingId: state.uri.queryParameters['listingId'],
        );
      },
      routes: [
        GoRoute(
          path: 'request-appointment/:businessId',
          builder: (context, state) => BusinessRequestAppointmentScreen(
            businessId: state.pathParameters['businessId']!,
            businessName: state.uri.queryParameters['name'] ?? 'Business',
          ),
        ),
        GoRoute(
          path: 'request-quote/:businessId',
          builder: (context, state) => BusinessRequestQuoteScreen(
            businessId: state.pathParameters['businessId']!,
            businessName: state.uri.queryParameters['name'] ?? 'Business',
          ),
        ),
        GoRoute(
          path: 'post',
          builder: (context, state) {
            final category = PostFlowActions.categoryPathFromQuery(
              state.uri.queryParameters,
            );
            return PostFlowScreen(
              vertical: PostVertical.business,
              categoryPath: category,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => ServicesHomeScreen(
        routeParameters: SearchRouteBuilder.fromRouterState(state),
      ),
      routes: [
        GoRoute(
          path: 'category/:categoryId',
          builder: (context, state) => ServiceCategoryScreen(
            categoryId: state.pathParameters['categoryId']!,
            initialSubService: state.uri.queryParameters['serviceName'],
          ),
        ),
        GoRoute(
          path: 'all',
          builder: (context, state) => const ServicesAllServicesScreen(),
        ),
        GoRoute(
          path: 'post',
          builder: (context, state) {
            final query = state.uri.queryParameters;
            final category = PostFlowActions.categoryPathFromQuery(query);
            return PostFlowScreen(
              vertical: PostVertical.services,
              categoryPath: category,
              initialListingType: PostFlowActions.listingTypeFromQuery(query),
            );
          },
        ),
        GoRoute(
          path: 'listing/:listingId',
          builder: (context, state) => ServiceListingDetailScreen(
            listingId: state.pathParameters['listingId']!,
          ),
          routes: [
            GoRoute(
              path: 'quote',
              builder: (context, state) {
                final extra = state.extra;
                final map = extra is Map ? extra : const {};
                return ServiceSubmitQuoteScreen(
                  requestListingId: state.pathParameters['listingId']!,
                  customerId: map['customerId']?.toString() ?? '',
                  requestTitle: map['title']?.toString() ?? 'Request',
                );
              },
            ),
            GoRoute(
              path: 'chat/:providerId',
              builder: (context, state) {
                final extra = state.extra;
                var title = 'Request';
                if (extra is String && extra.isNotEmpty) title = extra;
                return ServiceQuoteChatScreen(
                  requestListingId: state.pathParameters['listingId']!,
                  providerId: state.pathParameters['providerId']!,
                  requestTitle: title,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'my-listings',
          builder: (context, state) => const MyServiceListingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const CommunityScreen(),
      routes: [
        GoRoute(
          path: 'buddy',
          builder: (context, state) => const BuddyHubScreen(),
          routes: [
            GoRoute(
              path: 'profile',
              builder: (context, state) => const BuddyOptInScreen(),
            ),
            GoRoute(
              path: 'chat/:threadId',
              builder: (context, state) =>
                  BuddyChatScreen(threadId: state.pathParameters['threadId']!),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/community/events',
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
    GoRoute(
      path: '/visa',
      redirect: (context, state) {
        if (state.uri.path != '/visa') return null;
        final params = SearchRouteBuilder.fromRouterState(state);
        final topic = params?.visaTopic ?? state.uri.queryParameters['topic'];
        return SearchRouteParameterConsumer.visaGuideRouteForTopic(topic);
      },
      builder: (context, state) {
        final deadlineId = state.uri.queryParameters['deadlineId'];
        return VisaScreen(highlightDeadlineId: deadlineId);
      },
      routes: [
        GoRoute(
          path: 'guide/:categoryId',
          builder: (context, state) =>
              VisaGuideScreen(categoryId: state.pathParameters['categoryId']!),
        ),
      ],
    ),
    GoRoute(
      path: '/money',
      builder: (context, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
        final locatorTab =
            int.tryParse(state.uri.queryParameters['locatorTab'] ?? '') ?? 0;
        final marketsSegment = tab == 2 ? 1 : 0;
        return MoneyScreen(
          initialTab: tab,
          initialLocatorTab: locatorTab,
          initialMarketsSegment: marketsSegment,
        );
      },
      routes: [
        GoRoute(
          path: 'corridor-comparator',
          redirect: (context, state) => _withQuery(
            '/money-services/corridor-comparator',
            state.uri.query,
          ),
          routes: [
            GoRoute(
              path: 'submit',
              redirect: (context, state) => _withQuery(
                '/money-services/corridor-comparator/submit',
                state.uri.query,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/money/corridor-comparator',
      redirect: (context, state) {
        if (state.uri.path.endsWith('/submit')) {
          return _withQuery(
            '/money-services/corridor-comparator/submit',
            state.uri.query,
          );
        }
        return _withQuery(
          '/money-services/corridor-comparator',
          state.uri.query,
        );
      },
    ),
    GoRoute(
      path: '/money-services/gold',
      builder: (context, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
        return GoldDashboardScreen(initialTab: tab);
      },
    ),
    GoRoute(
      path: '/money-services/cost-of-living',
      builder: (context, state) => const CostOfLivingScreen(),
    ),
    GoRoute(
      path: '/money-services/personal-budget',
      builder: (context, state) => const PersonalBudgetScreen(),
    ),
    GoRoute(
      path: '/money-services/corridor-comparator',
      builder: (context, state) => _corridorComparatorScreen(state),
      routes: [
        GoRoute(
          path: 'submit',
          builder: (context, state) => SubmitTransferReportScreen(
            initialCountryCode: state.uri.queryParameters['country'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/exchange-locator',
      // Root `/exchange-locator` redirects to Money Hub (see `_appRouteRedirect`). Stub never shown.
      builder: (context, state) => const SizedBox.shrink(),
      routes: [
        GoRoute(
          path: 'company/:companyId',
          builder: (context, state) => CompanyDetailScreen(
            companyId: state.pathParameters['companyId']!,
          ),
        ),
        GoRoute(
          path: 'branch/:branchId',
          builder: (context, state) =>
              BranchDetailScreen(branchId: state.pathParameters['branchId']!),
        ),
      ],
    ),
    GoRoute(path: '/doctors', redirect: (_, __) => '/health-insurance'),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
      routes: [
        GoRoute(
          path: 'post',
          builder: (context, state) {
            final category = PostFlowActions.categoryPathFromQuery(
              state.uri.queryParameters,
            );
            return PostFlowScreen(
              vertical: PostVertical.marketplace,
              categoryPath: category,
            );
          },
        ),
        GoRoute(
          path: 'category/:categoryId',
          builder: (context, state) => CategoryListingsScreen(
            categoryId: state.pathParameters['categoryId']!,
          ),
        ),
        GoRoute(
          path: 'listing/:listingId',
          builder: (context, state) {
            final extra = state.extra;
            return MarketplaceListingDetailScreen(
              listingId: state.pathParameters['listingId']!,
              initialListing: extra is MarketplaceListing ? extra : null,
            );
          },
          routes: [
            GoRoute(
              path: 'offer',
              builder: (context, state) {
                final extra = state.extra;
                final map = extra is Map ? extra : const {};
                return MarketplaceMakeOfferScreen(
                  listingId: state.pathParameters['listingId']!,
                  sellerId: map['sellerId']?.toString() ?? '',
                  listingTitle: map['title']?.toString() ?? 'Listing',
                  listedPriceHint: map['priceHint'] is num
                      ? (map['priceHint'] as num).toDouble()
                      : null,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'chat/:listingId',
          builder: (context, state) {
            final extra = state.extra;
            var title = 'Listing';
            if (extra is String && extra.isNotEmpty) title = extra;
            return MarketplaceChatScreen(
              listingId: state.pathParameters['listingId']!,
              listingTitle: title,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/ai-chat',
      pageBuilder: (context, state) {
        final extra = state.extra;
        String? initialMessage;
        String? composerHint;
        String? contextSubtitle;
        String? contextSource;
        String? contextBody;
        var livingEntrance = false;
        if (extra is Map<String, dynamic>) {
          initialMessage = extra['query'] as String?;
          composerHint = extra['composerHint'] as String?;
          contextSubtitle = extra['contextSubtitle'] as String?;
          contextSource = extra['contextSource'] as String?;
          contextBody = extra['contextBody'] as String?;
          livingEntrance = extra['livingEntrance'] as bool? ?? false;
        } else if (extra is String) {
          initialMessage = extra;
        }
        final autoSend = extra is Map<String, dynamic>
            ? (extra['autoSendInitialMessage'] as bool? ?? true)
            : true;
        final screen = AiChatScreen(
          initialMessage: initialMessage,
          composerHint: composerHint,
          contextSubtitle: contextSubtitle,
          contextSource: contextSource,
          contextBody: contextBody,
          autoSendInitialMessage: autoSend,
          livingEntrance: livingEntrance,
        );
        if (livingEntrance) {
          final entranceOrbRect = extra is Map<String, dynamic>
              ? AiChatEntranceOrbRectCodec.decode(extra['entranceOrbRect'])
              : null;
          return buildAiChatLivingEntrancePage(
            state: state,
            child: screen,
            entranceOrbRect: entranceOrbRect,
          );
        }
        return MaterialPage<void>(key: state.pageKey, child: screen);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'my-activity',
          builder: (context, state) => const MyActivityScreen(),
        ),
        GoRoute(
          path: 'saved-searches',
          builder: (context, state) => const SavedSearchesScreen(),
        ),
        GoRoute(
          path: 'personal-info',
          builder: (context, state) => const PersonalInfoScreen(),
        ),
        GoRoute(
          path: 'progressive-capture',
          builder: (context, state) => const ProgressiveProfileCaptureScreen(),
        ),
        GoRoute(
          path: 'appearance',
          pageBuilder: (context, state) =>
              _profileSubPage(state: state, child: const AppearanceScreen()),
        ),
        GoRoute(
          path: 'language',
          builder: (context, state) => const ProfileLanguageScreen(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) =>
              const ProfileNotificationPreferencesScreen(),
        ),
        GoRoute(
          path: 'help',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: 'report-issue',
          builder: (context, state) => const ReportIssueScreen(),
        ),
        GoRoute(
          path: 'privacy',
          pageBuilder: (context, state) => _profileSubPage(
            state: state,
            child: const PrivacyDashboardScreen(),
          ),
        ),
        GoRoute(
          path: 'blocked-users',
          pageBuilder: (context, state) =>
              _profileSubPage(state: state, child: const BlockedUsersScreen()),
        ),
        GoRoute(
          path: 'privacy-policy',
          builder: (context, state) =>
              const LegalDocumentScreen(type: LegalDocumentType.privacy),
        ),
        GoRoute(
          path: 'terms',
          builder: (context, state) =>
              const LegalDocumentScreen(type: LegalDocumentType.terms),
        ),
      ],
    ),
    GoRoute(
      path: '/appearance',
      redirect: (context, state) => '/profile/appearance',
    ),
    GoRoute(
      path: '/expat-score',
      builder: (context, state) => const ExpatScoreScreen(),
    ),
    GoRoute(
      path: '/business-advertise',
      redirect: (context, state) =>
          ComplianceFlagsGate.redirectIfGated(state.uri.path),
      builder: (context, state) => const BusinessAdvertiseScreen(),
    ),
    GoRoute(
      path: '/advertise',
      redirect: (context, state) =>
          ComplianceFlagsGate.redirectIfGated(state.uri.path),
      builder: (context, state) => const BusinessAdvertiseScreen(),
    ),
    GoRoute(
      path: '/premium',
      redirect: (context, state) =>
          ComplianceFlagsGate.redirectIfGated(state.uri.path),
      builder: (context, state) => const PremiumSubscriptionScreen(),
    ),
    GoRoute(
      path: '/boost-listing',
      redirect: (context, state) =>
          ComplianceFlagsGate.redirectIfGated(state.uri.path),
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map<String, dynamic> ? extra : const {};
        return BoostListingScreen(
          listingTitle: map['title'] as String? ?? 'Your Listing',
          currentViews: map['views'] as int? ?? 0,
          currentContacts: map['contacts'] as int? ?? 0,
          listingId: map['id'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/global-search',
      builder: (context, state) => const GlobalSearchScreen(),
      routes: [
        GoRoute(
          path: 'ask-ai',
          builder: (context, state) {
            final extra = state.extra;
            SearchAskAiResult? offer;
            SearchAnalysis? analysis;
            if (extra is Map<String, dynamic>) {
              offer = extra['offer'] as SearchAskAiResult?;
              analysis = extra['analysis'] as SearchAnalysis?;
            }
            if (offer == null || analysis == null) {
              return const GlobalSearchScreen();
            }
            return SearchAskAiScreen(offer: offer, analysis: analysis);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      redirect: (context, state) => '/notification-preferences',
    ),
    GoRoute(
      path: '/notification-preferences',
      builder: (context, state) => const NotificationPreferencesScreen(),
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const ScannerStudioScreen(),
      routes: [
        GoRoute(
          path: 'capture',
          builder: (context, state) {
            final import = state.uri.queryParameters['import'] == '1';
            final source = state.uri.queryParameters['source'];
            return DocScannerScreen(autoImport: import, scanSource: source);
          },
        ),
        GoRoute(
          path: 'pdf-tools',
          builder: (context, state) {
            final mode = state.uri.queryParameters['mode'] ?? 'merge';
            return PdfStudioScreen(mode: mode);
          },
        ),
        GoRoute(
          path: 'ocr',
          builder: (context, state) => const OcrStudioScreen(),
        ),
        GoRoute(
          path: 'ai',
          builder: (context, state) => const ScannerAiScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/barcode-scanner',
      builder: (context, state) => const BarcodeScannerScreen(),
    ),
    GoRoute(
      path: '/dietary-profile',
      builder: (context, state) =>
          DietaryProfileScreen(onComplete: () => context.pop()),
    ),
    GoRoute(
      path: '/arabic-companion',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        final phrase = state.uri.queryParameters['phrase'];
        return ArabicCompanionScreen(
          initialCategoryId: category,
          initialPhraseId: phrase,
        );
      },
      routes: [
        GoRoute(
          path: 'translate',
          builder: (context, state) =>
              const LandmarkTranslatorScreen(companionMode: true),
        ),
      ],
    ),
    GoRoute(
      path: '/landmark-translator',
      redirect: (context, state) => '/arabic-companion/translate',
    ),
    GoRoute(
      path: '/bill-splitter',
      builder: (context, state) => const BillSplitterScreen(),
      routes: [
        GoRoute(
          path: 'receipt/review',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is ReceiptLineItemsExtractionResult) {
              return ReceiptReviewScreen(
                initialExtraction: extra,
                people: const [],
              );
            }
            if (extra is Map<String, dynamic>) {
              return ReceiptReviewScreen(
                initialExtraction:
                    extra['extraction'] as ReceiptLineItemsExtractionResult,
                people: (extra['people'] as List<SplitPerson>?) ?? const [],
              );
            }
            return const BillSplitterScreen();
          },
        ),
        GoRoute(
          path: 'receipt/assign',
          builder: (context, state) {
            final draft = state.extra;
            if (draft is ReceiptSplitDraft) {
              return ReceiptAssignmentScreen(draft: draft);
            }
            return const BillSplitterScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/my-splits',
      builder: (context, state) => const MySplitsScreen(),
    ),
    GoRoute(
      path: '/warranty-shield',
      builder: (context, state) => const WarrantyShieldScreen(),
      routes: [
        GoRoute(
          path: 'scan/review',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              return WarrantyReviewScreen(
                initialExtraction:
                    extra['extraction'] as WarrantyExtractionResult,
                sourceImagePath: extra['imagePath'] as String? ?? '',
              );
            }
            return const WarrantyShieldScreen();
          },
        ),
        GoRoute(
          path: 'item',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is WarrantyItem) {
              return WarrantyDetailScreen(item: extra);
            }
            return const WarrantyShieldScreen();
          },
        ),
        GoRoute(
          path: 'claim',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Map<String, dynamic> &&
                extra['item'] is WarrantyItem) {
              return WarrantyClaimAssistantScreen(
                item: extra['item'] as WarrantyItem,
                expiredAcknowledged:
                    extra['expiredAcknowledged'] as bool? ?? false,
              );
            }
            if (extra is WarrantyItem) {
              return WarrantyClaimAssistantScreen(item: extra);
            }
            return const WarrantyShieldScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/scam-shield',
      builder: (context, state) => const ScamShieldScreen(),
      routes: [
        GoRoute(
          path: 'share-review',
          builder: (context, state) => const ScamShieldShareReviewScreen(),
        ),
        GoRoute(
          path: 'incident',
          builder: (context, state) {
            final extra = state.extra;
            final prefill = extra is ScamIncidentPrefill ? extra : null;
            return ScamShieldIncidentScreen(prefill: prefill);
          },
        ),
        GoRoute(
          path: 'in-call-assistant',
          builder: (context, state) {
            final skip =
                state.uri.queryParameters['skipClaimed'] == '1' ||
                state.uri.queryParameters['skipClaimed'] == 'true';
            return ScamShieldInCallAssistantScreen(skipClaimedCallerStep: skip);
          },
        ),
        GoRoute(
          path: 'sim-swap',
          builder: (context, state) => const ScamShieldSimSwapScreen(),
        ),
        GoRoute(
          path: 'directory',
          builder: (context, state) => const ScamShieldDirectoryScreen(),
        ),
        GoRoute(
          path: 'official-directory',
          builder: (context, state) =>
              const ScamShieldOfficialDirectoryScreen(),
        ),
        GoRoute(
          path: 'payment-check',
          builder: (context, state) {
            final extra = state.extra;
            final prefill = extra is PaymentCheckPrefill ? extra : null;
            return ScamShieldPaymentCheckScreen(prefill: prefill);
          },
        ),
        GoRoute(
          path: 'advisories',
          builder: (context, state) => const ScamShieldAdvisoriesScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => ScamShieldAdvisoryDetailScreen(
                advisoryId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'academy',
          builder: (context, state) => const ScamShieldAcademyScreen(),
        ),
        GoRoute(
          path: 'call-screening',
          builder: (context, state) => const ScamCallScreeningOptInScreen(),
        ),
        GoRoute(
          path: 'sms-filter-guide',
          builder: (context, state) => const ScamSmsFilterGuideScreen(),
        ),
        GoRoute(
          path: 'checkup',
          builder: (context, state) => const ScamShieldCheckupScreen(),
        ),
        GoRoute(
          path: 'personal-context',
          builder: (context, state) => const PersonalContextSettingsScreen(),
        ),
        GoRoute(
          path: 'shield',
          builder: (context, state) => const ScamShieldShieldStatusScreen(),
        ),
        GoRoute(
          path: 'security-tip',
          builder: (context, state) {
            final topicId = state.uri.queryParameters['topic'] ?? '';
            return ScamShieldSecurityTipScreen(topicId: topicId);
          },
        ),
        GoRoute(
          path: 'check-number',
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'];
            return ScamShieldCheckNumberScreen(prefillNumber: phone);
          },
        ),
        GoRoute(
          path: 'report-ready',
          builder: (context, state) => const ScamShieldSensitiveRouteShell(
            child: ScamShieldReportReadyScreen(),
          ),
        ),
        GoRoute(
          path: 'evidence-locker',
          builder: (context, state) => const ScamShieldSensitiveRouteShell(
            child: ScamShieldEvidenceLockerScreen(),
          ),
        ),
        GoRoute(
          path: 'investment-check',
          builder: (context, state) => const ScamShieldInvestmentCheckScreen(),
        ),
        GoRoute(
          path: 'scam-types',
          builder: (context, state) => const ScamTypeLibraryListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => ScamTypeLibraryDetailScreen(
                typeId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'family-verification',
          builder: (context, state) => const ScamShieldSensitiveRouteShell(
            child: FamilyVerificationKitScreen(),
          ),
          routes: [
            GoRoute(
              path: 'share',
              builder: (context, state) => const ScamShieldSensitiveRouteShell(
                child: FamilyVerificationShareScreen(),
              ),
            ),
            GoRoute(
              path: 'practice',
              builder: (context, state) => const ScamShieldSensitiveRouteShell(
                child: FamilyVerificationScenarioScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/climate-navigator',
      builder: (context, state) => const ClimateNavigatorScreen(),
    ),
    GoRoute(
      path: '/queue-avoidance',
      builder: (context, state) => const QueueAvoidanceScreen(),
    ),
    GoRoute(
      path: '/bill-tracker',
      builder: (context, state) => const BillTrackerScreen(),
      routes: [
        GoRoute(
          path: 'scan/review',
          builder: (context, state) {
            final result = state.extra as BillScanPipelineResult?;
            if (result == null) {
              return const BillTrackerScreen();
            }
            return BillReviewScreen(pipelineResult: result);
          },
        ),
        GoRoute(
          path: 'import/text',
          builder: (context, state) {
            final initial = state.extra as String?;
            return BillTextImportScreen(initialText: initial);
          },
        ),
        GoRoute(
          path: 'loans/add',
          builder: (context, state) => const AddLoanScreen(),
        ),
        GoRoute(
          path: 'loans/person',
          builder: (context, state) {
            final personKey =
                state.extra as String? ??
                state.uri.queryParameters['personKey'] ??
                '';
            return PersonLoanDetailScreen(personKey: personKey);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/know-qatar',
      builder: (context, state) {
        final section = state.uri.queryParameters['section'];
        return KnowQatarScreen(initialSectionKey: section);
      },
    ),
    GoRoute(
      path: TelecomDecoderScreen.route,
      redirect: (_, _) =>
          KnowQatarScreen.route(sectionKey: 'telecom_contracts'),
    ),
    GoRoute(
      path: BuyingCarScreen.route,
      redirect: (_, _) => KnowQatarScreen.route(sectionKey: 'buying_car'),
    ),
    GoRoute(
      path: FreelanceVisaScreen.route,
      redirect: (_, _) => KnowQatarScreen.route(sectionKey: 'freelance_visa'),
    ),
    GoRoute(
      path: ConsumerComplaintScreen.route,
      builder: (context, state) => const ConsumerComplaintScreen(),
    ),
    GoRoute(
      path: CivicReportScreen.route,
      builder: (context, state) => const CivicReportScreen(),
    ),
    GoRoute(
      path: LeavingQatarScreen.route,
      builder: (context, state) => const LeavingQatarScreen(),
    ),
    GoRoute(
      path: WelcomeHomeScreen.route,
      builder: (context, state) => const WelcomeHomeScreen(),
    ),
    GoRoute(
      path: '/disruption-readiness/leaving',
      builder: (context, state) => const DisruptionReadinessScreen(
        profile: DisruptionEntryProfile.leavingQatar,
      ),
    ),
    GoRoute(
      path: '/disruption-readiness/know',
      builder: (context, state) => const DisruptionReadinessScreen(
        profile: DisruptionEntryProfile.knowQatar,
      ),
    ),
    GoRoute(
      path: '/disruption-readiness/trip',
      builder: (context, state) {
        final tripId = state.uri.queryParameters['tripId'];
        return DisruptionReadinessScreen(
          profile: DisruptionEntryProfile.tripPlanner,
          tripId: tripId,
        );
      },
    ),
    GoRoute(
      path: DisruptionUnderstandAlertScreen.route,
      builder: (context, state) => const DisruptionUnderstandAlertScreen(),
    ),
    GoRoute(
      path: '/daily-ussd',
      builder: (context, state) => const UssdCodesScreen(),
    ),
    GoRoute(
      path: '/daily-phrases',
      redirect: (context, state) {
        final query = state.uri.query;
        return query.isEmpty ? '/arabic-companion' : '/arabic-companion?$query';
      },
    ),
    GoRoute(
      path: '/driving',
      builder: (context, state) => const DrivingHubScreen(),
      routes: [
        GoRoute(
          path: 'calculator',
          builder: (context, state) => const DrivingFeeCalculatorScreen(),
        ),
        GoRoute(
          path: 'fine-status',
          builder: (context, state) => const DrivingFineStatusScreen(),
        ),
        GoRoute(
          path: 'theory-quiz',
          builder: (context, state) => const DrivingTheoryQuizScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/document-vault',
      builder: (context, state) => const DocumentVaultScreen(),
    ),
    GoRoute(
      path: '/document-vault/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final data = state.extra as Map<String, dynamic>? ?? {};
        return DocumentDetailScreen(documentId: id, documentData: data);
      },
    ),
    GoRoute(
      path: '/evidence-trail',
      builder: (context, state) => const EvidenceTrailScreen(),
    ),
    GoRoute(
      path: '/ramadan',
      builder: (context, state) => const RamadanHubScreen(),
    ),
    GoRoute(
      path: '/ramadan/qibla',
      redirect: (context, state) => '/prayer-mosque/qibla',
    ),
    GoRoute(
      path: '/ramadan/zakat',
      builder: (context, state) => const ZakatCalculatorScreen(),
    ),
    GoRoute(
      path: '/trip-planner',
      builder: (context, state) => const TripPlannerHomeScreen(),
    ),
    GoRoute(
      path: '/trip-planner/generating',
      builder: (context, state) => const TripGeneratingScreen(),
    ),
    GoRoute(
      path: '/trip-planner/preferences',
      builder: (context, state) => const TripPreferencesScreen(),
    ),
    GoRoute(
      path: '/trip-planner/saved',
      builder: (context, state) => const SavedTripsScreen(),
    ),
    GoRoute(
      path: '/trip-planner/settings',
      builder: (context, state) => const TripSettingsScreen(),
    ),
    GoRoute(
      path: '/trip-planner/shared/:code',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return SharedTripScreen(shareCode: code);
      },
    ),
    GoRoute(
      path: '/trip-planner/itinerary/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GeneratedItineraryScreen(tripId: id);
      },
    ),
    GoRoute(
      path: '/trip-planner/day/:tripId/:day',
      builder: (context, state) {
        final tripId = state.pathParameters['tripId']!;
        final day = int.parse(state.pathParameters['day']!);
        return DailyScheduleScreen(tripId: tripId, dayNumber: day);
      },
    ),
    GoRoute(
      path: '/trip-planner/activity/:tripId/:activityId',
      builder: (context, state) {
        final tripId = state.pathParameters['tripId']!;
        final activityId = state.pathParameters['activityId']!;
        return PlaceDetailsScreen(tripId: tripId, activityId: activityId);
      },
    ),
    GoRoute(
      path: '/trip-planner/budget/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripBudgetScreen(tripId: id);
      },
    ),
    GoRoute(
      path: '/trip-planner/map/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripMapScreen(tripId: id);
      },
    ),
    GoRoute(
      path: '/trip-planner/weather/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripWeatherScreen(tripId: id);
      },
    ),
    GoRoute(
      path: '/trip-planner/summary/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripSummaryScreen(tripId: id);
      },
    ),
    GoRoute(
      path: '/trip-planner/explore',
      builder: (context, state) => const ExploreQatarScreen(),
    ),
    GoRoute(
      path: '/trip-planner/explore/:category',
      builder: (context, state) {
        final category = state.pathParameters['category']!;
        return ExploreCategoryScreen(categoryName: category);
      },
    ),
    GoRoute(
      path: '/trip-planner/place/:placeId',
      builder: (context, state) {
        final placeId = state.pathParameters['placeId']!;
        return CatalogPlaceScreen(placeId: placeId);
      },
    ),
    GoRoute(
      path: '/trip-planner/search',
      builder: (context, state) => const TravelSearchScreen(),
    ),
    GoRoute(
      path: '/trip-planner/wallet',
      builder: (context, state) => const TravelWalletScreen(),
    ),
    GoRoute(
      path: '/trip-planner/fair-prices',
      builder: (context, state) => const FairPriceGuideScreen(),
    ),
    GoRoute(
      path: '/trip-planner/bill-scan',
      builder: (context, state) => const TripBillScanScreen(),
    ),
    GoRoute(
      path: '/trip-planner/import-booking',
      builder: (context, state) => const TripBookingImportScreen(),
    ),
    GoRoute(
      path: '/trip-planner/readiness/:id',
      builder: (context, state) =>
          TripReadinessScreen(tripId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trip-planner/emergency',
      builder: (context, state) => const TravelEmergencyScreen(),
    ),
    GoRoute(
      path: '/trip-planner/local-life',
      builder: (context, state) => const LocalLifeHubScreen(),
      routes: [
        GoRoute(
          path: ':categoryId',
          builder: (context, state) => LocalLifeCategoryScreen(
            categoryId: state.pathParameters['categoryId']!,
          ),
          routes: [
            GoRoute(
              path: ':entryId',
              builder: (context, state) => LocalLifeEntryScreen(
                categoryId: state.pathParameters['categoryId']!,
                entryId: state.pathParameters['entryId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/trip-planner/guide/culture',
      redirect: (context, state) =>
          '/trip-planner/local-life/culture_etiquette',
    ),
    GoRoute(
      path: '/trip-planner/guide/dos-donts',
      redirect: (context, state) =>
          '/trip-planner/local-life/culture_etiquette',
    ),
    GoRoute(
      path: '/trip-planner/guide/ramadan',
      redirect: (context, state) =>
          '/trip-planner/local-life/culture_etiquette',
    ),
    GoRoute(
      path: '/trip-planner/guide/transport',
      redirect: (context, state) => '/trip-planner/local-life/getting_around',
    ),
    GoRoute(
      path: '/prayer-mosque',
      builder: (context, state) => const PrayerDashboardScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/times',
      builder: (context, state) => const PrayerTimesScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/qibla',
      builder: (context, state) => const QiblaCompassScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/mosques',
      builder: (context, state) => const NearbyMosquesScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/mosque/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MosqueDetailsScreen(mosqueId: id);
      },
    ),
    GoRoute(
      path: '/prayer-mosque/calendar',
      builder: (context, state) => const IslamicCalendarScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/jumuah',
      builder: (context, state) => const JumuahReminderScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/settings',
      builder: (context, state) => const PrayerSettingsScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/notifications',
      builder: (context, state) => const PrayerNotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/history',
      builder: (context, state) => const PrayerHistoryScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/assistant',
      builder: (context, state) => const PrayerAssistantScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/travel',
      builder: (context, state) => const TravelPrayerScreen(),
    ),
    GoRoute(
      path: '/prayer-mosque/search',
      builder: (context, state) => const PrayerSearchScreen(),
    ),
    GoRoute(
      path: '/invite/:code',
      builder: (context, state) => ReferralInviteRedirectScreen(
        code: state.pathParameters['code'] ?? '',
      ),
    ),
    GoRoute(
      path: '/agency-verification/check',
      builder: (context, state) => AgencyVerificationScreen(
        initialCountryId: state.uri.queryParameters['country'] ?? '',
        initialSection: state.uri.queryParameters['section'] ?? '',
      ),
    ),
    GoRoute(
      path: '/employer-track-record/check',
      builder: (context, state) => EmployerTrackRecordLookupScreen(
        initialEmployerName: state.uri.queryParameters['employer'] ?? '',
      ),
    ),
    GoRoute(
      path: '/eosb',
      builder: (context, state) => const EosbDashboardScreen(),
    ),
    GoRoute(
      path: '/eosb/employee-info',
      builder: (context, state) => EmployeeInformationScreen(
        fromOnboarding: state.uri.queryParameters['fromOnboarding'] == '1',
        referralCode: state.uri.queryParameters['ref'],
      ),
    ),
    GoRoute(
      path: '/eosb/result',
      builder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['fromOnboarding'] == '1';
        final legalUpdate = state.uri.queryParameters['legalUpdate'] == '1';
        final screen = EosbResultScreen(showLegalUpdateBanner: legalUpdate);
        if (fromOnboarding) {
          return OnboardingEosbResultGate(child: screen);
        }
        return screen;
      },
    ),
    GoRoute(
      path: '/eosb/comparison',
      builder: (context, state) => const EmployerComparisonScreen(),
    ),
    GoRoute(
      path: '/eosb/warnings',
      builder: (context, state) => const LegalWarningsScreen(),
    ),
    GoRoute(
      path: '/eosb/death-benefits',
      builder: (context, state) => const EosbDeathBenefitsScreen(),
    ),
    GoRoute(
      path: '/eosb/ai-assistant',
      builder: (context, state) => const EosbAiAssistantScreen(),
    ),
    GoRoute(
      path: '/eosb/documents',
      builder: (context, state) => const GenerateDocumentsScreen(),
    ),
    GoRoute(
      path: '/eosb/verify/:certificateId',
      builder: (context, state) => EosbCertificateVerifyScreen(
        certificateId: state.pathParameters['certificateId'] ?? '',
        fingerprint: state.uri.queryParameters['fingerprint'],
      ),
    ),
    GoRoute(
      path: '/eosb/history',
      builder: (context, state) => CalculationHistoryScreen(
        openEntryId: state.uri.queryParameters['openEntry'],
        legalUpdate: state.uri.queryParameters['legalUpdate'] == '1',
      ),
    ),
    GoRoute(
      path: '/eosb/settings',
      redirect: (context, state) => '/profile/privacy',
    ),
    GoRoute(
      path: '/eosb/contract-analysis',
      builder: (context, state) => const ContractAnalysisScreen(),
    ),
    GoRoute(
      path: '/eosb/scenarios',
      builder: (context, state) => const ScenarioSimulatorScreen(),
    ),
    GoRoute(
      path: '/eosb/timeline',
      builder: (context, state) => const EmploymentTimelineScreen(),
    ),
    GoRoute(
      path: '/eosb/legal-review',
      builder: (context, state) => const LegalReviewScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime',
      builder: (context, state) => const OvertimeTruthHubScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/input',
      builder: (context, state) => const OvertimeInputScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/result',
      builder: (context, state) => const OvertimeResultScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/calendar',
      builder: (context, state) => const OvertimeCalendarScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/employee',
      builder: (context, state) => const OvertimeEmployeeScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/summary',
      builder: (context, state) => const OvertimeSummaryScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/history',
      builder: (context, state) => const OvertimeHistoryScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/ai-review',
      builder: (context, state) => const OvertimeAiReviewScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/import',
      builder: (context, state) => const OvertimeImportScreen(),
    ),
    GoRoute(
      path: '/eosb/overtime/rounding',
      builder: (context, state) => const OvertimeRoundingPatternScreen(),
    ),
    GoRoute(
      path: '/eosb/payslip-consistency',
      builder: (context, state) => const PayslipConsistencyScreen(),
    ),
    GoRoute(
      path: '/concierge-90-day',
      builder: (context, state) => const ConciergeJourneyScreen(),
    ),
    GoRoute(
      path: '/health-insurance',
      builder: (context, state) => const HealthInsuranceDashboardScreen(),
      routes: [
        GoRoute(
          path: 'compliance',
          builder: (context, state) => const ComplianceCheckScreen(),
          routes: [
            GoRoute(
              path: 'results',
              builder: (context, state) => const ComplianceResultsScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) =>
                  const InsuranceComplianceHistoryScreen(),
              routes: [
                GoRoute(
                  path: ':entryId',
                  builder: (context, state) {
                    final entry =
                        state.extra as InsuranceComplianceHistoryEntry?;
                    if (entry == null) {
                      return const InsuranceComplianceHistoryScreen();
                    }
                    return InsuranceComplianceHistoryDetailScreen(entry: entry);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'coverage-reality-check',
          builder: (context, state) => const CoverageRealityCheckScreen(),
        ),
        GoRoute(
          path: 'upload',
          builder: (context, state) => const PolicyUploadScreen(),
        ),
        GoRoute(
          path: 'scenarios',
          builder: (context, state) =>
              const HealthInsuranceScenarioSimulatorScreen(),
        ),
        GoRoute(
          path: 'policy-explainer',
          builder: (context, state) => const PolicyExplainerScreen(),
        ),
        GoRoute(
          path: 'denial-dispute',
          builder: (context, state) =>
              const HealthInsuranceDenialDisputeScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/case-timeline/:engine/:caseId',
      builder: (context, state) {
        final engine =
            CaseTimelineEngineTypeX.fromStorage(
              state.pathParameters['engine'],
            ) ??
            CaseTimelineEngineType.eosb;
        final caseId = state.pathParameters['caseId'] ?? '';
        final includeSettlement =
            state.uri.queryParameters['settlement'] != '0';
        return CaseTimelineScreen(
          engine: engine,
          caseId: caseId,
          eosbIncludeSettlement: includeSettlement,
        );
      },
    ),
    GoRoute(
      path: '/tenancy',
      builder: (context, state) => const TenancyDashboardScreen(),
      routes: [
        GoRoute(
          path: 'listing-check',
          builder: (context, state) => const ListingVerificationScreen(),
        ),
        GoRoute(
          path: 'lease-entry',
          builder: (context, state) => const TenancyLeaseEntryScreen(),
        ),
        GoRoute(
          path: 'result',
          builder: (context, state) => const TenancyResultScreen(),
        ),
        GoRoute(
          path: 'checklist',
          builder: (context, state) => const TenancyDisputeChecklistScreen(),
        ),
        GoRoute(
          path: 'documents',
          builder: (context, state) => const TenancyDocumentsScreen(),
        ),
        GoRoute(
          path: 'ai-assistant',
          builder: (context, state) => const TenancyAiAssistantScreen(),
        ),
        GoRoute(
          path: 'scenarios',
          builder: (context, state) => const TenancyScenarioSimulatorScreen(),
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => const TenancyHistoryScreen(),
        ),
        GoRoute(
          path: 'condition',
          builder: (context, state) => const TenancyConditionHubScreen(),
          routes: [
            GoRoute(
              path: 'capture',
              builder: (context, state) {
                final typeRaw = state.uri.queryParameters['type'];
                final type = typeRaw == 'moveOut'
                    ? TenancyConditionRecordType.moveOut
                    : TenancyConditionRecordType.moveIn;
                return TenancyConditionCaptureScreen(recordType: type);
              },
            ),
            GoRoute(
              path: 'compare',
              builder: (context, state) =>
                  const TenancyConditionCompareScreen(),
            ),
            GoRoute(
              path: 'report',
              builder: (context, state) => const TenancyConditionReportScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/sponsorship-transfer',
      builder: (context, state) => const SponsorshipTransferDashboardScreen(),
      routes: [
        GoRoute(
          path: 'readiness',
          builder: (context, state) => const TransferReadinessScreen(),
        ),
        GoRoute(
          path: 'result',
          builder: (context, state) => const TransferResultScreen(),
        ),
        GoRoute(
          path: 'checklist',
          builder: (context, state) => const TransferChecklistScreen(),
        ),
        GoRoute(
          path: 'documents',
          builder: (context, state) => const TransferDocumentsScreen(),
        ),
        GoRoute(
          path: 'ai-assistant',
          builder: (context, state) => const TransferAiAssistantScreen(),
        ),
        GoRoute(
          path: 'scenarios',
          builder: (context, state) => const TransferScenarioSimulatorScreen(),
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => const TransferHistoryScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/maintenance',
      builder: (context, state) => const MaintenanceScreen(),
    ),
    GoRoute(
      path: '/force-update',
      builder: (context, state) => const ForceUpdateScreen(),
    ),
    GoRoute(
      path: '/suspended',
      builder: (context, state) => const SuspendedAccountScreen(),
    ),
    GoRoute(
      path: '/feature-disabled',
      builder: (context, state) => const FeatureDisabledScreen(),
    ),
    GoRoute(
      path: '/my-posts',
      builder: (context, state) => const MyPostsHubScreen(),
    ),
    GoRoute(
      path: '/dev/post-schema-preview',
      builder: (context, state) {
        final vertical =
            PostVertical.fromId(state.uri.queryParameters['vertical']) ??
            PostVertical.marketplace;
        final categoryPath =
            state.uri.queryParameters['category'] ?? 'other.miscellaneous';
        return PostSchemaPreviewScreen(
          vertical: vertical,
          categoryPath: categoryPath,
        );
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'users',
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: 'moderation',
          builder: (context, state) => const AdminModerationScreen(),
        ),
        GoRoute(
          path: 'config',
          builder: (context, state) => const AdminConfigScreen(),
        ),
        GoRoute(
          path: 'ai-usage',
          builder: (context, state) => const AdminAiUsageScreen(),
        ),
        GoRoute(
          path: 'legal-sources',
          builder: (context, state) => const AdminLegalSourcesScreen(),
        ),
        GoRoute(
          path: 'legal-change-monitor',
          builder: (context, state) => const AdminLegalChangeMonitorScreen(),
        ),
        GoRoute(
          path: 'moph-insurers',
          builder: (context, state) => const AdminMophInsurersScreen(),
        ),
        GoRoute(
          path: 'exchange-locator',
          builder: (context, state) => const AdminExchangeLocatorScreen(),
        ),
        GoRoute(
          path: 'shield-freshness',
          builder: (context, state) => const AdminShieldFreshnessScreen(),
        ),
      ],
    ),
  ],
);
