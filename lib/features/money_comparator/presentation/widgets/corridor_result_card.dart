import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/money_comparator/domain/corridor_provider_links.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';
import 'package:raabta/features/money_comparator/presentation/providers/corridor_comparator_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:url_launcher/url_launcher.dart';

class CorridorResultCard extends StatelessWidget {
  const CorridorResultCard({
    super.key,
    required this.row,
    required this.currencyCode,
    required this.rank,
    required this.locale,
  });

  final CorridorComparisonRow row;
  final String currencyCode;
  final int rank;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final agg = row.aggregate;
    final method = agg.method;
    final catalogLocale = AppLocale.normalize(locale);
    final updated = agg.lastUpdated;
    final dateLocale = AppLocale.toLanguageCode(catalogLocale);
    final updatedLabel = updated != null
        ? DateFormat.yMMMd(dateLocale).add_jm().format(updated)
        : MoneyComparatorStrings.t('mc_community_updated_recently', catalogLocale);

    final hours = agg.avgDeliveryHours;
    final speedLabel = hours < 24
        ? MoneyComparatorStrings.format(
            'mc_community_speed_hours',
            catalogLocale,
            params: {'hours': hours.round().toString()},
          )
        : MoneyComparatorStrings.format(
            'mc_community_speed_days',
            catalogLocale,
            params: {'days': (hours / 24).toStringAsFixed(1)},
          );

    final providerUrl = CorridorProviderLinks.urlForProvider(agg.providerName);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusMd,
      glowColor: rank == 1 ? AppColors.amberGlow : AppColors.goldFamilyMain,
      glowIntensity: rank == 1 ? 0.15 : 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '#$rank',
                style: AppTypography.caption.copyWith(
                  color: AppColors.amberGlow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(method.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  agg.providerName,
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            method.label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                MoneyComparatorStrings.t('rte_recipient_gets', catalogLocale),
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
                    value: row.estimatedRecipientGets,
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
              'mc_community_reports_meta',
              catalogLocale,
              params: {
                'count': agg.reportCount.toString(),
                'updated': updatedLabel,
              },
            ),
            style: AppTypography.caption,
          ),
          Text(
            MoneyComparatorStrings.format(
              'mc_community_stats_line',
              catalogLocale,
              params: {
                'per100': row.recipientGetsPer100Qar.toStringAsFixed(1),
                'code': currencyCode,
                'fee': agg.avgFeePaidQar.toStringAsFixed(0),
                'speed': speedLabel,
              },
            ),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
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
                providerUrl != null
                    ? MoneyComparatorStrings.format(
                        'rte_go_to_provider',
                        catalogLocale,
                        params: {'provider': agg.providerName},
                      )
                    : agg.providerName,
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
