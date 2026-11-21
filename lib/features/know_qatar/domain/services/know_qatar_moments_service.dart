import 'package:raabta/features/know_qatar/data/know_qatar_catalog.dart';
import 'package:raabta/features/know_qatar/data/know_qatar_hosting_official_links_config.dart';
import 'package:raabta/features/know_qatar/data/know_qatar_moments_config.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_moment_models.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';

abstract final class KnowQatarMomentsService {
  static KnowQatarMomentId defaultMomentForPersona(KnowQatarPersona persona) {
    switch (persona) {
      case KnowQatarPersona.visitor:
        return KnowQatarMomentId.visitingQatar;
      case KnowQatarPersona.newResident:
        return KnowQatarMomentId.justArrived;
      case KnowQatarPersona.workingResident:
        return KnowQatarMomentId.startingChangingJob;
      case KnowQatarPersona.family:
        return KnowQatarMomentId.bringingFamily;
    }
  }

  static List<KnowQatarMomentId> chipOrder(KnowQatarMomentId selectedDefault) {
    const lifecycle = [
      KnowQatarMomentId.justArrived,
      KnowQatarMomentId.startingChangingJob,
      KnowQatarMomentId.bringingFamily,
      KnowQatarMomentId.hostingVisitors,
      KnowQatarMomentId.settingUpHome,
      KnowQatarMomentId.visitingQatar,
      KnowQatarMomentId.goingHome,
      KnowQatarMomentId.whenSomethingGoesWrong,
      KnowQatarMomentId.allTopics,
    ];
    if (selectedDefault == KnowQatarMomentId.allTopics) {
      return lifecycle;
    }
    return [
      selectedDefault,
      ...lifecycle.where((id) => id != selectedDefault),
    ];
  }

  static List<KnowQatarMomentResolvedItem> resolveMomentItems({
    required KnowQatarMomentId momentId,
    required Set<String> publishedSectionKeys,
  }) {
    final def = KnowQatarMomentsConfig.definitionFor(momentId);
    if (def == null) return const [];

    final out = <KnowQatarMomentResolvedItem>[];
    for (final ref in def.items) {
      final resolved = _resolveRef(ref, publishedSectionKeys);
      if (resolved != null) out.add(resolved);
    }
    return out;
  }

  static KnowQatarMomentResolvedItem? resolveDestination({
    required String destinationKey,
    required Set<String> publishedSectionKeys,
  }) {
    if (destinationKey.startsWith('section:')) {
      final key = destinationKey.substring('section:'.length);
      if (!publishedSectionKeys.contains(key)) return null;
      final section = KnowQatarCatalog.sectionByKey(key);
      if (section == null) return null;
      return KnowQatarMomentResolvedItem(
        destinationKey: destinationKey,
        isSection: true,
        route: KnowQatarScreen.route(sectionKey: key),
        titleKey: section.titleKey,
        summaryKey: section.teaserKey,
      );
    }
    if (destinationKey.startsWith('route:')) {
      final route = destinationKey.substring('route:'.length);
      if (!KnowQatarMomentsConfig.registeredRoutes.contains(route)) {
        return null;
      }
      final meta = _routeLabelKeys[route];
      if (meta == null) return null;
      return KnowQatarMomentResolvedItem(
        destinationKey: destinationKey,
        isSection: false,
        route: route,
        titleKey: meta.$1,
        summaryKey: meta.$2,
      );
    }
    if (destinationKey.startsWith('external:')) {
      final linkId = destinationKey.substring('external:'.length);
      return _resolveExternalLink(linkId);
    }
    return null;
  }

  static KnowQatarMomentResolvedItem? _resolveExternalLink(String linkId) {
    final url = KnowQatarHostingOfficialLinksConfig.urlForLinkId(linkId);
    if (url == null || url.isEmpty) return null;
    return KnowQatarMomentResolvedItem(
      destinationKey: 'external:$linkId',
      isSection: false,
      route: '',
      titleKey: KnowQatarHostingOfficialLinksConfig.titleKeyForLinkId(linkId),
      summaryKey:
          KnowQatarHostingOfficialLinksConfig.summaryKeyForLinkId(linkId),
      isExternal: true,
      externalUrl: url,
      trustSourceNameKey:
          KnowQatarHostingOfficialLinksConfig.sourceNameKeyForLinkId(linkId),
      urlVerifiedIso:
          KnowQatarHostingOfficialLinksConfig.urlVerifiedIsoForLinkId(linkId),
    );
  }

