import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/rules/overtime_rules.dart';

/// Minimum dual-sided shifts before showing rounding analysis (OverPay-aligned).
const kMinShiftsForRoundingAnalysis = 10;

/// One minute or more — ignore sub-minute noise.
const kRoundingVarianceThresholdMinutes = 1;

enum OvertimeRoundingDirection {
  employerFavor,
  neutral,
  mixed,
}

/// Deterministic rounding pattern summary — no AI, no p-values.
class OvertimeRoundingPatternResult {
  const OvertimeRoundingPatternResult({
    required this.dualShiftCount,
    required this.minRequiredShifts,
    required this.clockInEmployerFavorCount,
    required this.clockOutEmployerFavorCount,
    required this.avgClockInLossMinutes,
    required this.avgClockOutLossMinutes,
    required this.avgTotalMinutesLostPerShift,
    required this.estimatedQarImpact,
    required this.direction,
    required this.currency,
  });

  final int dualShiftCount;
  final int minRequiredShifts;
  final int clockInEmployerFavorCount;
  final int clockOutEmployerFavorCount;
  final double avgClockInLossMinutes;
  final double avgClockOutLossMinutes;
  final double avgTotalMinutesLostPerShift;
  final double estimatedQarImpact;
  final OvertimeRoundingDirection direction;
  final String currency;

  bool get hasEnoughData => dualShiftCount >= minRequiredShifts;

  int get shiftsNeeded => (minRequiredShifts - dualShiftCount).clamp(0, 999);

  /// Plain summary inputs for l10n templates.
  String get primaryPatternKey {
    if (clockInEmployerFavorCount >= clockOutEmployerFavorCount &&
        clockInEmployerFavorCount > dualShiftCount ~/ 2) {
      return 'ot_rounding_pattern_clock_in';
    }
    if (clockOutEmployerFavorCount > dualShiftCount ~/ 2) {
      return 'ot_rounding_pattern_clock_out';
    }
    return 'ot_rounding_pattern_neutral';
  }
}

abstract final class OvertimeRoundingPatternAnalyzer {
  static OvertimeRoundingPatternResult analyze({
    required OvertimeMonthlyRecord record,
  }) {
    final dualDays = record.days.where((d) => d.hasDualShiftTimes).toList();
    final count = dualDays.length;

    if (count == 0) {
      return OvertimeRoundingPatternResult(
        dualShiftCount: 0,
        minRequiredShifts: kMinShiftsForRoundingAnalysis,
        clockInEmployerFavorCount: 0,
        clockOutEmployerFavorCount: 0,
        avgClockInLossMinutes: 0,
        avgClockOutLossMinutes: 0,
        avgTotalMinutesLostPerShift: 0,
        estimatedQarImpact: 0,
        direction: OvertimeRoundingDirection.neutral,
        currency: record.profile.currency,
      );
    }

    var clockInFavor = 0;
    var clockOutFavor = 0;
    final clockInLosses = <double>[];
    final clockOutLosses = <double>[];
    final totalLossPerShift = <double>[];

    for (final day in dualDays) {
      final inVar = _varianceMinutes(
        day.employerReportedStartTime,
        day.userLoggedStartTime,
      );
      final outVar = _varianceMinutes(
        day.employerReportedEndTime,
        day.userLoggedEndTime,
      );

      var shiftLoss = 0.0;

      if (inVar != null &&
          inVar >= kRoundingVarianceThresholdMinutes) {
        clockInFavor++;
        clockInLosses.add(inVar);
        shiftLoss += inVar;
      }

      if (outVar != null &&
          outVar <= -kRoundingVarianceThresholdMinutes) {
        clockOutFavor++;
        clockOutLosses.add(outVar.abs());
        shiftLoss += outVar.abs();
      }

      if (shiftLoss > 0) totalLossPerShift.add(shiftLoss);
    }

    final avgIn = clockInLosses.isEmpty
        ? 0.0
        : clockInLosses.reduce((a, b) => a + b) / clockInLosses.length;
    final avgOut = clockOutLosses.isEmpty
        ? 0.0
        : clockOutLosses.reduce((a, b) => a + b) / clockOutLosses.length;
    final avgTotal = totalLossPerShift.isEmpty
        ? 0.0
        : totalLossPerShift.reduce((a, b) => a + b) / totalLossPerShift.length;

    final rules = OvertimeRulesRegistry.forCountry(record.profile.countryCode);
    final minuteRate = rules.minuteRateFromBasic(record.profile.basicSalary);
    final totalMinutes = totalLossPerShift.fold<double>(0, (a, b) => a + b);
    final qarImpact = totalMinutes * minuteRate;

    final direction = _direction(
      count: count,
      clockInFavor: clockInFavor,
      clockOutFavor: clockOutFavor,
    );

    return OvertimeRoundingPatternResult(
      dualShiftCount: count,
      minRequiredShifts: kMinShiftsForRoundingAnalysis,
      clockInEmployerFavorCount: clockInFavor,
      clockOutEmployerFavorCount: clockOutFavor,
      avgClockInLossMinutes: avgIn,
      avgClockOutLossMinutes: avgOut,
      avgTotalMinutesLostPerShift: avgTotal,
      estimatedQarImpact: qarImpact,
      direction: direction,
      currency: record.profile.currency,
    );
  }

  static OvertimeRoundingDirection _direction({
    required int count,
    required int clockInFavor,
    required int clockOutFavor,
  }) {
    final favorTotal = clockInFavor + clockOutFavor;
    if (favorTotal == 0) return OvertimeRoundingDirection.neutral;
    if (favorTotal >= count * 0.6) return OvertimeRoundingDirection.employerFavor;
    if (favorTotal >= count * 0.3) return OvertimeRoundingDirection.mixed;
    return OvertimeRoundingDirection.neutral;
  }

  /// Employer minus user in minutes (null if unparsable).
  static double? _varianceMinutes(String? employer, String? user) {
    final e = _parseMinutes(employer);
    final u = _parseMinutes(user);
    if (e == null || u == null) return null;
    return (e - u).toDouble();
  }

  static int? _parseMinutes(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) return null;
    final parts = hhmm.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }
}
