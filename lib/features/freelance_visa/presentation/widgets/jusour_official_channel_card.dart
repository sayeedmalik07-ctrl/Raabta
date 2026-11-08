import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/freelance_visa/presentation/l10n/freelance_visa_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Official Jusour contact card — signpost only, same shape as Agency Verification portal section.
class JusourOfficialChannelCard extends StatelessWidget {
  const JusourOfficialChannelCard({super.key, required this.locale});

  static const officialWebsiteUrl = 'https://jusour.qa/en';

  final String locale;

  Future<void> _openOfficialSite() async {
    final uri = Uri.tryParse(officialWebsiteUrl);
    if (uri == null) return;
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
            FreelanceVisaStrings.t('fv_jusour_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.info),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            FreelanceVisaStrings.t('fv_jusour_body', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            FreelanceVisaStrings.t('fv_jusour_contact', locale),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openOfficialSite,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(
                FreelanceVisaStrings.t('fv_open_official_site', locale),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            FreelanceVisaStrings.t('fv_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
