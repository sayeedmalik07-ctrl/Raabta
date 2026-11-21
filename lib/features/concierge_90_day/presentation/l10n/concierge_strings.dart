import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';

/// 90-Day Concierge strings — 8 languages, RTL via AppLocale.
abstract final class ConciergeStrings {
  static const supportedLocales = [
    'English',
    'Arabic',
    'Hindi',
    'Urdu',
    'Malayalam',
    'Nepali',
    'Bengali',
    'Filipino',
  ];

  static String t(String key, [String locale = 'English']) {
    final map = _catalog[key];
    if (map == null) return key;
    return map[locale] ?? map['English'] ?? key;
  }

  /// Exposed for catalog parity regression tests only.
  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static String phaseLabel(ConciergePhase phase, String locale) {
    final key = switch (phase) {
      ConciergePhase.getOriented => 'concierge_phase_oriented',
      ConciergePhase.paperwork => 'concierge_phase_paperwork',
      ConciergePhase.moneyBasics => 'concierge_phase_money',
      ConciergePhase.dailyLife => 'concierge_phase_daily',
      ConciergePhase.settlingSpace => 'concierge_phase_housing',
      ConciergePhase.communityExplore => 'concierge_phase_community',
      ConciergePhase.knowYourRights => 'concierge_phase_rights',
    };
    return t(key, locale);
  }

  static const _en = 'English';
  static const _ar = 'Arabic';
  static const _hi = 'Hindi';

