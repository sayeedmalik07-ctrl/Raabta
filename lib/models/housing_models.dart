enum ListingType { room, flat, sharing, studio, all }

enum GenderPreference { maleOnly, femaleOnly, family, any }

enum NationalityPreference { any, indian, pakistani, filipino, arabic }

enum ListingStatus { pending, approved, rejected }

enum ScamVerdict { safe, suspicious, likelyScam }

ScamVerdict? parseScamVerdict(String? value) {
  switch (value) {
    case 'safe':
      return ScamVerdict.safe;
    case 'suspicious':
      return ScamVerdict.suspicious;
    case 'likely_scam':
      return ScamVerdict.likelyScam;
    default:
      return null;
  }
}

String scamVerdictToApi(ScamVerdict verdict) {
  switch (verdict) {
    case ScamVerdict.safe:
      return 'safe';
    case ScamVerdict.suspicious:
      return 'suspicious';
    case ScamVerdict.likelyScam:
      return 'likely_scam';
  }
}

class ScamScanResult {
  const ScamScanResult({
    required this.scamScore,
    required this.verdict,
    required this.flags,
    required this.reason,
    required this.recommendation,
    this.listingId,
    this.scannedAt,
  });

  final int scamScore;
  final ScamVerdict verdict;
  final List<String> flags;
  final String reason;
  final String recommendation;
  final String? listingId;
  final DateTime? scannedAt;

