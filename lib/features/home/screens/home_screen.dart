import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart' as glass;
import 'package:raabta/core/spacing/app_spacing.dart' as core_spacing;
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/navigation/floating_nav_bar.dart';
import 'package:raabta/core/navigation/shell_chrome_scope.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';
import 'package:raabta/features/home/providers/expat_score_advice_provider.dart';
import 'package:raabta/features/home/utils/home_ai_assistant_action_resolver.dart';
import 'package:raabta/features/home/utils/home_ai_feed_utils.dart';
import 'package:raabta/core/utils/profile_display_helper.dart';
import 'package:raabta/features/home/widgets/animated_search_entry.dart';
import 'package:raabta/features/home/l10n/home_profile_strings.dart';
import 'package:raabta/features/home/providers/home_doha_day_part_provider.dart';
import 'package:raabta/features/home/widgets/home_doha_collapsing_header.dart';
import 'package:raabta/features/home/widgets/home_doha_header_choreography.dart';
import 'package:raabta/features/home/widgets/home_profile_popover.dart';
import 'package:raabta/features/home/widgets/home_glance_row.dart';
import 'package:raabta/features/home/widgets/home_currency_rail_zone.dart';
import 'package:raabta/features/home/widgets/home_ramadan_seasonal_card.dart';
import 'package:raabta/features/ramadan/ramadan_season.dart';
import 'package:raabta/features/concierge_90_day/presentation/widgets/concierge_widgets.dart';
import 'package:raabta/features/home/widgets/home_daily_essentials_zone.dart';
import 'package:raabta/features/home/utils/home_personalization_resolver.dart';
import 'package:raabta/features/home/widgets/home_trust_safety_zone.dart';
import 'package:raabta/features/home/widgets/home_truth_engine_reveal_listener.dart';
import 'package:raabta/features/home/widgets/home_services_strip_zone.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_qatar_life_zone.dart';
import 'package:raabta/features/home/widgets/home_for_you_zone.dart';
import 'package:raabta/core/design/home_glass_legibility_tokens.dart';
import 'package:raabta/features/home/widgets/home_page_grain_layer.dart';
import 'package:raabta/features/home/widgets/home_search_with_ai_row.dart';
import 'package:raabta/features/home/widgets/home_lazy_section.dart';
import 'package:raabta/features/home/data/home_ai_orb_coach_mark_prefs.dart';
import 'package:raabta/features/home/widgets/home_ai_orb_coach_mark.dart';
import 'package:raabta/features/home/widgets/home_floating_ai_assistant.dart';
import 'package:raabta/core/navigation/post_vertical_menu.dart';
import 'package:raabta/core/navigation/shell_post_center_action.dart';
import 'package:raabta/core/navigation/shell_post_entry.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/presentation/post_draft_relocated_snackbar.dart';
import 'package:raabta/features/home/providers/life_events_providers.dart';
import 'package:raabta/features/home/providers/life_intelligence_providers.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_awareness_providers.dart';
import 'package:raabta/features/home/providers/life_intelligence_push_providers.dart';
import 'package:raabta/features/home/widgets/home_today_supplementary_zone.dart';
import 'package:raabta/features/home/widgets/home_today_zone.dart';
import 'package:raabta/features/home/utils/home_responsive_layout.dart';
import 'package:raabta/features/home/utils/home_time_greeting.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/providers/notification_providers.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/screens/community/community_screen.dart';
import 'package:raabta/screens/profile/profile_screen.dart';
import 'package:raabta/screens/visa/visa_screen.dart';

