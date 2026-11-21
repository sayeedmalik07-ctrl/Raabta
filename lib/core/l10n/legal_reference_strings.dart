import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Shared disclosure labels for Truth Engine legal/reference sections.
abstract final class LegalReferenceStrings {
  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static String format(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    var text = t(key, locale);
    for (final entry in params.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  static final _catalog = <String, Map<String, String>>{
    'legal_reference_title': l10nEntry(
      english: 'Legal reference',
      arabic: 'المرجع القانوني',
      hindi: 'कानूनी संदर्भ',
    ),
    'legal_reference_view_basis': l10nEntry(
      english: 'View legal basis',
      arabic: 'عرض الأساس القانوني',
      hindi: 'कानूनी आधार देखें',
    ),
    'legal_reference_item_count': l10nEntry(
      english: '{count} reference points',
      arabic: '{count} نقاط مرجعية',
      hindi: '{count} संदर्भ बिंदु',
    ),
    'truth_engine_source_basis': l10nEntry(
      english: 'Based on: {source}',
      arabic: 'استناداً إلى: {source}',
      hindi: 'Adhar: {source}',
      urdu: 'Bunyad: {source}',
    ),
    'truth_engine_last_verified': l10nEntry(
      english: 'Last verified on {date}',
      arabic: 'آخر تحقق في {date}',
      hindi: 'Last verified: {date}',
      urdu: 'Last verified: {date}',
    ),
    'truth_engine_official_link': l10nEntry(
      english: 'Open official source',
      arabic: 'فتح المصدر الرسمي',
      hindi: 'Official source kholen',
      urdu: 'Official source kholen',
    ),
  };
}
