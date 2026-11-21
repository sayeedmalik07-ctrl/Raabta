import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../colors/app_colors.dart';
import '../design/raabta_continuous_shape.dart';
import '../glass/glass_container.dart';
import '../navigation/post_vertical_menu.dart';
import '../navigation/shell_nav_config.dart';
import '../navigation/shell_post_center_action.dart';
import '../design/home_glass_legibility_tokens.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

const _floatingNavTabHeight = 50.0;

/// Active tab lens footprint (icon + label as one unit).
@visibleForTesting
const kFloatingNavLensBaseWidth = 60.0;

@visibleForTesting
const kFloatingNavLensHeight = 52.0;

/// Premium floating navigation bar UI — presentation only.
class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.slots,
    required this.locale,
    required this.postMenuOpen,
    required this.onPostMenuToggle,
    this.activeNavColor,
  });

  final Color? activeNavColor;

  final ShellTab currentTab;
  final ValueChanged<ShellTab> onTabSelected;
  final List<ShellNavSlot> slots;
  final String locale;
  final bool postMenuOpen;
  final VoidCallback onPostMenuToggle;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  static const _lensDuration = Duration(milliseconds: 320);
  static const _lensBaseWidth = kFloatingNavLensBaseWidth;
  static const _lensHeight = kFloatingNavLensHeight;

  late final AnimationController _lensController;
  late Animation<double> _lensTween;

  ShellTab? _lensGlideFrom;
  ShellTab? _lensGlideTo;

  @override
  void initState() {
    super.initState();
    _lensController = AnimationController(vsync: this, duration: _lensDuration)
      ..value = 1;
    _lensTween = CurvedAnimation(
      parent: _lensController,
      curve: Curves.easeOutBack,
    );
    _lensGlideFrom = widget.currentTab;
    _lensGlideTo = widget.currentTab;
  }

  @override
  void didUpdateWidget(covariant FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTab != widget.currentTab) {
      _lensGlideFrom = oldWidget.currentTab;
      _lensGlideTo = widget.currentTab;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (reduceMotion) {
        _lensController.value = 1;
      } else {
        _lensController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _lensController.dispose();
    super.dispose();
  }

  double _lensCenterX(ShellTab tab, double totalWidth, TextDirection direction) {
    return floatingNavLensCenterXForTab(
      tab: tab,
      totalWidth: totalWidth,
      textDirection: direction,
    );
  }

  void _handleTabTap(ShellTab tab) {
    final changed = tab != widget.currentTab;
    if (changed) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
    widget.onTabSelected(tab);
  }

  void _handlePostTap() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
    widget.onPostMenuToggle();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedActive = widget.activeNavColor ?? AppColors.brandFamilyMain;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final textDirection = Directionality.of(context);

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: RaabtaContinuousShape.shadowOnly(
              radius: AppSpacing.navRadius,
              shadows: AppColors.isLight
                  ? [
                      BoxShadow(
                        color: AppColors.brandFamilyMain.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: GlassContainer(
              height: AppSpacing.navHeight,
              margin: const EdgeInsets.only(
                left: AppSpacing.navHorizontalMargin,
                right: AppSpacing.navHorizontalMargin,
                bottom: AppSpacing.navBottomMargin,
              ),
              borderRadius: AppSpacing.navRadius,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                3,
                AppSpacing.sm,
                5,
              ),
              glowColor: AppColors.brandFamilyMain,
              glowIntensity: AppColors.isLight ? 0.05 : 0.04,
              backgroundColor: floatingNavGlassBackground(
                currentTab: widget.currentTab,
                isLight: AppColors.isLight,
              ),
              blurSigma: floatingNavGlassBlurSigma(
                currentTab: widget.currentTab,
                isLight: AppColors.isLight,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final lensTop =
                      (constraints.maxHeight - _lensHeight) / 2;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _lensController,
                        builder: (context, _) {
                          final t = _lensTween.value;
                          final fromTab = _lensGlideFrom ?? widget.currentTab;
                          final toTab = _lensGlideTo ?? widget.currentTab;
                          final fromX = _lensCenterX(
                            fromTab,
                            constraints.maxWidth,
                            textDirection,
                          );
                          final toX = _lensCenterX(
                            toTab,
                            constraints.maxWidth,
                            textDirection,
                          );
                          final center = fromX + (toX - fromX) * t;
                          final width = reduceMotion
                              ? _lensBaseWidth
                              : _lensBaseWidth *
                                  (1 + 0.32 * math.sin(t * math.pi));
                          final maxLeft =
                              math.max(0.0, constraints.maxWidth - width);
                          final left =
                              (center - width / 2).clamp(0.0, maxLeft);

                          return Positioned(
                            left: left,
                            top: lensTop,
                            child: _NavActiveLens(
                              width: width,
                              height: _lensHeight,
                              color: resolvedActive,
                              opacity: 0.85,
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: constraints.maxHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (final slot in widget.slots)
                              switch (slot) {
                                ShellNavTabSlot(
                                  :final tab,
                                  :final destination,
                                ) =>
                                  Expanded(
                                    child: _FloatingNavItem(
                                      destination: destination,
                                      isActive: tab == widget.currentTab,
                                      activeColor: resolvedActive,
                                      dimmed: widget.postMenuOpen,
                                      onTap: () => _handleTabTap(tab),
                                    ),
                                  ),
                                ShellNavCenterActionSlot() => SizedBox(
                                    width: PostVerticalMenu.centerSlotWidth,
                                  ),
                              },
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.navHorizontalMargin,
            right: AppSpacing.navHorizontalMargin,
            bottom: PostVerticalMenu.fabBottomInset(),
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -PostVerticalMenu.navOverlap),
                child: ShellPostNavButton(
                  locale: widget.locale,
                  open: widget.postMenuOpen,
                  onPressed: _handlePostTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavActiveLens extends StatelessWidget {
  const _NavActiveLens({
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
  });

  final double width;
  final double height;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.isLight
        ? color.withValues(alpha: 0.14)
        : color.withValues(alpha: 0.16);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          DecoratedBox(
            decoration: RaabtaContinuousShape.decoration(
              radius: height / 2,
              color: fill,
              side: BorderSide(
                color: color.withValues(alpha: AppColors.isLight ? 0.28 : 0.22),
              ),
              shadows: [
                BoxShadow(
                  color: color.withValues(alpha: 0.18 * opacity),
                  blurRadius: AppColors.isLight ? 6 : 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavItem extends StatefulWidget {
  const _FloatingNavItem({
    required this.destination,
    required this.isActive,
    required this.activeColor,
    required this.dimmed,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool isActive;
  final Color activeColor;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with TickerProviderStateMixin {
  static const _pressIn = Duration(milliseconds: 80);
  static const _release = Duration(milliseconds: 220);
  static const _popDuration = Duration(milliseconds: 260);
  static const _iconFade = Duration(milliseconds: 160);

  late final AnimationController _pressController;
  late final AnimationController _popController;
  late Animation<double> _pressScale;
  late Animation<double> _popScale;
  late Animation<double> _popLift;

  bool _pressing = false;
  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: _release,
      value: 1,
    );
    _pressScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutBack),
    );
    _popController = AnimationController(vsync: this, duration: _popDuration);
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));
    _popLift = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -3), weight: 45),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 55),
    ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _FloatingNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (!reduceMotion) {
        _popController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _popController.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressing = true);
    if (_reduceMotion) return;
    _pressController.duration = _pressIn;
    _pressController.reverse(from: 1);
  }

  void _onTapUp(TapUpDetails _) {
    widget.onTap();
    _onRelease();
  }

  void _onTapCancel() => _onRelease();

  void _onRelease() {
    if (!mounted) return;
    setState(() => _pressing = false);
    if (_reduceMotion) {
      _pressController.value = 1;
      return;
    }
    _pressController.duration = _release;
    _pressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isActive
        ? widget.activeColor
        : AppColors.inactiveNavigation;
    final labelColor =
        widget.isActive ? widget.activeColor : AppColors.textTertiary;

    final pressScale = _pressing && !_reduceMotion
        ? 0.88
        : (_popController.isAnimating && widget.isActive && !_reduceMotion
            ? _popScale.value
            : _pressScale.value);

    final lift = widget.isActive && _popController.isAnimating && !_reduceMotion
        ? _popLift.value
        : 0.0;

    final content = AnimatedBuilder(
      animation: Listenable.merge([_pressController, _popController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, lift),
          child: Transform.scale(
            scale: pressScale,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppSpacing.iconMd,
            height: AppSpacing.iconMd,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (_pressing)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.activeColor.withValues(alpha: 0.22),
                              widget.activeColor.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: _reduceMotion ? Duration.zero : _iconFade,
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: IconTheme(
                    key: ValueKey<bool>(widget.isActive),
                    data: IconThemeData(
                      color: iconColor,
                      size: AppSpacing.iconMd,
                    ),
                    child: widget.isActive &&
                            widget.destination.selectedIcon != null
                        ? widget.destination.selectedIcon!
                        : widget.destination.icon,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 13,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: AnimatedDefaultTextStyle(
                duration: _reduceMotion ? Duration.zero : _iconFade,
                style: AppTypography.chipLabel.copyWith(
                  fontSize: 11,
                  height: 1.15,
                  color: labelColor,
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  widget.destination.label,
                  maxLines: 1,
                  softWrap: false,
                  textScaler: TextScaler.noScaling,
                ),
              ),
            ),
          ),
          if (widget.isActive) ...[
            const SizedBox(height: 3),
            Container(
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: widget.activeColor.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: widget.activeColor.withValues(alpha: 0.45),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      label: widget.destination.label,
      selected: widget.isActive,
      child: Opacity(
        opacity: widget.dimmed
            ? 0.52
            : (widget.isActive ? 1 : 0.82),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: _floatingNavTabHeight,
            child: ClipRect(
              child: Align(
                alignment: const Alignment(0, -0.14),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hub landings (Market / Community) use a more opaque dock so feed content
/// does not compete with the glass pill. Home keeps the lighter glass.
@visibleForTesting
bool floatingNavUsesHubDockGlass(ShellTab tab) {
  return tab == ShellTab.documents || tab == ShellTab.community;
}

/// Home tab glass pill — kit polish ~78% surface (see [HUB_DESIGN_CONTRACT.md]).
@visibleForTesting
const kFloatingNavHomeSurfaceAlpha =
    HomeGlassLegibilityTokens.homeNavSurfaceAlpha;

/// Home tab backdrop blur sigma (Round 4C legibility floor).
@visibleForTesting
const kFloatingNavHomeBlurSigma = HomeGlassLegibilityTokens.homeNavBlurSigma;

@visibleForTesting
Color floatingNavGlassBackground({
  required ShellTab currentTab,
  required bool isLight,
}) {
  final hubDock = floatingNavUsesHubDockGlass(currentTab);
  if (!hubDock) {
    return AppColors.surface.withValues(alpha: kFloatingNavHomeSurfaceAlpha);
  }
  if (isLight) {
    return Color.lerp(
      AppColors.surface,
      Colors.white,
      0.58,
    )!;
  }
  return Color.lerp(
    AppColors.surface,
    AppColors.background,
    0.66,
  )!;
}

@visibleForTesting
double floatingNavGlassBlurSigma({
  required ShellTab currentTab,
  required bool isLight,
}) {
  final hubDock = floatingNavUsesHubDockGlass(currentTab);
  if (!hubDock) return kFloatingNavHomeBlurSigma;
  if (isLight) return 0;
  return AppSpacing.glassBlur * 0.55;
}

/// Tab center X for the inner nav row [totalWidth] (LTR layout coords).
@visibleForTesting
double floatingNavLensCenterXForTab({
  required ShellTab tab,
  required double totalWidth,
  required TextDirection textDirection,
}) {
  final index = ShellNavConfig.navIndexForTab(tab, 'English');
  final tabWidth =
      (totalWidth - PostVerticalMenu.centerSlotWidth) / ShellTab.values.length;
  final ltrX = index < 2
      ? (index + 0.5) * tabWidth
      : (index + 0.5) * tabWidth + PostVerticalMenu.centerSlotWidth;
  if (textDirection == TextDirection.rtl) {
    return totalWidth - ltrX;
  }
  return ltrX;
}

/// @visibleForTesting
double navLensStretchWidthForTest(double progress) {
  return kFloatingNavLensBaseWidth *
      (1 + 0.32 * math.sin(progress * math.pi));
}
