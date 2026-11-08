import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';

/// Decorative empty-state hero for Food Inspector surfaces.
class FoodInspectorEmptyIllustration extends StatelessWidget {
  const FoodInspectorEmptyIllustration({
    super.key,
    this.icon = Icons.qr_code_scanner_rounded,
    this.size = 120,
    this.accentColor = AppColors.purpleGlow,
  });

  final IconData icon;
  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.08),
              border: Border.all(color: accentColor.withValues(alpha: 0.18)),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amberGlow.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.amberGlow.withValues(alpha: 0.22),
              ),
            ),
          ),
          Icon(icon, size: AppSpacing.iconXl, color: accentColor),
        ],
      ),
    );
  }
}
