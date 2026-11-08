import 'package:firebase_auth/firebase_auth.dart';

/// Identity verification signal available through Firebase Auth / [AuthSessionService].
abstract final class PostIdentityVerification {
  /// True when the account is signed in and has a verified email or phone identity.
  static bool isVerified(User? user) {
    if (user == null || user.isAnonymous) return false;
    if (user.emailVerified) return true;
    final phone = user.phoneNumber;
    return phone != null && phone.trim().isNotEmpty;
  }
}
