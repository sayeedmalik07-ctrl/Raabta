import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';

/// Aggregates real provider data from existing listings — no fabricated metrics.
class ServiceProviderProfileSection extends ConsumerWidget {
  const ServiceProviderProfileSection({
    super.key,
    required this.listing,
    required this.locale,
  });

  final ServiceListing listing;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (listing.isRequest || listing.userId.isEmpty) {
      return const SizedBox.shrink();
    }

    final listingsAsync =
        ref.watch(userServiceListingsProvider(listing.userId));

    return listingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (listings) {
        final providerListings = listings
            .where((item) => item.listingType == ServiceListingType.provider)
            .toList();
        if (providerListings.isEmpty) return const SizedBox.shrink();

        final services = <String>{
          for (final item in providerListings)
            if (item.serviceName.trim().isNotEmpty) item.serviceName.trim(),
        }.toList()
          ..sort();

        final areas = <String>{
          for (final item in providerListings)
            if (item.area.trim().isNotEmpty) item.area.trim(),
        }.toList()
          ..sort();

        final identityVerified = providerListings.any(
          (item) => item.posterIdentityVerified,
        );

        if (services.isEmpty && areas.isEmpty && !identityVerified) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.lg),
          child: GlassCard(
            borderRadius: AppRadius.lg,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServicesStrings.t('provider_profile_title', locale),
                  style: AppTypography.subtitle,
                ),
                if (identityVerified) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _VerifiedBadge(locale: locale),
                ],
                if (services.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ServicesStrings.t('provider_services_offered', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final service in services)
                        _ChipLabel(label: service),
                    ],
                  ),
                ],
                if (areas.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ServicesStrings.t('provider_areas_served', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final area in areas) _ChipLabel(label: area),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandFamilyMain.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 16, color: AppColors.greenFamilyMain),
          const SizedBox(width: AppSpacing.xs),
          Text(
            ServicesStrings.t('provider_identity_verified', locale),
            style: AppTypography.caption.copyWith(color: AppColors.greenFamilyMain),
          ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HubLayoutTokens.trustBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(HubLayoutTokens.trustBadgeRadius),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: HubLayoutTokens.trustBadgeFontSize,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
