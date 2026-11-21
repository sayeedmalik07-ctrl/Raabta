import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/utils/home_doha_qatar_clock.dart';
import 'package:raabta/core/design/home_glass_legibility_tokens.dart';
import 'package:raabta/features/home/widgets/home_search_with_ai_row.dart';
import 'package:timezone/timezone.dart' as tz;

/// Collapsing Doha top zone geometry and motion (decision D1 / D4).
abstract final class HomeDohaTopZoneMetrics {
  HomeDohaTopZoneMetrics._();

  static const double expandedBodyHeight = 236;
  static const double collapsedBodyHeight = 64;
  static const double collapseRange = expandedBodyHeight - collapsedBodyHeight;

  static const double greetingFadeEndT = 0.55;
  static const double chipFadeEndT = 0.45;
  static const double glassBarFadeStartT = 0.55;

  static const double searchRowYExpanded = 68;
  static const double searchRowYCollapsed = 10;
  static const double greetingRowTop = 12;

  /// Painted diameter of [_CelestialOrb] in the Doha header.
  static const double celestialOrbDiameter = 36;

  /// Stars paint only in the upper sky band (keeps dots off search / avatar).
  static const double starfieldSkyBandFraction = 0.36;

  /// Soft dissolve at skyline base — overlay only (not PNG layers).
  static const double skylineHorizonFadeHeight = 32;

  /// Base anchor: horizontally aligned with the AI orb, above the search row.
  static Offset celestialAnchorBesideHomeOrb({
    required double width,
    required double collapseProgress,
    DohaDayPart part = DohaDayPart.day,
    DateTime? qatarLocalNow,
    HomeDohaPrayerAnchorTimes? prayerTimes,
    double topSafeInset = 0,
  }) {
    final t = collapseProgress.clamp(0.0, 1.0);
    final searchY = searchRowTopY(t, reduceMotion: false);
    final outer = HomeSearchWithAiRow.dohaOuterPaddingForCollapse(t);
    final orbSize = RaabtaOrbKitSizes.homeSparkle;
    final rowTop = searchY + outer.top;
    final orbCenterX = width - AppSpacing.screenHorizontalPadding - orbSize / 2;
    var left = orbCenterX - celestialOrbDiameter / 2;
    var top = rowTop - celestialOrbDiameter * 0.62;

    final qatarNow = HomeDohaQatarClock.now(
      clock: qatarLocalNow != null ? () => qatarLocalNow : null,
    );

    if (part == DohaDayPart.night) {
      final hour = qatarNow.hour + qatarNow.minute / 60.0;
      final nightProgress = ((hour - 18.5) / 11.0).clamp(0.0, 1.0);
      // Open sky between greeting and EN / bell — away from the AI column.
      left = width * 0.52 - celestialOrbDiameter / 2;
      left += -16 + (nightProgress * 22);
      top = greetingRowTop + topSafeInset + 8;
      top += -(nightProgress * 8);
    } else {
      final arc = celestialSunArcProgress(
        part: part,
        qatarNow: qatarNow,
        prayerTimes: prayerTimes,
      );
      switch (part) {
        case DohaDayPart.dawn:
          left += lerpDouble(-width * 0.26, -width * 0.10, arc)!;
          top += lerpDouble(-2, -14, arc)!;
        case DohaDayPart.day:
          left += lerpDouble(-width * 0.22, 14, arc)!;
          top += lerpDouble(-6, -26, arc)!;
        case DohaDayPart.golden:
          left += lerpDouble(6, 28, arc)!;
          top += lerpDouble(-22, -4, arc)!;
        case DohaDayPart.night:
          break;
      }
    }

    return Offset(left, top);
  }

