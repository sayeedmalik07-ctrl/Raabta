import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Compact metric display for counts, weather, and statistics.
class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.icon,
    required this.value,
    required this.accentColor,
    this.label,
  });

  final IconData icon;
  final String value;
  final Color accentColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      borderRadius: AppSpacing.radiusFull,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: accentColor),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                value,
                style: AppTypography.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  label!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
