import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/bill_tracker_repository.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_detector.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_tracker_summary.dart';
import 'package:raabta/services/raabta_notification_service.dart';

final billTrackerRepositoryProvider = Provider<BillTrackerRepository>((ref) {
  return BillTrackerRepository();
});

final billTrackerUserIdProvider = FutureProvider<String>((ref) async {
  return RaabtaNotificationService.instance.getOrCreateUserId();
});

final billTrackerEntriesStreamProvider =
    StreamProvider.autoDispose<List<BillEntry>>((ref) async* {
  final userId = await ref.watch(billTrackerUserIdProvider.future);
  yield* ref.watch(billTrackerRepositoryProvider).watchBills(userId);
});

final billTrackerSummaryProvider =
    Provider.autoDispose<BillTrackerSummary>((ref) {
  final bills = ref.watch(billTrackerEntriesStreamProvider).valueOrNull ?? [];
  return BillTrackerSummary.fromBills(bills);
});

final billAnomaliesProvider =
    Provider.autoDispose<List<BillAnomaly>>((ref) {
  final bills = ref.watch(billTrackerEntriesStreamProvider).valueOrNull ?? [];
  return BillAnomalyDetector.detectAll(bills);
});

final billAnomalyByIdProvider =
    Provider.autoDispose<Map<String, BillAnomaly>>((ref) {
  final anomalies = ref.watch(billAnomaliesProvider);
  return {for (final a in anomalies) a.billId: a};
});
