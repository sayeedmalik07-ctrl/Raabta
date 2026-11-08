import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/eosb/data/qatar_recruitment_agency_verification_catalog.dart';
import 'package:raabta/features/eosb/presentation/l10n/qatar_recruitment_agency_verification_strings.dart';

/// Qatar-side MOL recruitment-agency verification — link-out only.
class QatarRecruitmentAgencyVerificationSection extends StatelessWidget {
  const QatarRecruitmentAgencyVerificationSection({
    super.key,
    required this.locale,
    required this.onOpenUrl,
  });

  final String locale;
  final Future<void> Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            QatarRecruitmentAgencyVerificationStrings.t('section_title', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.brandFamilyMain,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            QatarRecruitmentAgencyVerificationStrings.t('section_body', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: QatarRecruitmentAgencyVerificationStrings.t(
              'open_mol_list',
              locale,
            ),
            icon: Icons.open_in_new_rounded,
            accentColor: AppColors.brandFamilyMain,
            expand: true,
            onPressed: () => onOpenUrl(
              QatarRecruitmentAgencyVerificationCatalog.molLicensedAgenciesPdfUrl,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            QatarRecruitmentAgencyVerificationStrings.t('disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
