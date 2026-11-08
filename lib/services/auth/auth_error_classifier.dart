import 'package:firebase_auth/firebase_auth.dart';

/// Classifies Firebase Auth errors — transient failures must not trigger logout.
class AuthErrorClassifier {
  AuthErrorClassifier._();

  static const transientCodes = {
    'network-request-failed',
    'too-many-requests',
    'timeout',
    'internal-error',
  };

  static const fatalCodes = {
    'user-disabled',
    'user-token-expired',
    'user-not-found',
    'invalid-user-token',
    'invalid-credential',
    'operation-not-allowed',
  };

  static bool isTransient(FirebaseAuthException error) {
    return transientCodes.contains(error.code);
  }

  static bool isFatal(FirebaseAuthException error) {
    return fatalCodes.contains(error.code);
  }

  static bool isTransientError(Object error) {
    if (error is FirebaseAuthException) {
      return isTransient(error);
    }
    final message = error.toString().toLowerCase();
    return message.contains('socket') ||
        message.contains('network') ||
        message.contains('timeout') ||
        message.contains('connection');
  }

  static String userMessageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-disabled':
        return 'Your account has been disabled. Please contact support.';
      case 'user-token-expired':
      case 'invalid-user-token':
        return 'Your session expired for security. Please sign in again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Could not reach the server. Check your connection.';
      default:
        return error.message ?? 'Authentication error. Please try again.';
    }
  }
}
