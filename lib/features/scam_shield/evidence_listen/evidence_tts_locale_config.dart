import 'package:raabta/core/l10n/app_locale.dart';

/// Maps Raabta catalog locales to on-device TTS BCP-47 tags (Phase 22).
abstract final class EvidenceTtsLocaleConfig {
  static const slowByDefaultLocales = {
    'Arabic',
    'Hindi',
    'Urdu',
    'Malayalam',
    'Nepali',
    'Bengali',
    'Tamil',
    'Filipino',
  };

  static bool prefersSlowSpeech(String locale) {
    return slowByDefaultLocales.contains(AppLocale.normalize(locale));
  }

  /// Candidate tags in priority order for [FlutterTts.isLanguageAvailable].
  static List<String> ttsCandidatesFor(String locale) {
    switch (AppLocale.normalize(locale)) {
      case 'Arabic':
        return ['ar-QA', 'ar-SA', 'ar'];
      case 'Hindi':
        return ['hi-IN', 'hi'];
      case 'Urdu':
        return ['ur-PK', 'ur-IN', 'ur'];
      case 'Malayalam':
        return ['ml-IN', 'ml'];
      case 'Nepali':
        return ['ne-NP', 'ne-IN', 'ne'];
      case 'Bengali':
        return ['bn-IN', 'bn-BD', 'bn'];
      case 'Tamil':
        return ['ta-IN', 'ta'];
      case 'Filipino':
        return ['fil-PH', 'en-PH', 'fil'];
      default:
        return ['en-US', 'en-GB', 'en'];
    }
  }

  static double speechRate({required bool slow}) => slow ? 0.42 : 0.55;
}
