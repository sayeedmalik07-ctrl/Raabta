import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/screens/profile/data/my_activity_repository.dart';
import 'package:raabta/screens/profile/models/my_activity_aggregation.dart';

final myActivityRepositoryProvider = Provider<MyActivityRepository>((ref) {
  return MyActivityRepository();
});

final myActivityPendingItemsProvider =
    StreamProvider<MyActivityAggregation>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid ?? '';
  if (uid.isEmpty) {
    return Stream.value(const MyActivityAggregation(items: []));
  }
  return ref.watch(myActivityRepositoryProvider).watchPendingItems(uid);
});

/// Count of confirmed pending items. Null when aggregation is incomplete.
final myActivityPendingCountProvider = Provider<int?>((ref) {
  return ref.watch(myActivityPendingItemsProvider).maybeWhen(
        data: (aggregation) =>
            aggregation.hasPartialFailure ? null : aggregation.items.length,
        orElse: () => null,
      );
});
