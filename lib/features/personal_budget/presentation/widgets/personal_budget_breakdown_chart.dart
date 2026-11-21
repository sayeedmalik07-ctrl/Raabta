import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';

class PersonalBudgetBreakdownChart extends StatelessWidget {
  const PersonalBudgetBreakdownChart({
    super.key,
    required this.segments,
    required this.locale,
  });

  final List<PersonalBudgetBreakdownSegment> segments;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return Text(
        PersonalBudgetStrings.t('pb_breakdown_empty', locale),
        style: AppTypography.bodySmall,
      );
    }

    final total = segments.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 170,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 34,
                    startDegreeOffset: -90,
                    sections: segments.map((seg) {
                      final pct = (seg.amount / total) * 100;
                      return PieChartSectionData(
                        value: seg.amount,
                        title: '${pct.toStringAsFixed(0)}%',
                        color: seg.color,
                        radius: 50,
                        titleStyle: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      );
                    }).toList(),
                  ),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: segments.map((seg) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: seg.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              PersonalBudgetStrings.t(seg.labelKey, locale),
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
            ],
          ),
        ),
      ],
    );
  }
}
