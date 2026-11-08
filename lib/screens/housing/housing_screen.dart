import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_advanced_filter_toggle.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_post_fab.dart';
import 'package:raabta/core/widgets/hub/hub_quick_action_tile.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/core/widgets/hub/hub_summary_strip_card.dart';
import 'package:raabta/features/home/widgets/metric_chip.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/listing_card.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';
import 'package:raabta/services/ai/housing_match_service.dart';
import 'package:raabta/widgets/ai/housing_match_widget.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/features/global_search/presentation/search_route_parameter_consumer.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/presentation/widgets/save_search_button.dart';
import 'package:share_plus/share_plus.dart';

Map<String, dynamic> housingListingToMatchData(HousingListing listing) {
  return {
    ...listing.toJson(),
    'price': listing.pricePerMonth,
    'propertyType': listing.typeLabel,
  };
}

class HousingListScreen extends ConsumerStatefulWidget {
  const HousingListScreen({super.key, this.routeParameters});

  final SearchRouteParameters? routeParameters;

  @override
  ConsumerState<HousingListScreen> createState() => _HousingListScreenState();
}

class _HousingListScreenState extends ConsumerState<HousingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = widget.routeParameters;
      if (params != null && !params.isEmpty) {
        SearchRouteParameterConsumer.applyHousingFilters(ref, params);
      }
    });
  }

  static const List<ListingType> _typeFilterTypes = [
    ListingType.all,
    ListingType.room,
    ListingType.flat,
    ListingType.sharing,
    ListingType.studio,
  ];

  String _areaLabel(HousingFilters filters, UserAIProfile? profile) {
    final selected = filters.area?.trim();
    if (selected != null && selected.isNotEmpty) return selected;
    return ProfileDisplayHelper.preferredAreaLabel(profile);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String value) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(searchQuery: value);
  }

  void _selectType(ListingType type) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(type: type);
  }

  void _selectArea(String? area) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(
              area: area,
              clearArea: area == null,
            );
  }

  void _updatePriceRange(RangeValues range) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(
              minPrice: range.start,
              maxPrice: range.end,
            );
  }

  void _selectGender(GenderPreference gender) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(gender: gender);
  }

  void _selectNationality(NationalityPreference nationality) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(nationality: nationality);
  }

  void _openPostListing() {
    final locale = ref.read(userLanguageProvider);
    if (ref.read(currentUserProvider) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(HousingStrings.t('sign_in_to_post_listing', locale)),
        ),
      );
      context.push('/login');
      return;
    }

    context.push('/housing/post');
  }

  int _newTodayCount(List<HousingListing> listings) =>
      listings.where((listing) => listing.daysAgo == 0).length;

  List<HousingListing> _filteredListings(List<HousingListing> allListings) {
    var listings = List<HousingListing>.from(allListings);
    final profile = ref.read(userAIProfileProvider);
    if (profile != null) {
      listings.sort((a, b) => _matchScore(b).compareTo(_matchScore(a)));
    }
    return listings;
  }

  List<HousingListing> _recommendedListings(List<HousingListing> allListings) {
    if (allListings.isEmpty) return const [];

    final profile = ref.read(userAIProfileProvider);
    if (profile == null) return allListings.take(2).toList();

    final matcher = ref.read(housingMatchServiceProvider);
    final ranked = matcher.rankListings(
      allListings.map(housingListingToMatchData).toList(),
      profile,
    );

    return ranked.take(2).map((match) {
      final id = match.listing['id'] as String? ?? '';
      return allListings.firstWhere(
        (listing) => listing.id == id,
        orElse: () => allListings.first,
      );
    }).toList();
  }

  int _matchedListingCount(List<HousingListing> allListings) {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null) return 0;

    final matcher = ref.read(housingMatchServiceProvider);
    return allListings
        .where(
          (listing) =>
              matcher
                  .calculateMatch(
                    housingListingToMatchData(listing),
                    profile,
                  )
                  .matchScore >=
              72,
        )
        .length;
  }

  int? _averageMatchRate(List<HousingListing> allListings) {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null || allListings.isEmpty) return null;

    final matcher = ref.read(housingMatchServiceProvider);
    final scores = allListings
        .map(
          (listing) => matcher
              .calculateMatch(housingListingToMatchData(listing), profile)
              .matchScore,
        )
        .toList();
    if (scores.isEmpty) return null;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  int _matchScore(HousingListing listing) {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null) return 0;
    return ref
        .read(housingMatchServiceProvider)
        .calculateMatch(housingListingToMatchData(listing), profile)
        .matchScore;
  }

  Widget _buildAiMatchBanner(String locale, List<HousingListing> allListings) {
    final matched = _matchedListingCount(allListings);
    final avgRate = _averageMatchRate(allListings);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: 0.12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HousingStrings.t('ai_match_title', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              HousingStrings.format(
                'ai_match_count',
                locale,
                params: {'count': '$matched'},
              ),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              avgRate != null
                  ? HousingStrings.format(
                      'ai_match_avg',
                      locale,
                      params: {'rate': '$avgRate'},
                    )
                  : HousingStrings.t('ai_match_complete_profile', locale),
              style: AppTypography.headline2.copyWith(
                color: AppColors.brandFamilyMain,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push('/profile'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                HousingStrings.t('update_profile_link', locale),
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _hubChromeSlivers({
    required HousingFilters filters,
    required String locale,
  }) {
    return [
      SliverToBoxAdapter(child: _buildHeader(filters)),
      SliverToBoxAdapter(child: _buildSearchSection(filters)),
      SliverToBoxAdapter(child: _buildSummaryStrip(locale)),
      SliverToBoxAdapter(child: _buildQuickActionRow(locale)),
      SliverToBoxAdapter(child: _buildFilterChipRows(filters)),
      if (_showAdvancedFilters)
        SliverToBoxAdapter(child: _buildAdvancedFilters(filters)),
    ];
  }

  void _toggleAdvancedFilters() {
    setState(() => _showAdvancedFilters = !_showAdvancedFilters);
  }

  Widget _buildSummaryStrip(String locale) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    if (uid.isEmpty) return const SizedBox.shrink();

    final housingSavedAsync =
        ref.watch(userSavedSearchesForVerticalProvider(SavedSearchVertical.housing));
    final myListingsAsync = ref.watch(userHousingListingsProvider(uid));

    final savedCount = housingSavedAsync.maybeWhen(
      data: (searches) =>
          searches.where((search) => search.active).length,
      orElse: () => null,
    );
    final approvedCount = myListingsAsync.maybeWhen(
      data: (listings) => listings
          .where((listing) => listing.status == ListingStatus.approved)
          .length,
      orElse: () => null,
    );

    if (savedCount == null && approvedCount == null) {
      return const SizedBox.shrink();
    }

    final cards = <Widget>[];
    if (savedCount != null && savedCount > 0) {
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
    if (approvedCount != null && approvedCount > 0) {
      if (cards.isNotEmpty) {
        cards.add(const SizedBox(width: AppSpacing.sm));
      }
      cards.add(
        Expanded(
          child: HubSummaryStripCard(
            value: ProfileDisplayHelper.formatCount(approvedCount),
            label: HousingStrings.t('my_listings', locale),
            icon: Icons.home_work_outlined,
            onTap: () => context.push('/housing/my-listings'),
          ),
        ),
      );
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return HubSummaryStripPadding(child: Row(children: cards));
  }

  Widget _buildQuickActionRow(String locale) {
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
              label: HousingStrings.t('post_listing', locale),
              onTap: _openPostListing,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.bookmark_border,
              label: SavedSearchStrings.t('saved_searches_title', locale),
              onTap: () => context.push('/profile/saved-searches'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HubQuickActionTile(
              icon: Icons.balance_outlined,
              label: TenancyStrings.t('tenancy_title', locale),
              onTap: () => context.push('/tenancy'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListingItems(List<HousingListing> listings) {
    final items = <Widget>[];
    for (var i = 0; i < listings.length; i++) {
      items.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListingCard(listing: listings[i], listIndex: i),
            HousingMatchWidget(
              listingData: housingListingToMatchData(listings[i]),
              compact: true,
            ),
          ],
        ),
      );
      if ((i + 1) % 5 == 0) {
        items.add(SponsoredListingCard(listing: listings[i]));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final filters = ref.watch(housingFiltersProvider);
    final listingsAsync = ref.watch(housingListingsProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      floatingActionButton: HubPostFab(
        onPressed: _openPostListing,
        tooltip: HousingStrings.t('post_listing', locale),
      ),
      body: SafeArea(
        child: listingsAsync.when(
          loading: () => const HubLoadingPlaceholder(),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: GlassEmptyState(
                accent: GlassEmptyStateAccent.brand,
                icon: Icons.error_outline,
                title: HousingStrings.t('error_load_listings', locale),
                description: error.toString(),
                actionLabel: CommonActionStrings.t('action_retry', locale),
                onAction: () => ref.invalidate(housingListingsProvider),
              ),
            ),
          ),
          data: (listings) {
            final filtered = _filteredListings(listings);
            final listingWidgets = _buildListingItems(filtered);

            return RefreshIndicator(
              color: AppColors.brandFamilyMain,
              onRefresh: () async {
                ref.invalidate(housingListingsProvider);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  ..._hubChromeSlivers(filters: filters, locale: locale),
                  if (filtered.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.lg,
                          AppSpacing.xl,
                          100,
                        ),
                        child: GlassEmptyState(
                          key: const Key('housing_hub_empty_state'),
                          accent: GlassEmptyStateAccent.brand,
                          icon: Icons.home_outlined,
                          title: HousingStrings.t('empty_no_listings', locale),
                          description: HousingStrings.t(
                            'empty_no_listings_hint',
                            locale,
                          ),
                          actionLabel: HousingStrings.t('post_listing', locale),
                          onAction: _openPostListing,
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < listingWidgets.length - 1
                                    ? AppSpacing.md
                                    : 0,
                              ),
                              child: listingWidgets[index],
                            );
                          },
                          childCount: listingWidgets.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HubFeedFooterNotice(locale: locale),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(HousingFilters filters) {
    final locale = ref.watch(userLanguageProvider);
    return HubLandingHeader(
      title: HousingStrings.t('hub_title', locale),
      subtitle: HousingStrings.t('hub_subtitle', locale),
      onBack: () => Navigator.of(context).pop(),
      trailing: IconButton(
        onPressed: () => context.push('/housing/my-listings'),
        icon: Icon(Icons.list_alt_outlined, color: AppColors.brandFamilyMain),
        tooltip: HousingStrings.t('my_listings', locale),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }

  Widget _buildSearchSection(HousingFilters filters) {
    final locale = ref.watch(userLanguageProvider);
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: HubLayoutTokens.searchMinHeight,
                  ),
                  child: TextField(
                    key: const Key('housing_hub_search'),
                    controller: _searchController,
                    style: AppTypography.subtitle,
                    onChanged: _applySearch,
                    textInputAction: TextInputAction.search,
                    decoration: hubSearchInputDecoration(
                      hintText: HousingStrings.t('search_hint', locale),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              HubAdvancedFilterToggle(
                expanded: _showAdvancedFilters,
                onToggle: _toggleAdvancedFilters,
                semanticsLabel: HousingStrings.t(
                  'hub_advanced_filters_semantics',
                  locale,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SaveSearchButton(
              vertical: SavedSearchVertical.housing,
              criteria: SavedSearchCriteria.fromHousingFilters(filters),
              accent: SaveSearchButtonAccent.hubBrand,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChipRows(HousingFilters filters) {
    final locale = ref.watch(userLanguageProvider);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: qatarAreas.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final area = qatarAreas[index];
                final selected = filters.area == area;
                return buildHubFilterChip(
                  label: Text(area),
                  selected: selected,
                  onSelected: (_) => _selectArea(selected ? null : area),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: _typeFilterTypes.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final type = _typeFilterTypes[index];
                final selected = filters.type == type;
                return buildHubFilterChip(
                  label: Text(HousingStrings.filterTypeLabel(type, locale)),
                  selected: selected,
                  onSelected: (_) => _selectType(type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters(HousingFilters filters) {
    final locale = ref.watch(userLanguageProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HousingStrings.format(
                'price_range_label',
                locale,
                params: {
                  'min': '${filters.minPrice.round()}',
                  'max': '${filters.maxPrice.round()}',
                },
              ),
              style: AppTypography.subtitle,
            ),
            RangeSlider(
              values: RangeValues(filters.minPrice, filters.maxPrice),
              min: 500,
              max: 5000,
              divisions: 45,
              activeColor: AppColors.brandFamilyMain,
              inactiveColor: AppColors.surfaceElevated,
              labels: RangeLabels(
                '${filters.minPrice.round()}',
                '${filters.maxPrice.round()}',
              ),
              onChanged: _updatePriceRange,
            ),
            Text(
              HousingStrings.t('gender_preference', locale),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: GenderPreference.values.map((g) {
                final selected = filters.gender == g;
                return buildHubChoiceChip(
                  label: Text(HousingStrings.genderLabel(g, locale)),
                  selected: selected,
                  onSelected: (_) => _selectGender(g),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              HousingStrings.t('nationality_preference', locale),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: NationalityPreference.values.map((n) {
                final selected = filters.nationality == n;
                return buildHubChoiceChip(
                  label: Text(HousingStrings.nationalityLabel(n, locale)),
                  selected: selected,
                  onSelected: (_) => _selectNationality(n),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class HousingScreen extends HousingListScreen {
  const HousingScreen({super.key, super.routeParameters});
}

enum PremiumCardBadge { featured, urgent }

class PremiumPropertyCard extends ConsumerWidget {
  const PremiumPropertyCard({
    super.key,
    required this.listing,
    required this.badgeType,
    this.matchScore,
  });

  final HousingListing listing;
  final PremiumCardBadge badgeType;
  final int? matchScore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final savedIds = ref.watch(savedListingIdsProvider);
    final isSaved = savedIds.contains(listing.id);
    final photoUrl = listing.photoUrls.isNotEmpty
        ? listing.photoUrls.first
        : 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800';

    return GestureDetector(
      onTap: () => ListingCard.openDetail(context, listing.id),
      child: GlassCard(
        width: 260,
        padding: EdgeInsets.zero,
        borderRadius: AppSpacing.radiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceElevated,
                            AppColors.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.surfaceElevated,
                      child: Icon(
                        Icons.home,
                        color: AppColors.isLight
                            ? AppColors.textTertiary
                            : Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: MonetizationBadge(
                      type: badgeType == PremiumCardBadge.featured
                          ? ListingBadgeType.featured
                          : ListingBadgeType.urgent,
                      locale: locale,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Column(
                      children: [
                        _CircleIconButton(
                          icon: isSaved ? Icons.favorite : Icons.favorite_border,
                          onPressed: () => ref
                              .read(savedListingIdsProvider.notifier)
                              .toggle(listing.id),
                        ),
                        const SizedBox(height: 4),
                        _CircleIconButton(
                          icon: Icons.share_outlined,
                          onPressed: () => Share.share(
                            'Check out ${listing.title} on Raabta: ${listing.shareLink}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: AppTypography.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📍 ${listing.area}',
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.priceLabel,
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.brandFamilyMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _AmenityChip(label: '🛏️ ${listing.bedrooms}'),
                      _AmenityChip(label: '🚿 ${listing.bathrooms}'),
                      if (listing.amenities.contains('WiFi'))
                        const _AmenityChip(label: '📶 WiFi'),
                      if (listing.amenities.contains('AC'))
                        const _AmenityChip(label: '❄️ AC'),
                    ],
                  ),
                  HousingMatchWidget(
                    listingData: housingListingToMatchData(listing),
                    compact: true,
                  ),
                  if (matchScore != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                      child: Text(
                        HousingStrings.format(
                          'match_score_badge',
                          locale,
                          params: {'score': '$matchScore'},
                        ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.daysAgo == 0
                              ? 'Today'
                              : '${listing.daysAgo} days ago',
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ListingCard.buildWhatsAppButton(listing, compact: true),
                      const SizedBox(width: 4),
                      ListingCard.buildViewButton(
                        context,
                        listing.id,
                        locale: locale,
                        compact: true,
                      ),
                    ],
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

class SponsoredListingCard extends ConsumerWidget {
  const SponsoredListingCard({super.key, required this.listing});

  final HousingListing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HousingStrings.t('sponsored_label', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ListingCard(
          listing: listing,
          listIndex: 0,
          isSponsored: true,
        ),
        HousingMatchWidget(
          listingData: housingListingToMatchData(listing),
          compact: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Sponsored listings help property owners reach more renters.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Why am I seeing this?',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroStatsBar extends StatelessWidget {
  const _HeroStatsBar({
    required this.propertyCount,
    required this.areaLabel,
    required this.newToday,
  });

  final String propertyCount;
  final String areaLabel;
  final String newToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            MetricChip(
              icon: Icons.home_outlined,
              value: propertyCount,
              label: 'Properties',
              accentColor: AppColors.brandFamilyMain,
            ),
            MetricChip(
              icon: Icons.location_on_outlined,
              value: areaLabel,
              label: 'Your Area',
              accentColor: AppColors.brandFamilyDark,
            ),
            MetricChip(
              icon: Icons.auto_awesome_outlined,
              value: newToday,
              label: 'Today',
              accentColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
    );
  }
}
