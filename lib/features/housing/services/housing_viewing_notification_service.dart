import 'package:raabta/features/housing/presentation/l10n/housing_viewing_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

enum HousingViewingNotificationKind {
  received,
  confirmed,
  declined,
  countered,
}

class HousingViewingNotificationService {
  Future<void> notifyViewingReceived({
    required String recipientUserId,
    required String listingId,
    required String listingTitle,
    required String requestId,
    required String slotsSummary,
    String locale = 'English',
  }) =>
      _send(
        recipientUserId: recipientUserId,
        listingId: listingId,
        requestId: requestId,
        title: HousingViewingStrings.t('hv_notif_received_title', locale),
        body: HousingViewingStrings.format(
          'hv_notif_received_body',
          locale,
          params: {
            'title': listingTitle,
            'slots': slotsSummary,
          },
        ),
        dedupSuffix: 'received',
      );

  Future<void> notifyViewingUpdated({
    required String recipientUserId,
    required String listingId,
    required String listingTitle,
    required String requestId,
    required HousingViewingNotificationKind kind,
    required String detail,
    String locale = 'English',
  }) {
    final (titleKey, bodyKey, suffix) = switch (kind) {
      HousingViewingNotificationKind.received => (
          'hv_notif_received_title',
          'hv_notif_received_body',
          'received',
        ),
      HousingViewingNotificationKind.confirmed => (
          'hv_notif_confirmed_title',
          'hv_notif_confirmed_body',
          'confirmed',
        ),
      HousingViewingNotificationKind.declined => (
          'hv_notif_declined_title',
          'hv_notif_declined_body',
          'declined',
        ),
      HousingViewingNotificationKind.countered => (
          'hv_notif_countered_title',
          'hv_notif_countered_body',
          'countered',
        ),
    };

    return _send(
      recipientUserId: recipientUserId,
      listingId: listingId,
      requestId: requestId,
      title: HousingViewingStrings.t(titleKey, locale),
      body: HousingViewingStrings.format(
        bodyKey,
        locale,
        params: {
          'title': listingTitle,
          'detail': detail,
        },
      ),
      dedupSuffix: suffix,
    );
  }

  Future<void> _send({
    required String recipientUserId,
    required String listingId,
    required String requestId,
    required String title,
    required String body,
    required String dedupSuffix,
  }) async {
    if (!ComplianceFlagsGate.current.viewingsEnabled) return;
    await NotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.general,
        title: title,
        body: body,
        route: '/housing/chat/$listingId',
        dedupKey: 'hv_viewing_${requestId}_$dedupSuffix',
        remoteUserIds: [recipientUserId],
        data: {
          'listingId': listingId,
          'requestId': requestId,
          'kind': 'housing_viewing',
        },
      ),
    );
  }
}
