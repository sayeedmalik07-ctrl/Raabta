import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/housing/presentation/widgets/housing_owner_viewings_overview.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';

class MyHousingListingsScreen extends ConsumerWidget {
  const MyHousingListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final uid = user?.uid ?? '';

    if (uid.isEmpty) {
      return GlassScreenScaffold(
        title: HousingStrings.t('my_listings', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: GlassEmptyState(
            icon: Icons.login_rounded,
            title: HousingStrings.t('sign_in_required', locale),
            description: HousingStrings.t('my_listings_empty_body', locale),
          ),
        ),
      );
    }

    final listingsAsync = ref.watch(userHousingListingsProvider(uid));

    return GlassScreenScaffold(
      title: HousingStrings.t('my_listings', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back,
        onPressed: () => Navigator.of(context).pop(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: GlassPrimaryButton(
          label: HousingStrings.t('post_listing', locale),
          icon: Icons.add,
          onPressed: () => context.push('/housing/post'),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      body: listingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.cyanGlow),
        ),
        error: (_, _) => Center(
          child: GlassEmptyState(
            icon: Icons.error_outline,
            title: HousingStrings.t('error_load_listings', locale),
            description: HousingStrings.t('my_listings_empty_body', locale),
          ),
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return Center(
              child: GlassEmptyState(
                icon: Icons.home_work_outlined,
                title: HousingStrings.t('my_listings_empty_title', locale),
                description: HousingStrings.t('my_listings_empty_body', locale),
                actionLabel: HousingStrings.t('post_listing', locale),
                onAction: () => context.push('/housing/post'),
              ),
            );
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              HousingOwnerViewingsOverview(ownerId: uid, locale: locale),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < listings.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                _MyListingTile(
                  listing: listings[i],
                  locale: locale,
                  onTap: () => context.push('/housing/listing/${listings[i].id}'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MyListingTile extends StatelessWidget {
  const _MyListingTile({
    required this.listing,
    required this.locale,
    required this.onTap,
  });

  final HousingListing listing;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(listing.title, style: AppTypography.subtitle),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cyanGlow.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  HousingStrings.listingStatusLabel(listing.status, locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.cyanGlow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('📍 ${listing.area}', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            listing.priceLabel,
            style: AppTypography.body.copyWith(
              color: AppColors.cyanGlow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            HousingStrings.postedLabel(listing.daysAgo, locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
