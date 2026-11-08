import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

/// Global Search static index strings — tools, money, and health discoverability.
abstract final class GlobalSearchIndexStrings {
  static const supportedLocales = AppLocale.supportedLocales;

  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    // ── Quick actions (QuickActionsHub routes) ───────────────────────────────
    'search_qa_services_title': _enArHi(
      'Services',
      'الخدمات',
      'सेवाएँ',
    ),
    'search_qa_services_subtitle': _enArHi(
      'Post your service or browse classified listings',
      'انشر خدمتك أو تصفح الإعلانات',
      'अपनी सेवा पोस्ट करें या लिस्टिंग देखें',
    ),
    'search_qa_scanner_title': _enArHi('PDF Studio', 'استوديو PDF', 'PDF Studio'),
    'search_qa_scanner_subtitle': _enArHi(
      'Scan, OCR, PDF tools & vault',
      'مسح، OCR، أدوات PDF والخزنة',
      'Scan, OCR, PDF tools & vault',
    ),
    'search_qa_vault_title': _enArHi('Document Vault', 'خزنة المستندات', 'Document Vault'),
    'search_qa_vault_subtitle': _enArHi(
      'View & chat with your documents',
      'اعرض مستنداتك وتحدث معها',
      'View & chat with your documents',
    ),
    'search_qa_barcode_title': _enArHi('Barcode Scanner', 'ماسح الباركود', 'Barcode Scanner'),
    'search_qa_barcode_subtitle': _enArHi(
      'Scan any product barcode',
      'امسح باركود أي منتج',
      'Scan any product barcode',
    ),
    'search_qa_companion_title': _enArHi(
      'Arabic Companion',
      'رفيق العربية',
      'Arabic Companion',
    ),
    'search_qa_companion_subtitle': _enArHi(
      'Phrasebook + live Gulf Arabic for taxis & directions',
      'عبارات + ترجمة مباشرة للتكسي والاتجاهات',
      'Phrasebook + live Gulf Arabic for taxis & directions',
    ),
    'search_qa_billsplit_title': _enArHi('Bill Splitter', 'تقسيم الفاتورة', 'Bill Splitter'),
    'search_qa_billsplit_subtitle': _enArHi(
      'Split bills in any currency',
      'قسّم الفواتير بأي عملة',
      'Split bills in any currency',
    ),
    'search_qa_warranty_title': _enArHi('Warranty Shield', 'درع الضمان', 'Warranty Shield'),
    'search_qa_warranty_subtitle': _enArHi(
      'Track your Qatar warranties',
      'تتبع ضماناتك في قطر',
      'Track your Qatar warranties',
    ),
    'search_qa_scam_shield_title': _enArHi(
      'Scam Shield',
      'درع الاحتيال',
      'Scam Shield',
    ),
    'search_qa_scam_shield_subtitle': _enArHi(
      'Check suspicious messages before you act',
      'تحقق من الرسائل المشبوهة قبل التصرف',
      'Check suspicious messages before you act',
    ),
    'search_qa_climate_title': _enArHi('Climate Navigator', 'مرشد المناخ', 'Climate Navigator'),
    'search_qa_climate_subtitle': _enArHi(
      'Indoor & shaded routes',
      'مسارات داخلية ومظللة',
      'Indoor & shaded routes',
    ),
    'search_qa_queue_title': _enArHi('Queue Avoidance', 'تجنب الطوابير', 'Queue Avoidance'),
    'search_qa_queue_subtitle': _enArHi(
      'Check wait times before you go',
      'تحقق من أوقات الانتظار',
      'Check wait times before you go',
    ),
    'search_qa_billtracker_title': _enArHi('Bill Tracker', 'متتبع الفواتير', 'Bill Tracker'),
    'search_qa_billtracker_subtitle': _enArHi(
      'Track Qatar utility bills',
      'تتبع فواتير قطر',
      'Track Qatar utility bills',
    ),
    'search_qa_trip_title': _enArHi(
      'Trip Planner',
      'مخطط الرحلات',
      'Trip Planner',
    ),
    'search_qa_trip_subtitle': _enArHi(
      'AI-powered Qatar itineraries',
      'خطط سفر قطر بالذكاء الاصطناعي',
      'AI-powered Qatar itineraries',
    ),
    'search_qa_prayer_title': _enArHi('Prayer & Mosque', 'الصلاة والمسجد', 'Prayer & Mosque'),
    'search_qa_prayer_subtitle': _enArHi(
      'Prayer times, Qibla & nearby mosques',
      'مواقيت الصلاة والقبلة والمساجد القريبة',
      'Prayer times, Qibla & nearby mosques',
    ),
    'search_qa_eosb_hub_title': _enArHi('EOSB Truth Engine', 'محرك حقيقة EOSB', 'EOSB Truth Engine'),
    'search_qa_eosb_hub_subtitle': _enArHi(
      'End of Service Benefits calculator',
      'حاسبة مكافأة نهاية الخدمة',
      'End of Service Benefits calculator',
    ),
    'search_qa_health_ins_title': _enArHi(
      'Health Insurance Truth Engine',
      'محرك حقيقة التأمين الصحي',
      'Health Insurance Truth Engine',
    ),
    'search_qa_health_ins_subtitle': _enArHi(
      'Employer compliance & policy explainer (Law 22/2021)',
      'امتثال صاحب العمل وشرح الوثيقة (القانون 22/2021)',
      'Employer compliance & policy explainer (Law 22/2021)',
    ),
    'search_qa_tenancy_title': _enArHi(
      'Housing Rights Truth Engine',
      'محرك حقوق الإيجار',
      'Housing Rights Truth Engine',
    ),
    'search_qa_tenancy_subtitle': _enArHi(
      'Lease compliance, dispute checklist & Law 4/2008 guidance',
      'امتثال عقد الإيجار وقائمة النزاع والقانون 4/2008',
      'Lease compliance, dispute checklist & Law 4/2008 guidance',
    ),
    'search_qa_sponsorship_transfer_title': _enArHi(
      'Sponsorship Transfer Truth Engine',
      'محرك نقل الكفالة',
      'Sponsorship Transfer Truth Engine',
    ),
    'search_qa_sponsorship_transfer_subtitle': _enArHi(
      'Iqama transfer readiness, notice period & Law 19/2020 rights',
      'جاهزية نقل الإقامة ومدة الإشعار وحقوق القانون 19/2020',
      'Iqama transfer readiness, notice period & Law 19/2020 rights',
    ),
    'search_qa_ussd_title': _enArHi('SIM USSD Codes', 'رموز USSD', 'SIM USSD Codes'),
    'search_qa_ussd_subtitle': _enArHi(
      'Ooredoo & Vodafone Qatar codes',
      'رموز Ooredoo و Vodafone',
      'Ooredoo & Vodafone Qatar codes',
    ),
    'search_qa_phrases_title': _enArHi('Arabic Phrases', 'عبارات عربية', 'Arabic Phrases'),
    'search_qa_phrases_subtitle': _enArHi(
      'Qatar Arabic phrasebook',
      'قاموس عبارات قطر العربية',
      'Qatar Arabic phrasebook',
    ),
    'search_qa_driving_title': _enArHi(
      'Driving & Traffic',
      'القيادة والمرور',
      'Driving & Traffic',
    ),
    'search_qa_driving_subtitle': _enArHi(
      'MOI fees, fines guide & theory quiz',
      'رسوم وزارة الداخلية والغرامات واختبار النظرية',
      'MOI fees, fines guide & theory quiz',
    ),
    'search_qa_ramadan_title': _enArHi('Ramadan', 'رمضان', 'Ramadan'),
    'search_qa_ramadan_subtitle': _enArHi(
      'Prayer times, Qibla, Zakat & Iftar',
      'مواقيت الصلاة والقبلة والزكاة والإفطار',
      'Prayer times, Qibla, Zakat & Iftar',
    ),

