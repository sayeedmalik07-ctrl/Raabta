import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/icons/hub_screen_icons.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/providers/marketplace_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/marketplace/widgets/marketplace_listing_card.dart';
import 'package:raabta/screens/monetization/boost_listing_screen.dart';
import 'package:raabta/services/qr/listing_deep_links.dart';
import 'package:raabta/services/qr/listing_ownership.dart';
import 'package:raabta/core/widgets/qr_share_sheet.dart';

class CategoryListingsScreen extends ConsumerStatefulWidget {
  const CategoryListingsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<CategoryListingsScreen> createState() =>
      _CategoryListingsScreenState();
}

class _CategoryListingsScreenState
    extends ConsumerState<CategoryListingsScreen> {
  final Set<String> _savedListingIds = {};

  MarketplaceCategory get _category =>
      marketplaceCategoryById(widget.categoryId);

  String get _hubTitle => '${_category.emoji} ${_category.name}';

  void _openPostInCategory() {
    context.push('/marketplace/post?category=${_category.id}');
  }

  void _toggleSave(String id) {
    setState(() {
      if (_savedListingIds.contains(id)) {
        _savedListingIds.remove(id);
      } else {
        _savedListingIds.add(id);
      }
    });
  }

  void _openBoost(MarketplaceListing listing) {
    if (!MonetizationState.showPremiumTierUi) return;
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

  void _openListingQr(MarketplaceListing listing, String locale) {
    showQrShareSheet(
      context,
      title: MarketplaceStrings.t('mp_listing_qr_title', locale),
      subtitle: listing.title,
      caption: MarketplaceStrings.t('mp_listing_qr_caption', locale),
      qrData: ListingDeepLinks.marketplaceListing(listing.id),
    );
  }

  Future<void> _onRefresh() async {
    ref.invalidate(marketplaceListingsProvider);
    await ref.read(
      marketplaceCategoryListingsProvider(widget.categoryId).future,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final listingsAsync = ref.watch(
      marketplaceCategoryListingsProvider(widget.categoryId),
    );
    final subtitle =
        MarketplaceStrings.t('mp_category_hub_subtitle', locale);

    Widget bodyLoading() => const Center(
          child: HubLoadingPlaceholder(
            width: 320,
            height: 360,
            silhouette: HubLoadingSilhouette.listing,
          ),
        );

    Widget bodyError() => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassErrorState(
              message: MarketplaceStrings.t('mp_err_load_listings', locale),
              onRetry: () {
                ref.invalidate(marketplaceListingsProvider);
                ref.invalidate(
                  marketplaceCategoryListingsProvider(widget.categoryId),
                );
              },
              retryLabel: CommonActionStrings.t('action_retry', locale),
            ),
          ),
        );

    return listingsAsync.when(
      loading: () => HubSubscreenScaffold(
        title: _hubTitle,
        subtitle: subtitle,
        onBack: () => context.pop(),
        headerTrailing: IconButton(
          onPressed: _openPostInCategory,
          tooltip: MarketplaceStrings.t('mp_post_ad', locale),
          icon: Icon(Icons.post_add_outlined, color: AppColors.brandFamilyMain),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        body: bodyLoading(),
      ),
      error: (error, stackTrace) => HubSubscreenScaffold(
        title: _hubTitle,
        subtitle: subtitle,
        onBack: () => context.pop(),
        headerTrailing: IconButton(
          onPressed: _openPostInCategory,
          tooltip: MarketplaceStrings.t('mp_post_ad', locale),
          icon: Icon(Icons.post_add_outlined, color: AppColors.brandFamilyMain),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        body: bodyError(),
      ),
      data: (listings) => HubSubscreenScaffold(
        title: _hubTitle,
        subtitle: subtitle,
        onBack: () => context.pop(),
        headerTrailing: IconButton(
          onPressed: _openPostInCategory,
          tooltip: MarketplaceStrings.t('mp_post_ad', locale),
          icon: Icon(Icons.post_add_outlined, color: AppColors.brandFamilyMain),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        body: RefreshIndicator(
          color: AppColors.brandFamilyMain,
          onRefresh: _onRefresh,
          child: listings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.xxxl,
                  ),
                  children: [
                    GlassEmptyState(
                      icon: Icons.inventory_2_outlined,
                      accent: GlassEmptyStateAccent.brand,
                      title: MarketplaceStrings.t('mp_no_listings_yet', locale),
                      description: MarketplaceStrings.format(
                        'mp_empty_category_first',
                        locale,
                        params: {'category': _category.name},
                      ),
                      actionLabel:
                          MarketplaceStrings.t('mp_post_ad', locale),
                      onAction: _openPostInCategory,
                    ),
                  ],
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.md,
                          AppSpacing.xl,
                          AppSpacing.sm,
                        ),
                        child: HomeSectionHeader(
                          overline: MarketplaceStrings.t(
                            'mp_category_listings_overline',
                            locale,
                          ),
                          title: MarketplaceStrings.format(
                            listings.length == 1
                                ? 'mp_listing_count_one'
                                : 'mp_listing_count_many',
                            locale,
                            params: {'count': '${listings.length}'},
                          ),
                          leadingIcon: HubScreenIcons.marketplaceCategory(
                            _category.id,
                          ),
                          compact: true,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.58,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final listing = listings[index];
                            return MarketplaceListingCard(
                              listing: listing,
                              locale: locale,
                              isSaved: _savedListingIds.contains(listing.id),
                              onSave: () => _toggleSave(listing.id),
                              onBoost: MonetizationState.showPremiumTierUi
                                  ? () => _openBoost(listing)
                                  : null,
                              onTap: () {
                                context.push(
                                  '/marketplace/listing/${listing.id}',
                                  extra: listing,
                                );
                              },
                              onGetQr: isListingOwnedByCurrentUser(
                                    listing.ownerUserId,
                                  )
                                  ? () => _openListingQr(listing, locale)
                                  : null,
                              compactGrid: true,
                            );
                          },
                          childCount: listings.length,
                        ),
                      ),
                    ),
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
    );
  }
}
