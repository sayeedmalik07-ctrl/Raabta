import 'package:flutter/material.dart';

import 'food_inspector_theme.dart';

class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const frameW = 270.0;
        const frameH = 130.0;
        final left = (constraints.maxWidth - frameW) / 2;
        final top = (constraints.maxHeight - frameH) / 2;
        final scanRect = Rect.fromLTWH(left, top, frameW, frameH);

        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _OverlayPainter(scanRect: scanRect),
            ),
            Positioned(
              left: left,
              top: top,
              width: frameW,
              height: frameH,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: foodInspectorPurple, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const _Corner(alignment: Alignment.topLeft),
                  const _Corner(alignment: Alignment.topRight),
                  const _Corner(alignment: Alignment.bottomLeft),
                  const _Corner(alignment: Alignment.bottomRight),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({required this.scanRect});

  final Rect scanRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, cutout),
      overlayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect;
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(painter: _CornerPainter(alignment: alignment)),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.alignment});

  final Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foodInspectorGold
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? 16.0 : -16.0;
    final dy = isTop ? 16.0 : -16.0;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}
