import 'app_locale.dart';

/// One selectable language in LanguageScreen / ProfileLanguageScreen.
class AppLocalePickerOption {
  const AppLocalePickerOption({
    required this.flag,
    required this.pickerLabel,
    required this.headline,
  });

  /// Emoji flag shown on the tile.
  final String flag;

  /// Value persisted to [LanguageScreen.languageKey] — native script or English.
  final String pickerLabel;

  /// Headline shown when this option is selected (in that language).
  final String headline;

  /// Normalized catalog locale key (English, Arabic, …).
  String get catalogLocale => AppLocale.normalize(pickerLabel);
}

/// Shared picker configuration — keep LanguageScreen and Profile in sync.
abstract final class AppLocalePicker {
  /// Primary user-facing languages (7 options).
  ///
  /// [AppLocale.supportedLocales] also includes Malayalam and Nepali for
  /// onboarding flows and catalog slots — intentionally omitted here
  /// (see docs/L10N.md).
  static const primaryOptions = <AppLocalePickerOption>[
    AppLocalePickerOption(
      flag: '🇬🇧',
      pickerLabel: AppLocalePickerLabels.english,
      headline: 'Choose your language',
    ),
    AppLocalePickerOption(
      flag: '🇵🇰',
      pickerLabel: AppLocalePickerLabels.urdu,
      headline: 'اپنی زبان منتخب کریں',
    ),
    AppLocalePickerOption(
      flag: '🇮🇳',
      pickerLabel: AppLocalePickerLabels.hindi,
      headline: 'अपनी भाषा चुनें',
    ),
    AppLocalePickerOption(
      flag: '🇶🇦',
      pickerLabel: AppLocalePickerLabels.arabic,
      headline: 'اختر لغتك',
    ),
    AppLocalePickerOption(
      flag: '🇵🇭',
      pickerLabel: AppLocalePickerLabels.filipino,
      headline: 'Piliin ang iyong wika',
    ),
    AppLocalePickerOption(
      flag: '🇧🇩',
      pickerLabel: AppLocalePickerLabels.bengali,
      headline: 'আপনার ভাষা নির্বাচন করুন',
    ),
    AppLocalePickerOption(
      flag: '🇮🇳',
      pickerLabel: AppLocalePickerLabels.tamil,
      headline: 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
    ),
  ];

  /// Catalog locales not shown in the primary picker (onboarding / extended).
  static const extendedCatalogLocales = ['Malayalam', 'Nepali'];

  static AppLocalePickerOption? optionForPickerLabel(String? pickerLabel) {
    if (pickerLabel == null) return null;
    for (final option in primaryOptions) {
      if (option.pickerLabel == pickerLabel) return option;
    }
    return null;
  }

  static int indexForPickerLabel(String? pickerLabel) {
    if (pickerLabel == null) return -1;
    return primaryOptions.indexWhere((o) => o.pickerLabel == pickerLabel);
  }
}
