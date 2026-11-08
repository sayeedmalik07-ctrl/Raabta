/// Structured viewing request on a housing listing — scheduling only, not payment.
enum HousingViewingStatus {
  pending,
  awaitingViewer,
  confirmed,
  declined,
  expired,
}

extension HousingViewingStatusX on HousingViewingStatus {
  String get storageValue => switch (this) {
        HousingViewingStatus.pending => 'pending',
        HousingViewingStatus.awaitingViewer => 'awaiting_viewer',
        HousingViewingStatus.confirmed => 'confirmed',
        HousingViewingStatus.declined => 'declined',
        HousingViewingStatus.expired => 'expired',
      };

  static HousingViewingStatus fromStorage(String? raw) {
    return switch (raw) {
      'awaiting_viewer' => HousingViewingStatus.awaitingViewer,
      'confirmed' => HousingViewingStatus.confirmed,
      'declined' => HousingViewingStatus.declined,
      'expired' => HousingViewingStatus.expired,
      _ => HousingViewingStatus.pending,
    };
  }

  bool get isOpen =>
      this == HousingViewingStatus.pending ||
      this == HousingViewingStatus.awaitingViewer;
}

class HousingViewingRequest {
  const HousingViewingRequest({
    required this.id,
    required this.listingId,
    required this.viewerId,
    required this.ownerId,
    required this.proposedSlots,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.confirmedAt,
    this.note,
    this.hasOwnerCountered = false,
  });

  final String id;
  final String listingId;
  final String viewerId;
  final String ownerId;
  final List<DateTime> proposedSlots;
  final HousingViewingStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? confirmedAt;
  final String? note;
  final bool hasOwnerCountered;

  bool get isExpired =>
      status.isOpen && DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'listingId': listingId,
        'viewerId': viewerId,
        'ownerId': ownerId,
        'proposedSlots':
            proposedSlots.map((s) => s.toIso8601String()).toList(growable: false),
        'status': status.storageValue,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'expiresAtMs': expiresAt.millisecondsSinceEpoch,
        if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
        if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
        'hasOwnerCountered': hasOwnerCountered,
      };

  factory HousingViewingRequest.fromJson(String id, Map<String, dynamic> json) {
    final slotsRaw = json['proposedSlots'] as List<dynamic>? ?? const [];
    final slots = slotsRaw
        .map((e) => DateTime.tryParse(e.toString()))
        .whereType<DateTime>()
        .toList(growable: false);

    return HousingViewingRequest(
      id: id,
      listingId: json['listingId'] as String? ?? '',
      viewerId: json['viewerId'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      proposedSlots: slots,
      status: HousingViewingStatusX.fromStorage(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      expiresAt: json['expiresAtMs'] is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['expiresAtMs'] as num).toInt(),
            )
          : DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
              DateTime.now(),
      confirmedAt: DateTime.tryParse(json['confirmedAt'] as String? ?? ''),
      note: json['note'] as String?,
      hasOwnerCountered: json['hasOwnerCountered'] as bool? ?? false,
    );
  }

  HousingViewingRequest copyWith({
    List<DateTime>? proposedSlots,
    HousingViewingStatus? status,
    DateTime? expiresAt,
    DateTime? confirmedAt,
    bool? hasOwnerCountered,
    String? note,
  }) {
    return HousingViewingRequest(
      id: id,
      listingId: listingId,
      viewerId: viewerId,
      ownerId: ownerId,
      proposedSlots: proposedSlots ?? this.proposedSlots,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      note: note ?? this.note,
      hasOwnerCountered: hasOwnerCountered ?? this.hasOwnerCountered,
    );
  }
}
