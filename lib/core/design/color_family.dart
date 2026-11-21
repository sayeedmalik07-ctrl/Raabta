import 'package:flutter/material.dart';
import 'package:raabta/core/design/raabta_continuous_shape.dart';

/// Kit v2 color family: dark / light / lightDeep tokens resolved by [Brightness].
@immutable
class ColorFamily {
  const ColorFamily({
    required this.dark,
    required this.light,
    required this.lightDeep,
  });

  final Color dark;
  final Color light;
  final Color lightDeep;

  Color main(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  Color text(Brightness brightness) =>
      brightness == Brightness.dark ? dark : lightDeep;
}

/// Six kit families (hex lives here only).
abstract final class RaabtaColorFamilies {
  static const ColorFamily brand = ColorFamily(
    dark: Color(0xFF9B7BFF),
    light: Color(0xFF6C3FC5),
    lightDeep: Color(0xFF4A2A96),
  );

  static const ColorFamily gold = ColorFamily(
    dark: Color(0xFFFFB627),
    light: Color(0xFFE39A00),
    lightDeep: Color(0xFF8A5A00),
  );

  static const ColorFamily teal = ColorFamily(
    dark: Color(0xFF2DD4BF),
    light: Color(0xFF12A596),
    lightDeep: Color(0xFF0A6B61),
  );

  static const ColorFamily green = ColorFamily(
    dark: Color(0xFF2ED3A0),
    light: Color(0xFF12A877),
    lightDeep: Color(0xFF0A6F4D),
  );

  static const ColorFamily amber = ColorFamily(
    dark: Color(0xFFFF9F43),
    light: Color(0xFFE8801A),
    lightDeep: Color(0xFF9A520A),
  );

  static const ColorFamily red = ColorFamily(
    dark: Color(0xFFFF5A5F),
    light: Color(0xFFE03545),
    lightDeep: Color(0xFFA81B2B),
  );

  static const List<ColorFamily> all = [
    brand,
    gold,
    teal,
    green,
    amber,
    red,
  ];
}

/// Premium card surface from kit §3 (no [BackdropFilter]).
ShapeDecoration premiumSurfaceDecoration({
  required ColorFamily family,
  required Brightness brightness,
  required double borderRadius,
}) {
  final accent = family.main(brightness);
  if (brightness == Brightness.dark) {
    return RaabtaContinuousShape.decoration(
      radius: borderRadius,
      gradient: LinearGradient(
        begin: const Alignment(-0.9, -1.0),
        end: const Alignment(0.9, 1.0),
        colors: [
          Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            const Color(0x17FFFFFF),
          ),
          Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            const Color(0x06FFFFFF),
          ),
        ],
      ),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
    );
  }

  return RaabtaContinuousShape.decoration(
    radius: borderRadius,
    gradient: LinearGradient(
      begin: const Alignment(-0.85, -1.0),
      end: const Alignment(0.85, 1.0),
      colors: [
        Colors.white,
        Color.alphaBlend(accent.withValues(alpha: 0.06), Colors.white),
      ],
    ),
    side: BorderSide(color: accent.withValues(alpha: 0.14)),
    shadows: [
      BoxShadow(
        color: accent.withValues(alpha: 0.16),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      const BoxShadow(
        color: Color(0x0F0F172A),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );
}

/// Representative fill for contrast checks (light gradient end).
Color premiumSurfaceSampleColor({
  required ColorFamily family,
  required Brightness brightness,
}) {
  final accent = family.main(brightness);
  if (brightness == Brightness.dark) {
    return Color.alphaBlend(
      accent.withValues(alpha: 0.08),
      const Color(0x06FFFFFF),
    );
  }
  return Color.alphaBlend(accent.withValues(alpha: 0.06), Colors.white);
}

Color premiumSurfaceBorderColor({
  required ColorFamily family,
  required Brightness brightness,
}) {
  final accent = family.main(brightness);
  if (brightness == Brightness.dark) {
    return Colors.white.withValues(alpha: 0.10);
  }
  return Color.alphaBlend(accent.withValues(alpha: 0.14), Colors.white);
}
