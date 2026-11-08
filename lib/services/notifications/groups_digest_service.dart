import 'dart:async';

import 'package:raabta/core/l10n/app_locale_storage.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';
import 'package:raabta/services/smart_notification_engine.dart';

/// Client-side group activity batching — coalesces posts/replies/joins into
/// a single digest (not one push per event). Prefer Cloud Function batching
/// when backend infra is available.
class GroupsDigestService {
  GroupsDigestService._();
  static final GroupsDigestService instance = GroupsDigestService._();

  static const batchWindow = Duration(minutes: 45);

  final Map<String, _GroupActivityBucket> _buckets = {};
  Timer? _flushTimer;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _flushTimer = Timer.periodic(batchWindow, (_) => _flushAll());
  }

  void stop() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _started = false;
  }

  /// Record activity for digest — never fires immediately.
  void recordActivity({
    required String groupId,
    String? groupName,
    String activityKind = 'post',
  }) {
    start();
    final bucket = _buckets.putIfAbsent(
      groupId,
      () => _GroupActivityBucket(groupId: groupId, groupName: groupName),
    );
    bucket.count++;
    bucket.lastKind = activityKind;
    if (groupName != null) bucket.groupName = groupName;
  }

  Future<void> _flushAll() async {
    if (_buckets.isEmpty) return;
    final snapshot = Map<String, _GroupActivityBucket>.from(_buckets);
    _buckets.clear();

    var totalPosts = 0;
    final groupNames = <String>[];
    for (final b in snapshot.values) {
      totalPosts += b.count;
      groupNames.add(b.groupName ?? b.groupId);
    }
    if (totalPosts == 0) return;

    final groupCount = snapshot.length;
    final locale = await AppLocaleStorage.readNormalized();
    final body = NotificationCopyStrings.groupsDigestBody(
      totalPosts: totalPosts,
      groupCount: groupCount,
      groupName: groupNames.first,
      locale: locale,
    );

    await SmartNotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.groupActivity,
        title: NotificationCopyStrings.t('groups_digest_title', locale),
        body: body,
        route: '/community',
        dedupKey:
            'groups_digest_${DateTime.now().millisecondsSinceEpoch ~/ batchWindow.inMilliseconds}',
        dedupWindow: batchWindow,
        data: {
          'digest': true,
          'groupCount': '$groupCount',
          'activityCount': '$totalPosts',
        },
      ),
    );
  }
}

class _GroupActivityBucket {
  _GroupActivityBucket({required this.groupId, this.groupName});

  final String groupId;
  String? groupName;
  int count = 0;
  String lastKind = 'post';
}
