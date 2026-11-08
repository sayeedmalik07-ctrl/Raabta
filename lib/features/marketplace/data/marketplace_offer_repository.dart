import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/marketplace/data/marketplace_chat_repository.dart';
import 'package:raabta/features/marketplace/domain/marketplace_offer.dart';
import 'package:raabta/features/marketplace/domain/marketplace_offer_lifecycle.dart';
import 'package:raabta/features/marketplace/services/marketplace_offer_notification_service.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/services/firebase_service.dart';

class MarketplaceOfferRepository {
  MarketplaceOfferRepository({
    FirebaseFirestore? firestore,
    MarketplaceChatRepository? chatRepository,
    MarketplaceOfferNotificationService? notifications,
  })  : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _chat = chatRepository ?? MarketplaceChatRepository(),
        _notifications =
            notifications ?? MarketplaceOfferNotificationService();

  final FirebaseFirestore? _firestore;
  final MarketplaceChatRepository _chat;
  final MarketplaceOfferNotificationService _notifications;

  CollectionReference<Map<String, dynamic>>? _offersRef(String listingId) {
    if (_firestore == null) return null;
    return _firestore
        .collection('marketplace_listings')
        .doc(listingId)
        .collection('offers');
  }

  Stream<List<MarketplaceOffer>> watchListingOffers(String listingId) {
    final ref = _offersRef(listingId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: true).snapshots().asyncMap(
      (snap) async {
        final offers = <MarketplaceOffer>[];
        for (final doc in snap.docs) {
          var offer = MarketplaceOffer.fromJson(doc.id, doc.data());
          final expired = MarketplaceOfferLifecycle.expireIfNeeded(offer);
          if (expired.status == MarketplaceOfferStatus.expired &&
              offer.status.isOpen) {
            await doc.reference.update(expired.toJson());
            offer = expired;
          }
          offers.add(offer);
        }
        return offers;
      },
    );
  }

  Future<MarketplaceOffer?> createOffer({
    required String listingId,
    required String sellerId,
    required double offeredPrice,
    required String listingTitle,
  }) async {
    ComplianceFlagsGate.requireOffers();
    final ref = _offersRef(listingId);
    final buyerId = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || buyerId == null || buyerId == sellerId) return null;
    if (offeredPrice <= 0) return null;

    final now = DateTime.now();
    final doc = ref.doc();
    final offer = MarketplaceOffer(
      id: doc.id,
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
      offeredPrice: offeredPrice,
      status: MarketplaceOfferStatus.pending,
      createdAt: now,
      expiresAt: MarketplaceOfferLifecycle.expiryFromNow(now),
    );

    await doc.set(offer.toJson());
    await _notifications.notifyOfferReceived(
      recipientUserId: sellerId,
      listingId: listingId,
      listingTitle: listingTitle,
      offerId: offer.id,
      amount: offeredPrice,
    );
    return offer;
  }

  Future<MarketplaceOffer?> sellerAccept({
    required MarketplaceOffer offer,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        offer: offer,
        next: MarketplaceOfferLifecycle.sellerAccept(offer),
        systemMessageKey: 'mp_offer_chat_accepted',
        locale: locale,
        listingTitle: listingTitle,
        notifyBuyer: true,
        notifyKind: MarketplaceOfferNotificationKind.accepted,
      );

  Future<MarketplaceOffer?> sellerDecline({
    required MarketplaceOffer offer,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        offer: offer,
        next: MarketplaceOfferLifecycle.sellerDecline(offer),
        systemMessageKey: 'mp_offer_chat_declined',
        locale: locale,
        listingTitle: listingTitle,
        notifyBuyer: true,
        notifyKind: MarketplaceOfferNotificationKind.declined,
      );

  Future<MarketplaceOffer?> sellerCounter({
    required MarketplaceOffer offer,
    required double counterPrice,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        offer: offer,
        next: MarketplaceOfferLifecycle.sellerCounter(offer, counterPrice),
        systemMessageKey: 'mp_offer_chat_countered',
        locale: locale,
        listingTitle: listingTitle,
        notifyBuyer: true,
        notifyKind: MarketplaceOfferNotificationKind.countered,
        messagePrice: counterPrice,
      );

  Future<MarketplaceOffer?> buyerAcceptCounter({
    required MarketplaceOffer offer,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        offer: offer,
        next: MarketplaceOfferLifecycle.buyerAcceptCounter(offer),
        systemMessageKey: 'mp_offer_chat_accepted',
        locale: locale,
        listingTitle: listingTitle,
        notifyBuyer: false,
        notifyKind: MarketplaceOfferNotificationKind.accepted,
      );

  Future<MarketplaceOffer?> buyerDeclineCounter({
    required MarketplaceOffer offer,
    required String listingTitle,
    required String locale,
  }) =>
      _applyTransition(
        offer: offer,
        next: MarketplaceOfferLifecycle.buyerDeclineCounter(offer),
        systemMessageKey: 'mp_offer_chat_declined',
        locale: locale,
        listingTitle: listingTitle,
        notifyBuyer: false,
        notifyKind: MarketplaceOfferNotificationKind.declined,
      );

  Future<MarketplaceOffer?> _applyTransition({
    required MarketplaceOffer offer,
    required MarketplaceOffer? next,
    required String systemMessageKey,
    required String locale,
    required String listingTitle,
    required bool notifyBuyer,
    required MarketplaceOfferNotificationKind notifyKind,
    double? messagePrice,
  }) async {
    ComplianceFlagsGate.requireOffers();
    if (next == null) return null;
    final ref = _offersRef(offer.listingId)?.doc(offer.id);
    if (ref == null) return null;

    await ref.update(next.toJson());

    final price = messagePrice ?? next.offeredPrice;
    await _chat.sendOfferSystemMessage(
      listingId: offer.listingId,
      messageKey: systemMessageKey,
      locale: locale,
      params: {
        'amount': price.toStringAsFixed(0),
      },
    );

    final recipient = notifyBuyer ? offer.buyerId : offer.sellerId;
    await _notifications.notifyOfferUpdated(
      recipientUserId: recipient,
      listingId: offer.listingId,
      listingTitle: listingTitle,
      offerId: offer.id,
      amount: next.offeredPrice,
      kind: notifyKind,
    );

    return next;
  }
}
