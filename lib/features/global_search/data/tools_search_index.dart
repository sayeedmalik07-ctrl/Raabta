import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/static_search_entry.dart';
import 'package:raabta/features/know_qatar/presentation/screens/know_qatar_screen.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';

/// App-wide tools, quick actions, calculators, and monetization destinations.
abstract final class ToolsSearchIndex {
  static const _quickActionKeys = <String, (String, String)>{
    '/services': ('search_qa_services_title', 'search_qa_services_subtitle'),
    '/scanner/capture': ('search_qa_scanner_title', 'search_qa_scanner_subtitle'),
    '/document-vault': ('search_qa_vault_title', 'search_qa_vault_subtitle'),
    '/barcode-scanner': ('search_qa_barcode_title', 'search_qa_barcode_subtitle'),
    '/arabic-companion': ('search_qa_companion_title', 'search_qa_companion_subtitle'),
    '/bill-splitter': ('search_qa_billsplit_title', 'search_qa_billsplit_subtitle'),
    '/warranty-shield': ('search_qa_warranty_title', 'search_qa_warranty_subtitle'),
    '/scam-shield': ('search_qa_scam_shield_title', 'search_qa_scam_shield_subtitle'),
    '/climate-navigator': ('search_qa_climate_title', 'search_qa_climate_subtitle'),
    '/queue-avoidance': ('search_qa_queue_title', 'search_qa_queue_subtitle'),
    '/bill-tracker': ('search_qa_billtracker_title', 'search_qa_billtracker_subtitle'),
    '/trip-planner': ('search_qa_trip_title', 'search_qa_trip_subtitle'),
    '/prayer-mosque': ('search_qa_prayer_title', 'search_qa_prayer_subtitle'),
    '/eosb': ('search_qa_eosb_hub_title', 'search_qa_eosb_hub_subtitle'),
    '/health-insurance': ('search_qa_health_ins_title', 'search_qa_health_ins_subtitle'),
    '/tenancy': ('search_qa_tenancy_title', 'search_qa_tenancy_subtitle'),
    '/sponsorship-transfer': (
      'search_qa_sponsorship_transfer_title',
      'search_qa_sponsorship_transfer_subtitle',
    ),
    '/daily-ussd': ('search_qa_ussd_title', 'search_qa_ussd_subtitle'),
    '/driving': ('search_qa_driving_title', 'search_qa_driving_subtitle'),
    '/ramadan': ('search_qa_ramadan_title', 'search_qa_ramadan_subtitle'),
  };

  /// Former standalone guides — search resolves to Know Qatar sections.
  static const consolidatedKnowQatarSections = <String, String>{
    '/buying-car-qatar': 'buying_car',
    '/freelance-visa-qatar': 'freelance_visa',
    '/telecom-contract-decoder': 'telecom_contracts',
    '/daily-ussd': 'sim_ussd',
    '/driving': 'driving_traffic',
  };

