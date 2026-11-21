import 'package:raabta/features/business/presentation/l10n/business_quote_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

enum BusinessQuoteNotificationKind {
  received,
  quoted,
  declined,
  cancelled,
}

class BusinessQuoteNotificationService {
  Future<void> notifyReceived({
    required String recipientUserId,
    required String businessId,
    required String businessName,
    required String requestId,
    String locale = 'English',
  }) =>
      _send(
        recipientUserId: recipientUserId,
        businessId: businessId,
        requestId: requestId,
        title: BusinessQuoteStrings.t('biz_quote_notif_received_title', locale),
        body: BusinessQuoteStrings.format(
          'biz_quote_notif_received_body',
          locale,
          params: {'name': businessName},
        ),
        dedupSuffix: 'received',
      );

  Future<void> notifyUpdated({
    required String recipientUserId,
    required String businessId,
    required String businessName,
    required String requestId,
    required BusinessQuoteNotificationKind kind,
    String detail = '',
    String locale = 'English',
  }) {
    final (titleKey, bodyKey, suffix) = switch (kind) {
      BusinessQuoteNotificationKind.received => (
          'biz_quote_notif_received_title',
          'biz_quote_notif_received_body',
          'received',
        ),
      BusinessQuoteNotificationKind.quoted => (
          'biz_quote_notif_quoted_title',
          'biz_quote_notif_quoted_body',
          'quoted',
        ),
      BusinessQuoteNotificationKind.declined => (
          'biz_quote_notif_declined_title',
          'biz_quote_notif_declined_body',
          'declined',
        ),
      BusinessQuoteNotificationKind.cancelled => (
          'biz_quote_notif_cancelled_title',
          'biz_quote_notif_cancelled_body',
          'cancelled',
        ),
    };

    return _send(
      recipientUserId: recipientUserId,
      businessId: businessId,
      requestId: requestId,
      title: BusinessQuoteStrings.t(titleKey, locale),
      body: BusinessQuoteStrings.format(
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
    if (!ComplianceFlagsGate.current.businessQuotesEnabled) return;
    await NotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.general,
        title: title,
        body: body,
        route: '/businesses?listingId=$businessId',
        dedupKey: 'biz_quote_${requestId}_$dedupSuffix',
        remoteUserIds: [recipientUserId],
        data: {
          'businessId': businessId,
          'requestId': requestId,
          'kind': 'business_quote',
        },
      ),
    );
  }
}
