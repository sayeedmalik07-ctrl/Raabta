import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';

/// Home Ramadan seasonal card — English and Arabic required; others fall back to English.
abstract final class HomeRamadanStrings {
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

  static const _catalog = <String, Map<String, String>>{
    'home_ramadan_overline': {
      'English': 'Seasonal',
      'Arabic': 'موسمي',
      'Hindi': 'मौसमी',
      'Urdu': 'موسمی',
      'Malayalam': 'സീസണൽ',
      'Nepali': 'मौसमी',
      'Bengali': 'মৌসুমী',
      'Tamil': 'பருவகால',
      'Filipino': 'Pana-panahon',
    },
    'home_ramadan_pre_title': {
      'English': 'Ramadan is approaching',
      'Arabic': 'رمضان يقترب',
      'Hindi': 'रमज़ान करीब आ रहा है',
      'Urdu': 'رمضان قریب آ رہا ہے۔',
      'Malayalam': 'റമദാൻ അടുത്തുവരികയാണ്',
      'Nepali': 'रमजान नजिकिदै छ',
      'Bengali': 'রমজান ঘনিয়ে আসছে',
      'Tamil': 'ரமலான் நெருங்கி வருகிறது',
      'Filipino': 'Malapit na ang Ramadan',
    },
    'home_ramadan_pre_countdown': {
      'English': '{days} days until Ramadan',
      'Arabic': 'متبقٍ {days} يوم على رمضان',
      'Hindi': 'रमज़ान शुरू होने में {days} दिन',
      'Urdu': 'رمضان میں {days} دن باقی',
      'Malayalam': 'റമദാൻ വരെ {days} ദിവസം',
      'Nepali': 'रमजान अघि {days} दिन',
      'Bengali': 'রমজানে আর {days} দিন',
      'Tamil': 'ரமலானுக்கு இன்னும் {days} நாள்',
      'Filipino': '{days} araw hanggang Ramadan',
    },
    'home_ramadan_pre_tomorrow': {
      'English': 'Ramadan starts tomorrow',
      'Arabic': 'يبدأ رمضان غداً',
      'Hindi': 'रमज़ान कल से शुरू हो रहा है',
      'Urdu': 'کل سے رمضان شروع ہو رہا ہے۔',
      'Malayalam': 'നാളെയാണ് റമദാൻ ആരംഭിക്കുന്നത്',
      'Nepali': 'भोलिदेखि रमजान सुरु हुँदैछ',
      'Bengali': 'আগামীকাল থেকে শুরু হচ্ছে রমজান মাস',
      'Tamil': 'ரம்ஜான் நாளை தொடங்குகிறது',
      'Filipino': 'Magsisimula na ang Ramadan bukas',
    },
    'home_ramadan_during_title': {
      'English': 'Ramadan Mubarak',
      'Arabic': 'رمضان مبارك',
      'Hindi': 'रमदान मुबारक',
      'Urdu': 'رمضان مبارک',
      'Malayalam': 'റമദാൻ മുബാറക്',
      'Nepali': 'रमजान मुबारक',
      'Bengali': 'রমজান মোবারক',
      'Tamil': 'ரமலான் முபாரக்',
      'Filipino': 'Maligayang Ramadan',
    },
    'home_ramadan_during_subtitle': {
      'English': 'Day {day} · Ramadan {year} AH',
      'Arabic': 'اليوم {day} · رمضان {year} هـ',
      'Hindi': 'दिन {day} · रमज़ान {year} हि',
      'Urdu': 'دن {day} · رمضان {year} ہجری',
      'Malayalam': 'ദിവസം {day} · റമദാൻ {year} AH',
      'Nepali': 'दिन {day} · रमजान {year} हि',
      'Bengali': 'দিন {day} · রমজান {year} হিজরি',
      'Tamil': 'நாள் {day} · ரமலான் {year} AH',
      'Filipino': 'Araw {day} · Ramadan {year} AH',
    },
    'home_ramadan_cta_primary': {
      'English': 'Ramadan Companion',
      'Arabic': 'رفيق رمضان',
      'Hindi': 'रमज़ान साथी',
      'Urdu': 'رمضان ساتھی',
      'Malayalam': 'റമദാൻ സഹയാത്രികൻ',
      'Nepali': 'रमजान साथी',
      'Bengali': 'রমজানের সাথী',
      'Tamil': 'ரமலான் தோழர்',
      'Filipino': 'Kasamang Ramadan',
    },
    'home_ramadan_cta_zakat': {
      'English': 'Zakat',
      'Arabic': 'الزكاة',
      'Hindi': 'जकात',
      'Urdu': 'زکوٰۃ',
      'Malayalam': 'സകാത്ത്',
      'Nepali': 'जकात',
      'Bengali': 'যাকাত',
      'Tamil': 'ஜகாத்',
      'Filipino': 'Zakat (alms)',
    },
    'home_ramadan_countdown_badge': {
      'English': '{days}d',
      'Arabic': '{days} ي',
      'Hindi': '{days} दिन',
      'Urdu': '{days} دن',
      'Malayalam': '{days} ദിവസം',
      'Nepali': '{days} दिन',
      'Bengali': '{days} দিন',
      'Tamil': '{days} நா',
      'Filipino': '{days} araw',
    },
  };
}
