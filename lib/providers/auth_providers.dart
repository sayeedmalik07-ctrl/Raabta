import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/auth/auth_session_service.dart';

/// Live Firebase Auth session — updates on sign-in, sign-out, and token refresh.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return AuthSessionService.instance.authStateChanges;
});

/// Fires when the ID token is refreshed (~hourly). UI rarely needs this directly.
final idTokenChangesProvider = StreamProvider<User?>((ref) {
  return AuthSessionService.instance.idTokenChanges;
});

/// Current user derived from the auth stream (not a one-shot snapshot).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull ??
      AuthSessionService.instance.currentUser;
});

/// True once Firebase has emitted the initial restored auth state on startup.
final authSessionReadyProvider = FutureProvider<bool>((ref) async {
  await AuthSessionService.instance.waitForInitialAuthState();
  return true;
});

/// Whether a Firebase user session is active.
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Resolves auth for profile screens — waits past the cold-start null emission.
final resolvedAuthUserForProfileProvider =
    FutureProvider.autoDispose<User?>((ref) async {
  await ref.watch(authSessionReadyProvider.future);
  ref.watch(authStateChangesProvider);

  var user = AuthSessionService.instance.currentUser;
  if (user != null) return user;

  try {
    user = await AuthSessionService.instance.authStateChanges
        .firstWhere((u) => u != null)
        .timeout(const Duration(seconds: 4));
    return user;
  } catch (_) {
    return AuthSessionService.instance.currentUser;
  }
});
