import 'dart:io' show Platform;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// App Check tokens for Scam Shield anonymous signal uploads only.
class ScamAppCheckService {
  ScamAppCheckService._();
  static final instance = ScamAppCheckService._();

  static bool _activated = false;

  /// Anonymous signal uploads target iOS/Android; desktop builds skip App Check.
  static bool get supported =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS);

  Future<void> activateIfNeeded() async {
    if (!supported) return;
    if (_activated) return;
    _activated = true;
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  }

  Future<String?> getToken() async {
    if (!supported) return null;
    try {
      await activateIfNeeded();
      return FirebaseAppCheck.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}
