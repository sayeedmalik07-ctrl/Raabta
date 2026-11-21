/// Structured price quote on a customer service request listing.
class ServiceQuote {
  const ServiceQuote({
    required this.id,
    required this.requestListingId,
    required this.providerId,
    required this.providerName,
    required this.price,
    required this.includedDescription,
    required this.createdAt,
    this.priceChangeNote,
    this.status = ServiceQuoteStatus.submitted,
  });

  final String id;
  final String requestListingId;
  final String providerId;
  final String providerName;
  final double price;
  final String includedDescription;
  final String? priceChangeNote;
  final DateTime createdAt;
  final ServiceQuoteStatus status;

  Map<String, dynamic> toJson() => {
        'requestListingId': requestListingId,
        'providerId': providerId,
        'providerName': providerName,
        'price': price,
        'includedDescription': includedDescription,
        if (priceChangeNote != null && priceChangeNote!.trim().isNotEmpty)
          'priceChangeNote': priceChangeNote!.trim(),
        'createdAt': createdAt.toIso8601String(),
        'status': status.storageValue,
      };

  factory ServiceQuote.fromJson(String id, Map<String, dynamic> json) {
    return ServiceQuote(
      id: id,
      requestListingId: json['requestListingId'] as String? ?? '',
      providerId: json['providerId'] as String? ?? id,
      providerName: json['providerName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      includedDescription: json['includedDescription'] as String? ?? '',
      priceChangeNote: json['priceChangeNote'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: ServiceQuoteStatusX.fromStorage(json['status'] as String?),
    );
  }
}

enum ServiceQuoteStatus {
  submitted,
  selected,
}

extension ServiceQuoteStatusX on ServiceQuoteStatus {
  String get storageValue => switch (this) {
        ServiceQuoteStatus.submitted => 'submitted',
        ServiceQuoteStatus.selected => 'selected',
      };

  static ServiceQuoteStatus fromStorage(String? raw) {
    return switch (raw) {
      'selected' => ServiceQuoteStatus.selected,
      _ => ServiceQuoteStatus.submitted,
    };
  }
}
