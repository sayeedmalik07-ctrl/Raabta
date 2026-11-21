import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/profile/l10n/progressive_profile_strings.dart';
import 'package:raabta/screens/profile/progressive_profile_flow.dart';

/// Step progress for the three-field profile capture flow.
class ProgressiveProfileStepIndicator extends StatelessWidget {
  const ProgressiveProfileStepIndicator({
    super.key,
    required this.field,
    required this.locale,
  });

  final ProgressiveProfileField field;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final current = ProgressiveProfileFlow.stepNumberFor(field);
    const total = ProgressiveProfileFlow.totalSteps;
    final progress = current / total;
    final stepLabel = ProgressiveProfileStrings.t(
      ProgressiveProfileStrings.stepLabelKey(field),
      locale,
    );
    final semanticsLabel = ProgressiveProfileStrings.format(
      'sem_progress',
      locale,
      params: {
        'current': '$current',
        'total': '$total',
        'field': stepLabel,
      },
    );

    return Semantics(
      label: semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                ProgressiveProfileStrings.format(
                  'flow_step_of',
                  locale,
                  params: {
                    'current': '$current',
                    'total': '$total',
                  },
                ),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(total, (index) {
                  final active = index < current;
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: index == 0 ? 0 : AppSpacing.xs,
                    ),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.cyanGlow
                            : AppColors.glassBorderBright,
                      ),
                    ),
                  );
                }),
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
            stepLabel,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
