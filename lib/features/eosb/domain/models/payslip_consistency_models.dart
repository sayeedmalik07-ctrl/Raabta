/// Manual payslip row for cross-document salary comparison (Part B).
class PayslipManualEntry {
  const PayslipManualEntry({
    required this.year,
    required this.month,
    required this.basicSalary,
    this.housingAllowance,
    this.transportAllowance,
    this.employerName,
  });

  final int year;
  final int month;
  final double basicSalary;
  final double? housingAllowance;
  final double? transportAllowance;
  final String? employerName;

  int get sortKey => year * 12 + month;

  bool get hasHousingAllowance =>
      housingAllowance != null && housingAllowance! > 0;

  bool get hasTransportAllowance =>
      transportAllowance != null && transportAllowance! > 0;

  bool get hasEmployerName =>
      employerName != null && employerName!.trim().isNotEmpty;
}

enum PayslipDiscrepancyKind {
  basicSalaryBetweenPayslips,
  basicSalaryVsContract,
  missingMonth,
  employerNameMismatch,
  housingAllowanceChange,
  transportAllowanceChange,
}

/// Structured discrepancy — UI resolves [messageKey] via [EosbStrings.format].
class PayslipDiscrepancy {
  const PayslipDiscrepancy({
    required this.kind,
    required this.messageKey,
    this.params = const {},
  });

  final PayslipDiscrepancyKind kind;
  final String messageKey;
  final Map<String, String> params;
}

/// Contract figures used as comparison baseline (from EOSB intake).
class PayslipContractReference {
  const PayslipContractReference({
    this.basicSalary = 0,
    this.companyName = '',
    this.housingAllowance = 0,
    this.transportAllowance = 0,
  });

  final double basicSalary;
  final String companyName;
  final double housingAllowance;
  final double transportAllowance;

  bool get hasBasicSalary => basicSalary > 0;
  bool get hasCompanyName => companyName.trim().isNotEmpty;
}

class PayslipConsistencyResult {
  const PayslipConsistencyResult({
    required this.entries,
    required this.contract,
    required this.discrepancies,
    this.minRequiredEntries = kMinPayslipEntriesForComparison,
  });

  final List<PayslipManualEntry> entries;
  final PayslipContractReference contract;
  final List<PayslipDiscrepancy> discrepancies;
  final int minRequiredEntries;

  bool get hasEnoughEntries => entries.length >= minRequiredEntries;
  int get entriesNeeded =>
      (minRequiredEntries - entries.length).clamp(0, 999);
  bool get hasDiscrepancies => discrepancies.isNotEmpty;
}

/// Minimum payslip rows before comparison runs (mirrors OT rounding sample gate).
const kMinPayslipEntriesForComparison = 2;

/// Ignore sub-QAR noise when comparing salary figures.
const kPayslipSalaryToleranceQar = 0.01;
