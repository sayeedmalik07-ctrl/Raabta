import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/core/widgets/hub/hub_post_fab.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/data/service_taxonomy.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_category.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/screens/services/providers/service_listings_providers.dart';
import 'package:raabta/screens/services/utils/service_subcategory_visuals.dart';
import 'package:raabta/screens/services/widgets/service_category_leaf_chips.dart';
import 'package:raabta/screens/services/widgets/service_hub_listing_card.dart';
import 'package:raabta/screens/services/widgets/service_hub_subscreen_scaffold.dart';
import 'package:raabta/screens/services/widgets/service_subcategory_tile.dart';
import 'package:raabta/screens/services/widgets/services_hub_browse_segment.dart';

class ServiceCategoryScreen extends ConsumerStatefulWidget {
  const ServiceCategoryScreen({
    super.key,
    required this.categoryId,
    this.initialSubService,
  });

  final String categoryId;
  final String? initialSubService;

  static const screenKey = Key('services_category_screen');

  @override
  ConsumerState<ServiceCategoryScreen> createState() =>
      _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends ConsumerState<ServiceCategoryScreen> {
  String? _selectedSubService;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSubService?.trim();
    if (initial != null && initial.isNotEmpty) {
      _selectedSubService = initial;
    }
  }

  void _openPost() {
    final category = findServiceCategoryById(widget.categoryId);
    if (category == null) return;
    context.push(
      '/services/post?categoryId=${Uri.encodeComponent(category.id)}'
      '${_selectedSubService != null ? '&serviceName=${Uri.encodeComponent(_selectedSubService!)}' : ''}',
    );
  }

  void _selectSubService(String? sub) {
    HapticFeedback.selectionClick();
    setState(() => _selectedSubService = sub);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final category = findServiceCategoryById(widget.categoryId);

    if (category == null) {
      return ServiceHubSubscreenScaffold(
        title: ServicesStrings.t('title', locale),
        subtitle: ServicesStrings.t('subtitle', locale),
        onBack: () => Navigator.of(context).pop(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.category_outlined,
              title: ServicesStrings.t('no_results', locale),
              description: ServicesStrings.t('subtitle', locale),
            ),
          ),
        ),
      );
    }

    final categoryVisual = ServiceSubcategoryVisuals.forCategory(
      categoryId: category.id,
      icon: category.icon,
    );
    final browseType = ref.watch(servicesBrowseListingTypeProvider);
    final filter = (
      categoryId: widget.categoryId,
      serviceName: _selectedSubService,
      listingType: browseType,
    );
    final listingsAsync = ref.watch(categoryServiceListingsProvider(filter));

    return KeyedSubtree(
      key: ServiceCategoryScreen.screenKey,
      child: ServiceHubSubscreenScaffold(
        title: category.name,
        subtitle: _categorySubtitle(locale, category),
        onBack: () => Navigator.of(context).pop(),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom > 0 ? 0 : AppSpacing.sm,
          ),
          child: HubPostFab(
            tooltip: ServicesStrings.t('post_listing', locale),
            onPressed: _openPost,
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.brandFamilyMain,
          onRefresh: () async {
            ref.invalidate(categoryServiceListingsProvider(filter));
            await ref.read(categoryServiceListingsProvider(filter).future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: ServicesHubBrowseSegment(locale: locale),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: HubNoticeBanner.hostNotice(locale: locale),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      ServiceCategoryHeroBadge(
                        icon: categoryVisual.icon,
                        gradient: categoryVisual.gradient,
                        glowColor: categoryVisual.glowColor,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          category.name,
                          style: AppTypography.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: ServiceCategoryLeafChipRow(
                    key: const Key('services_category_leaf_chips'),
                    locale: locale,
                    category: category,
                    selectedSubService: _selectedSubService,
                    onSelect: _selectSubService,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    ServicesStrings.t('tab_listings', locale),
                    style: AppTypography.subtitle,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: _listingsSliver(
                  locale: locale,
                  listingsAsync: listingsAsync,
                  browseType: browseType,
                  category: category,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    bottom: AppSpacing.xxxl,
                  ),
                  child: HubFeedFooterNotice(locale: locale),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categorySubtitle(String locale, ServiceCategory category) {
    final sub = _selectedSubService?.trim();
    if (sub != null && sub.isNotEmpty) {
      return sub;
    }
    return ServicesStrings.format(
      'services_count',
      locale,
      params: {'count': '${category.subServices.length}'},
    );
  }

  Widget _listingsSliver({
    required String locale,
    required AsyncValue<List<ServiceListing>> listingsAsync,
    required ServiceListingType browseType,
    required ServiceCategory category,
  }) {
    return listingsAsync.when(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < 2 ? AppSpacing.md : 0,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return HubLoadingPlaceholder(
                    width: constraints.maxWidth,
                    height: 128,
                    silhouette: browseType == ServiceListingType.provider
                        ? HubLoadingSilhouette.serviceCard
                        : HubLoadingSilhouette.serviceCardRequest,
                  );
                },
              ),
            );
          },
          childCount: 3,
        ),
      ),
      error: (_, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.error_outline,
              title: ServicesStrings.t('hub_load_error_title', locale),
              description: ServicesStrings.t('submit_error', locale),
              actionLabel: CommonActionStrings.t('action_retry', locale),
              onAction: () {
                ref.invalidate(
                  categoryServiceListingsProvider((
                    categoryId: widget.categoryId,
                    serviceName: _selectedSubService,
                    listingType: browseType,
                  )),
                );
              },
            ),
          ),
        ),
      ),
      data: (listings) {
        if (listings.isEmpty) {
          final leaf = _selectedSubService?.trim();
          String description;
          if (browseType == ServiceListingType.provider) {
            description = leaf != null && leaf.isNotEmpty
                ? ServicesStrings.format(
                    'hub_category_no_providers_inline',
                    locale,
                    params: {'leaf': leaf},
                  )
                : ServicesStrings.t('hub_category_no_providers_all', locale);
          } else {
            description = leaf != null && leaf.isNotEmpty
                ? ServicesStrings.format(
                    'hub_category_no_requests_inline',
                    locale,
                    params: {'leaf': leaf},
                  )
                : ServicesStrings.t('hub_category_no_requests_all', locale);
          }
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: GlassEmptyState(
                accent: GlassEmptyStateAccent.brand,
                icon: browseType == ServiceListingType.provider
                    ? Icons.handyman_outlined
                    : Icons.assignment_outlined,
                title: ServicesStrings.t('listings_empty_title', locale),
                description: description,
                actionLabel: ServicesStrings.t('post_listing', locale),
                onAction: _openPost,
              ),
            ),
          );
        }

        return SliverList.separated(
          itemCount: listings.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final listing = listings[index];
            return ServiceHubListingCard(
              listing: listing,
              locale: locale,
              onTap: () => context.push('/services/listing/${listing.id}'),
            );
          },
        );
      },
    );
  }
}
