import 'package:raabta/core/l10n/app_locale.dart';

/// Maps Raabta app locale → speech-to-text BCP-47 locale for voice input.
abstract final class LandmarkSttLocale {
  static String forAppLocale(String locale) {
    switch (AppLocale.normalize(locale)) {
      case 'Arabic':
        return 'ar-QA';
      case 'Hindi':
        return 'hi-IN';
      case 'Urdu':
        return 'ur-PK';
      case 'Malayalam':
        return 'ml-IN';
      case 'Nepali':
        return 'ne-NP';
      case 'Bengali':
        return 'bn-BD';
      case 'Filipino':
        return 'fil-PH';
      default:
        return 'en-US';
    }
  }

  /// Human-readable language name for the AI translation prompt.
  static String languageNameForPrompt(String locale) {
    switch (AppLocale.normalize(locale)) {
      case 'Arabic':
        return 'Arabic';
      case 'Hindi':
        return 'Hindi';
      case 'Urdu':
        return 'Urdu';
      case 'Malayalam':
        return 'Malayalam';
      case 'Nepali':
        return 'Nepali';
      case 'Bengali':
        return 'Bengali';
      case 'Filipino':
        return 'Filipino';
      default:
        return 'English';
    }
  }
}
