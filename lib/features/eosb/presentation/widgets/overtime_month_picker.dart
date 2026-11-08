import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

/// Month/year selector wired to [OvertimeTruthNotifier.loadMonth].
class OvertimeMonthPickerField extends ConsumerWidget {
  const OvertimeMonthPickerField({super.key, required this.locale});

  final String locale;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Future<void> _pick(BuildContext context, WidgetRef ref, int year, int month) async {
    var selectedYear = year;
    var selectedMonth = month;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    EosbStrings.t('ot_select_month', locale),
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            setSheetState(() => selectedYear -= 1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          '$selectedYear',
                          textAlign: TextAlign.center,
                          style: AppTypography.headline2,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setSheetState(() => selectedYear += 1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: List.generate(12, (index) {
                      final m = index + 1;
                      final selected = m == selectedMonth;
                      return ChoiceChip(
                        label: Text(
                          _monthNames[index].substring(0, 3),
                          style: AppTypography.caption,
                        ),
                        selected: selected,
                        onSelected: (_) =>
                            setSheetState(() => selectedMonth = m),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassPrimaryButton(
                    label: EosbStrings.t('ot_apply_month', locale),
                    expand: true,
                    accentColor: AppColors.cyanGlow,
                    onPressed: () {
                      ref
                          .read(overtimeTruthProvider.notifier)
                          .loadMonth(selectedYear, selectedMonth);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(overtimeTruthProvider).record;

    return CalculatorPickerField(
      label: EosbStrings.t('ot_pay_period', locale),
      valueLabel: record.label,
      onTap: () => _pick(context, ref, record.year, record.month),
    );
  }
}
