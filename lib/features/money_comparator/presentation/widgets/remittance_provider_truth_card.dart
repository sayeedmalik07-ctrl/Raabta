import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/money_comparator/data/models/remittance_provider_rate_model.dart';
import 'package:raabta/features/money_comparator/domain/corridor_provider_links.dart';
import 'package:raabta/features/money_comparator/domain/remittance_truth_calculator.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:url_launcher/url_launcher.dart';

class RemittanceProviderTruthCard extends StatelessWidget {
  const RemittanceProviderTruthCard({
    super.key,
    required this.row,
    required this.currencyCode,
    required this.rank,
    required this.locale,
  });

  final RemittanceProviderComparisonRow row;
  final String currencyCode;
  final int rank;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final provider = row.provider;
    final isRpw = provider.dataSource == RemittanceProviderDataSource.worldBankRpw;
    final providerUrl = CorridorProviderLinks.urlForProvider(provider.providerName);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusMd,
      glowColor: rank == 1 ? AppColors.emeraldGlow : AppColors.goldFamilyMain,
      glowIntensity: rank == 1 ? 0.14 : 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '#$rank',
                style: AppTypography.caption.copyWith(
                  color: rank == 1 ? AppColors.emeraldGlow : AppColors.amberGlow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(provider.providerName, style: AppTypography.title),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isRpw)
            TrustLabel(
              type: TrustLabelType.verified,
              locale: locale,
              verifiedDateIso: provider.dataAsOf,
              sourceName: MoneyComparatorStrings.t('rte_label_rpw', locale),
              sourceUrl: provider.sourceUrl,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrustLabel(
                  type: TrustLabelType.community,
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  MoneyComparatorStrings.t('rte_label_curated', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                MoneyComparatorStrings.t('rte_recipient_gets', locale),
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
                    value: row.recipientGetsForeign,
                    decimals: 0,
                    suffix: ' $currencyCode',
                    style: AppTypography.headline2.copyWith(
                      color: AppColors.goldFamilyMain,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            MoneyComparatorStrings.format(
              'rte_provider_stats',
              locale,
              params: {
                'effective': row.providerEffectiveRate.toStringAsFixed(4),
                'fee': provider.flatFeeQar.toStringAsFixed(0),
                'markup': row.hiddenMarkupQar.toStringAsFixed(0),
                'total_pct': row.totalCostPercent.toStringAsFixed(2),
              },
            ),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            MoneyComparatorStrings.format(
              'rte_data_as_of',
              locale,
              params: {'period': provider.dataAsOf},
            ),
            style: AppTypography.caption,
          ),
          if (provider.reliabilityNote != null &&
              provider.reliabilityNote!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              provider.reliabilityNote!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: providerUrl != null
                  ? () async {
                      final uri = Uri.parse(providerUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(
                MoneyComparatorStrings.format(
                  'rte_go_to_provider',
                  locale,
                  params: {'provider': provider.providerName},
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.goldFamilyMain,
                side: BorderSide(
                  color: AppColors.goldFamilyMain.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
