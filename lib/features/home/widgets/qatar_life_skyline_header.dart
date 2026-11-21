import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Compact Doha West Bay–inspired skyline backdrop for the Qatar Life heading.
///
/// Uses a static vector silhouette (no bundled photograph) so the header stays
/// lightweight and licensing-safe until a project-owned photo asset exists.
class QatarLifeSkylineHeader extends StatelessWidget {
  const QatarLifeSkylineHeader({
    super.key,
    required this.child,
  });

  final Widget child;

  /// Target visual band for the header backdrop (70–90dp).
  static const visualHeight = 88.0;

  static LinearGradient _overlayGradient(bool isLight) {
    if (isLight) {
      // Lighter overlay at the bottom so silhouettes remain visible beneath text.
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.glassSurface.withValues(alpha: 0.16),
          AppColors.glassSurface.withValues(alpha: 0.11),
          Colors.white.withValues(alpha: 0.07),
        ],
        stops: const [0.0, 0.50, 1.0],
      );
    }

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.background.withValues(alpha: 0.62),
        AppColors.surfaceElevated.withValues(alpha: 0.82),
        Color.lerp(
          AppColors.surfaceElevated,
          AppColors.tealGlow,
          0.08,
        )!,
      ],
      stops: const [0.0, 0.52, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = AppColors.isLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeCardTier.homeCardRadius),
      child: SizedBox(
        height: visualHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              child: CustomPaint(
                key: const Key('qatar_life_skyline_backdrop'),
                painter: _DohaWestBaySkylinePainter(isLight: isLight),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: _overlayGradient(isLight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simplified West Bay skyline silhouette — static, decorative, no photograph.
class _DohaWestBaySkylinePainter extends CustomPainter {
  const _DohaWestBaySkylinePainter({required this.isLight});

  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final skylineTop = size.height * 0.18;
    final baseline = size.height;

    _paintAtmosphere(canvas, size, skylineTop);

    final fill = isLight
        ? Color.lerp(AppColors.tealGlow, AppColors.cyanGlow, 0.35)!
            .withValues(alpha: 0.50)
        : Color.lerp(Colors.white, AppColors.tealGlow, 0.22)!
            .withValues(alpha: 0.24);

    final accent = isLight
        ? AppColors.cyanGlow.withValues(alpha: 0.36)
        : AppColors.iceCyanGlow.withValues(alpha: 0.16);

    _drawRectTower(
      canvas,
      size,
      left: 0.02,
      width: 0.11,
      height: 0.34,
      baseline: baseline,
      fill: fill,
    );
    _drawRectTower(
      canvas,
      size,
      left: 0.12,
      width: 0.08,
      height: 0.48,
      baseline: baseline,
      fill: accent,
    );
    _drawSpireTower(
      canvas,
      size,
      center: 0.28,
      width: 0.05,
      height: 0.72,
      baseline: baseline,
      fill: fill,
    );
    _drawSailTower(
      canvas,
      size,
      center: 0.42,
      width: 0.12,
      height: 0.78,
      baseline: baseline,
      fill: accent,
    );
    _drawCylinderTower(
      canvas,
      size,
      center: 0.58,
      width: 0.10,
      height: 0.66,
      baseline: baseline,
      fill: fill,
    );
    _drawRectTower(
      canvas,
      size,
      left: 0.68,
      width: 0.10,
      height: 0.52,
      baseline: baseline,
      fill: fill,
    );
    _drawRectTower(
      canvas,
      size,
      left: 0.80,
      width: 0.09,
      height: 0.40,
      baseline: baseline,
      fill: accent,
    );
    _drawRectTower(
      canvas,
      size,
      left: 0.90,
      width: 0.08,
      height: 0.30,
      baseline: baseline,
      fill: fill,
    );
  }

  void _paintAtmosphere(Canvas canvas, Size size, double skylineTop) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isLight
            ? [
                AppColors.cyanGlow.withValues(alpha: 0.08),
                AppColors.tealGlow.withValues(alpha: 0.16),
              ]
            : [
                AppColors.background.withValues(alpha: 0.20),
                AppColors.tealGlow.withValues(alpha: 0.08),
              ],
      ).createShader(sky);
    canvas.drawRect(sky, skyPaint);
  }

  void _drawRectTower(
    Canvas canvas,
    Size size, {
    required double left,
    required double width,
    required double height,
    required double baseline,
    required Color fill,
  }) {
    final rect = Rect.fromLTWH(
      size.width * left,
      baseline - size.height * height,
      size.width * width,
      size.height * height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
      Paint()..color = fill,
    );
  }

  void _drawSpireTower(
    Canvas canvas,
    Size size, {
    required double center,
    required double width,
    required double height,
    required double baseline,
    required Color fill,
  }) {
    final w = size.width * width;
    final h = size.height * height;
    final cx = size.width * center;
    final baseTop = baseline - h * 0.72;

    final body = Rect.fromLTWH(cx - w / 2, baseTop, w, h * 0.72);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(w * 0.2)),
      Paint()..color = fill,
    );

    final spire = Path()
      ..moveTo(cx - w * 0.18, baseTop)
      ..lineTo(cx, baseline - h)
      ..lineTo(cx + w * 0.18, baseTop)
      ..close();
    canvas.drawPath(spire, Paint()..color = fill);
  }

  void _drawSailTower(
    Canvas canvas,
    Size size, {
    required double center,
    required double width,
    required double height,
    required double baseline,
    required Color fill,
  }) {
    final w = size.width * width;
    final h = size.height * height;
    final cx = size.width * center;
    final top = baseline - h;

    final sail = Path()
      ..moveTo(cx - w * 0.42, baseline)
      ..quadraticBezierTo(cx - w * 0.05, baseline - h * 0.42, cx + w * 0.36, top)
      ..lineTo(cx + w * 0.36, baseline)
      ..close();
    canvas.drawPath(sail, Paint()..color = fill);
  }

  void _drawCylinderTower(
    Canvas canvas,
    Size size, {
    required double center,
    required double width,
    required double height,
    required double baseline,
    required Color fill,
  }) {
    final w = size.width * width;
    final h = size.height * height;
    final cx = size.width * center;
    final bodyTop = baseline - h * 0.78;
    final domeHeight = h * 0.22;

    final body = Rect.fromLTWH(cx - w / 2, bodyTop + domeHeight * 0.35, w, h * 0.78);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(w * 0.18)),
      Paint()..color = fill,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bodyTop + domeHeight * 0.55),
        width: w,
        height: domeHeight,
      ),
      Paint()..color = fill,
    );
  }

  @override
  bool shouldRepaint(covariant _DohaWestBaySkylinePainter oldDelegate) =>
      oldDelegate.isLight != isLight;
}
