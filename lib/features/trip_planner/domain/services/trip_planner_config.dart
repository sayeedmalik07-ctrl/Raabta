/// Tunable Trip Planner cost-control constants.
abstract final class TripPlannerConfig {
  /// How long an identical prompt → itinerary mapping is reused (accidental resubmit).
  static const promptCacheTtlHours = 36;

  /// Max cached prompt signatures kept per user (LRU trim).
  static const promptCacheMaxEntries = 12;

  /// Ignore rapid duplicate Generate taps within this window.
  static const generateDebounceSeconds = 3;

  // ── Weather auto-adjust thresholds (for future auto-adjust feature) ──
  /// Rain probability must rise by at least this much (reserved for multi-day API).
  static const weatherRainProbabilityDelta = 0.50;

  /// Absolute rain probability floor (reserved for multi-day API).
  static const weatherRainProbabilityFloor = 0.60;

  /// Heat-index swing (°C) that may warrant plan changes.
  static const weatherTemperatureDeltaC = 5.0;

  /// AI request type for booking confirmation import extraction (separate from itinerary generation).
  static const bookingImportRequestType = 'trip_planner_booking_import';
}
