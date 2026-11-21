import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';

class TripBudgetChart extends StatelessWidget {
  const TripBudgetChart({
    super.key,
    required this.budget,
    required this.locale,
    required this.currency,
  });

  final BudgetBreakdown budget;
  final String locale;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final sections = [
      _Section('Tickets', budget.tickets, AppColors.cyanGlow),
      _Section('Food', budget.food, AppColors.emeraldGlow),
      _Section('Transport', budget.transport, AppColors.purpleGlow),
      _Section('Shopping', budget.shopping, AppColors.amberGlow),
      _Section('Hotel', budget.hotel, AppColors.tealGlow),
      _Section('Other', budget.miscellaneous + budget.parking, AppColors.roseGlow),
    ].where((s) => s.value > 0).toList();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TripStrings.t('trip_budget', locale), style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: sections.isEmpty
                ? Center(child: Text(TripStrings.t('trip_no_costs_yet', locale)))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sections
                          .map(
                            (s) => PieChartSectionData(
                              value: s.value,
                              title: '${s.value.round()}',
                              color: s.color,
                              radius: 50,
                              titleStyle: AppTypography.chipLabel.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...sections.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(s.label, style: AppTypography.bodySmall),
                    ],
                  ),
                  Text(
                    formatTripCurrency(s.value, symbol: currency),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.glassBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TripStrings.t('trip_remaining', locale),
                style: AppTypography.title,
              ),
              Text(
                formatTripCurrency(budget.remaining, symbol: currency),
                style: AppTypography.headline2.copyWith(
                  color: budget.isOverBudget
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section {
  _Section(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class TripTimelineWidget extends StatelessWidget {
  const TripTimelineWidget({
    super.key,
    required this.activities,
    required this.locale,
    required this.onActivityTap,
  });

  final List<TripActivity> activities;
  final String locale;
  final ValueChanged<TripActivity> onActivityTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final act = activities[index];
        final isLast = index == activities.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    Text(act.startTime, style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _colorForType(act.type),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.glassBorderBright,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.md,
                    left: AppSpacing.sm,
                  ),
                  child: GlassCard(
                    onTap: () => onActivityTap(act),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(act.title, style: AppTypography.title),
                        if (act.description.isNotEmpty)
                          Text(
                            act.description,
                            style: AppTypography.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (act.estimatedCost > 0 || act.entryFee > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xxs),
                            child: Text(
                              formatTripCurrency(
                                act.estimatedCost + act.entryFee,
                              ),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.cyanGlow,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _colorForType(TripActivityType type) {
    switch (type) {
      case TripActivityType.restaurant:
        return AppColors.emeraldGlow;
      case TripActivityType.prayer:
        return AppColors.tealGlow;
      case TripActivityType.shopping:
        return AppColors.amberGlow;
      case TripActivityType.transport:
        return AppColors.purpleGlow;
      default:
        return AppColors.cyanGlow;
    }
  }
}
