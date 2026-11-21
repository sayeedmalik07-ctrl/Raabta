import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';
import 'package:raabta/features/cost_of_living/presentation/l10n/cost_of_living_strings.dart';
import 'package:raabta/features/cost_of_living/presentation/providers/cost_of_living_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/cost_of_living/presentation/widgets/cost_of_living_category_chart.dart';
import 'package:raabta/features/profile/advanced/widgets/advanced_profile_card.dart';
import 'package:raabta/features/cost_of_living/presentation/widgets/cost_of_living_disclaimer_banner.dart';
import 'package:raabta/features/cost_of_living/presentation/widgets/cost_of_living_widgets.dart';
import 'package:raabta/features/cost_of_living/services/cost_of_living_service.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/metric_chip.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_link_card.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class CostOfLivingScreen extends ConsumerStatefulWidget {
  const CostOfLivingScreen({super.key});

  @override
  ConsumerState<CostOfLivingScreen> createState() => _CostOfLivingScreenState();
}

class _CostOfLivingScreenState extends ConsumerState<CostOfLivingScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    ref.invalidate(costOfLivingSnapshotProvider);
    try {
      await ref
          .read(costOfLivingServiceProvider)
          .fetchLatest(force: true);
    } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final snapAsync = ref.watch(costOfLivingSnapshotProvider);
    final comparisons = ref.watch(personalCostComparisonsProvider);

    return snapAsync.when(
      loading: () => MoneyToolScreenScaffold(
        title: CostOfLivingStrings.t('col_title', locale),
        subtitle: CostOfLivingStrings.t('col_hub_subtitle', locale),
        onBack: () => context.pop(),
        onRefresh: _refresh,
        isRefreshing: _refreshing,
        children: const [
          MoneyHubScreenLoading(cardCount: 4, cardHeight: 132),
        ],
      ),
      error: (e, _) => MoneyToolScreenScaffold(
        title: CostOfLivingStrings.t('col_title', locale),
        subtitle: CostOfLivingStrings.t('col_hub_subtitle', locale),
        onBack: () => context.pop(),
        onRefresh: _refresh,
        isRefreshing: _refreshing,
        children: [
          _ErrorState(
            message: e.toString(),
            locale: locale,
            onRetry: _refresh,
          ),
        ],
      ),
      data: (snap) => MoneyToolScreenScaffold(
        title: CostOfLivingStrings.t('col_title', locale),
        subtitle: CostOfLivingStrings.t('col_hub_subtitle', locale),
        onBack: () => context.pop(),
        onRefresh: _refresh,
        isRefreshing: _refreshing,
        disclaimer: CostOfLivingDisclaimerBanner(
          text: CostOfLivingStrings.t('col_disclaimer', locale),
        ),
        children: [
          MoneyHubSectionHeader(
            overline:
                CostOfLivingStrings.t('col_section_official_overline', locale),
            title: CostOfLivingStrings.t('col_section_qatar_cpi_title', locale),
            subtitle:
                CostOfLivingStrings.t('col_section_qatar_cpi_subtitle', locale),
            leadingIcon: Icons.analytics_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const AdvancedProfileNudgeBanner(),
          const SizedBox(height: AppSpacing.md),
          const PersonalBudgetLinkCard(),
          const SizedBox(height: AppSpacing.md),
          CostOfLivingDataAsOfChip(
            cpiLabel: snap.cpiSourceDateLabel,
            qolLabel: snap.qolSourceDateLabel,
          ),
          if (snap.isFromCache) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              CostOfLivingStrings.t('col_cached_snapshot', locale),
              style:
                  AppTypography.caption.copyWith(color: AppColors.warning),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          _OverviewSection(snapshot: snap, locale: locale),
          const SizedBox(height: AppSpacing.xxl),
          CostOfLivingCategoryChart(categories: snap.featuredCategories),
          const SizedBox(height: AppSpacing.xxl),
          MoneyHubSectionHeader(
            overline:
                CostOfLivingStrings.t('col_section_breakdown_overline', locale),
            title:
                CostOfLivingStrings.t('col_section_category_cpi_title', locale),
            subtitle: CostOfLivingStrings.t(
              'col_section_category_cpi_subtitle',
              locale,
            ),
            leadingIcon: Icons.list_alt_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          ...snap.featuredCategories.map(
            (c) => CostOfLivingCategoryTile(category: c),
          ),
          const SizedBox(height: AppSpacing.xxl),
          MoneyHubSectionHeader(
            overline:
                CostOfLivingStrings.t('col_section_bills_overline', locale),
            title: CostOfLivingStrings.t('col_section_bills_title', locale),
            subtitle:
                CostOfLivingStrings.t('col_section_bills_subtitle', locale),
            leadingIcon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          PersonalComparisonSection(comparisons: comparisons),
          if (snap.aiSummary != null && snap.aiSummary!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppSpacing.radiusLg,
              glowColor: AppColors.sharePurple,
              glowIntensity: 0.12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoneyHubSectionHeader(
                    overline: CostOfLivingStrings.t(
                      'col_section_insight_overline',
                      locale,
                    ),
                    title: CostOfLivingStrings.t(
                      'col_section_summary_title',
                      locale,
                    ),
                    leadingIcon: Icons.auto_awesome_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(snap.aiSummary!, style: AppTypography.bodySmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    CostOfLivingStrings.t('col_ai_summary_disclaimer', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          HubFeedFooterNotice(locale: locale),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.snapshot,
    required this.locale,
  });

  final CostOfLivingSnapshot snapshot;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final qol = snapshot.qualityOfLife;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.emeraldGlow,
      glowIntensity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HomeIconBadge(
                icon: Icons.home_work_outlined,
                accentColor: AppColors.emeraldGlow,
                size: 44,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CostOfLivingStrings.t('col_overview_title', locale),
                      style: AppTypography.headline2,
                    ),
                    Text(
                      CostOfLivingStrings.t('col_overview_subtitle', locale),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (snapshot.generalCpi != null || qol != null) ...[
            const SizedBox(height: AppSpacing.lg),
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.md),
              borderRadius: AppSpacing.radiusXl,
              glowColor: AppColors.emeraldGlow,
              glowIntensity: 0.08,
              child: Row(
                children: [
                  if (snapshot.generalCpi != null)
                    Expanded(
                      child: MetricChip(
                        icon: Icons.analytics_outlined,
                        value: snapshot.generalCpi!.toStringAsFixed(2),
                        label: CostOfLivingStrings.t('col_general_cpi', locale),
                        accentColor: AppColors.emeraldGlow,
                      ),
                    ),
                  if (snapshot.generalCpi != null && qol != null)
                    const SizedBox(width: AppSpacing.sm),
                  if (qol != null)
                    Expanded(
                      child: MetricChip(
                        icon: Icons.star_outline,
                        value: qol.score.toStringAsFixed(1),
                        label: CostOfLivingStrings.format(
                          'col_qol_rank',
                          locale,
                          params: {'rank': qol.rank.toString()},
                        ),
                        accentColor: AppColors.cyanGlow,
                      ),
                    ),
                ],
              ),
            ),
            if (qol != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                CostOfLivingStrings.format(
                  'col_numbeo_source',
                  locale,
                  params: {'source': qol.sourceLabel},
                ),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.locale,
    required this.onRetry,
  });

  final String message;
  final String locale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onRetry,
            child: Text(CostOfLivingStrings.t('col_retry', locale)),
          ),
        ],
      ),
    );
  }
}
