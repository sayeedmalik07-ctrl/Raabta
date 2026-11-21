import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';

class PostMarketplaceCategoryConfirmStep extends StatelessWidget {
  const PostMarketplaceCategoryConfirmStep({
    super.key,
    required this.locale,
    required this.totalSteps,
    required this.categoryLabel,
    required this.onConfirm,
    required this.onChangeCategory,
  });

  final String locale;
  final int totalSteps;
  final String categoryLabel;
  final VoidCallback onConfirm;
  final VoidCallback onChangeCategory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        PostFlowStepIndicator(
          currentStep: 1,
          totalSteps: totalSteps,
          stepLabelKey: 'flow_step_category',
          locale: locale,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          PostEngineStrings.t('marketplace_category_detected', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(categoryLabel, style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.xl),
        GlassPrimaryButton(
          label: PostEngineStrings.t('marketplace_category_confirm', locale),
          onPressed: onConfirm,
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassSecondaryButton(
          label: PostEngineStrings.t('marketplace_category_change', locale),
          onPressed: onChangeCategory,
        ),
      ],
    );
  }
}
