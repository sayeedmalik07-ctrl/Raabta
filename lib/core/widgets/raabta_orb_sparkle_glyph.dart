import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// Raabta link mark + small sparkle (Batch H / logo kit).
///
/// Vector paths match [RaabtaOrbBrandGlyphTokens.markWhiteSvg].
class RaabtaOrbSparkleGlyph extends StatelessWidget {
  const RaabtaOrbSparkleGlyph({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _RaabtaOrbBrandGlyphPainter(
        strokeColor: Colors.white.withValues(alpha: 0.95),
        junctionColor: AppColors.accentGold,
      ),
    );
  }
}

/// Logo kit source paths (`assets/raabta_brand/svg/raabta_mark_white.svg`).
abstract final class RaabtaOrbBrandGlyphTokens {
  RaabtaOrbBrandGlyphTokens._();

  static const markWhiteSvg = 'assets/raabta_brand/svg/raabta_mark_white.svg';
  static const markMonoSvg = 'assets/raabta_brand/svg/raabta_mark_mono.svg';
  static const viewBox = 100.0;
  static const strokeWidth = 12.0;
  static const junctionRadius = 7.5;
}

class _RaabtaOrbBrandGlyphPainter extends CustomPainter {
  _RaabtaOrbBrandGlyphPainter({
    required this.strokeColor,
    required this.junctionColor,
  });

  final Color strokeColor;
  final Color junctionColor;

  @override
  void paint(Canvas canvas, Size size) {
    final markSide = size.width * 0.72;
    final dx = (size.width - markSide) / 2;
    final dy = (size.height - markSide) / 2 + size.height * 0.02;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(markSide / RaabtaOrbBrandGlyphTokens.viewBox);

    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = RaabtaOrbBrandGlyphTokens.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final stem = Path()
      ..moveTo(30, 86)
      ..lineTo(30, 38)
      ..cubicTo(30, 24, 40, 14, 54, 14)
      ..cubicTo(68, 14, 77, 23, 77, 34)
      ..cubicTo(77, 46, 67, 54, 54, 54)
      ..lineTo(30, 54);

    final tail = Path()
      ..moveTo(54, 54)
      ..cubicTo(64, 58, 69, 70, 72, 86);

    canvas.drawPath(stem, stroke);
    canvas.drawPath(tail, stroke);

    final junction = Paint()
      ..color = junctionColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(54, 54),
      RaabtaOrbBrandGlyphTokens.junctionRadius,
      junction,
    );

    canvas.restore();

    _paintAccentSparkle(canvas, size);
  }

  void _paintAccentSparkle(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.80, size.height * 0.20);
    final mainR = size.width * 0.11;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - math.pi / 4;
      final tip = center + Offset(math.cos(angle) * mainR, math.sin(angle) * mainR);
      const wing = 0.32;
      final a1 = angle - wing;
      final a2 = angle + wing;
      final inner = mainR * 0.2;
      if (i == 0) {
        path.moveTo(tip.dx, tip.dy);
      } else {
        path.lineTo(tip.dx, tip.dy);
      }
      path.lineTo(
        center.dx + math.cos(a1) * inner,
        center.dy + math.sin(a1) * inner,
      );
      path.lineTo(
        center.dx + math.cos(a2) * inner,
        center.dy + math.sin(a2) * inner,
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RaabtaOrbBrandGlyphPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.junctionColor != junctionColor;
  }
}