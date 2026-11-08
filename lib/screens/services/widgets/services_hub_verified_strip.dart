import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/utils/service_listing_display_helpers.dart';

/// Short horizontal list of identity-verified provider listings (kit: verified strip).
class ServicesHubVerifiedStrip extends StatelessWidget {
  const ServicesHubVerifiedStrip({
    super.key,
    required this.locale,
    required this.listings,
  });

  final String locale;
  final List<ServiceListing> listings;

  static const sectionKey = Key('services_hub_verified_strip');

  @override
  Widget build(BuildContext context) {
    final verified = listings
        .where(
          (l) =>
              !l.isRequest &&
              l.posterIdentityVerified &&
              l.status == 'active',
        )
        .take(8)
        .toList();
    if (verified.isEmpty) return const SizedBox.shrink();

    return KeyedSubtree(
      key: sectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              ServicesStrings.t('hub_verified_providers', locale),
              style: AppTypography.subtitle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: HubLayoutTokens.filterChipHeight + 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: verified.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final listing = verified[index];
                return _VerifiedProviderChip(
                  locale: locale,
                  listing: listing,
                  onTap: () => context.push('/services/listing/${listing.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedProviderChip extends StatelessWidget {
  const _VerifiedProviderChip({
    required this.locale,
    required this.listing,
    required this.onTap,
  });

  final String locale;
  final ServiceListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = serviceHubProviderHeadline(listing);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.glassBorder),
            color: AppColors.surfaceElevated.withValues(alpha: 0.35),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 14,
                    color: AppColors.greenFamilyMain,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                listing.serviceName.trim().isNotEmpty
                    ? listing.serviceName
                    : serviceListingCategoryLabel(listing),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: HubLayoutTokens.trustBadgeFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
