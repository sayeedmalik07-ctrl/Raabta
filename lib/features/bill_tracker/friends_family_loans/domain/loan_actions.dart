import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_balance_calculator.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/services/smart_notification_engine.dart';

/// Schedules or cancels loan reminders — failures are logged, never block saves.
Future<void> syncLoanReminders(LoanEntryModel entry) async {
  final remaining = remainingBalance(entry);
  if (remaining <= 0 || entry.isArchived) {
    await SmartNotificationEngine.instance
        .cancelFriendsFamilyLoanReminders(entry.id);
    return;
  }

  await SmartNotificationEngine.instance.scheduleFriendsFamilyLoanReminders(
    loanId: entry.id,
    personName: entry.personName,
    personKey: personKeyFromName(entry.personName),
    direction: entry.direction,
    remainingAmount: remaining,
    dueDate: entry.dueDate,
  );
}

Future<void> cancelLoanReminders(String loanId) async {
  await SmartNotificationEngine.instance.cancelFriendsFamilyLoanReminders(loanId);
}

String formatLoanStatusLabel(LoanStatus status, String locale) {
  switch (status) {
    case LoanStatus.active:
      return BillTrackerStrings.t('loan_status_active', locale);
    case LoanStatus.overdue:
      return BillTrackerStrings.t('loan_status_overdue', locale);
    case LoanStatus.settled:
      return BillTrackerStrings.t('loan_status_settled', locale);
  }
}

String formatDirectionLabel(LoanDirection direction, String locale) {
  return direction == LoanDirection.lent
      ? BillTrackerStrings.t('loan_direction_they_owe', locale)
      : BillTrackerStrings.t('loan_direction_you_owe', locale);
}
