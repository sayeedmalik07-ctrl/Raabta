import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class EosbBreakdownChart extends StatefulWidget {
  const EosbBreakdownChart({
    super.key,
    required this.result,
    required this.locale,
  });

  final EosbResult result;
  final String locale;

  @override
  State<EosbBreakdownChart> createState() => _EosbBreakdownChartState();
}

class _EosbBreakdownChartState extends State<EosbBreakdownChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _colors = [
    AppColors.emeraldGlow,
    AppColors.cyanGlow,
    AppColors.accentGold,
    AppColors.sharePurple,
    AppColors.heatOrange,
    AppColors.info,
    AppColors.successBright,
    AppColors.errorBright,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items =
        widget.result.breakdown.where((b) => b.amount > 0).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final total = items.fold<double>(0, (s, i) => s + i.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EosbStrings.t('eosb_breakdown_chart', widget.locale),
          style: AppTypography.title.copyWith(fontSize: 15),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 180,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: items.asMap().entries.map((e) {
                          final pct = (e.value.amount / total) * 100 * progress;
                          return PieChartSectionData(
                            value: e.value.amount * progress,
                            title: pct >= 8
                                ? '${pct.toStringAsFixed(0)}%'
                                : '',
                            color: _colors[e.key % _colors.length],
                            radius: 52 * (0.85 + 0.15 * progress),
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
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: Opacity(
                      opacity: progress,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: items.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _colors[e.key % _colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    EosbStrings.t(e.value.titleKey, widget.locale),
                                    style: AppTypography.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
