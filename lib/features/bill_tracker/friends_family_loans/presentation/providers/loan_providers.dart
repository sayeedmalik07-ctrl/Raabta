import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/data/repository/loan_repository.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_balance_calculator.dart';
import 'package:raabta/services/raabta_notification_service.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepository();
});

final loanUserIdProvider = FutureProvider<String>((ref) async {
  return RaabtaNotificationService.instance.getOrCreateUserId();
});

final loanEntriesStreamProvider =
    StreamProvider.autoDispose<List<LoanEntryModel>>((ref) async* {
  final userId = await ref.watch(loanUserIdProvider.future);
  yield* ref.watch(loanRepositoryProvider).watchLoans(userId);
});

final personLoanSummariesProvider =
    Provider.autoDispose<List<PersonLoanSummary>>((ref) {
  final entries = ref.watch(loanEntriesStreamProvider).valueOrNull ?? [];
  return groupEntriesByPerson(entries);
});

final knownLoanPersonNamesProvider = Provider.autoDispose<List<String>>((ref) {
  final entries = ref.watch(loanEntriesStreamProvider).valueOrNull ?? [];
  return knownPersonNames(entries);
});

final archivedPersonSummariesProvider =
    Provider.autoDispose<List<PersonLoanSummary>>((ref) {
  final summaries = ref.watch(personLoanSummariesProvider);
  return summaries
      .where((s) => s.activeEntries.isEmpty && s.settledEntries.isNotEmpty)
      .toList();
});

final activePersonSummariesProvider =
    Provider.autoDispose<List<PersonLoanSummary>>((ref) {
  final summaries = ref.watch(personLoanSummariesProvider);
  return summaries.where((s) => s.activeEntries.isNotEmpty).toList();
});
