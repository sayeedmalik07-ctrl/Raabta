/// How accommodation or food is provided in the offer.
enum JobOfferBenefitMode {
  /// Employer provides in-kind (no cash allowance expected).
  inKind,

  /// Paid as a monthly cash allowance.
  cashAllowance,

  /// Not included — user pays own costs (allowance amount may be zero).
  notIncluded,
}

/// User-entered offer inputs — no OCR or external data.
class JobOfferCalculatorInput {
  const JobOfferCalculatorInput({
    required this.grossMonthlySalary,
    this.accommodationMode = JobOfferBenefitMode.notIncluded,
    this.accommodationAllowance = 0,
    this.foodMode = JobOfferBenefitMode.notIncluded,
    this.foodAllowance = 0,
    this.recruitmentFee = 0,
  });

  final double grossMonthlySalary;
  final JobOfferBenefitMode accommodationMode;
  final double accommodationAllowance;
  final JobOfferBenefitMode foodMode;
  final double foodAllowance;
  final double recruitmentFee;
}

enum JobOfferMinimumWageComparison {
  /// True value below applicable legal minimum for this benefit structure.
  belowMinimum,

  /// Within 10% above applicable minimum.
  nearMinimum,

  /// Clearly above applicable minimum.
  aboveMinimum,
}

/// Deterministic calculator output — factual figures only, no scam/good verdict.
class JobOfferCalculatorResult {
  const JobOfferCalculatorResult({
    required this.trueMonthlyValue,
    required this.applicableMinimumWage,
    required this.minimumWageComparison,
    required this.nationalAverageWage,
    required this.nationalAverageReportingPeriod,
    required this.percentOfNationalAverage,
    this.recruitmentFeeAmount = 0,
    this.recruitmentFeeMonthsOfTrueValue,
  });

  final double trueMonthlyValue;
  final double applicableMinimumWage;
  final JobOfferMinimumWageComparison minimumWageComparison;
  final double nationalAverageWage;
  final String nationalAverageReportingPeriod;

  /// Percentage of QNPS national average (context only, not a target).
  final double percentOfNationalAverage;

  final double recruitmentFeeAmount;

  /// Months of true monthly value the fee represents, when fee > 0.
  final double? recruitmentFeeMonthsOfTrueValue;
}
