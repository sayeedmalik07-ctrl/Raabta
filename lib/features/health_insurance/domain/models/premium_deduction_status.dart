/// User answer for Art. 13 salary-deduction / cost-sharing question (Law 22/2021).
enum PremiumDeductionStatus {
  unanswered,
  /// No deduction or cost-sharing reported.
  noDeduction,
  /// User confirmed premium was deducted or they were asked to pay.
  deductionReported,
  /// User is unsure — informational only, not a violation flag.
  notSure,
}

extension PremiumDeductionStatusJson on PremiumDeductionStatus {
  static PremiumDeductionStatus fromJson(Object? value, {bool? legacyEmployerPaysFull}) {
    if (value is String) {
      return PremiumDeductionStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PremiumDeductionStatus.unanswered,
      );
    }
    if (legacyEmployerPaysFull == true) {
      return PremiumDeductionStatus.noDeduction;
    }
    if (legacyEmployerPaysFull == false) {
      return PremiumDeductionStatus.deductionReported;
    }
    return PremiumDeductionStatus.unanswered;
  }
}
