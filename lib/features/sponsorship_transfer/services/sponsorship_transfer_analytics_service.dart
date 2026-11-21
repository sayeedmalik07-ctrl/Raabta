import 'package:flutter/foundation.dart';

/// Anonymous sponsorship transfer analytics — debug logging until Firebase Analytics wired.
abstract final class SponsorshipTransferAnalyticsService {
  static void readinessCheckCompleted({
    required bool hasCriticalIssue,
    required bool hasWarning,
  }) {
    debugPrint(
      '[Sponsorship Transfer Analytics] readiness_check '
      'critical=$hasCriticalIssue warning=$hasWarning',
    );
  }

  static void checklistUpdated({required int collectedCount}) {
    debugPrint(
      '[Sponsorship Transfer Analytics] checklist_updated collected=$collectedCount',
    );
  }

  static void packetGenerated({required int collectedCount}) {
    debugPrint(
      '[Sponsorship Transfer Analytics] packet_generated collected=$collectedCount',
    );
  }

  static void aiAssistantUsed() {
    debugPrint('[Sponsorship Transfer Analytics] ai_assistant_used');
  }
}
