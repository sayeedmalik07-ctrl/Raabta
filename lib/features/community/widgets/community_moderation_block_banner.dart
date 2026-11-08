import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

/// Shared hard-block feedback for Community composers (Part A).
class CommunityModerationBlockBanner extends StatelessWidget {
  const CommunityModerationBlockBanner({
    super.key,
    required this.message,
    this.guidelinesLine,
    this.compact = false,
  });

  final String message;
  final String? guidelinesLine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 16.0 : 18.0;
    final bodyStyle = (compact ? AppTypography.caption : AppTypography.bodySmall)
        .copyWith(color: AppColors.error);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: AppColors.error, size: iconSize),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message, style: bodyStyle),
            ),
          ],
        ),
        if (guidelinesLine != null && guidelinesLine!.isNotEmpty) ...[
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          Padding(
            padding: EdgeInsets.only(left: compact ? AppSpacing.lg : AppSpacing.lg),
            child: Text(
              guidelinesLine!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(
            HubLayoutTokens.noticeBannerRadius,
          ),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.22),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: content,
        ),
      ),
    );
  }
}
