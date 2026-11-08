import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_change_of_plans_service.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/features/trip_planner/services/trip_flight_reminder_service.dart';
import 'package:raabta/features/trip_planner/services/trip_planner_analytics_service.dart';

class TripChangeOfPlansSection extends ConsumerWidget {
  const TripChangeOfPlansSection({
    super.key,
    required this.trip,
    required this.locale,
  });

  final TripPlan trip;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUndo = ref.watch(tripChangeOfPlansUndoAvailableProvider(trip.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trip.itineraryDatesRevision > 0) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.08,
            child: Text(
              TripStrings.t('trip_schedule_stale_hint', locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (trip.scheduleNeedsReview) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.warning,
            glowIntensity: 0.1,
            child: Text(
              TripStrings.t('trip_booking_review_hint', locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        OutlinedButton.icon(
          onPressed: () => _openSheet(context, ref),
          icon: const Icon(Icons.date_range_outlined, size: 18),
          label: Text(TripStrings.t('trip_change_of_plans', locale)),
        ),
        if (canUndo) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () async {
              TripPlannerAnalyticsService.changeOfPlansUndo();
              await ref
                  .read(tripPlannerProvider.notifier)
                  .undoChangeOfPlans(trip.id);
            },
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: Text(TripStrings.t('trip_change_of_plans_undo', locale)),
          ),
        ],
      ],
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _ChangeOfPlansSheet(trip: trip, locale: locale),
    );
  }
}

class _ChangeOfPlansSheet extends ConsumerStatefulWidget {
  const _ChangeOfPlansSheet({required this.trip, required this.locale});

  final TripPlan trip;
  final String locale;

  @override
  ConsumerState<_ChangeOfPlansSheet> createState() =>
      _ChangeOfPlansSheetState();
}

