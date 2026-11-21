enum BusinessQuoteStatus {
  pending,
  quoted,
  declined,
  cancelled,
  expired,
}

extension BusinessQuoteStatusX on BusinessQuoteStatus {
  String get storageValue => switch (this) {
        BusinessQuoteStatus.pending => 'pending',
        BusinessQuoteStatus.quoted => 'quoted',
        BusinessQuoteStatus.declined => 'declined',
        BusinessQuoteStatus.cancelled => 'cancelled',
        BusinessQuoteStatus.expired => 'expired',
      };

  static BusinessQuoteStatus fromStorage(String? raw) {
    return switch (raw) {
      'quoted' => BusinessQuoteStatus.quoted,
      'declined' => BusinessQuoteStatus.declined,
      'cancelled' => BusinessQuoteStatus.cancelled,
      'expired' => BusinessQuoteStatus.expired,
      _ => BusinessQuoteStatus.pending,
    };
  }

  bool get isOpen => this == BusinessQuoteStatus.pending;

  bool get isTerminal => !isOpen;
}

class BusinessQuoteRequest {
  const BusinessQuoteRequest({
    required this.id,
    required this.businessId,
    required this.requesterId,
    required this.ownerId,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAtMs,
    this.budgetQar,
    this.ownerQuotePrice,
    this.ownerQuoteDescription,
    this.ownerQuoteNote,
    this.quotedAt,
  });

  final String id;
  final String businessId;
  final String requesterId;
  final String ownerId;
  final String description;
  final BusinessQuoteStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int expiresAtMs;
  final double? budgetQar;
  final double? ownerQuotePrice;
  final String? ownerQuoteDescription;
  final String? ownerQuoteNote;
  final DateTime? quotedAt;

  bool get isExpired =>
      status.isOpen && DateTime.now().millisecondsSinceEpoch > expiresAtMs;

  Map<String, dynamic> toJson() => {
        'businessId': businessId,
        'requesterId': requesterId,
        'ownerId': ownerId,
        'description': description,
        'status': status.storageValue,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'expiresAtMs': expiresAtMs,
        if (budgetQar != null) 'budgetQar': budgetQar,
        if (ownerQuotePrice != null) 'ownerQuotePrice': ownerQuotePrice,
        if (ownerQuoteDescription != null)
          'ownerQuoteDescription': ownerQuoteDescription,
        if (ownerQuoteNote != null && ownerQuoteNote!.trim().isNotEmpty)
          'ownerQuoteNote': ownerQuoteNote!.trim(),
        if (quotedAt != null) 'quotedAt': quotedAt!.toIso8601String(),
      };

  factory BusinessQuoteRequest.fromJson(String id, Map<String, dynamic> json) {
    return BusinessQuoteRequest(
      id: id,
      businessId: json['businessId'] as String? ?? '',
      requesterId: json['requesterId'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: BusinessQuoteStatusX.fromStorage(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      expiresAtMs: (json['expiresAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      budgetQar: (json['budgetQar'] as num?)?.toDouble(),
      ownerQuotePrice: (json['ownerQuotePrice'] as num?)?.toDouble(),
      ownerQuoteDescription: json['ownerQuoteDescription'] as String?,
      ownerQuoteNote: json['ownerQuoteNote'] as String?,
      quotedAt: DateTime.tryParse(json['quotedAt'] as String? ?? ''),
    );
  }

  BusinessQuoteRequest copyWith({
    BusinessQuoteStatus? status,
    DateTime? updatedAt,
    int? expiresAtMs,
    double? ownerQuotePrice,
    String? ownerQuoteDescription,
    String? ownerQuoteNote,
    DateTime? quotedAt,
  }) {
    return BusinessQuoteRequest(
      id: id,
      businessId: businessId,
      requesterId: requesterId,
      ownerId: ownerId,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAtMs: expiresAtMs ?? this.expiresAtMs,
      budgetQar: budgetQar,
      ownerQuotePrice: ownerQuotePrice ?? this.ownerQuotePrice,
      ownerQuoteDescription:
          ownerQuoteDescription ?? this.ownerQuoteDescription,
      ownerQuoteNote: ownerQuoteNote ?? this.ownerQuoteNote,
      quotedAt: quotedAt ?? this.quotedAt,
    );
  }
}
