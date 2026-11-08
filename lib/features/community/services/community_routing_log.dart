import 'package:flutter/foundation.dart';

/// Cost-visibility logging for community moderation routing.
abstract final class CommunityRoutingLog {
  static void prefilterBlock({
    required String contentType,
    required String reason,
  }) {
    debugPrint(
      '[CommunityAnalytics] communityPrefilterBlock '
      'type=$contentType reason=$reason',
    );
  }

  static void dedupHit({
    required String contentType,
    required String verdict,
  }) {
    debugPrint(
      '[CommunityAnalytics] communityDedupHit '
      'type=$contentType verdict=$verdict',
    );
  }

  static void claudeModeration({
    required String contentType,
    bool suspiciousLinks = false,
  }) {
    debugPrint(
      '[CommunityAnalytics] communityClaudeModeration '
      'type=$contentType suspiciousLinks=$suspiciousLinks',
    );
  }
}
