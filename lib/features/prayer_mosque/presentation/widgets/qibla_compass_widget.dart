import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';

class QiblaCompassWidget extends StatelessWidget {
  const QiblaCompassWidget({
    super.key,
    required this.heading,
    required this.qiblaBearing,
    required this.accuracy,
    required this.locale,
    required this.distanceKm,
    this.loading = false,
    this.compassUnavailable = false,
  });

  final double? heading;
  final double? qiblaBearing;
  final double? accuracy;
  final String locale;
  final double? distanceKm;
  final bool loading;
  final bool compassUnavailable;

  bool get isAligned {
    if (qiblaBearing == null || heading == null) return false;
    final delta = (qiblaBearing! - heading!).abs() % 360;
    final shortest = delta > 180 ? 360 - delta : delta;
    return shortest <= 5;
  }

  double? get needleRotation {
    if (qiblaBearing == null || heading == null) return null;
    return (qiblaBearing! - heading!) * (math.pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: GlassProgressIndicator(color: AppColors.chipPrayer),
      );
    }

    return Column(
      children: [
        Text(
          PrayerStrings.t('prayer_qibla_instruction', locale),
          style: AppTypography.body,
          textAlign: TextAlign.center,
        ),
        if (compassUnavailable) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            PrayerStrings.t('prayer_compass_unavailable', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAligned ? AppColors.success : AppColors.glassBorderBright,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isAligned ? AppColors.success : AppColors.tealGlow)
                        .withValues(alpha: 0.25),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: heading != null
                  ? CustomPaint(
                      painter: _CompassDialPainter(heading: heading!),
                    )
                  : null,
            ),
            if (needleRotation != null && !compassUnavailable)
              Transform.rotate(
                angle: needleRotation!,
                child: Icon(
                  Icons.navigation_rounded,
                  size: 64,
                  color: isAligned ? AppColors.success : AppColors.amberGlow,
                ),
              )
            else if (qiblaBearing != null)
              Transform.rotate(
                angle: qiblaBearing! * (math.pi / 180),
                child: Icon(
                  Icons.navigation_rounded,
                  size: 64,
                  color: AppColors.amberGlow.withValues(alpha: 0.85),
                ),
              ),
            Text(
              '🕋',
              style: TextStyle(
                fontSize: 32,
                color: isAligned ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _StatRow(
                label: PrayerStrings.t('prayer_qibla_heading', locale),
                value: heading != null
                    ? '${heading!.toStringAsFixed(1)}°'
                    : '—',
              ),
              _StatRow(
                label: PrayerStrings.t('prayer_qibla_angle', locale),
                value: qiblaBearing != null
                    ? '${qiblaBearing!.toStringAsFixed(1)}°'
                    : '—',
              ),
              _StatRow(
                label: PrayerStrings.t('prayer_qibla_accuracy', locale),
                value: accuracy != null
                    ? '${accuracy!.toStringAsFixed(0)}°'
                    : '—',
              ),
              if (distanceKm != null)
                _StatRow(
                  label: PrayerStrings.t('prayer_qibla_distance', locale),
                  value: '${distanceKm!.toStringAsFixed(0)} km',
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                PrayerStrings.t('prayer_calibrate', locale),
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.title),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({required this.heading});

  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (var i = 0; i < 72; i++) {
      final angle = i * 5 * math.pi / 180;
      final inner = radius - (i % 9 == 0 ? 16 : 8);
      final x1 = center.dx + radius * math.sin(angle);
      final y1 = center.dy - radius * math.cos(angle);
      final x2 = center.dx + inner * math.sin(angle);
      final y2 = center.dy - inner * math.cos(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
