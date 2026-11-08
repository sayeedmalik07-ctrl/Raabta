import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_premium_surface.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Kit "Describe what you need" — routes to request post flow (AI optional inside PostFlow).
class ServicesHubDescribeCard extends StatelessWidget {
  const ServicesHubDescribeCard({
    super.key,
    required this.locale,
  });

  final String locale;

  static const cardKey = Key('services_hub_describe_card');

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: cardKey,
      child: GlassCard(
        onTap: () => context.push(
          '/services/post?listingType=${ServiceListingType.request.id}',
        ),
        borderRadius: HubPremiumSurface.summaryCardRadius,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: HubPremiumSurface.brandGlowIntensity,
        backgroundColor: HubPremiumSurface.brandFamilyTint(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.brandFamilyMain.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.brandFamilyMain,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ServicesStrings.t('hub_describe_title', locale),
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ServicesStrings.t('hub_describe_subtitle', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.brandFamilyMain,
            ),
          ],
        ),
      ),
    );
  }
}
