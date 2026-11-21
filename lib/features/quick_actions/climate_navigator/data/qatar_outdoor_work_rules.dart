/// Configurable Qatar outdoor-work heat rules (Ministerial Decision No. 17 of 2021).
///
/// Values are year-agnostic — never embed calendar years in UI copy.
abstract final class QatarOutdoorWorkRules {
  /// Clock-ban season: 1 June through 15 September (inclusive), Qatar local.
  static const seasonStartMonth = 6;
  static const seasonStartDay = 1;
  static const seasonEndMonth = 9;
  static const seasonEndDay = 15;

  /// Daily restricted window during the season (Qatar local, inclusive).
  static const restrictedStartHour = 10;
  static const restrictedStartMinute = 0;
  static const restrictedEndHour = 15;
  static const restrictedEndMinute = 30;

  /// Art. 4(9) — work must stop when workplace WBGT rises beyond this (°C).
  static const wbgtWorkStopThresholdC = 32.1;

  static const regulationCitation = 'Ministerial Decision No. 17 of 2021';
  static const ministryName = 'Ministry of Labour (Qatar)';

  static const restrictedWindowLabel = '10:00–15:30';
  static const seasonRangeLabel = '1 June–15 September';
}

/// Deterministic labour compliance snapshot — separate clock ban vs WBGT trigger.
class OutdoorWorkComplianceStatus {
  const OutdoorWorkComplianceStatus({
    required this.isClockBanSeason,
    required this.isClockBanWindowActive,
    required this.isWbgtStopRequired,
    required this.wbgtEstimateC,
    required this.evaluatedAt,
  });

  final bool isClockBanSeason;
  final bool isClockBanWindowActive;
  final bool isWbgtStopRequired;
  final double wbgtEstimateC;
  final DateTime evaluatedAt;

  /// Restricted if WBGT stop applies **or** the seasonal clock window is active.
  bool get isOutdoorWorkRestricted =>
      isWbgtStopRequired || isClockBanWindowActive;

  /// Outside 1 Jun–15 Sep — clock ban does not apply (WBGT limit still year-round).
  bool get isOffSeason => !isClockBanSeason;
}
