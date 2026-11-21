/// Canonical in-app navigation steps for RaabtaAI — AI guidance only, not app routing.
abstract final class RaabtaFeatureNavigationGuide {
  RaabtaFeatureNavigationGuide._();

  static const lastUpdated = '2026-09-17-selective';

  static const entries = <RaabtaFeatureNavEntry>[
    // ── Truth Engines ──────────────────────────────────────────────────────
    RaabtaFeatureNavEntry(
      id: 'eosb',
      route: '/eosb',
      name: 'EOSB Truth Engine',
      purpose: 'Calculate Qatar end-of-service gratuity and review employment details.',
      steps: [
        'Open EOSB from Home, Global Search, or Quick Actions.',
        'Tap Calculate (or Recalculate) on the EOSB dashboard.',
        'Enter employee information and employment dates on the form.',
        'Tap Calculate to run the gratuity calculation.',
        'Review the result screen; save or explore comparison and warnings if shown.',
      ],
      actionLabel: 'Calculate EOSB',

      matchPhrases: const ['end of service', 'end-of-service', 'end of service benefit', 'end of service benefits', 'eosb', 'gratuity', 'calculate eosb'],
      matchKeywords: const ['eos'],
      negativeKeywords: const [],
      whenToRecommend: 'EOSB, gratuity, end-of-service, or employment entitlement questions in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'eosb_overtime',
      route: '/eosb/overtime',
      name: 'Overtime Truth Hub',
      purpose: 'Verify overtime pay patterns under Qatar rules.',
      steps: [
        'Open EOSB, then choose Overtime from Your Tools (or go to /eosb/overtime).',
        'Enter or import overtime hours as prompted.',
        'Review the overtime summary and any AI review if available.',
      ],
      prerequisites: ['Employment basics may link back to EOSB employee information.'],
      actionLabel: 'Open Overtime Hub',

      matchPhrases: const ['overtime pay', 'overtime hub', 'overtime hours', 'calculate overtime', 'verify overtime', 'eosb and overtime', 'calculate eosb and overtime'],
      matchKeywords: const ['overtime'],
      negativeKeywords: const [],
      whenToRecommend: 'Overtime pay, working hours, or wage verification in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'health_insurance',
      route: '/health-insurance',
      name: 'Health Insurance Truth Engine',
      purpose: 'Check employer insurance compliance and explain policy documents.',
      steps: [
        'Open Health Insurance Truth Engine.',
        'Run Compliance Check to assess employer coverage obligations.',
        'Upload a policy document if you need a policy explainer.',
        'Use Denial & Dispute guidance if a claim was rejected.',
      ],
      actionLabel: 'Open Health Insurance',

      matchPhrases: const ['health insurance', 'insurance policy', 'employer insurance', 'mandatory insurance', 'moph insurance', 'insurance compliance', 'policy explainer'],
      matchKeywords: const ['qhis'],
      negativeKeywords: const [],
      whenToRecommend: 'Mandatory health insurance, employer premiums, or policy compliance in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'tenancy',
      route: '/tenancy',
      name: 'Housing & Tenancy Truth Engine',
      purpose: 'Enter lease terms, run compliance checks, and prepare dispute checklists.',
      steps: [
        'Open Tenancy Truth Engine.',
        'Tap Enter Lease to add lease details.',
        'Review the compliance result when available.',
        'Use the dispute checklist or condition capture tools if moving in/out.',
      ],
      actionLabel: 'Open Tenancy',

      matchPhrases: const ['tenancy truth', 'lease compliance', 'landlord dispute', 'rent deposit', 'housing tenancy', 'check my lease', 'enter lease'],
      matchKeywords: const ['landlord'],
      negativeKeywords: const ['employer accommodation', 'labour accommodation', 'wps accommodation'],
      whenToRecommend: 'Rent, lease, landlord disputes, deposits, or Law 4/2008 housing questions.',
    ),
    RaabtaFeatureNavEntry(
      id: 'sponsorship_transfer',
      route: '/sponsorship-transfer',
      name: 'Sponsorship Transfer Truth Engine',
      purpose: 'Assess employer transfer readiness, notice periods, and checklist steps.',
      steps: [
        'Open Sponsorship Transfer Truth Engine.',
        'Tap Start Readiness Check and answer the prompts.',
        'Review the result and open the transfer checklist.',
        'Use the in-engine AI assistant for follow-up questions on your case.',
      ],
      actionLabel: 'Open Sponsorship Transfer',

      matchPhrases: const ['sponsorship transfer', 'transfer my sponsorship', 'transfer readiness', 'change employer', 'employer transfer', 'iqama transfer', 'run transfer readiness'],
      matchKeywords: const ['noc'],
      negativeKeywords: const [],
      whenToRecommend: 'Changing employer, NOC, iqama transfer, or Law 19/2020 mobility questions.',
    ),

    // ── Daily Essentials ───────────────────────────────────────────────────
    RaabtaFeatureNavEntry(
      id: 'scanner_capture',
      route: '/scanner/capture',
      name: 'Document Scanner',
      purpose: 'Scan documents with OCR and export PDFs.',
      steps: [
        'Open Document Scanner (Doc Scanner).',
        'Capture or import pages with the camera or gallery.',
        'Apply filters, run OCR, or export via the scanner tools.',
        'Save to Document Vault when you want long-term storage.',
      ],
      actionLabel: 'Scan a Document',

      matchPhrases: const ['document scanner', 'doc scanner', 'scan document', 'scan a document', 'ocr scan'],
      matchKeywords: const ['scanner'],
      negativeKeywords: const [],
      whenToRecommend: 'Scanning IDs, contracts, receipts, or any paper document.',
    ),
    RaabtaFeatureNavEntry(
      id: 'barcode_scanner',
      route: '/barcode-scanner',
      name: 'Food Inspector',
      purpose: 'Scan product barcodes for halal and ingredient awareness.',
      steps: [
        'Open Food Inspector (Barcode Scanner).',
        'Scan a product barcode with the camera.',
        'Review halal, E-number, and allergy information shown.',
      ],
      actionLabel: 'Scan a Product',

      matchPhrases: const ['food inspector', 'barcode scanner', 'scan barcode', 'halal check', 'product barcode'],
      matchKeywords: const ['barcode', 'halal'],
      negativeKeywords: const [],
      whenToRecommend: 'Halal checks, food ingredients, or barcode product lookup.',
    ),
    RaabtaFeatureNavEntry(
      id: 'warranty_shield',
      route: '/warranty-shield',
      name: 'Warranty Shield',
      purpose: 'Track product warranties and expiry reminders.',
      steps: [
        'Open Warranty Shield.',
        'Add a product warranty with purchase date and retailer.',
        'Review upcoming expiry alerts on the dashboard.',
      ],
      actionLabel: 'Open Warranty Shield',

      matchPhrases: const ['warranty shield', 'product warranty', 'warranty track', 'warranty expiry'],
      matchKeywords: const ['warranty'],
      negativeKeywords: const [],
      whenToRecommend: 'Product warranty tracking or expiry reminders.',
    ),
    RaabtaFeatureNavEntry(
      id: 'bill_splitter',
      route: '/bill-splitter',
      name: 'Bill Splitter',
      purpose: 'Split restaurant or group bills fairly.',
      steps: [
        'Open Bill Splitter.',
        'Enter bill items or scan a receipt if available.',
        'Assign items to people and review each share.',
      ],
      actionLabel: 'Split a Bill',

      matchPhrases: const ['bill splitter', 'split bill', 'split the bill', 'restaurant bill', 'split restaurant'],
      matchKeywords: const ['splitter'],
      negativeKeywords: const [],
      whenToRecommend: 'Splitting restaurant, utility, or group expenses.',
    ),
    RaabtaFeatureNavEntry(
      id: 'bill_tracker',
      route: '/bill-tracker',
      name: 'Bill Tracker',
      purpose: 'Track utility and telecom bill due dates.',
      steps: [
        'Open Bill Tracker.',
        'Add a bill manually or import bill details when supported.',
        'Review upcoming due dates on the dashboard.',
      ],
      actionLabel: 'Track Bills',

      matchPhrases: const ['bill tracker', 'track bills', 'utility bill', 'kahramaa', 'ooredoo bill', 'vodafone bill'],
      matchKeywords: const ['telecom bill'],
      negativeKeywords: const [],
      whenToRecommend: 'Kahramaa, Ooredoo, Vodafone, or recurring utility bills.',
    ),
    RaabtaFeatureNavEntry(
      id: 'leaving_qatar',
      route: '/leaving-qatar',
      name: 'Leaving Qatar',
      purpose: 'Departure checklist, timeline, and official signpost links.',
      steps: [
        'Open Leaving Qatar from Daily Essentials or search.',
        'Work through the departure timeline and checklist sections.',
        'Use linked Raabta tools (EOSB, fines, marketplace hints) where shown.',
      ],
      actionLabel: 'Open Leaving Qatar',

      matchPhrases: const ['leaving qatar', 'departure checklist', 'final exit', 'exit qatar', 'leaving the country'],
      matchKeywords: const ['departure'],
      negativeKeywords: const [],
      whenToRecommend: 'Final exit, departure planning, or leaving Qatar checklists.',
    ),
    RaabtaFeatureNavEntry(
      id: 'document_vault',
      route: '/document-vault',
      name: 'Document Vault',
      purpose: 'Store and browse scanned documents with expiry tracking.',
      steps: [
        'Open Document Vault.',
        'Browse saved documents or open a document detail view.',
        'Add new scans via Document Scanner when needed.',
      ],
      actionLabel: 'Open Document Vault',

      matchPhrases: const ['document vault', 'stored documents', 'vault documents'],
      matchKeywords: const ['vault'],
      negativeKeywords: const [],
      whenToRecommend: 'Storing visas, contracts, IDs, or scanned paperwork.',
    ),

    // ── Core Services ──────────────────────────────────────────────────────
    RaabtaFeatureNavEntry(
      id: 'jobs',
      route: '/jobs',
      name: 'Jobs',
      purpose: 'Browse Qatar job listings matched to your profile.',
      steps: [
        'Open Jobs from Explore Raabta or Global Search.',
        'Browse listings and open a job for details.',
        'Use CV Maker (/jobs/cv-start) if you need to build a CV.',
      ],
      actionLabel: 'Browse Jobs',

      matchPhrases: const ['browse jobs', 'job listings', 'job search', 'find jobs', 'careers in qatar'],
      matchKeywords: const ['career'],
      negativeKeywords: const [],
      whenToRecommend: 'Job search, careers, or hiring in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'housing',
      route: '/housing',
      name: 'Housing',
      purpose: 'Search rooms and apartments or post a listing.',
      steps: [
        'Open Housing from Explore Raabta.',
        'Filter listings by area and budget.',
        'Open a listing for details or post your own listing.',
      ],
      actionLabel: 'Find Housing',

      matchPhrases: const ['find housing', 'find apartment', 'find an apartment', 'apartment to rent', 'rent apartment', 'room for rent', 'housing listing', 'flat for rent'],
      matchKeywords: const ['accommodation'],
      negativeKeywords: const ['employer accommodation', 'labour accommodation', 'wps accommodation'],
      whenToRecommend: 'Rent, rooms, apartments, or accommodation search.',
    ),
    RaabtaFeatureNavEntry(
      id: 'services',
      route: '/services',
      name: 'Services Marketplace',
      purpose: 'Find or post local service listings.',
      steps: [
        'Open Services from Explore Raabta.',
        'Browse categories or search for a service provider.',
        'Open a listing or post a new service offer.',
      ],
      actionLabel: 'Browse Services',

      matchPhrases: const ['services marketplace', 'service listing', 'find service provider', 'local service provider', 'find a local service', 'local services'],
      matchKeywords: const ['tutoring'],
      negativeKeywords: const [],
      whenToRecommend: 'Repairs, tutoring, domestic help, or local services.',
    ),
    RaabtaFeatureNavEntry(
      id: 'businesses',
      route: '/businesses',
      name: 'Businesses',
      purpose: 'Directory of Qatar businesses and services.',
      steps: [
        'Open Businesses from Explore Raabta.',
        'Search or browse business categories.',
        'Open a business profile for contact details.',
      ],
      actionLabel: 'Browse Businesses',

      matchPhrases: const ['business directory', 'browse businesses', 'find business', 'local business'],
      matchKeywords: const ['businesses'],
      negativeKeywords: const [],
      whenToRecommend: 'Finding local businesses or service providers.',
    ),
    RaabtaFeatureNavEntry(
      id: 'money',
      route: '/money',
      name: 'Money Hub',
      purpose: 'Live exchange rates, remittance comparison, and branch finder.',
      steps: [
        'Open Money Hub.',
        'Check live rates on the dashboard tab.',
        'Switch to Find a Branch or related tabs for exchange locations.',
      ],
      actionLabel: 'Open Money Hub',

      matchPhrases: const ['money hub', 'exchange rates', 'live rates', 'remittance rates', 'currency rates'],
      matchKeywords: const [],
      negativeKeywords: const ['corridor comparator', 'exchange locator', 'exchange branch', 'gold intelligence', 'personal budget', 'cost of living', 'corridor', 'gold price', 'have for money', 'send money to'],
      whenToRecommend: 'Exchange rates, remittance, or money transfer planning.',
    ),
    RaabtaFeatureNavEntry(
      id: 'visa',
      route: '/visa',
      name: 'Visa & Documents',
      purpose: 'Visa guides, deadlines, and residency document help.',
      steps: [
        'Open Visa & Documents.',
        'Choose a guide category relevant to your visa type.',
        'Use Document Scanner links when you need to capture visa paperwork.',
      ],
      actionLabel: 'Open Visa & Documents',

      matchPhrases: const ['visa help', 'check my visa', 'visa status', 'visa renewal', 'residency visa'],
      matchKeywords: const ['iqama', 'metrash'],
      negativeKeywords: const [],
      whenToRecommend: 'Visa status, renewals, residency, or immigration paperwork in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'marketplace',
      route: '/marketplace',
      name: 'Marketplace',
      purpose: 'Buy and sell second-hand items in Raabta classifieds.',
      steps: [
        'Open Marketplace.',
        'Browse categories or search listings.',
        'Post an ad when you want to sell something.',
      ],
      actionLabel: 'Open Marketplace',

      matchPhrases: const ['marketplace', 'classifieds', 'buy and sell', 'second hand', 'sell my item'],
      matchKeywords: const ['marketplace'],
      negativeKeywords: const [],
      whenToRecommend: 'Buying or selling used items in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'doctors',
      route: '/doctors',
      name: 'Doctors Directory',
      purpose: 'Browse healthcare providers in Qatar.',
      steps: [
        'Open Doctors from Explore or search.',
        'Browse or search for a provider.',
        'Open a profile for contact and location details.',
      ],
      actionLabel: 'Find Doctors',

      matchPhrases: const ['find a doctor', 'doctors directory', 'find doctor', 'healthcare provider', 'find clinic'],
      matchKeywords: const ['doctor', 'clinic', 'hospital', 'dentist'],
      negativeKeywords: const [],
      whenToRecommend: 'Finding clinics, doctors, or healthcare providers.',
    ),
    RaabtaFeatureNavEntry(
      id: 'gold',
      route: '/money-services/gold',
      name: 'Gold Intelligence',
      purpose: 'Qatar gold prices, karat calculator, and alerts.',
      steps: [
        'Open Gold Intelligence from Money services.',
        'Review spot prices and karat breakdowns.',
        'Use calculator or alerts if you track gold holdings.',
      ],
      actionLabel: 'Open Gold Intelligence',

      matchPhrases: const ['gold intelligence', 'gold price', 'gold prices', 'karat calculator', 'jewellery price'],
      matchKeywords: const ['karat'],
      negativeKeywords: const [],
      whenToRecommend: 'Gold prices, jewellery pricing, or karat calculations in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'cost_of_living',
      route: '/money-services/cost-of-living',
      name: 'Cost of Living',
      purpose: 'Qatar CPI-style cost snapshots by category.',
      steps: [
        'Open Cost of Living.',
        'Review category comparisons and charts shown.',
      ],
      actionLabel: 'Open Cost of Living',

      matchPhrases: const ['cost of living', 'living costs', 'cpi snapshot'],
      matchKeywords: const ['cpi'],
      negativeKeywords: const [],
      whenToRecommend: 'Living costs, CPI, or budget planning benchmarks.',
    ),
    RaabtaFeatureNavEntry(
      id: 'personal_budget',
      route: '/money-services/personal-budget',
      name: 'Personal Budget Calculator',
      purpose: 'Build a monthly budget from income and spending categories.',
      steps: [
        'Open Personal Budget Calculator.',
        'Enter income and category amounts.',
        'Review the budget summary.',
      ],
      actionLabel: 'Open Budget Calculator',

      matchPhrases: const ['personal budget', 'monthly budget', 'budget calculator'],
      matchKeywords: const ['budgeting'],
      negativeKeywords: const [],
      whenToRecommend: 'Monthly budgeting or personal finance planning.',
    ),
    RaabtaFeatureNavEntry(
      id: 'corridor_comparator',
      route: '/money-services/corridor-comparator',
      name: 'Corridor Comparator',
      purpose: 'Compare remittance corridors and share transfer experiences.',
      steps: [
        'Open Corridor Comparator from Money services.',
        'Select corridors and compare indicative rates.',
        'Submit a transfer experience report if you want to share feedback.',
      ],
      actionLabel: 'Compare Corridors',

      matchPhrases: const ['corridor comparator', 'compare corridors', 'remittance corridor', 'send money to india', 'sending money to india', 'send money to', 'compare remittance', 'exchange option'],
      matchKeywords: const ['corridor'],
      negativeKeywords: const [],
      whenToRecommend: 'Remittance corridor comparison or transfer provider research.',
    ),
    RaabtaFeatureNavEntry(
      id: 'exchange_locator',
      route: '/money?tab=2',
      name: 'Exchange Locator',
      purpose: 'Map of exchange companies, branches, queues, and reviews.',
      steps: [
        'Open Money Hub and go to the Branches tab.',
        'Browse companies or switch to the map/branches view.',
        'Open a branch for details, queues, and reviews.',
      ],
      actionLabel: 'Find Exchange Branches',

      matchPhrases: const ['exchange locator', 'exchange branch', 'find exchange', 'exchange house', 'money changer branch'],
      matchKeywords: const [],
      negativeKeywords: const [],
      whenToRecommend: 'Finding exchange houses or branch locations in Qatar.',
    ),

    // ── Other important features ───────────────────────────────────────────
    RaabtaFeatureNavEntry(
      id: 'scam_shield',
      route: '/scam-shield',
      name: 'ScamShield',
      purpose: 'Assess suspicious messages, links, and scam patterns before you respond.',
      steps: [
        'Open ScamShield.',
        'Start an assessment and paste or describe the suspicious message or link.',
        'Review the risk guidance; use incident logging or directory tools if needed.',
      ],
      actionLabel: 'Check with ScamShield',

      matchPhrases: const ['scam shield', 'scamshield', 'report a scam', 'suspicious message', 'suspicious transaction', 'phishing', 'job scam', 'fraud check'],
      matchKeywords: const ['scam'],
      negativeKeywords: const [],
      whenToRecommend: 'Suspicious SMS, WhatsApp, job scam, phishing, or fraud checks.',
    ),
    RaabtaFeatureNavEntry(
      id: 'know_qatar',
      route: '/know-qatar',
      name: 'Know Qatar',
      purpose: 'Static Qatar life guides with official sources and deep links to Raabta tools.',
      steps: [
        'Open Know Qatar from Qatar Life or search.',
        'Expand the section that matches your topic.',
        'Follow action links inside the section for related Raabta tools.',
      ],
      actionLabel: 'Open Know Qatar',

      matchPhrases: const ['know qatar', 'qatar life guide', 'life in qatar guide'],
      matchKeywords: const [],
      negativeKeywords: const [],
      whenToRecommend: 'General Qatar life guides, buying a car, telecom, driving, or freelance visa facts.',
    ),
    RaabtaFeatureNavEntry(
      id: 'global_search',
      route: '/global-search',
      name: 'Global Search',
      purpose: 'Search across Raabta features, listings, jobs, and community content.',
      steps: [
        'Open Global Search from Home or the search entry point.',
        'Type the feature or topic name (e.g. EOSB, visa, housing).',
        'Tap the best match to navigate directly.',
      ],
      actionLabel: 'Open Global Search',

      matchPhrases: const ['global search', 'search raabta', 'search the app'],
      matchKeywords: const [],
      negativeKeywords: const [],
      whenToRecommend: 'User cannot find a feature or wants the fastest route to any Raabta tool.',
    ),
    RaabtaFeatureNavEntry(
      id: 'climate_navigator',
      route: '/climate-navigator',
      name: 'Climate Navigator',
      purpose: 'Heat risk guidance and shaded/indoor walking routes.',
      steps: [
        'Open Climate Navigator.',
        'Review current heat risk and outdoor work guidance.',
        'Use cooling resources or route suggestions when shown.',
      ],
      actionLabel: 'Open Climate Navigator',

      matchPhrases: const ['climate navigator', 'heat route', 'walking route heat', 'outdoor heat safety'],
      matchKeywords: const ['climate'],
      negativeKeywords: const [],
      whenToRecommend: 'Heat safety, outdoor work, or walking routes in summer.',
    ),
    RaabtaFeatureNavEntry(
      id: 'queue_avoidance',
      route: '/queue-avoidance',
      name: 'Queue Avoidance',
      purpose: 'Crowd-reported wait times at government and service locations.',
      steps: [
        'Open Queue Avoidance.',
        'Pick a location category and review reported wait times.',
        'Submit a crowd report if you want to update wait data.',
      ],
      actionLabel: 'Check Queue Times',

      matchPhrases: const ['queue avoidance', 'wait times', 'government queue', 'metrash queue'],
      matchKeywords: const ['queue'],
      negativeKeywords: const [],
      whenToRecommend: 'Government office queues, Metrash, or service centre wait times.',
    ),
    RaabtaFeatureNavEntry(
      id: 'arabic_companion',
      route: '/arabic-companion',
      name: 'Arabic Companion',
      purpose: 'Offline phrasebook and live Gulf Arabic translation.',
      steps: [
        'Open Arabic Companion.',
        'Browse phrase categories or use live translation.',
      ],
      actionLabel: 'Open Arabic Companion',

      matchPhrases: const ['arabic companion', 'arabic phrasebook', 'gulf arabic', 'translate arabic'],
      matchKeywords: const ['phrasebook'],
      negativeKeywords: const [],
      whenToRecommend: 'Arabic phrases for taxis, shops, directions, or daily conversation.',
    ),
    RaabtaFeatureNavEntry(
      id: 'trip_planner',
      route: '/trip-planner',
      name: 'Trip Planner',
      purpose: 'AI-built Qatar itineraries, saved trips, and place guides.',
      steps: [
        'Open Trip Planner.',
        'Set trip preferences or open a saved itinerary.',
        'Explore places, budget, and travel tools from the trip home screen.',
      ],
      actionLabel: 'Open Trip Planner',

      matchPhrases: const ['trip planner', 'qatar itinerary', 'travel itinerary', 'places to visit qatar'],
      matchKeywords: const ['itinerary'],
      negativeKeywords: const [],
      whenToRecommend: 'Visiting Qatar, itineraries, attractions, or travel planning.',
    ),
    RaabtaFeatureNavEntry(
      id: 'prayer_mosque',
      route: '/prayer-mosque',
      name: 'Prayer & Mosque',
      purpose: 'Prayer times, Qibla, nearby mosques, and Islamic calendar tools.',
      steps: [
        'Open Prayer & Mosque.',
        'View today\'s prayer times on the dashboard.',
        'Open Qibla, mosque finder, or calendar tools as needed.',
      ],
      actionLabel: 'Open Prayer & Mosque',

      matchPhrases: const ['prayer times', 'prayer mosque', 'qibla', 'nearby mosque', 'mosque finder'],
      matchKeywords: const ['qibla'],
      negativeKeywords: const [],
      whenToRecommend: 'Prayer times, Qibla direction, or mosque locations.',
    ),
    RaabtaFeatureNavEntry(
      id: 'concierge_90_day',
      route: '/concierge-90-day',
      name: '90-Day Concierge Journey',
      purpose: 'Guided newcomer milestones for the first months in Qatar.',
      steps: [
        'Open 90-Day Concierge Journey.',
        'Review your milestone timeline.',
        'Complete or explore linked Raabta tools from each milestone.',
      ],
      actionLabel: 'Open 90-Day Concierge',

      matchPhrases: const ['90-day concierge', '90 day concierge', 'newcomer checklist', 'first 90 days'],
      matchKeywords: const ['concierge'],
      negativeKeywords: const [],
      whenToRecommend: 'New arrivals or first 90 days in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'evidence_trail',
      route: '/evidence-trail',
      name: 'Evidence Trail',
      purpose: 'Log labour dispute incidents and export a PDF evidence trail.',
      steps: [
        'Open Evidence Trail.',
        'Add dated incident notes with supporting details.',
        'Export the PDF trail when you need a record for complaints.',
      ],
      actionLabel: 'Open Evidence Trail',

      matchPhrases: const ['evidence trail', 'dispute evidence', 'labour dispute log', 'complaint record'],
      matchKeywords: const [],
      negativeKeywords: const [],
      whenToRecommend: 'Documenting employer disputes or building a complaint record.',
    ),
    RaabtaFeatureNavEntry(
      id: 'driving',
      route: '/driving',
      name: 'Driving Hub',
      purpose: 'Driving fees, fine status lookup, and theory quiz for Qatar licences.',
      steps: [
        'Open Driving Hub.',
        'Use fine status lookup or fee calculators as shown.',
        'Try the theory quiz section if preparing for a licence test.',
      ],
      actionLabel: 'Open Driving Hub',

      matchPhrases: const ['driving hub', 'traffic fine', 'driving licence', 'driving license', 'theory quiz'],
      matchKeywords: const ['driving'],
      negativeKeywords: const [],
      whenToRecommend: 'Traffic fines, driving licence, or MOI driving queries in Qatar.',
    ),
    RaabtaFeatureNavEntry(
      id: 'daily_ussd',
      route: '/daily-ussd',
      name: 'USSD Codes',
      purpose: 'Quick-reference telecom USSD codes for Ooredoo and Vodafone.',
      steps: [
        'Open USSD Codes.',
        'Select your operator.',
        'Copy or dial the code you need.',
      ],
      actionLabel: 'Open USSD Codes',

      matchPhrases: const ['ussd codes', 'ussd code', 'telecom ussd', 'ooredoo ussd'],
      matchKeywords: const ['ussd'],
      negativeKeywords: const [],
      whenToRecommend: 'Mobile balance, data, or telecom USSD shortcuts.',
    ),
    RaabtaFeatureNavEntry(
      id: 'expat_score',
      route: '/expat-score',
      name: 'Expat Life Score',
      purpose: 'View expat life score breakdown and improvement tips.',
      steps: [
        'Open Expat Life Score from Home or profile.',
        'Review category scores and recommendations.',
      ],
      actionLabel: 'View Expat Score',

      matchPhrases: const ['expat life score', 'expat score', 'life score breakdown'],
      matchKeywords: const [],
      negativeKeywords: const [],
      whenToRecommend: 'Profile completeness or expat life score improvement.',
    ),
    RaabtaFeatureNavEntry(
      id: 'cv_maker',
      route: '/jobs/cv-start',
      name: 'CV Maker',
      purpose: 'Build and export a CV for Qatar job applications.',
      steps: [
        'Open CV Maker from Jobs (/jobs/cv-start).',
        'Follow the CV builder steps.',
        'Preview and export your CV.',
      ],
      actionLabel: 'Start CV Maker',

      matchPhrases: const ['cv maker', 'build cv', 'create cv', 'resume builder'],
      matchKeywords: const ['cv-start'],
      negativeKeywords: const [],
      whenToRecommend: 'Creating or updating a CV for Qatar jobs.',
    ),

    RaabtaFeatureNavEntry(
      id: 'ramadan',
      route: '/ramadan',
      name: 'Ramadan Hub',
      purpose: 'Seasonal Ramadan prayer, Qibla, and Zakat tools.',
      steps: [
        'Open Ramadan Hub from Home or Quick Actions.',
        'Use prayer times, Qibla, or Zakat tools as needed.',
      ],
      actionLabel: 'Open Ramadan Hub',

      matchPhrases: const ['ramadan hub', 'ramadan tools', 'zakat calculator'],
      matchKeywords: const ['ramadan'],
      negativeKeywords: const [],
      whenToRecommend: 'Ramadan-season prayer, Qibla, or Zakat questions.',
    ),
    RaabtaFeatureNavEntry(
      id: 'news',
      route: '/news',
      name: 'Qatar Expat News',
      purpose: 'Curated RSS news feed for Qatar expat headlines.',
      steps: [
        'Open Community → News, or go directly to /news.',
        'Browse headlines and open articles of interest.',
      ],
      actionLabel: 'Open News',

      matchPhrases: const ['expat news', 'qatar news feed', 'community news'],
      matchKeywords: const ['news'],
      negativeKeywords: const [],
      whenToRecommend: 'Latest Qatar expat news — not legal advice.',
    ),
    RaabtaFeatureNavEntry(
      id: 'prospective_migrant',
      route: '/prospective',
      name: 'Prospective Migrant Hub',
      purpose: 'Pre-arrival contract preview, country guides, and QVC checklist.',
      steps: [
        'Open Prospective Migrant Hub.',
        'Choose country guide, contract preview, or QVC checklist.',
        'Complete the pre-arrival steps before you travel.',
      ],
      actionLabel: 'Open Prospective Hub',

      matchPhrases: const [
        'moving to qatar',
        'before i arrive',
        'prospective migrant',
        'qvc checklist',
      ],
      matchKeywords: const ['prospective'],
      negativeKeywords: const [],
      whenToRecommend: 'Pre-arrival planning before the user lands in Qatar.',
    ),

    // ── Community (single hub route; sections are in-app) ──────────────────
    RaabtaFeatureNavEntry(
      id: 'community',
      route: '/community',
      name: 'Community',
      purpose: 'Groups, Ask Qatar, news, events, and lost & found.',
      steps: [
        'Open Community.',
        'Choose Groups, Ask Qatar, News, Events, or Lost & Found.',
        'Post or browse within the section you need.',
      ],
      actionLabel: 'Open Community',

      matchPhrases: const ['ask qatar', 'community groups', 'lost and found', 'community events'],
      matchKeywords: const ['community'],
      negativeKeywords: const [],
      whenToRecommend: 'Community questions, events, news, or lost items — not official legal advice.',
    ),
  ];

