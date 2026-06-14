import 'package:flutter/material.dart';
import 'package:raabta/screens/housing/housing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);

  int _currentIndex = 0;

  static const List<_FeatureCard> _features = [
    _FeatureCard(
      emoji: '🏠',
      title: 'Housing',
      subtitle: 'Find your home',
    ),
    _FeatureCard(
      emoji: '\u{1F4B8}',
      title: 'Send Money',
      subtitle: 'Transfer instantly',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _currentIndex == 0 ? _buildHomeContent() : _buildPlaceholder(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: _surfaceColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: _subtitleColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            activeIcon: Icon(Icons.apartment),
            label: 'Housing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
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
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                    onTap: index == 0
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HousingScreen(),
                              ),
                            );
                          }
                        : null,
                  );
                },
                childCount: _features.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    const tabLabels = ['Home', 'Housing', 'AI Chat', 'Jobs', 'Profile'];
    return Center(
      child: Text(
        tabLabels[_currentIndex],
        style: const TextStyle(
          color: _subtitleColor,
          fontSize: 18,
        ),
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

class _FeatureCardWidget extends StatelessWidget {
  const _FeatureCardWidget({
    required this.feature,
    this.onTap,
  });

  final _FeatureCard feature;
  final VoidCallback? onTap;

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
