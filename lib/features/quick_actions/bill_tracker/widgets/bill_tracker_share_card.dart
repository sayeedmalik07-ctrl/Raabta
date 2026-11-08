import 'package:flutter/material.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_tracker_summary.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

UtilityBillsCardData buildBillTrackerShareCardData({
  required BillTrackerSummary summary,
  required String locale,
}) {
  final unpaidRows = summary.unpaid
      .map(
        (bill) => UtilityBillShareRow(
          emoji: bill.displayEmoji,
          provider: bill.displayProvider,
          amount: bill.amount,
          dueLabel: BillTrackerStrings.dueLabel(
            isPaid: bill.isPaid,
            daysUntilDue: bill.daysUntilDue,
            locale: locale,
          ),
          isOverdue: bill.isOverdue,
        ),
      )
      .toList(growable: false);

  return UtilityBillsCardData(
    totalOutstanding: summary.totalUnpaid,
    overdueCount: summary.overdue.length,
    dueSoonCount: summary.dueSoon.length,
    paidCount: summary.paid.length,
    unpaidBills: unpaidRows,
    shareCaption: summary.totalUnpaid > 0
        ? 'My Qatar bills — QAR ${summary.totalUnpaid.toStringAsFixed(0)} outstanding on RAABTA'
        : 'All my Qatar utility bills are paid on RAABTA 🎉',
  );
}

Future<void> showBillTrackerShareCard(
  BuildContext context, {
  required BillTrackerSummary summary,
  required String locale,
}) {
  return ShareCardSheet.show(
    context,
    buildBillTrackerShareCardData(summary: summary, locale: locale),
  );
}
