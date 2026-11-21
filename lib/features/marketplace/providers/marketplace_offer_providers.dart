import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/marketplace/data/marketplace_offer_repository.dart';
import 'package:raabta/features/marketplace/domain/marketplace_offer.dart';

final marketplaceOfferRepositoryProvider =
    Provider<MarketplaceOfferRepository>((ref) {
  return MarketplaceOfferRepository();
});

final marketplaceListingOffersProvider =
    StreamProvider.autoDispose.family<List<MarketplaceOffer>, String>(
  (ref, listingId) {
    return ref.watch(marketplaceOfferRepositoryProvider).watchListingOffers(
          listingId,
        );
  },
);
