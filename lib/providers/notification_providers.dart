import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notification_repository.dart';

final notificationRepositoryProvider =
    FutureProvider<NotificationRepository>((ref) async {
  return createNotificationRepository();
});

final notificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) async* {
  final repo = await ref.watch(notificationRepositoryProvider.future);
  yield* repo.watchNotifications();
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) async* {
  final repo = await ref.watch(notificationRepositoryProvider.future);
  yield* repo.watchUnreadCount();
});

final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  final repo = await ref.watch(notificationRepositoryProvider.future);
  return repo.getSettings();
});
