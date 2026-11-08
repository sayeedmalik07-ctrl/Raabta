/// Settling-in phase bands for the 90-day concierge timeline.
enum ConciergePhase {
  getOriented, // days 1–3
  paperwork, // days 3–7
  moneyBasics, // days 7–14
  dailyLife, // days 14–30
  settlingSpace, // days 30–45
  communityExplore, // days 45–60
  knowYourRights, // days 60–90
}

enum MilestoneStatus {
  pending,
  completed,
  notApplicable,
}

/// Stable milestone ids — only features confirmed live in Step 0 audit.
enum JourneyMilestoneId {
  profileBasics,
  eosbOnboarding,
  languagePreference,
  visaDocuments,
  documentVault,
  moneyBasics,
  billTracker,
  healthInsurance,
  prayerMosque,
  simUssd,
  arabicPhrases,
  drivingLicense,
  housing,
  marketplace,
  community,
  tripPlanner,
  servicesHub,
  eosbRevisit,
  overtimeRevisit,
  exchangeLocator,
}

class JourneyMilestone {
  const JourneyMilestone({
    required this.id,
    required this.phase,
    required this.dayStart,
    required this.dayEnd,
    required this.titleKey,
    required this.descriptionKey,
    required this.actionKey,
    required this.route,
    this.optionalRelevance = false,
    this.autoDetectKey,
  });

  final JourneyMilestoneId id;
  final ConciergePhase phase;
  final int dayStart;
  final int dayEnd;
  final String titleKey;
  final String descriptionKey;
  final String actionKey;
  final String route;
  final bool optionalRelevance;
  final String? autoDetectKey;

  String get idString => id.name;
}

