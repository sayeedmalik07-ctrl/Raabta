import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_template_engine.dart';

enum TripChangeOfPlansAction {
  shiftDays,
  trimFromStart,
  trimFromEnd,
  extendAtStart,
  extendAtEnd,
}

class TripChangeOfPlansPreview {
  const TripChangeOfPlansPreview({
    required this.action,
    required this.daysAffected,
    required this.activitiesDeferred,
    required this.newDayCount,
  });

  final TripChangeOfPlansAction action;
  final int daysAffected;
  final int activitiesDeferred;
  final int newDayCount;
}

abstract final class TripChangeOfPlansService {
  TripChangeOfPlansService._();

  static TripChangeOfPlansPreview preview({
    required TripPlan trip,
    required TripChangeOfPlansAction action,
    required int count,
  }) {
    final n = count.clamp(0, 30);
    return switch (action) {
      TripChangeOfPlansAction.shiftDays => TripChangeOfPlansPreview(
          action: action,
          daysAffected: n.abs(),
          activitiesDeferred: 0,
          newDayCount: trip.days.length,
        ),
      TripChangeOfPlansAction.trimFromStart ||
      TripChangeOfPlansAction.trimFromEnd =>
        _previewTrim(trip, action, n),
      TripChangeOfPlansAction.extendAtStart ||
      TripChangeOfPlansAction.extendAtEnd =>
        TripChangeOfPlansPreview(
          action: action,
          daysAffected: n,
          activitiesDeferred: 0,
          newDayCount: trip.days.length + n,
        ),
    };
  }

  static TripChangeOfPlansPreview _previewTrim(
    TripPlan trip,
    TripChangeOfPlansAction action,
    int removeCount,
  ) {
    final maxRemove = trip.days.length - 1;
    final remove = removeCount.clamp(0, maxRemove);
    var deferred = 0;
    if (action == TripChangeOfPlansAction.trimFromStart) {
      for (var i = 0; i < remove && i < trip.days.length; i++) {
        deferred += trip.days[i].activities.length;
      }
    } else {
      for (var i = trip.days.length - remove; i < trip.days.length; i++) {
        if (i >= 0) deferred += trip.days[i].activities.length;
      }
    }
    return TripChangeOfPlansPreview(
      action: action,
      daysAffected: remove,
      activitiesDeferred: deferred,
      newDayCount: trip.days.length - remove,
    );
  }

  static TripPlan apply({
    required TripPlan trip,
    required TripChangeOfPlansAction action,
    required int count,
  }) {
    final updated = switch (action) {
      TripChangeOfPlansAction.shiftDays => _shiftCalendar(trip, count),
      TripChangeOfPlansAction.trimFromStart =>
        _trim(trip: trip, fromStart: true, removeCount: count),
      TripChangeOfPlansAction.trimFromEnd =>
        _trim(trip: trip, fromStart: false, removeCount: count),
      TripChangeOfPlansAction.extendAtStart =>
        _extend(trip: trip, atStart: true, addCount: count),
      TripChangeOfPlansAction.extendAtEnd =>
        _extend(trip: trip, atStart: false, addCount: count),
    };
    return _finalizeAfterMutation(updated);
  }

  static TripPlan _shiftCalendar(TripPlan trip, int deltaDays) {
    if (deltaDays == 0) return trip;
    final prefs = trip.preferences;
    final shifted = prefs.copyWith(
      tripStartDate: _shiftDate(prefs.tripStartDate, deltaDays),
      tripEndDate: _shiftDate(prefs.tripEndDate, deltaDays),
    );
    return trip.copyWith(
      preferences: shifted,
      itineraryDatesRevision: trip.itineraryDatesRevision + 1,
      scheduleNeedsReview: trip.bookingSegments.isNotEmpty
          ? true
          : trip.scheduleNeedsReview,
    );
  }

  static DateTime? _shiftDate(DateTime? date, int deltaDays) {
    if (date == null) return null;
    return date.add(Duration(days: deltaDays));
  }

