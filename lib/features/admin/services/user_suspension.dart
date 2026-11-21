/// Reads suspension flags from Firestore user profile maps.
abstract final class UserSuspension {
  static bool isSuspendedMap(Map<String, dynamic>? data) {
    if (data == null) return false;
    return data['isSuspended'] == true || data['suspended'] == true;
  }
}
