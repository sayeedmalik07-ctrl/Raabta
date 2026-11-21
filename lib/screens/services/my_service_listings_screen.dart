import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/core/widgets/hub/hub_post_fab.dart';
import 'package:raabta/core/widgets/hub/hub_quick_action_tile.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/screens/services/widgets/service_hub_listing_card.dart';
import 'package:raabta/screens/services/widgets/service_hub_subscreen_scaffold.dart';

enum _MyListingsFilter { all, provider, request }

/// Owner hub for service listings (providers + requests) — kit T2.
class MyServiceListingsScreen extends ConsumerStatefulWidget {
  const MyServiceListingsScreen({super.key});

  static const screenKey = Key('services_my_listings_screen');

  @override
  ConsumerState<MyServiceListingsScreen> createState() =>
      _MyServiceListingsScreenState();
}

class _MyServiceListingsScreenState extends ConsumerState<MyServiceListingsScreen> {
  _MyListingsFilter _filter = _MyListingsFilter.all;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final uid = user?.uid ?? '';

    if (uid.isEmpty) {
      return ServiceHubSubscreenScaffold(
        title: ServicesStrings.t('my_listings', locale),
        subtitle: ServicesStrings.t('subtitle', locale),
        onBack: () => Navigator.of(context).pop(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.login_rounded,
              title: ServicesStrings.t('sign_in_required', locale),
              description: ServicesStrings.t('my_listings_empty_body', locale),
            ),
          ),
        ),
      );
    }

    final listingsAsync = ref.watch(userServiceListingsProvider(uid));

    return KeyedSubtree(
      key: MyServiceListingsScreen.screenKey,
      child: ServiceHubSubscreenScaffold(
        title: ServicesStrings.t('my_listings', locale),
        subtitle: _subtitle(locale, listingsAsync.valueOrNull),
        onBack: () => Navigator.of(context).pop(),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom > 0 ? 0 : AppSpacing.sm,
          ),
          child: HubPostFab(
            key: const Key('services_my_listings_post_fab'),
            tooltip: ServicesStrings.t('post_listing', locale),
            onPressed: () => context.push('/services/post'),
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.brandFamilyMain,
          onRefresh: () async {
            ref.invalidate(userServiceListingsProvider(uid));
            await ref.read(userServiceListingsProvider(uid).future);
          },
          child: listingsAsync.when(
            loading: () => _loadingList(),
            error: (_, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                _hubChrome(locale, const []),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: GlassEmptyState(
                      accent: GlassEmptyStateAccent.brand,
                      icon: Icons.error_outline,
                      title: ServicesStrings.t('submit_error', locale),
                      description:
                          ServicesStrings.t('my_listings_empty_body', locale),
                    ),
                  ),
                ),
              ],
            ),
            data: (listings) {
              final filtered = _applyFilter(listings);
              if (listings.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: [
                    _hubChrome(locale, listings),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: GlassEmptyState(
                          accent: GlassEmptyStateAccent.brand,
                          icon: Icons.home_repair_service_outlined,
                          title:
                              ServicesStrings.t('my_listings_empty_title', locale),
                          description:
                              ServicesStrings.t('my_listings_empty_body', locale),
                          actionLabel: ServicesStrings.t('post_listing', locale),
                          onAction: () => context.push('/services/post'),
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (filtered.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: [
                    _hubChrome(locale, listings),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: GlassEmptyState(
                          accent: GlassEmptyStateAccent.brand,
                          icon: Icons.filter_alt_off_outlined,
                          title: ServicesStrings.t(
                            'hub_empty_filtered_title',
                            locale,
                          ),
                          description: ServicesStrings.t(
                            'hub_empty_filtered_description',
                            locale,
                          ),
                          actionLabel: CommonStrings.clearFilters,
                          onAction: () =>
                              setState(() => _filter = _MyListingsFilter.all),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
                children: [
                  _hubChrome(locale, listings),
                  for (var i = 0; i < filtered.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.md),
                    _MyListingHubRow(
                      listing: filtered[i],
                      locale: locale,
                      onTap: () => context.push(
                        '/services/listing/${filtered[i].id}',
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  HubFeedFooterNotice(locale: locale),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _hubChrome(String locale, List<ServiceListing> all) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HubNoticeBanner.hostNotice(locale: locale),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: HubQuickActionTile(
                  icon: Icons.edit_note_outlined,
                  label: ServicesStrings.t('quick_post_request', locale),
                  onTap: () => context.push(
                    '/services/post?listingType=request',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: HubQuickActionTile(
                  icon: Icons.handyman_outlined,
                  label: ServicesStrings.t('quick_offer_service', locale),
                  onTap: () => context.push(
                    '/services/post?listingType=provider',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: HubLayoutTokens.filterChipHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                buildHubFilterChip(
                  label: Text(ServicesStrings.t('hub_my_listings_all', locale)),
                  selected: _filter == _MyListingsFilter.all,
                  onSelected: (_) =>
                      setState(() => _filter = _MyListingsFilter.all),
                ),
                const SizedBox(width: AppSpacing.sm),
                buildHubFilterChip(
                  label: Text(
                    ServicesStrings.t('hub_segment_providers', locale),
                  ),
                  selected: _filter == _MyListingsFilter.provider,
                  onSelected: (_) =>
                      setState(() => _filter = _MyListingsFilter.provider),
                ),
                const SizedBox(width: AppSpacing.sm),
                buildHubFilterChip(
                  label: Text(
                    ServicesStrings.t('hub_segment_requests', locale),
                  ),
                  selected: _filter == _MyListingsFilter.request,
                  onSelected: (_) =>
                      setState(() => _filter = _MyListingsFilter.request),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ServiceListing> _applyFilter(List<ServiceListing> listings) {
    return switch (_filter) {
      _MyListingsFilter.all => listings,
      _MyListingsFilter.provider => listings
          .where((l) => l.listingType == ServiceListingType.provider)
          .toList(),
      _MyListingsFilter.request => listings
          .where((l) => l.listingType == ServiceListingType.request)
          .toList(),
    };
  }

  String _subtitle(String locale, List<ServiceListing>? listings) {
    if (listings == null) {
      return ServicesStrings.t('hub_my_listings_subtitle', locale);
    }
    if (listings.isEmpty) {
      return ServicesStrings.t('my_listings_empty_title', locale);
    }
    final filtered = _applyFilter(listings);
    return ServicesStrings.format(
      'hub_my_listings_count',
      locale,
      params: {'count': '${filtered.length}'},
    );
  }

  Widget _loadingList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return HubLoadingPlaceholder(
              width: constraints.maxWidth,
              height: 128,
              silhouette: index.isEven
                  ? HubLoadingSilhouette.serviceCard
                  : HubLoadingSilhouette.serviceCardRequest,
            );
          },
        );
      },
    );
  }
}

class _MyListingHubRow extends StatelessWidget {
  const _MyListingHubRow({
    required this.listing,
    required this.locale,
    required this.onTap,
  });

  final ServiceListing listing;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceHubListingCard(
          listing: listing,
          locale: locale,
          onTap: onTap,
        ),
        if (!listing.isRequest) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(
              serviceHubPostedLine(listing.createdAt, locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (listing.status != 'active') ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(
              listing.status,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
