import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/locale_catalog_entry.dart';

/// Labels for [TruthConfidenceBanner] — plain language, no numeric confidence.
abstract final class TruthConfidenceStrings {
  static String t(String key, [String locale = 'English']) {
    final normalized = AppLocale.normalize(locale);
    final map = _catalog[key];
    if (map == null) return key;
    return map[normalized] ?? map['English'] ?? key;
  }

  static final _catalog = <String, Map<String, String>>{
    'truth_confidence_known_label': l10nEntry(
      english: 'Confirmed from your information',
      arabic: 'مؤكد من معلوماتك',
    ),
    'truth_confidence_possible_label': l10nEntry(
      english: 'May apply — worth checking',
      arabic: 'قد ينطبق — يستحق التحقق',
    ),
    'truth_confidence_unknown_label': l10nEntry(
      english: 'Not something Raabta can confirm',
      arabic: 'ليس مما يمكن لـ Raabta تأكيده',
    ),
    'truth_confidence_action_label': l10nEntry(
      english: 'What to do next',
      arabic: 'ما يمكنك فعله بعد ذلك',
    ),
  };
}