/// Source of truth — only live Raabta routes (no aspirational stubs).
abstract final class JourneyMilestoneCatalog {
  static const all = <JourneyMilestone>[
    JourneyMilestone(
      id: JourneyMilestoneId.profileBasics,
      phase: ConciergePhase.getOriented,
      dayStart: 1,
      dayEnd: 3,
      titleKey: 'concierge_ms_profile_title',
      descriptionKey: 'concierge_ms_profile_desc',
      actionKey: 'concierge_ms_profile_action',
      route: '/profile/personal-info',
      autoDetectKey: 'profile_basics',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.eosbOnboarding,
      phase: ConciergePhase.getOriented,
      dayStart: 1,
      dayEnd: 3,
      titleKey: 'concierge_ms_eosb_title',
      descriptionKey: 'concierge_ms_eosb_desc',
      actionKey: 'concierge_ms_eosb_action',
      route: '/onboarding/welcome',
      autoDetectKey: 'eosb_onboarding',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.languagePreference,
      phase: ConciergePhase.getOriented,
      dayStart: 1,
      dayEnd: 3,
      titleKey: 'concierge_ms_language_title',
      descriptionKey: 'concierge_ms_language_desc',
      actionKey: 'concierge_ms_language_action',
      route: '/profile/language',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.visaDocuments,
      phase: ConciergePhase.paperwork,
      dayStart: 3,
      dayEnd: 7,
      titleKey: 'concierge_ms_visa_title',
      descriptionKey: 'concierge_ms_visa_desc',
      actionKey: 'concierge_ms_visa_action',
      route: '/visa',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.documentVault,
      phase: ConciergePhase.paperwork,
      dayStart: 3,
      dayEnd: 7,
      titleKey: 'concierge_ms_vault_title',
      descriptionKey: 'concierge_ms_vault_desc',
      actionKey: 'concierge_ms_vault_action',
      route: '/scanner/capture',
      autoDetectKey: 'document_vault',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.moneyBasics,
      phase: ConciergePhase.moneyBasics,
      dayStart: 7,
      dayEnd: 14,
      titleKey: 'concierge_ms_money_title',
      descriptionKey: 'concierge_ms_money_desc',
      actionKey: 'concierge_ms_money_action',
      route: '/money',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.billTracker,
      phase: ConciergePhase.moneyBasics,
      dayStart: 7,
      dayEnd: 14,
      titleKey: 'concierge_ms_bills_title',
      descriptionKey: 'concierge_ms_bills_desc',
      actionKey: 'concierge_ms_bills_action',
      route: '/bill-tracker',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.healthInsurance,
      phase: ConciergePhase.moneyBasics,
      dayStart: 7,
      dayEnd: 14,
      titleKey: 'concierge_ms_health_ins_title',
      descriptionKey: 'concierge_ms_health_ins_desc',
      actionKey: 'concierge_ms_health_ins_action',
      route: '/health-insurance/compliance',
      autoDetectKey: 'health_insurance',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.prayerMosque,
      phase: ConciergePhase.dailyLife,
      dayStart: 14,
      dayEnd: 30,
      titleKey: 'concierge_ms_prayer_title',
      descriptionKey: 'concierge_ms_prayer_desc',
      actionKey: 'concierge_ms_prayer_action',
      route: '/prayer-mosque',
      optionalRelevance: true,
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.simUssd,
      phase: ConciergePhase.dailyLife,
      dayStart: 14,
      dayEnd: 30,
      titleKey: 'concierge_ms_ussd_title',
      descriptionKey: 'concierge_ms_ussd_desc',
      actionKey: 'concierge_ms_ussd_action',
      route: '/know-qatar?section=sim_ussd',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.arabicPhrases,
      phase: ConciergePhase.dailyLife,
      dayStart: 14,
      dayEnd: 30,
      titleKey: 'concierge_ms_phrases_title',
      descriptionKey: 'concierge_ms_phrases_desc',
      actionKey: 'concierge_ms_phrases_action',
      route: '/arabic-companion',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.drivingLicense,
      phase: ConciergePhase.dailyLife,
      dayStart: 14,
      dayEnd: 30,
      titleKey: 'concierge_ms_driving_title',
      descriptionKey: 'concierge_ms_driving_desc',
      actionKey: 'concierge_ms_driving_action',
      route: '/know-qatar?section=driving_traffic',
      optionalRelevance: true,
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.housing,
      phase: ConciergePhase.settlingSpace,
      dayStart: 30,
      dayEnd: 45,
      titleKey: 'concierge_ms_housing_title',
      descriptionKey: 'concierge_ms_housing_desc',
      actionKey: 'concierge_ms_housing_action',
      route: '/housing',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.marketplace,
      phase: ConciergePhase.settlingSpace,
      dayStart: 30,
      dayEnd: 45,
      titleKey: 'concierge_ms_market_title',
      descriptionKey: 'concierge_ms_market_desc',
      actionKey: 'concierge_ms_market_action',
      route: '/marketplace',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.community,
      phase: ConciergePhase.communityExplore,
      dayStart: 45,
      dayEnd: 60,
      titleKey: 'concierge_ms_community_title',
      descriptionKey: 'concierge_ms_community_desc',
      actionKey: 'concierge_ms_community_action',
      route: '/community',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.tripPlanner,
      phase: ConciergePhase.communityExplore,
      dayStart: 45,
      dayEnd: 60,
      titleKey: 'concierge_ms_trip_title',
      descriptionKey: 'concierge_ms_trip_desc',
      actionKey: 'concierge_ms_trip_action',
      route: '/trip-planner',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.servicesHub,
      phase: ConciergePhase.communityExplore,
      dayStart: 45,
      dayEnd: 60,
      titleKey: 'concierge_ms_services_title',
      descriptionKey: 'concierge_ms_services_desc',
      actionKey: 'concierge_ms_services_action',
      route: '/services',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.eosbRevisit,
      phase: ConciergePhase.knowYourRights,
      dayStart: 60,
      dayEnd: 90,
      titleKey: 'concierge_ms_eosb_revisit_title',
      descriptionKey: 'concierge_ms_eosb_revisit_desc',
      actionKey: 'concierge_ms_eosb_revisit_action',
      route: '/eosb',
      autoDetectKey: 'eosb_revisit',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.overtimeRevisit,
      phase: ConciergePhase.knowYourRights,
      dayStart: 60,
      dayEnd: 90,
      titleKey: 'concierge_ms_overtime_title',
      descriptionKey: 'concierge_ms_overtime_desc',
      actionKey: 'concierge_ms_overtime_action',
      route: '/eosb/overtime',
    ),
    JourneyMilestone(
      id: JourneyMilestoneId.exchangeLocator,
      phase: ConciergePhase.knowYourRights,
      dayStart: 60,
      dayEnd: 90,
      titleKey: 'concierge_ms_exchange_title',
      descriptionKey: 'concierge_ms_exchange_desc',
      actionKey: 'concierge_ms_exchange_action',
      route: '/money?tab=2',
    ),
  ];

  static JourneyMilestone? byId(JourneyMilestoneId id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }

  static JourneyMilestone? byIdString(String id) {
    for (final m in all) {
      if (m.idString == id) return m;
    }
    return null;
  }
}
