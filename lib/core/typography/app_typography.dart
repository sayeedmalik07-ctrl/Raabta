import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_locale.dart';

/// Shared typography tokens for the RAABTA design system.
///
/// Kit defaults (materiality): headings w700 with −0.5 tracking at 20sp+,
/// body w400, captions w500. Colors inherit from [DefaultTextStyle].
///
/// Call [forLocale] (or use styles through [AppFonts.textThemeFor]) so Arabic,
/// Urdu and Indic scripts never receive negative tracking.
class AppTypography {
  AppTypography._();

  /// Materiality kit heading tighten (Latin only, 20sp+).
  static const double latinHeadingTracking = -0.5;
  static const double latinHeadingMinFontSize = 20;

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Applies tabular figures for scores, currency, countdowns, and weather.
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: _tabular);

  /// Locale-aware tracking and weight normalization.
  static TextStyle forLocale(TextStyle base, String locale) {
    if (!AppLocale.usesLatinTypographyTracking(locale)) {
      return base.copyWith(letterSpacing: 0);
    }

    final size = base.fontSize;
    final weight = base.fontWeight ?? FontWeight.w400;

    // Expat score display — keep deliberate tight tracking, not kit −0.5.
    if (size == 56 && weight == FontWeight.w800) {
      return base;
    }

    final isKitHeading = size != null &&
        size >= latinHeadingMinFontSize &&
        weight.value >= FontWeight.w600.value;

    if (!isKitHeading) {
      return base;
    }
    return base.copyWith(letterSpacing: latinHeadingTracking);
  }

  static const TextStyle display = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -2,
    height: 1.0,
    fontFeatures: _tabular,
  );

  static const TextStyle headline1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.1,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  /// N26-style section category label — uppercase applied at render time for LTR.
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  static const TextStyle greeting = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Send-money rate hero (.big in materiality kit).
  static const TextStyle rateHero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.1,
    fontFeatures: _tabular,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
    color: Color(0xFF00D4FF),
  );
}