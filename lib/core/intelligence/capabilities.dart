/// A navigable Raabta tool surfaced to the Central Brain and home intelligence.
class Capability {
  const Capability({
    required this.id,
    required this.name,
    required this.description,
    required this.route,
    required this.isReadOnly,
  });

  final String id;
  final String name;
  final String description;

  /// Primary GoRouter path for this tool (verified in [app_router.dart]).
  final String route;

  /// `true` = browse/read-only; `false` = user can enter data or trigger an action.
  final bool isReadOnly;
}

/// Hand-written inventory of Raabta tools — static config, not Firestore.
///
/// Routes cross-checked against `lib/core/router/app_router.dart` (2026-06-19).
/// Mirrors Phase 0 audit tool inventory + [RaabtaCapabilitiesReference].
const List<Capability> raabtaCapabilities = [
  // ── Quick Actions / Daily tools ──────────────────────────────────────────
  Capability(
    id: 'scanner',
    name: 'PDF Studio & Doc Scanner',
    description:
        'Scan documents with OCR, merge or split PDFs, and export polished files.',
    route: '/scanner/capture',
    isReadOnly: false,
  ),
  Capability(
    id: 'document_vault',
    name: 'Document Vault',
    description:
        'Store scanned IDs, visas, and contracts; browse expiry dates and open details.',
    route: '/document-vault',
    isReadOnly: false,
  ),
  Capability(
    id: 'barcode_scanner',
    name: 'Food Inspector',
    description:
        'Scan product barcodes for halal status, E-numbers, and allergy warnings.',
    route: '/barcode-scanner',
    isReadOnly: false,
  ),
  Capability(
    id: 'arabic_companion',
    name: 'Arabic Companion',
    description:
        'Offline Qatar Arabic phrasebook plus live AI translation for taxis, delivery, and directions.',
    route: '/arabic-companion',
    isReadOnly: true,
  ),
  Capability(
    id: 'bill_splitter',
    name: 'Bill Splitter',
    description: 'Split restaurant or group bills fairly across people and currencies.',
    route: '/bill-splitter',
    isReadOnly: false,
  ),
  Capability(
    id: 'warranty_shield',
    name: 'Warranty Shield',
    description: 'Track product warranties, receipts, and expiry reminder dates.',
    route: '/warranty-shield',
    isReadOnly: false,
  ),
  Capability(
    id: 'climate_navigator',
    name: 'Climate Navigator',
    description: 'Plan shaded or indoor walking routes to beat Qatar heat.',
    route: '/climate-navigator',
    isReadOnly: true,
  ),
  Capability(
    id: 'queue_avoidance',
    name: 'Queue Avoidance',
    description: 'See crowd-reported wait times at government and service locations.',
    route: '/queue-avoidance',
    isReadOnly: true,
  ),
  Capability(
    id: 'bill_tracker',
    name: 'Bill Tracker',
    description: 'Track Kahramaa, Ooredoo, Vodafone and other utility bill due dates.',
    route: '/bill-tracker',
    isReadOnly: false,
  ),
  Capability(
    id: 'scam_shield',
    name: 'Scam Shield',
    description:
        'Check suspicious messages, links, and phone patterns before you respond.',
    route: '/scam-shield',
    isReadOnly: false,
  ),
  Capability(
    id: 'consumer_complaint',
    name: 'MOCI Consumer Complaint',
    description:
        'Reference for filing general product and service complaints with MOCI under Law No. 8 of 2008.',
    route: '/consumer-complaint',
    isReadOnly: true,
  ),

  // ── Labour & rights truth engines ────────────────────────────────────────
  Capability(
    id: 'eosb',
    name: 'EOSB Truth Engine',
    description:
        'Calculate end-of-service gratuity, leave, notice, and ticket entitlements under Qatar labour law.',
    route: '/eosb',
    isReadOnly: false,
  ),
  Capability(
    id: 'eosb_overtime',
    name: 'Overtime Truth Engine',
    description:
        'Verify overtime pay against Qatar rules; calendar import, summary, and AI review.',
    route: '/eosb/overtime',
    isReadOnly: false,
  ),
  Capability(
    id: 'health_insurance',
    name: 'Health Insurance Truth Engine',
    description:
        'Check employer health insurance compliance and explain policy documents (Law 22/2021).',
    route: '/health-insurance',
    isReadOnly: false,
  ),
  Capability(
    id: 'tenancy',
    name: 'Housing & Tenancy Truth Engine',
    description:
        'Enter lease terms, run compliance checks, dispute checklists, and document packets.',
    route: '/tenancy',
    isReadOnly: false,
  ),
  Capability(
    id: 'sponsorship_transfer',
    name: 'Sponsorship Transfer Truth Engine',
    description:
        'Assess iqama transfer readiness, notice periods, and Law 19/2020 checklist steps.',
    route: '/sponsorship-transfer',
    isReadOnly: false,
  ),
  Capability(
    id: 'employer_track_record',
    name: 'Employer Track Record',
    description:
        'Look up employer compliance signals and run a pre-offer safety checklist before accepting a job.',
    route: '/employer-track-record/check',
    isReadOnly: false,
  ),
  Capability(
    id: 'agency_verification',
    name: 'Agency Verification',
    description:
        'Open official government recruitment-agency verification portals by nationality; signpost only.',
    route: '/agency-verification/check',
    isReadOnly: true,
  ),

  // ── Faith, travel, onboarding ────────────────────────────────────────────
  Capability(
    id: 'prayer_mosque',
    name: 'Prayer & Mosque',
    description:
        'Prayer times, Qibla compass, nearby mosques, Islamic calendar, and Jumuah reminders.',
    route: '/prayer-mosque',
    isReadOnly: true,
  ),
  Capability(
    id: 'trip_planner',
    name: 'Trip Planner',
    description:
        'AI-built Qatar itineraries, saved trips, place guides, and travel wallet.',
    route: '/trip-planner',
    isReadOnly: false,
  ),
  Capability(
    id: 'ramadan',
    name: 'Ramadan Hub',
    description: 'Seasonal Ramadan tools — prayer, Qibla, and Zakat calculator.',
    route: '/ramadan',
    isReadOnly: false,
  ),
  Capability(
    id: 'concierge_90_day',
    name: '90-Day Concierge Journey',
    description: 'Guided newcomer checklist and milestones for the first months in Qatar.',
    route: '/concierge-90-day',
    isReadOnly: false,
  ),
  Capability(
    id: 'prospective_migrant',
    name: 'Prospective Migrant Hub',
    description:
        'Pre-arrival contract preview, country guides, and QVC checklist before moving to Qatar.',
    route: '/prospective',
    isReadOnly: false,
  ),

  // ── Money services ───────────────────────────────────────────────────────
  Capability(
    id: 'money',
    name: 'Money & Exchange Rates',
    description:
        'Live remittance rates, house comparison, rate alerts, and branch finder tabs.',
    route: '/money',
    isReadOnly: true,
  ),
  Capability(
    id: 'gold',
    name: 'Gold Intelligence',
    description: 'Qatar gold spot prices, karat calculator, locker value, and price alerts.',
    route: '/money-services/gold',
    isReadOnly: true,
  ),
  Capability(
    id: 'cost_of_living',
    name: 'Cost of Living (CPI)',
    description: 'Official-style Qatar cost-of-living snapshots and category comparisons.',
    route: '/money-services/cost-of-living',
    isReadOnly: true,
  ),
  Capability(
    id: 'personal_budget',
    name: 'Personal Budget Calculator',
    description: 'Build a monthly budget from your income and spending categories.',
    route: '/money-services/personal-budget',
    isReadOnly: false,
  ),
  Capability(
    id: 'exchange_locator',
    name: 'Exchange Locator Pro',
    description: 'Map of exchange companies, branches, queue reports, reviews, and favorites.',
    route: '/money?tab=2',
    isReadOnly: true,
  ),
  Capability(
    id: 'corridor_comparator',
    name: 'Corridor Comparator',
    description: 'Compare remittance corridors and submit transfer experience reports.',
    route: '/money-services/corridor-comparator',
    isReadOnly: false,
  ),

  // ── Community & content ──────────────────────────────────────────────────
  Capability(
    id: 'community',
    name: 'Community',
    description: 'Expat groups, Ask Qatar Q&A, news, events, and lost & found.',
    route: '/community',
    isReadOnly: false,
  ),
  Capability(
    id: 'community_events',
    name: 'Community Events',
    description: 'Browse and post community meetups and event listings.',
    route: '/community/events',
    isReadOnly: false,
  ),
  Capability(
    id: 'news',
    name: 'Qatar Expat News',
    description: 'Curated RSS news feed for Qatar expat and GCC headlines.',
    route: '/news',
    isReadOnly: true,
  ),

  // ── Core marketplace & life screens ──────────────────────────────────────
  Capability(
    id: 'jobs',
    name: 'Jobs',
    description: 'Browse job listings matched to your profile and skills.',
    route: '/jobs',
    isReadOnly: true,
  ),
  Capability(
    id: 'cv_maker',
    name: 'CV Maker',
    description: 'Build, preview, and export a professional CV for Qatar job applications.',
    route: '/jobs/cv-start',
    isReadOnly: false,
  ),
  Capability(
    id: 'housing',
    name: 'Housing',
    description: 'Search rooms and apartments, view maps, and post housing listings.',
    route: '/housing',
    isReadOnly: false,
  ),
  Capability(
    id: 'businesses',
    name: 'Businesses',
    description: 'Directory of local businesses and services across Qatar.',
    route: '/businesses',
    isReadOnly: true,
  ),
  Capability(
    id: 'services_marketplace',
    name: 'Services Marketplace',
    description: 'Find and post service listings by category (repairs, tutoring, etc.).',
    route: '/services',
    isReadOnly: false,
  ),
  Capability(
    id: 'marketplace',
    name: 'Marketplace',
    description: 'Buy and sell second-hand items in the Raabta classifieds marketplace.',
    route: '/marketplace',
    isReadOnly: false,
  ),
  Capability(
    id: 'visa',
    name: 'Visa & Documents',
    description: 'Visa guides, document deadline tracker, and residency renewal information.',
    route: '/visa',
    isReadOnly: true,
  ),
  Capability(
    id: 'expat_score',
    name: 'Expat Life Score',
    description: 'View your expat life score breakdown, achievements, and improvement tips.',
    route: '/expat-score',
    isReadOnly: true,
  ),
  Capability(
    id: 'evidence_trail',
    name: 'Evidence Trail',
    description:
        'Log labour dispute incidents with dates, notes, and export a PDF evidence trail.',
    route: '/evidence-trail',
    isReadOnly: false,
  ),
  Capability(
    id: 'ai_chat',
    name: 'Raabta AI Chat',
    description: 'Ask Qatar life, labour, and app questions with Claude-powered assistance.',
    route: '/ai-chat',
    isReadOnly: false,
  ),
  Capability(
    id: 'global_search',
    name: 'Global Search',
    description: 'Search across app features, listings, jobs, and community content.',
    route: '/global-search',
    isReadOnly: true,
  ),

  // ── Daily utilities ──────────────────────────────────────────────────────
  Capability(
    id: 'daily_ussd',
    name: 'USSD Codes',
    description: 'Quick-reference USSD codes for Qatar telecom and utility shortcuts.',
    route: '/daily-ussd',
    isReadOnly: true,
  ),
  Capability(
    id: 'driving',
    name: 'Driving Hub',
    description:
        'Driving fee calculator, fine status lookup, and theory quiz for Qatar licences.',
    route: '/driving',
    isReadOnly: false,
  ),
];

/// Plain keyword match against [Capability.name] and [Capability.description].
List<Capability> findCapability(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];

  final tokens = q.split(RegExp(r'\s+')).where((t) => t.length >= 2).toList();
  if (tokens.isEmpty) return const [];

  final matches = <Capability>[];
  for (final cap in raabtaCapabilities) {
    final haystack = '${cap.name} ${cap.description} ${cap.id}'.toLowerCase();
    final hit = tokens.every((token) => haystack.contains(token));
    if (hit) matches.add(cap);
  }
  return matches;
}
