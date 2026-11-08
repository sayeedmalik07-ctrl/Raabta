import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale_storage.dart';
import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_delivery.dart';

/// Raised when an elevated advisory is published — Phase 30 wires
/// `scamAdvisoryAlert` here via [RaabtaNotificationService].
class ScamAdvisoryPublishedEvent {
  const ScamAdvisoryPublishedEvent({required this.advisory});

  final ScamAdvisory advisory;
}

abstract final class ScamAdvisoryPushHook {
  static final List<ScamAdvisoryPublishedEvent Function()> _pending = [];

  /// Call after Firestore confirms a new/updated published elevated advisory.
  static void onElevatedAdvisoryPublished(ScamAdvisory advisory) {
    if (advisory.severity != ScamAdvisorySeverity.elevated) return;
    if (advisory.status != ScamAdvisoryStatus.published) return;
    if (!advisory.isActive) return;
    final event = ScamAdvisoryPublishedEvent(advisory: advisory);
    _pending.add(() => event);
    AppLocaleStorage.readNormalized().then((locale) {
      SecurityAlertDelivery.notifyElevatedAdvisory(
        advisory: advisory,
        locale: locale,
      );
    });
  }

  @visibleForTesting
  static List<ScamAdvisoryPublishedEvent> drainPendingForTests() {
    final events = _pending.map((f) => f()).toList();
    _pending.clear();
    return events;
  }
}
