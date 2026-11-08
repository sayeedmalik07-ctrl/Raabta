import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_constants.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';
import 'package:raabta/features/cost_of_living/presentation/l10n/cost_of_living_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

/// Horizontal CPI breakdown — stable layout (avoids vertical bar chart overflow).
class CostOfLivingCategoryChart extends ConsumerWidget {
  const CostOfLivingCategoryChart({
    super.key,
    required this.categories,
  });

  final List<CostOfLivingCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final locale = ref.watch(userLanguageProvider);
    final sorted = List<CostOfLivingCategory>.from(categories)
      ..sort((a, b) => b.cpiIndex.compareTo(a.cpiIndex));
    final top = sorted.take(6).toList();
    final maxIndex = top.map((c) => c.cpiIndex).reduce((a, b) => a > b ? a : b);
    final safeMax = maxIndex <= 0 ? 100.0 : maxIndex;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.emeraldGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoneyHubSectionHeader(
            overline: CostOfLivingStrings.t('col_chart_overline', locale),
            title: CostOfLivingStrings.t('col_chart_title', locale),
            subtitle: CostOfLivingStrings.t('col_chart_subtitle', locale),
            leadingIcon: Icons.bar_chart_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < top.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _CategoryBarRow(
              category: top[i],
              fraction: (top[i].cpiIndex / safeMax).clamp(0.05, 1.0),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBarRow extends StatelessWidget {
  const _CategoryBarRow({
    required this.category,
    required this.fraction,
  });

  final CostOfLivingCategory category;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final color = _trendColor(category.trend);
    final name = category.displayName;
    final short = name.length > 22 ? '${name.substring(0, 20)}…' : name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                short,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            MoneyAnimatedFigure(
              value: category.cpiIndex,
              decimals: 1,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _trendColor(CostOfLivingTrend trend) => switch (trend) {
        CostOfLivingTrend.up => AppColors.errorBright.withValues(alpha: 0.9),
        CostOfLivingTrend.down =>
          AppColors.successBright.withValues(alpha: 0.9),
        CostOfLivingTrend.flat => AppColors.cyanGlow.withValues(alpha: 0.85),
      };
}