  static TripPlan _trim({
    required TripPlan trip,
    required bool fromStart,
    required int removeCount,
  }) {
    if (trip.days.isEmpty || removeCount <= 0) return trip;
    final maxRemove = trip.days.length - 1;
    final remove = removeCount.clamp(0, maxRemove);
    if (remove == 0) return trip;

    final deferred = [...trip.deferredActivities];
    List<TripDayPlan> remaining;
    if (fromStart) {
      for (var i = 0; i < remove; i++) {
        deferred.addAll(trip.days[i].activities);
      }
      remaining = trip.days.sublist(remove);
    } else {
      final startIdx = trip.days.length - remove;
      for (var i = startIdx; i < trip.days.length; i++) {
        deferred.addAll(trip.days[i].activities);
      }
      remaining = trip.days.sublist(0, startIdx);
    }

    final renumbered = _renumberDays(remaining);
    final prefs = trip.preferences.copyWith(days: renumbered.length);
    return trip.copyWith(
      days: renumbered,
      preferences: prefs,
      deferredActivities: deferred,
      itineraryDatesRevision: trip.itineraryDatesRevision + 1,
      scheduleNeedsReview: trip.bookingSegments.isNotEmpty
          ? true
          : trip.scheduleNeedsReview,
    );
  }

  static TripPlan _extend({
    required TripPlan trip,
    required bool atStart,
    required int addCount,
  }) {
    if (addCount <= 0) return trip;
    final emptyDays = List<TripDayPlan>.generate(
      addCount,
      (i) => TripDayPlan(
        dayNumber: i + 1,
        title: 'Day ${i + 1}',
        activities: const [],
      ),
    );
    List<TripDayPlan> merged;
    if (atStart) {
      merged = [...emptyDays, ...trip.days];
    } else {
      merged = [...trip.days, ...emptyDays];
    }
    final renumbered = _renumberDays(merged);
    final prefs = trip.preferences.copyWith(days: renumbered.length);
    return trip.copyWith(
      days: renumbered,
      preferences: prefs,
      itineraryDatesRevision: trip.itineraryDatesRevision + 1,
      scheduleNeedsReview: trip.scheduleNeedsReview,
    );
  }

  static List<TripDayPlan> _renumberDays(List<TripDayPlan> days) {
    return [
      for (var i = 0; i < days.length; i++)
        TripDayPlan(
          dayNumber: i + 1,
          title: days[i].title.startsWith('Day ')
              ? 'Day ${i + 1}'
              : days[i].title,
          activities: days[i].activities,
          theme: days[i].theme,
        ),
    ];
  }

  static TripPlan _finalizeAfterMutation(TripPlan trip) {
    if (trip.days.length != trip.preferences.days) {
      trip = trip.copyWith(preferences: trip.preferences.copyWith(days: trip.days.length));
    }
    final budget = TripBudgetService.calculate(trip.days, trip.preferences);
    final tips = TripBudgetService.optimizationTips(budget, trip.preferences);
    var prefs = trip.preferences;
    if (prefs.tripStartDate != null && prefs.tripEndDate == null) {
      prefs = prefs.copyWith(
        tripEndDate: prefs.tripStartDate!.add(Duration(days: prefs.days - 1)),
      );
    }
    return trip.copyWith(
      preferences: prefs,
      budget: budget,
      budgetTips: tips,
    );
  }

  static TripPlan moveDeferredToDay({
    required TripPlan trip,
    required String activityId,
    required int dayNumber,
  }) {
    TripActivity? activity;
    for (final a in trip.deferredActivities) {
      if (a.id == activityId) {
        activity = a;
        break;
      }
    }
    if (activity == null) return trip;
    final resolved = activity;

    final deferred = trip.deferredActivities.where((a) => a.id != activityId).toList();
    final days = trip.days.map((d) {
      if (d.dayNumber != dayNumber) return d;
      return TripDayPlan(
        dayNumber: d.dayNumber,
        title: d.title,
        theme: d.theme,
        activities: [...d.activities, resolved],
      );
    }).toList();

    final updated = trip.copyWith(days: days, deferredActivities: deferred);
    return _finalizeAfterMutation(updated);
  }
}
