import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_data_status.dart';

/// Queue status values — structured for future IoT/automation without schema change.
enum ExchangeQueueStatus {
  low('low', 'Low wait'),
  moderate('moderate', 'Moderate wait'),
  busy('busy', 'Busy'),
  closed('closed', 'Closed');

  const ExchangeQueueStatus(this.value, this.label);
  final String value;
  final String label;

  static ExchangeQueueStatus fromValue(String? raw) {
    return ExchangeQueueStatus.values.firstWhere(
      (s) => s.value == raw,
      orElse: () => ExchangeQueueStatus.low,
    );
  }
}

class ExchangeBranch {
  const ExchangeBranch({
    required this.id,
    required this.companyId,
    required this.branchName,
    this.branchCode,
    this.address = '',
    this.area = '',
    this.city = 'Doha',
    this.zone = '',
    this.latitude = 25.2854,
    this.longitude = 51.5310,
    this.googleMapsLink,
    this.openingHours = '',
    this.closingHours = '',
    this.fridayTiming,
    this.isOpenNow = false,
    this.phone,
    this.whatsapp,
    this.email,
    this.services = const [],
    this.parkingAvailable = false,
    this.wheelchairAccessible = false,
    this.nearbyMetro,
    this.metroDistance,
    this.nearestLandmark,
    this.branchPhoto,
    this.queueStatus = ExchangeQueueStatus.low,
    this.estimatedWaitingMinutes = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.lastUpdated,
    this.companyName,
    this.companyLogo,
    this.dataStatus = ExchangeDataStatus.verified,
    this.geocodeSource,
    this.geocodePrecision,
    this.geocodedAt,
    this.detailsVerified = false,
    this.hourlyBusyCounts = const {},
    this.queueLastUpdated,
  });

  final String id;
  final String companyId;
  final String branchName;
  final String? branchCode;
  final String address;
  final String area;
  final String city;
  final String zone;
  final double latitude;
  final double longitude;
  final String? googleMapsLink;
  final String openingHours;
  final String closingHours;
  final String? fridayTiming;
  final bool isOpenNow;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final List<String> services;
  final bool parkingAvailable;
  final bool wheelchairAccessible;
  final String? nearbyMetro;
  final String? metroDistance;
  final String? nearestLandmark;
  final String? branchPhoto;
  final ExchangeQueueStatus queueStatus;
  final int estimatedWaitingMinutes;
  final double rating;
  final int reviewCount;
  final DateTime? lastUpdated;
  final String? companyName;
  final String? companyLogo;
  final ExchangeDataStatus dataStatus;
  final String? geocodeSource;
  final ExchangeGeocodePrecision? geocodePrecision;
  final DateTime? geocodedAt;
  final bool detailsVerified;
  /// Denormalized `{ "weekday-hour": reportCount }` for best-time hints.
  final Map<String, int> hourlyBusyCounts;
  final DateTime? queueLastUpdated;

  String get displayLocation =>
      [area, city].where((s) => s.isNotEmpty).join(', ');

  bool get hasConfirmedHours =>
      openingHours.isNotEmpty && closingHours.isNotEmpty;

  String get todayHours {
    if (!hasConfirmedHours) {
      return 'Hours not confirmed — contact branch';
    }
    if (fridayTiming != null && DateTime.now().weekday == DateTime.friday) {
      return fridayTiming!;
    }
    return '$openingHours – $closingHours';
  }

