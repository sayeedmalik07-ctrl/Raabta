import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/design/raabta_continuous_shape.dart';
import 'package:raabta/core/design/raabta_physical_shadow_tokens.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';

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
    this.solidSurfaceFamily,
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

  /// Round 4B materiality — tinted solid surface (replaces glass tint + glow).
  final RaabtaSolidSurfaceFamily? solidSurfaceFamily;

  static bool get _preferSolidSurfaceOnPlatform {
    if (AppColors.isLight) return true;
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final solid = solidSurfaceFamily;

    var effectiveBlur = _preferSolidSurfaceOnPlatform ? 0.0 : blurSigma;
    if (solid != null) {
      effectiveBlur = 0;
    }

    final surfaceColor = solid != null
        ? (backgroundColor ??
            RaabtaSolidSurfaceTokens.fill(solid, brightness))
        : (backgroundColor ??
            (AppColors.isLight ? AppColors.surface : AppColors.glassSurface));

    final borderSide = solid != null
        ? BorderSide(
            color: RaabtaSolidSurfaceTokens.hairline(solid, brightness),
            width: 1,
          )
        : BorderSide(
            color: AppColors.glassBorder,
            width: AppSpacing.glassBorderWidth,
          );

    final surfaceShape = RaabtaContinuousShape.surface(
      borderRadius,
      side: borderSide,
    );

    Widget inner = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    if (effectiveBlur > 0) {
      inner = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: inner,
      );
    }

    final surface = Material(
      color: surfaceColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: surfaceShape,
      clipBehavior: Clip.antiAlias,
      child: inner,
    );

    final content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: RaabtaContinuousShape.shadowOnly(
        radius: borderRadius,
        shadows: _resolveOuterShadows(brightness),
      ),
      child: surface,
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

  List<BoxShadow>? _resolveOuterShadows(Brightness brightness) {
    if (solidSurfaceFamily != null) {
      return RaabtaPhysicalShadowTokens.card(brightness);
    }
    return _buildGlowShadow();
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