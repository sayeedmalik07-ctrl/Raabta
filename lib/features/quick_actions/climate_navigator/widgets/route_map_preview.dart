import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Stylized route preview — decorative polyline, not live navigation.
class RouteMapPreview extends StatelessWidget {
  const RouteMapPreview({
    super.key,
    required this.fromLabel,
    required this.toLabel,
    required this.routeLabel,
    this.accentColor = AppColors.cyanGlow,
  });

  final String fromLabel;
  final String toLabel;
  final String routeLabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        height: 96,
        width: double.infinity,
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _RoutePreviewPainter(accentColor: accentColor),
            ),
            Positioned(
              left: AppSpacing.md,
              top: AppSpacing.sm,
              child: Text(
                routeLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textOnGlassMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              bottom: AppSpacing.sm,
              right: AppSpacing.md,
              child: Row(
                children: [
                  _Pin(label: _short(fromLabel), color: AppColors.successBright),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: accentColor.withValues(alpha: 0.35),
                    ),
                  ),
                  _Pin(label: _short(toLabel), color: AppColors.errorBright),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _short(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '—';
    if (trimmed.length <= 14) return trimmed;
    return '${trimmed.substring(0, 12)}…';
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_rounded, color: color, size: 16),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnGlassSecondary,
            fontSize: 9,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _RoutePreviewPainter extends CustomPainter {
  _RoutePreviewPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor.withValues(alpha: 0.12),
          AppColors.sharePurple.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.18,
        size.width * 0.88,
        size.height * 0.62,
      );

    final shadow = Paint()
      ..color = accentColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, shadow);

    final line = Paint()
      ..color = accentColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);

    final dotPaint = Paint()..color = accentColor.withValues(alpha: 0.5);
    final metric = path.computeMetrics().first;
    for (var t = 0.2; t <= 0.8; t += 0.15) {
      final pos = metric.getTangentForOffset(metric.length * t)?.position;
      if (pos != null) {
        canvas.drawCircle(pos, 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
