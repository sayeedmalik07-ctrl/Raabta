import 'package:flutter/material.dart';
import 'package:raabta/features/know_qatar/data/know_qatar_catalog.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';

/// Five former standalone guides — ported into Know Qatar (Part C consolidation).
abstract final class KnowQatarConsolidatedCatalog {
  static const sectionKeys = [
    'buying_car',
    'freelance_visa',
    'telecom_contracts',
    'sim_ussd',
    'driving_traffic',
  ];

  static String routeFor(String sectionKey) =>
      KnowQatarScreen.route(sectionKey: sectionKey);

  static final _reviewed = DateTime.parse(KnowQatarCatalog.lastContentReview);

  static final sections = <KnowQatarSection>[
    KnowQatarSection(
      sectionKey: 'buying_car',
      titleKey: 'kq_section_buying_car_title',
      teaserKey: 'kq_section_buying_car_teaser',
      bodyKey: 'kq_section_buying_car_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_moci',
      sourceUrl: 'https://www.moci.gov.qa',
      legalCallouts: const [
        KnowQatarLegalCallout(
          titleKey: 'kq_buying_car_callout_as_is_title',
          bodyKey: 'kq_buying_car_callout_as_is_body',
          severity: KnowQatarCalloutSeverity.critical,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_leaving_qatar_fines',
          route: '/leaving-qatar',
          icon: Icons.traffic_outlined,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_consumer_complaint',
          route: '/consumer-complaint',
          icon: Icons.gavel_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'freelance_visa',
      titleKey: 'kq_section_freelance_visa_title',
      teaserKey: 'kq_section_freelance_visa_teaser',
      bodyKey: 'kq_section_freelance_visa_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_moci',
      sourceUrl: 'https://www.moci.gov.qa',
      legalCallouts: const [
        KnowQatarLegalCallout(
          titleKey: 'kq_freelance_visa_callout_title',
          bodyKey: 'kq_freelance_visa_callout_body',
          severity: KnowQatarCalloutSeverity.warning,
        ),
        KnowQatarLegalCallout(
          titleKey: 'kq_freelance_visa_risk_title',
          bodyKey: 'kq_freelance_visa_risk_body',
          severity: KnowQatarCalloutSeverity.violation,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_sponsorship_transfer',
          route: '/sponsorship-transfer',
          icon: Icons.swap_horiz_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'telecom_contracts',
      titleKey: 'kq_section_telecom_title',
      teaserKey: 'kq_section_telecom_teaser',
      bodyKey: 'kq_section_telecom_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_cra',
      sourceUrl: 'https://www.cra.gov.qa',
      legalCallouts: const [
        KnowQatarLegalCallout(
          titleKey: 'kq_telecom_callout_scope_title',
          bodyKey: 'kq_telecom_callout_scope_body',
          severity: KnowQatarCalloutSeverity.info,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_consumer_complaint',
          route: '/consumer-complaint',
          icon: Icons.support_agent_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'sim_ussd',
      titleKey: 'kq_section_ussd_title',
      teaserKey: 'kq_section_ussd_teaser',
      bodyKey: 'kq_section_ussd_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_telecom_operators',
      sourceUrl: 'https://www.ooredoo.qa',
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_ussd_codes',
          route: '/daily-ussd',
          icon: Icons.sim_card_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'driving_traffic',
      titleKey: 'kq_section_driving_title',
      teaserKey: 'kq_section_driving_teaser',
      bodyKey: 'kq_section_driving_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_moi',
      sourceUrl: 'https://portal.moi.gov.qa',
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_driving_hub',
          route: '/driving',
          icon: Icons.directions_car_outlined,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_visa_deadline',
          route: '/visa',
          icon: Icons.event_note_outlined,
        ),
      ],
    ),
  ];
}
