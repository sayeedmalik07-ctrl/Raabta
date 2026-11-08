import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Secondary/outline glass button.
class GlassSecondaryButton extends StatelessWidget {
  const GlassSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onPressed,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppSpacing.radiusSm,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSpacing.iconSm, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label, style: AppTypography.button),
        ],
      ),
    );
  }
}
