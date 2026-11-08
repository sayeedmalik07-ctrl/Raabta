import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Compact inline tag for metadata labels and tappable suggestion chips.
class GlassTag extends StatelessWidget {
  const GlassTag({
    super.key,
    required this.label,
    this.icon,
    this.accentColor = AppColors.cyanGlow,
    this.onTap,
    this.margin,
    this.filled = true,
  });

  final String label;
  final IconData? icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      margin: margin,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: icon != null ? AppSpacing.xxs : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: filled
            ? accentColor.withValues(alpha: 0.12)
            : AppColors.glassSurface,
        borderRadius: BorderRadius.circular(
          filled ? AppSpacing.radiusSm : AppSpacing.radiusFull,
        ),
        border: filled ? null : Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: (icon != null ? AppTypography.chipLabel : AppTypography.caption)
                .copyWith(
              color: filled ? accentColor : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
