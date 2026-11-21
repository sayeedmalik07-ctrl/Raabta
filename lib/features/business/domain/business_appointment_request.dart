enum BusinessAppointmentStatus {
  pending,
  awaitingRequester,
  confirmed,
  declined,
  cancelled,
  expired,
}

extension BusinessAppointmentStatusX on BusinessAppointmentStatus {
  String get storageValue => switch (this) {
        BusinessAppointmentStatus.pending => 'pending',
        BusinessAppointmentStatus.awaitingRequester => 'awaiting_requester',
        BusinessAppointmentStatus.confirmed => 'confirmed',
        BusinessAppointmentStatus.declined => 'declined',
        BusinessAppointmentStatus.cancelled => 'cancelled',
        BusinessAppointmentStatus.expired => 'expired',
      };

  static BusinessAppointmentStatus fromStorage(String? raw) {
    return switch (raw) {
      'awaiting_requester' => BusinessAppointmentStatus.awaitingRequester,
      'confirmed' => BusinessAppointmentStatus.confirmed,
      'declined' => BusinessAppointmentStatus.declined,
      'cancelled' => BusinessAppointmentStatus.cancelled,
      'expired' => BusinessAppointmentStatus.expired,
      _ => BusinessAppointmentStatus.pending,
    };
  }

  bool get isOpen =>
      this == BusinessAppointmentStatus.pending ||
      this == BusinessAppointmentStatus.awaitingRequester;

  bool get isTerminal => !isOpen;
}

class BusinessAppointmentRequest {
  const BusinessAppointmentRequest({
    required this.id,
    required this.businessId,
    required this.requesterId,
    required this.ownerId,
    required this.proposedSlots,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAtMs,
    this.selectedSlot,
    this.confirmedAt,
    this.note,
    this.hasOwnerCountered = false,
  });

  final String id;
  final String businessId;
  final String requesterId;
  final String ownerId;
  final List<DateTime> proposedSlots;
  final BusinessAppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int expiresAtMs;
  final DateTime? selectedSlot;
  final DateTime? confirmedAt;
  final String? note;
  final bool hasOwnerCountered;

  bool get isExpired =>
      status.isOpen && DateTime.now().millisecondsSinceEpoch > expiresAtMs;

  Map<String, dynamic> toJson() => {
        'businessId': businessId,
        'requesterId': requesterId,
        'ownerId': ownerId,
        'proposedSlots':
            proposedSlots.map((s) => s.toIso8601String()).toList(growable: false),
        'status': status.storageValue,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'expiresAtMs': expiresAtMs,
        if (selectedSlot != null)
          'selectedSlot': selectedSlot!.toIso8601String(),
        if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
        if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
        'hasOwnerCountered': hasOwnerCountered,
      };

  factory BusinessAppointmentRequest.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    final slotsRaw = json['proposedSlots'] as List<dynamic>? ?? const [];
    final slots = slotsRaw
        .map((e) => DateTime.tryParse(e.toString()))
        .whereType<DateTime>()
        .toList(growable: false);

    return BusinessAppointmentRequest(
      id: id,
      businessId: json['businessId'] as String? ?? '',
      requesterId: json['requesterId'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      proposedSlots: slots,
      status: BusinessAppointmentStatusX.fromStorage(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      expiresAtMs: (json['expiresAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      selectedSlot: DateTime.tryParse(json['selectedSlot'] as String? ?? ''),
      confirmedAt: DateTime.tryParse(json['confirmedAt'] as String? ?? ''),
      note: json['note'] as String?,
      hasOwnerCountered: json['hasOwnerCountered'] as bool? ?? false,
    );
  }

  BusinessAppointmentRequest copyWith({
    List<DateTime>? proposedSlots,
    BusinessAppointmentStatus? status,
    DateTime? updatedAt,
    int? expiresAtMs,
    DateTime? selectedSlot,
    DateTime? confirmedAt,
    bool? hasOwnerCountered,
    String? note,
  }) {
    return BusinessAppointmentRequest(
      id: id,
      businessId: businessId,
      requesterId: requesterId,
      ownerId: ownerId,
      proposedSlots: proposedSlots ?? this.proposedSlots,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAtMs: expiresAtMs ?? this.expiresAtMs,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      note: note ?? this.note,
      hasOwnerCountered: hasOwnerCountered ?? this.hasOwnerCountered,
    );
  }
}
