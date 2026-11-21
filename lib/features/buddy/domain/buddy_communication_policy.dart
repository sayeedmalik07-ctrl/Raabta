import 'package:raabta/services/classifieds/block_user_repository.dart';

/// Client-side block checks for Buddy (one direction — rules enforce both).
abstract final class BuddyCommunicationPolicy {
  static Future<bool> isLocallyBlocked({
    required BlockUserRepository blocks,
    required String actorUid,
    required String otherUid,
  }) async {
    if (otherUid.isEmpty || actorUid == otherUid) return false;
    final blocked =
        await blocks.fetchBlockedUserIds(uid: actorUid);
    return blocked.contains(otherUid);
  }

  static Future<void> ensureLocallyAllowed({
    required BlockUserRepository blocks,
    required String actorUid,
    required String otherUid,
  }) async {
    if (await isLocallyBlocked(
      blocks: blocks,
      actorUid: actorUid,
      otherUid: otherUid,
    )) {
      throw StateError('Blocked peer');
    }
  }
}
