import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// Static recruitment-fee safety fact — link-out to existing Agency Verification checklist.
class JobRecruitmentFeeSafetyCard extends StatelessWidget {
  const JobRecruitmentFeeSafetyCard({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.info,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            JobsStrings.t('trust_no_hiring_fees_body', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => context.push(AgencyVerificationScreen.route()),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.info,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(JobsStrings.t('trust_no_hiring_fees_link', locale)),
          ),
        ],
      ),
    );
  }
}
