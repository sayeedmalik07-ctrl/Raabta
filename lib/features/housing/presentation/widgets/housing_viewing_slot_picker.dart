import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/features/housing/services/housing_viewing_reminder_service.dart';

class HousingViewingSlotDraft {
  HousingViewingSlotDraft({DateTime? date, TimeOfDay? time})
      : date = date ?? DateTime.now().add(const Duration(days: 1)),
        time = time ?? const TimeOfDay(hour: 10, minute: 0);

  DateTime date;
  TimeOfDay time;

  DateTime toDateTime() => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
}

class HousingViewingSlotPickerController {
  List<HousingViewingSlotDraft> _slots = [HousingViewingSlotDraft()];

  List<DateTime> collectFutureSlots() {
    final now = DateTime.now();
    return _slots
        .map((s) => s.toDateTime())
        .where((dt) => dt.isAfter(now))
        .toList(growable: false);
  }
}

class HousingViewingSlotPickerList extends StatefulWidget {
  const HousingViewingSlotPickerList({
    super.key,
    required this.locale,
    required this.controller,
    this.maxSlots = 3,
  });

  final String locale;
  final HousingViewingSlotPickerController controller;
  final int maxSlots;

  @override
  State<HousingViewingSlotPickerList> createState() =>
      HousingViewingSlotPickerListState();
}

class HousingViewingSlotPickerListState
    extends State<HousingViewingSlotPickerList> {
  List<HousingViewingSlotDraft> get _slots => widget.controller._slots;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _slots.length; i++) ...[
          _SlotRow(
            locale: widget.locale,
            draft: _slots[i],
            onChanged: () => setState(() {}),
          ),
          if (i < _slots.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
        if (_slots.length < widget.maxSlots) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => setState(() => _slots.add(HousingViewingSlotDraft())),
            icon: const Icon(Icons.add, color: AppColors.cyanGlow),
            label: Text(
              HousingViewingStrings.t('hv_add_slot', widget.locale),
              style: AppTypography.link,
            ),
          ),
        ],
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.locale,
    required this.draft,
    required this.onChanged,
  });

  final String locale;
  final HousingViewingSlotDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: draft.date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
              );
              if (picked != null) {
                draft.date = picked;
                onChanged();
              }
            },
            child: Text(
              '${HousingViewingStrings.t('hv_slot_date_label', locale)}: '
              '${draft.date.day}/${draft.date.month}/${draft.date.year}',
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: draft.time,
              );
              if (picked != null) {
                draft.time = picked;
                onChanged();
              }
            },
            child: Text(
              '${HousingViewingStrings.t('hv_slot_time_label', locale)}: '
              '${draft.time.format(context)}',
            ),
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> showHousingViewingSlotPickerDialog({
  required BuildContext context,
  required String locale,
  required List<DateTime> slots,
}) async {
  if (slots.length == 1) return slots.first;

  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(HousingViewingStrings.t('hv_pick_slot_title', locale)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final slot in slots)
            ListTile(
              title: Text(
                HousingViewingReminderService.formatSlot(slot, locale),
              ),
              onTap: () => Navigator.pop(ctx, slot),
            ),
        ],
      ),
    ),
  );
}