  /// Routes safe for [[action:...]] chips — roots only (sub-routes allowed via prefix match).
  static Set<String> get actionRouteRoots =>
      entries.map((e) => e.route).toSet();

  static RaabtaFeatureNavEntry? byId(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }


  static const _scoreThreshold = 8;
  static const _phraseScore = 10;
  static const _keywordScore = 3;
  static const _nameRouteScore = 5;
  static const _negativePenalty = 5;
  static const _maxKeywordHits = 2;

  /// Route tails that must not match from generic wording alone (e.g. "for money").
  static const _genericRouteTails = {
    'money',
    'jobs',
    'visa',
    'community',
    'housing',
    'services',
    'businesses',
    'marketplace',
  };

  static const _truthEngineIds = {
    'eosb',
    'eosb_overtime',
    'health_insurance',
    'tenancy',
    'sponsorship_transfer',
  };

  static const _dailyEssentialIds = {
    'scanner_capture',
    'barcode_scanner',
    'warranty_shield',
    'bill_splitter',
    'bill_tracker',
    'leaving_qatar',
    'document_vault',
  };

  static String _normalizeSelectionText(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Builds text used ONLY for navigation selection (not injected into prompt).
  static String buildSelectionText({
    required String message,
    List<Map<String, String>> conversationHistory = const [],
    String? rollingSummary,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return '';

    final buffer = StringBuffer(trimmed);
    final needsContext = _isAmbiguousFollowUp(trimmed) ||
        selectRelevantEntries(trimmed, maxEntries: 1).isEmpty;

    if (needsContext && conversationHistory.isNotEmpty) {
      final recent = conversationHistory.length > 4
          ? conversationHistory.sublist(conversationHistory.length - 4)
          : conversationHistory;
      for (final turn in recent) {
        final content = turn['content']?.trim();
        if (content != null && content.isNotEmpty) {
          buffer.write(' ');
          buffer.write(content);
        }
      }
    }

    final summary = rollingSummary?.trim();
    if (needsContext && summary != null && summary.isNotEmpty) {
      final snippet = summary.length > 200
          ? summary.substring(summary.length - 200)
          : summary;
      buffer.write(' ');
      buffer.write(snippet);
    }

    return buffer.toString();
  }

  static bool _isAmbiguousFollowUp(String message) {
    final lower = message.toLowerCase().trim();
    if (lower.length >= 60) return false;
    const patterns = [
      'what information',
      'what do i need',
      'what next',
      'and then',
      'how about that',
      'how about',
      'tell me more',
      'what else',
      'what about',
    ];
    return patterns.any(lower.contains);
  }

  static int _categoryPriority(String id) {
    if (_truthEngineIds.contains(id)) return 0;
    if (_dailyEssentialIds.contains(id)) return 1;
    if (id == 'money' || id == 'global_search') return 3;
    return 2;
  }

  static int _scoreEntry(RaabtaFeatureNavEntry entry, String normalized) {
    var score = 0;
    var phraseKeywordScore = 0;
    var keywordHits = 0;

    final phrases = [...entry.matchPhrases]..sort((a, b) => b.length.compareTo(a.length));
    for (final phrase in phrases) {
      final p = phrase.toLowerCase();
      if (p.isNotEmpty && normalized.contains(p)) {
        phraseKeywordScore += _phraseScore;
        score += _phraseScore;
      }
    }

    for (final keyword in entry.matchKeywords) {
      final k = keyword.toLowerCase();
      if (k.isEmpty) continue;
      if (normalized.contains(k)) {
        keywordHits++;
        if (keywordHits <= _maxKeywordHits) {
          phraseKeywordScore += _keywordScore;
          score += _keywordScore;
        }
      }
    }

    final hasDomainSignal = phraseKeywordScore > 0;

    if (hasDomainSignal) {
      final nameLower = entry.name.toLowerCase();
      if (nameLower.isNotEmpty && normalized.contains(nameLower)) {
        score += _nameRouteScore;
      } else {
        for (final part in nameLower.split(RegExp(r'[^a-z0-9]+'))) {
          if (part.length >= 5 && normalized.contains(part)) {
            score += _nameRouteScore;
            break;
          }
        }
      }

      final routeTail = entry.route.split('/').where((s) => s.isNotEmpty).last;
      if (routeTail.length >= 4 &&
          !_genericRouteTails.contains(routeTail) &&
          (normalized.contains(routeTail) ||
              normalized.contains(routeTail.replaceAll('-', ' ')))) {
        score += _nameRouteScore;
      }
    }

    for (final negative in entry.negativeKeywords) {
      final n = negative.toLowerCase();
      if (n.isNotEmpty && normalized.contains(n)) {
        score -= _negativePenalty;
      }
    }

    return score;
  }

  /// Deterministic local feature selection for main-chat navigation injection.
  static List<RaabtaFeatureNavEntry> selectRelevantEntries(
    String selectionText, {
    int maxEntries = 2,
  }) {
    final normalized = _normalizeSelectionText(selectionText);
    if (normalized.isEmpty || maxEntries <= 0) return const [];

    final scored = <({RaabtaFeatureNavEntry entry, int score})>[];
    for (final entry in entries) {
      final score = _scoreEntry(entry, normalized);
      if (score >= _scoreThreshold) {
        scored.add((entry: entry, score: score));
      }
    }

    if (scored.isEmpty) return const [];

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return _categoryPriority(a.entry.id).compareTo(_categoryPriority(b.entry.id));
    });

    return scored.take(maxEntries).map((item) => item.entry).toList();
  }

