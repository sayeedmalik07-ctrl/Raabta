import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/models/job_application.dart';
import 'package:raabta/screens/jobs/l10n/jobs_application_strings.dart';

class JobApplicationStatusBadge extends StatelessWidget {
  const JobApplicationStatusBadge({
    super.key,
    required this.status,
    required this.locale,
  });

  final JobApplicationStatus status;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      JobApplicationStatus.applied => AppColors.cyanGlow,
      JobApplicationStatus.underReview => AppColors.purpleGlow,
      JobApplicationStatus.contacted => AppColors.success,
      JobApplicationStatus.closed => AppColors.textTertiary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        JobsApplicationStrings.t(status.labelKey(), locale),
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }
}
