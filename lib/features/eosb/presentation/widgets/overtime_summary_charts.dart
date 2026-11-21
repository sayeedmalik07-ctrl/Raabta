import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class OvertimeSummaryCharts extends StatelessWidget {
  const OvertimeSummaryCharts({
    super.key,
    required this.result,
    required this.locale,
  });

  final OvertimeTruthResult result;
  final String locale;

  static const _colors = [
    AppColors.cyanGlow,
    AppColors.accentGold,
    AppColors.emeraldGlow,
    AppColors.sharePurple,
    AppColors.heatOrange,
    AppColors.info,
  ];

  @override
  Widget build(BuildContext context) {
    final summary = result.summary;
    final categories = <(String, double)>[
      ('ot_cat_weekday', summary.regularDayHours),
      ('ot_cat_restday', summary.restDayHours),
      ('ot_cat_holiday', summary.holidayHours),
      ('ot_cat_night', summary.nightHours),
    ].where((e) => e.$2 > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categories.isNotEmpty) ...[
          Text(
            EosbStrings.t('ot_chart_categories', locale),
            style: AppTypography.title.copyWith(fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: categories.asMap().entries.map((e) {
                  final total = categories.fold<double>(0, (s, c) => s + c.$2);
                  final pct = total > 0 ? (e.value.$2 / total) * 100 : 0;
                  return PieChartSectionData(
                    value: e.value.$2,
                    title: '${pct.toStringAsFixed(0)}%',
                    color: _colors[e.key % _colors.length],
                    radius: 52,
                    titleStyle: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          EosbStrings.t('ot_chart_daily', locale),
          style: AppTypography.title.copyWith(fontSize: 15),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final day = value.toInt() + 1;
                      if (day % 5 != 1) return const SizedBox.shrink();
                      return Text('$day', style: AppTypography.caption);
                    },
                  ),
                ),
              ),
              barGroups: summary.dailyTotals.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      color: e.value > 0
                          ? AppColors.accentGold
                          : AppColors.surfaceElevated,
                      width: 6,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SummaryStatGrid(result: result, locale: locale),
      ],
    );
  }
}

class _SummaryStatGrid extends StatelessWidget {
  const _SummaryStatGrid({required this.result, required this.locale});

  final OvertimeTruthResult result;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final s = result.summary;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _MiniStat(
          label: EosbStrings.t('ot_avg_daily', locale),
          value: '${s.averageDailyOvertime.toStringAsFixed(1)}h',
        ),
        _MiniStat(
          label: EosbStrings.t('ot_days_recorded', locale),
          value: '${s.workingDaysRecorded}',
        ),
        _MiniStat(
          label: EosbStrings.t('ot_missing_days', locale),
          value: '${s.missingDays}',
        ),
        if (s.highestDay != null)
          _MiniStat(
            label: EosbStrings.t('ot_highest_day', locale),
            value:
                '${s.highestDay!.date.day} (${s.highestDay!.totalHours.toStringAsFixed(1)}h)',
          ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption),
            Text(value, style: AppTypography.title.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class OvertimeRateBreakdownCard extends StatelessWidget {
  const OvertimeRateBreakdownCard({
    super.key,
    required this.result,
    required this.locale,
  });

  final OvertimeTruthResult result;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final bd = result.rateBreakdown;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t('ot_rate_breakdown', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...bd.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(step, style: AppTypography.bodySmall),
            ),
          ),
          const Divider(height: AppSpacing.lg),
          _rateRow(
            EosbStrings.t('ot_hourly_rate', locale),
            formatEosbCurrency(bd.hourlyRate),
          ),
          _rateRow('Daily rate', formatEosbCurrency(bd.dailyRate)),
          _rateRow('Minute rate', bd.minuteRate.toStringAsFixed(4)),
        ],
      ),
    );
  }

  Widget _rateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.title.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