  static List<RaabtaFeatureNavEntry> selectRelevantEntriesForRequest({
    required String message,
    List<Map<String, String>> conversationHistory = const [],
    String? rollingSummary,
    int maxEntries = 2,
  }) {
    final direct = selectRelevantEntries(message, maxEntries: maxEntries);
    if (direct.isNotEmpty) return direct;

    final expanded = buildSelectionText(
      message: message,
      conversationHistory: conversationHistory,
      rollingSummary: rollingSummary,
    );
    if (expanded.trim() == message.trim()) return const [];
    return selectRelevantEntries(expanded, maxEntries: maxEntries);
  }

  static String buildNavigationIndex() {
    final buffer = StringBuffer(
      'NAVIGATION INDEX (feature names and routes only — orient the user; '
      'detailed steps when a specific feature is identified):\n',
    );
    for (final entry in entries) {
      buffer.writeln('- ${entry.name} → ${entry.route}');
    }
    return buffer.toString().trim();
  }

  static String buildContextualPromptSection(
    String selectionText, {
    int maxEntries = 2,
  }) {
    final selected = selectRelevantEntries(selectionText, maxEntries: maxEntries);
    if (selected.isEmpty) {
      return buildNavigationIndex();
    }
    final buffer = StringBuffer(
      'NAVIGATION GUIDE (relevant features only — do not invent screens):\n',
    );
    for (final entry in selected) {
      buffer.writeln(entry.toPromptLines());
    }
    return buffer.toString().trim();
  }

