import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';

/// Derived bill lists for the utility bills dashboard.
class BillTrackerSummary {
  const BillTrackerSummary({
    required this.all,
    required this.unpaid,
    required this.paid,
    required this.overdue,
    required this.dueSoon,
    required this.upcoming,
    required this.totalUnpaid,
  });

  final List<BillEntry> all;
  final List<BillEntry> unpaid;
  final List<BillEntry> paid;
  final List<BillEntry> overdue;
  final List<BillEntry> dueSoon;
  final List<BillEntry> upcoming;
  final double totalUnpaid;

  bool get isEmpty => all.isEmpty;

  factory BillTrackerSummary.fromBills(List<BillEntry> bills) {
    final unpaid = bills.where((b) => !b.isPaid).toList();
    final paid = bills.where((b) => b.isPaid).toList();
    final overdue = bills.where((b) => b.isOverdue).toList();
    final dueSoon = bills.where((b) => b.isDueSoon).toList();
    final upcoming = unpaid
        .where((b) => !b.isOverdue && !b.isDueSoon)
        .toList(growable: false);

    return BillTrackerSummary(
      all: bills,
      unpaid: unpaid,
      paid: paid,
      overdue: overdue,
      dueSoon: dueSoon,
      upcoming: upcoming,
      totalUnpaid: unpaid.fold(0.0, (sum, bill) => sum + bill.amount),
    );
  }
}
