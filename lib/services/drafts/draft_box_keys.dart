/// Stable, namespaced Hive draft keys — `{namespace}_{form}` or with suffix.
///
/// Storage key in Hive is `{userId}::{formId}` (see [DraftService]).
/// Convention: lowercase snake_case; append dynamic segments with `_`.
abstract final class DraftBoxKeys {
  static const String boxName = 'drafts_box_v1';

  // Community
  static const String askQatarComposer = 'ask_qatar_composer';
  static const String rumourCheckComposer = 'rumour_check_composer';
  static String askQatarAnswerComposer(String questionId) =>
      'ask_qatar_answer_$questionId';
  static String eventComposer(String groupId) => 'event_composer_$groupId';
  static String lostFoundComposer(String groupId) => 'lost_found_composer_$groupId';
  static String groupPostComposer(String groupSlug) =>
      'group_post_composer_$groupSlug';

  // EOSB
  static const String eosbEmployeeInfo = 'eosb_employee_info';
  static const String overtimeInput = 'overtime_input';
  static String overtimeCalendarEntry(String dateKey) =>
      'overtime_calendar_entry_$dateKey';

  // Quick actions
  static const String billTrackerAdd = 'bill_tracker_add';
  static const String warrantyShieldAdd = 'warranty_shield_add';

  // Listings
  static const String housingPostListing = 'housing_post_listing';
  static const String marketplacePostAd = 'marketplace_post_ad';

  // Services lead capture
  static const String serviceListingPost = 'service_listing_post';

  // Money corridor comparator
  static const String corridorTransferReport = 'corridor_transfer_report';

  // Jobs & businesses
  static const String postJobComposer = 'post_job_composer';
  static const String businessListingAdd = 'business_listing_add';

  // Visa deadline tracker
  static const String deadlineTrackerAdd = 'deadline_tracker_add';

  // EOSB overtime employee profile
  static const String overtimeEmployeeProfile = 'overtime_employee_profile';

  // Health Insurance Truth Engine
  static const String healthInsuranceCompliance = 'health_insurance_compliance';

  // CV Maker — one draft per CV document
  static String cvMaker(String cvId) => 'cv_maker_$cvId';
}