  static KnowQatarMomentResolvedItem? _resolveRef(
    KnowQatarMomentItemRef ref,
    Set<String> publishedSectionKeys,
  ) {
    switch (ref.kind) {
      case KnowQatarMomentItemKind.section:
        final key = ref.sectionKey!;
        return resolveDestination(
          destinationKey: 'section:$key',
          publishedSectionKeys: publishedSectionKeys,
        );
      case KnowQatarMomentItemKind.route:
        final route = ref.route!;
        final base = resolveDestination(
          destinationKey: 'route:$route',
          publishedSectionKeys: publishedSectionKeys,
        );
        if (base == null) return null;
        final titleKey = ref.titleKeyOverride ?? base.titleKey;
        final summaryKey = ref.summaryKeyOverride ?? base.summaryKey;
        if (titleKey == base.titleKey && summaryKey == base.summaryKey) {
          return base;
        }
        return KnowQatarMomentResolvedItem(
          destinationKey: base.destinationKey,
          isSection: base.isSection,
          route: base.route,
          titleKey: titleKey,
          summaryKey: summaryKey,
        );
      case KnowQatarMomentItemKind.external:
        return _resolveExternalLink(ref.externalLinkId!);
    }
  }

  static String destinationKeyForRoute(String route) => 'route:$route';

  static String destinationKeyForSection(String sectionKey) =>
      'section:$sectionKey';

  static const _routeLabelKeys = <String, (String titleKey, String summaryKey)>{
    '/visa': ('kq_route_visa_title', 'kq_route_visa_summary'),
    '/eosb/employee-info': (
      'kq_route_before_you_sign_title',
      'kq_route_before_you_sign_summary',
    ),
    '/employer-track-record/check': (
      'kq_route_employer_track_title',
      'kq_route_employer_track_summary',
    ),
    '/agency-verification/check': (
      'kq_route_agency_verify_title',
      'kq_route_agency_verify_summary',
    ),
    '/sponsorship-transfer': (
      'kq_action_sponsorship_transfer',
      'kq_route_sponsorship_transfer_summary',
    ),
    '/eosb': ('kq_route_eosb_title', 'kq_route_eosb_summary'),
    '/visa/guide/family_visa': (
      'kq_route_family_visa_guide_title',
      'kq_route_family_visa_guide_summary',
    ),
    '/health-insurance': (
      'kq_route_health_insurance_title',
      'kq_route_health_insurance_summary',
    ),
    '/tenancy': ('kq_route_tenancy_title', 'kq_route_tenancy_summary'),
    '/telecom-contract-decoder': (
      'kq_section_telecom_title',
      'kq_section_telecom_teaser',
    ),
    '/money': ('kq_action_money_hub', 'kq_route_money_summary'),
    '/bill-tracker': ('kq_route_bill_tracker_title', 'kq_route_bill_tracker_summary'),
    '/daily-phrases': (
      'kq_route_daily_phrases_title',
      'kq_route_daily_phrases_summary',
    ),
    '/daily-ussd': ('kq_action_ussd_codes', 'kq_section_ussd_teaser'),
    '/leaving-qatar': (
      'kq_route_leaving_qatar_title',
      'kq_route_leaving_qatar_summary',
    ),
    '/concierge-90-day': (
      'kq_route_concierge_title',
      'kq_route_concierge_summary',
    ),
    '/trip-planner': (
      'kq_route_trip_planner_title',
      'kq_route_trip_planner_summary',
    ),
    '/prayer-mosque': (
      'kq_route_prayer_mosque_title',
      'kq_route_prayer_mosque_summary',
    ),
    '/welcome-home': (
      'kq_route_welcome_home_title',
      'kq_route_welcome_home_summary',
    ),
    '/disruption-readiness/know': (
      'kq_action_disruption_guide',
      'kq_route_disruption_summary',
    ),
    '/scam-shield': (
      'kq_route_scam_shield_title',
      'kq_route_scam_shield_summary',
    ),
    '/consumer-complaint': (
      'kq_action_consumer_complaint',
      'kq_route_consumer_complaint_summary',
    ),
    '/driving': ('kq_action_driving_hub', 'kq_section_driving_teaser'),
  };
}
