import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';

class KnowQatarProgressChart extends StatelessWidget {
  const KnowQatarProgressChart({
    super.key,
    required this.milestones,
    required this.locale,
  });

  final List<KnowQatarProgressMilestone> milestones;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          KnowQatarStrings.t('kq_progress_title', locale),
          style: AppTypography.title.copyWith(fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.glassBorder),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: milestones.map((m) {
              final color = Color(m.colorValue);
              final pct = (m.progress * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            KnowQatarStrings.t(m.labelKey, locale),
                            style: AppTypography.bodySmall,
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: AppTypography.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: m.progress.clamp(0, 1),
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class KnowQatarEconomyBarChart extends StatelessWidget {
  const KnowQatarEconomyBarChart({
    super.key,
    required this.milestones,
    required this.locale,
  });

  final List<KnowQatarProgressMilestone> milestones;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 1,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= milestones.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${(milestones[i].progress * 100).round()}%',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: milestones.asMap().entries.map((entry) {
            final m = entry.value;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: m.progress.clamp(0, 1),
                  color: Color(m.colorValue),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
