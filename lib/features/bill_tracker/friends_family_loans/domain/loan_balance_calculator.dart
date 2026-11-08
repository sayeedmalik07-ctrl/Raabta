import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

/// Normalizes person names for grouping and autocomplete keys.
String personKeyFromName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

double totalRepaid(List<LoanRepayment> repayments) =>
    repayments.fold(0.0, (sum, r) => sum + r.amount);

double remainingBalance(LoanEntryModel entry) {
  final repaid = totalRepaid(entry.repayments);
  return (entry.amount - repaid).clamp(0.0, double.infinity);
}

LoanStatus computeLoanStatus(LoanEntryModel entry, {DateTime? now}) {
  final remaining = remainingBalance(entry);
  if (remaining <= 0) return LoanStatus.settled;
  final clock = now ?? DateTime.now();
  final dueDay = DateTime(entry.dueDate.year, entry.dueDate.month, entry.dueDate.day);
  final today = DateTime(clock.year, clock.month, clock.day);
  if (dueDay.isBefore(today)) return LoanStatus.overdue;
  return LoanStatus.active;
}

bool isEntryActive(LoanEntryModel entry) =>
    remainingBalance(entry) > 0 && !entry.isArchived;

/// Net balance for one person: positive = they owe you, negative = you owe them.
double netBalanceForPerson(List<LoanEntryModel> entries) {
  var net = 0.0;
  for (final entry in entries) {
    final remaining = remainingBalance(entry);
    if (remaining <= 0) continue;
    net += entry.direction == LoanDirection.lent ? remaining : -remaining;
  }
  return net;
}

bool personHasOverdue(List<LoanEntryModel> entries, {DateTime? now}) {
  return entries.any(
    (e) => isEntryActive(e) && computeLoanStatus(e, now: now) == LoanStatus.overdue,
  );
}

class PersonLoanSummary {
  const PersonLoanSummary({
    required this.personName,
    required this.personKey,
    required this.netBalance,
    required this.hasOverdue,
    required this.activeEntries,
    required this.settledEntries,
  });

  final String personName;
  final String personKey;
  final double netBalance;
  final bool hasOverdue;
  final List<LoanEntryModel> activeEntries;
  final List<LoanEntryModel> settledEntries;
}

List<PersonLoanSummary> groupEntriesByPerson(
  List<LoanEntryModel> entries, {
  DateTime? now,
}) {
  final byKey = <String, List<LoanEntryModel>>{};
  final displayNames = <String, String>{};

  for (final entry in entries) {
    final key = personKeyFromName(entry.personName);
    byKey.putIfAbsent(key, () => []).add(entry);
    displayNames[key] ??= entry.personName.trim();
  }

  final summaries = <PersonLoanSummary>[];
  for (final key in byKey.keys) {
    final personEntries = byKey[key]!;
    final active = personEntries.where(isEntryActive).toList();
    final settled = personEntries.where((e) => !isEntryActive(e)).toList();

    if (active.isEmpty && settled.isEmpty) continue;

    summaries.add(
      PersonLoanSummary(
        personName: displayNames[key] ?? key,
        personKey: key,
        netBalance: netBalanceForPerson(personEntries),
        hasOverdue: personHasOverdue(active, now: now),
        activeEntries: active,
        settledEntries: settled,
      ),
    );
  }

  summaries.sort((a, b) {
    if (a.activeEntries.isNotEmpty != b.activeEntries.isNotEmpty) {
      return a.activeEntries.isNotEmpty ? -1 : 1;
    }
    return a.personName.toLowerCase().compareTo(b.personName.toLowerCase());
  });

  return summaries;
}

List<String> knownPersonNames(List<LoanEntryModel> entries) {
  final names = <String>{};
  for (final entry in entries) {
    final trimmed = entry.personName.trim();
    if (trimmed.isNotEmpty) names.add(trimmed);
  }
  final sorted = names.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return sorted;
}

/// Monthly reminder anchor: same day-of-month as [dueDate], 9:00 local.
/// If day doesn't exist in a month, uses last day of that month.
DateTime monthlyReminderAnchor(DateTime dueDate, int monthOffset, {DateTime? now}) {
  final base = now ?? DateTime.now();
  final targetMonth = DateTime(base.year, base.month + monthOffset, 1);
  final day = dueDate.day;
  final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
  final safeDay = day > lastDay ? lastDay : day;
  return DateTime(
    targetMonth.year,
    targetMonth.month,
    safeDay,
    9,
  );
}

/// Generates upcoming monthly reminder dates (up to [horizonMonths]).
List<DateTime> upcomingMonthlyReminders({
  required DateTime dueDate,
  int horizonMonths = 12,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final anchors = <DateTime>[];
  for (var i = 0; i < horizonMonths; i++) {
    final anchor = monthlyReminderAnchor(dueDate, i, now: clock);
    if (anchor.isAfter(clock)) {
      anchors.add(anchor);
    }
  }
  if (anchors.isEmpty) {
    anchors.add(monthlyReminderAnchor(dueDate, 1, now: clock));
  }
  return anchors;
}

String buildLoanReminderTitle(LoanDirection direction) =>
    direction == LoanDirection.lent ? 'Loan reminder' : 'Repayment reminder';

String buildLoanReminderBody({
  required LoanDirection direction,
  required String personName,
  required double remainingAmount,
  required DateTime dueDate,
}) {
  final amount = remainingAmount.toStringAsFixed(0);
  final due = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  if (direction == LoanDirection.lent) {
    return 'Reminder: $personName still owes you QAR $amount (due $due)';
  }
  return 'Reminder: You still owe $personName QAR $amount (was due $due)';
}

String buildLoanReminderShareMessage({
  required LoanDirection direction,
  required String personName,
  required double remainingAmount,
  required DateTime dueDate,
  required String locale,
}) {
  final amount = remainingAmount.toStringAsFixed(2);
  final due = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  final key = direction == LoanDirection.lent
      ? 'loan_reminder_share_lent'
      : 'loan_reminder_share_borrowed';
  return BillTrackerStrings.format(key, locale, {
    'name': personName,
    'amount': amount,
    'due': due,
  });
}
