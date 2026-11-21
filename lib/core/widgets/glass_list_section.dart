import 'dart:ui';

import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';

/// Glass surface for grouped list rows — uses [Material] instead of [DecoratedBox]
/// so rows never trigger the ListTile-in-glass framework assertion.
class GlassListSection extends StatelessWidget {
  const GlassListSection({
    super.key,
    required this.children,
    this.borderRadius = AppSpacing.radiusMd,
  });

  final List<Widget> children;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    // Home design kit v2.1 §3: no BackdropFilter in light mode.
    final effectiveBlur = AppColors.isLight ? 0.0 : AppSpacing.glassBlur;

    Widget section = Material(
      color: AppColors.glassSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    if (effectiveBlur > 0) {
      section = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: section,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: section,
    );
  }
}
