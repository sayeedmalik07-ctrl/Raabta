enum TripBookingType {
  flight,
  hotel,
  carRental,
}

extension TripBookingTypeExt on TripBookingType {
  String get storageKey => name;

  static TripBookingType? fromKey(String? raw) {
    if (raw == null) return null;
    for (final t in TripBookingType.values) {
      if (t.name == raw) return t;
    }
    return null;
  }
}

/// Imported booking metadata stored on a saved trip (not a parallel trip type).
class TripBookingSegment {
  const TripBookingSegment({
    required this.id,
    required this.type,
    this.destinationCity,
    this.destinationCountry,
    this.startDateTime,
    this.endDateTime,
    this.confirmationNumber,
    this.providerName,
    this.guestName,
    this.vaultDocumentId,
    this.fieldConfidence = const {},
    this.importedAt,
  });

  final String id;
  final TripBookingType type;
  final String? destinationCity;
  final String? destinationCountry;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String? confirmationNumber;
  final String? providerName;
  final String? guestName;
  final String? vaultDocumentId;
  final Map<String, double> fieldConfidence;
  final DateTime? importedAt;

  TripBookingSegment copyWith({
    String? id,
    TripBookingType? type,
    String? destinationCity,
    String? destinationCountry,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? confirmationNumber,
    String? providerName,
    String? guestName,
    String? vaultDocumentId,
    Map<String, double>? fieldConfidence,
    DateTime? importedAt,
  }) {
    return TripBookingSegment(
      id: id ?? this.id,
      type: type ?? this.type,
      destinationCity: destinationCity ?? this.destinationCity,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      confirmationNumber: confirmationNumber ?? this.confirmationNumber,
      providerName: providerName ?? this.providerName,
      guestName: guestName ?? this.guestName,
      vaultDocumentId: vaultDocumentId ?? this.vaultDocumentId,
      fieldConfidence: fieldConfidence ?? this.fieldConfidence,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'destinationCity': destinationCity,
        'destinationCountry': destinationCountry,
        'startDateTime': startDateTime?.toIso8601String(),
        'endDateTime': endDateTime?.toIso8601String(),
        'confirmationNumber': confirmationNumber,
        'providerName': providerName,
        'guestName': guestName,
        'vaultDocumentId': vaultDocumentId,
        'fieldConfidence': fieldConfidence,
        'importedAt': importedAt?.toIso8601String(),
      };

  factory TripBookingSegment.fromJson(Map<String, dynamic> json) {
    return TripBookingSegment(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: TripBookingType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TripBookingType.hotel,
      ),
      destinationCity: json['destinationCity'] as String?,
      destinationCountry: json['destinationCountry'] as String?,
      startDateTime: DateTime.tryParse(json['startDateTime'] as String? ?? ''),
      endDateTime: DateTime.tryParse(json['endDateTime'] as String? ?? ''),
      confirmationNumber: json['confirmationNumber'] as String?,
      providerName: json['providerName'] as String?,
      guestName: json['guestName'] as String?,
      vaultDocumentId: json['vaultDocumentId'] as String?,
      fieldConfidence: (json['fieldConfidence'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ) ??
          const {},
      importedAt: DateTime.tryParse(json['importedAt'] as String? ?? ''),
    );
  }
}
