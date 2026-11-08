import 'package:flutter/foundation.dart';

abstract final class DisruptionReadinessAnalytics {
  static void moduleOpened({
    required String profile,
    String? tripId,
  }) {
    debugPrint(
      '[DisruptionReadiness] open profile=$profile'
      '${tripId == null ? '' : ' tripId=$tripId'}',
    );
  }

  static void understandAlertOpened() {
    debugPrint('[DisruptionReadiness] understand_alert_opened');
  }
}
