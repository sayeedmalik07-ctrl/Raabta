import 'package:flutter/foundation.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_preferences.dart';

/// NIOSH/OSHA 20% rule — same ramp for [ClimateAcclimatizationType] values (A2).
/// Sources: CDC/NIOSH acclimatization; OSHA heat guidance (20% daily increase).
abstract final class ClimateAcclimatizationSchedule {
  static const maxSupervisionPlanDay = 14;
  static const rampDays = 5;

  /// Plan day 1 = [startDateQatar] in Qatar calendar.
  @visibleForTesting
  static int planDayNumber({
    required DateTime startDateQatar,
    required DateTime todayQatar,
  }) {
    final start = DateTime(startDateQatar.year, startDateQatar.month, startDateQatar.day);
    final today = DateTime(todayQatar.year, todayQatar.month, todayQatar.day);
    return today.difference(start).inDays + 1;
  }

  /// Exposure cap as percent of employer-defined usual daily heat-exposure duration.
  @visibleForTesting
  static int? exposurePercentForPlanDay(int planDay) {
    if (planDay < 1) return null;
    if (planDay >= rampDays) return 100;
    return planDay * 20;
  }

  static AcclimatizationScheduleSnapshot snapshot({
    required DateTime startDate,
    DateTime? referenceNow,
  }) {
    final startQatar = DateTime(startDate.year, startDate.month, startDate.day);
    final todayQatar = referenceNow != null
        ? ClimateAcclimatizationPreferences.qatarCalendarDate(referenceNow)
        : ClimateAcclimatizationPreferences.qatarCalendarDate(DateTime.now());
    final planDay = planDayNumber(
      startDateQatar: startQatar,
      todayQatar: todayQatar,
    );
    final percent = exposurePercentForPlanDay(planDay);
    return AcclimatizationScheduleSnapshot(
      planDay: planDay,
      exposurePercent: percent,
      phase: _phaseForPlanDay(planDay),
      withinSupervisionWindow:
          planDay >= rampDays && planDay <= maxSupervisionPlanDay,
    );
  }

  static AcclimatizationSchedulePhase _phaseForPlanDay(int planDay) {
    if (planDay < 1) return AcclimatizationSchedulePhase.notStarted;
    if (planDay < rampDays) return AcclimatizationSchedulePhase.ramp; // days 1–4
    if (planDay <= maxSupervisionPlanDay) {
      return AcclimatizationSchedulePhase.fullExposureSupervision;
    }
    return AcclimatizationSchedulePhase.afterSupervisionWindow;
  }
}

enum AcclimatizationSchedulePhase {
  notStarted,
  ramp,
  fullExposureSupervision,
  afterSupervisionWindow,
}

class AcclimatizationScheduleSnapshot {
  const AcclimatizationScheduleSnapshot({
    required this.planDay,
    required this.exposurePercent,
    required this.phase,
    required this.withinSupervisionWindow,
  });

  final int planDay;
  final int? exposurePercent;
  final AcclimatizationSchedulePhase phase;
  final bool withinSupervisionWindow;

  bool get showExposurePercent => exposurePercent != null;
}
