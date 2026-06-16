import 'package:flutter/material.dart';
import 'package:raabta/screens/marketplace/post_ad_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

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
      emoji: '📱',
      title: 'iPhone 14 Pro Max 256GB',
      price: '3,200 QR',
      area: 'Al Khor',
      posted: '2 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇮🇳',
    ),
    _MarketListing(
      emoji: '🚗',
      title: 'Toyota Corolla 2020',
      price: '42,000 QR',
      area: 'Doha',
      posted: '5 hours ago',
      condition: 'Good',
      sellerFlag: '🇵🇰',
    ),
    _MarketListing(
      emoji: '🛋️',
      title: 'IKEA Sofa Set',
      price: '800 QR',
      area: 'Lusail',
      posted: '1 day ago',
      condition: 'Like New',
      sellerFlag: '🇵🇭',
    ),
    _MarketListing(
      emoji: '📺',
      title: 'Samsung TV 55"',
      price: '1,200 QR',
      area: 'Al Khor',
      posted: '3 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇧🇩',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Navigator.of(context).canPop())
                          Padding(
                            padding: const EdgeInsets.only(right: 4, top: 2),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🛍️ Marketplace',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Buy & sell in Qatar expat community',
                                style: TextStyle(
                                  color: _subtitleColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PostAdScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _cyanColor,
                              foregroundColor: _backgroundColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Post Ad',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search cars, furniture, phones...',
                        hintStyle: const TextStyle(color: _subtitleColor),
                        prefixIcon:
                            const Icon(Icons.search, color: _subtitleColor),
                        filled: true,
                        fillColor: _surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 130,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _CategoryCard(category: _categories[index]);
                  },
                  childCount: _categories.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔥 Recent Listings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: _listings.length,
                      itemBuilder: (context, index) {
                        return _ListingCard(listing: _listings[index]);
                      },
                    ),
                  ],
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
    required this.emoji,
    required this.title,
    required this.price,
    required this.area,
    required this.posted,
    required this.condition,
    required this.sellerFlag,
  });

  final String emoji;
  final String title;
  final String price;
  final String area;
  final String posted;
  final String condition;
  final String sellerFlag;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _MarketCategory category;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 32)),
          const Spacer(),
          Text(
            category.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${category.count} listings',
            style: const TextStyle(color: _subtitleColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final _MarketListing listing;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _conditionGreen = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    listing.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Text(
                  listing.sellerFlag,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  listing.price,
                  style: const TextStyle(
                    color: _cyanColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.area,
                  style: const TextStyle(
                    color: _subtitleColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.posted,
                  style: const TextStyle(
                    color: _subtitleColor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _conditionGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    listing.condition,
                    style: const TextStyle(
                      color: _conditionGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
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
