import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';

class GoldTrendChart extends StatelessWidget {
  const GoldTrendChart({
    super.key,
    required this.points,
    required this.currentPrice,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.locale,
    this.periodChangePct,
  });

  final List<GoldHistoryPoint> points;
  final double currentPrice;
  final GoldChartRange selectedRange;
  final ValueChanged<GoldChartRange> onRangeChanged;
  final String locale;
  final double? periodChangePct;

  @override
  Widget build(BuildContext context) {
    final valid = points.where((p) => p.price > 0).toList();
    final hasChart = valid.length >= 2;

    double? minP;
    double? maxP;
    if (hasChart) {
      minP = valid.map((p) => p.price).reduce((a, b) => a < b ? a : b);
      maxP = valid.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    }

    final change = periodChangePct ??
        (hasChart && valid.first.price > 0
            ? ((valid.last.price - valid.first.price) / valid.first.price) * 100
            : 0.0);
    final isUp = change >= 0;
    final rangeLabel = GoldIntelligenceStrings.chartRangeLabel(selectedRange, locale);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      glowColor: AppColors.accentGold,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QAR ${currentPrice.toStringAsFixed(2)}',
                      style: AppTypography.headline2.copyWith(
                        color: AppColors.accentGold,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      GoldIntelligenceStrings.format(
                        'chart_subtitle_per_gram',
                        locale,
                        params: {'range': rangeLabel},
                      ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasChart)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isUp ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: (isUp ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.north_east : Icons.south_east,
                        size: 14,
                        color: isUp ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isUp ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _RangeSegmentedControl(
            selected: selectedRange,
            onChanged: onRangeChanged,
            locale: locale,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: hasChart
                ? _ChartBody(
                    points: valid,
                    minP: minP!,
                    maxP: maxP!,
                    showDots: selectedRange == GoldChartRange.today,
                  )
                : _EmptyChartHint(range: selectedRange, locale: locale),
          ),
          if (hasChart && minP != null && maxP != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RangeLabel(
                  label: GoldIntelligenceStrings.t('chart_low', locale),
                  value: minP,
                ),
                _RangeLabel(
                  label: GoldIntelligenceStrings.t('chart_high', locale),
                  value: maxP,
                  alignEnd: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RangeSegmentedControl extends StatelessWidget {
  const _RangeSegmentedControl({
    required this.selected,
    required this.onChanged,
    required this.locale,
  });

  final GoldChartRange selected;
  final ValueChanged<GoldChartRange> onChanged;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: GoldChartRange.values.map((range) {
          final isSelected = range == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  color: isSelected
                      ? AppColors.accentGold.withValues(alpha: 0.25)
                      : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentGold.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  GoldIntelligenceStrings.chartRangeLabel(range, locale),
                  style: AppTypography.caption.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accentGold
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartBody extends StatelessWidget {
  const _ChartBody({
    required this.points,
    required this.minP,
    required this.maxP,
    required this.showDots,
  });

  final List<GoldHistoryPoint> points;
  final double minP;
  final double maxP;
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    final pad = ((maxP - minP) * 0.12).clamp(0.05, 999.0);
    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price))
        .toList();

    return LineChart(
      LineChartData(
        minY: minP - pad,
        maxY: maxP + pad,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: pad > 0 ? pad : 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.glassBorder,
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceElevated.withValues(alpha: 0.95),
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                'QAR ${s.y.toStringAsFixed(2)}',
                AppTypography.caption.copyWith(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.28,
            color: AppColors.accentGold,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: showDots,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.accentGold,
                strokeWidth: 1.5,
                strokeColor: AppColors.background,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentGold.withValues(alpha: 0.28),
                  AppColors.accentGold.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartHint extends StatelessWidget {
  const _EmptyChartHint({required this.range, required this.locale});

  final GoldChartRange range;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 36,
            color: AppColors.accentGold.withValues(alpha: 0.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            range == GoldChartRange.today
                ? GoldIntelligenceStrings.t('chart_empty_intraday', locale)
                : GoldIntelligenceStrings.t('chart_empty_history', locale),
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeLabel extends StatelessWidget {
  const _RangeLabel({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final double value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
        Text(
          'QAR ${value.toStringAsFixed(2)}',
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
