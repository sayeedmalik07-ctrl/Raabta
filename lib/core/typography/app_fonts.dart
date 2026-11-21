import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// App-wide font resolution — Plus Jakarta Sans (bundled Latin), Noto Sans
/// Arabic (RTL), and Inter for Indic catalogs until dedicated bundles land.
abstract final class AppFonts {
  static const String plusJakartaFamily = 'PlusJakartaSans';
  static const String arabicFamily = 'NotoSansArabic';

  /// Family name used with [GoogleFonts.interTextTheme] for Indic catalogs.
  static const String indicFamily = 'Inter';

  static String familyForLocale(String locale) {
    if (AppLocale.isRtl(locale)) return arabicFamily;
    if (AppLocale.usesBundledLatinFont(locale)) return plusJakartaFamily;
    if (AppLocale.usesIndicScriptLocale(locale)) return indicFamily;
    return plusJakartaFamily;
  }

  /// Applies the locale-appropriate font to an existing [TextTheme].
  static TextTheme textThemeFor(TextTheme base, String locale) {
    final TextTheme themed;
    if (AppLocale.isRtl(locale)) {
      themed = base.apply(fontFamily: arabicFamily);
    } else if (AppLocale.usesIndicScriptLocale(locale)) {
      themed = GoogleFonts.interTextTheme(base);
    } else {
      themed = base.apply(fontFamily: plusJakartaFamily);
    }
    return _applyLocaleTypographyToTextTheme(themed, locale);
  }

  static TextTheme _applyLocaleTypographyToTextTheme(
    TextTheme theme,
    String locale,
  ) {
    TextStyle? map(TextStyle? style) =>
        style == null ? null : AppTypography.forLocale(style, locale);

    return theme.copyWith(
      displayLarge: map(theme.displayLarge),
      displayMedium: map(theme.displayMedium),
      displaySmall: map(theme.displaySmall),
      headlineLarge: map(theme.headlineLarge),
      headlineMedium: map(theme.headlineMedium),
      headlineSmall: map(theme.headlineSmall),
      titleLarge: map(theme.titleLarge),
      titleMedium: map(theme.titleMedium),
      titleSmall: map(theme.titleSmall),
      bodyLarge: map(theme.bodyLarge),
      bodyMedium: map(theme.bodyMedium),
      bodySmall: map(theme.bodySmall),
      labelLarge: map(theme.labelLarge),
      labelMedium: map(theme.labelMedium),
      labelSmall: map(theme.labelSmall),
    );
  }

  static TextStyle primaryStyle(String locale, {required Color color}) {
    return AppTypography.forLocale(
      TextStyle(
        color: color,
        fontFamily: familyForLocale(locale),
      ),
      locale,
    );
  }
}