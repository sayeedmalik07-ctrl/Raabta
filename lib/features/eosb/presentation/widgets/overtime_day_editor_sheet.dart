import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';

typedef OvertimeDayEditorSave = Future<void> Function(OvertimeDayEntry updated);

Future<void> showOvertimeDayEditorSheet({
  required BuildContext context,
  required String locale,
  required OvertimeDayEntry day,
  required OvertimeDayEditorSave onSave,
  String? draftFormId,
}) async {
  final hoursCtrl = TextEditingController(text: '${day.overtimeHours}');
  final minsCtrl = TextEditingController(text: '${day.overtimeMinutes}');
  final notesCtrl = TextEditingController(text: day.notes);
  final holidayCtrl = TextEditingController(text: day.holidayName);
  var category = day.dayCategory;
  var shift = day.shiftType;
  String? userStart = day.userLoggedStartTime;
  String? userEnd = day.userLoggedEndTime;
  String? employerStart = day.employerReportedStartTime;
  String? employerEnd = day.employerReportedEndTime;

  Map<String, dynamic> serialize() => {
        'hours': hoursCtrl.text,
        'minutes': minsCtrl.text,
        'notes': notesCtrl.text,
        'holiday': holidayCtrl.text,
        'category': category.name,
        'shift': shift.name,
        'userStart': userStart,
        'userEnd': userEnd,
        'employerStart': employerStart,
        'employerEnd': employerEnd,
      };

  void applyDraft(Map<String, dynamic> data, void Function(void Function()) setSheetState) {
    setSheetState(() {
      hoursCtrl.text = data['hours']?.toString() ?? '';
      minsCtrl.text = data['minutes']?.toString() ?? '';
      notesCtrl.text = data['notes']?.toString() ?? '';
      holidayCtrl.text = data['holiday']?.toString() ?? '';
      category = OvertimeDayCategory.values.byName(
        data['category']?.toString() ?? day.dayCategory.name,
      );
      shift = OvertimeShiftType.values.byName(
        data['shift']?.toString() ?? day.shiftType.name,
      );
      userStart = data['userStart']?.toString();
      userEnd = data['userEnd']?.toString();
      employerStart = data['employerStart']?.toString();
      employerEnd = data['employerEnd']?.toString();
    });
  }

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Widget buildContent(DraftSheetHandle? draft) {
              void notifyDraft() => draft?.notifyChanged();

              Future<void> pickCategory() async {
                final picked = await showCalculatorPickerSheet<OvertimeDayCategory>(
                  context: ctx,
                  title: EosbStrings.t('ot_day_category', locale),
                  selected: category,
                  options: OvertimeDayCategory.values
                      .map(
                        (c) => CalculatorPickerOption(
                          value: c,
                          label: _categoryLabel(c, locale),
                        ),
                      )
                      .toList(),
                );
                if (picked != null) {
                  setSheetState(() => category = picked);
                  notifyDraft();
                }
              }

              Future<void> pickShift() async {
                final picked = await showCalculatorPickerSheet<OvertimeShiftType>(
                  context: ctx,
                  title: EosbStrings.t('ot_shift_type', locale),
                  selected: shift,
                  options: OvertimeShiftType.values
                      .map(
                        (s) => CalculatorPickerOption(
                          value: s,
                          label: EosbStrings.t('ot_shift_${s.name}', locale),
                        ),
                      )
                      .toList(),
                );
                if (picked != null) {
                  setSheetState(() => shift = picked);
                  notifyDraft();
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${day.date.day} ${day.dayName}',
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CalculatorFormSection(
                        glowColor: AppColors.cyanGlow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CalculatorPickerField(
                              label: EosbStrings.t('ot_day_category', locale),
                              valueLabel: _categoryLabel(category, locale),
                              onTap: pickCategory,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            CalculatorPickerField(
                              label: EosbStrings.t('ot_shift_type', locale),
                              valueLabel:
                                  EosbStrings.t('ot_shift_${shift.name}', locale),
                              onTap: pickShift,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: CalculatorTextField(
                                    controller: hoursCtrl,
                                    label: EosbStrings.t('ot_hours', locale),
                                    hint: '0',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => notifyDraft(),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: CalculatorTextField(
                                    controller: minsCtrl,
                                    label: EosbStrings.t('ot_minutes', locale),
                                    hint: '0',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => notifyDraft(),
                                  ),
                                ),
                              ],
                            ),
                            if (category == OvertimeDayCategory.publicHoliday) ...[
                              const SizedBox(height: AppSpacing.lg),
                              CalculatorTextField(
                                controller: holidayCtrl,
                                label: EosbStrings.t('ot_holiday_name', locale),
                                hint: EosbStrings.t('ot_holiday_name', locale),
                                icon: Icons.celebration_outlined,
                                onChanged: (_) => notifyDraft(),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            CalculatorTextField(
                              controller: notesCtrl,
                              label: EosbStrings.t('ot_notes', locale),
                              hint: EosbStrings.t('ot_notes', locale),
                              icon: Icons.notes_outlined,
                              onChanged: (_) => notifyDraft(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CalculatorFormSection(
                        glowColor: AppColors.sharePurple,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              EosbStrings.t('ot_shift_times_section', locale),
                              style: AppTypography.title.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _ShiftTimeField(
                                    label: EosbStrings.t('ot_shift_user_start', locale),
                                    value: userStart,
                                    onPick: () async {
                                      final picked = await _pickTime(
                                        ctx,
                                        userStart,
                                      );
                                      if (picked != null) {
                                        setSheetState(() => userStart = picked);
                                        notifyDraft();
                                      }
                                    },
                                    onClear: userStart == null
                                        ? null
                                        : () {
                                            setSheetState(() => userStart = null);
                                            notifyDraft();
                                          },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _ShiftTimeField(
                                    label: EosbStrings.t('ot_shift_user_end', locale),
                                    value: userEnd,
                                    onPick: () async {
                                      final picked = await _pickTime(
                                        ctx,
                                        userEnd,
                                      );
                                      if (picked != null) {
                                        setSheetState(() => userEnd = picked);
                                        notifyDraft();
                                      }
                                    },
                                    onClear: userEnd == null
                                        ? null
                                        : () {
                                            setSheetState(() => userEnd = null);
                                            notifyDraft();
                                          },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _ShiftTimeField(
                                    label: EosbStrings.t(
                                      'ot_shift_employer_start',
                                      locale,
                                    ),
                                    value: employerStart,
                                    onPick: () async {
                                      final picked = await _pickTime(
                                        ctx,
                                        employerStart,
                                      );
                                      if (picked != null) {
                                        setSheetState(
                                          () => employerStart = picked,
                                        );
                                        notifyDraft();
                                      }
                                    },
                                    onClear: employerStart == null
                                        ? null
                                        : () {
                                            setSheetState(
                                              () => employerStart = null,
                                            );
                                            notifyDraft();
                                          },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _ShiftTimeField(
                                    label: EosbStrings.t(
                                      'ot_shift_employer_end',
                                      locale,
                                    ),
                                    value: employerEnd,
                                    onPick: () async {
                                      final picked = await _pickTime(
                                        ctx,
                                        employerEnd,
                                      );
                                      if (picked != null) {
                                        setSheetState(() => employerEnd = picked);
                                        notifyDraft();
                                      }
                                    },
                                    onClear: employerEnd == null
                                        ? null
                                        : () {
                                            setSheetState(() => employerEnd = null);
                                            notifyDraft();
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GlassPrimaryButton(
                        label: EosbStrings.t('ot_save_day', locale),
                        expand: true,
                        accentColor: AppColors.cyanGlow,
                        onPressed: () async {
                          await onSave(
                            OvertimeDayEntry(
                              date: day.date,
                              dayCategory: category,
                              shiftType: shift,
                              overtimeHours:
                                  int.tryParse(hoursCtrl.text.trim()) ?? 0,
                              overtimeMinutes:
                                  (int.tryParse(minsCtrl.text.trim()) ?? 0)
                                      .clamp(0, 59),
                              notes: notesCtrl.text.trim(),
                              holidayName: holidayCtrl.text.trim(),
                              userLoggedStartTime: userStart,
                              userLoggedEndTime: userEnd,
                              employerReportedStartTime: employerStart,
                              employerReportedEndTime: employerEnd,
                            ),
                          );
                          await draft?.clearDraft();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (draftFormId != null) {
              return DraftAwareSheet(
                formId: draftFormId,
                controllers: [hoursCtrl, minsCtrl, notesCtrl, holidayCtrl],
                serialize: serialize,
                applyDraft: (data) => applyDraft(data, setSheetState),
                builder: (context, draft) => buildContent(draft),
              );
            }

            return buildContent(null);
          },
        );
      },
    );
  } finally {
    hoursCtrl.dispose();
    minsCtrl.dispose();
    notesCtrl.dispose();
    holidayCtrl.dispose();
  }
}

String _categoryLabel(OvertimeDayCategory cat, String locale) {
  return switch (cat) {
    OvertimeDayCategory.regularDay => EosbStrings.t('ot_cat_weekday', locale),
    OvertimeDayCategory.weeklyRestDay =>
      EosbStrings.t('ot_cat_restday', locale),
    OvertimeDayCategory.publicHoliday =>
      EosbStrings.t('ot_cat_holiday', locale),
    OvertimeDayCategory.nightShift => EosbStrings.t('ot_cat_night', locale),
    OvertimeDayCategory.emergencyCallOut =>
      EosbStrings.t('ot_cat_emergency', locale),
    OvertimeDayCategory.standby => EosbStrings.t('ot_cat_standby', locale),
    OvertimeDayCategory.custom => EosbStrings.t('ot_cat_custom', locale),
  };
}

Future<String?> _pickTime(BuildContext context, String? current) async {
  final initial = _parseTimeOfDay(current) ?? TimeOfDay.now();
  final picked = await showTimePicker(
    context: context,
    initialTime: initial,
  );
  if (picked == null) return null;
  return _formatTime(picked);
}

TimeOfDay? _parseTimeOfDay(String? value) {
  if (value == null || !value.contains(':')) return null;
  final parts = value.trim().split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
}

String _formatTime(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _ShiftTimeField extends StatelessWidget {
  const _ShiftTimeField({
    required this.label,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CalculatorPickerField(
            label: label,
            valueLabel: value ?? '—',
            onTap: onPick,
            icon: Icons.schedule_outlined,
          ),
        ),
        if (onClear != null) ...[
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: onClear,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}
