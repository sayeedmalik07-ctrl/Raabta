import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/eosb/data/qatar_real_estate_verification_catalog.dart';
import 'package:raabta/features/eosb/presentation/l10n/qatar_realestate_verification_strings.dart';

/// Qatar-side broker verification — link-out only, separate from origin-country flow.
class QatarRealEstateVerificationSection extends StatelessWidget {
  const QatarRealEstateVerificationSection({
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
            QatarRealestateVerificationStrings.t('section_title', locale),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.brandFamilyMain,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            QatarRealestateVerificationStrings.t('section_body', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _LinkBlock(
            title: QatarRealestateVerificationStrings.t('aqarat_heading', locale),
            body: QatarRealestateVerificationStrings.t('aqarat_hint', locale),
            buttonLabel:
                QatarRealestateVerificationStrings.t('open_aqarat', locale),
            url: QatarRealEstateVerificationCatalog.aqaratLicensedBrokersUrl,
            onOpenUrl: onOpenUrl,
          ),
          const SizedBox(height: AppSpacing.md),
          _LinkBlock(
            title: QatarRealestateVerificationStrings.t('moj_heading', locale),
            body: QatarRealestateVerificationStrings.t('moj_hint', locale),
            buttonLabel: QatarRealestateVerificationStrings.t('open_moj', locale),
            url: QatarRealEstateVerificationCatalog.mojHomeUrl,
            onOpenUrl: onOpenUrl,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            QatarRealestateVerificationStrings.t('ad_license_note', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            QatarRealestateVerificationStrings.t('disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkBlock extends StatelessWidget {
  const _LinkBlock({
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.url,
    required this.onOpenUrl,
  });

  final String title;
  final String body;
  final String buttonLabel;
  final String url;
  final Future<void> Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.subtitle),
        const SizedBox(height: AppSpacing.xs),
        Text(body, style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        GlassPrimaryButton(
          label: buttonLabel,
          icon: Icons.open_in_new_rounded,
          accentColor: AppColors.brandFamilyMain,
          expand: true,
          onPressed: () => onOpenUrl(url),
        ),
      ],
    );
  }
}
