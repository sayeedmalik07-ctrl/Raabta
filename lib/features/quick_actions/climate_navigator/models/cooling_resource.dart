/// A nearby place where someone can cool down (AC, shade, or both).
class CoolingResource {
  const CoolingResource({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.is24Hour = false,
    this.isVerified = true,
    this.distanceMeters,
    this.acRest = false,
    this.respite = false,
    this.classificationProvenanceKey,
    this.publicAccessEvidence,
  });

  final String id;
  final String name;

  /// `mall` | `metro` | `mosque` | `hospital` | `library` | `shaded_area`
  final String type;
  final double latitude;
  final double longitude;
  final String? address;
  final bool is24Hour;
  final bool isVerified;
  final double? distanceMeters;

  /// Repository-backed air-conditioned rest (not inferred from venue name).
  final bool acRest;

  /// Repository-backed shade / waiting-area respite.
  final bool respite;

  /// L10n key for source-level provenance text (`cooling_prov_*`).
  final String? classificationProvenanceKey;

  /// Verbatim repo quote when public access is documented (nearest-stop only).
  final String? publicAccessEvidence;

  CoolingResource copyWith({
    double? distanceMeters,
    bool? isVerified,
    bool? acRest,
    bool? respite,
    String? classificationProvenanceKey,
    String? publicAccessEvidence,
  }) {
    return CoolingResource(
      id: id,
      name: name,
      type: type,
      latitude: latitude,
      longitude: longitude,
      address: address,
      is24Hour: is24Hour,
      isVerified: isVerified ?? this.isVerified,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      acRest: acRest ?? this.acRest,
      respite: respite ?? this.respite,
      classificationProvenanceKey:
          classificationProvenanceKey ?? this.classificationProvenanceKey,
      publicAccessEvidence: publicAccessEvidence ?? this.publicAccessEvidence,
    );
  }
}
