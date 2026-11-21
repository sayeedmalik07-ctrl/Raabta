import 'package:flutter/material.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_official_links.dart';
import 'package:raabta/features/disruption_readiness/presentation/screens/disruption_understand_alert_screen.dart';
import 'package:raabta/features/know_qatar/data/know_qatar_consolidated_catalog.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';

/// Static bundled Know Qatar content — update here without runtime AI.
abstract final class KnowQatarCatalog {
  static const lastContentReview = '2026-08-01';

  static const defaultSectionOrder = [
    'qatar_at_glance',
    'history',
    'leadership_government',
    'economy',
    'cities_regions',
    'culture_society',
    'work_in_qatar',
    'living_in_qatar',
    'money_cost_of_living',
    'residency_documents',
    'communities',
    'alerts_safety',
    ...KnowQatarConsolidatedCatalog.sectionKeys,
  ];

  static final _reviewed = DateTime.parse(lastContentReview);

  static final sections = <KnowQatarSection>[
    KnowQatarSection(
      sectionKey: 'qatar_at_glance',
      titleKey: 'kq_section_qatar_at_glance_title',
      teaserKey: 'kq_section_qatar_at_glance_teaser',
      bodyKey: 'kq_section_qatar_at_glance_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_hukoomi',
      sourceUrl: 'https://www.hukoomi.gov.qa',
      aiPromptKey: 'kq_ai_prompt_qatar_at_glance',
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_money_hub',
          route: '/money',
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'history',
      titleKey: 'kq_section_history_title',
      teaserKey: 'kq_section_history_teaser',
      bodyKey: 'kq_section_history_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_hukoomi',
      sourceUrl: 'https://www.hukoomi.gov.qa',
      aiPromptKey: 'kq_ai_prompt_history',
      timelineMilestones: [
        KnowQatarTimelineMilestone(
          yearKey: 'kq_history_year_4000bce',
          titleKey: 'kq_history_milestone_pearl_title',
          subtitleKey: 'kq_history_milestone_pearl_sub',
          icon: Icons.water_outlined,
          colorValue: 0xFF4FC3F7,
        ),
        KnowQatarTimelineMilestone(
          yearKey: 'kq_history_year_1766',
          titleKey: 'kq_history_milestone_al_zubarah_title',
          subtitleKey: 'kq_history_milestone_al_zubarah_sub',
          icon: Icons.account_balance_outlined,
          colorValue: 0xFF81C784,
        ),
        KnowQatarTimelineMilestone(
          yearKey: 'kq_history_year_1971',
          titleKey: 'kq_history_milestone_independence_title',
          subtitleKey: 'kq_history_milestone_independence_sub',
          icon: Icons.flag_outlined,
          colorValue: 0xFF9575CD,
        ),
        KnowQatarTimelineMilestone(
          yearKey: 'kq_history_year_1995',
          titleKey: 'kq_history_milestone_modern_title',
          subtitleKey: 'kq_history_milestone_modern_sub',
          icon: Icons.apartment_outlined,
          colorValue: 0xFFFFB74D,
        ),
        KnowQatarTimelineMilestone(
          yearKey: 'kq_history_year_2022',
          titleKey: 'kq_history_milestone_world_cup_title',
          subtitleKey: 'kq_history_milestone_world_cup_sub',
          icon: Icons.sports_soccer_outlined,
          colorValue: 0xFF4DD0E1,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'leadership_government',
      titleKey: 'kq_section_leadership_title',
      teaserKey: 'kq_section_leadership_teaser',
      bodyKey: 'kq_section_leadership_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_hukoomi',
      sourceUrl: 'https://www.hukoomi.gov.qa',
      aiPromptKey: 'kq_ai_prompt_leadership',
      progressMilestones: [
        KnowQatarProgressMilestone(
          labelKey: 'kq_gov_milestone_vision2030',
          progress: 0.72,
          colorValue: 0xFF4DD0E1,
        ),
        KnowQatarProgressMilestone(
          labelKey: 'kq_gov_milestone_digital',
          progress: 0.85,
          colorValue: 0xFF9575CD,
        ),
        KnowQatarProgressMilestone(
          labelKey: 'kq_gov_milestone_labour_reform',
          progress: 0.68,
          colorValue: 0xFF81C784,
        ),
      ],
      legalCallouts: [
        KnowQatarLegalCallout(
          titleKey: 'kq_leadership_callout_law_title',
          bodyKey: 'kq_leadership_callout_law_body',
          severity: KnowQatarCalloutSeverity.info,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_visa_documents',
          route: '/visa',
          icon: Icons.badge_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'economy',
      titleKey: 'kq_section_economy_title',
      teaserKey: 'kq_section_economy_teaser',
      bodyKey: 'kq_section_economy_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_qnv2030',
      sourceUrl: 'https://www.gco.gov.qa/en/state-of-qatar/qatar-national-vision-2030/',
      aiPromptKey: 'kq_ai_prompt_economy',
      progressMilestones: [
        KnowQatarProgressMilestone(
          labelKey: 'kq_economy_milestone_non_hydrocarbon',
          progress: 0.63,
          colorValue: 0xFF4DD0E1,
        ),
        KnowQatarProgressMilestone(
          labelKey: 'kq_economy_milestone_tourism',
          progress: 0.58,
          colorValue: 0xFF9575CD,
        ),
        KnowQatarProgressMilestone(
          labelKey: 'kq_economy_milestone_sme',
          progress: 0.45,
          colorValue: 0xFF66BB6A,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_money_hub',
          route: '/money',
          icon: Icons.trending_up_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'cities_regions',
      titleKey: 'kq_section_cities_title',
      teaserKey: 'kq_section_cities_teaser',
      bodyKey: 'kq_section_cities_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_hukoomi',
      sourceUrl: 'https://www.hukoomi.gov.qa',
      aiPromptKey: 'kq_ai_prompt_cities',
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_trip_planner',
          route: '/trip-planner',
          icon: Icons.map_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'culture_society',
      titleKey: 'kq_section_culture_title',
      teaserKey: 'kq_section_culture_teaser',
      bodyKey: 'kq_section_culture_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_moci',
      sourceUrl: 'https://www.moci.gov.qa',
      aiPromptKey: 'kq_ai_prompt_culture',
      showCultureChips: true,
      legalCallouts: [
        KnowQatarLegalCallout(
          titleKey: 'kq_culture_callout_dress_title',
          bodyKey: 'kq_culture_callout_dress_body',
          severity: KnowQatarCalloutSeverity.warning,
        ),
        KnowQatarLegalCallout(
          titleKey: 'kq_culture_callout_ramadan_title',
          bodyKey: 'kq_culture_callout_ramadan_body',
          severity: KnowQatarCalloutSeverity.info,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_arabic_tools',
          route: '/arabic-companion',
          icon: Icons.translate_rounded,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_mosque_prayer',
          route: '/prayer-mosque',
          icon: Icons.mosque_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'work_in_qatar',
      titleKey: 'kq_section_work_title',
      teaserKey: 'kq_section_work_teaser',
      bodyKey: 'kq_section_work_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_adlsa',
      sourceUrl: 'https://www.adlsa.gov.qa',
      aiPromptKey: 'kq_ai_prompt_work',
      legalCallouts: [
        KnowQatarLegalCallout(
          titleKey: 'kq_work_callout_wps_title',
          bodyKey: 'kq_work_callout_wps_body',
          severity: KnowQatarCalloutSeverity.violation,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_eosb',
          route: '/eosb',
          icon: Icons.calculate_outlined,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_sponsorship_transfer',
          route: '/sponsorship-transfer',
          icon: Icons.swap_horiz_outlined,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_jobs',
          route: '/jobs',
          icon: Icons.work_outline,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'living_in_qatar',
      titleKey: 'kq_section_living_title',
      teaserKey: 'kq_section_living_teaser',
      bodyKey: 'kq_section_living_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_moci',
      sourceUrl: 'https://www.moci.gov.qa',
      aiPromptKey: 'kq_ai_prompt_living',
      legalCallouts: [
        KnowQatarLegalCallout(
          titleKey: 'kq_living_callout_tenancy_title',
          bodyKey: 'kq_living_callout_tenancy_body',
          severity: KnowQatarCalloutSeverity.warning,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_tenancy',
          route: '/tenancy',
          icon: Icons.home_work_outlined,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_housing',
          route: '/housing',
          icon: Icons.apartment_outlined,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_civic_report',
          route: '/civic-report',
          icon: Icons.report_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'money_cost_of_living',
      titleKey: 'kq_section_money_title',
      teaserKey: 'kq_section_money_teaser',
      bodyKey: 'kq_section_money_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_qcb',
      sourceUrl: 'https://www.qcb.gov.qa',
      aiPromptKey: 'kq_ai_prompt_money',
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_cost_of_living',
          route: '/money-services/cost-of-living',
          icon: Icons.savings_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'residency_documents',
      titleKey: 'kq_section_residency_title',
      teaserKey: 'kq_section_residency_teaser',
      bodyKey: 'kq_section_residency_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_moi',
      sourceUrl: 'https://portal.moi.gov.qa',
      aiPromptKey: 'kq_ai_prompt_residency',
      showNationalityHighlight: true,
      legalCallouts: [
        KnowQatarLegalCallout(
          titleKey: 'kq_residency_callout_id_title',
          bodyKey: 'kq_residency_callout_id_body',
          severity: KnowQatarCalloutSeverity.critical,
        ),
      ],
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_visa_deadline',
          route: '/visa',
          icon: Icons.event_note_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'communities',
      titleKey: 'kq_section_communities_title',
      teaserKey: 'kq_section_communities_teaser',
      bodyKey: 'kq_section_communities_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_hukoomi',
      sourceUrl: 'https://www.hukoomi.gov.qa',
      aiPromptKey: 'kq_ai_prompt_communities',
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_community',
          route: '/community',
          icon: Icons.groups_outlined,
        ),
      ],
    ),
    KnowQatarSection(
      sectionKey: 'alerts_safety',
      titleKey: 'kq_section_alerts_safety_title',
      teaserKey: 'kq_section_alerts_safety_teaser',
      bodyKey: 'kq_section_alerts_safety_body',
      lastReviewed: _reviewed,
      sourceLabelKey: 'kq_source_moi',
      sourceUrl: DisruptionOfficialLinks.moiPortal,
      publicationStatus: KnowQatarSectionPublicationStatus.draft,
      actionLinks: [
        KnowQatarActionLink(
          labelKey: 'kq_action_disruption_guide',
          route: '/disruption-readiness/know',
          icon: Icons.shield_outlined,
        ),
        KnowQatarActionLink(
          labelKey: 'kq_action_understand_alert',
          route: DisruptionUnderstandAlertScreen.route,
          icon: Icons.sms_outlined,
        ),
      ],
    ),
    ...KnowQatarConsolidatedCatalog.sections,
  ];

  static KnowQatarSection? sectionByKey(String key) {
    for (final section in sections) {
      if (section.sectionKey == key) return section;
    }
    return null;
  }

  static List<KnowQatarSection> ordered(List<String> keys) {
    final byKey = {for (final s in sections) s.sectionKey: s};
    return keys.map((k) => byKey[k]).whereType<KnowQatarSection>().toList();
  }

  static List<KnowQatarSection> visibleOrdered(List<String> keys) {
    return ordered(keys).where((s) => s.isPublished).toList(growable: false);
  }

  static int get publishedSectionCount =>
      sections.where((s) => s.isPublished).length;
}