    // ── Tools static destinations ────────────────────────────────────────────
    'search_tool_raabta_ai_title': _enArHi(
      'Ask Raabta AI',
      'اسأل Raabta AI',
      'Raabta AI से पूछें',
    ),
    'search_tool_raabta_ai_subtitle': _enArHi(
      'Chat with Raabta about life in Qatar',
      'تحدث مع Raabta عن الحياة في قطر',
      'Qatar में जीवन पर Raabta से बात करें',
    ),
    'search_tool_eosb_title': _enArHi('EOSB Truth Engine', 'محرك حقيقة EOSB', 'EOSB Truth Engine'),
    'search_tool_eosb_subtitle': _enArHi(
      'End of Service Benefits calculator',
      'حاسبة مكافأة نهاية الخدمة',
      'End of Service Benefits calculator',
    ),
    'search_tool_overtime_title': _enArHi('Overtime Truth Hub', 'مركز حقيقة العمل الإضافي', 'Overtime Truth Hub'),
    'search_tool_overtime_subtitle': _enArHi(
      'EOSB · overtime calculator',
      'EOSB · حاسبة العمل الإضافي',
      'EOSB · overtime calculator',
    ),
    'search_tool_health_ins_title': _enArHi(
      'Health Insurance Truth Engine',
      'محرك حقيقة التأمين الصحي',
      'Health Insurance Truth Engine',
    ),
    'search_tool_health_ins_subtitle': _enArHi(
      'Law 22/2021 compliance & policy explainer',
      'الامتثال للقانون 22/2021',
      'Law 22/2021 compliance & policy explainer',
    ),
    'search_tool_tenancy_title': _enArHi(
      'Housing Rights Truth Engine',
      'محرك حقوق الإيجار',
      'Housing Rights Truth Engine',
    ),
    'search_tool_tenancy_subtitle': _enArHi(
      'Lease compliance & dispute preparation (Law 4/2008)',
      'امتثال الإيجار وتحضير النزاع (القانون 4/2008)',
      'Lease compliance & dispute preparation (Law 4/2008)',
    ),
    'search_tool_tenancy_checklist_title': _enArHi(
      'Tenancy Dispute Checklist',
      'قائمة مستندات نزاع الإيجار',
      'Tenancy Dispute Checklist',
    ),
    'search_tool_tenancy_checklist_subtitle': _enArHi(
      'Housing Rights · filing document checklist',
      'حقوق الإيجار · قائمة مستندات التقديم',
      'Housing Rights · filing document checklist',
    ),
    'search_tool_tenancy_ai_title': _enArHi(
      'Tenancy Legal Assistant',
      'مساعد الإيجار القانوني',
      'Tenancy Legal Assistant',
    ),
    'search_tool_tenancy_ai_subtitle': _enArHi(
      'Housing Rights · verified Law 4/2008 Q&A',
      'حقوق الإيجار · أسئلة القانون 4/2008',
      'Housing Rights · verified Law 4/2008 Q&A',
    ),
    'search_tool_tenancy_packet_title': _enArHi(
      'Tenancy Dispute Packet',
      'حزمة نزاع الإيجار',
      'Tenancy Dispute Packet',
    ),
    'search_tool_tenancy_packet_subtitle': _enArHi(
      'Housing Rights · generate & share PDF cover sheet',
      'حقوق الإيجار · إنشاء ومشاركة PDF',
      'Housing Rights · generate & share PDF cover sheet',
    ),
    'search_tool_sponsorship_transfer_title': _enArHi(
      'Sponsorship Transfer Truth Engine',
      'محرك نقل الكفالة',
      'Sponsorship Transfer Truth Engine',
    ),
    'search_tool_sponsorship_transfer_subtitle': _enArHi(
      'Transfer readiness & Law 19/2020 rights (not processing-time prediction)',
      'جاهزية النقل وحقوق القانون 19/2020',
      'Transfer readiness & Law 19/2020 rights',
    ),
    'search_tool_sponsorship_transfer_checklist_title': _enArHi(
      'Transfer Document Checklist',
      'قائمة مستندات النقل',
      'Transfer Document Checklist',
    ),
    'search_tool_sponsorship_transfer_checklist_subtitle': _enArHi(
      'Sponsorship Transfer · verified preparation checklist',
      'نقل الكفالة · قائمة تحضير موثقة',
      'Sponsorship Transfer · verified preparation checklist',
    ),
    'search_tool_sponsorship_transfer_ai_title': _enArHi(
      'Sponsorship Transfer Assistant',
      'مساعد نقل الكفالة',
      'Sponsorship Transfer Assistant',
    ),
    'search_tool_sponsorship_transfer_ai_subtitle': _enArHi(
      'Sponsorship Transfer · verified Law 19/18/2020 Q&A',
      'نقل الكفالة · أسئلة القوانين 19/18/2020',
      'Sponsorship Transfer · verified Law 19/18/2020 Q&A',
    ),
    'search_tool_civic_report_title': _enArHi(
      'Report neighbourhood problem',
      'بلاغ مشكلة في الحي',
      'Report neighbourhood problem',
    ),
    'search_tool_civic_report_subtitle': _enArHi(
      'Municipal & utility routing — not Raabta app support',
      'توجيه بلديات ومرافق — ليس دعم تطبيق رابطة',
      'Municipal & utility routing — not Raabta app support',
    ),
    'search_tool_ramadan_title': _enArHi('Ramadan Companion', 'رفيق رمضان', 'Ramadan Companion'),
    'search_tool_ramadan_subtitle': _enArHi(
      'Prayer, Qibla, Zakat & Iftar',
      'صلاة، قبلة، زكاة وإفطار',
      'Prayer, Qibla, Zakat & Iftar',
    ),
    'search_tool_zakat_title': _enArHi('Zakat Calculator', 'حاسبة الزكاة', 'Zakat Calculator'),
    'search_tool_zakat_subtitle': _enArHi(
      'Ramadan · calculate your Zakat',
      'رمضان · احسب زكاتك',
      'Ramadan · calculate your Zakat',
    ),
    'search_tool_driving_hub_title': _enArHi('Driving License Hub', 'مركز رخصة القيادة', 'Driving License Hub'),
    'search_tool_driving_hub_subtitle': _enArHi(
      'Fees, fines & theory quiz',
      'الرسوم والغرامات واختبار النظرية',
      'Fees, fines & theory quiz',
    ),
    'search_tool_driving_calc_title': _enArHi('Driving Fee Calculator', 'حاسبة رسوم القيادة', 'Driving Fee Calculator'),
    'search_tool_driving_calc_subtitle': _enArHi(
      'Driving · license fees',
      'القيادة · رسوم الرخصة',
      'Driving · license fees',
    ),
    'search_tool_cv_title': _enArHi('CV Maker', 'صانع السيرة الذاتية', 'CV Maker'),
    'search_tool_cv_subtitle': _enArHi(
      'Jobs · build your Qatar CV',
      'الوظائف · أنشئ سيرتك لقطر',
      'Jobs · build your Qatar CV',
    ),
    'search_tool_premium_title': _enArHi('Premium Subscription', 'اشتراك Premium', 'Premium Subscription'),
    'search_tool_premium_subtitle': _enArHi(
      'Raabta Premium features',
      'ميزات Raabta Premium',
      'Raabta Premium features',
    ),
    'search_tool_boost_title': _enArHi('Boost Listing', 'تعزيز الإعلان', 'Boost Listing'),
    'search_tool_boost_subtitle': _enArHi(
      'Promote your listing',
      'روّج لإعلانك',
      'Promote your listing',
    ),
    'search_tool_advertise_title': _enArHi('Advertise Your Business', 'أعلن عن عملك', 'Advertise Your Business'),
    'search_tool_advertise_subtitle': _enArHi(
      'Business promotion',
      'ترويج الأعمال',
      'Business promotion',
    ),
    'search_tool_expense_split_title': _enArHi('Expense Splitter', 'تقسيم المصروفات', 'Expense Splitter'),
    'search_tool_expense_split_subtitle': _enArHi(
      'Split bills with friends',
      'قسّم الفواتير مع الأصدقاء',
      'Split bills with friends',
    ),

