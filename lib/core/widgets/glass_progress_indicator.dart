import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';

/// Branded loading spinner — cyan accent on glass backgrounds.
class GlassProgressIndicator extends StatelessWidget {
  const GlassProgressIndicator({
    super.key,
    this.size,
    this.strokeWidth = 4,
    this.color = AppColors.cyanGlow,
  });

  final double? size;
  final double strokeWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth,
    );

    if (size == null) return indicator;

    return SizedBox(
      width: size,
      height: size,
      child: indicator,
    );
  }
}
