import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/design/home_glass_legibility_tokens.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/features/home/widgets/search_capsule_layout.dart';

List<Color> _brandOrbitGradient() => [
  AppColors.brandFamilyMain,
  AppColors.brandFamilyText,
  AppColors.brandFamilyMain,
];

/// Home Screen Global Search entry — gradient ring on tap converge (calm at idle).
class AnimatedSearchEntry extends StatefulWidget {
  const AnimatedSearchEntry({
    super.key,
    required this.hint,
    required this.onTap,
    this.compact = false,
    this.semanticsLabel,
  });

  final String hint;
  final VoidCallback onTap;
  final String? semanticsLabel;

  /// Tighter vertical padding for the sticky top search bar.
  final bool compact;

  /// Kit §10 global search pill — same height as header language chip.
  static const designPillHeight = 44.0;

  static const designPillRadius = designPillHeight / 2;

  @override
  State<AnimatedSearchEntry> createState() => _AnimatedSearchEntryState();
}

class _AnimatedSearchEntryState extends State<AnimatedSearchEntry>
    with TickerProviderStateMixin {
  static const _idleDuration = Duration(milliseconds: 3600);
  static const _tapDuration = Duration(milliseconds: 420);

  static const _pillHeight = AnimatedSearchEntry.designPillHeight;
  static const _rowTopInset = 12.0;

  late final AnimationController _idleController;
  late final AnimationController _tapController;
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(vsync: this, duration: _idleDuration);
    _tapController = AnimationController(vsync: this, duration: _tapDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion && _idleController.isAnimating) {
      _idleController.stop();
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_launching) return;
    setState(() => _launching = true);
    _idleController.stop();
    await _tapController.forward(from: 0);
    if (!mounted) return;
    widget.onTap();
    if (mounted) {
      setState(() => _launching = false);
      _tapController.reset();
    }
  }

  bool get _reduceMotion {
    final mq = MediaQuery.maybeOf(context);
    return mq?.disableAnimations ?? false;
  }

  bool get _embeddedInCapsule => SearchCapsuleLayout.embeddedOf(context);

  bool get _hostedInAiRow => SearchCapsuleLayout.hostedInAiRowOf(context);

  BorderRadius get _searchFillRadius {
    if (_embeddedInCapsule) {
      return BorderRadius.horizontal(left: Radius.circular(_pillHeight / 2));
    }
    return BorderRadius.circular(_pillHeight / 2);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = _reduceMotion;
    final embedded = _embeddedInCapsule;

    return Padding(
      padding: embedded || _hostedInAiRow || widget.compact
          ? EdgeInsets.zero
          : const EdgeInsets.only(top: _rowTopInset, bottom: AppSpacing.sm),
      child: Semantics(
        button: true,
        label: widget.semanticsLabel ?? widget.hint,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_idleController, _tapController]),
            builder: (context, _) {
              final tapT = Curves.easeInOutCubic.transform(
                _tapController.value,
              );
              final compactGeometry =
                  embedded || _hostedInAiRow || widget.compact;
              final showOrbitRing =
                  !reduceMotion && !compactGeometry && (_launching || tapT > 0);
              final orbitProgress = showOrbitRing
                  ? (_idleController.value + tapT * 0.35) % 1.0
                  : 0.0;
              final tighten = tapT;
              final expand = tapT;
              final ringOpacity = 1.0 - tapT * 0.15;
              final contentHeight = compactGeometry
                  ? _pillHeight
                  : _pillHeight + 6;

              return Transform.scale(
                scale: 1.0 + expand * 0.02,
                child: SizedBox(
                  height: contentHeight,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (showOrbitRing && !embedded)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: SearchOrbitRingPainter(
                              progress: orbitProgress,
                              tighten: tighten,
                              opacity: ringOpacity,
                              borderRadius: _pillHeight / 2,
                              gradientColors: _brandOrbitGradient(),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compactGeometry ? 0 : 4,
                        ),
                        child: _buildSearchSurface(
                          embedded: embedded,
                          expand: expand,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSurface({required bool embedded, required double expand}) {
    final textDirection =
        SearchCapsuleLayout.localeTextDirectionOf(this.context) ??
        Directionality.of(this.context);
    final hostedInRow = _hostedInAiRow;

    final row = Row(
      textDirection: textDirection,
      children: [
        Icon(
          Icons.search_rounded,
          size: hostedInRow ? AppSpacing.iconSm + 2 : AppSpacing.iconMd,
          color: AppColors.brandFamilyMain.withValues(
            alpha: 0.82 + expand * 0.12,
          ),
        ),
        SizedBox(width: hostedInRow ? AppSpacing.xs : AppSpacing.sm),
        Expanded(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: 0.55 + expand * 0.45,
            child: Text(
              widget.hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              textDirection: textDirection,
              style: AppTypography.bodySmall.copyWith(
                height: hostedInRow ? 1.2 : null,
                color: AppColors.textOnGlassSecondary,
              ),
            ),
          ),
        ),
        if (expand > 0.05)
          Icon(
            HomeDirectionalIcons.forwardArrowRounded(context),
            size: 18,
            color: AppColors.brandFamilyMain.withValues(alpha: expand),
          ),
      ],
    );

    final horizontalInset = embedded
        ? AppSpacing.sm
        : hostedInRow
        ? AppSpacing.sm
        : AppSpacing.md;
    final paddedRow = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: row,
    );

    if (embedded) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: _searchFillRadius,
          child: SizedBox(
            height: _pillHeight,
            child: Center(child: paddedRow),
          ),
        ),
      );
    }

    final pinnedHomeChrome = hostedInRow || widget.compact;

    return GlassContainer(
      height: _pillHeight,
      borderRadius: AnimatedSearchEntry.designPillRadius,
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: pinnedHomeChrome ? 0 : (0.04 + expand * 0.05),
      solidSurfaceFamily:
          pinnedHomeChrome ? RaabtaSolidSurfaceFamily.neutral : null,
      backgroundColor: pinnedHomeChrome
          ? RaabtaSolidSurfaceTokens.fill(
              RaabtaSolidSurfaceFamily.neutral,
              Theme.of(context).brightness,
            ).withValues(alpha: HomeGlassLegibilityTokens.pinnedSurfaceAlpha)
          : null,
      blurSigma: pinnedHomeChrome ? 0 : HomeGlassLegibilityTokens.fallbackBlurSigma,
      padding: EdgeInsets.zero,
      onTap: _handleTap,
      child: paddedRow,
    );
  }
}

