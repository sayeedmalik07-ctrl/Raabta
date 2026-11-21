import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/design/home_glass_legibility_tokens.dart';
import 'package:raabta/features/home/widgets/home_search_with_ai_row.dart';

/// Sticky top search — slides in when the inline home search scrolls off screen.
class HomeFloatingSearchBar extends StatelessWidget {
  /// Sticky scrim fill alpha over [AppColors.background] (Home-only readability).
  @visibleForTesting
  static const double stickyScrimOpacity =
      HomeGlassLegibilityTokens.pinnedSurfaceAlpha;

  /// Theme-aware sticky scrim fill (opaque in light; translucent scrim in dark).
  @visibleForTesting
  static Color stickyScrimFillColor() => AppColors.isLight
      ? AppColors.surface
      : AppColors.background.withValues(alpha: stickyScrimOpacity);

  /// Bottom hairline when the sticky bar is visible — theme-aware, no pure white.
  @visibleForTesting
  static Color stickyBottomBorderColor({required bool visible}) {
    if (!visible) return Colors.transparent;
    return AppColors.isLight
        ? const Color.fromRGBO(15, 23, 42, 0.06)
        : const Color.fromRGBO(255, 255, 255, 0.08);
  }

  const HomeFloatingSearchBar({
    super.key,
    required this.visible,
    required this.searchEntry,
    this.aiOrb,
  });

  final bool visible;
  final Widget searchEntry;
  final Widget? aiOrb;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 220);

    return AnimatedSlide(
      duration: duration,
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, -1.1),
      child: AnimatedOpacity(
        duration: duration,
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Material(
            color: Colors.transparent,
            elevation: visible ? 6 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            child: ClipRect(
              child: _StickySearchScrim(
                visible: visible,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontalPadding,
                    topInset + AppSpacing.xs,
                    AppSpacing.screenHorizontalPadding,
                    AppSpacing.sm,
                  ),
                  child: HomeSearchWithAiRow(
                    search: searchEntry,
                    aiOrb: aiOrb,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickySearchScrim extends StatelessWidget {
  const _StickySearchScrim({
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scrim = DecoratedBox(
      decoration: BoxDecoration(
        color: HomeFloatingSearchBar.stickyScrimFillColor(),
        border: Border(
          bottom: BorderSide(
            color: HomeFloatingSearchBar.stickyBottomBorderColor(
              visible: visible,
            ),
          ),
        ),
      ),
      child: child,
    );

    final skipBlur = AppColors.isLight ||
        (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux));

    if (skipBlur) {
      return scrim;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: scrim,
    );
  }
}
