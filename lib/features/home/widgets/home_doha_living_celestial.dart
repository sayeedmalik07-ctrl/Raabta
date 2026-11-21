import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:raabta/features/home/domain/home_doha_day_part.dart';
import 'package:raabta/features/home/domain/home_doha_scene_palette.dart';
import 'package:raabta/features/home/widgets/home_doha_header_choreography.dart';

/// Sun / moon in the Doha sky — gentle breathe when motion is allowed (Batch C).
class HomeDohaLivingCelestial extends StatefulWidget {
  const HomeDohaLivingCelestial({
    super.key,
    required this.palette,
    required this.part,
    this.animationsEnabled = true,
    this.size = HomeDohaTopZoneMetrics.celestialOrbDiameter,
  });

  final DohaScenePalette palette;
  final DohaDayPart part;
  final bool animationsEnabled;
  final double size;

  @override
  State<HomeDohaLivingCelestial> createState() => _HomeDohaLivingCelestialState();
}

class _HomeDohaLivingCelestialState extends State<HomeDohaLivingCelestial>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _breath;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant HomeDohaLivingCelestial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationsEnabled != widget.animationsEnabled) {
      _syncController();
    }
  }

  void _syncController() {
    if (!widget.animationsEnabled) {
      _controller?.dispose();
      _controller = null;
      _breath = null;
      return;
    }
    if (_controller != null) return;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _controller!, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool get _isMoon => widget.part == DohaDayPart.night;

  @override
  Widget build(BuildContext context) {
    final diameter = widget.size;
    Widget body = _isMoon
        ? _DohaNightCrescent(
            diameter: diameter,
            moonColor: widget.palette.celestialOrbColor,
            glowColor: widget.palette.celestialGlowColor,
          )
        : _DohaSunDisc(
            diameter: diameter,
            orbColor: widget.palette.celestialOrbColor,
            glowColor: widget.palette.celestialGlowColor,
          );

    if (_controller == null || _breath == null) {
      return SizedBox(width: diameter, height: diameter, child: body);
    }

    return AnimatedBuilder(
      animation: _breath!,
      builder: (context, child) {
        final t = _breath!.value;
        final scale = 0.94 + (t * 0.06);
        final glowAlpha = 0.5 + (t * 0.25);
        return Transform.scale(
          scale: scale,
          child: _isMoon
              ? _DohaNightCrescent(
                  diameter: diameter,
                  moonColor: widget.palette.celestialOrbColor,
                  glowColor:
                      widget.palette.celestialGlowColor.withValues(alpha: glowAlpha),
                )
              : _DohaSunDisc(
                  diameter: diameter,
                  orbColor: widget.palette.celestialOrbColor,
                  glowColor:
                      widget.palette.celestialGlowColor.withValues(alpha: glowAlpha),
                ),
        );
      },
    );
  }
}

class _DohaSunDisc extends StatelessWidget {
  const _DohaSunDisc({
    required this.diameter,
    required this.orbColor,
    required this.glowColor,
  });

  final double diameter;
  final Color orbColor;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: orbColor,
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

/// Waxing crescent via path difference (no overlay disc that reads as an "eye").
class _DohaNightCrescent extends StatelessWidget {
  const _DohaNightCrescent({
    required this.diameter,
    required this.moonColor,
    required this.glowColor,
  });

  final double diameter;
  final Color moonColor;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _DohaCrescentPainter(
          moonColor: moonColor,
          glowColor: glowColor,
        ),
      ),
    );
  }
}

class _DohaCrescentPainter extends CustomPainter {
  const _DohaCrescentPainter({
    required this.moonColor,
    required this.glowColor,
  });

  final Color moonColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final disc = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final biteCenter = Offset(radius + radius * 0.52, radius - radius * 0.04);
    final bite = Path()
      ..addOval(Rect.fromCircle(center: biteCenter, radius: radius * 0.9));
    final crescent = Path.combine(ui.PathOperation.difference, disc, bite);

    canvas.drawShadow(
      crescent,
      glowColor.withValues(alpha: 0.55),
      8,
      true,
    );
    canvas.drawPath(
      crescent,
      Paint()
        ..color = moonColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _DohaCrescentPainter oldDelegate) =>
      oldDelegate.moonColor != moonColor || oldDelegate.glowColor != glowColor;
}