  static List<StaticSearchEntry> get all {
    final entries = <StaticSearchEntry>[
      for (final tool in QuickActionsHub.tools)
        if (!consolidatedKnowQatarSections.containsKey(tool.route))
          _entryForQuickAction(tool),
      for (final tool in QuickActionsHub.tools)
        if (consolidatedKnowQatarSections.containsKey(tool.route))
          _knowQatarConsolidatedEntry(
            tool,
            consolidatedKnowQatarSections[tool.route]!,
          ),
      // EOSB sub-screens
      const StaticSearchEntry(
        id: 'raabta_ai_chat',
        titleKey: 'search_tool_raabta_ai_title',
        subtitleKey: 'search_tool_raabta_ai_subtitle',
        keywords: [
          'ask ai',
          'raabta ai',
          'chat',
          'assistant',
          'question',
          'help me',
        ],
        routePath: '/ai-chat',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'eosb_dashboard',
        titleKey: 'search_tool_eosb_title',
        subtitleKey: 'search_tool_eosb_subtitle',
        keywords: ['eosb', 'end of service', 'gratuity', 'benefits', 'labour law'],
        routePath: '/eosb',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'eosb_overtime',
        titleKey: 'search_tool_overtime_title',
        subtitleKey: 'search_tool_overtime_subtitle',
        keywords: ['overtime', 'extra hours', 'wage', 'eosb'],
        routePath: '/eosb/overtime',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'health_insurance_truth',
        titleKey: 'search_tool_health_ins_title',
        subtitleKey: 'search_tool_health_ins_subtitle',
        keywords: [
          'health insurance',
          'moph',
          'employer',
          'premium',
          'law 22',
          'coverage',
        ],
        routePath: '/health-insurance',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'tenancy_truth_engine',
        titleKey: 'search_tool_tenancy_title',
        subtitleKey: 'search_tool_tenancy_subtitle',
        keywords: [
          'tenancy',
          'rent',
          'lease',
          'landlord',
          'deposit',
          'dispute',
          'housing rights',
          'law 4',
          'law 8',
        ],
        routePath: '/tenancy',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'tenancy_checklist',
        titleKey: 'search_tool_tenancy_checklist_title',
        subtitleKey: 'search_tool_tenancy_checklist_subtitle',
        keywords: ['tenancy', 'dispute', 'checklist', 'filing', 'documents'],
        routePath: '/tenancy/checklist',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'tenancy_ai_assistant',
        titleKey: 'search_tool_tenancy_ai_title',
        subtitleKey: 'search_tool_tenancy_ai_subtitle',
        keywords: ['tenancy', 'rent', 'lease', 'legal', 'assistant', 'law 4'],
        routePath: '/tenancy/ai-assistant',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'tenancy_dispute_packet',
        titleKey: 'search_tool_tenancy_packet_title',
        subtitleKey: 'search_tool_tenancy_packet_subtitle',
        keywords: ['tenancy', 'dispute', 'pdf', 'packet', 'claim'],
        routePath: '/tenancy/documents',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'sponsorship_transfer_truth',
        titleKey: 'search_tool_sponsorship_transfer_title',
        subtitleKey: 'search_tool_sponsorship_transfer_subtitle',
        keywords: [
          'sponsorship',
          'transfer',
          'iqama',
          'employer change',
          'noc',
          'kafala',
          'job change',
        ],
        routePath: '/sponsorship-transfer',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'sponsorship_transfer_checklist',
        titleKey: 'search_tool_sponsorship_transfer_checklist_title',
        subtitleKey: 'search_tool_sponsorship_transfer_checklist_subtitle',
        keywords: [
          'sponsorship',
          'transfer',
          'checklist',
          'documents',
          'iqama',
        ],
        routePath: '/sponsorship-transfer/checklist',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'sponsorship_transfer_ai',
        titleKey: 'search_tool_sponsorship_transfer_ai_title',
        subtitleKey: 'search_tool_sponsorship_transfer_ai_subtitle',
        keywords: [
          'sponsorship',
          'transfer',
          'noc',
          'notice',
          'law 19',
          'law 18',
        ],
        routePath: '/sponsorship-transfer/ai-assistant',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'civic_report',
        titleKey: 'search_tool_civic_report_title',
        subtitleKey: 'search_tool_civic_report_subtitle',
        keywords: [
          'report',
          'complaint',
          'municipality',
          'oun',
          'ashghal',
          'kahramaa',
          'neighbourhood',
          'community problem',
          'street',
          'drainage',
        ],
        routePath: '/civic-report',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'ramadan_hub',
        titleKey: 'search_tool_ramadan_title',
        subtitleKey: 'search_tool_ramadan_subtitle',
        keywords: ['ramadan', 'iftar', 'zakat', 'qibla', 'fasting'],
        routePath: '/ramadan',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'zakat_calculator',
        titleKey: 'search_tool_zakat_title',
        subtitleKey: 'search_tool_zakat_subtitle',
        keywords: ['zakat', 'charity', 'gold', 'nisab', 'ramadan'],
        routePath: '/ramadan/zakat',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'driving_hub',
        titleKey: 'search_tool_driving_hub_title',
        subtitleKey: 'search_tool_driving_hub_subtitle',
        keywords: ['driving', 'license', 'fine', 'theory', 'qatar', 'traffic'],
        routePath: '/driving',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'driving_calculator',
        titleKey: 'search_tool_driving_calc_title',
        subtitleKey: 'search_tool_driving_calc_subtitle',
        keywords: ['driving fee', 'license cost', 'calculator'],
        routePath: '/driving/calculator',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'cv_maker',
        titleKey: 'search_tool_cv_title',
        subtitleKey: 'search_tool_cv_subtitle',
        keywords: ['cv', 'resume', 'curriculum vitae', 'jobs', 'apply'],
        routePath: '/jobs/cv-start',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'premium_subscription',
        titleKey: 'search_tool_premium_title',
        subtitleKey: 'search_tool_premium_subtitle',
        keywords: ['premium', 'subscription', 'pro', 'upgrade'],
        routePath: '/premium',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'boost_listing',
        titleKey: 'search_tool_boost_title',
        subtitleKey: 'search_tool_boost_subtitle',
        keywords: ['boost', 'promote', 'featured', 'listing'],
        routePath: '/boost-listing',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'business_advertise',
        titleKey: 'search_tool_advertise_title',
        subtitleKey: 'search_tool_advertise_subtitle',
        keywords: ['advertise', 'business', 'promotion', 'marketing'],
        routePath: '/business-advertise',
        category: GlobalSearchCategory.tools,
      ),
      const StaticSearchEntry(
        id: 'expense_splitter',
        titleKey: 'search_tool_expense_split_title',
        subtitleKey: 'search_tool_expense_split_subtitle',
        keywords: ['expense', 'split', 'bill splitter', 'share cost'],
        routePath: '/bill-splitter',
        category: GlobalSearchCategory.tools,
      ),
    ];
    if (!MonetizationState.showPremiumTierUi) {
      return entries
          .where(
            (e) => !MonetizationState.isPremiumTierRoute(e.routePath),
          )
          .toList();
    }
    return entries;
  }

