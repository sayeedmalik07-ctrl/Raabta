import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Visible wizard progress — category is always step 1 when shown.
class PostFlowStepIndicator extends StatelessWidget {
  const PostFlowStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabelKey,
    required this.locale,
  });

  final int currentStep;
  final int totalSteps;
  final String stepLabelKey;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              PostEngineStrings.format(
                'flow_step_of',
                locale,
                params: {
                  'current': '$currentStep',
                  'total': '$totalSteps',
                },
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: AppTypography.caption.copyWith(
                color: AppColors.cyanGlow,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.glassBorderBright,
            color: AppColors.cyanGlow,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          PostEngineStrings.t(stepLabelKey, locale),
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
