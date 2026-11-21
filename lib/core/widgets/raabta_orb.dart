import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';

/// Single reusable AI identity orb (sphere, gold arc, halo). One
/// [AnimationController] per instance; no blur layers or particles.
class RaabtaOrb extends StatefulWidget {
  const RaabtaOrb({
    super.key,
    required this.state,
    required this.size,
    this.showDepthRings = false,
    this.animationsEnabled = true,
    this.idleVisualsOnly = false,
    this.tactileMateriality = false,
  });

  final RaabtaOrbState state;
  final double size;

  /// Empty-state hero only (kit §10 depth hairlines).
  final bool showDepthRings;

  /// Parent can disable motion (e.g. off-screen Home orb).
  final bool animationsEnabled;

  /// Home search orb: static sphere, no gold arc or idle breath (sparkle overlay).
  final bool idleVisualsOnly;

  /// Round 4B: calmer halo on Home pinned/search orbs (tactile shadow on shell).
  final bool tactileMateriality;

  static const breathDuration = Duration(milliseconds: 3500);

  @override
  State<RaabtaOrb> createState() => _RaabtaOrbState();
}

class _RaabtaOrbState extends State<RaabtaOrb>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  RaabtaOrbState? _previousState;
  double _completionBlend = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: RaabtaOrb.breathDuration,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _syncTicker();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant RaabtaOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      if (widget.state == RaabtaOrbState.completion) {
        _completionBlend = 0;
      } else if (oldWidget.state == RaabtaOrbState.completion) {
        _completionBlend = 1;
      }
      _previousState = oldWidget.state;
    }
    if (oldWidget.animationsEnabled != widget.animationsEnabled ||
        oldWidget.idleVisualsOnly != widget.idleVisualsOnly ||
        oldWidget.state != widget.state) {
      _syncTicker();
    }
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  bool get _routeVisible => ModalRoute.of(context)?.isCurrent ?? true;

  bool get _idleResting =>
      widget.state == RaabtaOrbState.idle && widget.idleVisualsOnly;

  bool get _shouldAnimate {
    if (_idleResting) return false;
    if (_reduceMotion || !widget.animationsEnabled) return false;
    if (!_routeVisible || !TickerMode.of(context)) return false;
    if (widget.state == RaabtaOrbState.error) return false;
    return true;
  }

  void _syncTicker() {
    if (!_shouldAnimate) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = _idleResting ? 0 : 0.35;
      return;
    }
    if (widget.state == RaabtaOrbState.completion) {
      if (_controller.duration != const Duration(milliseconds: 300)) {
        _controller.duration = const Duration(milliseconds: 300);
      }
      if (!_controller.isAnimating) {
        _controller.forward(from: 0);
      }
      return;
    }
    if (_controller.duration != RaabtaOrb.breathDuration) {
      _controller.duration = RaabtaOrb.breathDuration;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final extent = widget.size * 1.26;

    return RepaintBoundary(
      child: SizedBox(
        width: extent,
        height: extent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (widget.state == RaabtaOrbState.completion && _shouldAnimate) {
              _completionBlend = Curves.easeOut.transform(_controller.value);
            }
            return CustomPaint(
              painter: _RaabtaOrbPainter(
                state: widget.state,
                priorState: _previousState,
                t: _controller.value,
                diameter: widget.size,
                showDepthRings: widget.showDepthRings,
                reduceMotion: _reduceMotion || !widget.animationsEnabled,
                idleVisualsOnly: widget.idleVisualsOnly,
                tactileMateriality: widget.tactileMateriality,
                completionBlend: _completionBlend,
                isLight: AppColors.isLight,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RaabtaOrbPainter extends CustomPainter {
  _RaabtaOrbPainter({
    required this.state,
    required this.priorState,
    required this.t,
    required this.diameter,
    required this.showDepthRings,
    required this.reduceMotion,
    required this.idleVisualsOnly,
    required this.tactileMateriality,
    required this.completionBlend,
    required this.isLight,
  });

  final RaabtaOrbState state;
  final RaabtaOrbState? priorState;
  final double t;
  final double diameter;
  final bool showDepthRings;
  final bool reduceMotion;
  final bool idleVisualsOnly;
  final bool tactileMateriality;
  final double completionBlend;
  final bool isLight;

  static const _twoPi = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = diameter / 2;

    final breath = reduceMotion
        ? 0.5
        : 0.5 + 0.5 * math.sin(t * _twoPi);

    var effectiveState = state;
    if (state == RaabtaOrbState.completion) {
      effectiveState = priorState ?? RaabtaOrbState.responding;
    }

    var sphereScale = 1.0 + (breath - 0.5) * 0.08;
    var haloStrength = 0.22 + breath * 0.12;
    var listenTightness = 0.0;
    var processingBoost = 0.0;
    var respondPhase = t;
    var desaturate = 0.0;

    if (idleVisualsOnly && effectiveState == RaabtaOrbState.idle) {
      return;
    }

    if (tactileMateriality && effectiveState == RaabtaOrbState.idle) {
      haloStrength = 0.05;
      sphereScale = 1.0;
    }

    switch (effectiveState) {
      case RaabtaOrbState.idle:
        break;
      case RaabtaOrbState.listening:
        listenTightness = reduceMotion ? 0.75 : breath;
      case RaabtaOrbState.processing:
        sphereScale *= 0.94;
        processingBoost = 0.18;
        haloStrength += 0.12;
      case RaabtaOrbState.responding:
        respondPhase = t;
      case RaabtaOrbState.error:
        desaturate = 1;
        sphereScale = 1;
        haloStrength = 0.08;
      case RaabtaOrbState.completion:
        break;
    }

    if (state == RaabtaOrbState.completion) {
      final idleScale = 1.0 + (breath - 0.5) * 0.08;
      sphereScale = lerpDouble(sphereScale, idleScale, completionBlend)!;
      haloStrength = lerpDouble(haloStrength, 0.22 + breath * 0.12, completionBlend)!;
      processingBoost *= 1 - completionBlend;
      listenTightness *= 1 - completionBlend;
      desaturate *= 1 - completionBlend;
      if (completionBlend >= 0.99) {
        effectiveState = RaabtaOrbState.idle;
      }
    }

    _paintHalo(canvas, center, r, haloStrength + processingBoost, desaturate);

    if (showDepthRings && effectiveState == RaabtaOrbState.idle) {
      _paintDepthRings(canvas, center, r, desaturate);
    }

    if (effectiveState == RaabtaOrbState.listening) {
      _paintListenRing(canvas, center, r, listenTightness, desaturate);
    }

    if (effectiveState == RaabtaOrbState.responding && !reduceMotion) {
      _paintRespondRings(canvas, center, r, respondPhase, desaturate);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(sphereScale);
    canvas.translate(-center.dx, -center.dy);
    _paintSphere(canvas, center, r, breath, desaturate);
    if (desaturate < 0.95) {
      _paintGoldArc(canvas, center, r, effectiveState, t);
    }
    canvas.restore();

    if (effectiveState == RaabtaOrbState.processing) {
      _paintProcessingDot(canvas, center, r, t, desaturate);
    }
  }

  void _paintHalo(
    Canvas canvas,
    Offset center,
    double r,
    double strength,
    double desaturate,
  ) {
    final color = Color.lerp(
      AppColors.purpleGlow,
      AppColors.textTertiary,
      desaturate,
    )!;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: strength),
          AppColors.cyanGlow.withValues(alpha: strength * 0.35 * (1 - desaturate)),
          Colors.transparent,
        ],
        stops: const [0.35, 0.62, 1],
      ).createShader(Rect.fromCircle(center: center, radius: r * 1.28));
    canvas.drawCircle(center, r * 1.26, paint);
  }

  void _paintDepthRings(
    Canvas canvas,
    Offset center,
    double r,
    double desaturate,
  ) {
    const outerFactor = 2.31;
    const innerFactor = 1.65;
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = Color.lerp(
        AppColors.purpleGlow,
        AppColors.textTertiary,
        desaturate,
      )!.withValues(alpha: 0.22);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = Color.lerp(
        AppColors.blueGlow,
        AppColors.textTertiary,
        desaturate,
      )!.withValues(alpha: 0.22);
    canvas.drawCircle(center, r * outerFactor, outer);
    canvas.drawCircle(center, r * innerFactor, inner);
  }

  void _paintListenRing(
    Canvas canvas,
    Offset center,
    double r,
    double tightness,
    double desaturate,
  ) {
    final gap = lerpDouble(0.22, 0.08, tightness)!;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = Color.lerp(
        AppColors.cyanGlow,
        AppColors.textTertiary,
        desaturate,
      )!.withValues(alpha: 0.55);
    canvas.drawCircle(center, r * (1 + gap), paint);
  }

  void _paintRespondRings(
    Canvas canvas,
    Offset center,
    double r,
    double phase,
    double desaturate,
  ) {
    final base = Color.lerp(
      AppColors.cyanGlow,
      AppColors.textTertiary,
      desaturate,
    )!;
    for (var i = 0; i < 2; i++) {
      final p = (phase + i * 0.45) % 1.0;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = base.withValues(alpha: (1 - p) * 0.35);
      canvas.drawCircle(center, r * (1.02 + p * 0.38), paint);
    }
  }

  void _paintSphere(
    Canvas canvas,
    Offset center,
    double r,
    double breath,
    double desaturate,
  ) {
    final core = Color.lerp(
      AppColors.brandFamilyMain,
      AppColors.textTertiary,
      desaturate,
    )!;
    final rim = Color.lerp(
      isLight ? AppColors.brandFamilyText : AppColors.sharePurple,
      AppColors.surfaceElevated,
      desaturate * 0.85,
    )!;
    final under = Color.lerp(
      AppColors.cyanGlow,
      AppColors.textTertiary,
      desaturate,
    )!;

    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.28, -0.32),
        radius: 0.95,
        colors: [
          core.withValues(alpha: 0.98),
          Color.lerp(rim, core, 0.35)!,
          under.withValues(alpha: 0.35 + breath * 0.1),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, spherePaint);

    final highlight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 0.55,
        colors: [
          Colors.white.withValues(alpha: 0.28 * (1 - desaturate)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, highlight);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = Colors.white.withValues(alpha: 0.14 + breath * 0.05);
    canvas.drawCircle(center, r - 0.4, border);
  }

  void _paintGoldArc(
    Canvas canvas,
    Offset center,
    double r,
    RaabtaOrbState effectiveState,
    double tick,
  ) {
    final sweep = effectiveState == RaabtaOrbState.processing ? 2.35 : 2.1;
    final start = -2.65 + (effectiveState == RaabtaOrbState.processing ? tick * 0.15 : 0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..color = AppColors.goldFamilyMain.withValues(alpha: 0.92);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.92),
      start,
      sweep,
      false,
      paint,
    );
  }

  void _paintProcessingDot(
    Canvas canvas,
    Offset center,
    double r,
    double tick,
    double desaturate,
  ) {
    final angle = tick * _twoPi;
    final dotCenter = center + Offset(math.cos(angle), math.sin(angle)) * (r * 1.1);
    final paint = Paint()
      ..color = Color.lerp(
        AppColors.goldFamilyMain,
        AppColors.textTertiary,
        desaturate,
      )!;
    canvas.drawCircle(dotCenter, math.max(1.8, r * 0.07), paint);
  }

  @override
  bool shouldRepaint(covariant _RaabtaOrbPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.t != t ||
        oldDelegate.diameter != diameter ||
        oldDelegate.reduceMotion != reduceMotion ||
        oldDelegate.completionBlend != completionBlend ||
        oldDelegate.showDepthRings != showDepthRings ||
        oldDelegate.isLight != isLight;
  }
}

/// Debug grid of all orb states (tests and manual QA).
class RaabtaOrbStatePreview extends StatelessWidget {
  const RaabtaOrbStatePreview({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    AppColors.applyBrightness(Theme.of(context).brightness == Brightness.light);
    const states = RaabtaOrbState.values;
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 16,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            for (final state in states)
              SizedBox(
                width: size * 1.4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RaabtaOrb(
                      state: state,
                      size: size,
                      showDepthRings: state == RaabtaOrbState.idle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.name,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
