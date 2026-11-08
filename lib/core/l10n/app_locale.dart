/// Canonical locale keys used by Raabta string catalogs.
///
/// [LanguageScreen] persists display names (e.g. `العربية`) — always normalize
/// through [AppLocale.normalize] before calling `*Strings.t`.
abstract final class AppLocalePickerLabels {
  static const english = 'English';
  static const arabic = 'العربية';
  static const urdu = 'اردو';
  static const hindi = 'हिंदी';
  static const filipino = 'Filipino';
  static const bengali = 'বাংলা';
  static const malayalam = 'Malayalam';
  static const nepali = 'Nepali';
  static const tamil = 'தமிழ்';

  /// Default quick-toggle pair for Home shortcut (English ↔ Arabic).
  static const quickToggleA = english;
  static const quickToggleB = arabic;
}

abstract final class AppLocale {
  /// Nine catalog locale keys — includes Malayalam/Nepali for onboarding/catalog
  /// slots even though they are omitted from the primary language picker.
  static const supportedLocales = [
    'English',
    'Arabic',
    'Hindi',
    'Urdu',
    'Malayalam',
    'Nepali',
    'Bengali',
    'Tamil',
    'Filipino',
  ];

  /// Maps persisted picker labels and legacy values to catalog locale keys.
  static String normalize(String? stored) {
    if (stored == null || stored.trim().isEmpty) return 'English';
    switch (stored.trim()) {
      case 'English':
        return 'English';
      case 'Arabic':
      case 'العربية':
        return 'Arabic';
      case 'Hindi':
      case 'हिंदी':
        return 'Hindi';
      case 'Urdu':
      case 'اردو':
        return 'Urdu';
      case 'Malayalam':
        return 'Malayalam';
      case 'Nepali':
        return 'Nepali';
      case 'Bengali':
      case 'বাংলা':
        return 'Bengali';
      case 'Filipino':
        return 'Filipino';
      case 'Tamil':
      case 'தமிழ்':
        return 'Tamil';
      default:
        return supportedLocales.contains(stored) ? stored : 'English';
    }
  }

  static bool isRtl(String locale) {
    final normalized = normalize(locale);
    return normalized == 'Arabic' || normalized == 'Urdu';
  }

  /// BCP-47-ish code for Material [Locale] / [Directionality].
  static String toLanguageCode(String locale) {
    switch (normalize(locale)) {
      case 'Arabic':
        return 'ar';
      case 'Hindi':
        return 'hi';
      case 'Urdu':
        return 'ur';
      case 'Malayalam':
        return 'ml';
      case 'Nepali':
        return 'ne';
      case 'Bengali':
        return 'bn';
      case 'Tamil':
        return 'ta';
      case 'Filipino':
        return 'fil';
      default:
        return 'en';
    }
  }

  /// Reverse map — catalog key → persisted picker label.
  static String toPickerLabel(String locale) {
    switch (normalize(locale)) {
      case 'Arabic':
        return AppLocalePickerLabels.arabic;
      case 'Hindi':
        return AppLocalePickerLabels.hindi;
      case 'Urdu':
        return AppLocalePickerLabels.urdu;
      case 'Bengali':
        return AppLocalePickerLabels.bengali;
      case 'Filipino':
        return AppLocalePickerLabels.filipino;
      case 'Tamil':
        return AppLocalePickerLabels.tamil;
      case 'Malayalam':
        return AppLocalePickerLabels.malayalam;
      case 'Nepali':
        return AppLocalePickerLabels.nepali;
      default:
        return AppLocalePickerLabels.english;
    }
  }

  /// Short chip label for Home toggle (EN / ع / …).
  static String chipLabel(String locale) {
    switch (normalize(locale)) {
      case 'Arabic':
        return 'ع';
      case 'Hindi':
        return 'ह';
      case 'Urdu':
        return 'Ur';
      case 'Bengali':
        return 'ব';
      case 'Filipino':
        return 'PH';
      case 'Tamil':
        return 'TA';
      case 'Malayalam':
        return 'ML';
      case 'Nepali':
        return 'NE';
      default:
        return 'EN';
    }
  }
}
