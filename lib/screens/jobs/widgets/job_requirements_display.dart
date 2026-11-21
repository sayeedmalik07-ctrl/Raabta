import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/models/job_requirements.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

class JobRequirementsDisplay extends StatelessWidget {
  const JobRequirementsDisplay({
    super.key,
    required this.requirements,
    required this.locale,
  });

  final JobRequirementsSpec requirements;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (!requirements.isSpecified) {
      return Text(
        JobsStrings.t('jobs_req_not_specified', locale),
        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requirements.requiredSkills.isNotEmpty)
          _Block(
            title: JobsStrings.t('jobs_req_skills', locale),
            items: requirements.requiredSkills,
          ),
        if (requirements.minimumExperience.trim().isNotEmpty)
          _Block(
            title: JobsStrings.t('jobs_req_experience', locale),
            items: [requirements.minimumExperience.trim()],
          ),
        if (requirements.qualifications.isNotEmpty)
          _Block(
            title: JobsStrings.t('jobs_req_qualifications', locale),
            items: requirements.qualifications,
          ),
        if (requirements.languageRequirements.isNotEmpty)
          _Block(
            title: JobsStrings.t('jobs_req_languages', locale),
            items: requirements.languageRequirements,
          ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: AppTypography.body),
            ),
          ),
        ],
      ),
    );
  }
}
