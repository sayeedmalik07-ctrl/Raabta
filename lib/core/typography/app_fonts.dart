import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raabta/core/l10n/app_locale.dart';

/// App-wide font resolution — Inter (LTR) and bundled Noto Sans Arabic (RTL).
abstract final class AppFonts {
  static const String arabicFamily = 'NotoSansArabic';

  static String familyForLocale(String locale) =>
      AppLocale.isRtl(locale) ? arabicFamily : _interFamily;

  static String get _interFamily =>
      GoogleFonts.inter().fontFamily ?? 'Inter';

  /// Applies the locale-appropriate font to an existing [TextTheme].
  static TextTheme textThemeFor(TextTheme base, String locale) {
    if (AppLocale.isRtl(locale)) {
      return base.apply(fontFamily: arabicFamily);
    }
    return GoogleFonts.interTextTheme(base);
  }

  static TextStyle primaryStyle(String locale, {required Color color}) {
    return TextStyle(
      color: color,
      fontFamily: familyForLocale(locale),
    );
  }
}
