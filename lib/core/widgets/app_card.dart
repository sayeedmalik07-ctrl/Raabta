import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.gradientBorder = false,
    this.glass = false,
    this.borderGradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool gradientBorder;
  final bool glass;
  final Gradient? borderGradient;

  static const BoxShadow _premiumShadow = BoxShadow(
    color: Colors.black45,
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.xxl);
    final innerDecoration = BoxDecoration(
      color: glass ? AppColors.glass : AppColors.surface,
      borderRadius: borderRadius,
      border: glass && !gradientBorder
          ? Border.all(color: AppColors.glassBorder)
          : null,
      boxShadow: const [_premiumShadow],
    );

    if (gradientBorder) {
      return Container(
        decoration: BoxDecoration(
          gradient: borderGradient ?? AppColors.primaryGradient,
          borderRadius: borderRadius,
          boxShadow: const [_premiumShadow],
        ),
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: innerDecoration.copyWith(
            color: glass ? AppColors.glass : AppColors.surface,
          ),
          padding: padding,
          child: child,
        ),
      );
    }

    return Container(
      decoration: innerDecoration,
      padding: padding,
      child: child,
    );
  }
}
