import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

void showOvertimeConfidenceSheet(
  BuildContext context, {
  required String locale,
  required OvertimeTruthResult result,
}) {
  final factors = <String>[
    if (result.record.profile.basicSalary > 0)
      EosbStrings.t('ot_conf_factor_salary', locale),
    if (result.record.profile.employeeName.isNotEmpty)
      EosbStrings.t('ot_conf_factor_name', locale),
    if (result.record.days.any((d) => d.totalHours > 0))
      EosbStrings.t('ot_conf_factor_hours', locale),
    if (result.record.employerPaidOvertime > 0)
      EosbStrings.t('ot_conf_factor_employer', locale),
    if (result.lineItems.length > 1)
      EosbStrings.t('ot_conf_factor_categories', locale),
    ...result.validationIssues.map(
      (_) => EosbStrings.t('ot_conf_factor_validation', locale),
    ),
  ];

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t('ot_confidence_explainer_title', locale),
            style: AppTypography.headline2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${result.confidenceScore}% — ${EosbStrings.t('ot_confidence_explainer_body', locale)}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          ...factors.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: AppColors.cyanGlow),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(f, style: AppTypography.bodySmall)),
                ],
              ),
            ),
          ),
          if (factors.isEmpty)
            Text(
              EosbStrings.t('ot_confidence_explainer_empty', locale),
              style: AppTypography.bodySmall,
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
}
