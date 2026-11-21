/// Deterministic buddy thread document id from two participant uids.
abstract final class BuddyThreadIds {
  static String forParticipants(String uidA, String uidB) {
    final sorted = [uidA.trim(), uidB.trim()]..sort();
    if (sorted[0].isEmpty || sorted[1].isEmpty || sorted[0] == sorted[1]) {
      throw ArgumentError('Invalid participant uids');
    }
    return '${sorted[0]}__${sorted[1]}';
  }

  static List<String> sortedParticipantUids(String uidA, String uidB) {
    final sorted = [uidA.trim(), uidB.trim()]..sort();
    return sorted;
  }
}
