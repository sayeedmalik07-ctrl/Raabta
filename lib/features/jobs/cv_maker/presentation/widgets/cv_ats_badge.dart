import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/jobs/cv_maker/domain/cv_template_catalog.dart';

class CvAtsBadge extends StatelessWidget {
  const CvAtsBadge({
    super.key,
    required this.compatibility,
    this.compact = false,
  });

  final CvAtsCompatibility compatibility;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final optimized =
        compatibility.badge == CvAtsBadgeKind.optimized;
    final color = optimized ? AppColors.success : AppColors.warning;
    final icon = optimized ? Icons.verified_outlined : Icons.info_outline;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: compact ? 2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          SizedBox(width: compact ? 4 : AppSpacing.xxs),
          Flexible(
            child: Text(
              compatibility.label,
              style: (compact ? AppTypography.caption : AppTypography.bodySmall)
                  .copyWith(color: color, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
