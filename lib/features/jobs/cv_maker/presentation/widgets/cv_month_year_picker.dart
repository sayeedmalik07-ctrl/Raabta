import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_builder_form_helpers.dart';

/// Month + year picker for CV dates (no day component).
Future<DateTime?> showCvMonthYearPicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  final first = firstDate ?? DateTime(now.year - 50);
  final last = lastDate ?? DateTime(now.year + 1, 12);
  var selected = initial ?? now;
  if (selected.isBefore(first)) selected = first;
  if (selected.isAfter(last)) selected = last;

  return showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      var month = selected.month;
      var year = selected.year;
      final years = List.generate(
        last.year - first.year + 1,
        (i) => first.year + i,
      );
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      return AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Select month & year', style: AppTypography.title),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Year', style: AppTypography.caption),
              const SizedBox(height: 4),
              DropdownButton<int>(
                value: year,
                isExpanded: true,
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (v) => setState(() => year = v ?? year),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Month', style: AppTypography.caption),
              const SizedBox(height: 4),
              DropdownButton<int>(
                value: month,
                isExpanded: true,
                items: List.generate(
                  12,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(months[i]),
                  ),
                ),
                onChanged: (v) => setState(() => month = v ?? month),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, DateTime(year, month, 1)),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

String formatCvMonthYear(DateTime? date) {
  if (date == null) return 'Not set';
  return DateFormat('MMM yyyy').format(date);
}

Widget cvMonthYearField({
  required String label,
  required DateTime? value,
  required VoidCallback onTap,
  bool enabled = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InputDecorator(
        decoration: cvBuilderFieldDecoration(labelText: label).copyWith(
          fillColor: enabled
              ? (AppColors.isLight ? AppColors.surface : AppColors.glassSurface)
              : AppColors.surface.withValues(alpha: 0.4),
        ),
        child: Text(
          formatCvMonthYear(value),
          style: AppTypography.body.copyWith(
            color: enabled ? null : AppColors.textTertiary,
          ),
        ),
      ),
    ),
  );
}
