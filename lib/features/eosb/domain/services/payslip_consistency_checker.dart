import 'package:raabta/features/eosb/domain/models/payslip_consistency_models.dart';
import 'package:raabta/features/eosb/domain/services/employer_name_normalizer.dart';

/// Deterministic payslip figure comparison — no AI, no scores, no accusations.
abstract final class PayslipConsistencyChecker {
  static PayslipConsistencyResult compare({
    required List<PayslipManualEntry> entries,
    required PayslipContractReference contract,
    String locale = 'English',
  }) {
    final valid = entries
        .where((e) => e.year > 0 && e.month >= 1 && e.month <= 12 && e.basicSalary > 0)
        .toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    if (valid.length < kMinPayslipEntriesForComparison) {
      return PayslipConsistencyResult(
        entries: valid,
        contract: contract,
        discrepancies: const [],
      );
    }

    final discrepancies = <PayslipDiscrepancy>[
      ..._basicSalaryDiscrepancies(valid, contract, locale),
      ..._missingMonthDiscrepancies(valid, locale),
      ..._employerNameDiscrepancies(valid, contract, locale),
      ..._allowanceDiscrepancies(valid, locale),
    ];

    return PayslipConsistencyResult(
      entries: valid,
      contract: contract,
      discrepancies: discrepancies,
    );
  }

  static List<PayslipDiscrepancy> _basicSalaryDiscrepancies(
    List<PayslipManualEntry> entries,
    PayslipContractReference contract,
    String locale,
  ) {
    final out = <PayslipDiscrepancy>[];

    for (final entry in entries) {
      final otherDifferent = entries
          .where(
            (o) =>
                o.sortKey != entry.sortKey &&
                !_salariesEqual(o.basicSalary, entry.basicSalary),
          )
          .toList();
      final differsFromContract = contract.hasBasicSalary &&
          !_salariesEqual(entry.basicSalary, contract.basicSalary);

      if (otherDifferent.isNotEmpty && differsFromContract) {
        final other = otherDifferent.first;
        out.add(
          PayslipDiscrepancy(
            kind: PayslipDiscrepancyKind.basicSalaryBetweenPayslips,
            messageKey: 'eosb_payslip_disc_basic_both',
            params: {
              'month': _monthLabel(entry, locale),
              'payslipSalary': _formatQar(entry.basicSalary),
              'otherMonth': _monthLabel(other, locale),
              'otherSalary': _formatQar(other.basicSalary),
              'contractSalary': _formatQar(contract.basicSalary),
            },
          ),
        );
      } else if (otherDifferent.isNotEmpty) {
        final other = otherDifferent.first;
        out.add(
          PayslipDiscrepancy(
            kind: PayslipDiscrepancyKind.basicSalaryBetweenPayslips,
            messageKey: 'eosb_payslip_disc_basic_pair',
            params: {
              'monthA': _monthLabel(entry, locale),
              'salaryA': _formatQar(entry.basicSalary),
              'monthB': _monthLabel(other, locale),
              'salaryB': _formatQar(other.basicSalary),
            },
          ),
        );
      } else if (differsFromContract) {
        out.add(
          PayslipDiscrepancy(
            kind: PayslipDiscrepancyKind.basicSalaryVsContract,
            messageKey: 'eosb_payslip_disc_basic_contract',
            params: {
              'month': _monthLabel(entry, locale),
              'payslipSalary': _formatQar(entry.basicSalary),
              'contractSalary': _formatQar(contract.basicSalary),
            },
          ),
        );
      }
    }

    return _dedupeDiscrepancies(out);
  }

  static List<PayslipDiscrepancy> _missingMonthDiscrepancies(
    List<PayslipManualEntry> entries,
    String locale,
  ) {
    if (entries.length < 2) return const [];

    final out = <PayslipDiscrepancy>[];
    for (var i = 0; i < entries.length - 1; i++) {
      final a = entries[i];
      final b = entries[i + 1];
      var cursor = _nextMonth(a.year, a.month);
      final endKey = b.sortKey;
      while (cursor < endKey) {
        final parts = _fromSortKey(cursor);
        out.add(
          PayslipDiscrepancy(
            kind: PayslipDiscrepancyKind.missingMonth,
            messageKey: 'eosb_payslip_disc_missing_month',
            params: {
              'month': _monthLabelFromParts(parts.$1, parts.$2, locale),
              'monthBefore': _monthLabel(a, locale),
              'monthAfter': _monthLabel(b, locale),
            },
          ),
        );
        cursor = _nextMonth(parts.$1, parts.$2);
      }
    }
    return out;
  }

