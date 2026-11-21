import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

const _weekdayKeys = [
  'day_mon',
  'day_tue',
  'day_wed',
  'day_thu',
  'day_fri',
  'day_sat',
  'day_sun',
];

/// Per-day open/closed + time range map keyed by weekday id (day_mon, …).
class PostOpeningHoursField extends StatelessWidget {
  const PostOpeningHoursField({
    super.key,
    required this.label,
    required this.locale,
    required this.value,
    required this.onChanged,
    this.error,
  });

  final String label;
  final String locale;
  final Map<String, dynamic>? value;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final String? error;

  Map<String, dynamic> _day(String key) {
    final raw = value?[key];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {'closed': true, 'open': '09:00', 'close': '18:00'};
  }

  void _updateDay(String key, Map<String, dynamic> day) {
    final next = Map<String, dynamic>.from(value ?? {});
    next[key] = day;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        for (final dayKey in _weekdayKeys) ...[
          _DayRow(
            dayLabel: PostEngineStrings.t(dayKey, locale),
            day: _day(dayKey),
            locale: locale,
            onChanged: (d) => _updateDay(dayKey, d),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}

class _DayRow extends StatefulWidget {
  const _DayRow({
    required this.dayLabel,
    required this.day,
    required this.locale,
    required this.onChanged,
  });

  final String dayLabel;
  final Map<String, dynamic> day;
  final String locale;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<_DayRow> {
  late final TextEditingController _open;
  late final TextEditingController _close;

  @override
  void initState() {
    super.initState();
    _open = TextEditingController(
      text: widget.day['open']?.toString() ?? '09:00',
    );
    _close = TextEditingController(
      text: widget.day['close']?.toString() ?? '18:00',
    );
  }

  @override
  void dispose() {
    _open.dispose();
    _close.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final closed = widget.day['closed'] == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(widget.dayLabel, style: AppTypography.body),
            ),
            Text(
              PostEngineStrings.t('field_hours_closed', widget.locale),
              style: AppTypography.caption,
            ),
            Switch(
              value: closed,
              onChanged: (v) => widget.onChanged({...widget.day, 'closed': v}),
            ),
          ],
        ),
        if (!closed)
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _open,
                  label: PostEngineStrings.t('field_hours_open', widget.locale),
                  onChanged: (v) =>
                      widget.onChanged({...widget.day, 'open': v}),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GlassTextField(
                  controller: _close,
                  label:
                      PostEngineStrings.t('field_hours_close', widget.locale),
                  onChanged: (v) =>
                      widget.onChanged({...widget.day, 'close': v}),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class PostStringListField extends StatefulWidget {
  const PostStringListField({
    super.key,
    required this.label,
    required this.locale,
    required this.items,
    required this.onChanged,
    this.placeholder,
    this.error,
  });

  final String label;
  final String locale;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;
  final String? placeholder;
  final String? error;

  @override
  State<PostStringListField> createState() => _PostStringListFieldState();
}

class _PostStringListFieldState extends State<PostStringListField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onChanged([...widget.items, text]);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GlassTextField(
                controller: _controller,
                hint: widget.placeholder,
                onSubmitted: (_) => _add(),
              ),
            ),
            IconButton(
              onPressed: _add,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.cyanGlow,
            ),
          ],
        ),
        if (widget.items.isNotEmpty)
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: widget.items.map((item) {
              return InputChip(
                label: Text(item),
                onDeleted: () {
                  widget.onChanged(
                    widget.items.where((e) => e != item).toList(),
                  );
                },
              );
            }).toList(),
          ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

List<String> coerceStringList(dynamic raw) =>
    PostSchemaValueCoercion.asStringList(raw);

Map<String, dynamic> coerceOpeningHours(dynamic raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return {};
}
