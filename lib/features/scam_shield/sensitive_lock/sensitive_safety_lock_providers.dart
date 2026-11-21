import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_auth_client.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_prefs.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_session.dart';

final sensitiveSafetyAuthClientProvider = Provider<SensitiveSafetyAuthClient>(
  (ref) => LocalAuthSensitiveSafetyClient(),
);

final sensitiveSafetyLockEnabledProvider =
    FutureProvider<bool>((ref) => SensitiveSafetyLockPrefs.isEnabled());

final sensitiveSafetyLockSessionProvider =
    Provider<SensitiveSafetyLockSession>((ref) {
  final session = SensitiveSafetyLockSession();
  ref.onDispose(session.lock);
  return session;
});