/// Thin gradient arc orbiting a pill outline — isolated repaint via [RepaintBoundary].
class SearchOrbitRingPainter extends CustomPainter {
  SearchOrbitRingPainter({
    required this.progress,
    required this.tighten,
    required this.borderRadius,
    required this.gradientColors,
    this.opacity = 1,
  });

  final double progress;
  final double tighten;
  final double borderRadius;
  final List<Color> gradientColors;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final inset = 2.0 + tighten * 5.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - inset * 2,
        size.height - inset * 2,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final total = metric.length;
    final arcLength = total * (0.18 - tighten * 0.04);
    final start = (progress % 1.0) * total;

    final arcPath = _extractArc(metric, start, arcLength);

    final center = Offset(size.width / 2, size.height / 2);
    final shader = SweepGradient(
      colors: gradientColors
          .map(
            (c) => c.withValues(alpha: (0.32 + (1 - tighten) * 0.22) * opacity),
          )
          .toList(),
      transform: GradientRotation(progress * 2 * math.pi),
    ).createShader(Rect.fromCircle(center: center, radius: size.shortestSide));

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 - tighten * 0.4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(arcPath, paint);
  }

  Path _extractArc(PathMetric metric, double start, double length) {
    final total = metric.length;
    final normalizedStart = start % total;
    final path = Path();
    if (normalizedStart + length <= total) {
      path.addPath(
        metric.extractPath(normalizedStart, normalizedStart + length),
        Offset.zero,
      );
    } else {
      path.addPath(metric.extractPath(normalizedStart, total), Offset.zero);
      path.addPath(
        metric.extractPath(0, normalizedStart + length - total),
        Offset.zero,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant SearchOrbitRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tighten != tighten ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.opacity != opacity ||
        oldDelegate.gradientColors != gradientColors;
  }
}
