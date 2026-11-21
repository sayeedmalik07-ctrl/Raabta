import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Home currency rail — English and Arabic required; others fall back to English.
abstract final class HomeCurrencyRailStrings {
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

  /// Strict nine-locale coverage inventory (J1 — no runtime behavior change).
  static Map<String, Map<String, String>> get catalogForStrictCoverage =>
      _catalog;

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  @visibleForTesting
  static Map<String, Set<String>> get strictLocaleCoverageReport =>
      buildLocaleCoverageReport(
        catalog: catalogForStrictCoverage,
        supportedLocales: supportedLocales,
        fillMissingWithEnglish: false,
      );

  static final _catalog = <String, Map<String, String>>{
    'home_currency_rail_overline': {
      'English': 'Money',
      'Arabic': 'المال',
      'Hindi': 'धन',
      'Urdu': 'مال',
      'Malayalam': 'പണം',
      'Nepali': 'पैसा',
      'Bengali': 'টাকা',
      'Tamil': 'பணம்',
      'Filipino': 'Pera',
    },
    'home_currency_rail_title': {
      'English': 'Home country rates',
      'Arabic': 'أسعار الوطن',
      'Hindi': 'गृह देश की दरें',
      'Urdu': 'وطن کی شرحیں',
      'Malayalam': 'നാട്ടിലെ നിരക്കുകൾ',
      'Nepali': 'गृह देशका दरहरू',
      'Bengali': 'নিজ দেশের হার',
      'Tamil': 'தாய்நாட்டு விகிதங்கள்',
      'Filipino': 'Mga rate sa bayan',
    },
    'home_currency_rail_subtitle': {
      'English': 'Indicative QAR corridors — compare in Money Hub',
      'Arabic': 'ممرات الريال الإرشادية — قارن في مركز المال',
      'Hindi': 'सूचक QAR कॉरिडोर — Money Hub में तुलना करें',
      'Urdu': 'اشارتی QAR راہداری — Money Hub میں موازنہ کریں',
      'Malayalam': 'സൂചക QAR ഇടനാഴികൾ — Money Hub-ൽ താരതമ്യം ചെയ്യുക',
      'Nepali': 'सङ्केतात्मक QAR कोरिडोरहरू — Money Hub मा तुलना गर्नुहोस्',
      'Bengali': 'ইঙ্গিতকারী QAR করিডোর — Money Hub-এ তুলনা করুন',
      'Tamil': 'குறிப்பு QAR தாழ்வாரங்கள் — Money Hub-ல் ஒப்பிடுங்கள்',
      'Filipino': 'Indikativong QAR corridor — ihambing sa Money Hub',
    },
    'home_currency_indicative_disclaimer': l10nEntry(
      english: 'Indicative mid-market rates — Raabta does not transfer money.',
      arabic: 'أسعار إرشادية من السوق — رابتة لا تحوّل الأموال.',
      hindi: 'सूचक मध्य-बाज़ार दरें — Raabta पैसे नहीं भेजता।',
      urdu: 'اشارتی درمیانی مارکیٹ شرحیں — Raabta رقم منتقل نہیں کرتا۔',
      malayalam: 'സൂചക മിഡ്-മാർക്കറ്റ് നിരക്കുകൾ — Raabta പണം കൈമാറുന്നില്ല.',
      nepali: 'सङ्केतात्मक मध्य-बजार दरहरू — Raabta ले पैसा सार्दैन।',
      bengali: 'ইঙ্গিতকারী মিড-মার্কেট হার — Raabta টাকা পাঠায় না।',
      tamil: 'குறிப்பு மிட்-மார்க்கெட் விகிதங்கள் — Raabta பணம் அனுப்பாது.',
      filipino:
          'Indikativong mid-market rate — hindi naglilipat ng pera ang Raabta.',
    ),
    'home_currency_rail_rate': {
      'English': '1 QAR = {rate} {code}',
      'Arabic': '1 ر.ق = {rate} {code}',
      'Hindi': '1 कतरी रियाल = {rate} {code}',
      'Urdu': '1 قطری ریال = {rate} {code}',
      'Malayalam': '1 ഖത്തർ റിയാൽ = {rate} {code}',
      'Nepali': '1 कतारी रियाल = {rate} {code}',
      'Bengali': '1 কাতারি রিয়াল = {rate} {code}',
      'Tamil': '1 கத்தார் ரியால் = {rate} {code}',
      'Filipino': '1 riyal ng Qatar = {rate} {code}',
    },
    'home_currency_rail_unavailable': {
      'English': 'Rates unavailable right now',
      'Arabic': 'الأسعار غير متاحة حالياً',
      'Hindi': 'दरें अभी उपलब्ध नहीं हैं',
      'Urdu': 'ابھی دستیاب نہیں ہیں۔',
      'Malayalam': 'നിരക്കുകൾ ഇപ്പോൾ ലഭ്യമല്ല',
      'Nepali': 'दरहरू अहिले उपलब्ध छैन',
      'Bengali': 'রেট এই মুহূর্তে অনুপলব্ধ',
      'Tamil': 'விலைகள் இப்போது கிடைக்கவில்லை',
      'Filipino': 'Hindi available ang mga rate sa ngayon',
    },
    'home_currency_indicative_badge': {
      'English': 'Indicative',
      'Arabic': 'إرشادي',
      'Hindi': 'सूचक',
      'Urdu': 'سوچک',
      'Malayalam': 'സൂചകമാണ്',
      'Nepali': 'सूचक',
      'Bengali': 'নির্দেশক',
      'Tamil': 'குறிக்கும்',
      'Filipino': 'Nagpapahiwatig',
    },
    'home_currency_live_indicative': l10nEntry(
      english: 'Live indicative',
      arabic: 'إرشادي مباشر',
      hindi: 'सजीव सूचक',
      urdu: 'زندہ اشارے',
      malayalam: 'ലൈവ് സൂചന',
      nepali: 'प्रत्यक्ष सूचक',
      bengali: 'লাইভ ইঙ্গিতকারী',
      tamil: 'நேரடி குறிப்பு',
      filipino: 'Live na nagpapahiwatig',
    ),
    'home_currency_compare_link': {
      'English': 'Compare exchange houses',
      'Arabic': 'قارن شركات الصرافة',
      'Hindi': 'विनिमय गृहों की तुलना करें',
      'Urdu': 'تبادلے کے گھروں کی موازنہ کریں۔',
      'Malayalam': 'എക്സ്ചേഞ്ച് ഹൗസുകൾ താരതമ്യം ചെയ്യുക',
      'Nepali': 'विनिमय घरहरू तुलना गर्नुहोस्',
      'Bengali': 'বিনিময় ঘর তুলনা',
      'Tamil': 'பரிமாற்ற வீடுகளை ஒப்பிடுக',
      'Filipino': 'Ikumpara ang mga exchange house',
    },
    'home_currency_updated_now': {
      'English': 'Updated just now',
      'Arabic': 'تم التحديث الآن',
      'Hindi': 'अभी अपडेट किया गया',
      'Urdu': 'ابھی اپ ڈیٹ کیا گیا',
      'Malayalam': 'ഇപ്പോൾ അപ്ഡേറ്റ് ചെയ്തു',
      'Nepali': 'भर्खरै अपडेट गरियो',
      'Bengali': 'এইমাত্র আপডেট হয়েছে',
      'Tamil': 'இப்போது புதுப்பிக்கப்பட்டது',
      'Filipino': 'Ngayon lang na-update',
    },
    'home_currency_updated_minutes': {
      'English': 'Updated {minutes} min ago',
      'Arabic': 'تم التحديث منذ {minutes} د',
      'Hindi': '{मिनट} मिनट पहले अपडेट किया गया {minutes}',
      'Urdu': '{منٹ} منٹ پہلے اپ ڈیٹ کیا گیا {منٹ} {minutes}',
      'Malayalam': '{minutes} മിനിറ്റ് മുമ്പ് അപ്‌ഡേറ്റ് ചെയ്‌തു',
      'Nepali': '{minutes} मिनेट पहिले अपडेट गरिएको',
      'Bengali': '{minutes} মিনিট আগে আপডেট',
      'Tamil': '{minutes} நிமி. முன்பு புதுப்பிக்கப்பட்டது',
      'Filipino': 'Na-update {minutes} min ang nakalipas',
    },
    'home_currency_updated_one_minute': {
      'English': 'Updated 1 min ago',
      'Arabic': 'تم التحديث منذ دقيقة',
      'Hindi': '1 मिनट पहले अपडेट किया गया',
      'Urdu': '1 منٹ پہلے اپ ڈیٹ کیا گیا۔',
      'Malayalam': '1 മിനിറ്റ് മുമ്പ് അപ്‌ഡേറ്റ് ചെയ്‌തു',
      'Nepali': '१ मिनेट पहिले अद्यावधिक गरिएको',
      'Bengali': '1 মিনিট আগে আপডেট',
      'Tamil': '1 நிமி. முன்பு புதுப்பிக்கப்பட்டது',
      'Filipino': 'Na-update 1 min ang nakalipas',
    },
    'home_currency_updated_indicative': l10nEntry(
      english: 'Indicative rate',
      arabic: 'سعر إرشادي',
      hindi: 'संकेतक दर',
      urdu: 'اشارتی شرح',
      malayalam: 'സൂചക നിരക്ക്',
      nepali: 'सङ्केतात्मक दर',
      bengali: 'ইঙ্গিতকারী হার',
      tamil: 'குறிப்பு விகிதம்',
      filipino: 'Indikativong rate',
    ),
    'home_currency_weekly_change': {
      'English': '{sign}{percent}% this week',
      'Arabic': '{sign}{percent}% هذا الأسبوع',
      'Hindi': 'इस सप्ताह {sign}{percent}%',
      'Urdu': 'اس ہفتہ {sign}{percent}%',
      'Malayalam': 'ഈ ആഴ്‌ച {sign}{percent}%',
      'Nepali': 'यो हप्ता {sign}{percent}%',
      'Bengali': 'এই সপ্তাহে {sign}{percent}%',
      'Tamil': 'இந்த வாரம் {sign}{percent}%',
      'Filipino': '{sign}{percent}% ngayong linggo',
    },
  };
}
