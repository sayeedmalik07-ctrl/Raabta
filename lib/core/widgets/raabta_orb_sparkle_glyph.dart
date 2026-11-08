import 'dart:math' as math;

import 'package:flutter/material.dart';

/// White four-point sparkle + secondary star (Home AI entry only, kit 01).
class RaabtaOrbSparkleGlyph extends StatelessWidget {
  const RaabtaOrbSparkleGlyph({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparkleGlyphPainter(),
    );
  }
}

class _SparkleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final mainR = size.width * 0.38;
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - math.pi / 4;
      final tip = c + Offset(math.cos(angle) * mainR, math.sin(angle) * mainR);
      const wing = 0.32;
      final a1 = angle - wing;
      final a2 = angle + wing;
      final inner = mainR * 0.18;
      if (i == 0) {
        path.moveTo(tip.dx, tip.dy);
      } else {
        path.lineTo(tip.dx, tip.dy);
      }
      path.lineTo(c.dx + math.cos(a1) * inner, c.dy + math.sin(a1) * inner);
      path.lineTo(c.dx + math.cos(a2) * inner, c.dy + math.sin(a2) * inner);
    }
    path.close();
    canvas.drawPath(path, paint);

    final small = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(c.dx + size.width * 0.14, c.dy + size.height * 0.16),
      size.width * 0.07,
      small,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
