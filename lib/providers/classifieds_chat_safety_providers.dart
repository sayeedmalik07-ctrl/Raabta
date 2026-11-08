import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/classifieds/block_user_repository.dart';
import 'package:raabta/services/report_service.dart';

final blockUserRepositoryProvider = Provider<BlockUserRepository>(
  (ref) => BlockUserRepository(),
);

final blockedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(blockUserRepositoryProvider).watchBlockedUserIds();
});

final blockedUsersListProvider = StreamProvider<List<BlockedUserEntry>>((ref) {
  return ref.watch(blockUserRepositoryProvider).watchBlockedUsers();
});

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(),
);
