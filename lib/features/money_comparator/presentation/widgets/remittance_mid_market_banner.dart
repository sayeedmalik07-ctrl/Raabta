import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/money_comparator/data/models/remittance_mid_market_model.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

/// Mid-market baseline disclosure — honest source + date, never "real-time".
class RemittanceMidMarketBanner extends StatelessWidget {
  const RemittanceMidMarketBanner({
    super.key,
    required this.locale,
    required this.corridorRate,
    required this.currencyCode,
    this.frankfurterDate,
  });

  final String locale;
  final RemittanceCorridorRate corridorRate;
  final String currencyCode;
  final String? frankfurterDate;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = switch (corridorRate.source) {
      RemittanceRateSource.frankfurterEcb =>
        MoneyComparatorStrings.t('rte_source_frankfurter', locale),
      RemittanceRateSource.openErApi =>
        MoneyComparatorStrings.t('rte_source_er_api', locale),
      RemittanceRateSource.unknown =>
        MoneyComparatorStrings.t('rte_source_unknown', locale),
    };

    final asOf = corridorRate.sourceDate ?? frankfurterDate ?? '';

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusMd,
      glowColor: AppColors.goldFamilyMain,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 360;
              final trust = TrustLabel(
                type: TrustLabelType.official,
                locale: locale,
                sourceName: sourceLabel,
                sourceUrl: corridorRate.source == RemittanceRateSource.frankfurterEcb
                    ? 'https://api.frankfurter.dev'
                    : 'https://open.er-api.com',
                showDetail: false,
              );
              final chip = MoneyLiveChip(
                label: MoneyComparatorStrings.t('rte_mid_market', locale),
                isLive: false,
                accentColor: AppColors.goldFamilyMain,
              );
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    trust,
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: chip,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: trust),
                  const SizedBox(width: AppSpacing.sm),
                  chip,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            alignment: AlignmentDirectional.centerStart,
            fit: BoxFit.scaleDown,
            child: Text(
              MoneyComparatorStrings.format(
                'rte_mid_market_rate_line',
                locale,
                params: {
                  'rate': corridorRate.rate.toStringAsFixed(4),
                  'code': currencyCode,
                },
              ),
              style: AppTypography.title.copyWith(
                color: AppColors.goldFamilyMain,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          if (asOf.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              MoneyComparatorStrings.format(
                'rte_mid_market_as_of',
                locale,
                params: {'date': asOf},
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            MoneyComparatorStrings.t('rte_mid_market_disclaimer', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