  /// 0→1 progress through the active sun band (prayer anchors, else clock bands).
  @visibleForTesting
  static double celestialSunArcProgress({
    required DohaDayPart part,
    required tz.TZDateTime qatarNow,
    HomeDohaPrayerAnchorTimes? prayerTimes,
  }) {
    if (part == DohaDayPart.night) return 0;

    if (prayerTimes != null && prayerTimes.isComplete) {
      final dawnEnd = prayerTimes.sunrise!.add(const Duration(minutes: 30));
      final goldenEnd = prayerTimes.maghrib!.add(const Duration(minutes: 20));
      return switch (part) {
        DohaDayPart.dawn =>
          _intervalProgress(qatarNow, prayerTimes.fajr!, dawnEnd),
        DohaDayPart.day => _intervalProgress(qatarNow, dawnEnd, prayerTimes.asr!),
        DohaDayPart.golden =>
          _intervalProgress(qatarNow, prayerTimes.asr!, goldenEnd),
        DohaDayPart.night => 0,
      };
    }

    final hour = qatarNow.hour + qatarNow.minute / 60.0;
    return switch (part) {
      DohaDayPart.dawn => ((hour - 5.0) / 1.75).clamp(0.0, 1.0),
      DohaDayPart.day => ((hour - 6.75) / 8.5).clamp(0.0, 1.0),
      DohaDayPart.golden => ((hour - 15.25) / 3.25).clamp(0.0, 1.0),
      DohaDayPart.night => 0,
    };
  }

  static double _intervalProgress(
    tz.TZDateTime now,
    DateTime start,
    DateTime end,
  ) {
    final startQ = HomeDohaQatarClock.now(clock: () => start);
    final endQ = HomeDohaQatarClock.now(clock: () => end);
    if (!endQ.isAfter(startQ)) return 0;
    if (now.isBefore(startQ)) return 0;
    if (!now.isBefore(endQ)) return 1;
    final total = endQ.difference(startQ).inMicroseconds;
    final elapsed = now.difference(startQ).inMicroseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  static const double parallaxBackPx = 8;
  static const double parallaxMidPx = 18;
  static const double parallaxFrontPx = 30;

  static const double glassBarSurfaceAlpha =
      HomeGlassLegibilityTokens.pinnedSurfaceAlpha;
  static const double glassBarBlurSigma =
      HomeGlassLegibilityTokens.pinnedBarBlurSigma;

  static const double snapLowerBoundT = 0.15;
  static const double snapUpperBoundT = 0.85;

  static double progressFromShrinkOffset(double shrinkOffset) {
    if (collapseRange <= 0) return 0;
    return (shrinkOffset / collapseRange).clamp(0.0, 1.0);
  }

  static double greetingOpacity(double t) {
    if (t <= 0) return 1;
    if (t >= greetingFadeEndT) return 0;
    return 1 - (t / greetingFadeEndT);
  }

  static double greetingSlideY(double t, {required bool reduceMotion}) {
    if (reduceMotion) return 0;
    return -10 * t;
  }

  static double searchRowTopY(double t, {required bool reduceMotion}) {
    if (reduceMotion) {
      return t >= 0.5 ? searchRowYCollapsed : searchRowYExpanded;
    }
    return lerpDouble(searchRowYExpanded, searchRowYCollapsed, t)!;
  }

  static double skylineOpacity(double t) => (1 - t).clamp(0.0, 1.0);

  static double celestialOpacity(double t) =>
      (1 - t * 1.25).clamp(0.0, 1.0);

  static double chipOpacity(double t) {
    if (t >= chipFadeEndT) return 0;
    return 1 - (t / chipFadeEndT);
  }

  static double glassBarOpacity(double t) {
    if (t <= glassBarFadeStartT) return 0;
    return ((t - glassBarFadeStartT) / (1 - glassBarFadeStartT)).clamp(0.0, 1.0);
  }

  static double layerParallaxY(double t, double pixels, {required bool reduceMotion}) {
    if (reduceMotion) return 0;
    return pixels * t;
  }

  static double? snapTargetOffset(double scrollOffset) {
    if (scrollOffset <= 0 || scrollOffset >= collapseRange) return null;
    final t = progressFromShrinkOffset(scrollOffset);
    if (t > snapLowerBoundT && t < snapUpperBoundT) {
      return t < 0.5 ? 0 : collapseRange;
    }
    return null;
  }
}