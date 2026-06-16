import 'package:flutter/material.dart';
import 'package:raabta/screens/ai_chat/ai_chat_screen.dart';
import 'package:raabta/screens/businesses/businesses_screen.dart';
import 'package:raabta/screens/community/community_screen.dart';
import 'package:raabta/screens/doctors/doctors_screen.dart';
import 'package:raabta/screens/housing/housing_screen.dart';
import 'package:raabta/screens/jobs/jobs_screen.dart';
import 'package:raabta/screens/marketplace/marketplace_screen.dart';
import 'package:raabta/screens/money/money_screen.dart';
import 'package:raabta/screens/profile/profile_screen.dart';
import 'package:raabta/screens/visa/visa_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  int _currentIndex = 0;

  static const List<_FeatureCard> _features = [
    _FeatureCard(
      emoji: '🏠',
      title: 'Housing',
      subtitle: 'Find your home',
    ),
    _FeatureCard(
      emoji: '\u{1F4B8}',
      title: 'Money Services',
      subtitle: 'Exchange rates & transfers',
    ),
    _FeatureCard(
      emoji: '📋',
      title: 'Visa Help',
      subtitle: 'Qatar visa guide',
    ),
    _FeatureCard(
      emoji: '🏥',
      title: 'Find Doctor',
      subtitle: 'Healthcare nearby',
    ),
    _FeatureCard(
      emoji: '💼',
      title: 'Jobs',
      subtitle: 'Career opportunities',
    ),
    _FeatureCard(
      emoji: '🏪',
      title: 'Businesses',
      subtitle: 'Local services',
    ),
  ];

  static const List<String> _newsChips = [
    'Visa Update',
    'Traffic',
    'New Jobs',
    'Events',
    'Weather',
  ];

  static const List<_MarketplaceCategory> _marketplaceCategories = [
    _MarketplaceCategory(emoji: '🚗', label: 'Cars'),
    _MarketplaceCategory(emoji: '🛋️', label: 'Furniture'),
    _MarketplaceCategory(emoji: '📱', label: 'Mobiles'),
    _MarketplaceCategory(emoji: '💻', label: 'Electronics'),
  ];

  Widget _buildBody() {
    return switch (_currentIndex) {
      0 => _buildHomeContent(),
      1 => const MarketplaceScreen(),
      2 => const CommunityScreen(),
      3 => AiChatScreen(onBack: () => setState(() => _currentIndex = 0)),
      4 => const ProfileScreen(),
      _ => _buildHomeContent(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: _surfaceColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: _subtitleColor,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '🏠 Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: '🛍️ Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: '👥 Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: '🤖 AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '👤 Profile',
          ),
        ],
      ),
    );
  }

  void _onFeatureTap(BuildContext context, int index) {
    final Widget? screen = switch (index) {
      0 => const HousingScreen(),
      1 => const MoneyScreen(),
      2 => const VisaScreen(),
      3 => const DoctorsScreen(),
      4 => const JobsScreen(),
      5 => const BusinessesScreen(),
      _ => null,
    };
    if (screen == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openMarketplace(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'See All →',
              style: TextStyle(
                color: _cyanColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Raabta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Assalamu Alaikum 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sunday, 15 June · Al Khor 🌤️ 38°C',
                      style: TextStyle(
                        color: _subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📰 Qatar Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newsChips.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _cyanColor),
                          ),
                          child: Text(
                            _newsChips[index],
                            style: const TextStyle(
                              color: _cyanColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
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
                mainAxisExtent: 140,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _FeatureCardWidget(
                    feature: _features[index],
                    onTap: () => _onFeatureTap(context, index),
                  );
                },
                childCount: _features.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: '🛍️ Marketplace',
                    onSeeAll: () => _openMarketplace(context),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _marketplaceCategories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = _marketplaceCategories[index];
                        return GestureDetector(
                          onTap: () => _openMarketplace(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  category.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: '👥 Community',
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(color: _cyanColor, width: 3),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔥 Indians in Qatar · 42 replies',
                          style: TextStyle(
                            color: _cyanColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Best CBSE school in Al Khor?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            sliver: SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _surfaceColor,
                      _surfaceColor.withValues(alpha: 0.6),
                      const Color(0xFF0A1825),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _cyanColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⭐ 250 Raabta Points · Explorer Level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 250 / 500,
                        minHeight: 8,
                        backgroundColor: _backgroundColor,
                        color: _cyanColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '250 / 500 to next level',
                      style: TextStyle(
                        color: _subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Refer friends to earn more →',
                        style: TextStyle(
                          color: _cyanColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard {
  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;
}

class _MarketplaceCategory {
  const _MarketplaceCategory({
    required this.emoji,
    required this.label,
  });

  final String emoji;
  final String label;
}

class _FeatureCardWidget extends StatelessWidget {
  const _FeatureCardWidget({
    required this.feature,
    required this.onTap,
  });

  final _FeatureCard feature;
  final VoidCallback onTap;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  static const TextStyle _emojiStyle = TextStyle(
    fontSize: 32,
    height: 1.2,
    fontFamilyFallback: [
      'Apple Color Emoji',
      'Segoe UI Emoji',
      'Noto Color Emoji',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feature.emoji, style: _emojiStyle),
            const Spacer(),
            Text(
              feature.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              feature.subtitle,
              style: const TextStyle(
                color: _subtitleColor,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
