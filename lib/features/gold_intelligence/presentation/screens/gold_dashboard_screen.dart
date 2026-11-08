import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/features/gold_intelligence/data/gold_faq_content.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_alerts_panel.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_calculator_panel.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_locker_panel.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_hero_card.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_karat_carousel.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_section_header.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_trend_chart.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_weight_pricing_panel.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:raabta/features/gold_intelligence/services/gold_qatar_service.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class GoldDashboardScreen extends ConsumerStatefulWidget {
  const GoldDashboardScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<GoldDashboardScreen> createState() =>
      _GoldDashboardScreenState();
}

class _GoldDashboardScreenState extends ConsumerState<GoldDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  GoldChartRange _chartRange = GoldChartRange.today;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _pullRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await ref.read(goldQatarServiceProvider).requestRefresh();
    } catch (_) {
      // Backend refresh optional — direct spot still runs in requestRefresh.
    }
    ref.invalidate(goldLatestProvider);
    ref.invalidate(goldHistoryProvider(_chartRange));
    try {
      await ref.read(goldLatestProvider.future);
    } catch (_) {
      // Error UI handled by AsyncValue in tabs.
    }
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final snapAsync = ref.watch(goldLatestProvider);
    final historyAsync = ref.watch(goldHistoryProvider(_chartRange));

    return MoneyToolScreenScaffold(
      title: GoldIntelligenceStrings.t('dashboard_title', locale),
      subtitle: GoldIntelligenceStrings.t('dashboard_subtitle', locale),
      onBack: () => context.pop(),
      onRefresh: _pullRefresh,
      isRefreshing: _refreshing,
      customBody: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabs,
            isScrollable: true,
            indicatorColor: AppColors.goldFamilyMain,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textTertiary,
            tabs: [
              Tab(text: GoldIntelligenceStrings.t('tab_market', locale)),
              Tab(text: GoldIntelligenceStrings.t('tab_calculator', locale)),
              Tab(text: GoldIntelligenceStrings.t('tab_locker', locale)),
              Tab(text: GoldIntelligenceStrings.t('tab_alerts', locale)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _marketTab(snapAsync, historyAsync, locale),
                _calculatorTab(snapAsync, locale),
                _lockerTab(snapAsync, locale),
                _alertsTab(snapAsync, locale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketTab(
    AsyncValue<GoldQatarSnapshot> snapAsync,
    AsyncValue<List<GoldHistoryPoint>> historyAsync,
    String locale,
  ) {
    return snapAsync.when(
      loading: () => const MoneyHubScreenLoading(cardCount: 4, cardHeight: 140),
      error: (e, _) => _errorState(
        locale: locale,
        message: e is GoldFetchException
            ? e.message
            : GoldIntelligenceStrings.t('error_load_gold_data', locale),
        onRetry: _pullRefresh,
      ),
      data: (snap) => RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            GoldHeroCard(snap: snap, locale: locale),
            const SizedBox(height: AppSpacing.xl),
            GoldSectionHeader(
              title: GoldIntelligenceStrings.t('purity_ladder_title', locale),
              subtitle: GoldIntelligenceStrings.t('purity_ladder_subtitle', locale),
              icon: Icons.diamond_outlined,
            ),
            GoldKaratCarousel(price24k: snap.gold24kQarPerGram, locale: locale),
            const SizedBox(height: AppSpacing.xl),
            GoldSectionHeader(
              title: GoldIntelligenceStrings.t('value_by_weight_title', locale),
              subtitle: GoldIntelligenceStrings.t('value_by_weight_subtitle', locale),
              icon: Icons.scale_outlined,
            ),
            GoldWeightPricingPanel(price24k: snap.gold24kQarPerGram, locale: locale),
            const SizedBox(height: AppSpacing.xl),
            GoldSectionHeader(
              title: GoldIntelligenceStrings.t('market_movement_title', locale),
              subtitle: GoldIntelligenceStrings.t('market_movement_subtitle', locale),
              icon: Icons.insights_outlined,
            ),
            historyAsync.when(
              loading: () => const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => GoldTrendChart(
                points: const [],
                currentPrice: snap.gold24kQarPerGram,
                selectedRange: _chartRange,
                onRangeChanged: (r) => setState(() => _chartRange = r),
                locale: locale,
              ),
              data: (points) => GoldTrendChart(
                points: points,
                currentPrice: snap.gold24kQarPerGram,
                selectedRange: _chartRange,
                onRangeChanged: (r) => setState(() => _chartRange = r),
                locale: locale,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (snap.aiInsight != null) _insightCard(snap, locale),
            const SizedBox(height: AppSpacing.lg),
            _faqSection(locale),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _errorState({
    required String locale,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTypography.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: CommonActionStrings.t('action_retry', locale),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard(GoldQatarSnapshot snap, String locale) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            GoldIntelligenceStrings.t('ai_insight_title', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(snap.aiInsight!, style: AppTypography.body),
          const SizedBox(height: AppSpacing.sm),
          Text(
            snap.aiInsightDisclaimer ??
                GoldIntelligenceStrings.t('ai_disclaimer', locale),
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _faqSection(String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          GoldIntelligenceStrings.t('faq_title', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...GoldFaqContent.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  title: Text(item.question, style: AppTypography.subtitle),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Text(item.answer, style: AppTypography.body),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _calculatorTab(AsyncValue<GoldQatarSnapshot> snapAsync, String locale) {
    return snapAsync.when(
      loading: () => const MoneyHubScreenLoading(cardCount: 2, cardHeight: 100),
      error: (e, _) => _errorState(
        locale: locale,
        message: GoldIntelligenceStrings.t('rate_unavailable', locale),
        onRetry: _pullRefresh,
      ),
      data: (snap) => GoldCalculatorPanel(
        price24k: snap.gold24kQarPerGram,
        onSwitchToLocker: () => _tabs.animateTo(2),
      ),
    );
  }

  Widget _lockerTab(AsyncValue<GoldQatarSnapshot> snapAsync, String locale) {
    return snapAsync.when(
      loading: () => const MoneyHubScreenLoading(cardCount: 2, cardHeight: 100),
      error: (_, _) => _errorState(
        locale: locale,
        message: GoldIntelligenceStrings.t('rate_unavailable', locale),
        onRetry: _pullRefresh,
      ),
      data: (snap) => GoldLockerPanel(price24k: snap.gold24kQarPerGram),
    );
  }

  Widget _alertsTab(AsyncValue<GoldQatarSnapshot> snapAsync, String locale) {
    return snapAsync.when(
      loading: () => const MoneyHubScreenLoading(cardCount: 2, cardHeight: 100),
      error: (_, _) => _errorState(
        locale: locale,
        message: GoldIntelligenceStrings.t('rate_unavailable', locale),
        onRetry: _pullRefresh,
      ),
      data: (snap) => GoldAlertsPanel(price24k: snap.gold24kQarPerGram),
    );
  }
}
