import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/models/admin_stats.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';

class AdminAiUsageScreen extends ConsumerWidget {
  const AdminAiUsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(aiUsageStatsProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'AI Usage'),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(aiUsageStatsProvider);
            await ref.read(aiUsageStatsProvider.future);
          },
          child: statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [Text('Error: $e')],
            ),
            data: (stats) {
              if (!stats.loggingAvailable) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: const Text(
                        'Live data from ai_usage_logs (last 30 days). '
                        'Deploy the latest server.js for model routing and caps.',
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    'Estimated cost: ${stats.estimatedCostQr.toStringAsFixed(2)} QR',
                    style: AppTypography.headline2,
                  ),
                  Text(
                    'Rate: ${stats.costPer1kTokens} QR / 1K tokens',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Daily volume (30 days)', style: AppTypography.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 200,
                    child: _DailyLineChart(data: stats.dailyCalls),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('By feature', style: AppTypography.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 220,
                    child: _FeatureBarChart(data: stats.byFeature),
                  ),
                  if (stats.byModel.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text('By model', style: AppTypography.subtitle),
                    const SizedBox(height: AppSpacing.sm),
                    ...stats.byModel.entries.map(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.key),
                        trailing: Text('${e.value} calls'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text('Top 10 users', style: AppTypography.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  ...stats.topUsers.map(
                    (u) => ListTile(
                      title: Text(u.displayName),
                      subtitle: Text(u.userId),
                      trailing: Text('${u.count} calls'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DailyLineChart extends StatelessWidget {
  const _DailyLineChart({required this.data});
  final List<DailyAiUsage> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].count.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AdminAppBar.adminAccent,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AdminAppBar.adminAccent.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBarChart extends StatelessWidget {
  const _FeatureBarChart({required this.data});
  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No feature breakdown'));
    }

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    entries[index].key,
                    style: const TextStyle(fontSize: 8),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  color: AppColors.cyanGlow,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