  static String buildContextualPromptForRequest({
    required String message,
    List<Map<String, String>> conversationHistory = const [],
    String? rollingSummary,
    int maxEntries = 2,
  }) {
    final selected = selectRelevantEntriesForRequest(
      message: message,
      conversationHistory: conversationHistory,
      rollingSummary: rollingSummary,
      maxEntries: maxEntries,
    );
    if (selected.isEmpty) {
      return buildNavigationIndex();
    }
    final buffer = StringBuffer(
      'NAVIGATION GUIDE (relevant features only — do not invent screens):\n',
    );
    for (final entry in selected) {
      buffer.writeln(entry.toPromptLines());
    }
    return buffer.toString().trim();
  }

  /// Compact navigation block injected into RaabtaAI chat context.
  static String buildCompactPromptSection() {
    final buffer = StringBuffer('NAVIGATION GUIDE (use these steps — do not invent screens):\n');
    for (final entry in entries) {
      buffer.writeln(entry.toPromptLines());
    }
    return buffer.toString().trim();
  }
}

class RaabtaFeatureNavEntry {
  const RaabtaFeatureNavEntry({
    required this.id,
    required this.route,
    required this.name,
    required this.purpose,
    required this.steps,
    required this.whenToRecommend,
    this.prerequisites = const [],
    this.actionLabel,
    this.matchPhrases = const [],
    this.matchKeywords = const [],
    this.negativeKeywords = const [],
  });

  final String id;
  final String route;
  final String name;
  final String purpose;
  final List<String> steps;
  final List<String> prerequisites;
  final String whenToRecommend;
  final String? actionLabel;
  final List<String> matchPhrases;
  final List<String> matchKeywords;
  final List<String> negativeKeywords;

  String toPromptLines() {
    final buffer = StringBuffer()
      ..writeln('• $name ($route): $purpose')
      ..writeln('  When: $whenToRecommend');
    if (prerequisites.isNotEmpty) {
      buffer.writeln('  Prereq: ${prerequisites.join('; ')}');
    }
    for (var i = 0; i < steps.length; i++) {
      buffer.writeln('  ${i + 1}. ${steps[i]}');
    }
    if (actionLabel != null) {
      buffer.writeln('  Action: [[action:$route|$actionLabel]]');
    }
    return buffer.toString().trimRight();
  }
}
