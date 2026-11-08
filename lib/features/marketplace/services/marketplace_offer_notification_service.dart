import 'package:raabta/features/marketplace/presentation/l10n/marketplace_offer_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

enum MarketplaceOfferNotificationKind {
  received,
  accepted,
  declined,
  countered,
}

/// In-app + push offer alerts via existing NotificationEngine (general type).
class MarketplaceOfferNotificationService {
  Future<void> notifyOfferReceived({
    required String recipientUserId,
    required String listingId,
    required String listingTitle,
    required String offerId,
    required double amount,
    String locale = 'English',
  }) =>
      _send(
        recipientUserId: recipientUserId,
        listingId: listingId,
        offerId: offerId,
        title: MarketplaceOfferStrings.t('mp_offer_notif_received_title', locale),
        body: MarketplaceOfferStrings.format(
          'mp_offer_notif_received_body',
          locale,
          params: {
            'title': listingTitle,
            'amount': amount.toStringAsFixed(0),
          },
        ),
        dedupSuffix: 'received',
      );

  Future<void> notifyOfferUpdated({
    required String recipientUserId,
    required String listingId,
    required String listingTitle,
    required String offerId,
    required double amount,
    required MarketplaceOfferNotificationKind kind,
    String locale = 'English',
  }) {
    final (titleKey, bodyKey, suffix) = switch (kind) {
      MarketplaceOfferNotificationKind.received => (
          'mp_offer_notif_received_title',
          'mp_offer_notif_received_body',
          'received',
        ),
      MarketplaceOfferNotificationKind.accepted => (
          'mp_offer_notif_accepted_title',
          'mp_offer_notif_accepted_body',
          'accepted',
        ),
      MarketplaceOfferNotificationKind.declined => (
          'mp_offer_notif_declined_title',
          'mp_offer_notif_declined_body',
          'declined',
        ),
      MarketplaceOfferNotificationKind.countered => (
          'mp_offer_notif_countered_title',
          'mp_offer_notif_countered_body',
          'countered',
        ),
    };

    return _send(
      recipientUserId: recipientUserId,
      listingId: listingId,
      offerId: offerId,
      title: MarketplaceOfferStrings.t(titleKey, locale),
      body: MarketplaceOfferStrings.format(
        bodyKey,
        locale,
        params: {
          'title': listingTitle,
          'amount': amount.toStringAsFixed(0),
        },
      ),
      dedupSuffix: suffix,
    );
  }

  Future<void> _send({
    required String recipientUserId,
    required String listingId,
    required String offerId,
    required String title,
    required String body,
    required String dedupSuffix,
  }) async {
    if (!ComplianceFlagsGate.current.offersEnabled) return;
    await NotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.general,
        title: title,
        body: body,
        route: '/marketplace/chat/$listingId',
        dedupKey: 'mp_offer_${offerId}_$dedupSuffix',
        remoteUserIds: [recipientUserId],
        data: {
          'listingId': listingId,
          'offerId': offerId,
          'kind': 'marketplace_offer',
        },
      ),
    );
  }
}
