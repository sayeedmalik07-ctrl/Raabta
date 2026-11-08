/// Structured price offer on a marketplace listing — agreement only, not payment.
enum MarketplaceOfferStatus {
  pending,
  awaitingBuyer,
  accepted,
  declined,
  expired,
}

extension MarketplaceOfferStatusX on MarketplaceOfferStatus {
  String get storageValue => switch (this) {
        MarketplaceOfferStatus.pending => 'pending',
        MarketplaceOfferStatus.awaitingBuyer => 'awaiting_buyer',
        MarketplaceOfferStatus.accepted => 'accepted',
        MarketplaceOfferStatus.declined => 'declined',
        MarketplaceOfferStatus.expired => 'expired',
      };

  static MarketplaceOfferStatus fromStorage(String? raw) {
    return switch (raw) {
      'awaiting_buyer' => MarketplaceOfferStatus.awaitingBuyer,
      'accepted' => MarketplaceOfferStatus.accepted,
      'declined' => MarketplaceOfferStatus.declined,
      'expired' => MarketplaceOfferStatus.expired,
      _ => MarketplaceOfferStatus.pending,
    };
  }

  bool get isOpen =>
      this == MarketplaceOfferStatus.pending ||
      this == MarketplaceOfferStatus.awaitingBuyer;
}

class MarketplaceOffer {
  const MarketplaceOffer({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.offeredPrice,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.hasSellerCountered = false,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final double offeredPrice;
  final MarketplaceOfferStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool hasSellerCountered;

  bool get isExpired =>
      status.isOpen && DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'listingId': listingId,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'offeredPrice': offeredPrice,
        'status': status.storageValue,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'hasSellerCountered': hasSellerCountered,
      };

  factory MarketplaceOffer.fromJson(String id, Map<String, dynamic> json) {
    return MarketplaceOffer(
      id: id,
      listingId: json['listingId'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      offeredPrice: (json['offeredPrice'] as num?)?.toDouble() ?? 0,
      status: MarketplaceOfferStatusX.fromStorage(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
      hasSellerCountered: json['hasSellerCountered'] as bool? ?? false,
    );
  }

  MarketplaceOffer copyWith({
    double? offeredPrice,
    MarketplaceOfferStatus? status,
    DateTime? expiresAt,
    bool? hasSellerCountered,
  }) {
    return MarketplaceOffer(
      id: id,
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      hasSellerCountered: hasSellerCountered ?? this.hasSellerCountered,
    );
  }
}
