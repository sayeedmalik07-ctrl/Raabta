import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/color_family.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/features/home/data/core_service_color_family.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/core/theme/theme_notifier.dart';
import 'package:raabta/providers/notification_providers.dart';
import 'package:raabta/screens/ai_chat/ai_chat_screen.dart';
import 'package:raabta/screens/community/community_screen.dart';
import 'package:raabta/screens/marketplace/marketplace_screen.dart';
import 'package:raabta/screens/profile/profile_screen.dart';
import 'package:raabta/widgets/ai/ai_feed_section.dart';
import 'package:raabta/widgets/ai/smart_search_bar.dart';
import 'package:raabta/widgets/common/theme_toggle_button.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _recommendedTabController;

  bool _insightsLoading = true;
  bool _recommendedLoading = true;
  bool _communityLoading = true;

  static const List<_FeatureCard> _features = [
    _FeatureCard(emoji: '🏠', title: 'Housing', subtitle: 'Find your home'),
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

  static const List<_QuickAction> _quickActions = [
    _QuickAction(emoji: '➕', label: 'Post Job', color: Color(0xFF3B82F6)),
    _QuickAction(emoji: '🏠', label: 'Post Room', color: Color(0xFF34D399)),
    _QuickAction(emoji: '🛒', label: 'Sell Item', color: Color(0xFFFBBF24)),
    _QuickAction(emoji: '🔧', label: 'Find Service', color: Color(0xFF6366F1)),
    _QuickAction(emoji: '📢', label: 'Promote Business', color: Color(0xFF22D3EE)),
  ];

  static const List<_AiInsight> _aiInsights = [
    _AiInsight(
      borderColor: AppColors.primary,
      emoji: '🏠',
      title: '23 new rooms near Al Khor',
      subtitle: 'Match your budget 1,500–2,500 QR',
      actionLabel: 'View Now →',
    ),
    _AiInsight(
      borderColor: AppColors.secondary,
      emoji: '💼',
      title: '17 jobs match your profile',
      subtitle: 'HSE Officer · Safety Manager · QE',
      actionLabel: 'View Jobs →',
    ),
    _AiInsight(
      borderColor: AppColors.success,
      emoji: '💰',
      title: 'INR rate increased today',
      subtitle: '1 QR = 22.95 INR ↑ +0.15',
      actionLabel: 'Best time to transfer →',
    ),
    _AiInsight(
      borderColor: AppColors.warning,
      emoji: '📋',
      title: 'New Iqama renewal update',
      subtitle: 'Process changed from 5 to 3 steps',
      actionLabel: 'Read Update →',
    ),
    _AiInsight(
      borderColor: Color(0xFFEC4899),
      emoji: '🎉',
      title: 'Indian cricket match this Friday',
      subtitle: 'Al Khor Sports Complex · Free entry',
      actionLabel: 'Join Event →',
    ),
  ];

  static const List<_ScoreMetric> _scoreMetrics = [
    _ScoreMetric(label: 'Career', value: 0.78, color: AppColors.primary),
    _ScoreMetric(label: 'Housing', value: 0.62, color: AppColors.info),
    _ScoreMetric(label: 'Financial', value: 0.80, color: AppColors.success),
    _ScoreMetric(label: 'Community', value: 0.45, color: AppColors.secondary),
    _ScoreMetric(label: 'Documentation', value: 0.65, color: AppColors.warning),
  ];

  static const List<String> _trendingTopics = [
    '#HSEJobs',
    '#AlKhorRooms',
    '#INRRate',
  ];

  static const List<_MarketplaceCategory> _marketplaceCategories = [
    _MarketplaceCategory(emoji: '🚗', label: 'Cars'),
    _MarketplaceCategory(emoji: '📱', label: 'Mobiles'),
    _MarketplaceCategory(emoji: '🛋️', label: 'Furniture'),
    _MarketplaceCategory(emoji: '💻', label: 'Electronics'),
  ];

  @override
  void initState() {
    super.initState();
    _recommendedTabController = TabController(length: 4, vsync: this);
    _loadAsyncSections();
  }

  Future<void> _loadAsyncSections() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _insightsLoading = false;
      _recommendedLoading = false;
      _communityLoading = false;
    });
  }

  @override
  void dispose() {
    _recommendedTabController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🌅';
    if (hour < 17) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }

  String get _formattedDate =>
      DateFormat('EEE d MMM').format(DateTime.now());

  void _onFeatureTap(int index) {
    switch (index) {
      case 0:
        context.push('/housing');
      case 1:
        context.push('/money');
      case 2:
        context.push('/visa');
      case 3:
        context.push('/doctors');
      case 4:
        context.push('/jobs');
      case 5:
        context.push('/businesses');
    }
  }

  void _onQuickActionTap(int index) {
    switch (index) {
      case 0:
        context.push('/jobs');
      case 1:
        context.push('/housing');
      case 2:
        context.push('/marketplace');
      case 3:
        context.push('/businesses');
      case 4:
        context.push('/business-advertise');
    }
  }

  void _openMarketplace() {
    context.push('/marketplace');
  }

  void _openCommunityTab() {
    setState(() => _currentIndex = 2);
  }

  void _openProfileTab() {
    setState(() => _currentIndex = 4);
  }

  void _openExpatScoreScreen() {
    context.push('/expat-score');
  }

  void _onAiInsightTap(int index) {
    switch (index) {
      case 0:
        context.push('/housing');
      case 1:
        context.push('/jobs');
      case 2:
        context.push('/money');
      case 3:
        context.push('/visa');
      case 4:
        _openCommunityTab();
    }
  }

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
    ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
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
            label: '🤖 AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '👤 Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => QuickActionsHub.show(context),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              child: const Text('⚡', style: TextStyle(fontSize: 22)),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopAppBar(),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartSearchBar(
                    onSearchResult: (result) {
                      if (result.confidence > 0.7) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🤖 AI found ${result.intent.name} results',
                            ),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildGreetingCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildExpatLifeScoreCard(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildAiInsightsSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildQuickActionsSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  const AIFeedSection(),
                  const SizedBox(height: 24),
                  _buildServicesSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildRecommendedSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildCommunitySection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildTrendingSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildMarketplaceSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Text('Raabta', style: AppTextStyles.h2),
          const Spacer(),
          const ThemeToggleButton(compact: true),
          const SizedBox(width: AppSpacing.sm),
          const _HomeNotificationBell(),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _openProfileTab,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Text(
                'MS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_greeting, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text('Mohammad Sayeed', style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoChip(label: '📍 Al Khor'),
              _InfoChip(label: '🌤️ 38°C Sunny'),
              _InfoChip(label: '📅 $_formattedDate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpatLifeScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surface, Color(0xFF0F1A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '⭐ Expat Life Score',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openExpatScoreScreen,
                child: Text(
                  'View Details →',
                  style: AppTextStyles.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Center(
            child: Column(
              children: [
                Text(
                  '72',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
                    height: 1,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Growing Strong 📈',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._scoreMetrics.map(_buildScoreMetricRow),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openExpatScoreScreen,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(
                      child: Text(
                        '🤖 Improve My Score',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreMetricRow(_ScoreMetric metric) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.label, style: AppTextStyles.bodySmall),
              Text(
                '${(metric.value * 100).round()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: metric.value,
              minHeight: 4,
              backgroundColor: AppColors.background,
              color: metric.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '🤖 Today\'s AI Insights',
          subtitle: 'Personalized for you',
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: _insightsLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (_, _) => const _SkeletonBox(width: 280, height: 120),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _aiInsights.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final insight = _aiInsights[index];
                    return _AiInsightCard(
                      insight: insight,
                      onTap: () => _onAiInsightTap(index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('⚡ Quick Actions', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _quickActions.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              final action = _quickActions[index];
              return _QuickActionButton(
                action: action,
                onTap: () => _onQuickActionTap(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🛠️ All Services', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 140,
          ),
          itemCount: _features.length,
          itemBuilder: (context, index) {
            return _FeatureCardWidget(
              feature: _features[index],
              onTap: () => _onFeatureTap(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '✨ Recommended For You',
          onSeeAll: () => context.push('/jobs'),
        ),
        const SizedBox(height: AppSpacing.md),
        TabBar(
          controller: _recommendedTabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Jobs'),
            Tab(text: 'Housing'),
            Tab(text: 'Businesses'),
            Tab(text: 'Market'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: _recommendedLoading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (_, _) => const _SkeletonBox(width: 220, height: 160),
                )
              : TabBarView(
                  controller: _recommendedTabController,
                  children: [
                    _buildRecommendedJobsRow(),
                    _buildRecommendedHousingRow(),
                    _buildRecommendedBusinessesRow(),
                    _buildRecommendedMarketRow(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRecommendedJobsRow() {
    const items = [
      ('A', 'HSE Officer', '8,500 QR', '85% Match'),
      ('Q', 'Safety Manager', '12,000 QR', '78% Match'),
      ('P', 'QA Engineer', '9,200 QR', '72% Match'),
    ];
    return _buildHorizontalMiniCards(
      items.map((item) {
        return _RecommendedJobCard(
          initial: item.$1,
          title: item.$2,
          salary: item.$3,
          match: item.$4,
          onApply: () => context.push('/jobs'),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedHousingRow() {
    const items = [
      ('🏠', '2BHK · Al Khor', '2,500 QR/mo'),
      ('🛏️', '1BHK · Al Khor', '1,800 QR/mo'),
      ('🏡', 'Studio · Al Khor', '1,200 QR/mo'),
    ];
    return _buildHorizontalMiniCards(
      items.map((item) {
        return _RecommendedHousingCard(
          emoji: item.$1,
          title: item.$2,
          price: item.$3,
          onView: () => context.push('/housing'),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedBusinessesRow() {
    const items = [
      ('🍛', 'Spice Kitchen', 'Indian Restaurant'),
      ('🔧', 'Al Khor Repairs', 'Home Services'),
      ('💇', 'Style Hub', 'Salon & Spa'),
    ];
    return _buildHorizontalMiniCards(
      items.map((item) {
        return _RecommendedGenericCard(
          emoji: item.$1,
          title: item.$2,
          subtitle: item.$3,
          actionLabel: 'View',
          onAction: () => context.push('/businesses'),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedMarketRow() {
    const items = [
      ('📱', 'iPhone 14 Pro', '2,800 QR'),
      ('🚗', 'Toyota Camry', '45,000 QR'),
      ('💻', 'MacBook Air', '3,200 QR'),
    ];
    return _buildHorizontalMiniCards(
      items.map((item) {
        return _RecommendedGenericCard(
          emoji: item.$1,
          title: item.$2,
          subtitle: item.$3,
          actionLabel: 'View',
          onAction: _openMarketplace,
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalMiniCards(List<Widget> cards) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (_, index) => cards[index],
    );
  }

  Widget _buildCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '👥 Community Buzz',
          onSeeAll: _openCommunityTab,
        ),
        const SizedBox(height: AppSpacing.md),
        if (_communityLoading)
          const Column(
            children: [
              _SkeletonBox(width: double.infinity, height: 88),
              SizedBox(height: AppSpacing.md),
              _SkeletonBox(width: double.infinity, height: 88),
            ],
          )
        else
          const Column(
            children: [
              _CommunityPostCard(
                initials: 'RK',
                name: 'Rajesh Kumar',
                time: '2h ago',
                text: 'Anyone know a good CBSE school in Al Khor for Grade 5?',
                likes: 24,
                comments: 8,
                flag: '🇮🇳',
              ),
              SizedBox(height: AppSpacing.md),
              _CommunityPostCard(
                initials: 'FA',
                name: 'Fatima Al-Hassan',
                time: '5h ago',
                text: 'Free health camp this weekend at Al Khor Community Center!',
                likes: 56,
                comments: 12,
                flag: '🇶🇦',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🔥 Trending Today', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _trendingTopics.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.circle.x),
                  border: Border.all(color: AppColors.borderHighlight),
                ),
                child: Text(
                  _trendingTopics[index],
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _TrendingItemCard(
          emoji: '💼',
          title: 'HSE jobs surge in Ras Laffan',
          subtitle: '12 new listings today',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _TrendingItemCard(
          emoji: '🏠',
          title: 'Al Khor room prices drop 8%',
          subtitle: 'Best deals this month',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _TrendingItemCard(
          emoji: '💰',
          title: 'INR hits 3-month high',
          subtitle: 'Transfer window open',
        ),
      ],
    );
  }

  Widget _buildMarketplaceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '🛍️ Marketplace',
          onSeeAll: _openMarketplace,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _marketplaceCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = _marketplaceCategories[index];
              return GestureDetector(
                onTap: _openMarketplace,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        category.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
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
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MarketplaceMiniCard(
                emoji: '📱',
                title: 'Samsung S24',
                price: '1,850 QR',
                onTap: _openMarketplace,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MarketplaceMiniCard(
                emoji: '🛋️',
                title: 'Sofa Set',
                price: '900 QR',
                onTap: _openMarketplace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Data models ─────────────────────────────────────────────────────────────

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

class _QuickAction {
  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String label;
  final Color color;
}

class _AiInsight {
  const _AiInsight({
    required this.borderColor,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final Color borderColor;
  final String emoji;
  final String title;
  final String subtitle;
  final String actionLabel;
}

class _ScoreMetric {
  const _ScoreMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _MarketplaceCategory {
  const _MarketplaceCategory({
    required this.emoji,
    required this.label,
  });

  final String emoji;
  final String label;
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        );
      },
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard({required this.insight, required this.onTap});

  final _AiInsight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border(
            left: BorderSide(color: insight.borderColor, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${insight.emoji} ${insight.title}',
              style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              insight.subtitle,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              insight.actionLabel,
              style: AppTextStyles.labelLarge.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: action.color,
                shape: BoxShape.circle,
              ),
              child: Text(action.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              action.label,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCardWidget extends StatelessWidget {
  const _FeatureCardWidget({required this.feature, required this.onTap});

  final _FeatureCard feature;
  final VoidCallback onTap;

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
    final brightness = Theme.of(context).brightness;
    final family = CoreServiceColorFamily.forTitle(feature.title);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: premiumSurfaceDecoration(
          family: family,
          brightness: brightness,
          borderRadius: AppRadius.lg,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feature.emoji, style: _emojiStyle),
            const Spacer(),
            Text(
              feature.title,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 4),
            Text(
              feature.subtitle,
              style: brightness == Brightness.light
                  ? AppTextStyles.bodySmall.copyWith(
                      color: family.text(brightness),
                    )
                  : AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedJobCard extends StatelessWidget {
  const _RecommendedJobCard({
    required this.initial,
    required this.title,
    required this.salary,
    required this.match,
    required this.onApply,
  });

  final String initial;
  final String title;
  final String salary;
  final String match;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceElevated,
                child: Text(initial, style: AppTextStyles.labelLarge),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  match,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.h3, maxLines: 1),
          Text(salary, style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: const Text('Apply', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedHousingCard extends StatelessWidget {
  const _RecommendedHousingCard({
    required this.emoji,
    required this.title,
    required this.price,
    required this.onView,
  });

  final String emoji;
  final String title;
  final String price;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.md),
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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.h3, maxLines: 1),
          Text(price, style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onView,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: const Text('View', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedGenericCard extends StatelessWidget {
  const _RecommendedGenericCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const Spacer(),
          Text(title, style: AppTextStyles.h3, maxLines: 1),
          Text(subtitle, style: AppTextStyles.bodySmall, maxLines: 1),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.initials,
    required this.name,
    required this.time,
    required this.text,
    required this.likes,
    required this.comments,
    required this.flag,
  });

  final String initials;
  final String name;
  final String time;
  final String text;
  final int likes;
  final int comments;
  final String flag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceElevated,
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyLarge.copyWith(fontSize: 13)),
                    Text(time, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(flag, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('$likes', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('$comments', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendingItemCard extends StatelessWidget {
  const _TrendingItemCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontSize: 13)),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _MarketplaceMiniCard extends StatelessWidget {
  const _MarketplaceMiniCard({
    required this.emoji,
    required this.title,
    required this.price,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTextStyles.h3, maxLines: 1),
            Text(price, style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _HomeNotificationBell extends ConsumerWidget {
  const _HomeNotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadNotificationCountProvider);
    final count = unreadAsync.value ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        if (count > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: count > 9 ? 20 : 16,
              height: 16,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
