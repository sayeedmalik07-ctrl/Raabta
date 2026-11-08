import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';

class OvertimeMonthGrid extends StatelessWidget {
  const OvertimeMonthGrid({
    super.key,
    required this.days,
    required this.locale,
    required this.onDayTap,
  });

  final List<OvertimeDayEntry> days;
  final String locale;
  final void Function(int index, OvertimeDayEntry day) onDayTap;

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final first = days.first.date;
    final leadingBlanks = first.weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: _weekdayLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(label, style: AppTypography.caption),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: AppSpacing.xs,
            crossAxisSpacing: AppSpacing.xs,
            childAspectRatio: 0.85,
          ),
          itemCount: leadingBlanks + days.length,
          itemBuilder: (context, gridIndex) {
            if (gridIndex < leadingBlanks) {
              return const SizedBox.shrink();
            }
            final index = gridIndex - leadingBlanks;
            final day = days[index];
            return _DayCell(
              day: day,
              locale: locale,
              onTap: () => onDayTap(index, day),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.locale,
    required this.onTap,
  });

  final OvertimeDayEntry day;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasOt = day.totalHours > 0;
    final isToday = _isToday(day.date);

    return Material(
      color: hasOt
          ? AppColors.accentGold.withValues(alpha: 0.12)
          : AppColors.glassSurface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            border: Border.all(
              color: isToday
                  ? AppColors.cyanGlow
                  : hasOt
                      ? AppColors.accentGold.withValues(alpha: 0.4)
                      : AppColors.glassBorder,
              width: isToday ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.date.day}',
                style: AppTypography.title.copyWith(
                  fontSize: 13,
                  color: isToday ? AppColors.cyanGlow : null,
                ),
              ),
              if (hasOt) ...[
                const SizedBox(height: 2),
                Text(
                  '${day.overtimeHours}h',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentGold,
                    fontSize: 9,
                  ),
                ),
              ] else
                Text(
                  '·',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
