import 'package:raabta/features/marketplace/domain/marketplace_offer.dart';

/// Deterministic offer state machine — no AI.
abstract final class MarketplaceOfferLifecycle {
  MarketplaceOfferLifecycle._();

  static const offerValidity = Duration(hours: 24);

  static DateTime expiryFromNow([DateTime? from]) =>
      (from ?? DateTime.now()).add(offerValidity);

  static MarketplaceOffer expireIfNeeded(MarketplaceOffer offer) {
    if (!offer.isExpired) return offer;
    return offer.copyWith(status: MarketplaceOfferStatus.expired);
  }

  static MarketplaceOffer? sellerAccept(MarketplaceOffer offer) {
    if (offer.status != MarketplaceOfferStatus.pending) return null;
    if (offer.isExpired) return offer.copyWith(status: MarketplaceOfferStatus.expired);
    return offer.copyWith(status: MarketplaceOfferStatus.accepted);
  }

  static MarketplaceOffer? sellerDecline(MarketplaceOffer offer) {
    if (offer.status != MarketplaceOfferStatus.pending &&
        offer.status != MarketplaceOfferStatus.awaitingBuyer) {
      return null;
    }
    if (offer.isExpired) return offer.copyWith(status: MarketplaceOfferStatus.expired);
    return offer.copyWith(status: MarketplaceOfferStatus.declined);
  }

  static MarketplaceOffer? sellerCounter(
    MarketplaceOffer offer,
    double counterPrice,
  ) {
    if (offer.status != MarketplaceOfferStatus.pending) return null;
    if (offer.hasSellerCountered) return null;
    if (counterPrice <= 0) return null;
    if (offer.isExpired) return offer.copyWith(status: MarketplaceOfferStatus.expired);
    return offer.copyWith(
      offeredPrice: counterPrice,
      status: MarketplaceOfferStatus.awaitingBuyer,
      expiresAt: expiryFromNow(),
      hasSellerCountered: true,
    );
  }

  static MarketplaceOffer? buyerAcceptCounter(MarketplaceOffer offer) {
    if (offer.status != MarketplaceOfferStatus.awaitingBuyer) return null;
    if (offer.isExpired) return offer.copyWith(status: MarketplaceOfferStatus.expired);
    return offer.copyWith(status: MarketplaceOfferStatus.accepted);
  }

  static MarketplaceOffer? buyerDeclineCounter(MarketplaceOffer offer) {
    if (offer.status != MarketplaceOfferStatus.awaitingBuyer) return null;
    if (offer.isExpired) return offer.copyWith(status: MarketplaceOfferStatus.expired);
    return offer.copyWith(status: MarketplaceOfferStatus.declined);
  }
}