    // ── Money Hub ────────────────────────────────────────────────────────────
    'search_money_rates_title': _enArHi('Exchange Rates', 'أسعار الصرف', 'Exchange Rates'),
    'search_money_rates_subtitle': _enArHi(
      'Money Hub · currency converter',
      'مركز المال · محول العملات',
      'Money Hub · currency converter',
    ),
    'search_money_compare_title': _enArHi(
      'Compare Exchange Houses',
      'قارن مكاتب الصرافة',
      'Compare Exchange Houses',
    ),
    'search_money_compare_subtitle': _enArHi(
      'Money Hub · walk-in house rates',
      'مركز المال · أسعار الصراف',
      'Money Hub · walk-in house rates',
    ),
    'search_money_gold_title': _enArHi('Gold Intelligence', 'ذكاء الذهب', 'Gold Intelligence'),
    'search_money_gold_subtitle': _enArHi(
      'Money Hub · Qatar gold prices',
      'مركز المال · أسعار الذهب',
      'Money Hub · Qatar gold prices',
    ),
    'search_money_cpi_title': _enArHi('Qatar Cost of Living', 'تكلفة المعيشة في قطر', 'Qatar Cost of Living'),
    'search_money_cpi_subtitle': _enArHi(
      'Money Hub · official CPI & bill context',
      'مركز المال · CPI الرسمي',
      'Money Hub · official CPI & bill context',
    ),
    'search_money_personal_budget_title': _enArHi(
      'Personal Budget Calculator',
      'حاسبة الميزانية الشخصية',
      'Personal Budget Calculator',
    ),
    'search_money_personal_budget_subtitle': _enArHi(
      'Money Hub · salary vs expenses & savings rate',
      'مركز المال · الراتب مقابل المصروفات',
      'Money Hub · salary vs expenses & savings rate',
    ),
    'search_money_corridor_title': _enArHi('Corridor Comparator', 'مقارن الممرات', 'Corridor Comparator'),
    'search_money_corridor_subtitle': _enArHi(
      'Money Hub · remittance apps & banks',
      'مركز المال · تطبيقات التحويل',
      'Money Hub · remittance apps & banks',
    ),
    'search_money_locator_title': _enArHi('Exchange Locator Pro', 'محدد الصراف Pro', 'Exchange Locator Pro'),
    'search_money_locator_subtitle': _enArHi(
      'Money Hub · find branches',
      'مركز المال · ابحث عن الفروع',
      'Money Hub · find branches',
    ),

