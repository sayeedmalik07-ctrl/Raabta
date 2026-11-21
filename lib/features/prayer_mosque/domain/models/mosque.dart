/// Mosque / prayer hall model for nearby search and details.
class MosquePlace {
  const MosquePlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.description = '',
    this.phone,
    this.website,
    this.rating = 0,
    this.reviewCount = 0,
    this.distanceMeters,
    this.walkMinutes,
    this.driveMinutes,
    this.isOpen = true,
    this.jumuahTime,
    this.khutbahTime,
    this.prayerCapacity,
    this.photoUrls = const [],
    this.facilities = const MosqueFacilities(),
    this.type = MosqueType.mosque,
    this.placeId,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final String? phone;
  final String? website;
  final double rating;
  final int reviewCount;
  final double? distanceMeters;
  final int? walkMinutes;
  final int? driveMinutes;
  final bool isOpen;
  final String? jumuahTime;
  final String? khutbahTime;
  final int? prayerCapacity;
  final List<String> photoUrls;
  final MosqueFacilities facilities;
  final MosqueType type;
  final String? placeId;

  MosquePlace copyWith({
    double? distanceMeters,
    int? walkMinutes,
    int? driveMinutes,
    bool? isOpen,
  }) {
    return MosquePlace(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      description: description,
      phone: phone,
      website: website,
      rating: rating,
      reviewCount: reviewCount,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      walkMinutes: walkMinutes ?? this.walkMinutes,
      driveMinutes: driveMinutes ?? this.driveMinutes,
      isOpen: isOpen ?? this.isOpen,
      jumuahTime: jumuahTime,
      khutbahTime: khutbahTime,
      prayerCapacity: prayerCapacity,
      photoUrls: photoUrls,
      facilities: facilities,
      type: type,
      placeId: placeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'description': description,
        'phone': phone,
        'website': website,
        'rating': rating,
        'reviewCount': reviewCount,
        'jumuahTime': jumuahTime,
        'khutbahTime': khutbahTime,
        'prayerCapacity': prayerCapacity,
        'photoUrls': photoUrls,
        'facilities': facilities.toJson(),
        'type': type.name,
        'placeId': placeId,
      };

  factory MosquePlace.fromJson(Map<String, dynamic> json) {
    return MosquePlace(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      jumuahTime: json['jumuahTime'] as String?,
      khutbahTime: json['khutbahTime'] as String?,
      prayerCapacity: json['prayerCapacity'] as int?,
      photoUrls: (json['photoUrls'] as List?)?.cast<String>() ?? const [],
      facilities: MosqueFacilities.fromJson(
        Map<String, dynamic>.from(json['facilities'] as Map? ?? {}),
      ),
      type: MosqueType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MosqueType.mosque,
      ),
      placeId: json['placeId'] as String?,
    );
  }
}

enum MosqueType { mosque, prayerHall, islamicCenter }

class MosqueFacilities {
  const MosqueFacilities({
    this.wheelchairAccess = false,
    this.parking = false,
    this.ablution = true,
    this.airConditioning = false,
    this.womensPrayerArea = false,
    this.jumuahAvailable = false,
  });

  final bool wheelchairAccess;
  final bool parking;
  final bool ablution;
  final bool airConditioning;
  final bool womensPrayerArea;
  final bool jumuahAvailable;

  Map<String, dynamic> toJson() => {
        'wheelchairAccess': wheelchairAccess,
        'parking': parking,
        'ablution': ablution,
        'airConditioning': airConditioning,
        'womensPrayerArea': womensPrayerArea,
        'jumuahAvailable': jumuahAvailable,
      };

  factory MosqueFacilities.fromJson(Map<String, dynamic> json) {
    return MosqueFacilities(
      wheelchairAccess: json['wheelchairAccess'] as bool? ?? false,
      parking: json['parking'] as bool? ?? false,
      ablution: json['ablution'] as bool? ?? true,
      airConditioning: json['airConditioning'] as bool? ?? false,
      womensPrayerArea: json['womensPrayerArea'] as bool? ?? false,
      jumuahAvailable: json['jumuahAvailable'] as bool? ?? false,
    );
  }
}
