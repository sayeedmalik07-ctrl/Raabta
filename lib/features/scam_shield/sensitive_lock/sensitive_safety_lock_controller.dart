import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_auth_client.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_constants.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_prefs.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_providers.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_session.dart';

class SensitiveSafetyLockController {
  SensitiveSafetyLockController(this._ref);

  final Ref _ref;

  SensitiveSafetyLockSession get _session =>
      _ref.read(sensitiveSafetyLockSessionProvider);

  SensitiveSafetyAuthClient get _auth =>
      _ref.read(sensitiveSafetyAuthClientProvider);

  Future<bool> isEnabled() => SensitiveSafetyLockPrefs.isEnabled();

  Future<bool> setEnabled(bool value) async {
    if (value) {
      final can = await _auth.canAuthenticate();
      if (!can) return false;
      final outcome = await _auth.authenticate(
        localizedReason: SensitiveSafetyLockConstants.authReason,
      );
      if (outcome != SensitiveSafetyAuthOutcome.success) return false;
      _session.markUnlocked();
    } else {
      _session.lock();
    }
    await SensitiveSafetyLockPrefs.setEnabled(value);
    _ref.invalidate(sensitiveSafetyLockEnabledProvider);
    return true;
  }

  Future<SensitiveSafetyAuthOutcome> unlock({required String reason}) async {
    final outcome = await _auth.authenticate(localizedReason: reason);
    if (outcome == SensitiveSafetyAuthOutcome.success) {
      _session.markUnlocked();
    }
    return outcome;
  }

  bool get isSessionUnlocked => _session.isUnlocked;

  void lockSession() => _session.lock();

  void onAppPaused() => _session.onPaused();

  void onAppResumed() => _session.onResumed();
}

final sensitiveSafetyLockControllerProvider = Provider(
  (ref) => SensitiveSafetyLockController(ref),
);
