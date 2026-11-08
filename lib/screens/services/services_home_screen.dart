import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_post_fab.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/core/widgets/hub/hub_summary_strip_card.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';
import 'package:raabta/features/saved_search/presentation/widgets/save_search_button.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/data/service_taxonomy.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_category.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/screens/services/utils/service_subcategory_visuals.dart';
import 'package:raabta/screens/services/widgets/service_hub_listing_card.dart';
import 'package:raabta/screens/services/widgets/service_subcategory_tile.dart';
import 'package:raabta/screens/services/widgets/services_hub_all_services_row.dart';
import 'package:raabta/screens/services/widgets/services_hub_browse_segment.dart';
import 'package:raabta/screens/services/widgets/services_hub_describe_card.dart';
import 'package:raabta/screens/services/widgets/services_hub_front_group_grid.dart';
import 'package:raabta/screens/services/widgets/services_hub_verified_strip.dart';

class ServicesHomeScreen extends ConsumerStatefulWidget {
  const ServicesHomeScreen({super.key, this.routeParameters});

  final SearchRouteParameters? routeParameters;

  @override
  ConsumerState<ServicesHomeScreen> createState() =>
      _ServicesHomeScreenState();
}

class _ServicesHomeScreenState extends ConsumerState<ServicesHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final params = widget.routeParameters;
    if (params == null || params.isEmpty) return;

    if (params.serviceTrade != null && params.serviceTrade!.trim().isNotEmpty) {
      _searchController.text = params.serviceTrade!.trim();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  void _openCategory(ServiceCategory category) {
    HapticFeedback.selectionClick();
    context.push('/services/category/${category.id}');
  }

  void _openPost({ServiceListingType? explicitListingType}) {
    HapticFeedback.selectionClick();
    final ServiceListingType postListingType = explicitListingType ??
        ref.read(servicesBrowseListingTypeProvider.notifier).state;
    context.push('/services/post?listingType=${postListingType.id}');
  }

  void _openListing(ServiceListing listing) {
    context.push('/services/listing/${listing.id}');
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  List<ServiceListing> _filterListings(List<ServiceListing> source) {
    var list = source;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((l) {
        final haystack =
            '${l.serviceName} ${l.serviceCategory} ${l.title} ${l.providerName}'
                .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final browseType = ref.watch(servicesBrowseListingTypeProvider);
    final listingsAsync = ref.watch(recentServiceListingsProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom > 0 ? 0 : AppSpacing.sm,
          ),
          child: HubPostFab(
            key: const Key('services_hub_post_fab'),
            tooltip: ServicesStrings.t('post_listing', locale),
            onPressed: () => _openPost(),
          ),
        ),
        body: SafeArea(
          child: listingsAsync.when(
            loading: () => _buildLoadingBody(locale, browseType),
            error: (e, _) => _buildErrorBody(locale, e),
            data: (listings) => _buildContent(locale, browseType, listings),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBody(String locale, ServiceListingType browseType) {
    final silhouette = browseType == ServiceListingType.provider
        ? HubLoadingSilhouette.serviceCard
        : HubLoadingSilhouette.serviceCardRequest;
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        ..._hubChromeSlivers(locale, browseType, const []),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < 3 ? AppSpacing.md : 0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return HubLoadingPlaceholder(
                        key: index == 0
                            ? const Key('services_hub_loading_skeleton')
                            : null,
                        width: constraints.maxWidth,
                        height: 128,
                        silhouette: silhouette,
                      );
                    },
                  ),
                );
              },
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBody(String locale, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: GlassEmptyState(
          key: const Key('services_hub_error_state'),
          accent: GlassEmptyStateAccent.brand,
          icon: Icons.error_outline,
          title: ServicesStrings.t('hub_load_error_title', locale),
          description: '$error',
          actionLabel: CommonActionStrings.t('action_retry', locale),
          onAction: () => ref.invalidate(recentServiceListingsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(
    String locale,
    ServiceListingType browseType,
    List<ServiceListing> listings,
  ) {
    final filtered = _filterListings(listings);
    final zeroFromSearch =
        filtered.isEmpty && _isSearching && listings.isNotEmpty;

    return RefreshIndicator(
      color: AppColors.brandFamilyMain,
      onRefresh: () async {
        ref.invalidate(recentServiceListingsProvider);
        await ref.read(recentServiceListingsProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          ..._hubChromeSlivers(locale, browseType, listings),
          if (_isSearching)
            ..._searchResultSlivers(locale, listings)
          else ...[
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: GlassEmptyState(
                    key: Key(
                      zeroFromSearch
                          ? 'services_hub_zero_result_state'
                          : 'services_hub_empty_state',
                    ),
                    accent: GlassEmptyStateAccent.brand,
                    icon: Icons.home_repair_service_outlined,
                    title: zeroFromSearch
                        ? ServicesStrings.t('hub_empty_search_title', locale)
                        : ServicesStrings.t('listings_empty_title', locale),
                    description: zeroFromSearch
                        ? ServicesStrings.t(
                            'hub_empty_search_description',
                            locale,
                          )
                        : ServicesStrings.t('listings_empty_body', locale),
                    actionLabel: zeroFromSearch
                        ? ServicesStrings.t('hub_clear_search', locale)
                        : ServicesStrings.t('post_listing', locale),
                    onAction: zeroFromSearch
                        ? _clearSearch
                        : () => _openPost(),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final listing = filtered[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              index < filtered.length - 1 ? AppSpacing.md : 0,
                        ),
                        child: ServiceHubListingCard(
                          listing: listing,
                          locale: locale,
                          onTap: () => _openListing(listing),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              child: HubFeedFooterNotice(locale: locale),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _hubChromeSlivers(
    String locale,
    ServiceListingType browseType,
    List<ServiceListing> listings,
  ) {
    return [
      SliverToBoxAdapter(child: _buildHubHeader(locale)),
      SliverToBoxAdapter(child: _buildHubSearchSection(locale)),
      SliverToBoxAdapter(child: _buildProvidersRequestsSegment(locale)),
      SliverToBoxAdapter(child: _buildHubSummaryStrip(locale)),
      if (!_isSearching) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              0,
            ),
            child: ServicesHubDescribeCard(locale: locale),
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
            child: ServicesHubFrontGroupGrid(locale: locale),
          ),
        ),
        SliverToBoxAdapter(
          child: ServicesHubAllServicesRow(locale: locale),
        ),
        SliverToBoxAdapter(
          child: ServicesHubVerifiedStrip(
            locale: locale,
            listings: listings,
          ),
        ),
      ],
      if (browseType == ServiceListingType.request && !_isSearching)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              0,
            ),
            child: Text(
              ServicesStrings.t('find_work_hint', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildHubHeader(String locale) {
    return HubLandingHeader(
      key: const Key('services_hub_landing_header'),
      title: ServicesStrings.t('title', locale),
      subtitle: ServicesStrings.t('subtitle', locale),
      onBack: () => Navigator.of(context).pop(),
      trailing: IconButton(
        onPressed: () => context.push('/services/my-listings'),
        icon: Icon(Icons.list_alt_outlined, color: AppColors.brandFamilyMain),
        tooltip: ServicesStrings.t('my_listings', locale),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }

  Widget _buildHubSearchSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            0,
          ),
          child: TextField(
            key: const Key('services_hub_search'),
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppTypography.subtitle,
            textInputAction: TextInputAction.search,
            decoration: hubSearchInputDecoration(
              hintText: ServicesStrings.t('hub_search_hint_main', locale),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SaveSearchButton(
              vertical: SavedSearchVertical.services,
              accent: SaveSearchButtonAccent.hubBrand,
              criteria: SavedSearchCriteria.fromServicesBrowse(
                query: _searchController.text,
                areaFilter: null,
                listingType: ref.read(servicesBrowseListingTypeProvider),
                categoryId: null,
                subService: null,
                routeFilters: widget.routeParameters,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersRequestsSegment(String locale) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: ServicesHubBrowseSegment(locale: locale),
      ),
    );
  }

  Widget _buildHubSummaryStrip(String locale) {
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final cards = <Widget>[];

    if (uid.isNotEmpty) {
      final mineAsync = ref.watch(userServiceListingsProvider(uid));
      final openCount = mineAsync.maybeWhen(
        data: (items) =>
            items.where((l) => l.isRequest && l.acceptsQuotes).length,
        orElse: () => null,
      );
      if (openCount != null && openCount > 0) {
        cards.add(
          Expanded(
            child: HubSummaryStripCard(
              value: ProfileDisplayHelper.formatCount(openCount),
              label: ServicesStrings.t('hub_strip_open_requests', locale),
              icon: Icons.assignment_outlined,
              onTap: () => context.push('/services/my-listings'),
            ),
          ),
        );
      }
    }

    final savedAsync = ref.watch(
      userSavedSearchesForVerticalProvider(SavedSearchVertical.services),
    );
    final savedCount = savedAsync.maybeWhen(
      data: (searches) => searches.where((s) => s.active).length,
      orElse: () => null,
    );
    if (savedCount != null && savedCount > 0) {
      if (cards.isNotEmpty) cards.add(const SizedBox(width: AppSpacing.sm));
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

    if (cards.isEmpty) return const SizedBox.shrink();
    return HubSummaryStripPadding(child: Row(children: cards));
  }

  List<Widget> _searchResultSlivers(
    String locale,
    List<ServiceListing> listings,
  ) {
    final query = _searchController.text.trim();
    final hits = searchServiceTaxonomy(query);
    final matchedListings = _filterListings(listings);

    if (hits.isEmpty && matchedListings.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.search_off_rounded,
              title: ServicesStrings.t('no_results', locale),
              description: ServicesStrings.t('listings_empty_body', locale),
              actionLabel: ServicesStrings.t('post_listing', locale),
              onAction: () => _openPost(),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            if (matchedListings.isNotEmpty) ...[
              Text(
                ServicesStrings.t('tab_listings', locale),
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...matchedListings.map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ServiceHubListingCard(
                    listing: l,
                    locale: locale,
                    onTap: () => _openListing(l),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (hits.isNotEmpty) ...[
              Text(
                ServicesStrings.t('tab_categories', locale),
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...hits.map((hit) {
                final visual = ServiceSubcategoryVisuals.forSubservice(
                  categoryId: hit.category.id,
                  subServiceName: hit.subService,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ServiceSubcategoryTile(
                    label: hit.subService,
                    visual: visual,
                    compact: true,
                    onTap: () => _openCategory(hit.category),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.brandFamilyMain,
                      ),
                      tooltip: ServicesStrings.t('post_listing', locale),
                      onPressed: () => _openPost(),
                    ),
                  ),
                );
              }),
            ],
          ]),
        ),
      ),
    ];
  }
}
