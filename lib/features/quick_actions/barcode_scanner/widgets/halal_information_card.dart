import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/food_inspector_strings.dart';
import '../models/halal_product_info.dart';
import 'food_inspector_theme.dart';

/// Community-sourced halal label data — never a certification verdict.
class HalalInformationCard extends StatelessWidget {
  const HalalInformationCard({
    super.key,
    required this.halalInfo,
    required this.locale,
  });

  final HalalProductInfo halalInfo;
  final String locale;

  static const _offProductUrl =
      'https://world.openfoodfacts.org/contribute';

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusSm,
      glowColor: foodInspectorPurple,
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            FoodInspectorStrings.t('halal_section_title', locale),
            style: AppTypography.subtitle.copyWith(color: foodInspectorGold),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (halalInfo.hasCommunityHalalData) ...[
            ...halalInfo.communityLabels.map(
              (label) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.label_outline,
                      size: 16,
                      color: AppColors.accentGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Text(
              FoodInspectorStrings.t('halal_no_data', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnGlassMuted,
                height: 1.45,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            FoodInspectorStrings.t('halal_community_attribution', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.accentGold,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (halalInfo.ingredientsToBeAwareOf.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              FoodInspectorStrings.t('halal_awareness_title', locale),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              FoodInspectorStrings.t('halal_awareness_framing', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnGlassMuted,
                height: 1.35,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            ...halalInfo.ingredientsToBeAwareOf.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        FoodInspectorStrings.t(item.ingredientKey, locale),
                        style: AppTypography.caption.copyWith(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            FoodInspectorStrings.t('halal_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassMuted,
              height: 1.4,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () async {
              final uri = Uri.parse(_offProductUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.groups_outlined, size: 16),
            label: Text(FoodInspectorStrings.t('halal_off_contribute', locale)),
            style: TextButton.styleFrom(
              foregroundColor: foodInspectorGold,
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }
}
