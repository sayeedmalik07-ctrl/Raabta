import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/domain/post_quality_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

class PostQualityPanel extends StatelessWidget {
  const PostQualityPanel({
    super.key,
    required this.score,
    required this.locale,
  });

  final PostQualityScore score;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                PostEngineStrings.format(
                  'quality_percent',
                  locale,
                  params: {'percent': '${score.percent}'},
                ),
                style: AppTypography.title.copyWith(color: AppColors.cyanGlow),
              ),
              const Spacer(),
              if (!score.canPublish)
                Icon(Icons.info_outline, size: 18, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...score.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Row(
                children: [
                  Icon(
                    item.complete ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: item.complete ? AppColors.success : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      PostEngineStrings.t(item.labelKey, locale),
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (score.missingMessages.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              PostEngineStrings.t('quality_to_improve', locale),
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            ),
            ...score.missingMessages.take(4).map(
                  (msg) => Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Text(
                      '• $msg',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
