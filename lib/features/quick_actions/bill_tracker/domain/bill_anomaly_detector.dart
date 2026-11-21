import 'package:raabta/features/quick_actions/bill_tracker/constants/bill_anomaly_thresholds.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';

/// Compares each unpaid bill to a rolling per-provider average (Part C).
abstract final class BillAnomalyDetector {
  static List<BillAnomaly> detectAll(
    List<BillEntry> bills, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final byProvider = <String, List<BillEntry>>{};
    for (final bill in bills) {
      final key = bill.displayProvider;
      byProvider.putIfAbsent(key, () => []).add(bill);
    }

    final anomalies = <BillAnomaly>[];
    for (final entry in byProvider.entries) {
      final providerBills = _inRollingWindow(entry.value, now);
      if (providerBills.length < 2) continue;

      for (final target in providerBills.where((b) => !b.isPaid)) {
        final anomaly = _evaluateBill(
          target: target,
          providerBills: providerBills,
          now: now,
        );
        if (anomaly != null) anomalies.add(anomaly);
      }
    }

    anomalies.sort(
      (a, b) => b.percentAboveAverage.compareTo(a.percentAboveAverage),
    );
    return anomalies;
  }

  static BillAnomaly? forBillId(
    String billId,
    List<BillEntry> bills, {
    DateTime? referenceDate,
  }) {
    for (final anomaly in detectAll(bills, referenceDate: referenceDate)) {
      if (anomaly.billId == billId) return anomaly;
    }
    return null;
  }

  static BillAnomaly? _evaluateBill({
    required BillEntry target,
    required List<BillEntry> providerBills,
    required DateTime now,
  }) {
    final baseline = providerBills
        .where((b) => b.id != target.id)
        .where((b) => _billSortDate(b).isBefore(_billSortDate(target)))
        .toList();

    if (baseline.length < BillAnomalyThresholds.minBaselineBillCount) {
      return null;
    }

    if (!_hasMinimumHistorySpan(baseline)) {
      return null;
    }

    final average =
        baseline.fold<double>(0, (sum, b) => sum + b.amount) / baseline.length;
    if (average <= 0) return null;

    final threshold =
        average * (1 + BillAnomalyThresholds.spikeThresholdFraction);
    if (target.amount <= threshold) return null;

    final percentAbove = ((target.amount - average) / average) * 100;

    return BillAnomaly(
      billId: target.id,
      provider: target.provider,
      displayProvider: target.displayProvider,
      currentAmount: target.amount,
      averageAmount: average,
      percentAboveAverage: percentAbove,
      baselineBillCount: baseline.length,
      currency: target.currency,
    );
  }

  static List<BillEntry> _inRollingWindow(
    List<BillEntry> bills,
    DateTime now,
  ) {
    final cutoff = now.subtract(
      Duration(
        days: BillAnomalyThresholds.rollingWindowMonths *
            BillAnomalyThresholds.daysPerMonth,
      ),
    );
    return bills
        .where((b) => !_billSortDate(b).isBefore(cutoff))
        .toList()
      ..sort((a, b) => _billSortDate(a).compareTo(_billSortDate(b)));
  }

  static bool _hasMinimumHistorySpan(List<BillEntry> baseline) {
    if (baseline.isEmpty) return false;
    final dates = baseline.map(_billSortDate).toList()..sort();
    final spanDays = dates.last.difference(dates.first).inDays;
    return spanDays >=
        BillAnomalyThresholds.minHistoryMonths *
            BillAnomalyThresholds.daysPerMonth;
  }

  static DateTime _billSortDate(BillEntry bill) =>
      bill.billingPeriodEnd ?? bill.dueDate;
}