  static StaticSearchEntry _knowQatarConsolidatedEntry(
    QuickActionTool tool,
    String sectionKey,
  ) {
    return StaticSearchEntry(
      id: 'know_qatar_$sectionKey',
      title: QuickActionsStrings.t(tool.titleKey, 'English'),
      subtitle: QuickActionsStrings.t(tool.descriptionKey, 'English'),
      keywords: [
        QuickActionsStrings.t(tool.titleKey, 'English'),
        QuickActionsStrings.t(tool.shortLabelKey, 'English'),
        'know qatar',
        sectionKey.replaceAll('_', ' '),
      ],
      routePath: KnowQatarScreen.route(sectionKey: sectionKey),
      category: GlobalSearchCategory.tools,
    );
  }

  static StaticSearchEntry _entryForQuickAction(QuickActionTool tool) {
    final keys = _quickActionKeys[tool.route];
    return StaticSearchEntry(
      id: 'tool_${tool.route.replaceAll('/', '')}',
      titleKey: keys?.$1,
      subtitleKey: keys?.$2,
      title: keys == null
          ? QuickActionsStrings.t(tool.titleKey, 'English')
          : null,
      subtitle: keys == null
          ? QuickActionsStrings.t(tool.descriptionKey, 'English')
          : null,
      keywords: [
        QuickActionsStrings.t(tool.titleKey, 'English'),
        QuickActionsStrings.t(tool.shortLabelKey, 'English'),
        QuickActionsStrings.t(tool.descriptionKey, 'English'),
        tool.route,
      ],
      routePath: tool.route,
      category: GlobalSearchCategory.tools,
    );
  }
}
