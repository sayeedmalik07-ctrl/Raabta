import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

export 'package:raabta/providers/auth_providers.dart';

/// Hardcoded admin allowlist — update with your Firebase Auth email/UID.
const adminEmails = <String>{
  'admin@raabta.app',
  'sayeed@raabta.app',
  'mohammadsayeed@gmail.com',
  'sayeedmalik07@gmail.com',
  'admin@raabtaone.com',
  'sayeed@raabtaone.com',
};

const adminUids = <String>{
  'crRIGNf5D0MWBYum6lAOLIKtIbF3', // Sayeed — email-auth Firebase user
  // Add phone-only account UID here when available (separate Firebase user).
};

class AdminAccess {
  AdminAccess._();

  static bool isAdminUser(User? user) {
    if (user == null) return false;
    final email = user.email?.trim().toLowerCase();
    if (email != null && adminEmails.contains(email)) return true;
    return adminUids.contains(user.uid);
  }

  static bool isCurrentUserAdmin() =>
      isAdminUser(AuthSessionService.instance.currentUser);
}

final isAdminProvider = Provider<bool>((ref) {
  ref.watch(authStateChangesProvider);
  return AdminAccess.isAdminUser(ref.watch(currentUserProvider));
});
