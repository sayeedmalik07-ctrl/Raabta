import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/listing_card.dart';
import 'package:raabta/screens/housing/post_listing_screen.dart';
import 'package:raabta/widgets/ai/housing_match_widget.dart';
import 'package:share_plus/share_plus.dart';

Map<String, dynamic> housingListingToMatchData(HousingListing listing) {
  return {
    ...listing.toJson(),
    'price': listing.pricePerMonth,
    'propertyType': listing.typeLabel,
  };
}

class HousingListScreen extends ConsumerStatefulWidget {
  const HousingListScreen({super.key});

  @override
  ConsumerState<HousingListScreen> createState() => _HousingListScreenState();
}

class _HousingListScreenState extends ConsumerState<HousingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAdvancedFilters = false;

  static const List<({String label, ListingType type})> _typeFilters = [
    (label: 'All', type: ListingType.all),
    (label: 'Room', type: ListingType.room),
    (label: 'Flat', type: ListingType.flat),
    (label: 'Sharing', type: ListingType.sharing),
    (label: 'Studio', type: ListingType.studio),
  ];

  static const List<({String emoji, String name, int count})> _trendingLocations = [
    (emoji: '🏙️', name: 'Al Khor', count: 234),
    (emoji: '🌆', name: 'Doha', count: 891),
    (emoji: '✨', name: 'Lusail', count: 456),
    (emoji: '🏖️', name: 'The Pearl', count: 178),
    (emoji: '🏘️', name: 'Al Wakrah', count: 123),
  ];

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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostListingScreen()),
    );
  }

  String get _selectedAreaLabel {
    final area = ref.read(housingFiltersProvider).area;
    return area ?? 'Al Khor';
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
    final filters = ref.watch(housingFiltersProvider);
    final listingsAsync = ref.watch(housingListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openPostListing,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Post Room',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: listingsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => _EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load listings',
            subtitle: error.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(housingListingsProvider),
          ),
          data: (listings) {
            if (listings.isEmpty) {
              return Column(
                children: [
                  _buildHeader(filters),
                  Expanded(
                    child: _EmptyState(
                      icon: Icons.home_outlined,
                      title: 'No listings found',
                      subtitle:
                          'Try adjusting your filters or post a new listing.',
                      actionLabel: 'Post Listing',
                      onAction: _openPostListing,
                    ),
                  ),
                ],
              );
            }

            final recommended = listings.take(2).toList();
            final listingWidgets = _buildListingItems(listings);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(housingListingsProvider);
                await ref.read(housingListingsProvider.future);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(filters)),
                  SliverToBoxAdapter(
                    child: _HeroStatsBar(
                      propertyCount: '1,247',
                      areaLabel: _selectedAreaLabel,
                      newToday: '23 New',
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildSearchAndFilters(filters)),
                  if (_showAdvancedFilters)
                    SliverToBoxAdapter(
                      child: _buildAdvancedFilters(filters),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xxl,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: SectionHeader(
                        title: '✨ Recommended For You',
                        onSeeAll: () {},
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 380,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        itemCount: recommended.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return PremiumPropertyCard(
                            listing: recommended[index],
                            showMatchBadge: index == 0,
                            badgeType: index == 0
                                ? PremiumCardBadge.featured
                                : PremiumCardBadge.urgent,
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xxl,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: Text('📍 Trending Locations', style: AppTextStyles.h2),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        itemCount: _trendingLocations.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final location = _trendingLocations[index];
                          final selected = filters.area == location.name;
                          return GestureDetector(
                            onTap: () => _selectArea(
                              selected ? null : location.name,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(location.emoji),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    location.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '(${location.count})',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xxl,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: Text('All Listings', style: AppTextStyles.h2),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      100,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(HousingFilters filters) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Housing', style: AppTextStyles.h1),
              Text(
                'Find rooms & flats across Qatar',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () =>
              setState(() => _showAdvancedFilters = !_showAdvancedFilters),
          icon: Icon(
            _showAdvancedFilters
                ? Icons.filter_alt
                : Icons.filter_alt_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(HousingFilters filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
          child: TextField(
            controller: _searchController,
            style: AppTextStyles.bodyLarge,
            onChanged: _applySearch,
            decoration: InputDecoration(
              hintText: 'Search rooms, flats in Qatar...',
              hintStyle: AppTextStyles.bodyMedium,
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
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
              return FilterChip(
                label: Text(area),
                selected: selected,
                onSelected: (_) => _selectArea(selected ? null : area),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 12,
                ),
                showCheckmark: false,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: _typeFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = _typeFilters[index];
              final selected = filters.type == item.type;
              return FilterChip(
                label: Text(item.label),
                selected: selected,
                onSelected: (_) => _selectType(item.type),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
                showCheckmark: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters(HousingFilters filters) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price: ${filters.minPrice.round()} – ${filters.maxPrice.round()} QR/month',
              style: AppTextStyles.bodyLarge,
            ),
            RangeSlider(
              values: RangeValues(filters.minPrice, filters.maxPrice),
              min: 500,
              max: 5000,
              divisions: 45,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceElevated,
              labels: RangeLabels(
                '${filters.minPrice.round()}',
                '${filters.maxPrice.round()}',
              ),
              onChanged: _updatePriceRange,
            ),
            Text('Gender preference', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: GenderPreference.values.map((g) {
                final selected = filters.gender == g;
                return ChoiceChip(
                  label: Text(genderLabel(g)),
                  selected: selected,
                  onSelected: (_) => _selectGender(g),
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Nationality preference', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: NationalityPreference.values.map((n) {
                final selected = filters.nationality == n;
                return ChoiceChip(
                  label: Text(nationalityLabel(n)),
                  selected: selected,
                  onSelected: (_) => _selectNationality(n),
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
  const HousingScreen({super.key});
}

enum PremiumCardBadge { featured, urgent }

class PremiumPropertyCard extends ConsumerWidget {
  const PremiumPropertyCard({
    super.key,
    required this.listing,
    required this.badgeType,
    this.showMatchBadge = false,
  });

  final HousingListing listing;
  final PremiumCardBadge badgeType;
  final bool showMatchBadge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedListingIdsProvider);
    final isSaved = savedIds.contains(listing.id);
    final photoUrl = listing.photoUrls.isNotEmpty
        ? listing.photoUrls.first
        : 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800';

    return GestureDetector(
      onTap: () => ListingCard.openDetail(context, listing.id),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A2535), Color(0xFF0D1520)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Icon(Icons.home, color: Colors.white54, size: 48),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: MonetizationBadge(
                      type: badgeType == PremiumCardBadge.featured
                          ? ListingBadgeType.featured
                          : ListingBadgeType.urgent,
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
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📍 ${listing.area}',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.priceLabel,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
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
                  if (showMatchBadge) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '🤖 95% Match',
                        style: AppTextStyles.bodySmall.copyWith(
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
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ListingCard.buildWhatsAppButton(listing, compact: true),
                      const SizedBox(width: 4),
                      ListingCard.buildViewButton(
                        context,
                        listing.id,
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

class SponsoredListingCard extends StatelessWidget {
  const SponsoredListingCard({super.key, required this.listing});

  final HousingListing listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📢 SPONSORED',
          style: AppTextStyles.bodySmall.copyWith(
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
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surfaceElevated],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(emoji: '🏠', value: propertyCount, label: 'Properties'),
            ),
            Container(width: 1, height: 36, color: AppColors.border),
            Expanded(
              child: _StatColumn(emoji: '📍', value: areaLabel, label: 'Your Area'),
            ),
            Container(width: 1, height: 36, color: AppColors.border),
            Expanded(
              child: _StatColumn(emoji: '✨', value: newToday, label: 'Today'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      ],
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
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 56),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
