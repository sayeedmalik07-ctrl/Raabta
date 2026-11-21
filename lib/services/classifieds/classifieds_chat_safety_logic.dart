/// Filters and send eligibility for classifieds chats (client-side).
abstract final class ClassifiedsChatSafetyLogic {
  static List<T> visibleMessages<T>({
    required List<T> messages,
    required String myUid,
    required Set<String> blockedUserIds,
    required String Function(T message) senderIdOf,
  }) {
    if (blockedUserIds.isEmpty) return messages;
    return [
      for (final m in messages)
        if (!blockedUserIds.contains(senderIdOf(m))) m,
    ];
  }

  static bool composerEnabled({
    required String? peerUid,
    required Set<String> myBlockedUserIds,
  }) {
    if (peerUid == null || peerUid.isEmpty) return true;
    return !myBlockedUserIds.contains(peerUid);
  }

  static String? inferMarketplacePeer({
    required String myUid,
    required String listingOwnerUid,
    required List<String> messageSenderIds,
  }) {
    if (myUid != listingOwnerUid) return listingOwnerUid;
    for (final sender in messageSenderIds.reversed) {
      if (sender.isNotEmpty && sender != myUid) return sender;
    }
    return null;
  }
}
