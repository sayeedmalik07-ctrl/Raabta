/// Know Qatar (Qatar 360°) — static knowledge layer strings.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class KnowQatarStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static const keysNeedingProfessionalReview = <String>{
    'kq_moment_just_arrived_intro',
    'kq_moment_starting_job_intro',
    'kq_moment_bringing_family_intro',
    'kq_moment_setting_up_home_intro',
    'kq_moment_visiting_intro',
    'kq_moment_going_home_intro',
    'kq_moment_something_wrong_intro',
    'kq_moment_hosting_visitors_title',
    'kq_moment_hosting_visitors_intro',
    'kq_hosting_link_moi_service_title',
    'kq_hosting_link_moi_policy_title',
    'kq_hosting_link_moph_qhis_title',
    'kq_hosting_link_moi_service_summary',
    'kq_hosting_link_moi_policy_summary',
    'kq_hosting_link_moph_qhis_summary',
    'kq_hosting_route_visa_summary',
    'kq_hosting_route_health_insurance_summary',
    'kq_section_qatar_at_glance_body',
    'kq_section_history_body',
    'kq_section_leadership_body',
    'kq_section_economy_body',
    'kq_section_cities_body',
    'kq_section_culture_body',
    'kq_section_work_body',
    'kq_section_living_body',
    'kq_section_money_body',
    'kq_section_residency_body',
    'kq_section_communities_body',
    'kq_section_alerts_safety_body',
  };

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale, {
    Map<String, String> params = const {},
  }) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // ── Screen chrome ─────────────────────────────────────────────────────
    'kq_screen_title': l10nEntry(
      english: 'Know Qatar',
      arabic: 'تعرّف على قطر',
      hindi: 'क़तर जानें',
      urdu: 'قطر جانیں',
    ),
    'kq_screen_intro': l10nEntry(
      english:
          'Short, source-backed summaries about Qatar — history, government, culture, work, and living. For calculations, tracking, or verification, use the linked Raabta tools below each section.',
      arabic:
          'ملخصات قصيرة مدعومة بمصادر رسمية عن قطر — التاريخ والحكومة والثقافة والعمل والمعيشة. للحساب أو التتبع أو التحقق، استخدم أدوات رaabta المرتبطة.',
    ),

    // ── Phase 2 persona banners (computed live — not stored) ───────────────
    'kq_persona_banner_visitor': l10nEntry(
      english:
          'Welcome to Qatar 360° — browse source-backed guides on history, culture, work, and daily life. Expand any section below; linked Raabta tools handle tracking and calculations.',
      arabic:
          'مرحباً بك في قطر 360° — تصفّح أدلة مدعومة بمصادر عن التاريخ والثقافة والعمل والحياة اليومية. وسّع أي قسم؛ أدوات Raabta المرتبطة تتولى التتبع والحساب.',
      hindi:
          'Qatar 360° में आपका स्वागत है — इतिहास, संस्कृति, काम और दैनिक जीवन पर source-backed guides देखें। नीचे कोई भी section खोलें; linked Raabta tools tracking और calculations संभालते हैं।',
      urdu:
          'Qatar 360° میں خوش آمدید — تاریخ، ثقافت، کام اور روزمرہ زندگی پر source-backed guides دیکھیں۔ نیچے کوئی section کھولیں؛ linked Raabta tools tracking اور calculations سنبھالتے ہیں۔',
    ),
    'kq_persona_banner_new_resident': l10nEntry(
      english:
          'New in Qatar? Start with Residency & Documents and Living in Qatar below — they cover QID, visas, housing basics, and the first practical steps most arrivals need.',
      arabic:
          'جديد في قطر؟ ابدأ بـ الإقامة والوثائق والمعيشة في قطر أدناه — تغطي QID والتأشيرات وأساسيات السكن وأول خطوات عملية.',
      hindi:
          'Qatar में नए? नीचे Residency & Documents और Living in Qatar से शुरू करें — QID, visas, housing basics और पहले practical steps।',
      urdu:
          'Qatar میں نئے؟ نیچے Residency & Documents اور Living in Qatar سے شروع کریں — QID، visas، housing basics اور پہلے practical steps۔',
    ),
    'kq_persona_banner_working_resident': l10nEntry(
      english:
          'Working in Qatar? Prioritise Work in Qatar for labour rules and mobility, and open EOSB from the linked tools to check your end-of-service entitlement before any job change.',
      arabic:
          'تعمل في قطر؟ ركّز على العمل في قطر لقواعد العمل والتنقل، وافتح EOSB من الأدوات المرتبطة للتحقق من مستحقات نهاية الخدمة قبل أي تغيير وظيفي.',
      hindi:
          'Qatar में काम? Work in Qatar में labour rules और mobility देखें, और job change से पहले EOSB से end-of-service entitlement check करें।',
      urdu:
          'Qatar میں کام؟ Work in Qatar میں labour rules دیکھیں، اور job change سے پہلے EOSB سے end-of-service entitlement check کریں۔',
    ),
    'kq_persona_banner_family': l10nEntry(
      english:
          'Bringing family to Qatar? Focus on Living in Qatar, Tenancy, and Residency & Documents — housing, schools, health cover, and family visa renewal timelines matter most for dependents.',
      arabic:
          'تأتي بعائلتك إلى قطر؟ ركّز على المعيشة في قطر والإيجار والإقامة والوثائق — السكن والمدارس والتأمين وجداول تجديد تأشيرة العائلة أهم للمعالين.',
      hindi:
          'परिवार Qatar ला रहे हैं? Living in Qatar, Tenancy, और Residency & Documents पर focus करें — housing, schools, health cover, family visa renewal।',
      urdu:
          'خاندان Qatar لا رہے ہیں؟ Living in Qatar، Tenancy، اور Residency & Documents پر focus کریں — housing، schools، health cover، family visa renewal۔',
    ),

    'kq_source_footer': l10nEntry(
      english: 'Source: {source} · Reviewed {date}',
      arabic: 'المصدر: {source} · مراجعة {date}',
      hindi: 'स्रोत: {source} · समीक्षा {date}',
      urdu: 'ماخذ: {source} · جائزہ {date}',
    ),
    'kq_action_card_hint': l10nEntry(
      english: 'Opens an existing Raabta tool — this section explains only.',
      arabic: 'يفتح أداة Raabta موجودة — هذا القسم للشرح فقط.',
    ),
    'kq_action_open': l10nEntry(
      english: 'Open →',
      arabic: 'فتح ←',
      hindi: 'खोलें →',
    ),
    'kq_action_links_heading': l10nEntry(
      english: 'Related Raabta tools',
      arabic: 'أدوات Raabta ذات الصلة',
      hindi: 'संबंधित Raabta टूल',
      urdu: 'متعلقہ Raabta ٹولز',
    ),
    'kq_ask_ai': l10nEntry(
      english: 'Ask RaabtaAI about this →',
      arabic: 'اسأل RaabtaAI عن هذا ←',
    ),
    'kq_timeline_title': l10nEntry(
      english: 'Historical timeline',
      arabic: 'الخط الزمني التاريخي',
    ),
    'kq_progress_title': l10nEntry(
      english: 'Key milestones & progress',
      arabic: 'معالم رئيسية وتقدم',
    ),
    'kq_chip_arabic_phrases': l10nEntry(
      english: 'Useful Arabic phrases',
      arabic: 'عبارات عربية مفيدة',
    ),
    'kq_chip_nearby_mosques': l10nEntry(
      english: 'Nearby mosques',
      arabic: 'مساجد قريبة',
    ),

    // ── Source labels ─────────────────────────────────────────────────────
    'kq_source_hukoomi': l10nEntry(english: 'Hukoomi', arabic: 'حكومي'),
    'kq_source_moci': l10nEntry(english: 'MOCI', arabic: 'وزارة التجارة'),
    'kq_source_adlsa': l10nEntry(
      english: 'ADLSA',
      arabic: 'وزارة التنمية الاجتماعية',
    ),
    'kq_source_moi': l10nEntry(english: 'MOI', arabic: 'وزارة الداخلية'),
    'kq_source_qnv2030': l10nEntry(
      english: 'Qatar National Vision 2030',
      arabic: 'رؤية قطر الوطنية 2030',
    ),
    'kq_source_qcb': l10nEntry(
      english: 'Qatar Central Bank',
      arabic: 'مصرف قطر المركزي',
    ),

    // ── Action labels ─────────────────────────────────────────────────────
    'kq_action_money_hub': l10nEntry(
      english: 'Check in Money Hub',
      arabic: 'تحقق في مركز المال',
    ),
    'kq_action_visa_documents': l10nEntry(
      english: 'Check in Visa & Documents',
      arabic: 'تحقق في التأشيرة والمستندات',
    ),
    'kq_action_trip_planner': l10nEntry(
      english: 'Explore in Trip Planner',
      arabic: 'استكشف في مخطط الرحلات',
    ),
    'kq_action_arabic_tools': l10nEntry(
      english: 'Open Arabic tools',
      arabic: 'افتح أدوات العربية',
    ),
    'kq_action_mosque_prayer': l10nEntry(
      english: 'Open Mosque & Prayer',
      arabic: 'افتح المسجد والصلاة',
    ),
    'kq_action_eosb': l10nEntry(
      english: 'Calculate in EOSB',
      arabic: 'احسب في EOSB',
    ),
    'kq_action_sponsorship_transfer': l10nEntry(
      english: 'Check in Employer Transfer',
      arabic: 'تحقق في نقل الكفالة',
    ),
    'kq_action_jobs': l10nEntry(
      english: 'Browse Jobs',
      arabic: 'تصفح الوظائف',
    ),
    'kq_action_tenancy': l10nEntry(
      english: 'Verify in Tenancy Truth Engine',
      arabic: 'تحقق في محرك الإيجار',
    ),
    'kq_action_housing': l10nEntry(
      english: 'Find Housing',
      arabic: 'ابحث عن سكن',
    ),
    // TODO-TRANSLATE-REVIEW
    'kq_action_civic_report': l10nEntry(
      english: 'Report a neighbourhood problem',
      arabic: 'الإبلاغ عن مشكلة في الحي',
      urdu: 'محلے کا مسئلہ رپورٹ کریں',
    ),
    'kq_action_cost_of_living': l10nEntry(
      english: 'Calculate Cost of Living',
      arabic: 'احسب تكلفة المعيشة',
    ),
    'kq_action_visa_deadline': l10nEntry(
      english: 'Track in Deadline Tracker',
      arabic: 'تتبع في متتبع المواعيد',
    ),
    'kq_action_community': l10nEntry(
      english: 'Join Community',
      arabic: 'انضم للمجتمع',
    ),
    'kq_trip_learn_link': l10nEntry(
      english: 'Learn about Qatar →',
      arabic: 'تعرّف على قطر ←',
    ),

    // ── Section 1: Qatar at a Glance ──────────────────────────────────────
    'kq_section_qatar_at_glance_title': l10nEntry(
      english: 'Qatar at a Glance',
      arabic: 'قطر في لمحة',
    ),
    'kq_section_qatar_at_glance_teaser': l10nEntry(
      english: 'Location, population, currency, and what makes Qatar unique.',
      arabic: 'الموقع والسكان والعملة وما يميز قطر.',
    ),
    'kq_section_qatar_at_glance_body': l10nEntry(
      english:
          'The State of Qatar is a peninsula on the Arabian Gulf, bordering Saudi Arabia. Its capital is Doha. According to Hukoomi, Qatar has developed rapidly since independence in 1971, transforming from a pearl-diving economy into a modern state with world-class infrastructure. The official currency is the Qatari Riyal (QAR), pegged to the US dollar. Qatar hosts a large expatriate population alongside Qatari nationals, making it one of the most internationally diverse countries in the Gulf. The country is a constitutional monarchy headed by the Amir, with the Shura Council serving as the legislative body. Public services — healthcare, education, and transport — are widely accessible. Qatar National Vision 2030 guides long-term development toward a knowledge-based, diversified economy. For day-to-day money matters — exchange rates, remittances, and budgeting — use Money Hub rather than estimating here.',
    ),

    // ── Section 2: History ────────────────────────────────────────────────
    'kq_section_history_title': l10nEntry(
      english: 'History',
      arabic: 'التاريخ',
    ),
    'kq_section_history_teaser': l10nEntry(
      english: 'From pearl diving to independence and modern Qatar.',
      arabic: 'من الغوص على اللؤلؤ إلى الاستقلال وقطر الحديثة.',
    ),
    'kq_section_history_body': l10nEntry(
      english:
          'Human settlement in Qatar dates back thousands of years, with archaeological evidence of trade and fishing communities along the coast. For centuries, pearl diving was the backbone of the local economy until the 1930s, when Japan\'s cultured pearls and later hydrocarbon discoveries reshaped the region. Oil was found in 1939 and exports began after World War II, accelerating development under Sheikh Ahmad bin Ali Al Thani. On 3 September 1971, Qatar declared full independence from British protection, establishing itself as a sovereign state. Sheikh Hamad bin Khalifa Al Thani\'s reign (1995–2013) saw major political, economic, and social reforms, including municipal elections and the launch of Al Jazeera. Under the current Amir, Sheikh Tamim bin Hamad Al Thani, Qatar has invested heavily in education, healthcare, and global diplomacy — including hosting the FIFA World Cup 2022. Hukoomi\'s official history resources remain the authoritative reference for dates and milestones.',
    ),
    'kq_history_year_4000bce': l10nEntry(english: 'Ancient era'),
    'kq_history_year_1766': l10nEntry(english: '1766'),
    'kq_history_year_1971': l10nEntry(english: '1971'),
    'kq_history_year_1995': l10nEntry(english: '1995'),
    'kq_history_year_2022': l10nEntry(english: '2022'),
    'kq_history_milestone_pearl_title': l10nEntry(
      english: 'Pearl-diving era',
      arabic: 'عصر الغوص على اللؤلؤ',
    ),
    'kq_history_milestone_pearl_sub': l10nEntry(
      english: 'Coastal trade and pearling communities.',
    ),
    'kq_history_milestone_al_zubarah_title': l10nEntry(
      english: 'Al Zubarah',
      arabic: 'الزبارة',
    ),
    'kq_history_milestone_al_zubarah_sub': l10nEntry(
      english: 'UNESCO heritage trading town.',
    ),
    'kq_history_milestone_independence_title': l10nEntry(
      english: 'Independence',
      arabic: 'الاستقلال',
    ),
    'kq_history_milestone_independence_sub': l10nEntry(
      english: 'Sovereign State of Qatar declared.',
    ),
    'kq_history_milestone_modern_title': l10nEntry(
      english: 'Modern reforms',
      arabic: 'إصلاحات حديثة',
    ),
    'kq_history_milestone_modern_sub': l10nEntry(
      english: 'Accelerated development and opening up.',
    ),
    'kq_history_milestone_world_cup_title': l10nEntry(
      english: 'World Cup 2022',
      arabic: 'كأس العالم 2022',
    ),
    'kq_history_milestone_world_cup_sub': l10nEntry(
      english: 'Global spotlight on Qatar.',
    ),

    // ── Section 3: Leadership & Government ────────────────────────────────
    'kq_section_leadership_title': l10nEntry(
      english: 'Leadership & Government',
      arabic: 'القيادة والحكومة',
    ),
    'kq_section_leadership_teaser': l10nEntry(
      english: 'How Qatar is governed — Amir, Council of Ministers, Shura Council.',
      arabic: 'كيف تحكم قطر — الأمير ومجلس الوزراء والشورى.',
    ),
    'kq_section_leadership_body': l10nEntry(
      english:
          'Qatar is a hereditary constitutional monarchy. Executive authority rests with the Amir, who appoints the Prime Minister and Council of Ministers. The legislative branch includes the Shura Council, which debates laws and policy; municipal councils handle local affairs. Ministries such as Interior (MOI), Commerce (MOCI), and Administrative Development, Labour & Social Affairs (ADLSA) administer day-to-day governance. Hukoomi serves as the unified e-government portal for public services — visa queries, business registration, and civil documents. Qatar National Vision 2030 sets four pillars: human development, social development, economic development, and environmental development. Recent labour reforms — including the abolition of the no-objection certificate (NOC) for most job changes and improved exit permit rules — reflect ADLSA and MOI policy updates. For document renewals and residency status, use Visa & Documents rather than relying on this summary alone.',
    ),
    'kq_gov_milestone_vision2030': l10nEntry(
      english: 'Vision 2030 pillar delivery',
      arabic: 'تنفيذ ركائز رؤية 2030',
    ),
    'kq_gov_milestone_digital': l10nEntry(
      english: 'Digital government services',
      arabic: 'الخدمات الحكومية الرقمية',
    ),
    'kq_gov_milestone_labour_reform': l10nEntry(
      english: 'Labour law reforms',
      arabic: 'إصلاحات قانون العمل',
    ),
    'kq_leadership_callout_law_title': l10nEntry(
      english: 'Official legal framework',
      arabic: 'الإطار القانوني الرسمي',
    ),
    'kq_leadership_callout_law_body': l10nEntry(
      english:
          'Laws are published through the Official Gazette and Hukoomi. Always verify current rules on official portals before acting.',
    ),

    // ── Section 4: Economy ────────────────────────────────────────────────
    'kq_section_economy_title': l10nEntry(
      english: 'Economy',
      arabic: 'الاقتصاد',
    ),
    'kq_section_economy_teaser': l10nEntry(
      english: 'Hydrocarbons, diversification, and Vision 2030 targets.',
      arabic: 'الطاقة والتنويع وأهداف رؤية 2030.',
    ),
    'kq_section_economy_body': l10nEntry(
      english:
          'Qatar holds one of the world\'s largest natural-gas reserves, and LNG exports remain the primary revenue source. The Qatar National Vision 2030 strategy deliberately diversifies into finance, logistics, tourism, education, and technology to reduce hydrocarbon dependency. Free zones, Qatar Financial Centre, and Invest Qatar promote foreign investment. The country maintains a strong sovereign wealth position and invests globally through Qatar Investment Authority. Non-oil sectors — including construction, services, and retail — employ the majority of the workforce. MOCI regulates commercial activity and consumer protection. Macroeconomic indicators are published by the Planning and Statistics Authority and Qatar Central Bank. For personal finance — salaries, remittances, exchange rates, and cost benchmarks — use Money Hub; this section provides context only.',
    ),
    'kq_economy_milestone_non_hydrocarbon': l10nEntry(
      english: 'Non-hydrocarbon GDP share',
    ),
    'kq_economy_milestone_tourism': l10nEntry(
      english: 'Tourism sector growth',
    ),
    'kq_economy_milestone_sme': l10nEntry(
      english: 'SME contribution target',
    ),

    // ── Section 5: Cities & Regions ───────────────────────────────────────
    'kq_section_cities_title': l10nEntry(
      english: 'Cities & Regions',
      arabic: 'المدن والمناطق',
    ),
    'kq_section_cities_teaser': l10nEntry(
      english: 'Doha, Lusail, Al Wakrah, and key regions across the peninsula.',
      arabic: 'الدوحة ولوسيل والوكرة والمناطق الرئيسية.',
    ),
    'kq_section_cities_body': l10nEntry(
      english:
          'Doha is the capital and economic centre, home to West Bay\'s business district, Souq Waqif, the Corniche, and Hamad International Airport. Lusail, north of Doha, is a planned smart city that hosted World Cup venues and continues expanding residential and commercial zones. Al Wakrah and Al Khor serve as growing suburban hubs with ports and industrial activity. The inland area includes farming communities and desert landscapes. The north features Al Zubarah, a UNESCO World Heritage Site. Each municipality (baladiya) has local services coordinated through the Ministry of Municipality. Public transport includes the Doha Metro, Mowasalat buses, and Karwa taxis. For exploring neighbourhoods, attractions, and trip itineraries, use Trip Planner — this section orients you geographically only.',
    ),

    // ── Section 6: Culture & Society ──────────────────────────────────────
    'kq_section_culture_title': l10nEntry(
      english: 'Culture & Society',
      arabic: 'الثقافة والمجتمع',
    ),
    'kq_section_culture_teaser': l10nEntry(
      english: 'Traditions, dress, Ramadan, and daily social norms.',
      arabic: 'التقاليد واللباس ورمضان والأعراف اليومية.',
    ),
    'kq_section_culture_body': l10nEntry(
      english:
          'Qatari culture blends Bedouin heritage with modern Gulf urban life. Islam shapes daily rhythms — prayer times, Friday as the weekly holiday, and Ramadan fasting norms. Hospitality (diyafa) is central: guests are welcomed warmly. Traditional dress includes the thobe and ghutra for men and abaya for women; expatriates are expected to dress modestly in public spaces, especially malls, souqs, and government buildings. Public displays of affection are discouraged. Alcohol is restricted to licensed hotel venues for non-Muslims. During Ramadan, eating, drinking, or smoking in public during daylight hours is prohibited for everyone. Arabic is the official language; English is widely used in business. Museums such as the National Museum of Qatar and Msheireb celebrate heritage. For practical language help and prayer times, use the Arabic tools and Mosque & Prayer features linked below.',
    ),
    'kq_culture_callout_dress_title': l10nEntry(
      english: 'Dress code guidance',
      arabic: 'إرشادات اللباس',
    ),
    'kq_culture_callout_dress_body': l10nEntry(
      english:
          'Shoulders and knees should be covered in public areas. Swimwear is for pools and beaches only. Government offices may enforce stricter standards.',
    ),
    'kq_culture_callout_ramadan_title': l10nEntry(
      english: 'Ramadan etiquette',
      arabic: 'آداب رمضان',
    ),
    'kq_culture_callout_ramadan_body': l10nEntry(
      english:
          'Restaurants may operate with curtained areas. Working hours often shorten. Iftar timings shift daily — check local announcements.',
    ),

    // ── Section 7: Work in Qatar ──────────────────────────────────────────
    'kq_section_work_title': l10nEntry(
      english: 'Work in Qatar',
      arabic: 'العمل في قطر',
    ),
    'kq_section_work_teaser': l10nEntry(
      english: 'Employment rules, WPS, contracts, and worker protections.',
      arabic: 'قواعد التوظيف ونظام حماية الأجور والعقود.',
    ),
    'kq_section_work_body': l10nEntry(
      english:
          'Most expatriates work under employer sponsorship governed by Qatar Labour Law (Law No. 14 of 2004, as amended). Contracts must be registered with ADLSA. The Wage Protection System (WPS) requires salaries to be paid through approved bank channels — late or partial payment is a violation employers can be reported for. Maximum ordinary working hours, overtime rules, annual leave, end-of-service benefits, and termination notice periods are set by law. Recent reforms improved job mobility: most workers can change employers without an NOC after meeting notice requirements. Domestic workers have separate regulations. Heat-protection bans restrict outdoor work during summer midday hours. Disputes can be raised via ADLSA channels including SMS complaint service. For gratuity calculations, overtime checks, employer transfer readiness, and job search, use the linked EOSB, Employer Transfer, and Jobs tools — never estimate entitlements from this summary.',
    ),
    'kq_work_callout_wps_title': l10nEntry(
      english: 'Wage Protection System (WPS)',
      arabic: 'نظام حماية الأجور',
    ),
    'kq_work_callout_wps_body': l10nEntry(
      english:
          'If your salary is delayed or paid outside WPS, this may be a legal violation. Document payslips and report through official ADLSA/MoL channels.',
    ),

    // ── Section 8: Living in Qatar ────────────────────────────────────────
    'kq_section_living_title': l10nEntry(
      english: 'Living in Qatar',
      arabic: 'المعيشة في قطر',
    ),
    'kq_section_living_teaser': l10nEntry(
      english: 'Housing, utilities, neighbourhoods, and tenancy basics.',
      arabic: 'السكن والمرافق والأحياء وأساسيات الإيجار.',
    ),
    'kq_section_living_body': l10nEntry(
      english:
          'Most residents rent apartments or villas; ownership is limited for non-Qataris in designated areas. Rental contracts must be registered on the Ministry of Justice rental portal. Landlords typically require post-dated cheques and a security deposit. Utilities (Kahramaa electricity/water, Ooredoo/Vodafone telecom) are usually tenant responsibilities unless stated otherwise. Popular expat areas include The Pearl, West Bay, Al Sadd, Bin Mahmoud, and compounds near Education City or Industrial Area depending on budget and commute. Summer heat (May–September) is intense; indoor life and air conditioning dominate. Tap water is desalinated — many residents use filtered dispensers. Waste collection is municipal. For lease verification, deposit disputes, and condition reports, use the Tenancy Truth Engine; for finding listings, use Housing.',
    ),
    'kq_living_callout_tenancy_title': l10nEntry(
      english: 'Registered lease requirement',
      arabic: 'متطلب تسجيل عقد الإيجار',
    ),
    'kq_living_callout_tenancy_body': l10nEntry(
      english:
          'Unregistered leases weaken your legal standing in disputes. Always register on the official MoJ portal and keep stamped copies.',
    ),

    // ── Section 9: Money & Cost of Living ─────────────────────────────────
    'kq_section_money_title': l10nEntry(
      english: 'Money & Cost of Living',
      arabic: 'المال وتكلفة المعيشة',
    ),
    'kq_section_money_teaser': l10nEntry(
      english: 'QAR basics, typical expenses, and how to budget realistically.',
      arabic: 'أساسيات الريال والمصروفات النموذجية والميزانية.',
    ),
    'kq_section_money_body': l10nEntry(
      english:
          'The Qatari Riyal (QAR) is pegged at QR 3.64 per USD. There is no personal income tax on employment income. Major costs include rent (often the largest share), school fees if applicable, transport, utilities, and food. Groceries range from budget hypermarkets to premium imports. Petrol is subsidised and relatively inexpensive. Healthcare for residents typically requires employer-provided or private insurance. Remittances are a major outflow for many expatriates — compare corridor rates before sending. Qatar Central Bank oversees banking; ATMs and digital wallets are widely available. Cost levels are comparable to other Gulf capitals, with luxury and budget options in most categories. For personalised budgeting and cost-of-living calculations based on your salary and family size, use the Cost of Living calculator in Money Hub.',
    ),

    // ── Section 10: Residency & Documents ─────────────────────────────────
    'kq_section_residency_title': l10nEntry(
      english: 'Residency & Documents',
      arabic: 'الإقامة والمستندات',
    ),
    'kq_section_residency_teaser': l10nEntry(
      english: 'QID, visas, sponsorship, and keeping documents current.',
      arabic: 'البطاقة الشخصية والتأشيرات والكفالة وتحديث المستندات.',
    ),
    'kq_section_residency_body': l10nEntry(
      english:
          'Legal residency requires a valid Qatar ID (QID) linked to an employer or family sponsor. Work visas are arranged by sponsors before arrival; family visas allow dependents to join under qualifying salary thresholds. QID renewal and visa extensions are processed through MOI and Metrash/Hukoomi portals — standard validity, renewal and extension procedures apply. The temporary automatic extension measure for expired or nearly expired entry visas ended on 7 June 2026; confirm your current status and applicable procedure through MOI/Metrash. Exit and travel rules depend on worker category — not every resident must apply for an exit permit; use Raabta\'s Leaving Qatar checklist for category-specific guidance. Overstaying a visit or entry visa can result in a daily penalty — MOI guidance lists QAR 200 per day for relevant visit-visa overstays; check your exact status and amount through MOI/Metrash. Residence cancellation has a separate departure rule: current RAABTA guidance covers the reported 14-day period and QAR 10/day after the applicable departure period — do not confuse this with visit-visa overstay penalties. Passport validity, medical tests, and biometric enrolment are standard steps. Driving licences require conversion or testing depending on nationality. If your nationality has specific embassy resources (e.g. India, Nepal, Philippines), those appear highlighted below via Raabta\'s home-country support layer. Track expiry dates proactively — use the Visa & Documents Deadline Tracker for reminders rather than relying on memory.',
      arabic:
          'تتطلب الإقامة القانونية بطاقة شخصية قطرية (QID) سارية مرتبطة بكفيل عمل أو عائلة. تُرتّب تأشيرات العمل عبر الكفلاء قبل الوصول؛ وتسمح تأشيرات العائلة للمعالين بالانضمام وفق حدود الراتب. تجديد QID وتمديد التأشيرات عبر MOI وMetrash/Hukoomi — وتسري إجراءات الصلاحية والتجديد والتمديد المعتادة. انتهى التمديد التلقائي المؤقت للتأشيرات المنتهية أو شبه المنتهية في 7 يونيو 2026؛ تحقق من وضعك عبر MOI/Metrash. قواعد المغادرة تعتمد على فئة العامل — ليس على كل مقيم التقدم لتصريح خروج؛ استخدم checklist مغادرة قطر في Raabta. تجاوز تأشيرة زيارة/دخول قد يفرض غرامة يومية — MOI يذكر QAR 200/يوم لتجاوزات الزيارة ذات الصلة؛ تحقق من رصيدك عبر MOI/Metrash. إلغاء الإقامة له قاعدة مغادرة منفصلة: إرشاد RAABTA يغطي فترة 14 يوماً المبلغ عنها وQAR 10/يوم بعد الفترة — لا تخلطها بغرامات تجاوز الزيارة.',
    ),
    'kq_residency_callout_id_title': l10nEntry(
      english: 'Valid QID required',
      arabic: 'البطاقة الشخصية السارية مطلوبة',
    ),
    'kq_residency_callout_id_body': l10nEntry(
      english:
          'An expired QID affects banking, healthcare, travel, and legal status. Renew before expiry through MOI/Metrash.',
    ),

    // ── Section 11: Communities ───────────────────────────────────────────
    'kq_section_communities_title': l10nEntry(
      english: 'Communities',
      arabic: 'المجتمعات',
    ),
    'kq_section_communities_teaser': l10nEntry(
      english: 'Expatriate groups, events, and finding your network.',
      arabic: 'مجموعات المغتربين والفعاليات وبناء شبكتك.',
    ),
    'kq_section_communities_body': l10nEntry(
      english:
          'Qatar\'s population is predominantly expatriate, with large communities from South Asia, the Philippines, Egypt, the Levant, and elsewhere. National associations, sports clubs, religious centres, and school parent groups are common ways to connect. Hukoomi lists official community frameworks; many embassies host cultural events and consular services. Workplace and compound communities often organise social activities. Raabta\'s Community screen helps you discover groups, events, and discussions relevant to life in Qatar — this section explains the landscape only. Respect local laws on public gatherings and social media conduct. During national events and religious periods, community norms may shift — stay aware of official announcements.',
    ),
    'kq_section_alerts_safety_title': l10nEntry(
      english: 'Alerts & Safety',
      arabic: 'التنبيهات والسلامة',
    ),
    'kq_section_alerts_safety_teaser': l10nEntry(
      english:
          'National Early Warning alerts, emergency numbers, and calm disruption guidance.',
      arabic: 'تنبيهات الإنذار المبكر وأرقام الطوارئ وإرشادات هادئة.',
    ),
    'kq_section_alerts_safety_body': l10nEntry(
      english:
          'Phone-level alerts come from Qatar\'s authorities through the national Early Warning System — not from Raabta. This section links to the shared disruption guide for official channels, airport and airline checks (without live status), evacuation-scam warnings, and embassy portals that Raabta has verified. Step-by-step GCO response wording ships only after Raabta verifies the official publication.',
      arabic:
          'تصل تنبيهات الهاتف من الجهات القطرية عبر نظام الإنذار المبكر — وليس من Raabta. يربط هذا القسم بالدليل المشترك للقنوات الرسمية.',
    ),
    'kq_action_disruption_guide': l10nEntry(
      english: 'Open disruption & safety guide',
      arabic: 'فتح دليل الاضطراب والسلامة',
    ),

    // ── AI pre-seed prompts (Part F) ──────────────────────────────────────
    'kq_ai_prompt_qatar_at_glance': l10nEntry(
      english: 'Tell me more about living in Qatar as a new resident.',
    ),
    'kq_ai_prompt_history': l10nEntry(
      english: 'Explain key moments in Qatar\'s history in simple terms.',
    ),
    'kq_ai_prompt_leadership': l10nEntry(
      english: 'How does Qatar\'s government structure affect residents?',
    ),
    'kq_ai_prompt_economy': l10nEntry(
      english: 'What should workers know about Qatar\'s economy and jobs?',
    ),
    'kq_ai_prompt_cities': l10nEntry(
      english: 'Which area of Qatar is best for families on a budget?',
    ),
    'kq_ai_prompt_culture': l10nEntry(
      english: 'What cultural norms should I know before my first week in Qatar?',
    ),
    'kq_ai_prompt_work': l10nEntry(
      english: 'What are my basic labour rights as an employee in Qatar?',
    ),
    'kq_ai_prompt_living': l10nEntry(
      english: 'What should I check before signing a rental contract in Qatar?',
    ),
    'kq_ai_prompt_money': l10nEntry(
      english: 'Help me understand typical monthly costs in Doha.',
    ),
    'kq_ai_prompt_residency': l10nEntry(
      english: 'What documents do I need to keep current as a Qatar resident?',
    ),
    'kq_ai_prompt_communities': l10nEntry(
      english: 'How can I find community groups for my nationality in Qatar?',
    ),

    // ── Consolidated guides (formerly standalone tools) ─────────────────────
    'kq_source_cra': l10nEntry(
      english: 'CRA (Communications Regulatory Authority)',
      arabic: 'هيئة تنظيم الاتصالات',
    ),
    'kq_source_telecom_operators': l10nEntry(
      english: 'Ooredoo / Vodafone Qatar',
      arabic: 'Ooredoo / Vodafone قطر',
    ),
    'kq_action_leaving_qatar_fines': l10nEntry(
      english: 'Leaving Qatar — traffic fines checklist',
      arabic: 'مغادرة قطر — checklist مخالفات المرور',
    ),
    'kq_action_consumer_complaint': l10nEntry(
      english: 'MOCI consumer complaint guide',
      arabic: 'دليل شكاوى MOCI الاستهلاكية',
    ),
    'kq_action_ussd_codes': l10nEntry(
      english: 'Open interactive USSD code list',
      arabic: 'فتح قائمة USSD التفاعلية',
    ),
    'kq_action_driving_hub': l10nEntry(
      english: 'Open driving & traffic tools',
      arabic: 'فتح أدوات القيادة والمرور',
    ),
    'kq_section_buying_car_title': l10nEntry(
      english: 'Buying a Car',
      arabic: 'شراء سيارة',
    ),
    'kq_section_buying_car_teaser': l10nEntry(
      english: 'Private as-is sales, dealer rights, and Muroor transfer steps.',
      arabic: 'البيع الخاص as-is، حقوق الوكيل، وخطوات النقل في Muroor.',
    ),
    'kq_section_buying_car_body': l10nEntry(
      english:
          'Plain-language guide for private and dealer purchases — informational only. Raabta does not verify any dealer, vehicle, or price.\n\nDealer sales typically come with warranty protection, and MOCI (Law No. 8 of 2008) has real enforcement power to back consumer rights. Vendor-issued warranties must be legally valid.\n\nBefore you buy: check vehicle history through the Metrash app; confirm outstanding traffic fines — typically cleared by the seller before transfer or deducted from the agreed price.\n\nOwnership transfer at Traffic Department (Muroor): both buyer and seller must visit together with both parties\' QIDs, the original Istimara, valid insurance for the new owner, and a vehicle inspection certificate. Transfer fee is approximately QAR 50 and is usually completed in one visit.',
      arabic:
          'دليل مبسّط للشراء الخاص والوكيل — للمعلومات فقط. Raabta لا تتحقق من أي dealer أو مركبة أو سعر.\n\nمبيعات الوكيل عادة مع warranty وMOCI (قانون 8/2008) لديه enforcement حقيقي.\n\nقبل الشراء: تاريخ المركبة عبر Metrash؛ مخالفات المرور outstanding.\n\nنقل الملكية في Muroor: الطرفان معاً + QID + Istimara + تأمين + فحص. الرسوم ~50 ر.ق.',
    ),
    'kq_buying_car_callout_as_is_title': l10nEntry(
      english: 'Private sales are "as-is" — no legal recourse after purchase',
      arabic: 'البيع الخاص "كما هو" — لا recourse قانوني بعد الشراء',
    ),
    'kq_buying_car_callout_as_is_body': l10nEntry(
      english:
          'Private used-car sales in Qatar are typically sold "as-is". If something turns out to be wrong after you buy, you generally have no legal remedy against the seller. Your real protection before a private purchase is a professional pre-purchase inspection (mechanic-conducted) — not any legal fix after the fact.',
      arabic:
          'بيع السيارات المستعملة بين الأفراد عادة "كما هو". إن ظهر عيب بعد الشراء، غالباً لا recourse قانوني ضد البائع. حمايتك: فحص pre-purchase احترافي قبل الشراء.',
    ),
    'kq_section_freelance_visa_title': l10nEntry(
      english: 'Freelance Visa Facts',
      arabic: 'حقائق تأشيرة العمل الحر',
    ),
    'kq_section_freelance_visa_teaser': l10nEntry(
      english: 'No official "freelance visa" — real pathways and misinformation risks.',
      arabic: 'لا "تأشيرة عمل حر" رسمية — مسارات حقيقية ومخاطر misinformation.',
    ),
    'kq_section_freelance_visa_body': l10nEntry(
      english:
          'Independent work is legal in Qatar, but only through specific recognized pathways — not through a single simple application that some websites describe online.\n\nMany websites describe a "Qatar Freelance Visa" with specific steps and fees. This content is often inaccurate or describes something that does not exist in that form.\n\nReal routes include company registration via MOCI, the Qatar Financial Centre (QFC), or a Free Zone authority, and government-run residency and self-sponsorship programs. Program availability and eligibility change — check what is currently open directly with the administering body.\n\nJusour (Qatar Manpower Solutions Company) administers manpower and residency programs. Contact Jusour directly through official channels — do not rely on unofficial websites or intermediaries. Email: info@jusour.qa · Phone: +974 44011044.\n\nBefore paying anyone or committing to any independent-work arrangement, verify the pathway directly with the official administering body or a licensed legal or business-setup consultant.',
      arabic:
          'العمل المستقل قانوني في قطر عبر مسارات معترف بها فقط — وليس عبر طلب واحد بسيط كما تصف بعض المواقع.\n\nمسارات حقيقية: MOCI، QFC، منطقة حرة، برامج إقامة حكومية. تحقق مباشرة مع الجهة المختصة.\n\nجسور: info@jusour.qa · +974 44011044.',
    ),
    'kq_freelance_visa_callout_title': l10nEntry(
      english: 'There is no Qatar visa officially named a "freelance visa."',
      arabic: 'لا توجد في قطر تأشيرة رسمية باسم "تأشيرة العمل الحر".',
    ),
    'kq_freelance_visa_callout_body': l10nEntry(
      english:
          'Independent work is legal in Qatar, but only through specific recognized pathways — not through a single simple application that some websites describe online.',
      arabic:
          'العمل المستقل قانوني في قطر، لكن فقط عبر مسارات معترف بها — وليس عبر طلب واحد بسيط كما تصف بعض المواقع.',
    ),
    'kq_freelance_visa_risk_title': l10nEntry(
      english: 'Informal arrangements carry real risk',
      arabic: 'الترتيبات غير الرسمية تحمل مخاطر حقيقية',
    ),
    'kq_freelance_visa_risk_body': l10nEntry(
      english:
          'Some people work through informal sponsorship arrangements without a genuine employment relationship. This is not a recognized legal status, and people using such arrangements have faced fines, detention during routine checks, and visa cancellation.',
      arabic:
          'بعض الناس يعملون عبر ترتيبات كفالة غير رسمية دون علاقة عمل حقيقية — ليس وضعاً قانونياً معترفاً به، وقد واجهوا غرامات واحتجازاً وإلغاء تأشيرة.',
    ),
    'kq_section_telecom_title': l10nEntry(
      english: 'Sign or Cancel Telecom',
      arabic: 'توقيع أو إلغاء الاتصالات',
    ),
    'kq_section_telecom_teaser': l10nEntry(
      english: 'Ooredoo/Vodafone contract traps, minimum periods, and CRA escalation.',
      arabic: 'فخاخ عقود Ooredoo/Vodafone، فترات الحد الأدنى، والتصعيد إلى CRA.',
    ),
    'kq_section_telecom_body': l10nEntry(
      english:
          'Plain-language decoder for Ooredoo and Vodafone contract traps — minimum periods, early termination, and when you can escalate to CRA. Raabta does not access your live account or tariff. Figures come from published provider terms — confirm your specific plan directly with your provider.\n\nOoredoo: a price increase normally gives you 15 days to cancel penalty-free — but increases from international roaming rates, government-imposed fees/taxes, or regulatory-framework changes do NOT trigger that cancellation right.\n\nVodafone: one-time promotional offers (e.g. "free months") are tied to a specific Kahramaa ID. Moving apartments, or reconnecting at a new address, does not carry the promotion over.\n\nMinimum service periods and early-termination fees vary by plan type. Fibre/broadband, bundled equipment, and GigaTV device terms are the focus of this guide — do not assume mobile-only examples apply to standalone SIM plans without checking your contract.',
      arabic:
          'دليل مبسّط لعقود Ooredoo و Vodafone — فترات الحد الأدنى، الإنهاء المبكر، والتصعيد إلى CRA. Raabta لا تصل إلى حسابك المباشر.\n\nOoredoo: رفع السعر → 15 يوماً للإلغاء دون غرامة — مع استثناءات roaming والرسوم الحكومية.\n\nVodafone: العروض مرتبطة بـ Kahramaa ID محدد — الانتقال لا ينقل العرض.',
    ),
    'kq_telecom_callout_scope_title': l10nEntry(
      english: 'Confirm your plan type before acting',
      arabic: 'أكّد نوع خطتك قبل التصرف',
    ),
    'kq_telecom_callout_scope_body': l10nEntry(
      english:
          'Scope: this guide focuses on Fibre/broadband, bundled equipment, and GigaTV device terms where confirmed in research. Mobile-only SIM early-termination fees were not confirmed — do not assume examples apply to a standalone mobile plan.',
      arabic:
          'النطاق: Fibre/الإنترنت والمعدات المجمّعة وGigaTV — رسوم إنهاء SIM mobile-only لم تُؤكَّد.',
    ),
    'kq_section_ussd_title': l10nEntry(
      english: 'SIM USSD Codes',
      arabic: 'رموز USSD',
    ),
    'kq_section_ussd_teaser': l10nEntry(
      english: 'Ooredoo & Vodafone Qatar balance, data, and recharge codes.',
      arabic: 'رموز Ooredoo و Vodafone قطر للرصيد والبيانات وإعادة الشحن.',
    ),
    'kq_section_ussd_body': l10nEntry(
      english:
          'Quick reference for Ooredoo and Vodafone Qatar USSD codes — balance checks, data balance, recharge, package activation, customer service, and roaming menus. Codes can change; verify on ooredoo.qa or vf.qa if a code stops working.\n\nUse the interactive USSD tool linked below to search, copy, or dial codes directly from your phone.',
      arabic:
          'مرجع سريع لرموز USSD لـ Ooredoo و Vodafone قطر — الرصيد، البيانات، إعادة الشحن، والتفعيل. قد تتغير الرموز — تحقق من موقع المشغل.\n\nاستخدم أداة USSD التفاعلية أدناه للبحث والنسخ والاتصال.',
    ),
    'kq_section_driving_title': l10nEntry(
      english: 'Driving & Traffic',
      arabic: 'القيادة والمرور',
    ),
    'kq_section_driving_teaser': l10nEntry(
      english: 'MOI fee reference, fine-status guidance, and theory practice.',
      arabic: 'مرجع رسوم MOI، إرشاد حالة الغرامات، وممارسة النظرية.',
    ),
    'kq_section_driving_body': l10nEntry(
      english:
          'MOI traffic reference and practice tools — Raabta does not show live Metrash fine status. Use the official MOI / Metrash portal to confirm your own fines and licence status.\n\nThe linked driving hub includes: a fee calculator for licence renewal and Istimara reference costs; a guide on how to check fine status via Metrash (not an in-app lookup); an unofficial theory quiz for practice (not MOI certified); and a link to track licence renewal dates in the Visa & Documents Deadline Tracker.',
      arabic:
          'مرجع مرور MOI وأدوات تدريب — Raabta لا تعرض حالة الغرامات المباشرة من Metrash. أكّد عبر بوابة MOI / Metrash.\n\nالأدوات المرتبطة: حاسبة الرسوم، دليل فحص الغرامات، اختبار نظرية غير رسمي، وتتبع مواعيد التجديد.',
    ),

    // ── Life Moments (lens over existing content) ─────────────────────────
    'kq_moments_chip_heading': l10nEntry(
      english: 'What\'s happening in your life?',
      arabic: 'ما الذي يحدث في حياتك؟',
    ),
    'kq_moment_all_topics_title': l10nEntry(
      english: 'All topics',
      arabic: 'كل المواضيع',
    ),
    'kq_moment_just_arrived_title': l10nEntry(
      english: 'Just arrived',
      arabic: 'وصلت للتو',
    ),
    'kq_moment_just_arrived_intro': l10nEntry(
      english:
          'Settle the essentials calmly — documents, daily life, and the tools Raabta already offers.',
    ),
    'kq_moment_starting_job_title': l10nEntry(
      english: 'Starting or changing a job',
      arabic: 'بدء أو تغيير عمل',
    ),
    'kq_moment_starting_job_intro': l10nEntry(
      english:
          'Understand work rules, verify employers, and use Raabta\'s calculators before you sign.',
    ),
    'kq_moment_bringing_family_title': l10nEntry(
      english: 'Bringing family',
      arabic: 'إحضار العائلة',
    ),
    'kq_moment_bringing_family_intro': l10nEntry(
      english:
          'Family visa, housing, insurance, and community resources — one step at a time.',
    ),
    'kq_moment_hosting_visitors_title': l10nEntry(
      english: 'Hosting visitors',
      arabic: 'استضافة الزوار',
      urdu: 'مہمانوں کی میزبانی',
    ),
    'kq_moment_hosting_visitors_intro': l10nEntry(
      english:
          'You are sponsoring relatives for a family visit to Qatar—not the same as bringing family to live here on a residence visa. Eligibility, documents, and fees are set by MOI and can change. Raabta does not apply for visas or verify sponsor eligibility. Confirm everything on official MOI and MoPH channels.',
      arabic:
          'أنت ترعى أقارباً لزيارة عائلية في قطر — ليست نفس إحضار العائلة للإقامة. الأهلية والمستندات والرسوم من وزارة الداخلية وقد تتغير. رابطة لا تقدّم التأشيرات ولا تتحقق من أهلية الكفيل.',
      urdu:
          'آپ قطر میں family visit کے لیے رشتہ داروں کو sponsor کر رہے ہیں — residence visa سے الگ۔ اہلیت MOI طے کرتی ہے۔ رابتہ visa apply یا sponsor eligibility verify نہیں کرتا۔',
    ),
    'kq_moment_label_official': l10nEntry(
      english: 'Official link',
      arabic: 'رابط رسمي',
      urdu: 'سرکاری لنک',
    ),
    'kq_moment_official_needs_internet': l10nEntry(
      english: 'Opening official links needs internet.',
      arabic: 'فتح الروابط الرسمية يحتاج اتصالاً بالإنترنت.',
      urdu: 'سرکاری لنکس کے لیے انٹرنیٹ درکار ہے۔',
    ),
    'kq_hosting_link_moi_service_title': l10nEntry(
      english: 'MOI family visit service',
      arabic: 'خدمة زيارة العائلة — وزارة الداخلية',
      urdu: 'MOI family visit سروس',
    ),
    'kq_hosting_link_moi_service_summary': l10nEntry(
      english:
          'Current MOI requirements, permitted relationships, Metrash2 steps, and fees as published by MOI.',
      arabic:
          'متطلبات وزارة الداخلية الحالية وMetrash2 والرسوم كما تنشرها الوزارة.',
      urdu: 'MOI کی موجودہ family visit ضروریات اور Metrash2 — سرکاری شائع شدہ معلومات.',
    ),
    'kq_hosting_link_moi_policy_title': l10nEntry(
      english: 'MOI announcement (5 Dec 2023)',
      arabic: 'إعلان وزارة الداخلية (5 ديسمبر 2023)',
      urdu: 'MOI اعلان (5 Dec 2023)',
    ),
    'kq_hosting_link_moi_policy_summary': l10nEntry(
      english:
          'Historical MOI news separating family visit rules from family residence sponsorship rules—confirm current rules on MOI services.',
      arabic:
          'خبر تاريخية تفصل زيارة العائلة عن إقامة العائلة — راجع القواعد الحالية على خدمات الوزارة.',
      urdu: 'تاریخی MOI خبر — visit بمقابلہ residence — موجودہ قواعد MOI پر چیک کریں۔',
    ),
    'kq_hosting_link_moph_qhis_title': l10nEntry(
      english: 'MoPH visitor insurance portal (QHIS)',
      arabic: 'بوابة تأمين الزوار — وزارة الصحة (QHIS)',
      urdu: 'MoPH visitor insurance پورٹل (QHIS)',
    ),
    'kq_hosting_link_moph_qhis_summary': l10nEntry(
      english:
          'Official MoPH portal signpost for visitor health insurance. Raabta has not verified current products, coverage limits, or purchase details—check on MoPH.',
      arabic:
          'إشارة رسمية لبوابة تأمين الزوار. رابطة لم تتحقق من المنتجات أو حدود التغطية الحالية.',
      urdu: 'سرکاری MoPH visitor insurance پورٹل۔ رابتہ نے موجودہ products/coverage verify نہیں کی — MoPH پر دیکھیں۔',
    ),
    'kq_hosting_route_visa_summary': l10nEntry(
      english:
          'Track your own document deadlines; confirm visa status on Metrash or MOI—not in Raabta.',
      arabic: 'تتبع مواعيد مستنداتك؛ تحقق من التأشيرة على Metrash أو MOI.',
      urdu: 'اپنے deadlines ٹrack کریں؛ visa status Metrash/MOI پر — رابتہ میں نہیں۔',
    ),
    'kq_hosting_route_health_insurance_summary': l10nEntry(
      english:
          'Resident and employer mandatory insurance guidance—not visitor-policy purchase.',
      arabic: 'إرشاد التأمين الإلزامي للمقيمين والعمل — ليس شراء تأمين الزائر.',
      urdu: 'Resident/employer insurance رہنمائی — visitor policy خریداری نہیں۔',
    ),
    'kq_source_moph': l10nEntry(
      english: 'Ministry of Public Health (MoPH)',
      arabic: 'وزارة الصحة العامة',
      urdu: 'وزارتِ صحت عمومی (MoPH)',
    ),
    'kq_moment_setting_up_home_title': l10nEntry(
      english: 'Setting up home & daily life',
      arabic: 'تأسيس المنزل والحياة اليومية',
    ),
    'kq_moment_setting_up_home_intro': l10nEntry(
      english:
          'Home, money, telecom, transport, and bills — linked tools, not new advice.',
    ),
    'kq_moment_visiting_title': l10nEntry(
      english: 'Visiting Qatar',
      arabic: 'زيارة قطر',
    ),
    'kq_moment_visiting_intro': l10nEntry(
      english:
          'Orientation, culture, and trip tools for a short stay — stay aware via official channels.',
    ),
    'kq_moment_going_home_title': l10nEntry(
      english: 'Going home',
      arabic: 'العودة للوطن',
    ),
    'kq_moment_going_home_intro': l10nEntry(
      english:
          'Plan departure, entitlements, and return support using Raabta\'s leaving and welcome flows.',
    ),
    'kq_moment_something_wrong_title': l10nEntry(
      english: 'When something goes wrong',
      arabic: 'عندما يحدث خطأ',
    ),
    'kq_moment_something_wrong_intro': l10nEntry(
      english:
          'Scams, disputes, and safety signposts — verify through official portals, not rumours.',
    ),
    'kq_moment_label_read': l10nEntry(
      english: 'Read',
      arabic: 'اقرأ',
    ),
    'kq_moment_label_tool': l10nEntry(
      english: 'Open tool',
      arabic: 'افتح الأداة',
    ),

    // Route / tool labels for moment items
    'kq_route_visa_title': l10nEntry(
      english: 'Visa & Documents',
      arabic: 'التأشيرة والمستندات',
    ),
    'kq_route_visa_summary': l10nEntry(
      english: 'Guides and the Deadline Tracker for your own dates.',
    ),
    'kq_route_before_you_sign_title': l10nEntry(
      english: 'Before You Sign',
      arabic: 'قبل التوقيع',
    ),
    'kq_route_before_you_sign_summary': l10nEntry(
      english: 'Home-country checklist before you accept a contract.',
    ),
    'kq_route_employer_track_title': l10nEntry(
      english: 'Employer Track Record',
    ),
    'kq_route_employer_track_summary': l10nEntry(
      english: 'Check reported employer patterns before you commit.',
    ),
    'kq_route_agency_verify_title': l10nEntry(
      english: 'Agency Verification',
    ),
    'kq_route_agency_verify_summary': l10nEntry(
      english: 'Verify recruitment agencies against published lists.',
    ),
    'kq_route_sponsorship_transfer_summary': l10nEntry(
      english: 'Understand transfer steps and official portals.',
    ),
    'kq_route_eosb_title': l10nEntry(
      english: 'End-of-Service Benefits',
    ),
    'kq_route_eosb_summary': l10nEntry(
      english: 'Calculate gratuity from your own employment inputs.',
    ),
    'kq_route_family_visa_guide_title': l10nEntry(
      english: 'Family visa step-guide',
    ),
    'kq_route_family_visa_guide_summary': l10nEntry(
      english: 'Official steps linked from Visa & Documents.',
    ),
    'kq_route_health_insurance_title': l10nEntry(
      english: 'Health Insurance Truth Engine',
    ),
    'kq_route_health_insurance_summary': l10nEntry(
      english: 'Check coverage rules against your situation.',
    ),
    'kq_route_tenancy_title': l10nEntry(
      english: 'Tenancy Truth Engine',
    ),
    'kq_route_tenancy_summary': l10nEntry(
      english: 'Compare lease terms with Qatar tenancy law.',
    ),
    'kq_route_money_summary': l10nEntry(
      english: 'Transfers, budgets, and cost-of-living tools.',
    ),
    'kq_route_bill_tracker_title': l10nEntry(
      english: 'Bill Tracker',
    ),
    'kq_route_bill_tracker_summary': l10nEntry(
      english: 'Track recurring bills you enter yourself.',
    ),
    'kq_route_daily_phrases_title': l10nEntry(
      english: 'Arabic Phrases',
    ),
    'kq_route_daily_phrases_summary': l10nEntry(
      english: 'Everyday phrases for errands and greetings.',
    ),
    'kq_route_leaving_qatar_title': l10nEntry(
      english: 'Leaving Qatar',
    ),
    'kq_route_leaving_qatar_summary': l10nEntry(
      english: 'Departure timeline, EOSB links, and home-country support.',
    ),
    'kq_route_concierge_title': l10nEntry(
      english: '90-day newcomer journey',
    ),
    'kq_route_concierge_summary': l10nEntry(
      english: 'Open the existing Concierge milestones on Home.',
    ),
    'kq_route_trip_planner_title': l10nEntry(
      english: 'Trip Planner',
    ),
    'kq_route_trip_planner_summary': l10nEntry(
      english: 'Build itineraries and local tips for your visit.',
    ),
    'kq_route_prayer_mosque_title': l10nEntry(
      english: 'Mosque & Prayer',
    ),
    'kq_route_prayer_mosque_summary': l10nEntry(
      english: 'Prayer times, Qibla, and nearby mosques.',
    ),
    'kq_route_welcome_home_title': l10nEntry(
      english: 'Welcome Home',
    ),
    'kq_route_welcome_home_summary': l10nEntry(
      english: 'Returnee programmes where Raabta has verified sources.',
    ),
    'kq_route_disruption_summary': l10nEntry(
      english: 'Calm disruption readiness — official links only.',
    ),
    'kq_route_scam_shield_title': l10nEntry(
      english: 'ScamShield',
    ),
    'kq_route_scam_shield_summary': l10nEntry(
      english: 'Report and learn about common scams in Qatar.',
    ),
    'kq_route_consumer_complaint_summary': l10nEntry(
      english: 'MOCI consumer complaint pathways.',
    ),

    // Next Step card
    'kq_next_step_heading': l10nEntry(
      english: 'Next step',
      arabic: 'الخطوة التالية',
    ),
    'kq_next_step_dismiss': l10nEntry(
      english: 'Hide for 7 days',
      arabic: 'إخفاء لمدة 7 أيام',
    ),
    'kq_next_step_deadline_expired': l10nEntry(
      english: '{document} needs attention',
    ),
    'kq_next_step_deadline_soon': l10nEntry(
      english: '{document} is coming up for renewal',
    ),
    'kq_next_step_moment_item': l10nEntry(
      english: 'Next: {title}',
    ),
    'kq_next_step_continue': l10nEntry(
      english: 'Continue: {title}',
    ),
    'kq_next_step_fallback_tracker': l10nEntry(
      english: 'Set up your Deadline Tracker with your own dates',
    ),
    'kq_next_step_action_open_tracker': l10nEntry(
      english: 'Open Visa & Documents',
    ),
    'kq_next_step_action_open': l10nEntry(
      english: 'Open',
      arabic: 'افتح',
    ),
    'kq_next_step_action_setup_tracker': l10nEntry(
      english: 'Set up tracker',
    ),
  };
}
