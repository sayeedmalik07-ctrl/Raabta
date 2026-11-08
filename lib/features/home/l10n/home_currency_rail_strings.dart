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

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static final _catalog = <String, Map<String, String>>{
    'home_currency_rail_overline': {
      'English': 'Money',
      'Arabic': 'المال',
    },
    'home_currency_rail_title': {
      'English': 'Send money home',
      'Arabic': 'أرسل المال إلى الوطن',
      'Hindi': 'घर पैसा भेजें',
      'Urdu': 'گھر پیسے بھیجیں',
      'Malayalam': 'വീട്ടിലേക്ക് പണം അയയ്‌ക്കുക',
      'Nepali': 'घर पैसा पठाउनुहोस्',
      'Bengali': 'বাড়িতে টাকা পাঠান',
      'Tamil': 'வீட்டுக்கு பணம் அனுப்புங்கள்',
      'Filipino': 'Magpadala ng pera sa bahay',
    },
    'home_currency_rail_subtitle': {
      'English': 'QAR corridors — tap to open Money Hub',
      'Arabic': 'ممرات الريال — اضغط لفتح مركز المال',
    },
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
    },
    'home_currency_indicative_badge': {
      'English': 'Indicative',
      'Arabic': 'إرشادي',
    },
    'home_currency_compare_link': {
      'English': 'Compare exchange houses',
      'Arabic': 'قارن شركات الصرافة',
    },
    'home_currency_updated_now': {
      'English': 'Updated just now',
      'Arabic': 'تم التحديث الآن',
      'Hindi': 'अभी अपडेट किया गया',
      'Urdu': 'ابھی اپ ڈیٹ ہوا',
      'Malayalam': 'Updated just now',
      'Nepali': 'Updated just now',
      'Bengali': 'এইমাত্র আপডেট হয়েছে',
      'Tamil': 'இப்போது புதுப்பிக்கப்பட்டது',
      'Filipino': 'Updated just now',
    },
    'home_currency_updated_minutes': {
      'English': 'Updated {minutes} min ago',
      'Arabic': 'تم التحديث منذ {minutes} د',
      'Hindi': '{minutes} मिनट पहले अपडेट',
      'Urdu': '{minutes} منٹ پہلے اپ ڈیٹ',
      'Malayalam': 'Updated {minutes} min ago',
      'Nepali': 'Updated {minutes} min ago',
      'Bengali': '{minutes} মিনিট আগে আপডেট',
      'Tamil': '{minutes} நிமி. முன்பு புதுப்பிக்கப்பட்டது',
      'Filipino': 'Updated {minutes} min ago',
    },
    'home_currency_updated_one_minute': {
      'English': 'Updated 1 min ago',
      'Arabic': 'تم التحديث منذ دقيقة',
      'Hindi': '1 मिनट पहले अपडेट',
      'Urdu': '1 منٹ پہلے اپ ڈیٹ',
      'Malayalam': 'Updated 1 min ago',
      'Nepali': 'Updated 1 min ago',
      'Bengali': '1 মিনিট আগে আপডেট',
      'Tamil': '1 நிமி. முன்பு புதுப்பிக்கப்பட்டது',
      'Filipino': 'Updated 1 min ago',
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
      'Urdu': 'اس ہفتے {sign}{percent}%',
      'Malayalam': '{sign}{percent}% this week',
      'Nepali': '{sign}{percent}% this week',
      'Bengali': 'এই সপ্তাহে {sign}{percent}%',
      'Tamil': 'இந்த வாரம் {sign}{percent}%',
      'Filipino': '{sign}{percent}% this week',
    },
  };
}
