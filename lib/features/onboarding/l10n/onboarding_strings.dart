/// Onboarding funnel strings — 8 supported app languages.
import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

abstract final class OnboardingStrings {
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

  static const _catalog = <String, Map<String, String>>{
    'welcome_headline': {
      'English': 'Know exactly what you\'re owed when you leave your job',
      'Arabic': 'اعرف بالضبط ما يستحقه لك عند مغادرة عملك',
      'Hindi': 'नौकरी छोड़ते समय आपको क्या मिलना चाहिए, जानें',
      'Urdu': 'نوکری چھوڑتے وقت آپ کو کیا ملنا چاہیے، جانیں',
      'Malayalam': 'ജോലി വിടുമ്പോൾ നിങ്ങൾക്ക് ലഭിക്കേണ്ടത് അറിയുക',
      'Nepali': 'काम छोड्दा तपाईंलाई के पाउनुपर्छ, थाहा पाउनुहोस्',
      'Bengali': 'চাকরি ছাড়ার সময় আপনি কী পাবেন, জানুন',
      'Filipino': 'Alamin kung ano ang dapat mong matanggap kapag umalis sa trabaho',
    },
    'welcome_subline': {
      'English':
          'Raabta compares your employer\'s offer with Qatar labour-law entitlement — starting with your end-of-service benefit.',
      'Arabic':
          'رابطت تقارن عرض صاحب العمل بمستحقات قانون العمل في قطر — بدءاً بمكافأة نهاية الخدمة.',
      'Hindi':
          'Raabta आपके employer के offer की तुलना Qatar labour law entitlement से करती है — EOSB से शुरू।',
      'Urdu':
          'Raabta آپ کے employer کے offer کا Qatar labour law entitlement سے موازنہ کرتی ہے — EOSB سے شروع۔',
      'Malayalam':
          'Raabta നിങ്ങളുടെ employer offer Qatar labour-law entitlement-നോട് താരതമ്യം ചെയ്യുന്നു — EOSB-യിൽ നിന്ന്.',
      'Nepali':
          'Raabta le employer ko offer Qatar labour-law entitlement sanga tulana garcha — EOSB bata suru.',
      'Bengali':
          'Raabta আপনার employer-এর offer Qatar labour-law entitlement-এর সাথে তুলনা করে — EOSB দিয়ে শুরু।',
      'Filipino':
          'Inihahambing ng Raabta ang offer ng employer sa entitlement sa batas ng Qatar — simula sa EOSB.',
    },
    'welcome_cta': {
      'English': 'Check My Entitlement',
      'Arabic': 'تحقق من مستحقاتي',
      'Hindi': 'मेरी entitlement जांचें',
      'Urdu': 'میری entitlement چیک کریں',
      'Malayalam': 'എന്റെ entitlement പരിശോധിക്കുക',
      'Nepali': 'मेरो entitlement जाँच गर्नुहोस्',
      'Bengali': 'আমার entitlement দেখুন',
      'Filipino': 'Suriin ang aking entitlement',
    },
    'welcome_skip': {
      'English': 'Skip for now — I\'ll explore myself',
      'Arabic': 'تخطي الآن — سأستكشف بنفسي',
      'Hindi': 'अभी छोड़ें — मैं खुद देखूंगा',
      'Urdu': 'ابھی skip کریں — خود دیکھوں گا',
      'Malayalam': 'ഇപ്പോൾ skip — ഞാൻ തന്നെ explore ചെയ്യാം',
      'Nepali': 'अहिले skip — म आफै explore गर्छु',
      'Bengali': 'এখন skip — নিজে explore করব',
      'Filipino': 'Laktawan muna — tuklasin ko na lang',
    },
    'qualifier_title': {
      'English': 'Two quick questions',
      'Arabic': 'سؤالان سريعان',
      'Hindi': 'दो त्वरित प्रश्न',
      'Urdu': 'دو فوری سوالات',
      'Malayalam': 'രണ്ട് ചോദ്യങ്ങൾ',
      'Nepali': 'दुई छोटा प्रश्न',
      'Bengali': 'দুটি দ্রুত প্রশ্ন',
      'Filipino': 'Dalawang mabilis na tanong',
    },
    'qualifier_contract': {
      'English': 'Contract type',
      'Arabic': 'نوع العقد',
      'Hindi': 'अनुबंध प्रकार',
      'Urdu': 'معاہدے کی قسم',
      'Malayalam': 'കരാർ തരം',
      'Nepali': 'करार प्रकार',
      'Bengali': 'চুক্তির ধরন',
      'Filipino': 'Uri ng kontrata',
    },
    'qualifier_years': {
      'English': 'Approximate years of service in Qatar',
      'Arabic': 'سنوات الخدمة التقريبية في قطر',
      'Hindi': 'कतर में अनुमानित सेवा वर्ष',
      'Urdu': 'قطر میں تقریباً سروس کے سال',
      'Malayalam': 'ഖatar-ൽ ഏകദേശം സേവന വർഷങ്ങൾ',
      'Nepali': 'Qatar ma lagbhag sewa varsha',
      'Bengali': 'কাতারে আনুমানিক চাকরির বছর',
      'Filipino': 'Tinatayang taon ng serbisyo sa Qatar',
    },
    'qualifier_continue': {
      'English': 'Continue',
      'Arabic': 'متابعة',
      'Hindi': 'जारी रखें',
      'Urdu': 'جاری رکھیں',
      'Malayalam': 'തുടരുക',
      'Nepali': 'जारी राख्नुहोस्',
      'Bengali': 'চালিয়ে যান',
      'Filipino': 'Magpatuloy',
    },
    'contract_unlimited': {
      'English': 'Unlimited contract',
      'Arabic': 'عقد غير محدود',
      'Hindi': 'असीमित अनुबंध',
      'Urdu': 'غیر محدود معاہدہ',
      'Malayalam': 'Unlimited contract',
      'Nepali': 'Unlimited contract',
      'Bengali': 'Unlimited contract',
      'Filipino': 'Unlimited contract',
    },
    'contract_limited': {
      'English': 'Limited contract',
      'Arabic': 'عقد محدود',
      'Hindi': 'सीमित अनुबंध',
      'Urdu': 'محدود معاہدہ',
      'Malayalam': 'Limited contract',
      'Nepali': 'Limited contract',
      'Bengali': 'Limited contract',
      'Filipino': 'Limited contract',
    },
    'form_banner': {
      'English': 'A few more details for your exact number',
      'Arabic': 'بعض التفاصيل الإضافية لرقمك الدقيق',
      'Hindi': 'आपके सटीक número के लिए कुछ और विवरण',
      'Urdu': 'آپ کے exact number کے لیے مزید تفصیلات',
      'Malayalam': 'നിങ്ങളുടെ exact number-ന് കുറച്ച് കൂടി details',
      'Nepali': 'तपाईंको exact number को लागि थप विवरण',
      'Bengali': 'আপনার exact number-এর জন্য আরও কিছু তথ্য',
      'Filipino': 'Ilang detalye pa para sa eksaktong numero',
    },
    'complete_sheet_title': {
      'English': 'You\'re set for your first check',
      'Arabic': 'أنت جاهز لأول فحص',
      'Hindi': 'आपका पहला check तैयार है',
      'Urdu': 'آپ کا پہلا check تیار ہے',
      'Malayalam': 'നിങ്ങളുടെ ആദ്യ check തയ്യാർ',
      'Nepali': 'तपाईंको पहिलो check तयार छ',
      'Bengali': 'আপনার প্রথম check প্রস্তুত',
      'Filipino': 'Handa na ang iyong unang check',
    },
    'complete_sheet_body': {
      'English':
          'This is one of 8 tools in Daily Essentials — explore the rest from Home.',
      'Arabic':
          'هذه واحدة من 8 أدوات في Daily Essentials — استكشف الباقي من الرئيسية.',
      'Hindi':
          'यह Daily Essentials के 8 tools में से एक है — Home से बाकी explore करें।',
      'Urdu':
          'یہ Daily Essentials کے 8 tools میں سے ایک ہے — Home سے باقی explore کریں۔',
      'Malayalam':
          'Daily Essentials-ലെ 8 tools-ൽ ഒന്നാണിത് — Home-ൽ നിന്ന് ബaki explore ചെയ്യുക.',
      'Nepali':
          'Yo Daily Essentials ka 8 tools ma euta ho — Home bata aru explore garnuhos.',
      'Bengali':
          'এটি Daily Essentials-এর 8টি tool-এর একটি — Home থেকে বাকি explore করুন।',
      'Filipino':
          'Isa ito sa 8 tools sa Daily Essentials — tuklasin ang iba mula sa Home.',
    },
    'complete_sheet_cta': {
      'English': 'Go to Home',
      'Arabic': 'الذهاب للرئيسية',
      'Hindi': 'Home पर जाएं',
      'Urdu': 'Home پر جائیں',
      'Malayalam': 'Home-ലേക്ക്',
      'Nepali': 'Home मा जानुहोस्',
      'Bengali': 'Home-এ যান',
      'Filipino': 'Pumunta sa Home',
    },
  };
}
