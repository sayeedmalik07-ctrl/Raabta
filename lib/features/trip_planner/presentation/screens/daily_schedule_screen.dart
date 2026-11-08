import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_budget_chart.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class DailyScheduleScreen extends ConsumerWidget {
  const DailyScheduleScreen({
    super.key,
    required this.tripId,
    required this.dayNumber,
  });

  final String tripId;
  final int dayNumber;

  TripPlan? _findTrip(TripPlannerState state) {
    for (final t in state.savedTrips) {
      if (t.id == tripId) return t;
    }
    if (state.activeTrip?.id == tripId) return state.activeTrip;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final trip = _findTrip(state);
    final locale = state.preferences.locale;

    if (trip == null) {
      return const GlassScreenScaffold(
        body: const Center(child: GlassProgressIndicator()),
      );
    }

    TripDayPlan? day;
    for (final d in trip.days) {
      if (d.dayNumber == dayNumber) {
        day = d;
        break;
      }
    }

    if (day == null) {
      return GlassScreenScaffold(
        title: TripStrings.format(
          'trip_day_title',
          locale,
          {'number': '$dayNumber'},
        ),
        body: Center(
          child: Text(TripStrings.t('trip_day_not_found', locale)),
        ),
      );
    }

    return GlassScreenScaffold(
      title: day.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          if (day.theme != null)
            Text(day.theme!, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          TripTimelineWidget(
            activities: day.activities,
            locale: locale,
            onActivityTap: (act) => context.push(
              '/trip-planner/activity/$tripId/${act.id}',
            ),
          ),
        ],
      ),
    );
  }
}
