/// Spacing for heat-triggered local reminders (Climate Navigator).
///
/// UX defaults only — not medical guidance. No quantities or health targets.
abstract final class ClimateHeatReminderConstants {
  /// Minutes between during-window reminders per approximate WBGT band.
  static const Map<String, int> intervalMinutesByBand = {
    'lower': 0,
    'moderate': 120,
    'high': 90,
    'extreme': 60,
    'work_stop': 45,
  };

  /// Local time (Qatar) for the optional evening-before shift prompt.
  static const beforeShiftEveningHour = 20;
  static const beforeShiftEveningMinute = 0;

  /// Minutes before [active window start] for the short lead-in prompt.
  static const beforeShiftLeadMinutes = 30;

  /// Cap scheduled during-window notifications per reschedule pass.
  static const maxDuringWindowSlots = 48;

  static int intervalMinutesForBand(String wbgtRiskLevelKey) =>
      intervalMinutesByBand[wbgtRiskLevelKey] ?? 0;

  static bool bandEligibleForReminders(String wbgtRiskLevelKey) =>
      intervalMinutesForBand(wbgtRiskLevelKey) > 0;
}
