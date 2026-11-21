import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_coverage.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Truth Engine Home section chrome (attention badge, eye control).
abstract final class HomeTruthEngineSectionStrings {
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
    'home_truth_attention_count': l10nEntry(
      english: '{count} need attention',
      arabic: '{count} تحتاج انتباهاً',
      hindi: '{count} को ध्यान चाहिए',
      urdu: '{count} کو توجہ درکار',
      malayalam: '{count} ശ്രദ്ധ ആവശ്യമാണ്',
      nepali: '{count} लाई ध्यान चाहिन्छ',
      bengali: '{count} জন্য মনোযোগ প্রয়োজন',
      tamil: '{count} கவனம் தேவை',
      filipino: '{count} kailangan ng pansin',
    ),
    'home_truth_eye_show': l10nEntry(
      english: 'Show sensitive details',
      arabic: 'إظهار التفاصيل الحساسة',
      hindi: 'संवेदनशील विवरण दिखाएँ',
      urdu: 'حساس تفصیلات دکھائیں',
      malayalam: 'സെൻസിറ്റീവ് വിവരങ്ങൾ കാണിക്കുക',
      nepali: 'संवेदनशील विवरण देखाउनुहोस्',
      bengali: 'সংবেদনশীল বিবরণ দেখান',
      tamil: 'உணர்திறன் விவரங்களை காட்டு',
      filipino: 'Ipakita ang sensitibong detalye',
    ),
    'home_truth_eye_hide': l10nEntry(
      english: 'Hide sensitive details',
      arabic: 'إخفاء التفاصيل الحساسة',
      hindi: 'संवेदनशील विवरण छिपाएँ',
      urdu: 'حساس تفصیلات چھپائیں',
      malayalam: 'സെൻസിറ്റീവ് വിവരങ്ങൾ മറയ്ക്കുക',
      nepali: 'संवेदनशील विवरण लुकाउनुहोस्',
      bengali: 'সংবেদনশীল বিবরণ লুকান',
      tamil: 'உணர்திறன் விவரங்களை மறை',
      filipino: 'Itago ang sensitibong detalye',
    ),
  };
}
