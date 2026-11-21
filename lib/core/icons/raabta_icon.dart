import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';

/// Unified home/product icon — 24px grid, outlined stroke weight, theme-aware color.
class RaabtaIcon extends StatelessWidget {
  const RaabtaIcon(
    this.icon, {
    super.key,
    this.size = AppSpacing.iconLg,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Icon(
        icon,
        size: size,
        color: color ?? AppColors.textSecondary,
      ),
    );
  }
}
