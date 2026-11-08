import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/l10n/home_currency_rail_strings.dart';
import 'package:raabta/features/home/utils/home_send_money_rate_utils.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/services/exchange_rate_service.dart';

/// Money Hub rates hero — Home kit **Send money home** DomainCard recipe (gold GlassCard).
class MoneyHubHeroCard extends ConsumerWidget {
  const MoneyHubHeroCard({
    super.key,
    required this.ratesAsync,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  final AsyncValue<ExchangeRates> ratesAsync;
  final String selectedCurrency;
  final ValueChanged<String> onCurrencySelected;

  /// Backend or open.er-api history spans seven calendar days (provider guarantee).
  static bool _historyIsSevenDayWindow(RateHistorySeries? series) {
    if (series == null || !series.isMarketSourced) return false;
    final dated = series.points.where((p) => p.rate != null).toList();
    if (dated.length < 2) return false;
    DateTime? parse(String d) {
      try {
        final parts = d.split('-');
        if (parts.length != 3) return null;
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {
        return null;
      }
    }

    final firstD = parse(dated.first.date);
    final lastD = parse(dated.last.date);
    if (firstD == null || lastD == null) return false;
    final span = lastD.difference(firstD).inDays.abs();
    return span >= 6 && span <= 8;
  }

  static String _signedPercentLabel(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final historyAsync = ref.watch(rateHistorySeriesProvider(selectedCurrency));

    final currency = raabtaCurrencies.firstWhere(
      (c) => c.code == selectedCurrency,
      orElse: () => raabtaCurrencies.first,
    );

    final goldMain = AppColors.goldFamilyMain;
    final goldText = AppColors.goldFamilyText;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: goldMain,
      glowIntensity: HomeCardTier.homeCardGlowIntensity,
      backgroundColor:
          goldMain.withValues(alpha: HomeCardTier.sendMoneyRateFamilyTintAlpha),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ratesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (rates) {
              if (rates.isFallback) {
                return MoneyLiveChip(
                  label: rates.isDirectApi
                      ? MoneyHubStrings.t(
                          'hero_live_indicative_rates',
                          locale,
                        )
                      : MoneyHubStrings.t('hero_indicative_rates', locale),
                  updatedAt: rates.lastUpdated,
                  isLive: !rates.isFallback,
                  accentColor: goldMain,
                  warningLabel: MoneyHubStrings.t(
                    'hero_approximate_check_connection',
                    locale,
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      MoneyHubStrings.t('hero_send_money_home_title', locale),
                      style: AppTypography.title.copyWith(fontSize: 14.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _IndicativeBadge(locale: locale),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    children: [
                      for (var i = 0; i < raabtaCurrencies.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        _HeroCurrencyChip(
                          currency: raabtaCurrencies[i],
                          selected: selectedCurrency == raabtaCurrencies[i].code,
                          onSelected: () => onCurrencySelected(
                            raabtaCurrencies[i].code,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ratesAsync.when(
            loading: () => Text(
              '…',
              style: AppTypography.title.copyWith(
                fontSize: HomeCardTier.sendMoneyRateBigFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
            error: (_, _) => Text(
              '—',
              style: AppTypography.title.copyWith(
                fontSize: HomeCardTier.sendMoneyRateBigFontSize,
                color: AppColors.textTertiary,
              ),
            ),
            data: (rates) {
              final rate = rates.rates[selectedCurrency];
              if (rate == null) {
                return Text(
                  '—',
                  style: AppTypography.title.copyWith(
                    fontSize: HomeCardTier.sendMoneyRateBigFontSize,
                    color: AppColors.textTertiary,
                  ),
                );
              }
              return MoneyAnimatedFigure(
                value: rate,
                decimals: 2,
                style: AppTypography.tabular(
                  AppTypography.title.copyWith(
                    fontSize: HomeCardTier.sendMoneyRateBigFontSize,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          ratesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (rates) {
              final rate = rates.rates[selectedCurrency];
              if (rate == null) return const SizedBox.shrink();

              final conversionLine = HomeCurrencyRailStrings.format(
                'home_currency_rail_rate',
                locale,
                params: {
                  'rate': rate.toStringAsFixed(2),
                  'code': currency.code,
                },
              );

              return historyAsync.when(
                loading: () => Text(
                  conversionLine,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
                error: (_, _) => Text(
                  conversionLine,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
                data: (series) {
                  final marketHistory =
                      series.isMarketSourced ? series.points : null;
                  final weeklyChange =
                      homeSendMoneyDisplayWeeklyChangePercent(marketHistory);
                  final useThisWeekCopy = weeklyChange != null &&
                      _historyIsSevenDayWindow(series);

                  if (weeklyChange == null) {
                    return Text(
                      conversionLine,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    );
                  }

                  final changeLabel = useThisWeekCopy
                      ? homeSendMoneyWeeklyChangeLabel(weeklyChange, locale)
                      : MoneyHubStrings.format(
                          'hero_rate_series_change',
                          locale,
                          params: {
                            'percent': _signedPercentLabel(weeklyChange),
                          },
                        );

                  final changeColor = weeklyChange >= 0
                      ? goldText
                      : AppColors.warning;

                  return Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: conversionLine,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textOnGlassMuted,
                          ),
                        ),
                        TextSpan(
                          text: ' · ',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textOnGlassMuted,
                          ),
                        ),
                        TextSpan(
                          text: changeLabel,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: changeColor,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              );
            },
          ),
          ratesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (rates) {
              if (rates.rates[selectedCurrency] == null) {
                return const SizedBox.shrink();
              }
              final updatedLabel =
                  homeSendMoneyRatesUpdatedLabel(rates, locale);
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  updatedLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IndicativeBadge extends StatelessWidget {
  const _IndicativeBadge({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.textPrimary.withValues(alpha: 0.08),
      ),
      child: Text(
        HomeCurrencyRailStrings.t('home_currency_indicative_badge', locale),
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnGlassMuted,
        ),
      ),
    );
  }
}

class _HeroCurrencyChip extends StatelessWidget {
  const _HeroCurrencyChip({
    required this.currency,
    required this.selected,
    required this.onSelected,
  });

  final CurrencyInfo currency;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('${currency.flag} ${currency.code}'),
      selected: selected,
      onSelected: (_) {
        moneyHubSelectionHaptic();
        onSelected();
      },
      selectedColor: currency.chartColor.withValues(alpha: 0.25),
      backgroundColor: AppColors.isLight
          ? AppColors.glassSurface
          : Colors.white.withValues(alpha: 0.04),
      labelStyle: AppTypography.chipLabel.copyWith(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected
            ? currency.chartColor
            : (AppColors.isLight ? AppColors.glassBorder : Colors.white24),
      ),
    );
  }
}
