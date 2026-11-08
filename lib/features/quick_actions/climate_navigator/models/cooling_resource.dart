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

  CoolingResource copyWith({
    double? distanceMeters,
    bool? isVerified,
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
    );
  }
}
