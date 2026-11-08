import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/domain/services/trip_planner_config.dart';

/// Rule-based pre-check before a weather-triggered Claude itinerary adjustment.
/// No AI cost — compares previous vs new forecast against tunable thresholds.
///
/// Not wired yet: Trip Planner has no auto-adjust listener today. This gate is
/// ready for when that feature is added.
abstract final class TripWeatherAdjustmentGate {
  static bool shouldAdjust({
    required QatarWeather? previous,
    required QatarWeather current,
    required TripPlan plan,
  }) {
    if (previous == null) return false;
    if (!_planHasOutdoorActivities(plan)) return false;

    if (!previous.isPeakHeat && current.isPeakHeat) return true;

    if ((current.heatIndexC - previous.heatIndexC).abs() >=
        TripPlannerConfig.weatherTemperatureDeltaC) {
      return true;
    }

    final prevRain = _impliesRain(previous.description);
    final currRain = _impliesRain(current.description);
    if (!prevRain && currRain) return true;

    return false;
  }

  static bool _impliesRain(String description) {
    final d = description.toLowerCase();
    return d.contains('rain') ||
        d.contains('storm') ||
        d.contains('thunder') ||
        d.contains('shower');
  }

  static bool _planHasOutdoorActivities(TripPlan plan) {
    const outdoorKeywords = [
      'beach',
      'desert',
      'park',
      'corniche',
      'safari',
      'outdoor',
      'kayak',
    ];
    for (final activity in plan.allActivities) {
      final hay =
          '${activity.title} ${activity.description}'.toLowerCase();
      if (outdoorKeywords.any(hay.contains)) return true;
    }
    return false;
  }
}
