import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/icons/hub_screen_icons.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/navigation/shell_chrome_scope.dart';
import 'package:raabta/core/widgets/hub/hub_quick_action_tile.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/core/widgets/hub/hub_summary_strip_card.dart';
import 'package:raabta/core/widgets/hub/hub_zero_result_recovery_strip.dart';
import 'package:raabta/features/community/data/community_content_labels.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';
import 'package:raabta/features/saved_search/presentation/widgets/save_search_button.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/screens/marketplace/widgets/marketplace_listing_card.dart';
import 'package:raabta/screens/monetization/boost_listing_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _savedListingIds = {};
  bool _leavingQatarFilter = false;
  int _selectedBoostPackage = 0;

  static List<({String label, String price})> _boostPackages(String locale) => [
    (label: MarketplaceStrings.t('mp_boost_3_days', locale), price: '10'),
    (label: MarketplaceStrings.t('mp_boost_7_days', locale), price: '20'),
    (label: MarketplaceStrings.t('mp_boost_30_days', locale), price: '60'),
  ];

  List<MarketplaceListing> _filteredListings(List<MarketplaceListing> source) {
    var list = source;
    if (_leavingQatarFilter) {
      list = list
          .where(
            (l) => l.relevantGroupIds.contains(
              CommunityContentLabels.leavingQatarId,
            ),
          )
          .toList();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return list;
    return list
        .where(
          (l) =>
              l.title.toLowerCase().contains(query) ||
              l.area.toLowerCase().contains(query) ||
              l.price.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPostAd() {
    HapticFeedback.selectionClick();
    context.push('/marketplace/post');
  }

  void _toggleSave(String id) {
    setState(() {
      if (_savedListingIds.contains(id)) {
        _savedListingIds.remove(id);
      } else {
        _savedListingIds.add(id);
        PostEngine().analytics.trackSave(
          listingId: id,
          verticalId: 'marketplace',
        );
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _leavingQatarFilter = false;
    });
  }

  void _openBoostListing(MarketplaceListing listing) {
    if (!ComplianceFlagsGate.effectivePaidBoosts) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BoostListingScreen(
          listingTitle: listing.title,
          currentViews: listing.views,
          currentContacts: (listing.views / 8).ceil().clamp(1, 99),
          listingId: listing.id,
        ),
      ),
    );
  }

  List<Widget> _buildListingRows(
    List<MarketplaceListing> listings,
    String locale,
  ) {
    final rows = <Widget>[];
    for (var i = 0; i < listings.length; i += 2) {
      final left = listings[i];
      final right = i + 1 < listings.length ? listings[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MarketplaceListingCard(
                  listing: left,
                  locale: locale,
                  isSaved: _savedListingIds.contains(left.id),
                  onSave: () => _toggleSave(left.id),
                  onBoost: ComplianceFlagsGate.effectivePaidBoosts
                      ? () => _openBoostListing(left)
                      : null,
                  onTap: () => context.push(
                    '/marketplace/listing/${left.id}',
                    extra: left,
                  ),
                  compactGrid: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : MarketplaceListingCard(
                        listing: right,
                        locale: locale,
                        isSaved: _savedListingIds.contains(right.id),
                        onSave: () => _toggleSave(right.id),
                        onBoost: ComplianceFlagsGate.effectivePaidBoosts
                            ? () => _openBoostListing(right)
                            : null,
                        onTap: () => context.push(
                          '/marketplace/listing/${right.id}',
                          extra: right,
                        ),
                        compactGrid: true,
                      ),
              ),
            ],
          ),
        ),
      );

      final pairEndIndex = i + (right != null ? 2 : 1);
      if (pairEndIndex % 6 == 0 && pairEndIndex < listings.length) {
        final sponsored = listings[pairEndIndex - 1];
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SponsoredAdStripe(locale: locale),
                MarketplaceListingCard(
                  listing: sponsored,
                  locale: locale,
                  isSaved: _savedListingIds.contains(
                    'sponsored-${sponsored.id}',
                  ),
                  onSave: () => _toggleSave('sponsored-${sponsored.id}'),
                  onBoost: ComplianceFlagsGate.effectivePaidBoosts
                      ? () {}
                      : null,
                  isSponsored: true,
                  onTap: () => _showSnack(
                    MarketplaceStrings.t('mp_sponsored_listing', locale),
                  ),
                  compactGrid: true,
                ),
              ],
            ),
          ),
        );
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final listingsAsync = ref.watch(marketplaceListingsProvider);
    final categoryCounts = ref.watch(marketplaceCategoryCountsProvider);
    final countsLoading = listingsAsync.isLoading;

    return listingsAsync.when(
      loading: () => AnimatedAuroraBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: const SafeArea(child: Center(child: HubLoadingPlaceholder())),
        ),
      ),
      error: (e, _) => AnimatedAuroraBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: GlassErrorState(
                  message: MarketplaceStrings.t('mp_err_load_hub', locale),
                  onRetry: () => ref.invalidate(marketplaceListingsProvider),
                  retryLabel: CommonActionStrings.t('action_retry', locale),
                ),
              ),
            ),
          ),
        ),
      ),
      data: (allListings) => _buildScaffold(
        locale: locale,
        allListings: allListings,
        categoryCounts: categoryCounts,
        countsLoading: countsLoading,
      ),
    );
  }

  Widget _buildScaffold({
    required String locale,
    required List<MarketplaceListing> allListings,
    required Map<String, int> categoryCounts,
    required bool countsLoading,
  }) {
    final listings = _filteredListings(allListings);
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final savedAsync = ref.watch(
      userSavedSearchesForVerticalProvider(SavedSearchVertical.marketplace),
    );

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: hubPostFabWhenAllowed(
          context,
          onPressed: _openPostAd,
          tooltip: MarketplaceStrings.t('mp_post_ad', locale),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.brandFamilyMain,
            onRefresh: () async {
              ref.invalidate(marketplaceListingsProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(locale)),
                SliverToBoxAdapter(
                  child: _buildSummaryStrip(
                    locale: locale,
                    uid: uid,
                    allListings: allListings,
                    savedAsync: savedAsync,
                  ),
                ),
                SliverToBoxAdapter(child: _buildQuickActions(locale)),
                SliverToBoxAdapter(child: _buildSearchSection(locale)),
                SliverToBoxAdapter(child: _buildFilterRow(locale)),
                if (listings.isEmpty &&
                    allListings.isNotEmpty &&
                    (_searchController.text.trim().isNotEmpty ||
                        _leavingQatarFilter))
                  SliverToBoxAdapter(
                    child: HubZeroResultRecoveryStrip(
                      message: MarketplaceStrings.t('mp_zero_results', locale),
                      undoLabel: MarketplaceStrings.t(
                        'mp_clear_filters',
                        locale,
                      ),
                      onUndo: _clearFilters,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _buildCategorySection(
                    locale: locale,
                    categoryCounts: categoryCounts,
                    countsLoading: countsLoading,
                  ),
                ),
                if (ComplianceFlagsGate.effectivePaidBoosts)
                  SliverToBoxAdapter(
                    child: _buildBoostBanner(
                      locale: locale,
                      listings: listings,
                      allListings: allListings,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.sm,
                    ),
                    child: HomeSectionHeader(
                      overline: MarketplaceStrings.t(
                        'mp_latest_overline',
                        locale,
                      ),
                      title: MarketplaceStrings.t('mp_recent_listings', locale),
                      leadingIcon: Icons.schedule_outlined,
                    ),
                  ),
                ),
                if (listings.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.xxxl,
                      ),
                      child: GlassEmptyState(
                        title: allListings.isEmpty
                            ? MarketplaceStrings.t('mp_no_listings_yet', locale)
                            : MarketplaceStrings.t(
                                'mp_no_listings_found',
                                locale,
                              ),
                        description: allListings.isEmpty
                            ? MarketplaceStrings.t(
                                'mp_empty_first_post',
                                locale,
                              )
                            : MarketplaceStrings.t('mp_empty_no_match', locale),
                        icon: Icons.search_off_rounded,
                        accent: allListings.isEmpty
                            ? GlassEmptyStateAccent.brand
                            : GlassEmptyStateAccent.cyan,
                        actionLabel: allListings.isEmpty
                            ? MarketplaceStrings.t('mp_post_ad', locale)
                            : null,
                        onAction: allListings.isEmpty ? _openPostAd : null,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildListingRows(listings, locale),
                      ),
                    ),
                  ),
                if (listings.isNotEmpty)
                  SliverToBoxAdapter(
                    child: HubFeedFooterNotice(locale: locale),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxxl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String locale) {
    return HubLandingHeader(
      title: MarketplaceStrings.t('mp_hub_title', locale),
      subtitle: MarketplaceStrings.t('mp_hub_subtitle', locale),
      onBack: () => Navigator.of(context).maybePop(),
      trailing: IconButton(
        onPressed: _openPostAd,
        tooltip: MarketplaceStrings.t('mp_post_ad', locale),
        icon: Icon(Icons.post_add_outlined, color: AppColors.brandFamilyMain),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }

  Widget _buildSummaryStrip({
    required String locale,
    required String uid,
    required List<MarketplaceListing> allListings,
    required AsyncValue<List<SavedSearch>> savedAsync,
  }) {
    final cards = <Widget>[];

    final savedCount = savedAsync.maybeWhen(
      data: (searches) => searches.where((s) => s.active).length,
      orElse: () => 0,
    );
    if (uid.isNotEmpty && savedCount > 0) {
      cards.add(
        Expanded(
          child: HubSummaryStripCard(
            value: ProfileDisplayHelper.formatCount(savedCount),
            label: SavedSearchStrings.t('saved_searches_title', locale),
            icon: Icons.search,
            onTap: () => context.push('/profile/saved-searches'),
          ),
        ),
      );
    }

    if (uid.isNotEmpty) {
      final myCount = allListings
          .where((l) => l.ownerUserId != null && l.ownerUserId == uid)
          .length;
      if (myCount > 0) {
        if (cards.isNotEmpty) {
          cards.add(const SizedBox(width: AppSpacing.sm));
        }
        cards.add(
          Expanded(
            child: HubSummaryStripCard(
              value: ProfileDisplayHelper.formatCount(myCount),
              label: MarketplaceStrings.t('mp_my_listings', locale),
              icon: Icons.inventory_2_outlined,
              onTap: () {},
            ),
          ),
        );
      }
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return HubSummaryStripPadding(child: Row(children: cards));
  }

  Widget _buildQuickActions(String locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.add,
              label: MarketplaceStrings.t('mp_quick_sell', locale),
              onTap: _openPostAd,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.bookmark_border,
              label: MarketplaceStrings.t('mp_quick_saved', locale),
              onTap: () => context.push('/profile/saved-searches'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.favorite_border,
              label: MarketplaceStrings.t('mp_quick_favorites', locale),
              onTap: () => context.push('/jobs/saved'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.location_on_outlined,
              label: MarketplaceStrings.t('mp_quick_meetup', locale),
              onTap: () => context.push('/community/events'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            0,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: HubLayoutTokens.searchMinHeight,
            ),
            child: TextField(
              controller: _searchController,
              style: AppTypography.subtitle,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: hubSearchInputDecoration(
                hintText: MarketplaceStrings.t('mp_search_hint', locale),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SaveSearchButton(
              vertical: SavedSearchVertical.marketplace,
              criteria: SavedSearchCriteria.fromMarketplaceBrowse(
                query: _searchController.text,
                leavingQatarFilter: _leavingQatarFilter,
              ),
              accent: SaveSearchButtonAccent.hubBrand,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(String locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          buildHubFilterChip(
            label: Text(
              CommunityStrings.t(
                'community_marketplace_leaving_filter',
                locale,
              ),
              style: AppTypography.caption,
            ),
            selected: _leavingQatarFilter,
            onSelected: (v) => setState(() => _leavingQatarFilter = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String locale,
    required Map<String, int> categoryCounts,
    required bool countsLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: HomeSectionHeader(
            title: MarketplaceStrings.t('mp_categories_title', locale),
            leadingIcon: HubScreenIcons.marketplace,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 154,
            ),
            itemCount: marketplaceCategories.length,
            itemBuilder: (context, index) {
              final category = marketplaceCategories[index];
              final count = categoryCounts[category.id];
              return _CategoryCard(
                icon: HubScreenIcons.marketplaceCategory(category.id),
                name: category.name,
                countLabel: countsLoading
                    ? '…'
                    : MarketplaceStrings.format(
                        'mp_listings_count',
                        locale,
                        params: {'count': '${count ?? 0}'},
                      ),
                onTap: () =>
                    context.push('/marketplace/category/${category.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBoostBanner({
    required String locale,
    required List<MarketplaceListing> listings,
    required List<MarketplaceListing> allListings,
  }) {
    final boostPackages = _boostPackages(locale);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        0,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusXl,
        glowColor: AppColors.amberGlow,
        glowIntensity: 0.15,
        backgroundColor: AppColors.amberGlow.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MarketplaceStrings.t('mp_boost_your_listing', locale),
              style: AppTypography.headline2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              MarketplaceStrings.t('mp_boost_views', locale),
              style: AppTypography.body.copyWith(color: AppColors.amberGlow),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(boostPackages.length, (index) {
                final selected = _selectedBoostPackage == index;
                return ChoiceChip(
                  label: Text(boostPackages[index].label),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedBoostPackage = index),
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.amberGlow.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.amberGlow
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.amberGlow
                        : AppColors.glassBorder,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (listings.isEmpty && allListings.isEmpty) {
                    _openPostAd();
                    return;
                  }
                  final sample = listings.isNotEmpty
                      ? listings.first
                      : allListings.first;
                  _openBoostListing(sample);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amberGlow,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  MarketplaceStrings.t('mp_boost_now', locale),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.name,
    required this.countLabel,
    required this.onTap,
  });

  final IconData icon;
  final String name;
  final String countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderRadius: AppSpacing.radiusSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeIconBadge(
            icon: icon,
            accentColor: AppColors.brandFamilyMain,
            size: 40,
          ),
          const Spacer(),
          Text(
            name,
            style: AppTypography.subtitle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            countLabel,
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsoredAdStripe extends StatelessWidget {
  const _SponsoredAdStripe({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        MarketplaceStrings.t('mp_ad_badge', locale),
        style: AppTypography.caption.copyWith(
          color: AppColors.goldFamilyMain,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
