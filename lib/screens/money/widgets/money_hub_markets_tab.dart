import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/l10n/money_hub_strings.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/services/exchange_rate_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MoneyHubMarketsTab extends ConsumerStatefulWidget {
  const MoneyHubMarketsTab({
    super.key,
    required this.ratesAsync,
    required this.selectedCurrency,
    required this.amountController,
    required this.onRefresh,
    this.initialSegment = 0,
  });

  final AsyncValue<ExchangeRates> ratesAsync;
  final String selectedCurrency;
  final TextEditingController amountController;
  final Future<void> Function() onRefresh;
  final int initialSegment;

  @override
  ConsumerState<MoneyHubMarketsTab> createState() => _MoneyHubMarketsTabState();
}

class _MoneyHubMarketsTabState extends ConsumerState<MoneyHubMarketsTab> {
  late int _segment;

  @override
  void initState() {
    super.initState();
    _segment = widget.initialSegment.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: MoneyHubSegmentedControl(
            labels: [
              MoneyHubStrings.t('markets_segment_trend', locale),
              MoneyHubStrings.t('markets_segment_compare', locale),
            ],
            selectedIndex: _segment,
            onChanged: (i) => setState(() => _segment = i),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _segment,
            children: [
              _MarketsTrendPanel(
                ratesAsync: widget.ratesAsync,
                selectedCurrency: widget.selectedCurrency,
                onRefresh: widget.onRefresh,
              ),
              _MarketsComparePanel(
                ratesAsync: widget.ratesAsync,
                selectedCurrency: widget.selectedCurrency,
                amountController: widget.amountController,
                onRefresh: widget.onRefresh,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketsTrendPanel extends ConsumerWidget {
  const _MarketsTrendPanel({
    required this.ratesAsync,
    required this.selectedCurrency,
    required this.onRefresh,
  });

  final AsyncValue<ExchangeRates> ratesAsync;
  final String selectedCurrency;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return RefreshIndicator(
      color: moneyHubAccent,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: moneyHubScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ratesAsync.when(
              loading: () => const MoneyHubScreenLoading(cardCount: 2, cardHeight: 72),
              error: (_, _) => const SizedBox.shrink(),
              data: (rates) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: MoneyLiveChip(
                  label: rates.isDirectApi
                      ? MoneyHubStrings.t('markets_live_rate_history', locale)
                      : MoneyHubStrings.t(
                          'markets_indicative_rate_history',
                          locale,
                        ),
                  updatedAt: rates.lastUpdated,
                  isLive: !rates.isFallback,
                  accentColor: moneyHubAccent,
                  warningLabel: rates.isFallback
                      ? MoneyHubStrings.t(
                          'markets_approximate_rates_warning',
                          locale,
                        )
                      : null,
                ),
              ),
            ),
            MoneyHubSectionHeader(
              overline: MoneyHubStrings.t('markets_overline', locale),
              title: MoneyHubStrings.t('markets_trend_chart_title', locale),
              subtitle: MoneyHubStrings.t(
                'markets_tap_currency_expand_chart',
                locale,
              ),
              leadingIcon: Icons.show_chart_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            ...raabtaCurrencies.map((currency) {
              final isSelected = selectedCurrency == currency.code;
              return _TrendCard(currency: currency, isSelected: isSelected);
            }),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends ConsumerWidget {
  const _TrendCard({required this.currency, required this.isSelected});

  final CurrencyInfo currency;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final historyAsync = ref.watch(rateHistoryProvider(currency.code));

    return GestureDetector(
      onTap: () {
        moneyHubSelectionHaptic();
        ref.read(selectedCurrencyProvider.notifier).setCurrency(currency.code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: AppSpacing.radiusLg,
          glowColor: isSelected ? currency.chartColor : null,
          glowIntensity: isSelected ? 0.14 : 0,
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Text(currency.flag, style: TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currency.country} — ${currency.code}',
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currency.name,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ref.watch(liveExchangeRatesProvider).when(
                        loading: () => Text(
                          '—',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        error: (_, _) => Text(
                          '—',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        data: (rates) {
                          final rate = rates.rates[currency.code];
                          if (rate == null) {
                            return Text(
                              '—',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            );
                          }
                          return MoneyAnimatedFigure(
                            value: rate,
                            decimals: 2,
                            style: AppTypography.subtitle.copyWith(
                              color: currency.chartColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
            SizedBox(
              height: isSelected ? 120 : 70,
              child: historyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: GlassLoadingCard(height: 60),
                ),
                error: (_, _) => Center(
                  child: Text(
                    MoneyHubStrings.t('markets_chart_unavailable', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                data: (history) {
                  final validPoints =
                      history.where((p) => p.rate != null).toList();
                  if (validPoints.length < 2) {
                    return Center(
                      child: Text(
                        MoneyHubStrings.t('markets_not_enough_data', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    );
                  }

                  final minRate = validPoints
                      .map((p) => p.rate!)
                      .reduce((a, b) => a < b ? a : b);
                  final maxRate = validPoints
                      .map((p) => p.rate!)
                      .reduce((a, b) => a > b ? a : b);
                  final range = maxRate - minRate;
                  final padding = range == 0 ? 0.5 : range * 0.1;

                  final firstRate = validPoints.first.rate!;
                  final lastRate = validPoints.last.rate!;
                  final isUp = lastRate >= firstRate;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 14, 8),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: isSelected,
                          drawVerticalLine: false,
                          horizontalInterval: range == 0 ? 1 : range / 3,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withValues(alpha: 0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: isSelected,
                              reservedSize: 40,
                              getTitlesWidget: (val, _) => Text(
                                val.toStringAsFixed(1),
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: isSelected,
                              getTitlesWidget: (val, _) {
                                final idx = val.toInt();
                                if (idx < 0 || idx >= validPoints.length) {
                                  return const SizedBox.shrink();
                                }
                                final date = validPoints[idx].date;
                                final parts = date.split('-');
                                return Text(
                                  '${parts[2]}/${parts[1]}',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 8,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (validPoints.length - 1).toDouble(),
                        minY: minRate - padding,
                        maxY: maxRate + padding,
                        lineBarsData: [
                          LineChartBarData(
                            spots: validPoints
                                .asMap()
                                .entries
                                .map(
                                  (e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.rate!,
                                  ),
                                )
                                .toList(),
                            isCurved: true,
                            color: isUp
                                ? currency.chartColor
                                : const Color(0xFFEF5350),
                            barWidth: isSelected ? 2.5 : 1.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: isSelected,
                              getDotPainter:
                                  (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 3,
                                color: currency.chartColor,
                                strokeWidth: 0,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  (isUp
                                          ? currency.chartColor
                                          : const Color(0xFFEF5350))
                                      .withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: isSelected,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots.map((s) {
                              final idx = s.x.toInt();
                              final date = idx < validPoints.length
                                  ? validPoints[idx].date
                                  : '';
                              return LineTooltipItem(
                                '$date\n${s.y.toStringAsFixed(3)} ${currency.code}',
                                TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (history) {
                final valid =
                    history.where((p) => p.rate != null).toList();
                if (valid.length < 2) return const SizedBox.shrink();
                final change = valid.last.rate! - valid.first.rate!;
                final pct = (change / valid.first.rate!) * 100;
                final isUp = change >= 0;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Row(
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        color: isUp ? AppColors.success : AppColors.error,
                        size: 14,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${isUp ? '+' : ''}${pct.toStringAsFixed(2)}% vs 7 days ago',
                        style: AppTypography.caption.copyWith(
                          color: isUp ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        ),
      ),
    );

  }
}


class _MarketsComparePanel extends ConsumerWidget {
  const _MarketsComparePanel({
    required this.ratesAsync,
    required this.selectedCurrency,
    required this.amountController,
    required this.onRefresh,
  });

  final AsyncValue<ExchangeRates> ratesAsync;
  final String selectedCurrency;
  final TextEditingController amountController;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final compareAsync =
        ref.watch(exchangeCompareProvider(selectedCurrency));
    final currency = raabtaCurrencies.firstWhere(
      (c) => c.code == selectedCurrency,
      orElse: () => raabtaCurrencies.first,
    );

    return RefreshIndicator(
      color: moneyHubAccent,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: moneyHubScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ratesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (rates) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: MoneyLiveChip(
                  label: MoneyHubStrings.t(
                    'markets_exchange_house_comparison',
                    locale,
                  ),
                  updatedAt: rates.lastUpdated,
                  isLive: !rates.isFallback,
                  accentColor: moneyHubAccent,
                ),
              ),
            ),
            MoneyHubSectionHeader(
              overline: MoneyHubStrings.t('markets_compare_overline', locale),
              title: MoneyHubStrings.format(
                'markets_exchange_houses_title',
                locale,
                params: {'flag': currency.flag},
              ),
              subtitle: MoneyHubStrings.format(
                'markets_walk_in_rates_for_code',
                locale,
                params: {'code': currency.code},
              ),
              leadingIcon: Icons.storefront_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _CompareAmountField(amountController: amountController),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: raabtaCurrencies.map((curr) {
                final isSelected = selectedCurrency == curr.code;
                return GestureDetector(
                  onTap: () {
                    moneyHubSelectionHaptic();
                    ref.read(selectedCurrencyProvider.notifier).setCurrency(
                          curr.code,
                        );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? curr.chartColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? curr.chartColor
                            : (AppColors.isLight
                                ? AppColors.glassBorder
                                : Colors.white24),
                      ),
                    ),
                    child: Text(
                      '${curr.flag} ${curr.code}',
                      style: AppTypography.chipLabel.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          compareAsync.when(
            loading: () => _compareShimmer(),
            error: (_, _) => _MarketsErrorCard(onRetry: onRefresh, locale: locale),
            data: (houses) {
              if (houses.isEmpty) {
                return GlassEmptyState(
                  icon: Icons.storefront_outlined,
                  title: MoneyHubStrings.t(
                    'markets_comparison_unavailable',
                    locale,
                  ),
                  description: MoneyHubStrings.t(
                    'markets_check_connection_retry',
                    locale,
                  ),
                  actionLabel: MoneyHubStrings.t('markets_retry', locale),
                  onAction: onRefresh,
                );
              }
              return Column(
                children: houses
                    .asMap()
                    .entries
                    .map(
                      (entry) => _HouseCard(
                        house: entry.value,
                        isTop: entry.key == 0,
                        currency: currency,
                        amount: ref.watch(converterAmountProvider),
                        locale: locale,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: AppSpacing.radiusSm,
            backgroundColor: AppColors.warning.withValues(alpha: 0.08),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    MoneyHubStrings.t('markets_rates_disclaimer', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
      ),
    );
  }
}

class _CompareAmountField extends ConsumerWidget {
  const _CompareAmountField({required this.amountController});
  final TextEditingController amountController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final amount = ref.watch(converterAmountProvider);
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppSpacing.radiusSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MoneyHubStrings.t('markets_amount_to_send', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  style: AppTypography.tabular(
                    AppTypography.title.copyWith(color: AppColors.textPrimary),
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: '0',
                  ),
                  onChanged: (val) {
                    final parsed = double.tryParse(val) ?? 0;
                    ref.read(converterAmountProvider.notifier).state = parsed;
                  },
                ),
              ),
              Text(
                'QR',
                style: AppTypography.subtitle.copyWith(
                  color: moneyHubAccent,
                ),
              ),
            ],
          ),
          if (amount <= 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                MoneyHubStrings.t('markets_enter_amount_hint', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HouseCard extends StatelessWidget {
  const _HouseCard({
    required this.house,
    required this.isTop,
    required this.currency,
    required this.amount,
    required this.locale,
  });

  final ExchangeHouseRate house;
  final bool isTop;
  final CurrencyInfo currency;
  final double amount;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final receives = amount * house.rate;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      glowColor: isTop ? moneyHubAccent : null,
      glowIntensity: isTop ? 0.15 : 0,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isTop
                      ? moneyHubAccent
                      : (AppColors.isLight
                          ? AppColors.glassSurface
                          : Colors.white12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isTop ? '🥇' : (house.rating > 4.3 ? '🥈' : ''),
                    style: TextStyle(
                      color: isTop ? Colors.black : AppColors.textSecondary,
                      fontSize: isTop ? 14 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            house.name,
                            style: AppTypography.subtitle.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isTop) ...[
                          const SizedBox(width: AppSpacing.xs),
                          StatusBadge(
                            label: MoneyHubStrings.t(
                              'markets_best_rate',
                              locale,
                            ),
                            color: moneyHubAccent,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < house.rating.floor()
                                ? Icons.star
                                : i < house.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: moneyHubAccent,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          house.rating.toStringAsFixed(1),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        if (house.hasApp) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.phone_android,
                            color: AppColors.cyanGlow,
                            size: 11,
                          ),
                          Flexible(
                            child: Text(
                              ' App',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.cyanGlow,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '1 QR = ${house.rate.toStringAsFixed(3)}',
                    style: AppTypography.tabular(
                      AppTypography.subtitle.copyWith(
                        color: isTop ? moneyHubAccent : currency.chartColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    currency.code,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (amount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.isLight
                    ? AppColors.glassSurface
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      '${amount.toStringAsFixed(0)} QR',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.textTertiary,
                    size: 14,
                  ),
                  const Spacer(),
                  Flexible(
                    child: MoneyAnimatedFigure(
                      value: receives,
                      decimals: 0,
                      suffix: ' ${currency.code}',
                      style: AppTypography.subtitle.copyWith(
                        color: isTop ? moneyHubAccent : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      house.fee == 'Free' ? '✓ No fee' : '+ ${house.fee} fee',
                      style: AppTypography.caption.copyWith(
                        color:
                            house.fee == 'Free' ? AppColors.success : AppColors.warning,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (house.website != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final url = Uri.parse(house.website!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isTop
                          ? moneyHubAccent
                          : (AppColors.isLight
                              ? AppColors.glassBorder
                              : Colors.white24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Visit ${house.name.split(' ').first}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isTop ? moneyHubAccent : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

Widget _compareShimmer() {
  return Column(
    children: List.generate(
      4,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: GlassLoadingCard(height: 80),
      ),
    ),
  );
}

class _MarketsErrorCard extends StatelessWidget {
  const _MarketsErrorCard({
    required this.onRetry,
    required this.locale,
  });

  final VoidCallback onRetry;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassEmptyState(
      icon: Icons.wifi_off,
      title: MoneyHubStrings.t('markets_could_not_load_rates', locale),
      description: MoneyHubStrings.t('markets_check_connection_retry', locale),
      actionLabel: MoneyHubStrings.t('markets_tap_to_retry', locale),
      onAction: onRetry,
    );
  }
}
