import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/navigation/post_vertical_menu.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_primary_brand_fill.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';

/// Theme-aware glass styling for the Post menu (dark + light).
abstract final class _PostMenuVisuals {
  static bool _isLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light;

  static Color scrimColor(BuildContext context) => _isLight(context)
      ? Colors.black.withValues(alpha: 0.36)
      : AppColors.background.withValues(alpha: 0.62);

  static Color pillFill(BuildContext context) => _isLight(context)
      ? Color.lerp(AppColors.surface, Colors.white, 0.92)!
      : Color.lerp(
          AppColors.surfaceElevated,
          Colors.white,
          0.18,
        )!;

  static Color pillBorder(BuildContext context) => _isLight(context)
      ? AppColors.glassBorderBright
      : Color.lerp(
          AppColors.glassBorderBright,
          AppColors.cyanGlow,
          0.28,
        )!;

  static List<BoxShadow> pillShadows(BuildContext context) => _isLight(context)
      ? const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: AppColors.shadowStrong.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: AppColors.cyanGlow.withValues(alpha: 0.08),
            blurRadius: 14,
          ),
        ];
}

/// Raised center Post control — icon only (+ rotates to ×).
class ShellPostNavButton extends StatefulWidget {
  const ShellPostNavButton({
    super.key,
    required this.locale,
    required this.open,
    required this.onPressed,
  });

  final String locale;
  final bool open;
  final VoidCallback onPressed;

  @override
  State<ShellPostNavButton> createState() => _ShellPostNavButtonState();
}

class _ShellPostNavButtonState extends State<ShellPostNavButton>
    with TickerProviderStateMixin {
  static const _idleBreathDuration = Duration(seconds: 4);

  late final AnimationController _pulse;
  late final AnimationController _pressController;
  late final AnimationController _ringController;
  late final Animation<double> _pressScale;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: _idleBreathDuration,
    );
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );
    _pressScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutBack),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant ShellPostNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != widget.open) _syncPulse();
  }

  void _syncPulse() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _pulse.stop();
      _pulse.value = widget.open ? 1 : 0.45;
      return;
    }
    if (widget.open) {
      _pulse.stop();
      _pulse.value = 1;
      return;
    }
    if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _pressController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressing = true);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!reduceMotion) {
      _pressController.duration = const Duration(milliseconds: 80);
      _pressController.reverse(from: 1);
      _ringController.forward(from: 0);
    }
  }

  void _onTapUp(TapUpDetails _) {
    widget.onPressed();
    _onRelease();
  }

  void _onTapCancel() => _onRelease();

  void _onRelease() {
    if (!mounted) return;
    setState(() => _pressing = false);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _pressController.value = 1;
      return;
    }
    _pressController.duration = const Duration(milliseconds: 220);
    _pressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = AppShellStrings.t('nav_post_semantics', widget.locale);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final brandGlow = AppColors.brandFamilyMain;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulse,
          _pressController,
          _ringController,
        ]),
        builder: (context, child) {
          final breath = widget.open ? 1.0 : 0.35 + _pulse.value * 0.5;
          final glow = _pressing ? math.max(breath, 0.85) : breath;
          final elevation = widget.open
              ? 10.0
              : (AppColors.isLight ? 5.0 : 7.0) + glow * 1.5;
          final shadowColor = brandGlow.withValues(
            alpha: AppColors.isLight ? 0.35 : 0.45,
          );

          final breatheScale = widget.open ? 1.04 : 0.98 + _pulse.value * 0.04;
          final scale = reduceMotion
              ? (_pressing ? 0.92 : breatheScale)
              : _pressScale.value * breatheScale;

          return GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (!reduceMotion && (_pressing || _ringController.isAnimating))
                  ..._buildPressRings(brandGlow),
                Transform.scale(
                  scale: scale,
                  child: Material(
                    key: const Key('shell_post_nav_button'),
                    elevation: elevation,
                    shadowColor: shadowColor,
                    color: Colors.transparent,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: AppColors.accentGold.withValues(
                          alpha: AppColors.isLight ? 0.55 : 0.42,
                        ),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Ink(
                      width: PostVerticalMenu.mainButtonSize,
                      height: PostVerticalMenu.mainButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: HomePrimaryBrandFill.gradientColors(),
                        ),
                      ),
                      child: Center(
                        child: AnimatedRotation(
                          turns: widget.open ? 0.125 : 0,
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: AppSpacing.iconMd + 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPressRings(Color color) {
    final t = _ringController.value;
    Widget ring(double phase) {
      final p = ((t - phase) / (1 - phase)).clamp(0.0, 1.0);
      if (p <= 0) return const SizedBox.shrink();
      final size = PostVerticalMenu.mainButtonSize + 14 + p * 22;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: (1 - p) * 0.35),
            width: 1.5,
          ),
        ),
      );
    }

    return [ring(0), ring(0.18)];
  }
}

