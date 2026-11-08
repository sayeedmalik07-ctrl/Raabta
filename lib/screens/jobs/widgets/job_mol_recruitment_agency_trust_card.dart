import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// Short MOL recruitment-agency check — deep-links to Agency Verification Qatar section.
class JobMolRecruitmentAgencyTrustCard extends StatelessWidget {
  const JobMolRecruitmentAgencyTrustCard({super.key, required this.locale});

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
            JobsStrings.t('trust_mol_agency_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.info),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            JobsStrings.t('trust_mol_agency_summary', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                AgencyVerificationScreen.route(
                  section: AgencyVerificationScreen.qatarRecruitmentSection,
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(JobsStrings.t('trust_mol_agency_button', locale)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
