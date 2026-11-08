import 'package:flutter/foundation.dart';

/// Anonymous tenancy analytics — debug logging until Firebase Analytics wired.
abstract final class TenancyAnalyticsService {
  static void complianceCheckCompleted({
    required bool hasCriticalIssue,
    required bool hasViolation,
  }) {
    debugPrint(
      '[Tenancy Analytics] compliance_check '
      'critical=$hasCriticalIssue violation=$hasViolation',
    );
  }

  static void disputePacketGenerated({required int collectedCount}) {
    debugPrint(
      '[Tenancy Analytics] dispute_packet_generated collected=$collectedCount',
    );
  }

  static void aiAssistantUsed({required String topicCategory}) {
    debugPrint(
      '[Tenancy Analytics] ai_assistant topic=$topicCategory',
    );
  }
}
