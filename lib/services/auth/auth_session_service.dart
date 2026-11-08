import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/services/auth/auth_error_classifier.dart';

/// Firebase Auth session lifecycle — single source of truth for token refresh
/// and startup restoration. Does not cache tokens manually; always uses SDK
/// [User.getIdToken] which refreshes internally.
class AuthSessionService {
  AuthSessionService({
    FirebaseAuth? auth,
    void Function(String message)? debugLog,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _debugLog = debugLog ?? _defaultDebugLog;

  final FirebaseAuth _auth;
  final void Function(String message) _debugLog;

  static final AuthSessionService instance = AuthSessionService();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<User?>? _tokenSubscription;

  User? _lastKnownUser;
  bool _suppressNextSessionEndedNotice = false;
  bool _initialized = false;

  /// Last unexpected session termination reason (debug / optional UI).
  String? lastSessionEndedReason;

  static void _defaultDebugLog(String message) {
    if (kDebugMode) {
      debugPrint('[AuthSession] $message');
    }
  }

  FirebaseAuth get auth => _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  /// Call once at app start — waits for persisted session restore, then listens.
  Future<User?> initialize() async {
    if (_initialized) return _auth.currentUser;
    _initialized = true;

    final user = await waitForInitialAuthState();
    _lastKnownUser = user;
    _logSessionHealth('initialize', user);

    _authSubscription ??= _auth.authStateChanges().listen(_onAuthStateChanged);
    _tokenSubscription ??= _auth.idTokenChanges().listen(_onIdTokenChanged);

    return user;
  }

  /// Waits for Firebase to emit the restored auth state (cold start / relaunch).
  Future<User?> waitForInitialAuthState({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final user = await _auth.authStateChanges().first.timeout(
            timeout,
            onTimeout: () => _auth.currentUser,
          );
      _debugLog(
        'Initial auth state: ${user == null ? 'signed-out' : 'uid=${user.uid}'}',
      );
      return user;
    } catch (e) {
      _debugLog('Initial auth wait error (using currentUser): $e');
      return _auth.currentUser;
    }
  }

  void _onAuthStateChanged(User? user) {
    final previous = _lastKnownUser;
    _lastKnownUser = user;

    if (previous?.uid != user?.uid) {
      _logSessionHealth('authStateChanges', user);
    }

    if (previous != null && user == null) {
      if (_suppressNextSessionEndedNotice) {
        _suppressNextSessionEndedNotice = false;
        _debugLog('Session cleared (explicit sign-out or admin action)');
        return;
      }
      lastSessionEndedReason =
          'Your session ended. Please sign in again to continue.';
      _debugLog('Unexpected sign-out detected');
    }
  }

  void _onIdTokenChanged(User? user) {
    if (user != null) {
      _debugLog('ID token refreshed for uid=${user.uid}');
    }
  }

  void _logSessionHealth(String source, User? user) {
    _debugLog(
      '$source → ${user == null ? 'no session' : 'active uid=${user.uid}'}',
    );
  }

  /// Marks the next auth-state-null event as intentional (no session-ended UI).
  void markSuppressSessionEndedNotice() {
    _suppressNextSessionEndedNotice = true;
  }

  bool consumeSuppressSessionEndedNotice() {
    if (_suppressNextSessionEndedNotice) {
      _suppressNextSessionEndedNotice = false;
      return true;
    }
    return false;
  }

  /// User-initiated sign-out — only path that should clear session deliberately.
  Future<void> signOutExplicit() async {
    markSuppressSessionEndedNotice();
    await _auth.signOut();
    _debugLog('Explicit sign-out');
  }

  /// Returns a fresh ID token. Retries transient failures; never signs out.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await user.getIdToken(forceRefresh);
      } on FirebaseAuthException catch (e) {
        lastError = e;
        if (AuthErrorClassifier.isTransient(e) && attempt < 2) {
          _debugLog(
            'getIdToken transient error (${e.code}), retry ${attempt + 1}',
          );
          await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
          continue;
        }
        _debugLog('getIdToken failed: ${e.code} ${e.message}');
        rethrow;
      } catch (e) {
        lastError = e;
        if (AuthErrorClassifier.isTransientError(e) && attempt < 2) {
          _debugLog('getIdToken network error, retry ${attempt + 1}');
          await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
          continue;
        }
        _debugLog('getIdToken failed: $e');
        rethrow;
      }
    }
    throw lastError ?? StateError('getIdToken failed');
  }

  @visibleForTesting
  void resetForTests() {
    _authSubscription?.cancel();
    _tokenSubscription?.cancel();
    _authSubscription = null;
    _tokenSubscription = null;
    _initialized = false;
    _lastKnownUser = null;
    _suppressNextSessionEndedNotice = false;
    lastSessionEndedReason = null;
  }
}
