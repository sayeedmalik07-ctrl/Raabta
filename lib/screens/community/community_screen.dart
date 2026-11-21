import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/civic_report/presentation/screens/civic_report_screen.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/hub/hub_premium_surface.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_advanced_filter_toggle.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/core/navigation/shell_chrome_scope.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/models/community_nationality_suggestion.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/services/community_pulse_service.dart';
import 'package:raabta/features/buddy/presentation/widgets/buddy_find_entry_card.dart';
import 'package:raabta/features/buddy/providers/buddy_providers.dart';
import 'package:raabta/features/community/widgets/community_nationality_suggestion_card.dart';
import 'package:raabta/features/community/widgets/community_pulse_strip.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/community/widgets/community_why_seeing_affordance.dart';
import 'package:raabta/features/community/utils/community_visibility_reasons.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/screens/community/widgets/community_section_primitives.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/community/ask_qatar_screen.dart';
import 'package:raabta/screens/community/events_screen.dart';
import 'package:raabta/screens/community/group_screen.dart';
import 'package:raabta/screens/community/lost_found_screen.dart';
import 'package:raabta/screens/community/news_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  static const _sectionCount = 6;

  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sectionCount, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Set<int> get _joinedGroupIds =>
      ref.watch(communityMembershipProvider).value ?? {0, 1};

  List<CommunityGroupDefinition> get _filteredGroups {
    if (_searchQuery.isEmpty) return CommunityGroupRegistry.all;
    return CommunityGroupRegistry.all
        .where((g) => g.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  List<CommunityGroupDefinition> get _yourGroups =>
      _filteredGroups.where((g) => _joinedGroupIds.contains(g.intId)).toList();

  List<CommunityGroupDefinition> get _professionalGroups =>
      _filteredGroups.where((g) => g.isProfessional).toList();

  void _toggleJoin(int groupId) {
    ref.read(communityMembershipProvider.notifier).toggle(groupId);
  }

  void _openGroup(CommunityGroupDefinition group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupScreen(
          groupId: group.intId,
          emoji: group.emoji,
          name: group.name,
          memberCount: group.members,
          isJoined: _joinedGroupIds.contains(group.intId),
          onJoinToggle: () => _toggleJoin(group.intId),
        ),
      ),
    );
  }

  Map<String, GroupPost> _latestPostByGroup(List<GroupPost> posts) {
    final map = <String, GroupPost>{};
    for (final post in posts) {
      map.putIfAbsent(post.groupId, () => post);
    }
    return map;
  }

  int _recentPostCount(String groupId, List<GroupPost> posts) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return posts
        .where(
          (p) => p.groupId == groupId && (p.createdAt?.isAfter(cutoff) ?? false),
        )
        .length;
  }

  List<GroupPost> _filterPosts(List<GroupPost> posts) {
    if (_searchQuery.isEmpty) return posts;
    return posts.where((post) {
      final text = post.text.toLowerCase();
      final groupName =
          CommunityGroupRegistry.byId(post.groupId)?.name.toLowerCase() ?? '';
      return text.contains(_searchQuery) || groupName.contains(_searchQuery);
    }).toList();
  }

  Future<void> _refreshCommunityData() async {
    ref.invalidate(communityMembershipProvider);
    ref.invalidate(recentGroupPostsProvider);
    ref.invalidate(trendingGroupPostsProvider);
    ref.invalidate(communityPulseProvider);
    ref.invalidate(communityNationalitySuggestionProvider);
    CommunityPulseService.clearClientCache();
    await Future.wait([
      ref.read(recentGroupPostsProvider.future),
      ref.read(trendingGroupPostsProvider.future),
      ref.read(communityPulseProvider.future),
    ]);
  }

  void _openPostEntry() {
    _tabController.animateTo(1);
  }

  void _toggleGroupsSearchFocus() {
    if (_tabController.index == 1) {
      _tabController.animateTo(0);
    } else {
      _tabController.animateTo(1);
    }
  }

  static const _landingHorizontalPadding = EdgeInsets.fromLTRB(
    AppSpacing.xl,
    AppSpacing.sm,
    AppSpacing.xl,
    0,
  );

  Widget _buildHubSearchRow(String locale) {
    final groupsFocus = _tabController.index == 1;
    return Padding(
      padding: _landingHorizontalPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: HubLayoutTokens.searchMinHeight,
              ),
              child: TextField(
                controller: _searchController,
                style: AppTypography.subtitle,
                textInputAction: TextInputAction.search,
                decoration: hubSearchInputDecoration(
                  hintText: groupsFocus
                      ? CommunityStrings.t(
                          'community_search_groups_hint',
                          locale,
                        )
                      : CommunityStrings.t(
                          'community_search_hub_hint',
                          locale,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          HubAdvancedFilterToggle(
            expanded: groupsFocus,
            onToggle: _toggleGroupsSearchFocus,
            semanticsLabel: CommunityStrings.t(
              'community_hub_groups_filter_semantics',
              locale,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedAuroraBackground(
      enableAnimation: !reduceMotion,
      ignoreSafeArea: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: hubPostFabWhenAllowed(
          context,
          onPressed: _openPostEntry,
          tooltip: CommunityStrings.t('community_post_fab_tooltip', locale),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HubLandingHeader(
                title: CommunityStrings.t('community_hub_title', locale),
                subtitle: CommunityStrings.t('community_hub_subtitle', locale),
                showBack: false,
                onBack: () => context.pop(),
              ),
              _buildHubSearchRow(locale),
              const Padding(
                padding: _landingHorizontalPadding,
                child: CommunityPulseStrip(),
              ),
              Padding(
                padding: _landingHorizontalPadding,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: buildHubFilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommunityHubIcons.actionGlyph(
                          Icons.report_outlined,
                          color: AppColors.brandFamilyMain,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          CommunityStrings.t(
                            'community_civic_report_chip',
                            locale,
                          ),
                        ),
                      ],
                    ),
                    selected: false,
                    onSelected: (_) =>
                        context.push(CivicReportScreen.route),
                  ),
                ),
              ),
              _buildSectionTabs(locale),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFeedTab(locale),
                    _buildGroupsTab(locale),
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
      ),
    );
  }

  Widget _buildSectionTabs(String locale) {
    final labels = [
      CommunityStrings.t('community_tab_feed', locale),
      CommunityStrings.t('community_tab_groups', locale),
      CommunityStrings.t('community_tab_ask_qatar', locale),
      CommunityStrings.t('community_tab_news', locale),
      CommunityStrings.t('community_tab_events', locale),
      CommunityStrings.t('community_tab_lost_found', locale),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SizedBox(
        height: HubLayoutTokens.filterChipHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          itemCount: labels.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            return buildHubFilterChip(
              label: Text(labels[index]),
              selected: _tabController.index == index,
              onSelected: (_) => _tabController.animateTo(index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedTab(String locale) {
    final trendingAsync = ref.watch(trendingGroupPostsProvider);

    return RefreshIndicator(
      color: AppColors.brandFamilyMain,
      onRefresh: _refreshCommunityData,
      child: trendingAsync.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: const [
            HubLoadingPlaceholder(
              height: 160,
              width: 400,
              silhouette: HubLoadingSilhouette.postCard,
            ),
          ],
        ),
        error: (_, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            GlassEmptyState(
              accent: GlassEmptyStateAccent.teal,
              icon: Icons.cloud_off_outlined,
              title: CommunityStrings.t('community_trending_unavailable', locale),
              description: CommunityStrings.t(
                'community_trending_unavailable_hint',
                locale,
              ),
            ),
          ],
        ),
        data: (trending) {
          final posts = _filterPosts(trending);
          if (posts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                GlassEmptyState(
                  accent: GlassEmptyStateAccent.teal,
                  icon: Icons.forum_outlined,
                  title: CommunityStrings.t(
                    'community_feed_empty_title',
                    locale,
                  ),
                  description: CommunityStrings.t(
                    'community_trending_empty_hint',
                    locale,
                  ),
                  actionLabel: CommunityStrings.t(
                    'community_feed_empty_cta',
                    locale,
                  ),
                  onAction: () => _tabController.animateTo(1),
                ),
                HubFeedFooterNotice(locale: locale),
              ],
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            children: [
              for (final post in posts)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildHubPostCard(context, post, locale),
                ),
              HubFeedFooterNotice(locale: locale),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHubPostCard(
    BuildContext context,
    GroupPost post,
    String locale,
  ) {
    final group = CommunityGroupRegistry.byId(post.groupId);
    final groupName = group?.name ??
        CommunityStrings.t('community_fallback_group', locale);
    final contextLine =
        '$groupName · ${communityRelativeTime(post.createdAt, locale)}';
    final visibility = CommunityVisibilityInput(
      relevantGroupIds: post.relevantGroupIds,
      likeCount: post.likes,
      commentCount: post.commentCount,
    );
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);
    final metaLine = CommunityStrings.format(
      'community_post_meta_reactions',
      locale,
      params: {
        'comments': '${post.commentCount}',
        'likes': '${post.likes}',
      },
    );
    final whyLabel = CommunityStrings.t('community_why_seeing_link', locale);

    return HubPostCard(
      authorName: post.authorDisplayName,
      authorInitial: post.authorInitials,
      sectionContextLine: contextLine,
      trustTierBadge: (label: trustLabel, tier: HubContentTrustTier.community),
      body: post.text,
      metaLine: metaLine,
      whySeeingLabel: whyLabel,
      onWhySeeingTap: () =>
          CommunityWhySeeingAffordance.showForInput(context, ref, visibility),
      onTap: group != null ? () => _openGroup(group) : null,
    );
  }

  Widget _buildGroupsTab(String locale) {
    final recentAsync = ref.watch(recentGroupPostsProvider);
    final natSuggestionAsync = ref.watch(communityNationalitySuggestionProvider);

    return RefreshIndicator(
      color: AppColors.brandFamilyMain,
      onRefresh: _refreshCommunityData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          _BuddyFindEntrySection(locale: locale),
          const SizedBox(height: AppSpacing.md),
          natSuggestionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (view) => CommunityNationalitySuggestionCard(
              view: view,
              locale: locale,
              onJoinGroup: () {
                final group = view.group;
                if (group == null) return;
                if (!_joinedGroupIds.contains(group.intId)) {
                  _toggleJoin(group.intId);
                }
                _openGroup(group);
              },
              onAskQatar: () => _tabController.animateTo(2),
              onDismiss: () =>
                  ref.invalidate(communityNationalitySuggestionProvider),
            ),
          ),
          if (natSuggestionAsync.valueOrNull?.kind !=
              CommunityNationalitySuggestionKind.hidden)
            const SizedBox(height: AppSpacing.md),
          if (_yourGroups.isNotEmpty) ...[
            CommunitySectionPrimitives.sectionHeader(
              overline:
                  CommunityStrings.t('community_section_joined_overline', locale),
              title:
                  CommunityStrings.t('community_section_your_groups', locale),
              leadingIcon: Icons.groups_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            recentAsync.when(
              loading: () => const SizedBox(
                height: 168,
                child: HubLoadingPlaceholder(
                  height: 168,
                  width: 200,
                  silhouette: HubLoadingSilhouette.postCard,
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (recent) {
                return SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _yourGroups.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final group = _yourGroups[index];
                      final newPosts = _recentPostCount(group.id, recent);
                      return _YourGroupHubCard(
                        group: group,
                        newPosts: newPosts,
                        latestPreview:
                            _latestPostByGroup(recent)[group.id]?.text,
                        onTap: () => _openGroup(group),
                        locale: locale,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          CommunitySectionPrimitives.sectionHeader(
            overline:
                CommunityStrings.t('community_section_discover_overline', locale),
            title:
                CommunityStrings.t('community_section_all_communities', locale),
            subtitle: CommunityStrings.format(
              'community_groups_count',
              locale,
              params: {'count': '${_filteredGroups.length}'},
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_filteredGroups.isEmpty)
            GlassEmptyState(
              accent: GlassEmptyStateAccent.teal,
              icon: Icons.search_off,
              title: CommunityStrings.t('community_empty_no_groups', locale),
              description: CommunityStrings.t(
                'community_empty_no_groups_hint',
                locale,
              ),
            )
          else
            recentAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: HubLoadingPlaceholder(
                  height: 120,
                  width: 360,
                  silhouette: HubLoadingSilhouette.postCard,
                ),
              ),
              error: (e, _) => GlassEmptyState(
                accent: GlassEmptyStateAccent.teal,
                icon: Icons.cloud_off_outlined,
                title: CommunityStrings.t('community_err_load_groups', locale),
                description: CommunityStrings.t(
                  'community_err_load_groups_hint',
                  locale,
                ),
              ),
              data: (recent) {
                final latest = _latestPostByGroup(recent);
                return Column(
                  children: _filteredGroups
                      .map(
                        (group) => _GroupHubCard(
                          group: group,
                          isJoined: _joinedGroupIds.contains(group.intId),
                          latestPreview: latest[group.id]?.text,
                          lastActivity: communityRelativeTime(
                            latest[group.id]?.createdAt,
                            locale,
                          ),
                          onJoinToggle: () => _toggleJoin(group.intId),
                          onTap: () => _openGroup(group),
                          locale: locale,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          const SizedBox(height: AppSpacing.xxl),
          CommunitySectionPrimitives.sectionHeader(
            overline:
                CommunityStrings.t('community_section_career_overline', locale),
            title:
                CommunityStrings.t('community_section_professional', locale),
            leadingIcon: Icons.work_outline_rounded,
            leadingVariant: HomeIconBadgeVariant.exploreBrand,
          ),
          const SizedBox(height: AppSpacing.md),
          ..._professionalGroups.map(
            (group) => _GroupHubCard(
              group: group,
              isJoined: _joinedGroupIds.contains(group.intId),
              onJoinToggle: () => _toggleJoin(group.intId),
              onTap: () => _openGroup(group),
              locale: locale,
            ),
          ),
          HubFeedFooterNotice(locale: locale),
        ],
      ),
    );
  }
}

class _YourGroupHubCard extends StatelessWidget {
  const _YourGroupHubCard({
    required this.group,
    required this.newPosts,
    required this.onTap,
    required this.locale,
    this.latestPreview,
  });

  final CommunityGroupDefinition group;
  final int newPosts;
  final VoidCallback onTap;
  final String locale;
  final String? latestPreview;

  @override
  Widget build(BuildContext context) {
    final glowIntensity = newPosts > 0
        ? HubPremiumSurface.brandGlowIntensity
        : HubPremiumSurface.brandGlowIntensity * 0.5;

    return SizedBox(
      width: 200,
      height: 168,
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: HubPremiumSurface.summaryCardRadius,
        backgroundColor: HubPremiumSurface.brandFamilyTint(),
        glowColor: communityHubAccent,
        glowIntensity: glowIntensity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.emoji, style: const TextStyle(fontSize: 36)),
            const Spacer(),
            Text(
              group.name,
              style: AppTypography.title.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (latestPreview != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                latestPreview!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (newPosts > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              StatusBadge(
                label: CommunityStrings.format(
                  'community_new_posts',
                  locale,
                  params: {'count': '$newPosts'},
                ),
                color: AppColors.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupHubCard extends StatelessWidget {
  const _GroupHubCard({
    required this.group,
    required this.isJoined,
    required this.onJoinToggle,
    required this.onTap,
    required this.locale,
    this.latestPreview,
    this.lastActivity,
  });

  final CommunityGroupDefinition group;
  final bool isJoined;
  final VoidCallback onJoinToggle;
  final VoidCallback onTap;
  final String locale;
  final String? latestPreview;
  final String? lastActivity;

  static String _formatMembers(int count) {
    return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final members = CommunityStrings.format(
      'community_members_count',
      locale,
      params: {'count': _formatMembers(group.members)},
    );
    final sectionParts = <String>[members];
    if (lastActivity != null && lastActivity!.isNotEmpty) {
      sectionParts.add(lastActivity!);
    }
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);
    final joinLabel = isJoined
        ? CommunityStrings.t('community_joined', locale)
        : CommunityStrings.t('community_join', locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: HubPostCard(
        onTap: onTap,
        authorName: group.name,
        authorInitial: group.emoji,
        sectionContextLine: sectionParts.join(' · '),
        trustTierBadge: (
          label: trustLabel,
          tier: HubContentTrustTier.community,
        ),
        body: latestPreview ?? '',
        maxBodyLines: latestPreview != null ? 2 : 1,
        overflow: buildHubChoiceChip(
          label: Text(
            joinLabel,
            style: const TextStyle(fontSize: 11),
          ),
          selected: isJoined,
          onSelected: (_) => onJoinToggle(),
        ),
      ),
    );
  }
}

class _BuddyFindEntrySection extends ConsumerWidget {
  const _BuddyFindEntrySection({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissedAsync = ref.watch(buddyEntryCardDismissedProvider);
    return dismissedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (dismissed) {
        if (dismissed) return const SizedBox.shrink();
        return BuddyFindEntryCard(
          locale: locale,
          onDismissed: () =>
              ref.invalidate(buddyEntryCardDismissedProvider),
        );
      },
    );
  }
}