/// Home dashboard — v2 layout: hero, today, shortcuts, for you, explore.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.initialTab = 0,
    this.initialShellTab,
    this.openAiChatOnLaunch = false,
  });

  /// Legacy `/home?tab=` query index (see [ShellNavConfig.resolveLegacyHomeTabQuery]).
  final int initialTab;

  /// Optional shell tab from `/home?shell=documents` (not legacy numeric indices).
  final ShellTab? initialShellTab;
  final bool openAiChatOnLaunch;

  /// Shell body inset clearing nav bar + raised center Post control.
  @visibleForTesting
  static double shellBodyBottomClearance() {
    return PostVerticalMenu.fabBottomInset() +
        PostVerticalMenu.navOverlap +
        PostVerticalMenu.mainButtonSize +
        core_spacing.AppSpacing.sm;
  }

  /// Extra feed inset above the floating nav (D5 — safe area counted separately).
  @visibleForTesting
  static const homeFeedBottomClearanceExtra = 16.0;

  /// Home scroll padding when content extends under the floating nav + Post FAB.
  @visibleForTesting
  static double homeScrollBottomPadding(BuildContext context) {
    return shellBodyBottomClearance() +
        MediaQuery.paddingOf(context).bottom +
        homeFeedBottomClearanceExtra;
  }

  /// Height of the non-interactive bottom fade on Home (scroll-under-nav).
  @visibleForTesting
  static double homeBottomScrimHeight(BuildContext context) {
    return homeScrollBottomPadding(context) +
        core_spacing.AppSpacing.navBottomMargin +
        core_spacing.AppSpacing.navHeight;
  }

  @visibleForTesting
  static bool usesHomeScrollUnderNav({
    required ShellTab currentTab,
    required bool showBottomNav,
  }) {
    return currentTab == ShellTab.home && showBottomNav;
  }

  /// Bottom fade behind the floating nav (all shell tabs with nav visible).
  @visibleForTesting
  static bool showShellBottomScrim({required bool showBottomNav}) {
    return showBottomNav;
  }


  /// Spacer heights inserted in the lazy personalized block (Ramadan + lazy zones).
  @visibleForTesting
  static List<double> personalizedBlockSpacerHeights({
    required bool includeRamadanCard,
  }) {
    const lazySectionCount = 4;
    final heights = <double>[];
    var hasPriorSection = includeRamadanCard;

    for (var i = 0; i < lazySectionCount; i++) {
      if (hasPriorSection) {
        heights.add(HomeZoneSpacing.betweenZones);
      }
      hasPriorSection = true;
    }

    if (hasPriorSection) {
      heights.add(HomeZoneSpacing.betweenZones);
    }
    return heights;
  }


  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Lazy Home zones between hero and the bottom services strip (explore not listed here).
  static const List<HomeSectionId> _canonicalLazySectionOrder = [
    HomeSectionId.trust,
    HomeSectionId.qatarLife,
    HomeSectionId.dailyEssentials,
    HomeSectionId.exchangeRates,
    HomeSectionId.forYou,
  ];

  /// Trailing zones after main lazy sections — move this list to promote services higher.
  static const List<HomeSectionId> _homeTrailingSectionOrder = [
    HomeSectionId.explore,
  ];

  ShellTab _currentTab = ShellTab.home;
  bool _launchAiChatOnMount = false;
  bool _expatScoreBootstrapStarted = false;
  bool _expatScoreLoading = false;
  bool _postMenuOpen = false;
  final ScrollController _homeScrollController = ScrollController();
  final LayerLink _aiOrbLayerLink = LayerLink();
  bool _hideAiCoachMark = false;

  @override
  void initState() {
    super.initState();
    final launch = ShellNavConfig.resolveLegacyHomeTabQuery(widget.initialTab);
    _currentTab = widget.initialShellTab ?? launch.tab;
    _launchAiChatOnMount = widget.openAiChatOnLaunch || launch.openAiChat;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _bootstrapExpatScore();
      if (_launchAiChatOnMount) {
        _launchAiChatOnMount = false;
        _openAiChat();
      }
      await evaluateLifeEventHealthCoverageOnHomeLoad(ref);
      ref.invalidate(securityAwarenessCampaignProvider);
      await evaluateLifeIntelligenceSignalsOnHomeLoad(ref);
      await evaluateLifeIntelligencePushOnHomeLoad(ref);
    });
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
  }

  Future<void> _maybeSnapDohaHeader() async {
    if (!mounted || !_homeScrollController.hasClients) return;
    final target = HomeDohaTopZoneMetrics.snapTargetOffset(
      _homeScrollController.offset,
    );
    if (target == null) return;
    await _homeScrollController.animateTo(
      target,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab ||
        oldWidget.initialShellTab != widget.initialShellTab) {
      final launch =
          ShellNavConfig.resolveLegacyHomeTabQuery(widget.initialTab);
      _currentTab = widget.initialShellTab ?? launch.tab;
    }
  }

  void _openAiChat({String? prompt}) {
    context.push(
      '/ai-chat',
      extra: {
        if (prompt != null && prompt.isNotEmpty) 'query': prompt,
        'autoSendInitialMessage': false,
      },
    );
  }

  void _openExpatScoreScreen() => context.push('/expat-score');

  void _openBuildProfile() => context.push('/profile/progressive-capture');

  void _closePostMenu() {
    if (!_postMenuOpen) return;
    setState(() => _postMenuOpen = false);
  }

  void _togglePostMenu() {
    setState(() => _postMenuOpen = !_postMenuOpen);
  }

  void _openPostVertical(PostVertical vertical) {
    _closePostMenu();
    ShellPostEntry.openVertical(context, vertical);
  }

  Future<void> _bootstrapExpatScore() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _expatScoreBootstrapStarted) return;

    _expatScoreBootstrapStarted = true;
    if (mounted) setState(() => _expatScoreLoading = true);

    try {
      final aiNotifier = ref.read(userAIProfileProvider.notifier);
      final existingProfile = ref.read(userAIProfileProvider);
      if (UserProfileOwnership.needsInit(existingProfile, user.uid)) {
        await aiNotifier.initProfile(user.uid);
      }

      final profile = ref.read(userAIProfileProvider);
      if (profile != null) {
        await ref.read(expatLifeScoreProvider.notifier).refreshIfEmpty(profile);
        unawaited(_loadAiFeed(profile));
      }
    } finally {
      if (mounted) setState(() => _expatScoreLoading = false);
    }
  }

  Future<void> _refreshExpatScore() async {
    final profile = ref.read(userAIProfileProvider);
    if (profile == null) return;

    if (mounted) setState(() => _expatScoreLoading = true);
    try {
      await ref.read(expatLifeScoreProvider.notifier).refresh(profile);
      await _loadAiFeed(profile, refresh: true);
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.invalidate(expatScoreAdviceProvider(user.uid));
      }
    } finally {
      if (mounted) setState(() => _expatScoreLoading = false);
    }
  }

  Future<void> _loadAiFeed(UserAIProfile profile, {bool refresh = false}) async {
    final notifier = ref.read(aiFeedProvider.notifier);
    if (refresh) {
      await notifier.refresh(profile);
    } else {
      await notifier.load(profile);
    }
  }

  String? _resolveUserName() {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email;
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first;
      final firstSegment = localPart.split(RegExp(r'[._-]')).first;
      if (firstSegment.isNotEmpty) {
        return firstSegment[0].toUpperCase() + firstSegment.substring(1);
      }
    }
    return null;
  }

  String _greetingLine(String locale, String? displayName) {
    final greeting = homeTimeGreetingForLocale(locale);
    if (displayName != null && displayName.isNotEmpty) {
      return '$greeting $displayName';
    }
    return greeting;
  }

  HomeDohaHeaderConfig _buildDohaHeaderConfig(
    String locale, {
    Widget? aiSearchOrb,
  }) {
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider).maybeWhen(
          data: (value) => value,
          orElse: () => 0,
        );
    final resolvedName = _resolveUserName();
    final displayName =
        user != null && resolvedName != null ? resolvedName : null;

    return (
      locale: locale,
      greetingLine: _greetingLine(locale, displayName),
      profileInitials: ProfileDisplayHelper.initials(user),
      showGuestProfileIcon: user == null,
      profilePhotoUrl: user?.photoURL,
      notificationCount: unreadCount,
      onProfileTap: () => HomeProfilePopover.show(context, ref),
      onNotificationTap: () => context.push('/notifications'),
      onDiscoverQatar: () => homeDohaOpenKnowQatar(context),
      profileMenuSemanticsLabel: user == null
          ? HomeProfileStrings.t('home_profile_guest_sign_in', locale)
          : HomeProfileStrings.t('open_profile_menu', locale),
      notificationSemanticsLabel: unreadCount > 0
          ? HomeProfileStrings.t('header_notifications_unread', locale)
              .replaceAll('{count}', '$unreadCount')
          : HomeProfileStrings.t('header_notifications', locale),
      searchRow: HomeSearchWithAiRow(
        aiOrb: aiSearchOrb,
        search: AnimatedSearchEntry(
          hint: AppShellStrings.t('global_search_hint', locale),
          semanticsLabel:
              AppShellStrings.t('global_search_field_label', locale),
          onTap: () => context.push('/global-search'),
        ),
      ),
    );
  }


  List<Widget> _buildPersonalizedSections(String locale) {
    final sections = <Widget>[];

    if (RamadanSeason.isSeasonalPeriod()) {
      sections.add(const HomeRamadanSeasonalCard());
    }

    for (var i = 0; i < _canonicalLazySectionOrder.length; i++) {
      if (sections.isNotEmpty) {
        sections.add(SizedBox(height: HomeZoneSpacing.betweenZones));
      }

      sections.add(switch (_canonicalLazySectionOrder[i]) {
        HomeSectionId.trust => const HomeTrustSafetyZone(),
        HomeSectionId.qatarLife => const HomeQatarLifeZone(),
        HomeSectionId.dailyEssentials => const HomeDailyEssentialsZone(),
        HomeSectionId.exchangeRates => const HomeCurrencyRailZone(),
        HomeSectionId.forYou =>
          HomeForYouZone(
            onAiTap: () => _openAiChat(),
            onBuildProfileTap: _openBuildProfile,
          ),
        HomeSectionId.explore => const SizedBox.shrink(),
      });
    }

    for (final trailingId in _homeTrailingSectionOrder) {
      sections.add(SizedBox(height: HomeZoneSpacing.betweenZones));
      sections.add(switch (trailingId) {
        HomeSectionId.explore => const HomeServicesStripZone(),
        _ => const SizedBox.shrink(),
      });
    }

    return sections;
  }

  Widget _buildHomeContent(String locale) {
    ref.watch(homeDohaDayPartProvider);
    final dayPartSeed = ref.read(homeDohaDayPartProvider);
    final topInset = MediaQuery.paddingOf(context).top;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final aiActive = isHomeFloatingAiAssistantVisible(
      currentTab: _currentTab,
      postDialOpen: _postMenuOpen,
    ) &&
        keyboardInset <= 0;

    final feedResult = ref.watch(aiFeedProvider).valueOrNull;
    final showAiFeedDot = feedResult != null &&
        HomeAiFeedUtils.visibleCards(feedResult).isNotEmpty;

    final coachMarkVisible = aiActive &&
        !_postMenuOpen &&
        !_hideAiCoachMark &&
        (ModalRoute.of(context)?.isCurrent ?? true);

    return HomeAiAssistantHost(
      locale: locale,
      active: aiActive,
      showProactiveDot: showAiFeedDot,
      orbLayerLink: _aiOrbLayerLink,
      linkLeaderOnStickyRow: false,
      onAssistantOpening: () {
        setState(() => _hideAiCoachMark = true);
        unawaited(HomeAiOrbCoachMarkPrefs.dismiss());
      },
      child: (context, aiOrbs) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            SafeArea(
              bottom: false,
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  unawaited(_maybeSnapDohaHeader());
                  return false;
                },
                child: RefreshIndicator(
                  color: glass.AppColors.brandFamilyMain,
                  onRefresh: () async {
                    ref.invalidate(qatarWeatherProvider);
                    final profile = ref.read(userAIProfileProvider);
                    if (profile != null) {
                      await _refreshExpatScore();
                    } else {
                      _expatScoreBootstrapStarted = false;
                      await _bootstrapExpatScore();
                    }
                  },
                  child: CustomScrollView(
                    controller: _homeScrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: HomeDohaCollapsingHeaderDelegate(
                          topSafeInset: topInset,
                          dayPartSeed: dayPartSeed.part,
                          config: _buildDohaHeaderConfig(
                            locale,
                            aiSearchOrb: aiOrbs.inline,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          HomeResponsiveLayout.contentLeadingInset(
                            MediaQuery.sizeOf(context).width,
                          ),
                          HomeZoneSpacing.betweenZones,
                          HomeResponsiveLayout.contentLeadingInset(
                            MediaQuery.sizeOf(context).width,
                          ),
                          HomeScreen.usesHomeScrollUnderNav(
                            currentTab: _currentTab,
                            showBottomNav:
                                MediaQuery.viewInsetsOf(context).bottom <= 0,
                          )
                              ? HomeScreen.homeScrollBottomPadding(context)
                              : 0,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              HomeTodayZone(
                                onFocusTap: _openExpatScoreScreen,
                                expatScoreLoading: _expatScoreLoading,
                                onOpenExpatScore: _openExpatScoreScreen,
                                onOpenBuildProfile: _openBuildProfile,
                              ),
                              const SizedBox(height: HomeZoneSpacing.afterHero),
                              const HomeGlanceRow(),
                              const SizedBox(height: HomeZoneSpacing.afterHero),
                              const HomeTodaySupplementaryZone(),
                              const ConciergeHomeCard(),
                              SizedBox(height: HomeZoneSpacing.betweenZones),
                              HomeLazySection(
                                builder: (context) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildPersonalizedSections(locale),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (aiOrbs.hasOrb)
              HomeAiOrbCoachMark(
                link: _aiOrbLayerLink,
                locale: locale,
                visible: coachMarkVisible,
                onDismissed: () {
                  if (mounted) setState(() => _hideAiCoachMark = true);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody(String locale) {
    final localeKey = ValueKey(locale);
    return switch (_currentTab) {
      ShellTab.home => _buildHomeContent(locale),
      ShellTab.documents =>
        VisaScreen(key: localeKey, isShellRootTab: true),
      ShellTab.community => CommunityScreen(key: localeKey),
      ShellTab.profile => ProfileScreen(key: localeKey),
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null &&
          (previous == null || previous.uid != next.uid)) {
        _expatScoreBootstrapStarted = false;
        unawaited(_bootstrapExpatScore());
      }
    });

    ref.listen<UserAIProfile?>(userAIProfileProvider, (previous, next) {
      if (next == null) return;
      if (previous == null) {
        unawaited(
          ref.read(expatLifeScoreProvider.notifier).refreshIfEmpty(next),
        );
        unawaited(_loadAiFeed(next));
        return;
      }
      if (previous.lastUpdated != next.lastUpdated) {
        unawaited(ref.read(expatLifeScoreProvider.notifier).refresh(next));
      }
    });

    final locale = ref.watch(userLanguageProvider);
    final isRtl = AppLocale.isRtl(locale);
    final navSlots = ShellNavConfig.slotsFor(locale);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final showBottomNav = keyboardInset <= 0;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final homeScrollUnderNav = HomeScreen.usesHomeScrollUnderNav(
      currentTab: _currentTab,
      showBottomNav: showBottomNav,
    );
    final shellBottomScrim = HomeScreen.showShellBottomScrim(
      showBottomNav: showBottomNav,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PostDraftRelocatedSnackbar.maybeShow(context, locale);
    });

    return PopScope(
      canPop: !_postMenuOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _postMenuOpen) _closePostMenu();
      },
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: HomeTruthEngineRevealListener(
            child: AnimatedAuroraBackground(
              enableAnimation: !reduceMotion,
              ignoreSafeArea: true,
              child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (_currentTab == ShellTab.home)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: HomePageGrainLayer(),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: homeScrollUnderNav
                        ? 0
                        : HomeScreen.shellBodyBottomClearance(),
                  ),
                  child: ShellChromeScope(
                    shellBottomNavVisible: showBottomNav,
                    child: _buildBody(locale),
                  ),
                ),
                if (shellBottomScrim)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: HomeScreen.homeBottomScrimHeight(context),
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              glass.AppColors.background.withValues(alpha: 0),
                              glass.AppColors.background.withValues(
                                alpha: HomeGlassLegibilityTokens.bottomScrimMidAlpha,
                              ),
                              glass.AppColors.background.withValues(
                                alpha: HomeGlassLegibilityTokens.bottomScrimHighAlpha,
                              ),
                              glass.AppColors.background,
                            ],
                            stops: const [0.0, 0.35, 0.72, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_postMenuOpen && showBottomNav)
                  Positioned.fill(
                    child: ShellPostVerticalMenuOverlay(
                      locale: locale,
                      open: _postMenuOpen,
                      onClose: _closePostMenu,
                      onVerticalSelected: _openPostVertical,
                    ),
                  ),
                if (showBottomNav)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: FloatingNavBar(
                      currentTab: _currentTab,
                      slots: navSlots,
                      locale: locale,
                      activeNavColor: glass.AppColors.brandFamilyMain,
                      postMenuOpen: _postMenuOpen,
                      onPostMenuToggle: _togglePostMenu,
                      onTabSelected: (tab) {
                        _closePostMenu();
                        if (tab == ShellTab.home && _currentTab == ShellTab.home) {
                          return;
                        }
                        setState(() => _currentTab = tab);
                      },
                    ),
                  ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
