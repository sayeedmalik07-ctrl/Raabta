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

  @visibleForTesting
  static Map<String, Set<String>> get localeCoverageReport =>
      buildLocaleCoverageReport(
        catalog: _catalog,
        supportedLocales: supportedLocales,
      );

  static const _catalog = <String, Map<String, String>>{
    'home_ramadan_overline': {
      'English': 'Seasonal',
      'Arabic': 'موسمي',
    },
    'home_ramadan_pre_title': {
      'English': 'Ramadan is approaching',
      'Arabic': 'رمضان يقترب',
    },
    'home_ramadan_pre_countdown': {
      'English': '{days} days until Ramadan',
      'Arabic': 'متبقٍ {days} يوم على رمضان',
    },
    'home_ramadan_pre_tomorrow': {
      'English': 'Ramadan starts tomorrow',
      'Arabic': 'يبدأ رمضان غداً',
    },
    'home_ramadan_during_title': {
      'English': 'Ramadan Mubarak',
      'Arabic': 'رمضان مبارك',
    },
    'home_ramadan_during_subtitle': {
      'English': 'Day {day} · Ramadan {year} AH',
      'Arabic': 'اليوم {day} · رمضان {year} هـ',
    },
    'home_ramadan_cta_primary': {
      'English': 'Ramadan Companion',
      'Arabic': 'رفيق رمضان',
    },
    'home_ramadan_cta_zakat': {
      'English': 'Zakat',
      'Arabic': 'الزكاة',
    },
    'home_ramadan_countdown_badge': {
      'English': '{days}d',
      'Arabic': '{days} ي',
    },
  };
}
