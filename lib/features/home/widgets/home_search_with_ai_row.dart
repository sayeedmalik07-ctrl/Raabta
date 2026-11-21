import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/features/home/widgets/animated_search_entry.dart';
import 'package:raabta/features/home/widgets/home_doha_header_collapse_scope.dart';
import 'package:raabta/features/home/widgets/search_capsule_layout.dart';

/// Home search pill beside the AI orb (PNG 01 / 17 / 19 — separate glass shapes).
class HomeSearchWithAiRow extends StatelessWidget {
  const HomeSearchWithAiRow({super.key, required this.search, this.aiOrb});

  final Widget search;
  final Widget? aiOrb;

  static const searchPillHeight = AnimatedSearchEntry.designPillHeight;

  static const searchPillRadius = AnimatedSearchEntry.designPillRadius;

  static const orbVisualSize = RaabtaOrbKitSizes.homeSparkle;

  /// Reference: search and orb sit close but remain distinct pills.
  static const searchOrbGap = AppSpacing.xs;

  static const rowHeight = orbVisualSize;

  static const inlineTopInset = 12.0;

  static const _inlineBottomInset = AppSpacing.sm;

  /// Outer padding above/below the 54dp row; fades out as the Doha header collapses.
  @visibleForTesting
  static EdgeInsets dohaOuterPaddingForCollapse(double collapseProgress) {
    final t = collapseProgress.clamp(0.0, 1.0);
    final factor = 1 - t;
    return EdgeInsets.only(
      top: inlineTopInset * factor,
      bottom: _inlineBottomInset * factor,
    );
  }

  /// Total vertical space used by the search row inside the header body.
  @visibleForTesting
  static double verticalFootprintForCollapse(double collapseProgress) {
    return rowHeight + dohaOuterPaddingForCollapse(collapseProgress).vertical;
  }

  @override
  Widget build(BuildContext context) {
    if (aiOrb == null) return search;

    final localeTextDirection = Directionality.of(context);

    final row = Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SearchCapsuleLayout(
                hostedInAiRow: true,
                localeTextDirection: localeTextDirection,
                child: search,
              ),
            ),
            const SizedBox(width: searchOrbGap),
            SizedBox(width: orbVisualSize, height: orbVisualSize, child: aiOrb),
          ],
        ),
      ),
    );

    final usesCompactSearch =
        search is AnimatedSearchEntry &&
        (search as AnimatedSearchEntry).compact;

    if (usesCompactSearch) return row;

    final collapseProgress = HomeDohaHeaderCollapseScope.maybeProgressOf(context);
    if (collapseProgress != null) {
      final padding = dohaOuterPaddingForCollapse(collapseProgress);
      if (padding == EdgeInsets.zero) return row;
      return Padding(padding: padding, child: row);
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: inlineTopInset,
        bottom: _inlineBottomInset,
      ),
      child: row,
    );
  }
}
