import 'package:flutter/material.dart';
import 'package:raabta/core/design/raabta_continuous_shape.dart';
import 'package:raabta/core/design/raabta_physical_shadow_tokens.dart';

/// Kit family for solid tinted Home surfaces (Round 4B humanized).
enum RaabtaSolidSurfaceFamily {
  gold,
  teal,
  brand,
  neutral,
}

/// Solid fills and hairlines from `raabta_home_materiality_kit.html` (--sg, --lg, …).
abstract final class RaabtaSolidSurfaceTokens {
  RaabtaSolidSurfaceTokens._();

  static const _goldDark = Color(0xFF1A1508);
  static const _goldLight = Color(0xFFFFF6E0);
  static const _tealDark = Color(0xFF08151A);
  static const _tealLight = Color(0xFFE7F7F4);
  static const _brandDark = Color(0xFF130F24);
  static const _brandLight = Color(0xFFF1ECFD);
  static const _neutralDark = Color(0xFF10162B);
  static const _neutralLight = Color(0xFFFFFFFF);

  static Color fill(RaabtaSolidSurfaceFamily family, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (family) {
      RaabtaSolidSurfaceFamily.gold =>
        isDark ? _goldDark : _goldLight,
      RaabtaSolidSurfaceFamily.teal =>
        isDark ? _tealDark : _tealLight,
      RaabtaSolidSurfaceFamily.brand =>
        isDark ? _brandDark : _brandLight,
      RaabtaSolidSurfaceFamily.neutral =>
        isDark ? _neutralDark : _neutralLight,
    };
  }

  static Color hairline(RaabtaSolidSurfaceFamily family, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (family) {
      RaabtaSolidSurfaceFamily.gold => Color.fromRGBO(
            255,
            isDark ? 182 : 227,
            isDark ? 39 : 154,
            isDark ? 0.16 : 0.30,
          ),
      RaabtaSolidSurfaceFamily.teal => Color.fromRGBO(
            isDark ? 45 : 18,
            isDark ? 212 : 165,
            isDark ? 191 : 150,
            isDark ? 0.16 : 0.28,
          ),
      RaabtaSolidSurfaceFamily.brand => Color.fromRGBO(
            isDark ? 155 : 108,
            isDark ? 123 : 63,
            isDark ? 255 : 197,
            isDark ? 0.20 : 0.22,
          ),
      RaabtaSolidSurfaceFamily.neutral => Color.fromRGBO(
            isDark ? 255 : 15,
            isDark ? 255 : 23,
            isDark ? 255 : 42,
            isDark ? 0.08 : 0.08,
          ),
    };
  }

  /// Maps an accent [ColorFamily] main hue to the closest solid surface family.
  static RaabtaSolidSurfaceFamily familyForAccentColor(Color accent) {
    const gold = Color(0xFFFFB627);
    const teal = Color(0xFF2DD4BF);
    const brand = Color(0xFF9B7BFF);
    final distances = <(RaabtaSolidSurfaceFamily, double)>[
      (RaabtaSolidSurfaceFamily.gold, _colorDistance(accent, gold)),
      (RaabtaSolidSurfaceFamily.teal, _colorDistance(accent, teal)),
      (RaabtaSolidSurfaceFamily.brand, _colorDistance(accent, brand)),
    ];
    distances.sort((a, b) => a.$2.compareTo(b.$2));
    return distances.first.$1;
  }

  /// Card / tile surface — solid fill, tinted hairline, physical shadow (no glow).
  static ShapeDecoration cardDecoration({
    required RaabtaSolidSurfaceFamily family,
    required Brightness brightness,
    required double radius,
  }) {
    return RaabtaContinuousShape.decoration(
      radius: radius,
      color: fill(family, brightness),
      side: BorderSide(color: hairline(family, brightness), width: 1),
      shadows: RaabtaPhysicalShadowTokens.card(brightness),
    );
  }

  static double _colorDistance(Color a, Color b) {
    final dr = a.r - b.r;
    final dg = a.g - b.g;
    final db = a.b - b.b;
    return dr * dr + dg * dg + db * db;
  }
}