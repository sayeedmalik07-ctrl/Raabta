import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/notification_priority.dart';
import 'package:raabta/services/notifications/notification_type.dart';

/// Output of priority classification — used by delivery and platform layers.
class ResolvedNotificationPriority {
  const ResolvedNotificationPriority({
    required this.type,
    required this.priority,
    required this.meta,
    required this.urgent,
    required this.digest,
  });

  final NotificationType type;
  final NotificationPriority priority;
  final NotificationTypeMeta meta;
  final bool urgent;
  final bool digest;

  /// Derived presentation decision for Android urgent channel / iOS urgent sound.
  ///
  /// Distinct from [SmartNotificationRequest.urgent] (explicit request flag) and
  /// [NotificationPriority] (classification tier). P0/P1 tiers may select urgent
  /// presentation here without mutating the request flag or bypassing delivery gates.
  bool get useUrgentPresentation =>
      urgent ||
      meta.highPriority ||
      priority.index <= NotificationPriority.p1TimeSensitive.index;

  /// Existing digest channel semantics.
  bool get useDigestPresentation => digest;
}

/// Platform presentation derived from type + resolved priority only.
abstract final class NotificationPresentation {
  static ResolvedNotificationPriority classify({
    required NotificationType type,
    NotificationPriority? requestedPriority,
    required bool urgent,
    required Map<String, dynamic> data,
  }) {
    final meta = NotificationTypeRegistry.metaFor(type);
    final priority = NotificationPriorityResolver.resolveForType(
      type,
      requested: requestedPriority,
    );
    final digest =
        type == NotificationType.groupActivity && _isDigestData(data);
    return ResolvedNotificationPriority(
      type: type,
      priority: priority,
      meta: meta,
      urgent: urgent,
      digest: digest,
    );
  }

  static bool _isDigestData(Map<String, dynamic> data) =>
      data['digest'] == true || data['digest'] == 'true';

  /// Classifies a scheduled notification from explicit type and/or JSON [payload].
  static ResolvedNotificationPriority classifyScheduled({
    NotificationType? notificationType,
    String? payload,
    bool urgent = false,
    NotificationPriority? priority,
  }) {
    var type = notificationType ?? NotificationType.general;
    var data = <String, dynamic>{};
    if (payload != null && payload.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(
          jsonDecode(payload) as Map<dynamic, dynamic>,
        );
        if (notificationType == null && data['type'] is String) {
          type = parseNotificationType(data['type'] as String);
        }
      } catch (_) {}
    }
    return classify(
      type: type,
      requestedPriority:
          priority ?? NotificationPriority.tryParse(data['priority'] as String?),
      urgent: urgent,
      data: data,
    );
  }

  /// iOS Notification Center grouping — stable Raabta thread ids.
  static String threadIdentifierFor(NotificationType type) {
    switch (type) {
      case NotificationType.jobMatch:
        return 'raabta.jobs';
      case NotificationType.housingMatch:
        return 'raabta.housing';
      case NotificationType.goldPriceThresholdQatar:
      case NotificationType.jewelryValueGainQatar:
      case NotificationType.rateAlert:
      case NotificationType.zakatAnnualReminder:
        return 'raabta.money';
      case NotificationType.billDue:
      case NotificationType.warrantyExpiring:
      case NotificationType.documentDeadlineApproaching:
      case NotificationType.iqamaExpiry:
      case NotificationType.friendsFamilyLoanReminder:
        return 'raabta.documents';
      case NotificationType.scamShieldIncident:
      case NotificationType.scamShieldShareAlert:
      case NotificationType.scamAdvisoryAlert:
      case NotificationType.securityTip:
      case NotificationType.emergency:
        return 'security';
      case NotificationType.communityReply:
      case NotificationType.buddyRequest:
      case NotificationType.buddyRequestAccepted:
      case NotificationType.eventApproved:
      case NotificationType.eventRejected:
      case NotificationType.eventLive:
      case NotificationType.eventReminder:
      case NotificationType.lostFoundPosted:
      case NotificationType.lostFoundResolved:
      case NotificationType.breakingNews:
      case NotificationType.groupActivity:
      case NotificationType.groupNewMember:
      case NotificationType.weeklyDigest:
      case NotificationType.adminAnnouncement:
        return 'raabta.community';
      case NotificationType.eosbReengagement:
      case NotificationType.healthInsuranceReminder:
      case NotificationType.legalSourceUpdate:
      case NotificationType.lifeEventCorrelation:
      case NotificationType.lifeIntelligence:
      case NotificationType.concierge90Day:
        return 'raabta.truth';
      case NotificationType.intelligenceDailyReview:
      case NotificationType.general:
        return 'raabta.ai';
    }
  }

  /// Tier-based score for payload metadata (not inferred from copy text).
  static double relevanceScoreFor(NotificationPriority priority) {
    return switch (priority) {
      NotificationPriority.p0Critical => 1.0,
      NotificationPriority.p1TimeSensitive => 0.85,
      NotificationPriority.p2ImportantPersonal => 0.7,
      NotificationPriority.p3UsefulRecommendation => 0.55,
      NotificationPriority.p4Discovery => 0.4,
      NotificationPriority.p5PromotionalCommercial => 0.25,
    };
  }

  /// Time-sensitive interruption requires entitlement — use [active] when absent.
  static InterruptionLevel interruptionLevelFor({
    required NotificationPriority priority,
    required bool timeSensitiveEntitlementAvailable,
  }) {
    if (timeSensitiveEntitlementAvailable &&
        priority.index <= NotificationPriority.p1TimeSensitive.index) {
      return InterruptionLevel.timeSensitive;
    }
    return InterruptionLevel.active;
  }

  /// Whether the smart-engine path should use the urgent Android channel.
  static bool useUrgentAndroidChannel(ResolvedNotificationPriority resolved) {
    return resolved.useUrgentPresentation;
  }

  /// Whether the smart-engine path should use the digest Android channel.
  static bool useDigestAndroidChannel(ResolvedNotificationPriority resolved) {
    return resolved.useDigestPresentation;
  }

  /// Serializes presentation fields into notification [data] / FCM payload.
  static Map<String, String> payloadMetadata(ResolvedNotificationPriority resolved) {
    return {
      'priority': resolved.priority.apiValue,
      'threadIdentifier': threadIdentifierFor(resolved.type),
      'relevanceScore':
          relevanceScoreFor(resolved.priority).toStringAsFixed(2),
    };
  }
}

/// Whether iOS Time Sensitive notifications entitlement is configured.
///
/// [Info.plist] has no time-sensitive entitlement — default to false until added.
abstract final class NotificationPlatformConfig {
  static const bool iosTimeSensitiveEntitlementAvailable = false;
}
