import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';

/// Kit-driven colors for the Doha skyline header — scene hex lives here only (D9/D10).
@immutable
class DohaScenePalette {
  const DohaScenePalette({
    required this.part,
    required this.skyGradientStops,
    required this.layerTints,
    required this.celestialOrbColor,
    required this.celestialGlowColor,
    required this.celestialCenterXFraction,
    required this.celestialCenterYOffsetPx,
    required this.starOpacity,
    required this.windowLightOpacity,
    required this.topScrimOpacity,
  });

  final DohaDayPart part;

  /// Top → bottom sky gradient (3 stops).
  final List<Color> skyGradientStops;

  /// Back, mid, front layer tints (srcIn coloring).
  final List<Color> layerTints;

  final Color celestialOrbColor;
  final Color celestialGlowColor;

  /// Horizontal anchor for sun/moon (0–1).
  final double celestialCenterXFraction;
  final double celestialCenterYOffsetPx;

  final double starOpacity;
  final double windowLightOpacity;

  /// Darkening scrim over the sky top band for white header text (D9).
  final double topScrimOpacity;

  static const headerTextColor = Color(0xFFFFFFFF);

  static DohaScenePalette forPart(DohaDayPart part) => switch (part) {
        DohaDayPart.dawn => _dawn,
        DohaDayPart.day => _day,
        DohaDayPart.golden => _golden,
        DohaDayPart.night => _night,
      };

  /// Effective background behind header text at the top edge (sky + scrim).
  Color effectiveTopHeaderBackground() {
    final topSky = skyGradientStops.first;
    return Color.alphaBlend(
      Colors.black.withValues(alpha: topScrimOpacity),
      topSky,
    );
  }

  /// WCAG contrast ratio vs [headerTextColor] (must be ≥ 4.5, D9).
  @visibleForTesting
  double headerTextContrastRatio() =>
      contrastRatio(headerTextColor, effectiveTopHeaderBackground());

  /// Relative luminance contrast (WCAG 2.x).
  @visibleForTesting
  static double contrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color color) {
    double channel(double c) {
      return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = channel(color.r);
    final g = channel(color.g);
    final b = channel(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  // Values from docs/raabta_home_collapsing_doha_header_kit.html PARTS map.
  static const _dawn = DohaScenePalette(
    part: DohaDayPart.dawn,
    skyGradientStops: [
      Color(0xFF2B3A67),
      Color(0xFF8E6BA8),
      Color(0xFFFFB48A),
    ],
    layerTints: [
      Color(0xFF7A66A3),
      Color(0xFF54487F),
      Color(0xFF35305E),
    ],
    celestialOrbColor: Color(0xFFFFE1B8),
    celestialGlowColor: Color(0x8CFFC896),
    celestialCenterXFraction: 0.18,
    celestialCenterYOffsetPx: 92,
    starOpacity: 0.25,
    windowLightOpacity: 0.35,
    topScrimOpacity: 0.22,
  );

  /// Day kit sky with a darker top stop + stronger scrim for 4.5:1 (D9).
  static const _day = DohaScenePalette(
    part: DohaDayPart.day,
    skyGradientStops: [
      Color(0xFF2E6FA8),
      Color(0xFF8CCBF2),
      Color(0xFFE6F5FF),
    ],
    layerTints: [
      Color(0xFF9CBFE0),
      Color(0xFF7BA3CC),
      Color(0xFF5B86B3),
    ],
    celestialOrbColor: Color(0xFFFFF6D6),
    celestialGlowColor: Color(0xB3FFF6C8),
    celestialCenterXFraction: 0.70,
    celestialCenterYOffsetPx: 46,
    starOpacity: 0,
    windowLightOpacity: 0,
    topScrimOpacity: 0.38,
  );

  static const _golden = DohaScenePalette(
    part: DohaDayPart.golden,
    skyGradientStops: [
      Color(0xFF3C3874),
      Color(0xFFE27358),
      Color(0xFFFFC66E),
    ],
    layerTints: [
      Color(0xFFC86A5E),
      Color(0xFF8E4B68),
      Color(0xFF5B3662),
    ],
    celestialOrbColor: Color(0xFFFFE08A),
    celestialGlowColor: Color(0xA6FFBE5A),
    celestialCenterXFraction: 0.58,
    celestialCenterYOffsetPx: 96,
    starOpacity: 0,
    windowLightOpacity: 0.55,
    topScrimOpacity: 0.20,
  );

  static const _night = DohaScenePalette(
    part: DohaDayPart.night,
    skyGradientStops: [
      Color(0xFF0A0F2E),
      Color(0xFF1A2358),
      Color(0xFF38408C),
    ],
    layerTints: [
      Color(0xFF2A3470),
      Color(0xFF1C2453),
      Color(0xFF121840),
    ],
    celestialOrbColor: Color(0xFFEDEBFF),
    celestialGlowColor: Color(0x47B8B8FF),
    celestialCenterXFraction: 0.76,
    celestialCenterYOffsetPx: 88,
    starOpacity: 1,
    windowLightOpacity: 1,
    topScrimOpacity: 0.12,
  );
}