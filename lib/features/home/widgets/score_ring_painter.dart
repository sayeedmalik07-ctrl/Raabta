import 'dart:math';

import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';

/// Paints the animated expat score ring with track, gradient progress, and glow.
class ScoreRingPainter extends CustomPainter {
  ScoreRingPainter({
    required this.progress,
    this.strokeWidth = 16,
    this.ambientGlow = 0,
    this.glowColor,
  });

  final double progress;
  final double strokeWidth;
  final double ambientGlow;
  final Color? glowColor;

  static const double _startAngle = -pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = AppColors.glassBorderBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final accent = glowColor ?? AppColors.cyanGlow;
    final pulse = ambientGlow.clamp(0.0, 1.0);

    if (pulse > 0) {
      final ambientPaint = Paint()
        ..color = accent.withValues(alpha: 0.08 + pulse * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 10 + pulse * 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + pulse * 14);
      canvas.drawCircle(center, radius, ambientPaint);
    }

    final sweepAngle = 2 * pi * clampedProgress;
    if (sweepAngle <= 0) {
      return;
    }

    final gradientShader = SweepGradient(
      colors: AppColors.scoreGradient,
      startAngle: _startAngle,
      endAngle: _startAngle + sweepAngle,
    ).createShader(rect);

    final glowPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6 + pulse * 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + pulse * 6)
      ..color = accent.withValues(alpha: 0.2 + pulse * 0.2);
    canvas.drawArc(rect, _startAngle, sweepAngle, false, glowPaint);

    final progressPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ambientGlow != ambientGlow ||
        oldDelegate.glowColor != glowColor;
  }
}
