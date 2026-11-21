import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_constants.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';
import 'package:raabta/features/cost_of_living/presentation/l10n/cost_of_living_strings.dart';
import 'package:raabta/features/cost_of_living/services/cost_of_living_service.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class CostOfLivingHomeCard extends ConsumerWidget {
  const CostOfLivingHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final snapAsync = ref.watch(costOfLivingSnapshotProvider);

    return snapAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassLoadingCard(height: 120),
      ),
      error: (_, _) => _card(
        context,
        locale: locale,
        generalCpi: null,
        cpiDate: null,
        qolScore: null,
        offline: true,
      ),
      data: (snap) => _card(
        context,
        locale: locale,
        generalCpi: snap.generalCpi,
        cpiDate: snap.cpiSourceDateLabel,
        qolScore: snap.qualityOfLife?.score,
        offline: snap.isFromCache,
        isDirectApi: snap.isDirectApi,
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String locale,
    required double? generalCpi,
    required String? cpiDate,
    required double? qolScore,
    bool offline = false,
    bool isDirectApi = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onTap: () => context.push('/money-services/cost-of-living'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        glowColor: AppColors.emeraldGlow,
        glowIntensity: 0.15,
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
                        CostOfLivingStrings.t('col_home_title', locale),
                        style: AppTypography.title,
                      ),
                      Text(
                        CostOfLivingStrings.t('col_home_subtitle', locale),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (generalCpi != null)
              MoneyAnimatedFigure(
                value: generalCpi,
                prefix: CostOfLivingStrings.t('col_general_cpi_prefix', locale),
                decimals: 1,
                style: AppTypography.tabular(
                  AppTypography.headline2.copyWith(
                    color: AppColors.emeraldGlow,
                  ),
                ),
              )
            else
              Text(
                CostOfLivingStrings.t('col_data_unavailable', locale),
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (qolScore != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                CostOfLivingStrings.format(
                  'col_qol_score',
                  locale,
                  params: {'score': qolScore.toStringAsFixed(0)},
                ),
                style: AppTypography.bodySmall,
              ),
            ],
            if (cpiDate != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  CostOfLivingStrings.format(
                    'col_data_as_of',
                    locale,
                    params: {'date': cpiDate},
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.cyanGlow,
                  ),
                ),
              ),
            if (isDirectApi)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  CostOfLivingStrings.t('col_official_data_gov', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.cyanGlow,
                  ),
                ),
              )
            else if (offline)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  CostOfLivingStrings.t('col_cached_data', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CostOfLivingCategoryTile extends ConsumerWidget {
  const CostOfLivingCategoryTile({super.key, required this.category});

  final CostOfLivingCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final trendColor = switch (category.trend) {
      CostOfLivingTrend.up => AppColors.errorBright,
      CostOfLivingTrend.down => AppColors.successBright,
      CostOfLivingTrend.flat => AppColors.textSecondary,
    };
    final trendIcon = switch (category.trend) {
      CostOfLivingTrend.up => Icons.north_east,
      CostOfLivingTrend.down => Icons.south_east,
      CostOfLivingTrend.flat => Icons.remove,
    };

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.displayName, style: AppTypography.subtitle),
                Text(
                  CostOfLivingStrings.format(
                    'col_category_index',
                    locale,
                    params: {'index': category.cpiIndex.toStringAsFixed(2)},
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, size: 16, color: trendColor),
                  const SizedBox(width: 4),
                  Text(
                    _trendLabel(category.trend, locale),
                    style: AppTypography.chipLabel.copyWith(color: trendColor),
                  ),
                ],
              ),
              if (category.changePctMom != null)
                Text(
                  CostOfLivingStrings.format(
                    'col_change_vs_prior_month',
                    locale,
                    params: {
                      'change':
                          '${category.changePctMom! >= 0 ? '+' : ''}${category.changePctMom!.toStringAsFixed(1)}',
                    },
                  ),
                  style: AppTypography.caption,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _trendLabel(CostOfLivingTrend trend, String locale) {
  return switch (trend) {
    CostOfLivingTrend.up => CostOfLivingStrings.t('col_trend_rising', locale),
    CostOfLivingTrend.down => CostOfLivingStrings.t('col_trend_falling', locale),
    CostOfLivingTrend.flat => CostOfLivingStrings.t('col_trend_stable', locale),
  };
}

class PersonalComparisonSection extends ConsumerWidget {
  const PersonalComparisonSection({
    super.key,
    required this.comparisons,
  });

  final List<PersonalCostComparison> comparisons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    if (comparisons.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        child: Text(
          CostOfLivingStrings.t('col_personal_comparison_empty', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...comparisons.map(
          (c) => GlassCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppSpacing.radiusLg,
            glowColor: c.aligned ? AppColors.cyanGlow : AppColors.accentGold,
            glowIntensity: 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.categoryLabel, style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  c.body,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          CostOfLivingStrings.t('col_personal_comparison_disclaimer', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
