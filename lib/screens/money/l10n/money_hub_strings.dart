/// Money Hub — dashboard, hero converter, tools grid, branches & markets tabs.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

abstract final class MoneyHubStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  /// Longer copy, disclaimers, and descriptions pending native review for ML/NE/BN/TA/TL.
  static const keysNeedingProfessionalReview = <String>{
    'tool_gold_intelligence_subtitle',
    'tool_send_home_subtitle',
    'tool_cost_of_living_subtitle',
    'tool_personal_budget_subtitle',
    'tool_zakat_subtitle',
    'hero_approximate_check_connection',
    'hero_indicative_corridor_preview',
    'hero_send_money_home_title',
    'dashboard_finance_tools_subtitle',
    'dashboard_wellness_subtitle',
    'branches_hero_subtitle',
    'branches_quick_access_subtitle',
    'branches_exchange_companies_subtitle',
    'branches_branch_finder_subtitle',
    'branches_map_view_subtitle',
    'branches_favorites_subtitle',
    'markets_enter_amount_hint',
    'markets_rates_disclaimer',
    'live_chip_updated_just_now',
    'live_chip_updated_minutes',
    'live_chip_updated_hours',
    'live_chip_updated_datetime',
    'markets_check_connection_retry',
    'shell_subtitle',
    'shell_search_hint',
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
    required Map<String, String> params,
  }) {
    var value = t(key, locale);
    params.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // ── Shell (T1) ────────────────────────────────────────────────────────────
    'shell_title': l10nEntry(
      english: 'Money Hub',
      arabic: 'مركز المال',
      hindi: 'मनी हब',
      urdu: 'منی ہب',
      bengali: 'মানি হাব',
      filipino: 'Money Hub',
    ),
    'shell_subtitle': l10nEntry(
      english: 'Rates, tools and branches.',
      arabic: 'الأسعار والأدوات والفروع.',
      hindi: 'दरें, उपकरण और शाखाएँ।',
      urdu: 'شرحیں، ٹولز اور شاخیں۔',
      bengali: 'হার, টুলস ও শাখাসমূহ।',
      filipino: 'Mga rate, tool at sangay.',
    ),
    'shell_search_hint': l10nEntry(
      english: 'Search money hub…',
      arabic: 'ابحث في مركز المال…',
      hindi: 'मनी हब खोजें…',
      urdu: 'منی ہب تلاش کریں…',
      bengali: 'মানি হাবে খুঁজুন…',
      filipino: 'Maghanap sa Money Hub…',
    ),
    'shell_tab_dashboard': l10nEntry(
      english: 'Dashboard',
      arabic: 'لوحة التحكم',
      hindi: 'डैशबोर्ड',
      urdu: 'ڈیش بورڈ',
      bengali: 'ড্যাশবোর্ড',
      filipino: 'Dashboard',
    ),
    'shell_tab_markets': l10nEntry(
      english: 'Markets',
      arabic: 'الأسواق',
      hindi: 'बाज़ार',
      urdu: 'مارکیٹس',
      bengali: 'বাজার',
      filipino: 'Markets',
    ),
    'shell_tab_branches': l10nEntry(
      english: 'Branches',
      arabic: 'الفروع',
      hindi: 'शाखाएँ',
      urdu: 'شاخیں',
      bengali: 'শাখা',
      filipino: 'Branches',
    ),

    // ── Tools grid ────────────────────────────────────────────────────────────
    'tool_gold_intelligence_title': l10nEntry(
      english: 'Gold Intelligence',
      arabic: 'ذكاء الذهب',
      hindi: 'Gold Intelligence',
      urdu: 'Gold Intelligence',
    ),
    'tool_gold_intelligence_subtitle': l10nEntry(
      english: 'Live 24K spot & calculator',
      arabic: 'سعر الذهب 24K المباشر والحاسبة',
      hindi: 'Live 24K spot & calculator',
      urdu: 'Live 24K spot & calculator',
    ),
    'tool_send_home_title': l10nEntry(
      english: 'Send Home',
      arabic: 'أرسل للوطن',
      hindi: 'घर भेजें',
      urdu: 'گھر بھیجیں',
    ),
    /// Kit hero headline ( DomainCard / landing ).
    'hero_send_money_home_title': l10nEntry(
      english: 'Send money home',
      arabic: 'أرسل المال إلى الوطن',
      hindi: 'पैसा घर भेजें',
      urdu: 'رقم گھر بھیجیں',
      bengali: 'টাকা বাড়িতে পাঠান',
      filipino: 'Magpadala ng pera sa bayan',
    ),
    'tool_send_home_subtitle': l10nEntry(
      english: 'Hidden markup vs mid-market truth',
      arabic: 'الهامش المخفي مقابل سعر السوق',
      hindi: 'Hidden markup vs mid-market truth',
      urdu: 'Hidden markup vs mid-market truth',
    ),
    'tool_cost_of_living_title': l10nEntry(
      english: 'Cost of Living',
      arabic: 'تكلفة المعيشة',
      hindi: 'जीवन योग्यता',
      urdu: 'معاش کا خرچ',
    ),
    'tool_cost_of_living_subtitle': l10nEntry(
      english: 'Official CPI & your bills',
      arabic: 'مؤشر CPI الرسمي وفواتيرك',
      hindi: 'Official CPI & your bills',
      urdu: 'Official CPI & your bills',
    ),
    'tool_personal_budget_title': l10nEntry(
      english: 'Personal Budget',
      arabic: 'الميزانية الشخصية',
      hindi: 'व्यक्तिगत बजट',
      urdu: 'ذاتی بجٹ',
    ),
    'tool_personal_budget_subtitle': l10nEntry(
      english: 'Salary pressure & savings',
      arabic: 'ضغط الراتب والادخار',
      hindi: 'Salary pressure & savings',
      urdu: 'Salary pressure & savings',
    ),
    'tool_zakat_subtitle': l10nEntry(
      english: 'Annual Zakat estimate',
      arabic: 'تقدير الزكاة السنوي',
      hindi: 'Annual Zakat estimate',
      urdu: 'Annual Zakat estimate',
    ),

    // ── Hero converter ────────────────────────────────────────────────────────
    'hero_live_indicative_rates': l10nEntry(
      english: 'Live indicative rates',
      arabic: 'أسعار إرشادية مباشرة',
      hindi: 'Live indicative rates',
      urdu: 'Live indicative rates',
    ),
    'hero_indicative_rates': l10nEntry(
      english: 'Indicative rates',
      arabic: 'أسعار إرشادية',
      hindi: 'Indicative rates',
      urdu: 'Indicative rates',
    ),
    'hero_approximate_check_connection': l10nEntry(
      english: 'Approximate — check connection',
      arabic: 'تقريبي — تحقق من الاتصال',
      hindi: 'Approximate — check connection',
      urdu: 'Approximate — check connection',
    ),
    'hero_convert_and_send': l10nEntry(
      english: 'Convert & send',
      arabic: 'حوّل وأرسل',
      hindi: 'Convert & send',
      urdu: 'Convert & send',
    ),
    'hero_indicative_corridor_preview': l10nEntry(
      english: 'Indicative corridor preview',
      arabic: 'معاينة إرشادية للممر',
      hindi: 'Indicative corridor preview',
      urdu: 'Indicative corridor preview',
    ),
    'hero_one_qar_to_code': l10nEntry(
      english: '1 QAR → {code}',
      arabic: '1 ر.ق → {code}',
      hindi: '1 QAR → {code}',
      urdu: '1 QAR → {code}',
    ),
    'hero_rate_source': l10nEntry(
      english: 'Rate source',
      arabic: 'مصدر السعر',
      hindi: 'Rate source',
      urdu: 'Rate source',
    ),
    'hero_live': l10nEntry(
      english: 'Live',
      arabic: 'مباشر',
      hindi: 'Live',
      urdu: 'Live',
    ),
    'hero_cached': l10nEntry(
      english: 'Cached',
      arabic: 'مخزّن',
      hindi: 'Cached',
      urdu: 'Cached',
    ),
    'hero_you_send': l10nEntry(
      english: 'You send',
      arabic: 'ترسل',
      hindi: 'You send',
      urdu: 'You send',
    ),
    'hero_recipient_gets': l10nEntry(
      english: 'Recipient gets',
      arabic: 'المستلم يحصل على',
      hindi: 'Recipient gets',
      urdu: 'Recipient gets',
    ),
    'hero_compare_exchange_houses': l10nEntry(
      english: 'Compare exchange houses',
      arabic: 'قارن مكاتب الصرافة',
      hindi: 'Compare exchange houses',
      urdu: 'Compare exchange houses',
    ),
    /// [MoneyLiveChip] relative freshness (same thresholds as legacy English helper).
    'live_chip_updated_just_now': l10nEntry(
      english: 'Updated just now',
      arabic: 'تم التحديث الآن',
      hindi: 'अभी अपडेट किया गया',
      urdu: 'ابھی اپ ڈیٹ ہوا',
      malayalam: 'ഇപ്പോൾ അപ്ഡേറ്റ് ചെയ്തു',
      nepali: 'अहिले अपडेट गरियो',
      bengali: 'এইমাত্র আপডেট হয়েছে',
      tamil: 'இப்போது புதுப்பிக்கப்பட்டது',
      filipino: 'Ini-update ngayon lang',
    ),
    'live_chip_updated_minutes': l10nEntry(
      english: 'Updated {minutes}m ago',
      arabic: 'تم التحديث منذ {minutes} د',
      hindi: '{minutes} मिनट पहले अपडेट',
      urdu: '{minutes} منٹ پہلے اپ ڈیٹ',
      malayalam: '{minutes} മിനിറ്റ് മുമ്പ് അപ്ഡേറ്റ്',
      nepali: '{minutes} मिनेट अघि अपडेट',
      bengali: '{minutes} মিনিট আগে আপডেট',
      tamil: '{minutes} நிமி. முன் புதுப்பிக்கப்பட்டது',
      filipino: 'In-update {minutes}m ang nakalipas',
    ),
    'live_chip_updated_hours': l10nEntry(
      english: 'Updated {hours}h ago',
      arabic: 'تم التحديث منذ {hours} س',
      hindi: '{hours} घंटे पहले अपडेट',
      urdu: '{hours} گھنٹے پہلے اپ ڈیٹ',
      malayalam: '{hours} മണിക്കൂർ മുമ്പ് അപ്ഡേറ്റ്',
      nepali: '{hours} घण्टा अघि अपडेट',
      bengali: '{hours} ঘণ্টা আগে আপডেট',
      tamil: '{hours} மணி. முன் புதுப்பிக்கப்பட்டது',
      filipino: 'In-update {hours} oras ang nakalipas',
    ),
    'live_chip_updated_datetime': l10nEntry(
      english: 'Updated {day}/{month} · {hour}:{minute}',
      arabic: 'تم التحديث {day}/{month} · {hour}:{minute}',
      hindi: 'अपडेट: {day}/{month} · {hour}:{minute}',
      urdu: 'اپ ڈیٹ: {day}/{month} · {hour}:{minute}',
      malayalam: 'അപ്ഡേറ്റ്: {day}/{month} · {hour}:{minute}',
      nepali: 'अपडेट: {day}/{month} · {hour}:{minute}',
      bengali: 'আপডেট: {day}/{month} · {hour}:{minute}',
      tamil: 'புதுப்பிப்பு: {day}/{month} · {hour}:{minute}',
      filipino: 'Na-update: {day}/{month} · {hour}:{minute}',
    ),
    /// When history is not a guaranteed 7-day window (synthetic/backend unknown).
    'hero_rate_series_change': l10nEntry(
      english: '{percent} vs start of series',
      arabic: '{percent} مقارنة ببداية السلسلة',
      hindi: 'श्रृंखला की शुरुआत की तुलना में {percent}',
      urdu: 'سلسلے کے آغاز کے مقابلے میں {percent}',
      malayalam: 'ശ്രേണിയുടെ ആരംഭവുമായി താരതമ്യപ്പെടുത്തുമ്പോൾ {percent}',
      nepali: 'श्रृङ्खलाको सुरुवातसँग तुलना गर्दा {percent}',
      bengali: 'সিরিজের শুরুর তুলনায় {percent}',
      tamil: 'தொடரின் தொடக்கத்துடன் ஒப்பிடும்போது {percent}',
      filipino: '{percent} kumpara sa simula ng serye',
    ),

    // ── Dashboard tab ─────────────────────────────────────────────────────────
    /// Kit / contract footer — indicative + no financial services (PNG reference).
    'dashboard_compliance_footer': l10nEntry(
      english:
          'Rates are indicative. Raabta does not offer financial advice or exchange services.',
      arabic:
          'الأسعار إرشادية. رابتا لا تقدّم استشارات مالية أو خدمات صرافة.',
      hindi:
          'दरें संकेतक हैं। राब्ता वित्तीय सलाह या विनिमय सेवाएँ प्रदान नहीं करता।',
      urdu:
          'شرحیں اشارتی ہیں۔ رابتا مالی مشورے یا ایکسچینج کی خدمات پیش نہیں کرتا۔',
      malayalam:
          'നിരക്കുകൾ സൂചകമാണ്. റാബ്റ സാമ്പത്തിക ഉപദേശമോ കറൻസി കൈമാറ്റ സേവനങ്ങളോ നൽകുന്നില്ല.',
      nepali:
          'दरहरू सन्दर्भमात्र हुन्। राब्ताले वित्तीय सल्लाह वा विनिमय सेवा प्रदान गर्दैन।',
      bengali:
          'হারসমূহ নির্দেশক। রাবতা আর্থিক পরামর্শ বা বিনিময় পরিষেবা প্রদান করে না।',
      tamil:
          'விகிதங்கள் குறிப்பிடத்தக்கவை. ராப்டா நிதி ஆலோசனையோ பரிமாற்ற சேவைகளோ வழங்காது.',
      filipino:
          'Ang mga rate ay indikasyon lamang. Hindi nag-aalok ang Raabta ng payong pinansyal o serbisyo sa palitan.',
    ),
    'dashboard_no_currencies_match': l10nEntry(
      english: 'No currencies match your search',
      arabic: 'لا توجد عملات تطابق بحثك',
      hindi: 'कोई मुद्रा आपकी खोज से मेल नहीं खाती',
      urdu: 'آپ کی تلاش سے کوئی کرنسی نہیں ملی',
      bengali: 'আপনার অনুসন্ধানের সাথে কোনো মুদ্রা মেলে না',
      filipino: 'Walang currency na tumutugma sa hinanap mo',
    ),
    'dashboard_tools_overline': l10nEntry(
      english: 'Tools',
      arabic: 'أدوات',
      hindi: 'उपकरण',
      urdu: 'ٹولز',
    ),
    'dashboard_finance_tools_title': l10nEntry(
      english: 'Finance tools',
      arabic: 'أدوات مالية',
      hindi: 'Finance tools',
      urdu: 'Finance tools',
    ),
    'dashboard_finance_tools_subtitle': l10nEntry(
      english: 'Gold, remittance, CPI & budget',
      arabic: 'الذهب، التحويلات، CPI والميزانية',
      hindi: 'Gold, remittance, CPI & budget',
      urdu: 'Gold, remittance, CPI & budget',
    ),
    'dashboard_wellness_overline': l10nEntry(
      english: 'Wellness',
      arabic: 'الرفاهية',
      hindi: 'Wellness',
      urdu: 'Wellness',
    ),
    'dashboard_financial_wellness_title': l10nEntry(
      english: 'Financial wellness',
      arabic: 'الرفاهية المالية',
      hindi: 'Financial wellness',
      urdu: 'Financial wellness',
    ),
    'dashboard_wellness_subtitle': l10nEntry(
      english: 'Awareness — not Raabta products',
      arabic: 'توعية — ليست منتجات رابطة',
      hindi: 'Awareness — not Raabta products',
      urdu: 'Awareness — not Raabta products',
    ),
    'dashboard_rates_overline': l10nEntry(
      english: 'Rates',
      arabic: 'الأسعار',
      hindi: 'Rates',
      urdu: 'Rates',
    ),
    'dashboard_live_rates_title': l10nEntry(
      english: 'Live rates',
      arabic: 'أسعار مباشرة',
      hindi: 'Live rates',
      urdu: 'Live rates',
    ),
    'dashboard_tap_currency_subtitle': l10nEntry(
      english: 'Tap a currency to select',
      arabic: 'اضغط على عملة للاختيار',
      hindi: 'Tap a currency to select',
      urdu: 'Tap a currency to select',
    ),
    'dashboard_active_badge': l10nEntry(
      english: 'ACTIVE',
      arabic: 'نشط',
      hindi: 'ACTIVE',
      urdu: 'ACTIVE',
    ),
    'dashboard_online_transfer': l10nEntry(
      english: 'Online transfer',
      arabic: 'تحويل عبر الإنترنت',
      hindi: 'Online transfer',
      urdu: 'Online transfer',
    ),
    'dashboard_via_exchange_app': l10nEntry(
      english: 'Via exchange app',
      arabic: 'عبر تطبيق الصرافة',
      hindi: 'Via exchange app',
      urdu: 'Via exchange app',
    ),
    'dashboard_walk_in': l10nEntry(
      english: 'Walk in',
      arabic: 'زيارة مباشرة',
      hindi: 'Walk in',
      urdu: 'Walk in',
    ),
    'dashboard_find_nearest_branch': l10nEntry(
      english: 'Find nearest branch',
      arabic: 'ابحث عن أقرب فرع',
      hindi: 'Find nearest branch',
      urdu: 'Find nearest branch',
    ),

    // ── Branches tab ──────────────────────────────────────────────────────────
    'branches_find_exchange_branches': l10nEntry(
      english: 'Find exchange branches',
      arabic: 'ابحث عن فروع الصرافة',
      hindi: 'Find exchange branches',
      urdu: 'Find exchange branches',
    ),
    'branches_hero_subtitle': l10nEntry(
      english: 'Companies, live queues, map & favorites',
      arabic: 'الشركات، الطوابير المباشرة، الخريطة والمفضلة',
      hindi: 'Companies, live queues, map & favorites',
      urdu: 'Companies, live queues, map & favorites',
    ),
    'branches_open_branch_finder': l10nEntry(
      english: 'Open branch finder',
      arabic: 'افتح محدد الفروع',
      hindi: 'Open branch finder',
      urdu: 'Open branch finder',
    ),
    'branches_locator_overline': l10nEntry(
      english: 'Locator',
      arabic: 'المحدد',
      hindi: 'Locator',
      urdu: 'Locator',
    ),
    'branches_quick_access_title': l10nEntry(
      english: 'Quick access',
      arabic: 'وصول سريع',
      hindi: 'Quick access',
      urdu: 'Quick access',
    ),
    'branches_quick_access_subtitle': l10nEntry(
      english: 'Jump straight to what you need',
      arabic: 'انتقل مباشرة لما تحتاجه',
      hindi: 'Jump straight to what you need',
      urdu: 'Jump straight to what you need',
    ),
    'branches_exchange_companies_title': l10nEntry(
      english: 'Exchange companies',
      arabic: 'شركات الصرافة',
      hindi: 'Exchange companies',
      urdu: 'Exchange companies',
    ),
    'branches_exchange_companies_subtitle': l10nEntry(
      english: 'Browse licensed houses & ratings',
      arabic: 'تصفح المكاتب المرخصة والتقييمات',
      hindi: 'Browse licensed houses & ratings',
      urdu: 'Browse licensed houses & ratings',
    ),
    'branches_branch_finder_title': l10nEntry(
      english: 'Branch finder',
      arabic: 'محدد الفروع',
      hindi: 'Branch finder',
      urdu: 'Branch finder',
    ),
    'branches_branch_finder_subtitle': l10nEntry(
      english: 'Nearest branch by your location',
      arabic: 'أقرب فرع حسب موقعك',
      hindi: 'Nearest branch by your location',
      urdu: 'Nearest branch by your location',
    ),
    'branches_map_view_title': l10nEntry(
      english: 'Map view',
      arabic: 'عرض الخريطة',
      hindi: 'Map view',
      urdu: 'Map view',
    ),
    'branches_map_view_subtitle': l10nEntry(
      english: 'See branches on the map',
      arabic: 'شاهد الفروع على الخريطة',
      hindi: 'See branches on the map',
      urdu: 'See branches on the map',
    ),
    'branches_favorites_title': l10nEntry(
      english: 'Favorites',
      arabic: 'المفضلة',
      hindi: 'Favorites',
      urdu: 'Favorites',
    ),
    'branches_favorites_subtitle': l10nEntry(
      english: 'Your saved branches',
      arabic: 'فروعك المحفوظة',
      hindi: 'Your saved branches',
      urdu: 'Your saved branches',
    ),

    // ── Markets tab (audited strings) ─────────────────────────────────────────
    'markets_segment_trend': l10nEntry(
      english: '7-day trend',
      arabic: 'اتجاه 7 أيام',
      hindi: '7-दिन का ट्रेंड',
      urdu: '7 دن کا رجحان',
      bengali: '৭-দিনের ট্রেন্ড',
      filipino: '7-day trend',
    ),
    'markets_segment_compare': l10nEntry(
      english: 'Compare houses',
      arabic: 'قارن مكاتب الصرافة',
      hindi: 'एक्सचेंज हाउस तुलना',
      urdu: 'ایکسچینج ہاؤسز موازنہ',
      bengali: 'এক্সচেঞ্জ হাউস তুলনা',
      filipino: 'Ikumpara ang mga exchange house',
    ),
    'markets_live_rate_history': l10nEntry(
      english: 'Live rate history',
      arabic: 'سجل الأسعار المباشرة',
      hindi: 'लाइव दर इतिहास',
      urdu: 'لائیو شرح کی تاریخ',
      bengali: 'লাইভ রেটের ইতিহাস',
      filipino: 'Live na kasaysayan ng rate',
    ),
    'markets_indicative_rate_history': l10nEntry(
      english: 'Indicative rate history',
      arabic: 'سجل أسعار إرشادية',
      hindi: 'संकेतक दर इतिहास',
      urdu: 'تعمیلی شرح کی تاریخ',
      bengali: 'ইঙ্গিতমূলক রেটের ইতিহাস',
      filipino: 'Indikasyon na kasaysayan ng rate',
    ),
    'markets_approximate_rates_warning': l10nEntry(
      english: 'Approximate rates — check connection',
      arabic: 'أسعار تقريبية — تحقق من الاتصال',
      hindi: 'अनुमानित दरें — कनेक्शन जाँचें',
      urdu: 'تقریبی شرحیں — کنکشن چیک کریں',
      bengali: 'আনুমানিক হার — সংযোগ পরীক্ষা করুন',
      filipino: 'Tinatayang rate — tingnan ang koneksyon',
    ),
    'markets_overline': l10nEntry(
      english: 'Markets',
      arabic: 'الأسواق',
      hindi: 'बाज़ार',
      urdu: 'بازار',
      bengali: 'বাজার',
      filipino: 'Markets',
    ),
    'markets_trend_chart_title': l10nEntry(
      english: '7-day rate trend',
      arabic: 'اتجاه سعر 7 أيام',
      hindi: '7-दिन की दर प्रवृत्ति',
      urdu: '7 دن کی شرح رجحان',
      bengali: '৭-দিনের রেট ট্রেন্ড',
      filipino: '7-day rate trend',
    ),
    'markets_chart_unavailable': l10nEntry(
      english: 'Chart unavailable',
      arabic: 'المخطط غير متاح',
      hindi: 'चार्ट उपलब्ध नहीं',
      urdu: 'چارٹ دستیاب نہیں',
      bengali: 'চার্ট উপলব্ধ নয়',
      filipino: 'Walang chart',
    ),
    'markets_not_enough_data': l10nEntry(
      english: 'Not enough data',
      arabic: 'بيانات غير كافية',
      hindi: 'पर्याप्त डेटा नहीं',
      urdu: 'کافی ڈیٹا نہیں',
      bengali: 'পর্যাপ্ত ডেটা নেই',
      filipino: 'Kulang ang data',
    ),
    'markets_compare_overline': l10nEntry(
      english: 'Compare',
      arabic: 'قارن',
      hindi: 'तुलना',
      urdu: 'موازنہ',
      bengali: 'তুলনা',
      filipino: 'Ikumpara',
    ),
    'markets_exchange_houses_title': l10nEntry(
      english: '{flag} Qatar exchange houses',
      arabic: '{flag} مكاتب صرافة في قطر',
      hindi: '{flag} कतर एक्सचेंज हाउस',
      urdu: '{flag} قطر ایکسچینج ہاؤسز',
      bengali: '{flag} কাতার এক্সচেঞ্জ হাউস',
      filipino: '{flag} Qatar exchange houses',
    ),
    'markets_tap_currency_expand_chart': l10nEntry(
      english: 'Tap a currency to expand the chart',
      arabic: 'اضغط على عملة لتوسيع الرسم البياني',
      hindi: 'Tap a currency to expand the chart',
      urdu: 'Tap a currency to expand the chart',
    ),
    'markets_exchange_house_comparison': l10nEntry(
      english: 'Exchange house comparison',
      arabic: 'مقارنة مكاتب الصرافة',
      hindi: 'Exchange house comparison',
      urdu: 'Exchange house comparison',
    ),
    'markets_walk_in_rates_for_code': l10nEntry(
      english: 'Walk-in rates for QR → {code}',
      arabic: 'أسعار الزيارة المباشرة لـ QR → {code}',
      hindi: 'Walk-in rates for QR → {code}',
      urdu: 'Walk-in rates for QR → {code}',
    ),
    'markets_comparison_unavailable': l10nEntry(
      english: 'Comparison unavailable',
      arabic: 'المقارنة غير متاحة',
      hindi: 'Comparison unavailable',
      urdu: 'Comparison unavailable',
    ),
    'markets_check_connection_retry': l10nEntry(
      english: 'Check your connection and try again.',
      arabic: 'تحقق من اتصالك وحاول مرة أخرى.',
      hindi: 'Check your connection and try again.',
      urdu: 'Check your connection and try again.',
    ),
    'markets_retry': l10nEntry(
      english: 'Retry',
      arabic: 'إعادة المحاولة',
      hindi: 'Retry',
      urdu: 'Retry',
    ),
    'markets_best_rate': l10nEntry(
      english: 'BEST RATE',
      arabic: 'أفضل سعر',
      hindi: 'BEST RATE',
      urdu: 'BEST RATE',
    ),
    'markets_could_not_load_rates': l10nEntry(
      english: 'Could not load rates',
      arabic: 'تعذّر تحميل الأسعار',
      hindi: 'Could not load rates',
      urdu: 'Could not load rates',
    ),
    'markets_tap_to_retry': l10nEntry(
      english: 'Tap to retry',
      arabic: 'اضغط لإعادة المحاولة',
      hindi: 'Tap to retry',
      urdu: 'Tap to retry',
    ),
    'markets_amount_to_send': l10nEntry(
      english: 'Amount to send',
      arabic: 'المبلغ المراد إرساله',
      hindi: 'Amount to send',
      urdu: 'Amount to send',
    ),
    'markets_enter_amount_hint': l10nEntry(
      english:
          'Enter an amount to see what your recipient gets at each house',
      arabic:
          'أدخل مبلغاً لمعرفة ما يحصل عليه المستلم في كل مكتب',
      hindi:
          'Enter an amount to see what your recipient gets at each house',
      urdu:
          'Enter an amount to see what your recipient gets at each house',
    ),
    'markets_rates_disclaimer': l10nEntry(
      english:
          'Rates shown are indicative based on mid-market with typical spreads. '
          'Visit exchange house for final rate. Rates change throughout the day.',
      arabic:
          'الأسعار المعروضة إرشادية بناءً على السوق الوسطي مع فروقات نموذجية. '
          'زر مكتب الصرافة للسعر النهائي. الأسعار تتغير خلال اليوم.',
      hindi:
          'Rates shown are indicative based on mid-market with typical spreads. '
          'Visit exchange house for final rate. Rates change throughout the day.',
      urdu:
          'Rates shown are indicative based on mid-market with typical spreads. '
          'Visit exchange house for final rate. Rates change throughout the day.',
    ),
  };
}
