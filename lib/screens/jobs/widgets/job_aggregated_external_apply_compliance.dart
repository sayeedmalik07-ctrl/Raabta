import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// In-body disclosure for aggregated listings (disabled apply lives on action bar).
class JobAggregatedExternalApplyCompliance extends StatelessWidget {
  const JobAggregatedExternalApplyCompliance({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceElevated),
          ),
          child: Text(
            JobsStrings.t('jobs_aggregated_disclosure', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          JobsStrings.t('jobs_employer_apply_unavailable_body', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
