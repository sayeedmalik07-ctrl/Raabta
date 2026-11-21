import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/jobs/data/adlsa_contract_verification_catalog.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Post-offer ADLSA contract registration check — official link-out only.
class JobAdlsaContractVerificationCard extends StatelessWidget {
  const JobAdlsaContractVerificationCard({
    super.key,
    required this.locale,
  });

  final String locale;

  Future<void> _openPortal() async {
    final uri = Uri.parse(AdlsaContractVerificationCatalog.portalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.info,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            JobsStrings.t('trust_adlsa_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.info),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            JobsStrings.t('trust_adlsa_body', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            JobsStrings.t('trust_adlsa_companion_note', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openPortal,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(JobsStrings.t('trust_adlsa_open_portal', locale)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: BorderSide(color: AppColors.info.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            JobsStrings.t('trust_adlsa_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
