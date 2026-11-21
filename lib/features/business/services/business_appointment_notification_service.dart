import 'package:raabta/features/business/presentation/l10n/business_appointment_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

enum BusinessAppointmentNotificationKind {
  received,
  confirmed,
  declined,
  countered,
  cancelled,
}

class BusinessAppointmentNotificationService {
  Future<void> notifyReceived({
    required String recipientUserId,
    required String businessId,
    required String businessName,
    required String requestId,
    required String slotsSummary,
    String locale = 'English',
  }) =>
      _send(
        recipientUserId: recipientUserId,
        businessId: businessId,
        requestId: requestId,
        title: BusinessAppointmentStrings.t('biz_appt_notif_received_title', locale),
        body: BusinessAppointmentStrings.format(
          'biz_appt_notif_received_body',
          locale,
          params: {'name': businessName, 'slots': slotsSummary},
        ),
        dedupSuffix: 'received',
      );

  Future<void> notifyUpdated({
    required String recipientUserId,
    required String businessId,
    required String businessName,
    required String requestId,
    required BusinessAppointmentNotificationKind kind,
    required String detail,
    String locale = 'English',
  }) {
    final (titleKey, bodyKey, suffix) = switch (kind) {
      BusinessAppointmentNotificationKind.received => (
          'biz_appt_notif_received_title',
          'biz_appt_notif_received_body',
          'received',
        ),
      BusinessAppointmentNotificationKind.confirmed => (
          'biz_appt_notif_confirmed_title',
          'biz_appt_notif_confirmed_body',
          'confirmed',
        ),
      BusinessAppointmentNotificationKind.declined => (
          'biz_appt_notif_declined_title',
          'biz_appt_notif_declined_body',
          'declined',
        ),
      BusinessAppointmentNotificationKind.countered => (
          'biz_appt_notif_countered_title',
          'biz_appt_notif_countered_body',
          'countered',
        ),
      BusinessAppointmentNotificationKind.cancelled => (
          'biz_appt_notif_cancelled_title',
          'biz_appt_notif_cancelled_body',
          'cancelled',
        ),
    };

    return _send(
      recipientUserId: recipientUserId,
      businessId: businessId,
      requestId: requestId,
      title: BusinessAppointmentStrings.t(titleKey, locale),
      body: BusinessAppointmentStrings.format(
        bodyKey,
        locale,
        params: {'name': businessName, 'detail': detail},
      ),
      dedupSuffix: suffix,
    );
  }

  Future<void> _send({
    required String recipientUserId,
    required String businessId,
    required String requestId,
    required String title,
    required String body,
    required String dedupSuffix,
  }) async {
    if (!ComplianceFlagsGate.current.businessAppointmentsEnabled) return;
    await NotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.general,
        title: title,
        body: body,
        route: '/businesses?listingId=$businessId',
        dedupKey: 'biz_appt_${requestId}_$dedupSuffix',
        remoteUserIds: [recipientUserId],
        data: {
          'businessId': businessId,
          'requestId': requestId,
          'kind': 'business_appointment',
        },
      ),
    );
  }
}