  factory ExchangeBranch.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ExchangeBranch.fromJson({...data, 'branchId': doc.id});
  }

  factory ExchangeBranch.fromJson(Map<String, dynamic> json) {
    return ExchangeBranch(
      id: json['branchId'] as String? ?? json['id'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      branchCode: json['branchCode'] as String?,
      address: json['address'] as String? ?? '',
      area: json['area'] as String? ?? '',
      city: json['city'] as String? ?? 'Doha',
      zone: json['zone'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 25.2854,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 51.5310,
      googleMapsLink: json['googleMapsLink'] as String?,
      openingHours: json['openingHours'] as String? ?? '',
      closingHours: json['closingHours'] as String? ?? '',
      fridayTiming: json['fridayTiming'] as String?,
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      parkingAvailable: json['parkingAvailable'] as bool? ?? false,
      wheelchairAccessible: json['wheelchairAccessible'] as bool? ?? false,
      nearbyMetro: json['nearbyMetro'] as String?,
      metroDistance: json['metroDistance'] as String?,
      nearestLandmark: json['nearestLandmark'] as String?,
      branchPhoto: json['branchPhoto'] as String?,
      queueStatus: ExchangeQueueStatus.fromValue(json['queueStatus'] as String?),
      estimatedWaitingMinutes:
          (json['estimatedWaitingMinutes'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      lastUpdated: _parseDate(json['lastUpdated']),
      companyName: json['companyName'] as String?,
      companyLogo: json['companyLogo'] as String?,
      dataStatus: ExchangeDataStatus.fromValue(json['dataStatus'] as String?),
      geocodeSource: json['geocodeSource'] as String?,
      geocodePrecision:
          ExchangeGeocodePrecision.fromValue(json['geocodePrecision'] as String?),
      geocodedAt: _parseDate(json['geocodedAt']),
      detailsVerified: json['detailsVerified'] as bool? ?? false,
      hourlyBusyCounts: _parseHourlyCounts(json['hourlyBusyCounts']),
      queueLastUpdated: _parseDate(json['queueLastUpdated'] ?? json['lastUpdated']),
    );
  }

  static Map<String, int> _parseHourlyCounts(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map(
      (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'branchId': id,
        'companyId': companyId,
        'branchName': branchName,
        'branchCode': branchCode,
        'address': address,
        'area': area,
        'city': city,
        'zone': zone,
        'latitude': latitude,
        'longitude': longitude,
        'googleMapsLink': googleMapsLink,
        'openingHours': openingHours,
        'closingHours': closingHours,
        'fridayTiming': fridayTiming,
        'isOpenNow': isOpenNow,
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'services': services,
        'parkingAvailable': parkingAvailable,
        'wheelchairAccessible': wheelchairAccessible,
        'nearbyMetro': nearbyMetro,
        'metroDistance': metroDistance,
        'nearestLandmark': nearestLandmark,
        'branchPhoto': branchPhoto,
        'queueStatus': queueStatus.value,
        'estimatedWaitingMinutes': estimatedWaitingMinutes,
        'rating': rating,
        'reviewCount': reviewCount,
        'lastUpdated':
            lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
        if (companyName != null) 'companyName': companyName,
        if (companyLogo != null) 'companyLogo': companyLogo,
        'dataStatus': dataStatus.value,
        if (geocodeSource != null) 'geocodeSource': geocodeSource,
        if (geocodePrecision != null) 'geocodePrecision': geocodePrecision!.value,
        if (geocodedAt != null) 'geocodedAt': Timestamp.fromDate(geocodedAt!),
        'detailsVerified': detailsVerified,
        if (hourlyBusyCounts.isNotEmpty) 'hourlyBusyCounts': hourlyBusyCounts,
        if (queueLastUpdated != null)
          'queueLastUpdated': Timestamp.fromDate(queueLastUpdated!),
      };

  ExchangeBranch copyWith({
    String? id,
    String? companyId,
    String? branchName,
    String? branchCode,
    String? address,
    String? area,
    String? city,
    String? zone,
    double? latitude,
    double? longitude,
    String? googleMapsLink,
    String? openingHours,
    String? closingHours,
    String? fridayTiming,
    bool? isOpenNow,
    String? phone,
    String? whatsapp,
    String? email,
    List<String>? services,
    bool? parkingAvailable,
    bool? wheelchairAccessible,
    String? nearbyMetro,
    String? metroDistance,
    String? nearestLandmark,
    String? branchPhoto,
    ExchangeQueueStatus? queueStatus,
    int? estimatedWaitingMinutes,
    double? rating,
    int? reviewCount,
    DateTime? lastUpdated,
    String? companyName,
    String? companyLogo,
    ExchangeDataStatus? dataStatus,
    String? geocodeSource,
    ExchangeGeocodePrecision? geocodePrecision,
    DateTime? geocodedAt,
    bool? detailsVerified,
    Map<String, int>? hourlyBusyCounts,
    DateTime? queueLastUpdated,
  }) {
    return ExchangeBranch(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
      address: address ?? this.address,
      area: area ?? this.area,
      city: city ?? this.city,
      zone: zone ?? this.zone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googleMapsLink: googleMapsLink ?? this.googleMapsLink,
      openingHours: openingHours ?? this.openingHours,
      closingHours: closingHours ?? this.closingHours,
      fridayTiming: fridayTiming ?? this.fridayTiming,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      services: services ?? this.services,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      nearbyMetro: nearbyMetro ?? this.nearbyMetro,
      metroDistance: metroDistance ?? this.metroDistance,
      nearestLandmark: nearestLandmark ?? this.nearestLandmark,
      branchPhoto: branchPhoto ?? this.branchPhoto,
      queueStatus: queueStatus ?? this.queueStatus,
      estimatedWaitingMinutes:
          estimatedWaitingMinutes ?? this.estimatedWaitingMinutes,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      dataStatus: dataStatus ?? this.dataStatus,
      geocodeSource: geocodeSource ?? this.geocodeSource,
      geocodePrecision: geocodePrecision ?? this.geocodePrecision,
      geocodedAt: geocodedAt ?? this.geocodedAt,
      detailsVerified: detailsVerified ?? this.detailsVerified,
      hourlyBusyCounts: hourlyBusyCounts ?? this.hourlyBusyCounts,
      queueLastUpdated: queueLastUpdated ?? this.queueLastUpdated,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
