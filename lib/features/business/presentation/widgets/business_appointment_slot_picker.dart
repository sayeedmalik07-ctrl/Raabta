import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/business/presentation/l10n/business_appointment_strings.dart';

class BusinessAppointmentSlotDraft {
  BusinessAppointmentSlotDraft({DateTime? date, TimeOfDay? time})
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

class BusinessAppointmentSlotPickerController {
  List<BusinessAppointmentSlotDraft> _slots = [BusinessAppointmentSlotDraft()];

  List<DateTime> collectFutureSlots() {
    final now = DateTime.now();
    return _slots
        .map((s) => s.toDateTime())
        .where((dt) => dt.isAfter(now))
        .toList(growable: false);
  }
}

class BusinessAppointmentSlotPickerList extends StatefulWidget {
  const BusinessAppointmentSlotPickerList({
    super.key,
    required this.locale,
    required this.controller,
    this.maxSlots = 3,
  });

  final String locale;
  final BusinessAppointmentSlotPickerController controller;
  final int maxSlots;

  @override
  State<BusinessAppointmentSlotPickerList> createState() =>
      BusinessAppointmentSlotPickerListState();
}

class BusinessAppointmentSlotPickerListState
    extends State<BusinessAppointmentSlotPickerList> {
  List<BusinessAppointmentSlotDraft> get _slots => widget.controller._slots;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _slots.length; i++) ...[
          _SlotRow(
            draft: _slots[i],
            onChanged: () => setState(() {}),
          ),
          if (i < _slots.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
        if (_slots.length < widget.maxSlots) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => setState(() => _slots.add(BusinessAppointmentSlotDraft())),
            icon: const Icon(Icons.add, color: AppColors.cyanGlow),
            label: Text(
              BusinessAppointmentStrings.t('biz_appt_add_slot', widget.locale),
              style: AppTypography.link,
            ),
          ),
        ],
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.draft, required this.onChanged});

  final BusinessAppointmentSlotDraft draft;
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
            child: Text('${draft.date.day}/${draft.date.month}/${draft.date.year}'),
          ),
        ),
        const SizedBox(width: 8),
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
            child: Text(draft.time.format(context)),
          ),
        ),
      ],
    );
  }
}
