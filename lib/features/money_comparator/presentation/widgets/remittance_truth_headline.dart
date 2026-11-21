import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/money_comparator/domain/remittance_truth_calculator.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

/// Headline "you'd lose ~X QAR" — reactive, no submit button.
class RemittanceTruthHeadline extends StatelessWidget {
  const RemittanceTruthHeadline({
    super.key,
    required this.locale,
    required this.rows,
    required this.amountSentQar,
    required this.currencyCode,
  });

  final String locale;
  final List<RemittanceProviderComparisonRow> rows;
  final double amountSentQar;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final best = rows.first;
    final worst = rows.reduce(
      (a, b) => a.totalCostQar > b.totalCostQar ? a : b,
    );

    if (rows.length == 1) {
      return _HeadlineCard(
        locale: locale,
        hiddenMarkupQar: worst.hiddenMarkupQar,
        providerName: worst.provider.providerName,
        flatFeeQar: worst.provider.flatFeeQar,
      );
    }

    final savingsVsWorst =
        worst.totalCostQar - best.totalCostQar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeadlineCard(
          locale: locale,
          hiddenMarkupQar: worst.hiddenMarkupQar,
          providerName: worst.provider.providerName,
          flatFeeQar: worst.provider.flatFeeQar,
        ),
        if (savingsVsWorst > 0.5) ...[
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppSpacing.radiusMd,
            glowColor: AppColors.emeraldGlow,
            glowIntensity: 0.1,
            child: Text(
              MoneyComparatorStrings.format(
                'rte_savings_vs_worst',
                locale,
                params: {
                  'amount': savingsVsWorst.toStringAsFixed(0),
                  'best': best.provider.providerName,
                  'worst': worst.provider.providerName,
                },
              ),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.emeraldGlow,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({
    required this.locale,
    required this.hiddenMarkupQar,
    required this.providerName,
    required this.flatFeeQar,
  });

  final String locale;
  final double hiddenMarkupQar;
  final String providerName;
  final double flatFeeQar;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusMd,
      glowColor: AppColors.amberGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            MoneyComparatorStrings.format(
              'rte_headline_provider',
              locale,
              params: {'provider': providerName},
            ),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            MoneyComparatorStrings.t('rte_headline_prefix', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FittedBox(
              alignment: AlignmentDirectional.centerStart,
              fit: BoxFit.scaleDown,
              child: MoneyAnimatedFigure(
                value: hiddenMarkupQar,
                decimals: 0,
                suffix: ' QAR',
                style: AppTypography.headline1.copyWith(
                  color: AppColors.amberGlow,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MoneyComparatorStrings.format(
              'rte_headline_sub',
              locale,
              params: {
                'fee': flatFeeQar.toStringAsFixed(0),
                'provider': providerName,
              },
            ),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
