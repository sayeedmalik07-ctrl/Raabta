import 'dart:ui';

import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';

/// Universal glass surface for blur, border, tint, and optional glow.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSpacing.radiusLg,
    this.glowColor,
    this.glowIntensity = 0,
    this.blurSigma = AppSpacing.glassBlur,
    this.backgroundColor,
    this.onTap,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final double blurSigma;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Home design kit v2.1 §3: no BackdropFilter in light mode.
    final effectiveBlur = AppColors.isLight ? 0.0 : blurSigma;
    final surfaceColor = backgroundColor ??
        (AppColors.isLight ? AppColors.surface : AppColors.glassSurface);

    Widget surface = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.glassBorder,
          width: AppSpacing.glassBorderWidth,
        ),
      ),
      child: child,
    );

    if (effectiveBlur > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: surface,
      );
    }

    final content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: _buildGlowShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: surface,
      ),
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }

  List<BoxShadow>? _buildGlowShadow() {
    final shadows = <BoxShadow>[];

    if (AppColors.isLight) {
      shadows.add(
        const BoxShadow(
          color: AppColors.shadowSoft,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      );
    }

    if (glowColor != null && glowIntensity > 0) {
      shadows.add(
        BoxShadow(
          color: glowColor!.withValues(alpha: glowIntensity),
          blurRadius: AppSpacing.glassGlowBlur,
          spreadRadius: 0,
        ),
      );
    }

    return shadows.isEmpty ? null : shadows;
  }
}
