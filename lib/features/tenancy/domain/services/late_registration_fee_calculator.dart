import 'package:raabta/features/tenancy/domain/rules/law_8_2026_tenancy.dart';

/// Estimates late registration fee penalties under Law 8/2026 Art. 20(2).
class LateRegistrationFeeEstimate {
  const LateRegistrationFeeEstimate({
    required this.baseFeeQar,
    required this.monthsLate,
    required this.penaltyRate,
    required this.totalFeeQar,
  });

  final double baseFeeQar;
  final int monthsLate;
  final double penaltyRate;
  final double totalFeeQar;
}

abstract final class LateRegistrationFeeCalculator {
  static const baseFee = 250.0;

  /// Full months of delay; any partial month counts as a full month.
  static int fullMonthsLate(DateTime leaseStart, DateTime reference) {
    if (!reference.isAfter(leaseStart)) return 0;
    final startMonth = DateTime(leaseStart.year, leaseStart.month);
    final refMonth = DateTime(reference.year, reference.month);
    final months =
        (refMonth.year - startMonth.year) * 12 + (refMonth.month - startMonth.month);
    return months.clamp(0, 999);
  }

  static double penaltyRateForMonths(int monthsLate) {
    if (monthsLate <= 0) return 0;
    if (monthsLate == 1) return Law82026Tenancy.latePenaltyMonth1;
    if (monthsLate == 2) return Law82026Tenancy.latePenaltyMonth2;
    if (monthsLate == 3) return Law82026Tenancy.latePenaltyMonth3;
    return Law82026Tenancy.latePenaltyBeyondMonth3;
  }

  static LateRegistrationFeeEstimate? estimate({
    required DateTime? leaseStartDate,
    DateTime? reference,
  }) {
    if (leaseStartDate == null) return null;
    final now = reference ?? DateTime.now();
    final monthsLate = fullMonthsLate(leaseStartDate, now);
    if (monthsLate <= 0) {
      return LateRegistrationFeeEstimate(
        baseFeeQar: baseFee,
        monthsLate: 0,
        penaltyRate: 0,
        totalFeeQar: baseFee,
      );
    }
    final rate = penaltyRateForMonths(monthsLate);
    return LateRegistrationFeeEstimate(
      baseFeeQar: baseFee,
      monthsLate: monthsLate,
      penaltyRate: rate,
      totalFeeQar: baseFee * (1 + rate),
    );
  }
}
