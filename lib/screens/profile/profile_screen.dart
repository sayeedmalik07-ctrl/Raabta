import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:raabta/config/app_config.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/config/referral_config.dart';
import 'package:raabta/features/referral/presentation/providers/referral_providers.dart';
import 'package:raabta/services/referral/referral_deep_links.dart';
import 'package:raabta/services/referral/referral_service.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/theme/theme_notifier.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_list_section.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/core/widgets/raabta_platform_notices_panel.dart';
import 'package:raabta/core/widgets/section_header.dart';
import 'package:raabta/features/admin/admin_access.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/home/widgets/profile_avatar.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/utils/home_time_greeting.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/features/profile/advanced/widgets/advanced_profile_card.dart';
import 'package:raabta/screens/reviews/workplace_reviews_screen.dart';
import 'package:raabta/screens/reviews/write_review_screen.dart';
import 'package:raabta/screens/profile/app_review_service.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:raabta/providers/app_update_provider.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/my_activity_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';
import 'package:raabta/screens/profile/l10n/my_activity_strings.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_draft_count_provider.dart';
import 'package:raabta/screens/profile/widgets/my_activity_pending_badge.dart';
import 'package:raabta/services/app_update_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const int _points = 250;
  static const int _nextLevelPoints = 500;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _expatScoreBootstrapStarted = false;

  static const Color _whatsappGreen = Color(0xFF25D366);

  static const List<_Achievement> _achievements = [
    _Achievement(emoji: '🌟', catalogKey: 'achievement_early_adopter', earned: true),
    _Achievement(emoji: '💼', catalogKey: 'achievement_job_seeker', earned: true),
    _Achievement(emoji: '🏠', catalogKey: 'achievement_home_hunter', earned: false),
    _Achievement(emoji: '🤝', catalogKey: 'achievement_connector', earned: false),
    _Achievement(emoji: '⭐', catalogKey: 'achievement_ambassador', earned: false),
    _Achievement(emoji: '🌍', catalogKey: 'achievement_qatar_pro', earned: false),
  ];

  static const List<_SettingsSection> _settingsSections = [
    _SettingsSection(
      sectionKey: 'section_account',
      items: [
        _SettingsItem(
          icon: Icons.pending_actions_outlined,
          settingsKey: 'settings_my_activity',
        ),
        _SettingsItem(
          icon: Icons.saved_search_outlined,
          settingsKey: 'settings_saved_searches',
        ),
        _SettingsItem(icon: Icons.person_outline, settingsKey: 'settings_edit_profile'),
        _SettingsItem(
          icon: Icons.workspace_premium_outlined,
          settingsKey: 'settings_my_subscription',
        ),
        _SettingsItem(icon: Icons.bookmark_outline, settingsKey: 'settings_saved_items'),
      ],
    ),
    _SettingsSection(
      sectionKey: 'section_quick_settings',
      items: [
        _SettingsItem(
          icon: Icons.notifications_outlined,
          settingsKey: 'settings_notifications',
        ),
        _SettingsItem(icon: Icons.language, settingsKey: 'settings_language'),
        _SettingsItem(icon: Icons.palette_outlined, settingsKey: 'settings_appearance'),
        _SettingsItem(icon: Icons.shield_outlined, settingsKey: 'settings_privacy'),
        _SettingsItem(
          icon: Icons.security_outlined,
          settingsKey: 'settings_scam_shield_status',
        ),
      ],
    ),
    _SettingsSection(
      sectionKey: 'section_raabta_tools',
      items: [
        _SettingsItem(icon: Icons.folder_outlined, settingsKey: 'settings_document_vault'),
        _SettingsItem(
          icon: Icons.restaurant_outlined,
          settingsKey: 'settings_dietary_profile',
        ),
        _SettingsItem(icon: Icons.auto_awesome_outlined, settingsKey: 'settings_ai_assistant'),
        _SettingsItem(icon: Icons.list_alt_outlined, settingsKey: 'settings_my_listings'),
      ],
    ),
    _SettingsSection(
      sectionKey: 'section_support',
      items: [
        _SettingsItem(icon: Icons.help_outline, settingsKey: 'settings_help_center'),
        _SettingsItem(icon: Icons.flag_outlined, settingsKey: 'settings_report_issue'),
        _SettingsItem(icon: Icons.star_outline, settingsKey: 'settings_rate_raabta'),
      ],
    ),
    _SettingsSection(
      sectionKey: 'section_about',
      items: [
        _SettingsItem(
          icon: Icons.privacy_tip_outlined,
          settingsKey: 'settings_privacy_policy',
        ),
        _SettingsItem(icon: Icons.description_outlined, settingsKey: 'settings_terms'),
      ],
    ),
  ];

  List<_SettingsSection> get _visibleSettingsSections {
    Iterable<_SettingsSection> sections = _settingsSections;
    if (!AppConfig.showRateApp) {
      sections = [
        for (final section in _settingsSections)
          if (section.sectionKey == 'section_support')
            _SettingsSection(
              sectionKey: section.sectionKey,
              items: [
                for (final item in section.items)
                  if (item.settingsKey != 'settings_rate_raabta') item,
              ],
            )
          else
            section,
      ];
    }
    if (!MonetizationState.showPremiumTierUi) {
      sections = [
        for (final section in sections)
          _SettingsSection(
            sectionKey: section.sectionKey,
            items: [
              for (final item in section.items)
                if (item.settingsKey != 'settings_my_subscription') item,
            ],
          ),
      ].where((section) => section.items.isNotEmpty);
    }
    return sections.toList();
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapExpatScore());
    });
  }

  Future<void> _bootstrapExpatScore() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _expatScoreBootstrapStarted) return;

    _expatScoreBootstrapStarted = true;
    try {
      final aiNotifier = ref.read(userAIProfileProvider.notifier);
      final existingProfile = ref.read(userAIProfileProvider);
      if (UserProfileOwnership.needsInit(existingProfile, user.uid)) {
        await aiNotifier.initProfile(user.uid);
      }
      final profile = ref.read(userAIProfileProvider);
      if (profile != null) {
        await ref.read(expatLifeScoreProvider.notifier).refreshIfEmpty(profile);
      }
    } catch (_) {
      _expatScoreBootstrapStarted = false;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _showComingSoon(String settingsKey) {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final label = ProfileStrings.t(settingsKey, locale);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ProfileStrings.format('snack_coming_soon', locale, params: {'label': label}),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  void _copyReferralCode(String code) {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ProfileStrings.t('snack_referral_copied', locale)),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  Future<void> _shareOnWhatsApp(String code) async {
    final uid = ref.read(currentUserProvider)?.uid;
    String shareCode = code;
    if (shareCode.isEmpty && uid != null) {
      shareCode = await ReferralService.instance.ensureReferralCode(uid) ?? '';
      ref.invalidate(referralProfileProvider);
    }
    if (shareCode.isEmpty) return;

    Share.share(
      'Join me on Raabta — check your Qatar EOSB entitlement. '
      '${ReferralDeepLinks.invite(shareCode)}',
    );
  }

  void _openExpatScore() {
    context.push('/expat-score');
  }

  void _openPremiumUpgrade() {
    if (!MonetizationState.showPremiumTierUi) return;
    context.push('/premium');
  }

  Future<void> _signOut() async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ProfileStrings.t('dialog_sign_out_title', locale)),
        content: Text(ProfileStrings.t('dialog_sign_out_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(CommonActionStrings.t('action_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ProfileStrings.t('action_sign_out', locale)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AuthSessionService.instance.signOutExplicit();
    if (!mounted) return;
    context.go('/login');
  }

  void _handleSettingsTap(_SettingsItem item) {
    if (item.isDestructive) {
      _signOut();
      return;
    }

    switch (item.route) {
      case _SettingsRoute.reviews:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorkplaceReviewsScreen()),
        );
      case _SettingsRoute.none:
        switch (item.settingsKey) {
          case 'settings_my_activity':
            context.push('/profile/my-activity');
          case 'settings_saved_searches':
            context.push('/profile/saved-searches');
          case 'settings_edit_profile':
            context.push('/profile/personal-info');
          case 'settings_my_subscription':
            _openPremiumUpgrade();
          case 'settings_saved_items':
            context.push('/marketplace');
          case 'settings_notifications':
            context.push('/profile/notifications');
          case 'settings_language':
            context.push('/profile/language');
          case 'settings_appearance':
            context.push('/profile/appearance');
          case 'settings_privacy':
            context.push('/profile/privacy');
          case 'settings_scam_shield_status':
            context.push('/scam-shield/shield');
          case 'settings_document_vault':
            context.push('/document-vault');
          case 'settings_dietary_profile':
            context.push('/dietary-profile');
          case 'settings_ai_assistant':
            context.push(
              '/ai-chat',
              extra: const {'autoSendInitialMessage': false},
            );
          case 'settings_my_listings':
            context.push('/my-posts');
          case 'settings_help_center':
            context.push('/profile/help');
          case 'settings_report_issue':
            context.push('/profile/report-issue');
          case 'settings_rate_raabta':
            if (AppConfig.showRateApp) _rateRaabta();
          case 'settings_privacy_policy':
            context.push('/profile/privacy-policy');
          case 'settings_terms':
            context.push('/profile/terms');
          default:
            _showComingSoon(item.settingsKey);
        }
    }
  }

  Future<void> _rateRaabta() async {
    final outcome = await requestAppStoreReview();
    if (!mounted) return;
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final message = switch (outcome) {
      AppReviewOutcome.success => null,
      AppReviewOutcome.notPublishedYet =>
        ProfileStrings.t('snack_rate_not_published', locale),
      AppReviewOutcome.unavailable =>
        ProfileStrings.t('snack_rate_unavailable', locale),
    };
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));

    return AnimatedAuroraBackground(
      ignoreSafeArea: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeroCard(onOpenExpatScore: _openExpatScore),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRewardsDashboard(locale),
                const SizedBox(height: AppSpacing.xxl),
                _buildAchievementsSection(locale),
                const SizedBox(height: AppSpacing.xxl),
                _buildReferralSection(locale),
                const SizedBox(height: AppSpacing.xxl),
                _buildReviewCard(context, locale),
                const SizedBox(height: AppSpacing.xxl),
                const AdvancedProfileCard(),
                const SizedBox(height: AppSpacing.xxl),
                ..._visibleSettingsSections.expand(
                  (section) => [
                    _buildSettingsGroup(section, locale),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                RaabtaPlatformNoticesPanel(locale: locale, dense: true),
                const SizedBox(height: AppSpacing.lg),
                _AppVersionFooter(locale: locale),
              ]),
            ),
          ),
        ],
      ),
      ),
    );
  }


  Widget _buildRewardsDashboard(String locale) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppSpacing.radiusMd,
      glowColor: AppColors.amberGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ProfileStrings.t('rewards_title', locale), style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_points',
                style: AppTypography.display.copyWith(
                  color: AppColors.amberGlow,
                  fontSize: 48,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  ProfileStrings.t('rewards_points', locale),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(
                label: ProfileStrings.t('rewards_explorer_badge', locale),
                color: AppColors.warning,
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
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
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
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.amberGlow,
                                      Color(0xFFFF6B00),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      ProfileStrings.format(
                        'rewards_progress',
                        locale,
                        params: {
                          'current': '$_points',
                          'target': '$_nextLevelPoints',
                          'nextLevel': ProfileStrings.t(
                            'achievement_connector',
                            locale,
                          ),
                        },
                      ),
                      style: AppTypography.bodySmall.copyWith(
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
                Expanded(
                  child: _buildRewardStatChip(
                    '🏆',
                    ProfileStrings.format(
                      'reward_stat_level',
                      locale,
                      params: {'level': '2'},
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildRewardStatChip(
                    '🎯',
                    ProfileStrings.format(
                      'reward_stat_pts',
                      locale,
                      params: {'pts': '250'},
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildRewardStatChip(
                    '👥',
                    ProfileStrings.format(
                      'reward_stat_refs',
                      locale,
                      params: {'count': '3'},
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildRewardStatChip(
                    '📝',
                    ProfileStrings.format(
                      'reward_stat_posts',
                      locale,
                      params: {'count': '7'},
                    ),
                  ),
                ),
              ],
            ),
            if (MonetizationState.showPremiumTierUi) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openPremiumUpgrade,
                  icon: const Text('💎', style: TextStyle(fontSize: 16)),
                  label: Text(
                    ProfileStrings.t('action_upgrade_premium', locale),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.amberGlow,
                    side: const BorderSide(color: AppColors.amberGlow),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showComingSoon('action_redeem_points'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amberGlow,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                    child: Text(
                      ProfileStrings.t('action_redeem_points', locale),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showComingSoon('action_earn_more'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyanGlow,
                      side: const BorderSide(color: AppColors.cyanGlow),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                    child: Text(
                      ProfileStrings.t('action_earn_more', locale),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildRewardStatChip(String emoji, String label) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      borderRadius: AppSpacing.radiusXs,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: ProfileStrings.t('section_achievements', locale)),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              return _AchievementBadge(
                achievement: _achievements[index],
                locale: locale,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection(String locale) {
    final referralAsync = ref.watch(referralProfileProvider);
    final uid = ref.watch(currentUserProvider)?.uid;

    return referralAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (profile) {
        final code = profile.referralCode ?? '';
        final successful = profile.successfulReferralsCount;
        final rewardLabel = MonetizationState.referralPremiumRewardsEnabled
            ? ReferralConfig.rewardDescription()
            : ProfileStrings.format(
                'referral_reward_ai_boost',
                locale,
                params: {
                  'extra': '${ReferralConfig.rewardAiBoostExtraQuestions}',
                  'days': '${ReferralConfig.rewardPremiumDays}',
                },
              );

        return GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          borderRadius: AppSpacing.radiusMd,
          glowColor: AppColors.cyanGlow,
          glowIntensity: 0.1,
          backgroundColor: AppColors.cyanGlow.withValues(alpha: 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ProfileStrings.t('referral_title', locale), style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ProfileStrings.format(
                  'referral_body',
                  locale,
                  params: {'reward': rewardLabel},
                ),
                style: AppTypography.body,
              ),
              if (MonetizationState.showPremiumTierUi &&
                  profile.hasActiveReferralPremium) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ProfileStrings.format(
                    'referral_premium_until',
                    locale,
                    params: {
                      'date':
                          '${profile.referralPremiumUntil!.day}/'
                          '${profile.referralPremiumUntil!.month}/'
                          '${profile.referralPremiumUntil!.year}',
                    },
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.cyanGlow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else if (profile.hasActiveReferralAiBoost) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ProfileStrings.format(
                    'referral_boost_until',
                    locale,
                    params: {
                      'date':
                          '${profile.referralAiBoostExpiresAt!.day}/'
                          '${profile.referralAiBoostExpiresAt!.month}/'
                          '${profile.referralAiBoostExpiresAt!.year}',
                      'extra': '${profile.referralAiBoostExtraQuestions}',
                    },
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.cyanGlow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (code.isNotEmpty)
                GlassCard(
                  onTap: () => _copyReferralCode(code),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  borderRadius: AppSpacing.radiusSm,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: AppColors.cyanGlow,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Icon(
                        Icons.copy_rounded,
                        color: AppColors.cyanGlow.withValues(alpha: 0.8),
                        size: 22,
                      ),
                    ],
                  ),
                )
              else if (uid != null)
                Text(
                  ProfileStrings.t('referral_generate_hint', locale),
                  style: AppTypography.bodySmall,
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                ProfileStrings.format(
                  'referral_success_count',
                  locale,
                  params: {
                    'count': '$successful',
                    'plural': successful == 1 ? '' : 's',
                  },
                ),
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: code.isEmpty && uid != null
                      ? () => _shareOnWhatsApp('')
                      : code.isNotEmpty
                          ? () => _shareOnWhatsApp(code)
                          : null,
                  icon: const Icon(Icons.share, size: 20),
                  label: Text(
                    ProfileStrings.t('action_share_invite', locale),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _whatsappGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityStatsSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: ProfileStrings.t('section_achievements', locale)),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _ActivityStatCard(
              emoji: '📝',
              value: '7',
              label: ProfileStrings.t('activity_posts', locale),
            ),
            _ActivityStatCard(
              emoji: '🏠',
              value: '3',
              label: ProfileStrings.t('activity_listings', locale),
            ),
            _ActivityStatCard(
              emoji: '❓',
              value: '12',
              label: ProfileStrings.t('activity_qas', locale),
            ),
            _ActivityStatCard(
              emoji: '👍',
              value: '45',
              label: ProfileStrings.t('activity_helpful_votes', locale),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, String locale) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppSpacing.radiusMd,
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ProfileStrings.t('review_employer_title', locale), style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ProfileStrings.t('review_employer_subtitle', locale),
            style: AppTypography.body,
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
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              ProfileStrings.t('review_browse_all', locale),
              style: const TextStyle(
                color: AppColors.cyanGlow,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WriteReviewScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanGlow,
                side: const BorderSide(color: AppColors.cyanGlow),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              child: Text(
                ProfileStrings.t('review_write', locale),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(_SettingsSection section, String locale) {
    final pendingCount = ref.watch(myActivityPendingCountProvider);
    final draftCount = ref.watch(postEngineDraftCountProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: ProfileStrings.t(section.sectionKey, locale),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassListSection(
          borderRadius: HomeCardTier.homeCardRadius,
          children: [
            for (var i = 0; i < section.items.length; i++) ...[
              _SettingsTile(
                item: section.items[i],
                label: switch (section.items[i].settingsKey) {
                  'settings_my_activity' =>
                    MyActivityStrings.t('settings_my_activity', locale),
                  'settings_saved_searches' =>
                    SavedSearchStrings.t('settings_saved_searches', locale),
                  _ => ProfileStrings.t(section.items[i].settingsKey, locale),
                },
                trailing: section.items[i].settingsKey == 'settings_my_activity'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyActivityPendingBadge(count: draftCount),
                          if (draftCount != null &&
                              draftCount > 0 &&
                              pendingCount != null &&
                              pendingCount > 0)
                            const SizedBox(width: AppSpacing.xs),
                          MyActivityPendingBadge(count: pendingCount),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      )
                    : null,
                onTap: () => _handleSettingsTap(section.items[i]),
              ),
              if (section.sectionKey == 'section_account' &&
                  section.items[i].settingsKey == 'settings_edit_profile') ...[
                _profileSettingsDivider(),
                ProfileAppUpdateSettingsRow(onOpenUpdate: _openAppUpdate),
              ],
              if (i < section.items.length - 1) _profileSettingsDivider(),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _openAppUpdate() async {
    final outcome = await AppUpdateService.openStoreListing();
    if (!mounted) return;
    if (outcome == AppUpdateOutcome.unavailable) {
      final locale = AppLocale.normalize(ref.read(userLanguageProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ProfileStrings.t('snack_store_unavailable', locale)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }
  }

  Widget _profileSettingsDivider() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: ProfileSettingsListMetrics.dividerStartInset,
      ),
      child: Divider(
        height: 1,
        color: AppColors.glassBorder.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildAppearanceTile() {
    return _AppearanceSettingsTile(onTap: () {
      HapticFeedback.selectionClick();
      context.push('/profile/appearance');
    });
  }
}


/// Home-aligned profile identity hero (glass card).
class ProfileHeroCard extends ConsumerWidget {
  const ProfileHeroCard({
    super.key,
    required this.onOpenExpatScore,
    @visibleForTesting this.expatChipLabelForTest,
  });

  static const double avatarSize = 60;

  final VoidCallback onOpenExpatScore;

  /// Avoids Firebase-backed expat providers in isolated widget tests.
  @visibleForTesting
  final String? expatChipLabelForTest;

  static String _memberSinceLabel(User? user, String locale) {
    final created = user?.metadata.creationTime;
    if (created == null) return '';
    return ProfileStrings.format(
      'member_since',
      locale,
      params: {'date': DateFormat('MMMM yyyy').format(created)},
    );
  }

  static String _expatChipLabel(WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final score = ref.watch(expatLifeScoreProvider).score;
    return ExpatScoreProfileHelper.scoreChipLabel(
      score: score?.total.round(),
      level: score?.level,
      locale: locale,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userAIProfileProvider);
    final timeGreeting = homeTimeGreetingForLocale(locale);
    final heroName =
        user != null ? ProfileDisplayHelper.profileHeroName(user) : null;
    final isSignedOut = user == null;
    final needsName = user != null && heroName == null;
    final showEditAffordance = !isSignedOut && !needsName;

    final subtitle = isSignedOut
        ? ProfileStrings.t('error_sign_in_required', locale)
        : needsName
            ? ProfileStrings.t('profile_hero_complete_name_prompt', locale)
            : profile != null
                ? ProfileDisplayHelper.profileSubtitle(profile)
                : AppShellStrings.t('default_location', locale);
    final memberSince = isSignedOut ? '' : _memberSinceLabel(user, locale);

    final brandOutline = OutlinedButton.styleFrom(
      foregroundColor: AppColors.brandFamilyMain,
      side: BorderSide(
        color: AppColors.brandFamilyMain.withValues(alpha: 0.55),
      ),
      minimumSize: const Size(48, 48),
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: GlassContainer(
        borderRadius: AppSpacing.radiusLg,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: HomeCardTier.homeCardGlowIntensity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(
                    initials: ProfileDisplayHelper.initials(user),
                    photoUrl: user?.photoURL,
                    size: avatarSize,
                    fontSize: 22,
                    ringStyle: ProfileAvatarRingStyle.brandKit,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeGreeting,
                          key: const Key('profile_hero_greeting'),
                          style: AppTypography.greeting.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (heroName != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            heroName,
                            key: const Key('profile_hero_name'),
                            style: AppTypography.title.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          key: const Key('profile_hero_subtitle'),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (memberSince.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            memberSince,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showEditAffordance)
                    IconButton(
                      key: const Key('profile_hero_edit_button'),
                      onPressed: () => context.push('/profile/personal-info'),
                      tooltip: ProfileStrings.t('settings_edit_profile', locale),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.brandFamilyMain,
                      ),
                    ),
                ],
              ),
              if (isSignedOut) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton(
                    key: const Key('profile_hero_sign_in'),
                    onPressed: () => context.go('/login'),
                    style: brandOutline,
                    child: Text(
                      ProfileStrings.t('action_go_to_sign_in', locale),
                    ),
                  ),
                ),
              ] else if (needsName) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton(
                    key: const Key('profile_hero_complete_profile'),
                    onPressed: () => context.push('/profile/personal-info'),
                    style: brandOutline,
                    child: Text(
                      ProfileStrings.t('action_complete_profile', locale),
                    ),
                  ),
                ),
              ],
              if (!isSignedOut) ...[
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  key: const Key('profile_hero_expat_chip'),
                  onTap: onOpenExpatScore,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  borderRadius: AppSpacing.radiusSm,
                  glowColor: AppColors.brandFamilyMain,
                  glowIntensity: HomeCardTier.expatScoreGlowIntensity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          expatChipLabelForTest ?? _expatChipLabel(ref),
                          style: AppTypography.subtitle.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceSettingsTile extends ConsumerWidget {
  const _AppearanceSettingsTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final themeMode = ref.watch(themeProvider);
    final subtitle = switch (themeMode) {
      ThemeMode.system => ProfileStrings.t('appearance_system_default', locale),
      ThemeMode.dark => ProfileStrings.t('appearance_dark_on', locale),
      ThemeMode.light => ProfileStrings.t('appearance_light_on', locale),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.purpleGlow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.palette_outlined,
                  size: 18,
                  color: AppColors.purpleGlow,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ProfileStrings.t('settings_appearance', locale),
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement, required this.locale});

  final _Achievement achievement;
  final String locale;

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
                      ? const LinearGradient(
                          colors: [AppColors.amberGlow, Color(0xFFFF6B00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: achievement.earned ? null : AppColors.surfaceElevated,
                  border: achievement.earned
                      ? null
                      : Border.all(color: AppColors.glassBorder),
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
                              color: AppColors.textTertiary.withValues(alpha: 0.5),
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
            ProfileStrings.t(achievement.catalogKey, locale),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: achievement.earned
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
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
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTypography.headline1.copyWith(
                  color: AppColors.cyanGlow,
                  fontSize: 26,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.item,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final _SettingsItem item;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor =
        item.isDestructive ? AppColors.error : AppColors.brandFamilyMain;
    return GlassSettingsTile(
      title: label,
      titleColor: color,
      onTap: onTap,
      leading: ProfileSettingsIconChip(
        icon: item.icon,
        iconColor: iconColor,
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: item.isDestructive ? AppColors.error : AppColors.textSecondary,
            size: 20,
          ),
    );
  }
}

/// Layout metrics for profile settings list rows (RTL-safe divider inset).
@visibleForTesting
abstract final class ProfileSettingsListMetrics {
  static const double dividerStartInset =
      AppSpacing.lg + ProfileSettingsIconChip.size + AppSpacing.md;
}

/// Compact brand-family icon chip for profile settings rows.
@visibleForTesting
class ProfileSettingsIconChip extends StatelessWidget {
  const ProfileSettingsIconChip({
    super.key,
    required this.icon,
    this.iconColor,
  });

  static const double size = 40;
  static const double radius = 14;

  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.brandFamilyMain;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

/// App update row injected into Account settings when an update is available.
@visibleForTesting
class ProfileAppUpdateSettingsRow extends ConsumerWidget {
  const ProfileAppUpdateSettingsRow({
    super.key,
    required this.onOpenUpdate,
  });

  final VoidCallback onOpenUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final update = ref.watch(appUpdateInfoProvider);
    if (update == null) return const SizedBox.shrink();

    final subtitle = update.isRequired
        ? ProfileStrings.format(
            'app_update_required',
            locale,
            params: {'version': update.latestVersion},
          )
        : ProfileStrings.format(
            'app_update_ready',
            locale,
            params: {'version': update.latestVersion},
          );
    final badgeColor =
        update.isRequired ? AppColors.warning : AppColors.brandFamilyMain;

    return Column(
      children: [
        GlassSettingsTile(
          key: const Key('profile_app_update_tile'),
          title: ProfileStrings.t('app_update_title', locale),
          subtitle: subtitle,
          onTap: onOpenUpdate,
          leading: const ProfileSettingsIconChip(
            icon: Icons.system_update_alt,
          ),
          trailing: StatusBadge(
            label: ProfileStrings.t('app_update_badge', locale),
            color: badgeColor,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: ProfileSettingsListMetrics.dividerStartInset,
          ),
          child: Divider(
            height: 1,
            color: AppColors.glassBorder.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

enum _SettingsRoute { none, reviews }

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.settingsKey,
    this.isDestructive = false,
    this.route = _SettingsRoute.none,
  });

  final IconData icon;
  final String settingsKey;
  final bool isDestructive;
  final _SettingsRoute route;
}

class _SettingsSection {
  const _SettingsSection({required this.sectionKey, required this.items});

  final String sectionKey;
  final List<_SettingsItem> items;
}

class _Achievement {
  const _Achievement({
    required this.emoji,
    required this.catalogKey,
    required this.earned,
  });

  final String emoji;
  final String catalogKey;
  final bool earned;
}

class _AppVersionFooter extends StatefulWidget {
  const _AppVersionFooter({required this.locale});

  final String locale;

  @override
  State<_AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<_AppVersionFooter> {
  Timer? _holdTimer;
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _info = info);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onHoldComplete() {
    if (!mounted) return;
    if (AdminAccess.isCurrentUserAdmin()) {
      context.push('/admin');
      return;
    }

    final uid = AuthSessionService.instance.currentUser?.uid;
    if (uid == null) return;

    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ProfileStrings.format(
            'snack_account_id_copied',
            widget.locale,
            params: {'uid': uid},
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  void _startHold() {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 2), _onHoldComplete);
  }

  void _cancelHold() {
    _holdTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final version = _info?.version ?? '…';
    final build = _info?.buildNumber ?? '…';

    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: Center(
        child: Text(
          ProfileStrings.format(
            'app_version',
            widget.locale,
            params: {'version': version, 'build': build},
          ),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
