import 'package:flutter/material.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_actions.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_balance_calculator.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

/// Opens the branded Friends & Family loan summary share card.
void showLoanShareCard(
  BuildContext context, {
  required PersonLoanSummary summary,
  required String locale,
}) {
  final activeRows = summary.activeEntries
      .map(
        (entry) => LoanShareEntryRow(
          directionLabel: formatDirectionLabel(entry.direction, locale),
          amount: remainingBalance(entry),
          dueDate: entry.dueDate,
          statusLabel: computeLoanStatus(entry).name,
        ),
      )
      .toList();

  ShareCardSheet.show(
    context,
    FriendsFamilyLoanCardData(
      personName: summary.personName,
      netBalance: summary.netBalance,
      activeEntries: activeRows,
      shareCaption: BillTrackerStrings.format(
        'loan_share_caption',
        locale,
        {'name': summary.personName},
      ),
    ),
  );
}
