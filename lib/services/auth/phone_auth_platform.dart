import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Firebase phone/SMS auth is only implemented on iOS and Android.
bool get isPhoneAuthSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// iOS phone auth uses silent push; request permission and register for APNs first.
Future<void> preparePhoneAuthIfNeeded() async {
  if (kIsWeb || !Platform.isIOS) return;

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

String phoneAuthUnsupportedMessage() {
  if (kIsWeb) {
    return 'Phone sign-in works in the iOS and Android apps. Browser support is not enabled yet.';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
      return 'SMS verification is not supported on the macOS app. '
          'Sign in on an iPhone or Android device, or continue without an account below.';
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return 'Phone sign-in requires the iOS or Android app. '
          'You can continue without an account below.';
    default:
      return 'Phone sign-in is not available on this device.';
  }
}
