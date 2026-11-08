/// Per-trip manual readiness toggles — only categories without auto data sources.
class TripReadinessManualChecks {
  const TripReadinessManualChecks({
    this.passportConfirmed = false,
    this.visaConfirmed = false,
    this.travelInsurance = false,
    this.insuranceCancellationCoverage = false,
    this.connectivity = false,
    this.currencyReady = false,
    this.emergencyContacts = false,
  });

  final bool passportConfirmed;
  final bool visaConfirmed;
  final bool travelInsurance;
  final bool insuranceCancellationCoverage;
  final bool connectivity;
  final bool currencyReady;
  final bool emergencyContacts;

  TripReadinessManualChecks copyWith({
    bool? passportConfirmed,
    bool? visaConfirmed,
    bool? travelInsurance,
    bool? insuranceCancellationCoverage,
    bool? connectivity,
    bool? currencyReady,
    bool? emergencyContacts,
  }) {
    return TripReadinessManualChecks(
      passportConfirmed: passportConfirmed ?? this.passportConfirmed,
      visaConfirmed: visaConfirmed ?? this.visaConfirmed,
      travelInsurance: travelInsurance ?? this.travelInsurance,
      insuranceCancellationCoverage:
          insuranceCancellationCoverage ?? this.insuranceCancellationCoverage,
      connectivity: connectivity ?? this.connectivity,
      currencyReady: currencyReady ?? this.currencyReady,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  Map<String, dynamic> toJson() => {
        'passportConfirmed': passportConfirmed,
        'visaConfirmed': visaConfirmed,
        'travelInsurance': travelInsurance,
        'insuranceCancellationCoverage': insuranceCancellationCoverage,
        'connectivity': connectivity,
        'currencyReady': currencyReady,
        'emergencyContacts': emergencyContacts,
      };

  factory TripReadinessManualChecks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TripReadinessManualChecks();
    return TripReadinessManualChecks(
      passportConfirmed: json['passportConfirmed'] as bool? ?? false,
      visaConfirmed: json['visaConfirmed'] as bool? ?? false,
      travelInsurance: json['travelInsurance'] as bool? ?? false,
      insuranceCancellationCoverage:
          json['insuranceCancellationCoverage'] as bool? ?? false,
      connectivity: json['connectivity'] as bool? ?? false,
      currencyReady: json['currencyReady'] as bool? ?? false,
      emergencyContacts: json['emergencyContacts'] as bool? ?? false,
    );
  }
}
