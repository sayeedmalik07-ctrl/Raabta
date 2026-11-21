import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/router/app_router.dart';

/// Consumes native app shortcuts / flagged-call notification deep links.
abstract final class ScamShieldEntryRoutePlatform {
  static const _channel = MethodChannel('com.sayeed.raabta/scam_proactive');

  static Future<bool> hasInCallAppShortcut() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>('hasInCallAppShortcut') ?? false;
    } catch (e, st) {
      debugPrint('hasInCallAppShortcut failed: $e\n$st');
      return false;
    }
  }

  static Future<void> consumePendingEntryRoute() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final route = await _channel.invokeMethod<String>('consumePendingEntryRoute');
      if (route != null && route.isNotEmpty) {
        appRouter.go(route);
      }
    } catch (e, st) {
      debugPrint('consumePendingEntryRoute failed: $e\n$st');
    }
  }
}
