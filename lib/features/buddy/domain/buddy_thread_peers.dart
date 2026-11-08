import 'package:raabta/features/buddy/models/buddy_thread.dart';

/// Derives chat peer from server thread fields — never trust client-supplied peer alone.
abstract final class BuddyThreadPeers {
  static String? peerUidForParticipant({
    required BuddyThread thread,
    required String myUid,
  }) {
    if (!thread.participantUids.contains(myUid)) return null;
    if (myUid == thread.newcomerUid) return thread.helperUid;
    if (myUid == thread.helperUid) return thread.newcomerUid;
    return null;
  }
}
