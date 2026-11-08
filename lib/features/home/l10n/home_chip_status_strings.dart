import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Home chip micro-line copy (Part A status lines).
abstract final class HomeChipStatusStrings {
  static const supportedLocales = AppLocale.supportedLocales;

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
    params.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'home_chip_eosb_saved': l10nEntry(
      english: 'Estimate saved',
      arabic: 'تم حفظ التقدير',
      hindi: 'अनुमान सहेजा गया',
      urdu: 'تخمینہ محفوظ',
      malayalam: 'അനുമാനം സേവ് ചെയ്തു',
      nepali: 'अनुमान सुरक्षित',
      bengali: 'অনুমান সংরক্ষিত',
      tamil: 'மதிப்பீடு சேமிக்கப்பட்டது',
      filipino: 'Na-save ang estimate',
    ),
    'home_chip_eosb_empty': l10nEntry(
      english: 'Check your gratuity',
      arabic: 'تحقق من مكافأة نهاية الخدمة',
      hindi: 'अपनी ग्रेच्युटी जाँचें',
      urdu: 'اپنی گریچuity چیک کریں',
      malayalam: 'നിങ്ങളുടെ ഗ്രാച്ചuity പരിശോധിക്കുക',
      nepali: 'आफ्नो ग्रेच्युटी जाँच गर्नुहोस्',
      bengali: 'আপনার গ্র্যাচুইটি যাচাই করুন',
      tamil: 'உங்கள் கிராசuityயை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong gratuity',
    ),
    'home_chip_st_empty': l10nEntry(
      english: 'Check your rights',
      arabic: 'تحقق من حقوقك',
      hindi: 'अपने अधिकार जाँचें',
      urdu: 'اپنے حقوق چیک کریں',
      malayalam: 'നിങ്ങളുടെ അവകാശങ്ങൾ പരിശോധിക്കുക',
      nepali: 'आफ्ना अधिकार जाँच गर्नुहोस्',
      bengali: 'আপনার অধিকার যাচাই করুন',
      tamil: 'உங்கள் உரிமைகளை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong mga karapatan',
    ),
    'home_chip_tenancy_saved': l10nEntry(
      english: 'Lease check saved',
      arabic: 'تم حفظ فحص الإيجار',
      hindi: 'लीज जाँच सहेजी गई',
      urdu: 'لیز چیک محفوظ',
      malayalam: 'ലീസ് പരിശോധന സേവ് ചെയ്തു',
      nepali: 'भाडा जाँच सुरक्षित',
      bengali: 'ভাড়া যাচাই সংরক্ষিত',
      tamil: 'குத்தகை சரிபார்ப்பு சேமிக்கப்பட்டது',
      filipino: 'Na-save ang lease check',
    ),
    'home_chip_tenancy_empty': l10nEntry(
      english: 'Check your lease',
      arabic: 'تحقق من عقد الإيجار',
      hindi: 'अपना लीज़ जाँचें',
      urdu: 'اپنا لیز چیک کریں',
      malayalam: 'നിങ്ങളുടെ ലീസ് പരിശോധിക്കുക',
      nepali: 'आफ्नो भाडा सम्झौता जाँच गर्नुहोस्',
      bengali: 'আপনার ভাড়া চুক্তি যাচাই করুন',
      tamil: 'உங்கள் குத்தகையை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong lease',
    ),
    'home_chip_hi_checked': l10nEntry(
      english: 'Policy checked',
      arabic: 'تم فحص الوثيقة',
      hindi: 'पॉलिसी जाँची गई',
      urdu: 'پالیسی چیک ہو گئی',
      malayalam: 'പോളിസി പരിശോധിച്ചു',
      nepali: 'पोलिसी जाँच भयो',
      bengali: 'পলিসি যাচাই হয়েছে',
      tamil: 'காப்பீடு சரிபார்க்கப்பட்டது',
      filipino: 'Nasuri ang policy',
    ),
    'home_chip_hi_empty': l10nEntry(
      english: 'Check your policy',
      arabic: 'تحقق من وثيقتك',
      hindi: 'अपनी पॉलिसी जाँचें',
      urdu: 'اپنی پالیسی چیک کریں',
      malayalam: 'നിങ്ങളുടെ പോളിസി പരിശോധിക്കുക',
      nepali: 'आफ्नो पोलिसी जाँच गर्नुहोस्',
      bengali: 'আপনার পলিসি যাচাই করুন',
      tamil: 'உங்கள் காப்பீட்டை சரிபாருங்கள்',
      filipino: 'Suriin ang iyong policy',
    ),
    'home_chip_warranty_expiring': l10nEntry(
      english: '{count} expiring soon',
      arabic: '{count} تنتهي قريباً',
      hindi: '{count} जल्द समाप्त',
      urdu: '{count} جلد ختم',
      malayalam: '{count} ഉടൻ കാലാവധി',
      nepali: '{count} चाँडै सकिने',
      bengali: '{count} শীঘ্রই মেয়াদ শেষ',
      tamil: '{count} விரைவில் காலாவதி',
      filipino: '{count} malapit nang mag-expire',
    ),
    'home_chip_warranty_empty': l10nEntry(
      english: 'Add a warranty',
      arabic: 'أضف ضماناً',
      hindi: 'वारंटी जोड़ें',
      urdu: 'وارنٹی شامل کریں',
      malayalam: 'വാറന്റി ചേർക്കുക',
      nepali: 'वारेन्टी थप्नुहोस्',
      bengali: 'ওয়ারেন্টি যোগ করুন',
      tamil: 'வாரண்டி சேர்க்கவும்',
      filipino: 'Magdagdag ng warranty',
    ),
    'home_chip_bill_empty': l10nEntry(
      english: 'Add a bill',
      arabic: 'أضف فاتورة',
      hindi: 'बिल जोड़ें',
      urdu: 'بل شامل کریں',
      malayalam: 'ബിൽ ചേർക്കുക',
      nepali: 'बिल थप्नुहोस्',
      bengali: 'বিল যোগ করুন',
      tamil: 'பில் சேர்க்கவும்',
      filipino: 'Magdagdag ng bill',
    ),
    'home_chip_split_static': l10nEntry(
      english: 'Split with friends',
      arabic: 'قسّم مع الأصدقاء',
      hindi: 'दोस्तों के साथ बाँटें',
      urdu: 'دوستوں کے ساتھ تقسیم',
      malayalam: 'സുഹൃത്തുക്കളുമായി പങ്കിടുക',
      nepali: 'साथीहरूसँग बाँड्नुहोस्',
      bengali: 'বন্ধুদের সাথে ভাগ করুন',
      tamil: 'நண்பர்களுடன் பிரிக்கவும்',
      filipino: 'Hatiin kasama ang mga kaibigan',
    ),
    'home_chip_heat_fallback': l10nEntry(
      english: 'Check today\'s heat',
      arabic: 'تحقق من حرارة اليوم',
      hindi: 'आज की गर्मी जाँचें',
      urdu: 'آج کی گرمی چیک کریں',
      malayalam: 'ഇന്നത്തെ ചൂട് പരിശോധിക്കുക',
      nepali: 'आजको तापक्रम जाँच गर्नुहोस्',
      bengali: 'আজকের তাপ যাচাই করুন',
      tamil: 'இன்றைய வெப்பத்தை சரிபாருங்கள்',
      filipino: 'Suriin ang init ngayon',
    ),
    'home_chip_trip_empty': l10nEntry(
      english: 'Plan a trip',
      arabic: 'خطط لرحلة',
      hindi: 'यात्रा की योजना बनाएं',
      urdu: 'سفر کی منصوبہ بندی',
      malayalam: 'യാത്ര ആസൂത്രണം ചെയ്യുക',
      nepali: 'यात्रा योजना बनाउनुहोस्',
      bengali: 'ভ্রমণ পরিকল্পনা করুন',
      tamil: 'பயணம் திட்டமிடுங்கள்',
      filipino: 'Magplano ng biyahe',
    ),
    'home_chip_queue_static': l10nEntry(
      english: 'Crowd reports',
      arabic: 'تقارير الزحام',
      hindi: 'भीड़ की रिपोर्ट',
      urdu: 'ہجوم کی رپورٹس',
      malayalam: 'തിരക്ക് റിപ്പോർട്ടുകൾ',
      nepali: 'भीड रिपोर्ट',
      bengali: 'ভিড়ের রিপোর্ট',
      tamil: 'கூட்ட அறிக்கைகள்',
      filipino: 'Mga ulat ng tao',
    ),
    'home_chip_know_qatar_static': l10nEntry(
      english: 'Rules, costs, tips',
      arabic: 'قواعد وتكاليف ونصائح',
      hindi: 'नियम, खर्च, सुझाव',
      urdu: 'قواعد، اخراجات، تجاویز',
      malayalam: 'നിയമങ്ങൾ, ചെലവ്, ടിപ്പുകൾ',
      nepali: 'नियम, खर्च, सुझाव',
      bengali: 'নিয়ম, খরচ, টিপস',
      tamil: 'விதிகள், செலவு, ஆலோசனைகள்',
      filipino: 'Mga tuntunin, gastos, tips',
    ),
    'home_chip_arabic_static': l10nEntry(
      english: 'Practice phrases',
      arabic: 'تدرّب على العبارات',
      hindi: 'वाक्यांश अभ्यास',
      urdu: 'جملوں کی مشق',
      malayalam: 'വാക്യങ്ങൾ പരിശീലിക്കുക',
      nepali: 'वाक्यांश अभ्यास',
      bengali: 'বাক্যাংশ অনুশীলন',
      tamil: 'சொற்றொடர்கள் பயிற்சி',
      filipino: 'Magsanay ng mga parirala',
    ),
  };
}