  static List<PayslipDiscrepancy> _employerNameDiscrepancies(
    List<PayslipManualEntry> entries,
    PayslipContractReference contract,
    String locale,
  ) {
    final named = entries.where((e) => e.hasEmployerName).toList();
    if (named.length < 2) {
      if (named.length == 1 &&
          contract.hasCompanyName &&
          EmployerNameNormalizer.normalize(named.first.employerName!) !=
              EmployerNameNormalizer.normalize(contract.companyName)) {
        return [
          PayslipDiscrepancy(
            kind: PayslipDiscrepancyKind.employerNameMismatch,
            messageKey: 'eosb_payslip_disc_employer_contract',
            params: {
              'month': _monthLabel(named.first, locale),
              'payslipEmployer': named.first.employerName!.trim(),
              'contractEmployer': contract.companyName.trim(),
            },
          ),
        ];
      }
      return const [];
    }

    final baselineKey =
        EmployerNameNormalizer.normalize(named.first.employerName!);
    final out = <PayslipDiscrepancy>[];
    for (var i = 1; i < named.length; i++) {
      final key = EmployerNameNormalizer.normalize(named[i].employerName!);
      if (key != baselineKey) {
        out.add(
          PayslipDiscrepancy(
            kind: PayslipDiscrepancyKind.employerNameMismatch,
            messageKey: 'eosb_payslip_disc_employer_pair',
            params: {
              'monthA': _monthLabel(named[i], locale),
              'nameA': named[i].employerName!.trim(),
              'monthB': _monthLabel(named.first, locale),
              'nameB': named.first.employerName!.trim(),
            },
          ),
        );
      }
    }
    return out;
  }

  static List<PayslipDiscrepancy> _allowanceDiscrepancies(
    List<PayslipManualEntry> entries,
    String locale,
  ) {
    final out = <PayslipDiscrepancy>[];
    out.addAll(_singleAllowanceTrack(
      entries,
      locale,
      kind: PayslipDiscrepancyKind.housingAllowanceChange,
      messageKey: 'eosb_payslip_disc_housing',
      read: (e) => e.housingAllowance,
      has: (e) => e.hasHousingAllowance,
    ));
    out.addAll(_singleAllowanceTrack(
      entries,
      locale,
      kind: PayslipDiscrepancyKind.transportAllowanceChange,
      messageKey: 'eosb_payslip_disc_transport',
      read: (e) => e.transportAllowance,
      has: (e) => e.hasTransportAllowance,
    ));
    return out;
  }

  static List<PayslipDiscrepancy> _singleAllowanceTrack(
    List<PayslipManualEntry> entries,
    String locale, {
    required PayslipDiscrepancyKind kind,
    required String messageKey,
    required double? Function(PayslipManualEntry) read,
    required bool Function(PayslipManualEntry) has,
  }) {
    final itemized = entries.where(has).toList();
    if (itemized.isEmpty) return const [];

    final baseline = itemized.first;
    final baselineAmount = read(baseline)!;
    final out = <PayslipDiscrepancy>[];

    for (final entry in entries) {
      if (entry.sortKey == baseline.sortKey) continue;
      final amount = read(entry);
      final entryHas = has(entry);
      if (!entryHas && baselineAmount > 0) {
        out.add(
          PayslipDiscrepancy(
            kind: kind,
            messageKey: messageKey,
            params: {
              'month': _monthLabel(entry, locale),
              'amount': _formatQar(0),
              'refMonth': _monthLabel(baseline, locale),
              'refAmount': _formatQar(baselineAmount),
            },
          ),
        );
      } else if (entryHas && !_salariesEqual(amount!, baselineAmount)) {
        out.add(
          PayslipDiscrepancy(
            kind: kind,
            messageKey: messageKey,
            params: {
              'month': _monthLabel(entry, locale),
              'amount': _formatQar(amount),
              'refMonth': _monthLabel(baseline, locale),
              'refAmount': _formatQar(baselineAmount),
            },
          ),
        );
      }
    }
    return out;
  }

  static List<PayslipDiscrepancy> _dedupeDiscrepancies(
    List<PayslipDiscrepancy> items,
  ) {
    final seen = <String>{};
    return items.where((d) => seen.add('${d.messageKey}:${d.params}')).toList();
  }

  static bool _salariesEqual(double a, double b) =>
      (a - b).abs() <= kPayslipSalaryToleranceQar;

  static String _formatQar(double amount) =>
      amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);

  static String _monthLabel(PayslipManualEntry entry, String locale) =>
      _monthLabelFromParts(entry.year, entry.month, locale);

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _monthLabelFromParts(int year, int month, String locale) {
    if (month >= 1 && month <= 12) {
      return '${_monthNames[month - 1]} $year';
    }
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  static int _nextMonth(int year, int month) {
    if (month == 12) return (year + 1) * 12 + 1;
    return year * 12 + month + 1;
  }

  static (int, int) _fromSortKey(int key) {
    final year = key ~/ 12;
    final month = key % 12;
    return month == 0 ? (year - 1, 12) : (year, month);
  }
}
