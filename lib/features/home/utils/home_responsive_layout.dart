import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Home feed breakpoints and centered content cap (Round 4C).
abstract final class HomeResponsiveLayout {
  HomeResponsiveLayout._();

  /// Compact phone layouts (scroll rails, 2×2 truth grid).
  static const double compactMax = 600;

  /// Tablet / small desktop.
  static const double mediumMax = 1023;

  /// Expanded desktop — truth grid may go 1×4.
  static const double expandedMin = 1024;

  /// Max width of scrollable Home content below the full-bleed Doha header.
  static const double contentMaxWidth = 680;

  static HomeWidthTier tierFor(double viewportWidth) {
    if (viewportWidth < compactMax) return HomeWidthTier.compact;
    if (viewportWidth < expandedMin) return HomeWidthTier.medium;
    return HomeWidthTier.expanded;
  }

  /// Leading (and trailing) inset so feed content is centered at [contentMaxWidth].
  static double contentLeadingInset(double viewportWidth) {
    if (viewportWidth <= contentMaxWidth) {
      return HomeZoneSpacing.sectionHorizontalPadding;
    }
    return (viewportWidth - contentMaxWidth) / 2;
  }

  /// Uses [viewportWidth] (not capped feed width) to pick expanded 1×4 layout.
  static int truthEngineGridCrossAxisCount({
    required double viewportWidth,
    required int itemCount,
  }) {
    if (itemCount >= 4 && viewportWidth >= expandedMin) return 4;
    return 2;
  }

  /// Horizontal scroll rail on compact; equal-width row on medium+.
  static bool qatarLifeUsesHorizontalScroll(double contentWidth) {
    return tierFor(contentWidth) == HomeWidthTier.compact;
  }
}

enum HomeWidthTier {
  compact,
  medium,
  expanded,
}