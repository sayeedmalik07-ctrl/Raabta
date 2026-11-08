import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum SensitiveSafetyAuthOutcome {
  success,
  cancelled,
  failed,
  notAvailable,
}

/// OS authentication only — Raabta sees success/failure, never biometrics.
abstract class SensitiveSafetyAuthClient {
  Future<bool> canAuthenticate();

  Future<SensitiveSafetyAuthOutcome> authenticate({
    required String localizedReason,
  });
}

class LocalAuthSensitiveSafetyClient implements SensitiveSafetyAuthClient {
  LocalAuthSensitiveSafetyClient([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> canAuthenticate() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSecure = await _auth.isDeviceSupported();
      return canCheck || isDeviceSecure;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<SensitiveSafetyAuthOutcome> authenticate({
    required String localizedReason,
  }) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (ok) return SensitiveSafetyAuthOutcome.success;
      return SensitiveSafetyAuthOutcome.cancelled;
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      if (code.contains('cancel') || code.contains('abort')) {
        return SensitiveSafetyAuthOutcome.cancelled;
      }
      if (code.contains('notavailable') ||
          code.contains('not_enrolled') ||
          code.contains('passcode') ||
          code.contains('lockout')) {
        return SensitiveSafetyAuthOutcome.notAvailable;
      }
      return SensitiveSafetyAuthOutcome.failed;
    } catch (_) {
      return SensitiveSafetyAuthOutcome.failed;
    }
  }
}

/// Test double — never stores or logs biometric payloads.
class FakeSensitiveSafetyAuthClient implements SensitiveSafetyAuthClient {
  FakeSensitiveSafetyAuthClient({
    this.deviceCanAuth = true,
    this.nextOutcome = SensitiveSafetyAuthOutcome.success,
    List<String>? callLog,
  }) : callLog = callLog ?? [];

  bool deviceCanAuth;
  SensitiveSafetyAuthOutcome nextOutcome;
  final List<String> callLog;

  @override
  Future<bool> canAuthenticate() async => deviceCanAuth;

  @override
  Future<SensitiveSafetyAuthOutcome> authenticate({
    required String localizedReason,
  }) async {
    callLog.add('authenticate:$localizedReason');
    return nextOutcome;
  }
}
