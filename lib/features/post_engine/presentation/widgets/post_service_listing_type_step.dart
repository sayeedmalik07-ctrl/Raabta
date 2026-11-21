import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Step 1 fork for Services post flow — offering vs. need (Part 10).
class PostServiceListingTypeStep extends StatelessWidget {
  const PostServiceListingTypeStep({
    super.key,
    required this.locale,
    required this.onSelected,
    this.totalSteps = 3,
  });

  final String locale;
  final ValueChanged<ServiceListingType> onSelected;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        PostFlowStepIndicator(
          currentStep: 1,
          totalSteps: totalSteps,
          stepLabelKey: 'flow_step_listing_type',
          locale: locale,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          PostEngineStrings.t('listing_type_prompt', locale),
          style: AppTypography.headline2.copyWith(fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          PostEngineStrings.t('listing_type_subtitle', locale),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ListingTypeCard(
          icon: Icons.handyman_outlined,
          title: PostEngineStrings.t('listing_type_offering', locale),
          subtitle: PostEngineStrings.t('listing_type_offering_hint', locale),
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(ServiceListingType.provider);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _ListingTypeCard(
          icon: Icons.search_outlined,
          title: PostEngineStrings.t('listing_type_need', locale),
          subtitle: PostEngineStrings.t('listing_type_need_hint', locale),
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(ServiceListingType.request);
          },
        ),
      ],
    );
  }
}

class _ListingTypeCard extends StatelessWidget {
  const _ListingTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderRadius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.1,
      child: Row(
        children: [
          Icon(icon, size: 36, color: AppColors.cyanGlow),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