class _ChangeOfPlansSheetState extends ConsumerState<_ChangeOfPlansSheet> {
  _PlanMode _mode = _PlanMode.shift;
  int _count = 1;
  int _shiftDelta = 1;
  bool _shiftForward = true;

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TripStrings.t('trip_change_of_plans', locale),
            style: AppTypography.headline2,
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<_PlanMode>(
            segments: [
              ButtonSegment(
                value: _PlanMode.shift,
                label: Text(TripStrings.t('trip_cop_shift', locale)),
              ),
              ButtonSegment(
                value: _PlanMode.trimStart,
                label: Text(TripStrings.t('trip_cop_trim_start', locale)),
              ),
              ButtonSegment(
                value: _PlanMode.trimEnd,
                label: Text(TripStrings.t('trip_cop_trim_end', locale)),
              ),
              ButtonSegment(
                value: _PlanMode.extendEnd,
                label: Text(TripStrings.t('trip_cop_extend', locale)),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildControls(locale),
          const SizedBox(height: AppSpacing.md),
          _PreviewBox(
            locale: locale,
            trip: widget.trip,
            mode: _mode,
            count: _effectiveCount(),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: TripStrings.t('trip_cop_apply', locale),
            icon: Icons.check_rounded,
            expand: true,
            onPressed: () async {
              final action = _toAction();
              TripPlannerAnalyticsService.changeOfPlansApplied(action.name);
              await ref.read(tripPlannerProvider.notifier).applyChangeOfPlans(
                    tripId: widget.trip.id,
                    action: action,
                    count: _effectiveCount(),
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControls(String locale) {
    if (_mode == _PlanMode.shift) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(TripStrings.t('trip_cop_shift_days', locale)),
              ),
              IconButton(
                onPressed: _shiftDelta > 1
                    ? () => setState(() => _shiftDelta--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_shiftDelta', style: AppTypography.title),
              IconButton(
                onPressed: _shiftDelta < 30
                    ? () => setState(() => _shiftDelta++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(TripStrings.t('trip_cop_shift_forward', locale)),
            value: _shiftForward,
            onChanged: (v) => setState(() => _shiftForward = v),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: Text(TripStrings.t('trip_cop_day_count', locale))),
        IconButton(
          onPressed: _count > 1 ? () => setState(() => _count--) : null,
          icon: const Icon(Icons.remove),
        ),
        Text('$_count', style: AppTypography.title),
        IconButton(
          onPressed: _count < 14 ? () => setState(() => _count++) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  int _effectiveCount() {
    if (_mode == _PlanMode.shift) {
      return _shiftForward ? _shiftDelta : -_shiftDelta;
    }
    return _count;
  }

  TripChangeOfPlansAction _toAction() {
    return switch (_mode) {
      _PlanMode.shift => TripChangeOfPlansAction.shiftDays,
      _PlanMode.trimStart => TripChangeOfPlansAction.trimFromStart,
      _PlanMode.trimEnd => TripChangeOfPlansAction.trimFromEnd,
      _PlanMode.extendEnd => TripChangeOfPlansAction.extendAtEnd,
    };
  }
}

enum _PlanMode { shift, trimStart, trimEnd, extendEnd }

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({
    required this.locale,
    required this.trip,
    required this.mode,
    required this.count,
  });

  final String locale;
  final TripPlan trip;
  final _PlanMode mode;
  final int count;

  @override
  Widget build(BuildContext context) {
    final action = switch (mode) {
      _PlanMode.shift => TripChangeOfPlansAction.shiftDays,
      _PlanMode.trimStart => TripChangeOfPlansAction.trimFromStart,
      _PlanMode.trimEnd => TripChangeOfPlansAction.trimFromEnd,
      _PlanMode.extendEnd => TripChangeOfPlansAction.extendAtEnd,
    };
    final preview = TripChangeOfPlansService.preview(
      trip: trip,
      action: action,
      count: mode == _PlanMode.shift ? count : count.abs(),
    );

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        TripStrings.format('trip_cop_preview', locale, {
          'days': '${preview.newDayCount}',
          'deferred': '${preview.activitiesDeferred}',
          'shift': mode == _PlanMode.shift ? '$count' : '0',
        }),
        style: AppTypography.bodySmall.copyWith(height: 1.45),
      ),
    );
  }
}

class TripDeferredActivitiesSection extends ConsumerWidget {
  const TripDeferredActivitiesSection({
    super.key,
    required this.trip,
    required this.locale,
  });

  final TripPlan trip;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (trip.deferredActivities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TripStrings.t('trip_saved_for_later', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...trip.deferredActivities.map(
          (activity) => GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title, style: AppTypography.subtitle),
                      Text(
                        activity.startTime,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<int>(
                  tooltip: TripStrings.t('trip_deferred_move_to_day', locale),
                  onSelected: (day) async {
                    await ref
                        .read(tripPlannerProvider.notifier)
                        .moveDeferredActivityToDay(
                          tripId: trip.id,
                          activityId: activity.id,
                          dayNumber: day,
                        );
                  },
                  itemBuilder: (ctx) => [
                    for (final day in trip.days)
                      PopupMenuItem(
                        value: day.dayNumber,
                        child: Text(day.title),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class TripFlightReminderToggle extends ConsumerWidget {
  const TripFlightReminderToggle({
    super.key,
    required this.trip,
    required this.locale,
  });

  final TripPlan trip;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledAsync = ref.watch(tripFlightReminderEnabledProvider(trip.id));
    final canSchedule = TripFlightReminderService.tripHasSchedulableFlight(trip);

    if (!canSchedule) return const SizedBox.shrink();

    return enabledAsync.when(
      data: (enabled) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(TripStrings.t('trip_flight_reminder_toggle', locale)),
        subtitle: Text(
          TripStrings.t('trip_flight_reminder_toggle_hint', locale),
          style: AppTypography.bodySmall,
        ),
        value: enabled,
        onChanged: (v) async {
          TripPlannerAnalyticsService.flightReminderToggled(v);
          await ref.read(tripPlannerProvider.notifier).setFlightReminderEnabled(
                tripId: trip.id,
                enabled: v,
              );
          ref.invalidate(tripFlightReminderEnabledProvider(trip.id));
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
