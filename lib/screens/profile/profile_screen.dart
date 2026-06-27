import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/screens/expat_score/expat_score_screen.dart';
import 'package:raabta/screens/monetization/premium_subscription_screen.dart';
import 'package:raabta/screens/reviews/workplace_reviews_screen.dart';
import 'package:raabta/screens/reviews/write_review_screen.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const String _referralCode = 'SAYEED2025';
  static const int _points = 250;
  static const int _nextLevelPoints = 500;
  static const int _referralsJoined = 3;
  static const int _referralGoal = 5;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  static const Color _whatsappGreen = Color(0xFF25D366);

  static const List<_Achievement> _achievements = [
    _Achievement(emoji: '🌟', title: 'Early Adopter', earned: true),
    _Achievement(emoji: '💼', title: 'Job Seeker', earned: true),
    _Achievement(emoji: '🏠', title: 'Home Hunter', earned: false),
    _Achievement(emoji: '🤝', title: 'Connector', earned: false),
    _Achievement(emoji: '⭐', title: 'Ambassador', earned: false),
    _Achievement(emoji: '🌍', title: 'Qatar Pro', earned: false),
  ];

  static const List<_LeaderboardEntry> _leaderboard = [
    _LeaderboardEntry(rank: 1, name: 'Ahmed K.', refs: 12),
    _LeaderboardEntry(rank: 2, name: 'Priya S.', refs: 9),
    _LeaderboardEntry(rank: 3, name: 'James M.', refs: 7),
  ];

  static const List<_SettingsSection> _settingsSections = [
    _SettingsSection(
      title: 'Account',
      items: [
        _SettingsItem(icon: Icons.person_outline, label: 'Edit Profile'),
        _SettingsItem(icon: Icons.language, label: 'Change Language'),
        _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications'),
      ],
    ),
    _SettingsSection(
      title: 'Activity',
      items: [
        _SettingsItem(icon: Icons.list_alt_outlined, label: 'My Listings'),
        _SettingsItem(icon: Icons.bookmark_outline, label: 'Saved Items'),
        _SettingsItem(
          icon: Icons.rate_review_outlined,
          label: 'My Reviews',
          route: _SettingsRoute.reviews,
        ),
      ],
    ),
    _SettingsSection(
      title: 'Support',
      items: [
        _SettingsItem(icon: Icons.help_outline, label: 'Help Center'),
        _SettingsItem(icon: Icons.flag_outlined, label: 'Report Issue'),
        _SettingsItem(icon: Icons.star_outline, label: 'Rate Raabta'),
      ],
    ),
    _SettingsSection(
      title: 'Legal',
      items: [
        _SettingsItem(icon: Icons.privacy_tip_outlined, label: 'Privacy'),
        _SettingsItem(icon: Icons.description_outlined, label: 'Terms'),
      ],
    ),
    _SettingsSection(
      title: 'Danger',
      items: [
        _SettingsItem(
          icon: Icons.logout,
          label: 'Sign Out',
          isDestructive: true,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  void _copyReferralCode() {
    Clipboard.setData(const ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code copied!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  void _shareOnWhatsApp() {
    Share.share(
      'Join me on Raabta — Qatar\'s largest expat community! '
      'Use my code $_referralCode to get started. '
      'https://raabta.app/invite/$_referralCode',
    );
  }

  void _openExpatScore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExpatScoreScreen()),
    );
  }

  void _openPremiumUpgrade() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PremiumSubscriptionScreen(),
      ),
    );
  }

  void _handleSettingsTap(_SettingsItem item) {
    if (item.isDestructive) {
      _showComingSoon('Sign Out');
      return;
    }

    switch (item.route) {
      case _SettingsRoute.reviews:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorkplaceReviewsScreen()),
        );
      case _SettingsRoute.none:
        if (item.label == 'Change Language') {
          context.push('/language');
        } else if (item.label == 'Notifications') {
          context.push('/notification-settings');
        } else if (item.label == 'My Listings') {
          context.push('/housing');
        } else if (item.label == 'Saved Items') {
          context.push('/marketplace');
        } else {
          _showComingSoon(item.label);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroProfileCard(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRewardsDashboard(),
                const SizedBox(height: AppSpacing.xxl),
                _buildAchievementsSection(),
                const SizedBox(height: AppSpacing.xxl),
                _buildReferralSection(),
                const SizedBox(height: AppSpacing.xxl),
                _buildActivityStatsSection(),
                const SizedBox(height: AppSpacing.xxl),
                _buildReviewCard(context),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(title: '⚙️ Quick Settings'),
                const SizedBox(height: AppSpacing.md),
                ..._settingsSections.expand(
                  (section) => [
                    _buildSettingsGroup(section),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceElevated,
            AppColors.surface,
            AppColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPatternPainter(
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      _buildGradientAvatar(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Mohammad Sayeed',
                        style: AppTextStyles.h1.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '🇮🇳 Indian · Al Khor, Qatar',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Member since June 2025',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GestureDetector(
                        onTap: _openExpatScore,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '⭐ 72 · Growing Strong',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: OutlinedButton(
                      onPressed: () => _showComingSoon('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientAvatar() {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
        ),
        alignment: Alignment.center,
        child: const Text(
          'MS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsDashboard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: AppColors.goldGradient,
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg - 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⭐ Raabta Rewards', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$_points',
                  style: AppTextStyles.scoreNumber.copyWith(
                    color: AppColors.gold,
                    fontSize: 48,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    'points',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Explorer 🗺️',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: SizedBox(
                        height: 10,
                        child: Stack(
                          children: [
                            Container(color: AppColors.background),
                            FractionallySizedBox(
                              widthFactor: (_points / _nextLevelPoints) *
                                  _progressAnimation.value,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.goldGradient,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$_points / $_nextLevelPoints to reach Connector',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _buildRewardStatChip('🏆', 'Level 2')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildRewardStatChip('🎯', '250 pts')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildRewardStatChip('👥', '3 Refs')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildRewardStatChip('📝', '7 Posts')),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openPremiumUpgrade,
                icon: const Text('💎', style: TextStyle(fontSize: 16)),
                label: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showComingSoon('Redeem Points'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text(
                      'Redeem Points',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showComingSoon('Earn More'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text(
                      'Earn More',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardStatChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '🏆 Achievements'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              return _AchievementBadge(achievement: _achievements[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👥 Invite & Earn', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Earn 50 points for each friend who joins',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: _copyReferralCode,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderHighlight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _referralCode,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Icon(
                    Icons.copy_rounded,
                    color: AppColors.primary.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                '$_referralsJoined / $_referralGoal friends invited',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: _referralsJoined / _referralGoal,
              minHeight: 6,
              backgroundColor: AppColors.background,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Refer ${_referralGoal - _referralsJoined} more to unlock Premium for free!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _shareOnWhatsApp,
              icon: const Icon(Icons.share, size: 20),
              label: const Text(
                '📤 Share on WhatsApp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _whatsappGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '🏆 Top Referrers This Month',
            style: AppTextStyles.h3.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._leaderboard.map(_buildLeaderboardRow),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(_LeaderboardEntry entry) {
    final rankColors = [
      AppColors.gold,
      AppColors.textSecondary,
      const Color(0xFFCD7F32),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankColors[entry.rank - 1].withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                color: rankColors[entry.rank - 1],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              entry.name,
              style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
            ),
          ),
          Text(
            '${entry.refs} refs',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '📊 Your Activity'),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.6,
          children: const [
            _ActivityStatCard(emoji: '📝', value: '7', label: 'Posts'),
            _ActivityStatCard(emoji: '🏠', value: '3', label: 'Listings'),
            _ActivityStatCard(emoji: '❓', value: '12', label: 'Q&As answered'),
            _ActivityStatCard(emoji: '👍', value: '45', label: 'Helpful votes'),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📝 Review an Employer', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Share your experience anonymously',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorkplaceReviewsScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text(
              'Browse all reviews →',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WriteReviewScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text(
                'Write a Review',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(_SettingsSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            section.title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: section.title == 'Danger'
                  ? AppColors.error.withValues(alpha: 0.7)
                  : AppColors.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++) ...[
                _SettingsTile(
                  item: section.items[i],
                  onTap: () => _handleSettingsTap(section.items[i]),
                ),
                if (i < section.items.length - 1)
                  Divider(
                    height: 1,
                    indent: 52,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: achievement.earned
                      ? AppColors.goldGradient
                      : null,
                  color: achievement.earned ? null : AppColors.surfaceElevated,
                  border: achievement.earned
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  alignment: Alignment.center,
                  child: achievement.earned
                      ? Text(
                          achievement.emoji,
                          style: const TextStyle(fontSize: 32),
                        )
                      : ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Text(
                            achievement.emoji,
                            style: TextStyle(
                              fontSize: 32,
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                ),
              ),
              if (!achievement.earned)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🔒', style: TextStyle(fontSize: 22)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: achievement.earned
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
              fontWeight:
                  achievement.earned ? FontWeight.w600 : FontWeight.w400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStatCard extends StatelessWidget {
  const _ActivityStatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primary,
              fontSize: 26,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item, required this.onTap});

  final _SettingsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        item.icon,
        color: item.isDestructive ? AppColors.error : AppColors.primary,
        size: 22,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: item.isDestructive ? AppColors.error : AppColors.textSecondary,
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 2,
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 24.0;
    const radius = 1.5;
    for (var x = spacing / 2; x < size.width; x += spacing) {
      for (var y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _SettingsRoute { none, reviews }

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.route = _SettingsRoute.none,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;
  final _SettingsRoute route;
}

class _SettingsSection {
  const _SettingsSection({required this.title, required this.items});

  final String title;
  final List<_SettingsItem> items;
}

class _Achievement {
  const _Achievement({
    required this.emoji,
    required this.title,
    required this.earned,
  });

  final String emoji;
  final String title;
  final bool earned;
}

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.refs,
  });

  final int rank;
  final String name;
  final int refs;
}
