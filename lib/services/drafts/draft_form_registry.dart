import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draftable_form.dart';

/// Registers every form expected to have draft protection.
/// Called once at app bootstrap — see `DRAFT_PROTECTION.md`.
void registerAllDraftableForms() {
  if (DraftableFormRegistry.catalog.isNotEmpty) return;

  const forms = <DraftableFormDescriptor>[
    // Community
    DraftableFormDescriptor(
      formId: DraftBoxKeys.askQatarComposer,
      label: 'Ask Qatar question composer',
      entryRoute: '/community',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: 'ask_qatar_answer_*',
      label: 'Ask Qatar answer composer',
      entryRoute: '/community',
      isProtected: true,
      isDynamicKey: true,
    ),
    DraftableFormDescriptor(
      formId: 'event_composer_*',
      label: 'Community events composer',
      entryRoute: '/community/events',
      isProtected: true,
      isDynamicKey: true,
    ),
    DraftableFormDescriptor(
      formId: 'lost_found_composer_*',
      label: 'Lost & Found composer',
      entryRoute: '/community',
      isProtected: true,
      isDynamicKey: true,
    ),
    DraftableFormDescriptor(
      formId: 'group_post_composer_*',
      label: 'Group post composer',
      entryRoute: '/community',
      isProtected: true,
      isDynamicKey: true,
    ),

    // EOSB
    DraftableFormDescriptor(
      formId: DraftBoxKeys.eosbEmployeeInfo,
      label: 'EOSB employee information',
      entryRoute: '/eosb/employee-info',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: DraftBoxKeys.overtimeInput,
      label: 'Overtime quick input',
      entryRoute: '/eosb/overtime/input',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: DraftBoxKeys.overtimeEmployeeProfile,
      label: 'Overtime employee profile',
      entryRoute: '/eosb/overtime/employee',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: 'overtime_calendar_entry_*',
      label: 'Overtime calendar day entry',
      entryRoute: '/eosb/overtime/calendar',
      isProtected: true,
      isDynamicKey: true,
    ),

    // Quick actions
    DraftableFormDescriptor(
      formId: DraftBoxKeys.billTrackerAdd,
      label: 'Bill Tracker add bill',
      entryRoute: '/bill-tracker',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: DraftBoxKeys.warrantyShieldAdd,
      label: 'Warranty Shield add item',
      entryRoute: '/warranty-shield',
      isProtected: true,
    ),

    // Listings
    DraftableFormDescriptor(
      formId: DraftBoxKeys.housingPostListing,
      label: 'Housing post listing',
      entryRoute: '/housing',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: DraftBoxKeys.marketplacePostAd,
      label: 'Marketplace post ad',
      entryRoute: '/marketplace',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: DraftBoxKeys.serviceListingPost,
      label: 'Services post listing',
      entryRoute: '/services/post',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: DraftBoxKeys.postJobComposer,
      label: 'Post a job',
      entryRoute: '/jobs',
      isProtected: true,
    ),
    DraftableFormDescriptor(
      formId: DraftBoxKeys.businessListingAdd,
      label: 'Add business listing',
      entryRoute: '/businesses',
      isProtected: true,
    ),

    // Visa
    DraftableFormDescriptor(
      formId: DraftBoxKeys.deadlineTrackerAdd,
      label: 'Deadline Tracker add entry',
      entryRoute: '/visa',
      isProtected: true,
    ),

    // Money
    DraftableFormDescriptor(
      formId: DraftBoxKeys.corridorTransferReport,
      label: 'Corridor transfer report',
      entryRoute: '/money-services/corridor-comparator/submit',
      isProtected: true,
    ),

    // CV Maker
    DraftableFormDescriptor(
      formId: 'cv_maker_*',
      label: 'CV Maker builder',
      entryRoute: '/jobs/cv-builder',
      isProtected: true,
      isDynamicKey: true,
    ),
    DraftableFormDescriptor(
      formId: 'post_engine_*',
      label: 'Post engine flows',
      entryRoute: '/profile/my-activity',
      isDynamicKey: true,
    ),
  ];

  for (final form in forms) {
    DraftableFormRegistry.register(form);
  }
}
