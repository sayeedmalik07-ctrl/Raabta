import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/screens/community/ask_qatar_screen.dart';
import 'package:raabta/screens/community/events_screen.dart';
import 'package:raabta/screens/community/group_screen.dart';
import 'package:raabta/screens/community/lost_found_screen.dart';
import 'package:raabta/screens/community/news_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final Set<int> _joinedGroupIds = {0, 1};
  final Map<int, int> _unreadCounts = {0: 3, 1: 7, 6: 2};
  final Map<int, int> _newPostsCounts = {0: 23, 1: 12, 6: 5};

  static const List<_CommunityGroup> _allGroups = [
    _CommunityGroup(
      id: 0,
      emoji: '🇮🇳',
      name: 'Indians in Qatar',
      members: 45230,
      lastActivity: 'Active 2 min ago',
      recentPostPreview: 'Best school in Al Khor?',
      recentAvatars: ['RM', 'AK', 'SP'],
    ),
    _CommunityGroup(
      id: 1,
      emoji: '🇵🇰',
      name: 'Pakistanis in Qatar',
      members: 32100,
      lastActivity: 'Active 5 min ago',
      recentPostPreview: 'Iqama renewal fee update 📋',
      recentAvatars: ['AK', 'HK', 'MN'],
    ),
    _CommunityGroup(
      id: 2,
      emoji: '🇧🇩',
      name: 'Bangladeshis in Qatar',
      members: 18500,
      lastActivity: 'Active 15 min ago',
      recentPostPreview: 'Room available in Al Khor',
      recentAvatars: ['AR', 'BK', 'CD'],
    ),
    _CommunityGroup(
      id: 3,
      emoji: '🇳🇵',
      name: 'Nepalis in Qatar',
      members: 12300,
      lastActivity: 'Active 1 hour ago',
      recentPostPreview: 'Weekend trekking group?',
      recentAvatars: ['NP', 'RS', 'TK'],
    ),
    _CommunityGroup(
      id: 4,
      emoji: '🇵🇭',
      name: 'Filipinos in Qatar',
      members: 28900,
      lastActivity: 'Active 20 min ago',
      recentPostPreview: 'Filipino grocery store in Lusail',
      recentAvatars: ['FP', 'MG', 'LN'],
    ),
    _CommunityGroup(
      id: 5,
      emoji: '🇰🇪',
      name: 'Kenyans in Qatar',
      members: 5600,
      lastActivity: 'Active 3 hours ago',
      recentPostPreview: 'Kenya independence day meetup',
      recentAvatars: ['KN', 'JO', 'PW'],
    ),
    _CommunityGroup(
      id: 6,
      emoji: '⛑️',
      name: 'HSE Professionals Qatar',
      members: 8900,
      lastActivity: 'Active 30 min ago',
      recentPostPreview: 'NEBOSH course in Doha?',
      recentAvatars: ['HS', 'QE', 'SM'],
      isProfessional: true,
    ),
    _CommunityGroup(
      id: 7,
      emoji: '💼',
      name: 'Qatar Jobs Board',
      members: 67200,
      lastActivity: 'Active 1 min ago',
      recentPostPreview: 'HSE Officer jobs in Ras Laffan',
      recentAvatars: ['JB', 'HR', 'CV'],
    ),
    _CommunityGroup(
      id: 8,
      emoji: '👨‍👩‍👧',
      name: 'Family Life Qatar',
      members: 22100,
      lastActivity: 'Active 45 min ago',
      recentPostPreview: 'Best pediatrician in Al Khor?',
      recentAvatars: ['FL', 'MK', 'PR'],
    ),
    _CommunityGroup(
      id: 9,
      emoji: '⛑️',
      name: 'Safety Professionals Qatar',
      members: 6200,
      lastActivity: 'Active 10 min ago',
      recentPostPreview: 'ISO 45001 audit tips',
      recentAvatars: ['SF', 'QA', 'HS'],
      isProfessional: true,
    ),
    _CommunityGroup(
      id: 10,
      emoji: '👷',
      name: 'Engineers Qatar',
      members: 11400,
      lastActivity: 'Active 8 min ago',
      recentPostPreview: 'PE license recognition in Qatar',
      recentAvatars: ['EN', 'CE', 'ME'],
      isProfessional: true,
    ),
    _CommunityGroup(
      id: 11,
      emoji: '🚗',
      name: 'Drivers Community Qatar',
      members: 9800,
      lastActivity: 'Active 25 min ago',
      recentPostPreview: 'Light vehicle license transfer',
      recentAvatars: ['DR', 'TX', 'LV'],
      isProfessional: true,
    ),
    _CommunityGroup(
      id: 12,
      emoji: '👩‍⚕️',
      name: 'Nurses in Qatar',
      members: 7600,
      lastActivity: 'Active 18 min ago',
      recentPostPreview: 'QCHP exam preparation group',
      recentAvatars: ['NR', 'RN', 'MD'],
      isProfessional: true,
    ),
    _CommunityGroup(
      id: 13,
      emoji: '👨‍🏫',
      name: 'Teachers in Qatar',
      members: 5400,
      lastActivity: 'Active 40 min ago',
      recentPostPreview: 'CBSE vs ICSE schools comparison',
      recentAvatars: ['TC', 'ED', 'PR'],
      isProfessional: true,
    ),
  ];

  static const List<_TrendingPost> _trendingPosts = [
    _TrendingPost(
      groupName: 'Indians in Qatar',
      title: 'Best CBSE school in Al Khor?',
      reactions: 142,
      isHot: true,
    ),
    _TrendingPost(
      groupName: 'HSE Professionals Qatar',
      title: 'NEBOSH vs IOSH — which is better in Qatar?',
      reactions: 89,
      isHot: true,
    ),
    _TrendingPost(
      groupName: 'Qatar Jobs Board',
      title: 'HSE jobs surge in Ras Laffan this week',
      reactions: 256,
      isHot: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_CommunityGroup> get _yourGroups =>
      _allGroups.where((g) => _joinedGroupIds.contains(g.id)).toList();

  List<_CommunityGroup> get _professionalGroups =>
      _allGroups.where((g) => g.isProfessional).toList();

  int get _totalUnread =>
      _unreadCounts.values.fold(0, (sum, count) => sum + count);

  void _toggleJoin(int groupId) {
    setState(() {
      if (_joinedGroupIds.contains(groupId)) {
        _joinedGroupIds.remove(groupId);
        _unreadCounts.remove(groupId);
        _newPostsCounts.remove(groupId);
      } else {
        _joinedGroupIds.add(groupId);
      }
    });
  }

  void _openGroup(_CommunityGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupScreen(
          emoji: group.emoji,
          name: group.name,
          memberCount: group.members,
          isJoined: _joinedGroupIds.contains(group.id),
          onJoinToggle: () => _toggleJoin(group.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              child: Text('👥 Community', style: AppTextStyles.h1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
              child: _CommunityStatsBar(),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              dividerColor: AppColors.surfaceElevated,
              tabs: const [
                Tab(text: 'Groups'),
                Tab(text: 'Ask Qatar'),
                Tab(text: 'News'),
                Tab(text: 'Events'),
                Tab(text: 'Lost & Found'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGroupsTab(),
                  const AskQatarScreen(embedded: true),
                  const NewsScreen(embedded: true),
                  const EventsScreen(embedded: true),
                  const LostFoundScreen(embedded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      children: [
        if (_yourGroups.isNotEmpty) ...[
          Row(
            children: [
              Text('Your Groups', style: AppTextStyles.h2),
              if (_totalUnread > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppRadius.circle.x),
                  ),
                  child: Text(
                    '$_totalUnread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _yourGroups.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final group = _yourGroups[index];
                return _YourGroupCard(
                  group: group,
                  newPosts: _newPostsCounts[group.id] ?? 0,
                  hasUnread: (_unreadCounts[group.id] ?? 0) > 0,
                  onTap: () => _openGroup(group),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        SectionHeader(
          title: 'All Communities',
          seeAllLabel: 'Explore →',
          onSeeAll: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        ..._allGroups.map(
          (group) => _GroupCard(
            group: group,
            isJoined: _joinedGroupIds.contains(group.id),
            unreadCount: _unreadCounts[group.id] ?? 0,
            onJoinToggle: () => _toggleJoin(group.id),
            onTap: () => _openGroup(group),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('💼 Professional Communities', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        ..._professionalGroups.map(
          (group) => _GroupCard(
            group: group,
            isJoined: _joinedGroupIds.contains(group.id),
            unreadCount: _unreadCounts[group.id] ?? 0,
            onJoinToggle: () => _toggleJoin(group.id),
            onTap: () => _openGroup(group),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('🔥 Trending Discussions', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.md),
        ..._trendingPosts.map(
          (post) => _TrendingPostCard(post: post),
        ),
      ],
    );
  }
}

class _CommunityStatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceElevated, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌍 Qatar\'s Largest Expat Community',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _Stat(value: '45,230', label: 'Members')),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(child: _Stat(value: '234', label: 'Online Now')),
              Container(width: 1, height: 28, color: AppColors.border),
              Expanded(child: _Stat(value: '12', label: 'Active Groups')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CommunityGroup {
  const _CommunityGroup({
    required this.id,
    required this.emoji,
    required this.name,
    required this.members,
    required this.lastActivity,
    required this.recentPostPreview,
    required this.recentAvatars,
    this.isProfessional = false,
  });

  final int id;
  final String emoji;
  final String name;
  final int members;
  final String lastActivity;
  final String recentPostPreview;
  final List<String> recentAvatars;
  final bool isProfessional;
}

class _TrendingPost {
  const _TrendingPost({
    required this.groupName,
    required this.title,
    required this.reactions,
    required this.isHot,
  });

  final String groupName;
  final String title;
  final int reactions;
  final bool isHot;
}

class _YourGroupCard extends StatelessWidget {
  const _YourGroupCard({
    required this.group,
    required this.newPosts,
    required this.hasUnread,
    required this.onTap,
  });

  final _CommunityGroup group;
  final int newPosts;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surfaceElevated, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 40)),
                const Spacer(),
                if (hasUnread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              group.name,
              style: AppTextStyles.h3.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (newPosts > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '$newPosts new posts',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.isJoined,
    required this.unreadCount,
    required this.onJoinToggle,
    required this.onTap,
  });

  final _CommunityGroup group;
  final bool isJoined;
  final int unreadCount;
  final VoidCallback onJoinToggle;
  final VoidCallback onTap;

  static String _formatMembers(int count) {
    return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Text(group.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${_formatMembers(group.members)} members',
                        style: AppTextStyles.bodySmall,
                      ),
                      Text(group.lastActivity, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isJoined && unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.circle.x),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: onJoinToggle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isJoined ? AppColors.textMuted : AppColors.primary,
                          side: BorderSide(
                            color: isJoined ? AppColors.textMuted : AppColors.primary,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          isJoined ? '✓ Joined' : 'Join',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                ...group.recentAvatars.take(3).map(
                  (initials) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.surfaceElevated,
                      child: Text(
                        initials,
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    group.recentPostPreview,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingPostCard extends StatelessWidget {
  const _TrendingPostCard({required this.post});

  final _TrendingPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (post.isHot)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'HOT',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.groupName, style: AppTextStyles.bodySmall),
                Text(
                  post.title,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '❤️ ${post.reactions}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