  static const _catalog = <String, Map<String, String>>{
    'concierge_card_overline': {
      _en: 'SETTLING IN',
      _ar: 'الاستقرار',
      _hi: 'बसना',
    },
    'concierge_card_title': {
      _en: 'Your 90-day concierge',
      _ar: 'مرافقك لـ 90 يوماً',
      _hi: 'आपका 90-दिन कंसीयर्ज',
    },
    'concierge_card_subtitle': {
      _en: 'One helpful next step — no overwhelming checklist.',
      _ar: 'خطوة واحدة مفيدة — بدون قائمة مُرهقة.',
      _hi: 'एक उपयोगी अगला कदम — कोई भारी चेकलिस्ट नहीं।',
    },
    'concierge_day_label': {
      _en: 'Day {day} of 90',
      _ar: 'اليوم {day} من 90',
      _hi: '90 में से दिन {day}',
    },
    'concierge_view_journey': {
      _en: 'See full journey',
      _ar: 'عرض الرحلة كاملة',
      _hi: 'पूरी यात्रा देखें',
    },
    'concierge_settled_cta': {
      _en: "I'm settled — hide concierge",
      _ar: 'استقررت — إخفاء المرافق',
      _hi: 'मैं settle हो गया — concierge छुपाएं',
    },
    'concierge_journey_title': {
      _en: '90-Day Settling-In Journey',
      _ar: 'رحلة الاستقرار 90 يوماً',
      _hi: '90-दिन बसने की यात्रा',
    },
    'concierge_arrival_prompt': {
      _en: 'When did you arrive in Qatar? (optional — helps personalize timing)',
      _ar: 'متى وصلت إلى قطر؟ (اختياري — يساعد في توقيت الإرشادات)',
      _hi: 'कतर कब पहुंचे? (वैकल्पिक — समय personalize करने में मदद)',
    },
    'concierge_arrival_skip': {
      _en: 'Skip — use account date instead',
      _ar: 'تخطي — استخدم تاريخ الحساب',
      _hi: 'छोड़ें — account date use करें',
    },
    'concierge_mark_done': {
      _en: 'Mark as done',
      _ar: 'تم',
      _hi: 'पूर्ण',
    },
    'concierge_not_applicable': {
      _en: 'Not for me',
      _ar: 'لا ينطبق علي',
      _hi: 'मेरे लिए नहीं',
    },
    'concierge_phase_oriented': {
      _en: 'Get oriented',
      _ar: 'التوجه الأول',
      _hi: 'ओरिएंटेशन',
    },
    'concierge_phase_paperwork': {
      _en: 'Paperwork foundations',
      _ar: 'أساسيات الأوراق',
      _hi: 'कागज़ी काम',
    },
    'concierge_phase_money': {
      _en: 'Money basics',
      _ar: 'أساسيات المال',
      _hi: 'पैसे की बुनियाद',
    },
    'concierge_phase_daily': {
      _en: 'Daily life setup',
      _ar: 'إعداد الحياة اليومية',
      _hi: 'दैनिक जीवन',
    },
    'concierge_phase_housing': {
      _en: 'Settling your space',
      _ar: 'ترتيب مسكنك',
      _hi: 'घर बसाना',
    },
    'concierge_phase_community': {
      _en: 'Community & exploration',
      _ar: 'المجتمع والاستكشاف',
      _hi: 'समुदाय और explore',
    },
    'concierge_phase_rights': {
      _en: 'Know your rights',
      _ar: 'اعرف حقوقك',
      _hi: 'अपने अधिकार जानें',
    },
    'concierge_ms_profile_title': {
      _en: 'Complete your profile basics',
      _ar: 'أكمل أساسيات ملفك',
      _hi: 'प्रोफ़ाइल basics पूरा करें',
    },
    'concierge_ms_profile_desc': {
      _en: 'Nationality and job details help Raabta personalize guidance.',
      _ar: 'الجنسية وتفاصيل العمل تساعد رابطت على تخصيص الإرشاد.',
      _hi: 'Nationality और job details guidance personalize करते हैं।',
    },
    'concierge_ms_profile_action': {_en: 'Open profile', _ar: 'افتح الملف', _hi: 'Profile खोलें'},
    'concierge_ms_eosb_title': {
      _en: 'Check your end-of-service entitlement',
      _ar: 'تحقق من مستحقات نهاية الخدمة',
      _hi: 'EOSB entitlement जांचें',
    },
    'concierge_ms_eosb_desc': {
      _en: 'Use the EOSB Truth Engine — our quick onboarding funnel if you have not yet.',
      _ar: 'استخدم محرك EOSB — مسار الترحيب السريع إن لم تفعل بعد.',
      _hi: 'EOSB Truth Engine use करें — अगर अभी नहीं किया।',
    },
    'concierge_ms_eosb_action': {_en: 'Start EOSB check', _ar: 'ابدأ فحص EOSB', _hi: 'EOSB शुरू करें'},
    'concierge_ms_language_title': {
      _en: 'Set your language preference',
      _ar: 'اضبط لغة التطبيق',
      _hi: 'Language preference सेट करें',
    },
    'concierge_ms_language_desc': {
      _en: 'Raabta works in 8 languages with full RTL support.',
      _ar: 'رابطت متوفرة بـ 8 لغات مع دعم RTL.',
      _hi: 'Raabta 8 भाषाओं में RTL support के साथ।',
    },
    'concierge_ms_language_action': {_en: 'Choose language', _ar: 'اختر اللغة', _hi: 'भाषा चुनें'},
    'concierge_ms_visa_title': {
      _en: 'Review visa & QID step-guides',
      _ar: 'راجع خطوات التأشيرة والإقامة',
      _hi: 'Visa & QID guides देखें',
    },
    'concierge_ms_visa_desc': {
      _en: 'Medical, work permit, and renewal steps in one place.',
      _ar: 'خطوات الفحص الطبي وتصريح العمل والتجديد.',
      _hi: 'Medical, work permit, renewal steps एक जगह।',
    },
    'concierge_ms_visa_action': {_en: 'Open Visa hub', _ar: 'افتح قسم التأشيرة', _hi: 'Visa hub'},
    'concierge_ms_vault_title': {
      _en: 'Scan & save key documents',
      _ar: 'امسح واحفظ مستنداتك',
      _hi: 'Documents scan करके save करें',
    },
    'concierge_ms_vault_desc': {
      _en: 'Passport, contract, and QID — before you need them urgently.',
      _ar: 'جواز، عقد، وبطاقة — قبل أن تحتاجها ب urgency.',
      _hi: 'Passport, contract, QID — जरूरत से पहले।',
    },
    'concierge_ms_vault_action': {_en: 'Open PDF Studio', _ar: 'استوديو PDF', _hi: 'PDF Studio'},
    'concierge_ms_money_title': {
      _en: 'Explore Money Services',
      _ar: 'استكشف خدمات المال',
      _hi: 'Money Services',
    },
    'concierge_ms_money_desc': {
      _en: 'Exchange rates and remittance tools for daily life in Qatar.',
      _ar: 'أسعار الصرف وأدوات التحويل.',
      _hi: 'Exchange rates और remittance tools।',
    },
    'concierge_ms_money_action': {_en: 'Open Money', _ar: 'افتح المال', _hi: 'Money खोलें'},
    'concierge_ms_bills_title': {
      _en: 'Set up Bill Tracker',
      _ar: 'فعّل متتبع الفواتير',
      _hi: 'Bill Tracker setup',
    },
    'concierge_ms_bills_desc': {
      _en: 'Track utilities and personal loans in one calm place.',
      _ar: 'تتبع الفواتير والقروض في مكان واحد.',
      _hi: 'Utilities और loans track करें।',
    },
    'concierge_ms_bills_action': {_en: 'Open Bill Tracker', _ar: 'متتبع الفواتير', _hi: 'Bill Tracker'},
    'concierge_ms_health_ins_title': {
      _en: 'Check employer health insurance',
      _ar: 'تحقق من التأمين الصحي',
      _hi: 'Employer health insurance जांच',
    },
    'concierge_ms_health_ins_desc': {
      _en: 'Confirm compliance early — before a problem arises.',
      _ar: 'تحقق من الامتثال مبكراً.',
      _hi: 'Compliance early confirm करें।',
    },
    'concierge_ms_health_ins_action': {
      _en: 'Run compliance check',
      _ar: 'فحص الامتثال',
      _hi: 'Compliance check',
    },
    'concierge_ms_prayer_title': {
      _en: 'Prayer times & nearby mosques',
      _ar: 'مواقيت الصلاة والمساجد',
      _hi: 'Prayer times & mosques',
    },
    'concierge_ms_prayer_desc': {
      _en: 'Optional — for users who want prayer and Qibla tools.',
      _ar: 'اختياري — لمن يريد مواقيت الصلاة والقبلة.',
      _hi: 'Optional — prayer & Qibla tools।',
    },
    'concierge_ms_prayer_action': {_en: 'Open Prayer hub', _ar: 'مركز الصلاة', _hi: 'Prayer hub'},
    'concierge_ms_ussd_title': {
      _en: 'SIM USSD quick codes',
      _ar: 'أكواد USSD للشريحة',
      _hi: 'SIM USSD codes',
    },
    'concierge_ms_ussd_desc': {
      _en: 'Ooredoo & Vodafone balance and bundle codes.',
      _ar: 'أكواد Ooredoo و Vodafone.',
      _hi: 'Ooredoo & Vodafone codes।',
    },
    'concierge_ms_ussd_action': {_en: 'View USSD codes', _ar: 'عرض الأكواد', _hi: 'USSD codes'},
    'concierge_ms_phrases_title': {
      _en: 'Qatar Arabic phrasebook',
      _ar: 'عبارات قطر العربية',
      _hi: 'Qatar Arabic phrases',
    },
    'concierge_ms_phrases_desc': {
      _en: 'Handy phrases for shops, taxis, and daily errands.',
      _ar: 'عبارات مفيدة للمحلات والتاكسي.',
      _hi: 'Shops, taxis के लिए phrases।',
    },
    'concierge_ms_phrases_action': {_en: 'Open phrasebook', _ar: 'افتح العبارات', _hi: 'Phrasebook'},
    'concierge_ms_driving_title': {
      _en: 'Driving license info',
      _ar: 'معلومات رخصة القيادة',
      _hi: 'Driving license info',
    },
    'concierge_ms_driving_desc': {
      _en: 'Optional — fees, fines, and theory quiz if you plan to drive.',
      _ar: 'اختياري — الرسوم والغرامات واختبار النظرية.',
      _hi: 'Optional — fees, fines, theory quiz।',
    },
    'concierge_ms_driving_action': {_en: 'Driving hub', _ar: 'قسم القيادة', _hi: 'Driving hub'},
    'concierge_ms_housing_title': {
      _en: 'Explore housing listings',
      _ar: 'استكشف السكن',
      _hi: 'Housing listings',
    },
    'concierge_ms_housing_desc': {
      _en: 'Compare areas and listings if you are still finding your place.',
      _ar: 'قارن المناطق والعروض إن كنت تبحث عن سكن.',
      _hi: 'Areas और listings compare करें।',
    },
    'concierge_ms_housing_action': {_en: 'Open Housing', _ar: 'افتح السكن', _hi: 'Housing'},
    'concierge_ms_market_title': {
      _en: 'Furnish with Marketplace',
      _ar: 'أثث من السوق',
      _hi: 'Marketplace से furnish',
    },
    'concierge_ms_market_desc': {
      _en: 'Household items and secondhand goods for a new home.',
      _ar: 'أدوات منزلية ومستعملة لمنزلك الجديد.',
      _hi: 'Household और secondhand items।',
    },
    'concierge_ms_market_action': {_en: 'Browse Marketplace', _ar: 'تصفح السوق', _hi: 'Marketplace'},
    'concierge_ms_community_title': {
      _en: 'Connect with other expats',
      _ar: 'تواصل مع المغتربين',
      _hi: 'Expats से connect',
    },
    'concierge_ms_community_desc': {
      _en: 'Groups and Ask Qatar — questions answered by people who live here.',
      _ar: 'المجموعات واسأل قطر.',
      _hi: 'Groups और Ask Qatar।',
    },
    'concierge_ms_community_action': {_en: 'Open Community', _ar: 'المجتمع', _hi: 'Community'},
    'concierge_ms_trip_title': {
      _en: 'Plan a Qatar weekend trip',
      _ar: 'خطط رحلة في قطر',
      _hi: 'Qatar trip plan',
    },
    'concierge_ms_trip_desc': {
      _en: 'Explore Qatar now that the basics are handled.',
      _ar: 'استكشف قطر بعد انتهاء الأساسيات.',
      _hi: 'Basics के बाद Qatar explore करें।',
    },
    'concierge_ms_trip_action': {_en: 'Trip Planner', _ar: 'مخطط الرحلة', _hi: 'Trip Planner'},
    'concierge_ms_services_title': {
      _en: 'Discover local services',
      _ar: 'اكتشف الخدمات المحلية',
      _hi: 'Local services',
    },
    'concierge_ms_services_desc': {
      _en: 'Browse classified services and business listings.',
      _ar: 'تصفح الخدمات والأعمال المحلية.',
      _hi: 'Services और business listings।',
    },
    'concierge_ms_services_action': {_en: 'Services hub', _ar: 'مركز الخدمات', _hi: 'Services'},
    'concierge_ms_eosb_revisit_title': {
      _en: 'Revisit your EOSB with real data',
      _ar: 'راجع EOSB ببيانات حقيقية',
      _hi: 'Real data से EOSB revisit',
    },
    'concierge_ms_eosb_revisit_desc': {
      _en: 'Update salary and tenure now that you have been working a while.',
      _ar: 'حدّث الراتب ومدة الخدمة بعد فترة عمل.',
      _hi: 'Salary और tenure update करें।',
    },
    'concierge_ms_eosb_revisit_action': {_en: 'EOSB dashboard', _ar: 'لوحة EOSB', _hi: 'EOSB dashboard'},
    'concierge_ms_overtime_title': {
      _en: 'Check overtime entitlement',
      _ar: 'تحقق من overtime',
      _hi: 'Overtime entitlement',
    },
    'concierge_ms_overtime_desc': {
      _en: 'Overtime Truth Engine — compare hours vs employer payment.',
      _ar: 'محرك overtime — قارن الساعات بالدفع.',
      _hi: 'Overtime Truth Engine।',
    },
    'concierge_ms_overtime_action': {_en: 'Overtime hub', _ar: 'مركز overtime', _hi: 'Overtime hub'},
    'concierge_ms_exchange_title': {
      _en: 'Find exchange offices near you',
      _ar: 'مكاتب الصرافة القريبة',
      _hi: 'Exchange offices',
    },
    'concierge_ms_exchange_desc': {
      _en: 'Exchange Locator Pro — useful once remittances become routine.',
      _ar: 'محدد الصرافة — مفيد للتحويلات الدورية.',
      _hi: 'Regular remittances के लिए Exchange Locator।',
    },
    'concierge_ms_exchange_action': {
      _en: 'Exchange Locator',
      _ar: 'محدد الصرافة',
      _hi: 'Exchange Locator',
    },
    'concierge_notif_body': {
      _en: "You've reached a new settling-in stage — here's what's next.",
      _ar: 'وصلت لمرحلة جديدة — إليك الخطوة التالية.',
      _hi: 'नया settling-in stage — अगला कदम देखें।',
    },
  };
}
