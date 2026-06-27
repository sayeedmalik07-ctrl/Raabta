import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/screens/marketplace/post_ad_screen.dart';
import 'package:raabta/screens/monetization/boost_listing_screen.dart';

enum ListingBoostBadge { featured, hot }

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _savedListingIds = {};
  int _selectedBoostPackage = 0;

  static const List<_MarketCategory> _categories = [
    _MarketCategory(emoji: '🚗', name: 'Cars & Bikes', count: 234),
    _MarketCategory(emoji: '📱', name: 'Mobiles & Tablets', count: 189),
    _MarketCategory(emoji: '🛋️', name: 'Furniture', count: 156),
    _MarketCategory(emoji: '💻', name: 'Electronics', count: 312),
    _MarketCategory(emoji: '🏠', name: 'Home Appliances', count: 98),
    _MarketCategory(emoji: '📚', name: 'Books & More', count: 67),
  ];

  static const List<_MarketListing> _listings = [
    _MarketListing(
      id: 'listing-1',
      emoji: '📱',
      title: 'iPhone 14 Pro Max 256GB',
      price: '3,200 QR',
      area: 'Al Khor',
      posted: '2 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇮🇳',
      views: 234,
      distanceKm: 2.3,
      badge: ListingBoostBadge.featured,
      trendingViews: 1240,
    ),
    _MarketListing(
      id: 'listing-2',
      emoji: '🚗',
      title: 'Toyota Corolla 2020',
      price: '42,000 QR',
      area: 'Doha',
      posted: '5 hours ago',
      condition: 'Good',
      sellerFlag: '🇵🇰',
      views: 891,
      distanceKm: 18.5,
      badge: ListingBoostBadge.hot,
      trendingViews: 2100,
    ),
    _MarketListing(
      id: 'listing-3',
      emoji: '🛋️',
      title: 'IKEA Sofa Set',
      price: '800 QR',
      area: 'Lusail',
      posted: '1 day ago',
      condition: 'Like New',
      sellerFlag: '🇵🇭',
      views: 156,
      distanceKm: 12.1,
      badge: ListingBoostBadge.featured,
      trendingViews: 890,
    ),
    _MarketListing(
      id: 'listing-4',
      emoji: '📺',
      title: 'Samsung TV 55"',
      price: '1,200 QR',
      area: 'Al Khor',
      posted: '3 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇧🇩',
      views: 412,
      distanceKm: 1.8,
      badge: ListingBoostBadge.hot,
      trendingViews: 1560,
    ),
  ];

  static const List<({String label, String price})> _boostPackages = [
    (label: '3 Days - 10 QR', price: '10'),
    (label: '7 Days - 20 QR', price: '20'),
    (label: '30 Days - 60 QR', price: '60'),
  ];

  List<_MarketListing> get _filteredListings {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _listings;
    return _listings
        .where(
          (l) =>
              l.title.toLowerCase().contains(query) ||
              l.area.toLowerCase().contains(query) ||
              l.price.toLowerCase().contains(query),
        )
        .toList();
  }

  List<_MarketListing> get _nearbyListings =>
      _listings.where((l) => l.area == 'Al Khor').toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPostAd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostAdScreen()),
    );
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openBoostListing(_MarketListing listing) {
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

  List<Widget> _buildListingItems(List<_MarketListing> listings) {
    final items = <Widget>[];
    for (var i = 0; i < listings.length; i++) {
      items.add(
        _ListingCard(
          listing: listings[i],
          isSaved: _savedListingIds.contains(listings[i].id),
          onSave: () => _toggleSave(listings[i].id),
          onBoost: () => _openBoostListing(listings[i]),
          onTap: () => _showSnack('Opening ${listings[i].title}'),
        ),
      );
      if ((i + 1) % 6 == 0) {
        items.add(
          _SponsoredListingCard(
            listing: listings[i],
            isSaved: _savedListingIds.contains('sponsored-${listings[i].id}'),
            onSave: () => _toggleSave('sponsored-${listings[i].id}'),
            onTap: () => _showSnack('Sponsored listing'),
          ),
        );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final listings = _filteredListings;
    final featured = _listings.take(2).toList();
    final nearby = _nearbyListings;
    final listingWidgets = _buildListingItems(listings);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopActions(context)),
            SliverToBoxAdapter(child: _buildHeroBanner()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                0,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 130,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _CategoryCard(category: _categories[index]),
                  childCount: _categories.length,
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
                child: SectionHeader(
                  title: '⭐ Featured Listings',
                  onSeeAll: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return _BoostedListingCard(
                      listing: featured[index],
                      isSaved: _savedListingIds.contains(featured[index].id),
                      onSave: () => _toggleSave(featured[index].id),
                      onMessage: () => context.push('/ai-chat'),
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
                child: Text('🔥 Trending Now', style: AppTextStyles.h2),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: _listings.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return _TrendingItemCard(listing: _listings[index]);
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
                child: SectionHeader(
                  title: '📍 Near Al Khor',
                  onSeeAll: () {},
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _NearbyCompactCard(
                    listing: nearby[index % nearby.length],
                    onTap: () => _showSnack('Opening ${nearby[index % nearby.length].title}'),
                  ),
                  childCount: nearby.length.clamp(2, 4),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildBoostBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Text('🔥 Recent Listings', style: AppTextStyles.h2),
              ),
            ),
            if (listings.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Center(
                    child: Text(
                      'No listings match your search',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => listingWidgets[index],
                    childCount: listingWidgets.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.xl, 0),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          const Spacer(),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: _openPostAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: const Text(
                'Post Ad',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.surfaceElevated, AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              CustomPaint(painter: _GridPatternPainter()),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🛍️ Qatar Marketplace', style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Buy & sell in your expat community',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStat(value: '12,456', label: 'Listings'),
                        ),
                        Container(width: 1, height: 28, color: AppColors.border),
                        Expanded(
                          child: _HeroStat(value: 'Al Khor', label: 'Area'),
                        ),
                        Container(width: 1, height: 28, color: AppColors.border),
                        Expanded(
                          child: _HeroStat(value: 'Free', label: 'To Post'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search cars, furniture, phones...',
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBoostBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.12),
              AppColors.surfaceElevated,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚀 Boost Your Listing', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Get 10x more views',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(_boostPackages.length, (index) {
                final selected = _selectedBoostPackage == index;
                return ChoiceChip(
                  label: Text(_boostPackages[index].label),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedBoostPackage = index),
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.gold.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.gold : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.gold : AppColors.border,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final sample = _listings.isNotEmpty
                      ? _listings.first
                      : _filteredListings.first;
                  _openBoostListing(sample);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text(
                  'Boost Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketCategory {
  const _MarketCategory({
    required this.emoji,
    required this.name,
    required this.count,
  });

  final String emoji;
  final String name;
  final int count;
}

class _MarketListing {
  const _MarketListing({
    required this.id,
    required this.emoji,
    required this.title,
    required this.price,
    required this.area,
    required this.posted,
    required this.condition,
    required this.sellerFlag,
    required this.views,
    required this.distanceKm,
    required this.badge,
    required this.trendingViews,
  });

  final String id;
  final String emoji;
  final String title;
  final String price;
  final String area;
  final String posted;
  final String condition;
  final String sellerFlag;
  final int views;
  final double distanceKm;
  final ListingBoostBadge badge;
  final int trendingViews;
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const spacing = 24.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _MarketCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 32)),
          const Spacer(),
          Text(
            category.name,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${category.count} listings',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BoostedListingCard extends StatelessWidget {
  const _BoostedListingCard({
    required this.listing,
    required this.isSaved,
    required this.onSave,
    required this.onMessage,
  });

  final _MarketListing listing;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final isFeatured = listing.badge == ListingBoostBadge.featured;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A2535), Color(0xFF0D1520)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(listing.emoji, style: const TextStyle(fontSize: 48)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _BoostBadge(isFeatured: isFeatured),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    onPressed: onSave,
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.price,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  listing.title,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ConditionChip(condition: listing.condition),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${listing.area} · ${listing.posted}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onMessage,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingItemCard extends StatelessWidget {
  const _TrendingItemCard({required this.listing});

  final _MarketListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text('🔥 ${listing.emoji}', style: const TextStyle(fontSize: 24)),
            ),
          ),
          const Spacer(),
          Text(
            listing.title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            listing.price,
            style: AppTextStyles.labelLarge.copyWith(fontSize: 11),
          ),
          Text(
            '${listing.trendingViews} views',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _NearbyCompactCard extends StatelessWidget {
  const _NearbyCompactCard({required this.listing, required this.onTap});

  final _MarketListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              width: double.infinity,
              color: AppColors.surfaceElevated,
              child: Center(
                child: Text(listing.emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.price,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                  ),
                  Text(
                    listing.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${listing.distanceKm} km',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
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

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.isSaved,
    required this.onSave,
    required this.onBoost,
    required this.onTap,
  });

  final _MarketListing listing;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onBoost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Center(
                        child: Text(listing.emoji, style: const TextStyle(fontSize: 44)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Text(listing.sellerFlag, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 4),
                          Material(
                            color: Colors.black45,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onSave,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  isSaved ? Icons.favorite : Icons.favorite_border,
                                  color: isSaved ? AppColors.primary : Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.price,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        listing.title,
                        style: AppTextStyles.h3.copyWith(fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          _ConditionChip(condition: listing.condition),
                          const Spacer(),
                          Text(
                            '👁️ ${listing.views} views',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('📍 ${listing.area}', style: AppTextStyles.bodySmall),
                      Text(listing.posted, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onBoost,
              child: Text(
                '🚀 Boost',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsoredListingCard extends StatelessWidget {
  const _SponsoredListingCard({
    required this.listing,
    required this.isSaved,
    required this.onSave,
    required this.onTap,
  });

  final _MarketListing listing;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            '📢 AD',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _ListingCard(
          listing: listing,
          isSaved: isSaved,
          onSave: onSave,
          onBoost: () {},
          onTap: onTap,
        ),
      ],
    );
  }
}

class _BoostBadge extends StatelessWidget {
  const _BoostBadge({required this.isFeatured});

  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final color = isFeatured ? AppColors.gold : AppColors.error;
    final label = isFeatured ? '⭐ FEATURED' : '🔥 HOT';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.condition});

  final String condition;

  @override
  Widget build(BuildContext context) {
    final lower = condition.toLowerCase();
    final isExcellent =
        lower.contains('excellent') || lower.contains('like new');
    final color = isExcellent ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        condition,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
