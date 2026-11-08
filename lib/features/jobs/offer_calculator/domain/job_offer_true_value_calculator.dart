import 'package:raabta/features/jobs/offer_calculator/domain/job_offer_reference_data.dart';
import 'package:raabta/features/jobs/offer_calculator/domain/models/job_offer_calculator_models.dart';

/// Deterministic pre-offer true-value arithmetic — no AI, no OCR.
abstract final class JobOfferTrueValueCalculator {
  JobOfferTrueValueCalculator._();

  static const _nearMinimumMargin = 0.10;

  static JobOfferCalculatorResult calculate(JobOfferCalculatorInput input) {
    final trueValue = _trueMonthlyValue(input);
    final applicableMin = _applicableMinimumWage(input);
    final comparison = _minimumComparison(trueValue, applicableMin);
    final nationalAvg = JobOfferReferenceData.qnpsNationalAverageMonthlyWage;
    final pctOfAvg =
        nationalAvg > 0 ? (trueValue / nationalAvg) * 100 : 0.0;

    double? feeMonths;
    if (input.recruitmentFee > 0 && trueValue > 0) {
      feeMonths = input.recruitmentFee / trueValue;
    }

    return JobOfferCalculatorResult(
      trueMonthlyValue: trueValue,
      applicableMinimumWage: applicableMin,
      minimumWageComparison: comparison,
      nationalAverageWage: nationalAvg,
      nationalAverageReportingPeriod: JobOfferReferenceData.qnpsReportingPeriod,
      percentOfNationalAverage: pctOfAvg,
      recruitmentFeeAmount: input.recruitmentFee,
      recruitmentFeeMonthsOfTrueValue: feeMonths,
    );
  }

  static double _trueMonthlyValue(JobOfferCalculatorInput input) {
    var total = input.grossMonthlySalary;
    if (input.accommodationMode == JobOfferBenefitMode.cashAllowance) {
      total += input.accommodationAllowance;
    }
    if (input.foodMode == JobOfferBenefitMode.cashAllowance) {
      total += input.foodAllowance;
    }
    return total;
  }

  /// Minimum wage floor matching the offer's in-kind vs allowance structure.
  static double _applicableMinimumWage(JobOfferCalculatorInput input) {
    var floor = JobOfferReferenceData.minimumWageBasic;
    if (input.accommodationMode != JobOfferBenefitMode.inKind) {
      floor += JobOfferReferenceData.minimumWageHousingAllowance;
    }
    if (input.foodMode != JobOfferBenefitMode.inKind) {
      floor += JobOfferReferenceData.minimumWageFoodAllowance;
    }
    return floor;
  }

  static JobOfferMinimumWageComparison _minimumComparison(
    double trueValue,
    double applicableMin,
  ) {
    if (trueValue < applicableMin) {
      return JobOfferMinimumWageComparison.belowMinimum;
    }
    if (trueValue <= applicableMin * (1 + _nearMinimumMargin)) {
      return JobOfferMinimumWageComparison.nearMinimum;
    }
    return JobOfferMinimumWageComparison.aboveMinimum;
  }
}
