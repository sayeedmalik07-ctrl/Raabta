import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_constants.dart';

/// In-memory session — cleared on background timeout or explicit lock.
class SensitiveSafetyLockSession {
  DateTime? unlockedAt;
  DateTime? backgroundStartedAt;

  bool get isUnlocked => unlockedAt != null;

  void markUnlocked() {
    unlockedAt = DateTime.now();
    backgroundStartedAt = null;
  }

  void lock() {
    unlockedAt = null;
  }

  void onPaused() {
    backgroundStartedAt ??= DateTime.now();
  }

  void onResumed() {
    final started = backgroundStartedAt;
    if (started != null &&
        DateTime.now().difference(started) >=
            SensitiveSafetyLockConstants.backgroundReauthDuration) {
      lock();
    }
    backgroundStartedAt = null;
  }
}