  factory ScamScanResult.fromJson(Map<String, dynamic> json) {
    return ScamScanResult(
      listingId: json['listingId'] as String?,
      scamScore: (json['scamScore'] as num?)?.toInt() ?? 0,
      verdict: parseScamVerdict(json['verdict'] as String?) ?? ScamVerdict.safe,
      flags: (json['flags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      reason: json['reason'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? ''),
    );
  }
}

class HousingListing {
  const HousingListing({
    required this.id,
    required this.title,
    required this.area,
    required this.areaSlug,
    required this.pricePerMonth,
    required this.type,
    required this.furnished,
    required this.bedrooms,
    required this.bathrooms,
    required this.photoUrls,
    required this.description,
    required this.amenities,
    required this.genderPreference,
    required this.nationalityPreference,
    required this.posterNationality,
    required this.posterNationalityFlag,
    required this.whatsapp,
    required this.phone,
    required this.contactName,
    required this.verified,
    required this.scamFlagged,
    this.scamScore,
    this.scamVerdict,
    this.scamFlags = const [],
    this.scamReason,
    this.scamRecommendation,
    this.reportCount = 0,
    required this.status,
    required this.featured,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.shareUrl,
  });

  final String id;
  final String title;
  final String area;
  final String areaSlug;
  final int pricePerMonth;
  final ListingType type;
  final bool furnished;
  final int bedrooms;
  final int bathrooms;
  final List<String> photoUrls;
  final String description;
  final List<String> amenities;
  final GenderPreference genderPreference;
  final NationalityPreference nationalityPreference;
  final String posterNationality;
  final String posterNationalityFlag;
  final String whatsapp;
  final String phone;
  final String contactName;
  final bool verified;
  final bool scamFlagged;
  final int? scamScore;
  final ScamVerdict? scamVerdict;
  final List<String> scamFlags;
  final String? scamReason;
  final String? scamRecommendation;
  final int reportCount;
  final ListingStatus status;
  final bool featured;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String? shareUrl;

  String get typeLabel {
    switch (type) {
      case ListingType.room:
        return 'Room';
      case ListingType.flat:
        return 'Flat';
      case ListingType.sharing:
        return 'Sharing';
      case ListingType.studio:
        return 'Studio';
      case ListingType.all:
        return 'All';
    }
  }

  String get furnishedLabel => furnished ? 'Furnished' : 'Unfurnished';

  String get priceLabel =>
      '${_formatNumber(pricePerMonth)} QR/month';

  int get daysAgo {
    final diff = DateTime.now().difference(createdAt).inDays;
    if (diff <= 0) return 0;
    return diff;
  }

  String get postedLabel {
    final days = daysAgo;
    if (days == 0) return 'Posted today';
    if (days == 1) return 'Posted 1 day ago';
    return 'Posted $days days ago';
  }

  String get shareLink =>
      shareUrl ?? 'https://raabta.app/listings/$id';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'area': area,
        'areaSlug': areaSlug,
        'pricePerMonth': pricePerMonth,
        'type': type.name,
        'furnished': furnished,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'photoUrls': photoUrls,
        'description': description,
        'amenities': amenities,
        'genderPreference': genderPreference.name,
        'nationalityPreference': nationalityPreference.name,
        'posterNationality': posterNationality,
        'posterNationalityFlag': posterNationalityFlag,
        'whatsapp': whatsapp,
        'phone': phone,
        'contactName': contactName,
        'verified': verified,
        'scamFlagged': scamFlagged,
        'scamScore': scamScore,
        'verdict': scamVerdict != null ? scamVerdictToApi(scamVerdict!) : null,
        'flags': scamFlags,
        'scamReason': scamReason,
        'scamRecommendation': scamRecommendation,
        'report_count': reportCount,
        'status': status.name,
        'featured': featured,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
        'shareUrl': shareUrl,
      };

  factory HousingListing.fromJson(Map<String, dynamic> json) {
    return HousingListing(
      id: json['id'] as String,
      title: json['title'] as String,
      area: json['area'] as String,
      areaSlug: json['areaSlug'] as String? ?? _slugify(json['area'] as String),
      pricePerMonth: (json['pricePerMonth'] as num).toInt(),
      type: _parseType(json['type'] as String?),
      furnished: json['furnished'] as bool? ?? false,
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 1,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 1,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String? ?? '',
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      genderPreference:
          _parseGender(json['genderPreference'] as String? ?? 'any'),
      nationalityPreference: _parseNationality(
        json['nationalityPreference'] as String? ?? 'any',
      ),
      posterNationality: json['posterNationality'] as String? ?? 'Expat',
      posterNationalityFlag: json['posterNationalityFlag'] as String? ?? '🌍',
      whatsapp: json['whatsapp'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      contactName: json['contactName'] as String? ?? 'Owner',
      verified: json['verified'] as bool? ?? false,
      scamFlagged: json['scamFlagged'] as bool? ?? false,
      scamScore: (json['scamScore'] as num?)?.toInt(),
      scamVerdict: parseScamVerdict(json['verdict'] as String?),
      scamFlags: (json['flags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      scamReason: json['scamReason'] as String?,
      scamRecommendation: json['scamRecommendation'] as String?,
      reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
      status: _parseStatus(json['status'] as String? ?? 'approved'),
      featured: json['featured'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 25.2854,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 51.5310,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      shareUrl: json['shareUrl'] as String?,
    );
  }

  static String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  static String _slugify(String area) =>
      area.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
}

class HousingFilters {
  const HousingFilters({
    this.searchQuery = '',
    this.area,
    this.type = ListingType.all,
    this.minPrice = 500,
    this.maxPrice = 5000,
    this.gender = GenderPreference.any,
    this.nationality = NationalityPreference.any,
  });

  final String searchQuery;
  final String? area;
  final ListingType type;
  final double minPrice;
  final double maxPrice;
  final GenderPreference gender;
  final NationalityPreference nationality;

  HousingFilters copyWith({
    String? searchQuery,
    String? area,
    bool clearArea = false,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    GenderPreference? gender,
    NationalityPreference? nationality,
  }) {
    return HousingFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      area: clearArea ? null : (area ?? this.area),
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
    );
  }
}

class CreateListingRequest {
  const CreateListingRequest({
    required this.title,
    required this.area,
    required this.pricePerMonth,
    required this.type,
    required this.furnished,
    required this.bedrooms,
    required this.bathrooms,
    required this.photoUrls,
    required this.description,
    required this.amenities,
    required this.genderPreference,
    required this.nationalityPreference,
    required this.whatsapp,
    required this.phone,
    required this.contactName,
    required this.featured,
    required this.isPremiumUser,
  });

  final String title;
  final String area;
  final int pricePerMonth;
  final ListingType type;
  final bool furnished;
  final int bedrooms;
  final int bathrooms;
  final List<String> photoUrls;
  final String description;
  final List<String> amenities;
  final GenderPreference genderPreference;
  final NationalityPreference nationalityPreference;
  final String whatsapp;
  final String phone;
  final String contactName;
  final bool featured;
  final bool isPremiumUser;

  Map<String, dynamic> toJson() => {
        'title': title,
        'area': area,
        'pricePerMonth': pricePerMonth,
        'type': type.name,
        'furnished': furnished,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'photoUrls': photoUrls,
        'description': description,
        'amenities': amenities,
        'genderPreference': genderPreference.name,
        'nationalityPreference': nationalityPreference.name,
        'whatsapp': whatsapp,
        'phone': phone,
        'contactName': contactName,
        'featured': featured && isPremiumUser,
        'isPremiumUser': isPremiumUser,
      };
}

class ListingReport {
  const ListingReport({
    required this.reason,
    required this.details,
    required this.reporterContact,
  });

  final String reason;
  final String details;
  final String reporterContact;

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'details': details,
        'reporterContact': reporterContact,
      };
}

const qatarAreas = [
  'Al Khor',
  'Doha',
  'Lusail',
  'Al Wakrah',
  'Mesaieed',
  'Al Rayyan',
  'West Bay',
  'The Pearl',
];

const areaCoordinates = {
  'Al Khor': (25.6804, 51.4969),
  'Doha': (25.2854, 51.5310),
  'Lusail': (25.4244, 51.5074),
  'Al Wakrah': (25.1659, 51.5976),
  'Mesaieed': (24.9924, 51.5517),
  'Al Rayyan': (25.2919, 51.4244),
  'West Bay': (25.3254, 51.5300),
  'The Pearl': (25.3680, 51.5500),
};

ListingType _parseType(String? value) {
  return ListingType.values.firstWhere(
    (e) => e.name == value?.toLowerCase(),
    orElse: () => ListingType.room,
  );
}

GenderPreference _parseGender(String value) {
  return GenderPreference.values.firstWhere(
    (e) => e.name == value.replaceAll('_', '').toLowerCase() ||
        e.name == value.toLowerCase(),
    orElse: () => GenderPreference.any,
  );
}

NationalityPreference _parseNationality(String value) {
  return NationalityPreference.values.firstWhere(
    (e) => e.name == value.toLowerCase(),
    orElse: () => NationalityPreference.any,
  );
}

ListingStatus _parseStatus(String value) {
  return ListingStatus.values.firstWhere(
    (e) => e.name == value.toLowerCase(),
    orElse: () => ListingStatus.approved,
  );
}

String areaSlug(String area) => area.toLowerCase().replaceAll(' ', '');

String genderLabel(GenderPreference value) {
  switch (value) {
    case GenderPreference.maleOnly:
      return 'Male Only';
    case GenderPreference.femaleOnly:
      return 'Female Only';
    case GenderPreference.family:
      return 'Family';
    case GenderPreference.any:
      return 'Any';
  }
}

String nationalityLabel(NationalityPreference value) {
  switch (value) {
    case NationalityPreference.any:
      return 'Any';
    case NationalityPreference.indian:
      return 'Indian';
    case NationalityPreference.pakistani:
      return 'Pakistani';
    case NationalityPreference.filipino:
      return 'Filipino';
    case NationalityPreference.arabic:
      return 'Arabic';
  }
}

List<HousingListing> fallbackHousingListings() {
  final now = DateTime.now();
  return [
    HousingListing(
      id: 'listing-1',
      title: 'Spacious Room near Al Khor Mall',
      area: 'Al Khor',
      areaSlug: 'alkhor',
      pricePerMonth: 1200,
      type: ListingType.room,
      furnished: true,
      bedrooms: 1,
      bathrooms: 1,
      photoUrls: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
      ],
      description:
          'Clean furnished room with shared kitchen. Near bus stop and Lulu Hypermarket.',
      amenities: ['WiFi', 'AC', 'Kitchen', 'Laundry'],
      genderPreference: GenderPreference.any,
      nationalityPreference: NationalityPreference.any,
      posterNationality: 'Indian',
      posterNationalityFlag: '🇮🇳',
      whatsapp: '97455123456',
      phone: '+97455123456',
      contactName: 'Rahul',
      verified: true,
      scamFlagged: false,
      status: ListingStatus.approved,
      featured: true,
      latitude: 25.6804,
      longitude: 51.4969,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    HousingListing(
      id: 'listing-2',
      title: '2BHK Flat in Al Sadd',
      area: 'Doha',
      areaSlug: 'doha',
      pricePerMonth: 3200,
      type: ListingType.flat,
      furnished: false,
      bedrooms: 2,
      bathrooms: 2,
      photoUrls: [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      ],
      description: 'Family flat with parking. Close to metro.',
      amenities: ['WiFi', 'AC', 'Parking', 'Balcony'],
      genderPreference: GenderPreference.family,
      nationalityPreference: NationalityPreference.any,
      posterNationality: 'Pakistani',
      posterNationalityFlag: '🇵🇰',
      whatsapp: '97455987654',
      phone: '+97455987654',
      contactName: 'Ahmed',
      verified: true,
      scamFlagged: false,
      status: ListingStatus.approved,
      featured: false,
      latitude: 25.2854,
      longitude: 51.5310,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    HousingListing(
      id: 'listing-3',
      title: 'Sharing Accommodation - Female Only',
      area: 'Lusail',
      areaSlug: 'lusail',
      pricePerMonth: 900,
      type: ListingType.sharing,
      furnished: true,
      bedrooms: 1,
      bathrooms: 1,
      photoUrls: [
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
      ],
      description: 'Bed space in shared villa. Filipino roommates welcome.',
      amenities: ['WiFi', 'AC', 'Kitchen'],
      genderPreference: GenderPreference.femaleOnly,
      nationalityPreference: NationalityPreference.filipino,
      posterNationality: 'Filipino',
      posterNationalityFlag: '🇵🇭',
      whatsapp: '97455654321',
      phone: '+97455654321',
      contactName: 'Maria',
      verified: false,
      scamFlagged: true,
      scamScore: 82,
      scamVerdict: ScamVerdict.likelyScam,
      scamFlags: const ['price_too_low', 'urgency_language', 'whatsapp_only'],
      scamReason: 'Price is far below market rate for Lusail with urgency language.',
      scamRecommendation:
          'Do not pay any deposit before viewing. Verify the poster in person.',
      status: ListingStatus.approved,
      featured: false,
      latitude: 25.4244,
      longitude: 51.5074,
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    HousingListing(
      id: 'listing-4',
      title: 'Modern Studio near Metro',
      area: 'Lusail',
      areaSlug: 'lusail',
      pricePerMonth: 2800,
      type: ListingType.studio,
      furnished: true,
      bedrooms: 1,
      bathrooms: 1,
      photoUrls: [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      ],
      description: 'Fully furnished studio with gym access.',
      amenities: ['WiFi', 'AC', 'Parking', 'Gym'],
      genderPreference: GenderPreference.any,
      nationalityPreference: NationalityPreference.any,
      posterNationality: 'Arabic',
      posterNationalityFlag: '🇶🇦',
      whatsapp: '97455432109',
      phone: '+97455432109',
      contactName: 'Khalid',
      verified: true,
      scamFlagged: false,
      status: ListingStatus.approved,
      featured: false,
      latitude: 25.4244,
      longitude: 51.5074,
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    HousingListing(
      id: 'listing-5',
      title: 'Budget Room - Al Wakrah',
      area: 'Al Wakrah',
      areaSlug: 'alwakrah',
      pricePerMonth: 750,
      type: ListingType.room,
      furnished: false,
      bedrooms: 1,
      bathrooms: 1,
      photoUrls: [
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
      ],
      description: 'Affordable room for workers. Bus to industrial area.',
      amenities: ['AC', 'Kitchen'],
      genderPreference: GenderPreference.maleOnly,
      nationalityPreference: NationalityPreference.indian,
      posterNationality: 'Indian',
      posterNationalityFlag: '🇮🇳',
      whatsapp: '97455345678',
      phone: '+97455345678',
      contactName: 'Sunil',
      verified: false,
      scamFlagged: false,
      status: ListingStatus.pending,
      featured: false,
      latitude: 25.1659,
      longitude: 51.5976,
      createdAt: now.subtract(const Duration(days: 5)),
    ),
  ];
}
