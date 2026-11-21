import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notifications/notification_type.dart';

/// Preferences domain model — maps taxonomy types to [NotificationSettings] fields.
class NotificationPreferencesModel {
  const NotificationPreferencesModel({
    required this.settings,
    this.lastSyncedAt,
  });

  final NotificationSettings settings;
  final DateTime? lastSyncedAt;

  bool isEnabled(NotificationType type) => settings.isTypeEnabled(type);

  NotificationPreferencesModel copyWith({
    NotificationSettings? settings,
    DateTime? lastSyncedAt,
  }) {
    return NotificationPreferencesModel(
      settings: settings ?? this.settings,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  NotificationPreferencesModel toggleType(NotificationType type, bool enabled) {
    switch (type) {
      case NotificationType.billDue:
        return copyWith(settings: settings.copyWith(billDue: enabled));
      case NotificationType.friendsFamilyLoanReminder:
        return copyWith(
          settings: settings.copyWith(friendsFamilyLoanReminder: enabled),
        );
      case NotificationType.warrantyExpiring:
        return copyWith(settings: settings.copyWith(warrantyExpiring: enabled));
      case NotificationType.documentDeadlineApproaching:
        return copyWith(
          settings: settings.copyWith(documentDeadlineApproaching: enabled),
        );
      case NotificationType.communityReply:
      case NotificationType.buddyRequest:
      case NotificationType.buddyRequestAccepted:
        return copyWith(settings: settings.copyWith(communityReply: enabled));
      case NotificationType.eventApproved:
      case NotificationType.eventRejected:
      case NotificationType.eventLive:
      case NotificationType.eventReminder:
        return copyWith(settings: settings.copyWith(communityEvents: enabled));
      case NotificationType.lostFoundPosted:
      case NotificationType.lostFoundResolved:
        return copyWith(
          settings: settings.copyWith(communityLostFound: enabled),
        );
      case NotificationType.groupActivity:
      case NotificationType.groupNewMember:
        return copyWith(settings: settings.copyWith(groupActivity: enabled));
      case NotificationType.jobMatch:
        return copyWith(settings: settings.copyWith(jobMatch: enabled));
      case NotificationType.housingMatch:
        return copyWith(settings: settings.copyWith(housingMatch: enabled));
      case NotificationType.eosbReengagement:
        return copyWith(settings: settings.copyWith(eosbReengagement: enabled));
      case NotificationType.intelligenceDailyReview:
        return copyWith(
          settings: settings.copyWith(intelligenceDailyReview: enabled),
        );
      case NotificationType.healthInsuranceReminder:
      case NotificationType.lifeEventCorrelation:
        return copyWith(
          settings: settings.copyWith(healthInsuranceReminder: enabled),
        );
      case NotificationType.lifeIntelligence:
        return copyWith(settings: settings.copyWith(lifeIntelligence: enabled));
      case NotificationType.concierge90Day:
        return copyWith(settings: settings.copyWith(concierge90Day: enabled));
      case NotificationType.zakatAnnualReminder:
        return copyWith(settings: settings.copyWith(zakatAnnualReminder: enabled));
      case NotificationType.adminAnnouncement:
        return copyWith(settings: settings.copyWith(adminAnnouncement: enabled));
      case NotificationType.scamShieldIncident:
        return copyWith(settings: settings.copyWith(scamShieldIncident: enabled));
      case NotificationType.scamShieldShareAlert:
        return copyWith(
          settings: settings.copyWith(scamShieldShareAlert: enabled),
        );
      case NotificationType.scamAdvisoryAlert:
        return copyWith(settings: settings.copyWith(scamAdvisoryAlert: enabled));
      case NotificationType.securityTip:
        return copyWith(settings: settings.copyWith(securityTip: enabled));
      case NotificationType.legalSourceUpdate:
        return copyWith(settings: settings.copyWith(legalSourceUpdate: enabled));
      default:
        return this;
    }
  }

  static List<NotificationTypeMeta> preferenceTypes() =>
      NotificationTypeRegistry.all;
}
