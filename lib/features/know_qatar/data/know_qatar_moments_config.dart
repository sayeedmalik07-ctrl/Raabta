import 'package:raabta/features/know_qatar/data/know_qatar_hosting_official_links_config.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_moment_models.dart';

/// Static Moments registry — maps life lenses onto existing sections and routes.
abstract final class KnowQatarMomentsConfig {
  static const allTopicsId = KnowQatarMomentId.allTopics;

  /// Routes allowed in moment items and Next Step (registered in [app_router.dart]).
  static const registeredRoutes = <String>{
    '/visa',
    '/money',
    '/jobs',
    '/eosb',
    '/eosb/employee-info',
    '/eosb/result',
    '/tenancy',
    '/sponsorship-transfer',
    '/health-insurance',
    '/agency-verification/check',
    '/employer-track-record/check',
    '/scam-shield',
    '/leaving-qatar',
    '/welcome-home',
    '/consumer-complaint',
    '/trip-planner',
    '/prayer-mosque',
    '/daily-ussd',
    '/daily-phrases',
    '/driving',
    '/concierge-90-day',
    '/bill-tracker',
    '/telecom-contract-decoder',
    '/visa/guide/family_visa',
    '/visa/guide/sponsor_transfer',
    '/disruption-readiness/know',
  };

  static const moments = <KnowQatarMomentDefinition>[
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.justArrived,
      titleKey: 'kq_moment_just_arrived_title',
      introKey: 'kq_moment_just_arrived_intro',
      items: [
        KnowQatarMomentItemRef.section('qatar_at_glance'),
        KnowQatarMomentItemRef.section('residency_documents'),
        KnowQatarMomentItemRef.section('living_in_qatar'),
        KnowQatarMomentItemRef.route('/visa'),
        KnowQatarMomentItemRef.section('sim_ussd'),
        KnowQatarMomentItemRef.route('/daily-phrases'),
        KnowQatarMomentItemRef.route('/leaving-qatar'),
        KnowQatarMomentItemRef.route('/concierge-90-day'),
      ],
    ),
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.startingChangingJob,
      titleKey: 'kq_moment_starting_job_title',
      introKey: 'kq_moment_starting_job_intro',
      items: [
        KnowQatarMomentItemRef.section('work_in_qatar'),
        KnowQatarMomentItemRef.section('residency_documents'),
        KnowQatarMomentItemRef.route('/eosb/employee-info'),
        KnowQatarMomentItemRef.route('/employer-track-record/check'),
        KnowQatarMomentItemRef.route('/agency-verification/check'),
        KnowQatarMomentItemRef.route('/sponsorship-transfer'),
        KnowQatarMomentItemRef.route('/eosb'),
      ],
    ),
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.bringingFamily,
      titleKey: 'kq_moment_bringing_family_title',
      introKey: 'kq_moment_bringing_family_intro',
      items: [
        KnowQatarMomentItemRef.section('residency_documents'),
        KnowQatarMomentItemRef.section('living_in_qatar'),
        KnowQatarMomentItemRef.section('cities_regions'),
        KnowQatarMomentItemRef.section('communities'),
        KnowQatarMomentItemRef.route('/visa/guide/family_visa'),
        KnowQatarMomentItemRef.route('/health-insurance'),
        KnowQatarMomentItemRef.route('/tenancy'),
      ],
    ),
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.hostingVisitors,
      titleKey: 'kq_moment_hosting_visitors_title',
      introKey: 'kq_moment_hosting_visitors_intro',
      items: [
        KnowQatarMomentItemRef.external(
          KnowQatarHostingOfficialLinksConfig.linkMoiFamilyVisit,
        ),
        KnowQatarMomentItemRef.external(
          KnowQatarHostingOfficialLinksConfig.linkMoiPolicy2023,
        ),
        KnowQatarMomentItemRef.external(
          KnowQatarHostingOfficialLinksConfig.linkMophQhisVisitor,
        ),
        KnowQatarMomentItemRef.route(
          '/visa',
          summaryKeyOverride: 'kq_hosting_route_visa_summary',
        ),
        KnowQatarMomentItemRef.route(
          '/health-insurance',
          summaryKeyOverride: 'kq_hosting_route_health_insurance_summary',
        ),
      ],
    ),
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.settingUpHome,
      titleKey: 'kq_moment_setting_up_home_title',
      introKey: 'kq_moment_setting_up_home_intro',
      items: [
        KnowQatarMomentItemRef.section('living_in_qatar'),
        KnowQatarMomentItemRef.section('money_cost_of_living'),
        KnowQatarMomentItemRef.section('cities_regions'),
        KnowQatarMomentItemRef.route('/tenancy'),
        KnowQatarMomentItemRef.route('/telecom-contract-decoder'),
        KnowQatarMomentItemRef.section('buying_car'),
        KnowQatarMomentItemRef.section('driving_traffic'),
        KnowQatarMomentItemRef.route('/money'),
        KnowQatarMomentItemRef.route('/bill-tracker'),
      ],
    ),
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.visitingQatar,
      titleKey: 'kq_moment_visiting_title',
      introKey: 'kq_moment_visiting_intro',
      items: [
        KnowQatarMomentItemRef.section('qatar_at_glance'),
        KnowQatarMomentItemRef.section('culture_society'),
        KnowQatarMomentItemRef.section('cities_regions'),
        KnowQatarMomentItemRef.route('/trip-planner'),
        KnowQatarMomentItemRef.route('/prayer-mosque'),
        KnowQatarMomentItemRef.route('/daily-phrases'),
        KnowQatarMomentItemRef.route('/disruption-readiness/know'),
      ],
    ),
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.goingHome,
      titleKey: 'kq_moment_going_home_title',
      introKey: 'kq_moment_going_home_intro',
      items: [
        KnowQatarMomentItemRef.route('/leaving-qatar'),
        KnowQatarMomentItemRef.route('/welcome-home'),
        KnowQatarMomentItemRef.route('/eosb'),
      ],
    ),
    KnowQatarMomentDefinition(
      id: KnowQatarMomentId.whenSomethingGoesWrong,
      titleKey: 'kq_moment_something_wrong_title',
      introKey: 'kq_moment_something_wrong_intro',
      items: [
        KnowQatarMomentItemRef.route('/disruption-readiness/know'),
        KnowQatarMomentItemRef.route('/scam-shield'),
        KnowQatarMomentItemRef.route('/eosb'),
        KnowQatarMomentItemRef.route('/consumer-complaint'),
        KnowQatarMomentItemRef.route('/employer-track-record/check'),
      ],
    ),
  ];

  static KnowQatarMomentDefinition? definitionFor(KnowQatarMomentId id) {
    if (id == KnowQatarMomentId.allTopics) return null;
    for (final m in moments) {
      if (m.id == id) return m;
    }
    return null;
  }
}
