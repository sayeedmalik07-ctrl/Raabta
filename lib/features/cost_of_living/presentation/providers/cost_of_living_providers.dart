import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';
import 'package:raabta/features/cost_of_living/services/cost_of_living_service.dart';
import 'package:raabta/features/cost_of_living/services/personal_comparison_service.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';
import 'package:raabta/features/quick_actions/bill_tracker/presentation/providers/bill_tracker_providers.dart';
import 'package:raabta/providers/auth_providers.dart';

final userBillsProvider = StreamProvider<List<BillEntry>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(billTrackerRepositoryProvider).watchBills(uid);
});

final personalCostComparisonsProvider =
    Provider<List<PersonalCostComparison>>((ref) {
  final snap = ref.watch(costOfLivingSnapshotProvider).valueOrNull;
  if (snap == null) return [];

  final bills = ref.watch(userBillsProvider).valueOrNull;
  if (bills == null || bills.isEmpty) return [];

  return PersonalComparisonService().buildComparisons(
    snapshot: snap,
    bills: bills,
  );
});
