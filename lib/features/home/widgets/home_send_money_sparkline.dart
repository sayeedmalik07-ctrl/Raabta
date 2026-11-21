import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Kit v2.1 gold send-money 7-day sparkline ([`.card.f.gold.rate`]).
class HomeSendMoneySparkline extends StatelessWidget {
  const HomeSendMoneySparkline({
    super.key,
    required this.values,
    this.height = HomeCardTier.sendMoneyRateSparklineHeight,
  });

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(height: height);

    final lineColor = AppColors.goldFamilyMain;
    final fillAmber = AppColors.accentGold;

    var minV = values.reduce((a, b) => a < b ? a : b);
    var maxV = values.reduce((a, b) => a > b ? a : b);
    final spread = maxV - minV;
    final pad = spread > 0.0001
        ? (spread * 0.18).clamp(0.02, 999.0)
        : (minV.abs() * 0.006).clamp(0.04, 0.25);

    minV -= pad;
    maxV += pad;

    final spots = values
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SizedBox(
      width: double.infinity,
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: minV,
          maxY: maxV,
          clipData: const FlClipData.all(),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.26,
              color: lineColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fillAmber.withValues(alpha: 0.32),
                    fillAmber.withValues(alpha: 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}
