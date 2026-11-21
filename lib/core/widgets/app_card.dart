import 'package:flutter/material.dart';

import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';

/// Backward-compatible card that delegates to the shared glass system.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.gradientBorder = false,
    this.glass = false,
    this.borderGradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool gradientBorder;
  final bool glass;
  final Gradient? borderGradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final glowColor = gradientBorder && borderGradient != null
        ? borderGradient!.colors.first
        : null;

    if (onTap != null) {
      return GlassCard(
        onTap: onTap,
        padding: padding,
        borderRadius: AppSpacing.radiusLg,
        glowColor: glowColor,
        glowIntensity: gradientBorder ? 0.18 : 0,
        child: child,
      );
    }

    if (glass || gradientBorder) {
      return GlassContainer(
        padding: padding,
        borderRadius: AppSpacing.radiusLg,
        glowColor: glowColor,
        glowIntensity: gradientBorder ? 0.18 : 0,
        child: child,
      );
    }

    return GlassContainer(
      padding: padding,
      borderRadius: AppSpacing.radiusLg,
      child: child,
    );
  }
}
