import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/domain/post_category_trust.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Surfaces config-driven verification requirements during the post flow.
class PostCategoryVerificationBanner extends StatelessWidget {
  const PostCategoryVerificationBanner({
    super.key,
    required this.requirements,
    required this.locale,
  });

  final PostCategoryTrustRequirements requirements;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (!requirements.hasAnyRequirement) return const SizedBox.shrink();

    final messages = <String>[];
    if (requirements.identityVerificationRequired) {
      messages.add(PostEngineStrings.t('trust_banner_identity', locale));
    }
    if (requirements.businessVerificationRequired) {
      messages.add(PostEngineStrings.t('trust_banner_business', locale));
    }
    if (requirements.licenseVerificationRequired) {
      messages.add(PostEngineStrings.t('trust_banner_license', locale));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        borderRadius: AppSpacing.radiusLg,
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.amberGlow,
        glowIntensity: 0.08,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user_outlined, color: AppColors.amberGlow),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final message in messages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        message,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