/// Full-screen scrim + vertical pill menu above the center Post button.
class ShellPostVerticalMenuOverlay extends StatefulWidget {
  const ShellPostVerticalMenuOverlay({
    super.key,
    required this.locale,
    required this.open,
    required this.onClose,
    required this.onVerticalSelected,
  });

  final String locale;
  final bool open;
  final VoidCallback onClose;
  final ValueChanged<PostVertical> onVerticalSelected;

  @override
  State<ShellPostVerticalMenuOverlay> createState() =>
      _ShellPostVerticalMenuOverlayState();
}

class _ShellPostVerticalMenuOverlayState extends State<ShellPostVerticalMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scrim;

  @override
  void initState() {
    super.initState();
    _scrim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scrim.addStatusListener(_onScrimStatusChanged);
    if (widget.open) _scrim.forward();
  }

  void _onScrimStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.open && mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant ShellPostVerticalMenuOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open && !oldWidget.open) {
      _scrim.forward(from: 0);
    } else if (!widget.open && oldWidget.open) {
      _scrim.reverse();
    }
  }

  @override
  void dispose() {
    _scrim.removeStatusListener(_onScrimStatusChanged);
    _scrim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open && _scrim.isDismissed) {
      return const SizedBox.shrink();
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final bottomInset = PostVerticalMenu.pillMenuBottomInset();

    return Stack(
      key: const Key('shell_post_menu_overlay'),
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: reduceMotion
                ? AlwaysStoppedAnimation(widget.open ? 1 : 0)
                : _scrim,
            child: GestureDetector(
              key: const Key('shell_post_menu_scrim'),
              behavior: HitTestBehavior.opaque,
              onTap: widget.onClose,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: reduceMotion ? 0 : 6,
                  sigmaY: reduceMotion ? 0 : 6,
                ),
                child: Container(
                  color: _PostMenuVisuals.scrimColor(context),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomInset,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = PostVerticalMenu.entries.length - 1; i >= 0; i--)
                _MenuPill(
                  key: Key(
                    'shell_post_menu_${PostVerticalMenu.entries[i].vertical.name}',
                  ),
                  entry: PostVerticalMenu.entries[i],
                  locale: widget.locale,
                  index: PostVerticalMenu.entries.length - 1 - i,
                  reduceMotion: reduceMotion,
                  menuOpen: widget.open,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onVerticalSelected(
                      PostVerticalMenu.entries[i].vertical,
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

}

class _MenuPill extends StatefulWidget {
  const _MenuPill({
    super.key,
    required this.entry,
    required this.locale,
    required this.index,
    required this.reduceMotion,
    required this.menuOpen,
    required this.onTap,
  });

  final PostVerticalMenuEntry entry;
  final String locale;
  final int index;
  final bool reduceMotion;
  final bool menuOpen;
  final VoidCallback onTap;

  @override
  State<_MenuPill> createState() => _MenuPillState();
}

class _MenuPillState extends State<_MenuPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curve;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(curve);
    _scale = Tween<double>(begin: 0.88, end: 1).animate(curve);

    if (widget.reduceMotion) {
      _controller.value = 1;
    } else if (widget.menuOpen) {
      Future<void>.delayed(
        Duration(milliseconds: 36 * widget.index),
        () {
          if (mounted) _controller.forward();
        },
      );
    }
  }

  @override
  void didUpdateWidget(covariant _MenuPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.menuOpen && !oldWidget.menuOpen && !widget.reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = PostVerticalMenu.labelFor(widget.entry, widget.locale);
    final pill = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PostVerticalMenu.pillMaxWidth,
            minHeight: PostVerticalMenu.pillHeight,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: _PostMenuVisuals.pillShadows(context),
            ),
            child: Material(
              color: _PostMenuVisuals.pillFill(context),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                splashColor: widget.entry.accentColor.withValues(alpha: 0.16),
                highlightColor: widget.entry.accentColor.withValues(alpha: 0.08),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: Color.lerp(
                        _PostMenuVisuals.pillBorder(context),
                        widget.entry.accentColor,
                        0.22,
                      )!,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.entry.icon,
                          color: widget.entry.accentColor,
                          size: AppSpacing.iconSm + 2,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.button.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.reduceMotion) return pill;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: pill),
      ),
    );
  }
}