    // ── Health Insurance Truth Engine ────────────────────────────────────────
    'search_health_insurance_title': _enArHi(
      'Health Insurance Truth Engine',
      'محرك حقيقة التأمين الصحي',
      'Health Insurance Truth Engine',
    ),
    'search_health_insurance_subtitle': _enArHi(
      'Employer compliance & policy guidance',
      'امتثال صاحب العمل وإرشادات الوثيقة',
      'Employer compliance & policy guidance',
    ),
    'search_health_navigation_title': _enArHi(
      'Healthcare Navigation',
      'التنقل في الرعاية الصحية',
      'Healthcare Navigation',
    ),
    'search_health_navigation_subtitle': _enArHi(
      'HMC, health card & emergency info for Qatar',
      'HMC وبطاقة الصحة ومعلومات الطوارئ في قطر',
      'HMC, health card & emergency info for Qatar',
    ),

    // ── Test-only (registry dummy provider) ──────────────────────────────────
    'search_test_dummy_title': _en('Dummy Test Tool'),
    'search_test_dummy_subtitle': _en('Test only'),
  };
}

Map<String, String> _en(String english) => {
      'English': english,
      'Arabic': english,
      'Hindi': english,
      'Urdu': english,
      'Malayalam': english,
      'Nepali': english,
      'Bengali': english,
      'Filipino': english,
    };

Map<String, String> _enArHi(String en, String ar, String hi) => {
      'English': en,
      'Arabic': ar,
      'Hindi': hi,
      'Urdu': hi,
      'Malayalam': en,
      'Nepali': en,
      'Bengali': hi,
      'Filipino': en,
    };
