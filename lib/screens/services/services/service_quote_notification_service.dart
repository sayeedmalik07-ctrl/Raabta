import 'package:raabta/models/notification_models.dart';
import 'package:raabta/screens/services/l10n/service_quote_strings.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

enum ServiceQuoteNotificationKind {
  received,
  selected,
}

class ServiceQuoteNotificationService {
  Future<void> notifyQuoteReceived({
    required String recipientUserId,
    required String requestListingId,
    required String requestTitle,
    required String providerId,
    required String providerName,
    required double price,
    String locale = 'English',
  }) =>
      _send(
        recipientUserId: recipientUserId,
        requestListingId: requestListingId,
        providerId: providerId,
        title: ServiceQuoteStrings.t('svc_quote_notif_received_title', locale),
        body: ServiceQuoteStrings.format(
          'svc_quote_notif_received_body',
          locale,
          params: {
            'provider': providerName,
            'title': requestTitle,
            'price': price.toStringAsFixed(0),
          },
        ),
        dedupSuffix: 'received_$providerId',
        routeProviderId: null,
      );

  Future<void> notifyQuoteSelected({
    required String recipientUserId,
    required String requestListingId,
    required String requestTitle,
    required double price,
    String locale = 'English',
  }) =>
      _send(
        recipientUserId: recipientUserId,
        requestListingId: requestListingId,
        providerId: recipientUserId,
        title: ServiceQuoteStrings.t('svc_quote_notif_selected_title', locale),
        body: ServiceQuoteStrings.format(
          'svc_quote_notif_selected_body',
          locale,
          params: {
            'title': requestTitle,
            'price': price.toStringAsFixed(0),
          },
        ),
        dedupSuffix: 'selected',
        routeProviderId: recipientUserId,
      );

  Future<void> _send({
    required String recipientUserId,
    required String requestListingId,
    required String providerId,
    required String title,
    required String body,
    required String dedupSuffix,
    required String? routeProviderId,
  }) async {
    if (!ComplianceFlagsGate.current.quotesEnabled) return;

    final route = routeProviderId == null
        ? '/services/listing/$requestListingId'
        : '/services/listing/$requestListingId/chat/$routeProviderId';

    await NotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.general,
        title: title,
        body: body,
        route: route,
        dedupKey: 'svc_quote_${requestListingId}_$dedupSuffix',
        remoteUserIds: [recipientUserId],
        data: {
          'requestListingId': requestListingId,
          if (routeProviderId != null) 'providerId': routeProviderId,
          'kind': 'service_quote',
        },
      ),
    );
  }
}
