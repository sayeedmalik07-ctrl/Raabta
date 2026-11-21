import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Chooses side-by-side vs stacked calm Prayer + ScamShield glance layout.
abstract final class HomeGlanceLayoutPolicy {
  static const _rowGap = AppSpacing.sm;
  static const _compactPrayerFixedInner =
      32 + AppSpacing.sm + AppSpacing.xs + 20;
  static const _compactScamFixedInner =
      22 + AppSpacing.sm + AppSpacing.xs + 20;
  static const _horizontalInset = AppSpacing.sm * 2;

  /// Side-by-side when half-width cards can show up to two lines with ellipsis.
  static bool prefersSideBySide({
    required double maxWidth,
    required TextScaler textScaler,
    required String prayerPrimaryLine,
    required String scamCalmLine,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    if (maxWidth < 300) return false;
    if (textScaler.scale(1) > 1.36) return false;

    // Wider phones: compact glance row matches full-width strip density.
    if (maxWidth >= 344) return true;

    final half = (maxWidth - _rowGap) / 2;
    final prayerTextWidth = half - _horizontalInset - _compactPrayerFixedInner;
    final scamTextWidth = half - _horizontalInset - _compactScamFixedInner;
    if (prayerTextWidth < 48 || scamTextWidth < 48) return false;

    final style = AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600);
    final lineHeight = style.height ?? 1.4;
    final maxTextHeight =
        style.fontSize! * lineHeight * 1.25 * textScaler.scale(1);

    return _fitsWithinHeight(
          text: prayerPrimaryLine,
          maxWidth: prayerTextWidth,
          maxHeight: maxTextHeight,
          style: style,
          textScaler: textScaler,
          textDirection: textDirection,
        ) &&
        _fitsWithinHeight(
          text: scamCalmLine,
          maxWidth: scamTextWidth,
          maxHeight: maxTextHeight,
          style: style,
          textScaler: textScaler,
          textDirection: textDirection,
        );
  }

  static bool _fitsWithinHeight({
    required String text,
    required double maxWidth,
    required double maxHeight,
    required TextStyle style,
    required TextScaler textScaler,
    required TextDirection textDirection,
  }) {
    if (text.trim().isEmpty) return false;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: maxWidth);
    return painter.size.height <= maxHeight + 0.5;
  }
}
