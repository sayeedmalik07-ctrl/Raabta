enum EmployerTrackRecordDisplayStatus {
  insufficientData,
  available,
}

/// Public API response for Employer Track Record (Part C — k-anonymity gated).
class EmployerTrackRecordLookup {
  const EmployerTrackRecordLookup({
    required this.status,
    this.totalCalculations,
    this.violationFlaggedCount,
    this.lastCalculationMonth,
    this.increasedReportsSignal = false,
    this.velocityWindowDays,
  });

  final EmployerTrackRecordDisplayStatus status;
  final int? totalCalculations;
  final int? violationFlaggedCount;

  /// Month-level only (`YYYY-MM`) when [status] is [available].
  final String? lastCalculationMonth;

  /// True when recent flagged calculations accelerated vs this employer's baseline.
  final bool increasedReportsSignal;

  /// Recent window length in days — set only when [increasedReportsSignal] is true.
  final int? velocityWindowDays;

  bool get isAvailable => status == EmployerTrackRecordDisplayStatus.available;

  factory EmployerTrackRecordLookup.insufficient() {
    return const EmployerTrackRecordLookup(
      status: EmployerTrackRecordDisplayStatus.insufficientData,
    );
  }

  factory EmployerTrackRecordLookup.fromJson(Map<String, dynamic> json) {
    final displayStatus = json['displayStatus'] as String? ?? '';
    if (displayStatus != 'available') {
      return EmployerTrackRecordLookup.insufficient();
    }

    final increasedReports = json['increasedReportsSignal'] == true;

    return EmployerTrackRecordLookup(
      status: EmployerTrackRecordDisplayStatus.available,
      totalCalculations: (json['totalCalculations'] as num?)?.toInt(),
      violationFlaggedCount: (json['violationFlaggedCount'] as num?)?.toInt(),
      lastCalculationMonth: json['lastCalculationDate'] as String?,
      increasedReportsSignal: increasedReports,
      velocityWindowDays: increasedReports
          ? (json['velocityWindowDays'] as num?)?.toInt()
          : null,
    );
  }
}
