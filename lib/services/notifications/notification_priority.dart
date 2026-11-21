import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/notification_type.dart';

/// Delivery urgency tier — lower [Enum.index] means higher urgency (P0 highest).
enum NotificationPriority {
  p0Critical,
  p1TimeSensitive,
  p2ImportantPersonal,
  p3UsefulRecommendation,
  p4Discovery,
  p5PromotionalCommercial;

  /// Stable API / FCM data value.
  String get apiValue => name;

  static NotificationPriority? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final value in NotificationPriority.values) {
      if (value.name == raw || value.apiValue == raw) return value;
    }
    return null;
  }
}

/// Resolves and clamps [NotificationPriority] per [NotificationType] registry rules.
abstract final class NotificationPriorityResolver {
  /// Structural minimum urgency allowed for promotional/commercial paths.
  /// P0 and P1 are always rejected for [NotificationTypeMeta.promotionalCommercial].
  static const promotionalMinAllowed = NotificationPriority.p2ImportantPersonal;

  /// Clamps [priority] to registry max and enforces promotional P0/P1 rejection.
  static NotificationPriority clamp(
    NotificationType type,
    NotificationPriority priority,
  ) {
    final meta = NotificationTypeRegistry.metaFor(type);

    var resolved = priority;

    // [maxPriority] = most urgent tier allowed (lowest index permitted).
    if (resolved.index < meta.maxPriority.index) {
      resolved = meta.maxPriority;
    }

    // Structural promotional guard — documentation alone is insufficient.
    if (meta.promotionalCommercial &&
        resolved.index <= NotificationPriority.p1TimeSensitive.index) {
      resolved = meta.maxPriority.index > promotionalMinAllowed.index
          ? meta.maxPriority
          : promotionalMinAllowed;
    }

    return resolved;
  }

  static NotificationPriority resolveForType(
    NotificationType type, {
    NotificationPriority? requested,
  }) {
    final meta = NotificationTypeRegistry.metaFor(type);
    return clamp(type, requested ?? meta.defaultPriority);
  }
}
