import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/data/models/employer_identity_verification.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';

/// User-facing listing status derived from admin moderation — not external verification.
enum BusinessListingDisplayStatus {
  pendingReview,
  listingApproved,
  directoryListing,
}

class BusinessListing {
  const BusinessListing({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.speciality,
    required this.trustScore,
    required this.phone,
    this.cuisine,
    this.openNow = true,
    this.closingTime,
    this.languages = const [],
    this.whatsapp,
    this.yearsActive = 1,
    this.hasReports = false,
    this.description,
    this.photoCount = 0,
    this.weeklyViews = 0,
    this.latestReview,
    this.isFeatured = false,
    this.tags = const [],
    this.ownerUserId,
    this.createdAt,
    this.verificationStatus,
    this.photoUrls = const [],
    this.contactMode = BusinessContactMode.messageOnly,
    this.status,
    this.categoryId,
    this.logoUrl,
    this.coverUrl,
    this.website,
    this.openingHours,
    this.socialLinks = const {},
    this.servicesOffered = const [],
    this.profileFields = const {},
    this.employerIdentityVerification,
  });

  final String id;
  final String name;
  final String category;
  final String emoji;
  final double rating;
  final int reviewCount;
  final String location;
  final String speciality;
  final int trustScore;
  final String phone;
  final String? cuisine;
  final bool openNow;
  final String? closingTime;
  final List<String> languages;
  final String? whatsapp;
  final int yearsActive;
  final bool hasReports;
  final String? description;
  final int photoCount;
  final int weeklyViews;
  final String? latestReview;
  final bool isFeatured;
  final List<String> tags;
  final String? ownerUserId;
  final DateTime? createdAt;
  final String? verificationStatus;
  final List<String> photoUrls;
  final BusinessContactMode contactMode;
  final String? status;
  final String? categoryId;
  final String? logoUrl;
  final String? coverUrl;
  final String? website;
  final Map<String, dynamic>? openingHours;
  final Map<String, String> socialLinks;
  final List<String> servicesOffered;
  final Map<String, dynamic> profileFields;
  final EmployerIdentityVerification? employerIdentityVerification;

  bool get hasWhatsApp => whatsapp != null && whatsapp!.trim().isNotEmpty;

  bool get isActiveListing => status == 'active';

  bool get hasAuthoritativeOwner =>
      ownerUserId != null && ownerUserId!.trim().isNotEmpty;

  bool get showsStructuredContactAction =>
      isActiveListing &&
      hasAuthoritativeOwner &&
      contactMode.allowsStructuredAction;

  bool get hasIftarTag => tags.contains('ramadan_iftar');

  bool get isPendingReview => verificationStatus == 'pending_review';

  /// Stored review count — no in-app review submission exists today.
  bool get hasStoredReviewData => reviewCount > 0;

  /// Rating is only meaningful when paired with stored review count.
  bool get hasDisplayRating => hasStoredReviewData && rating > 0;

  bool get hasDisplayLatestReview =>
      hasStoredReviewData && (latestReview?.trim().isNotEmpty ?? false);

  factory BusinessListing.fromFirestore(DocumentSnapshot doc) {
    return BusinessListing.fromFirestoreMap(
      doc.data() as Map<String, dynamic>? ?? {},
      doc.id,
    );
  }

  factory BusinessListing.fromFirestoreMap(
    Map<String, dynamic> data,
    String id,
  ) {
    final category = data['category'] as String? ?? 'Restaurant';
    return BusinessListing(
      id: id,
      name: data['name'] as String? ?? 'Business',
      category: category,
      emoji: data['emoji'] as String? ?? '🍽️',
      cuisine: data['cuisine'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      location: data['location'] as String? ??
          data['area'] as String? ??
          'Qatar',
      openNow: data['openNow'] as bool? ?? true,
      closingTime: data['closingTime'] as String?,
      languages: List<String>.from(data['languages'] ?? const []),
      phone: data['phone'] as String? ?? '',
      whatsapp: data['whatsapp'] as String?,
      yearsActive: (data['yearsActive'] as num?)?.toInt() ?? 1,
      speciality: data['speciality'] as String? ??
          data['description'] as String? ??
          'Local business',
      trustScore: (data['trustScore'] as num?)?.toInt() ?? 0,
      description: data['description'] as String?,
      photoCount: (data['photoCount'] as num?)?.toInt() ?? 0,
      weeklyViews: (data['weeklyViews'] as num?)?.toInt() ?? 0,
      latestReview: data['latestReview'] as String?,
      isFeatured: data['isFeatured'] as bool? ?? false,
      tags: List<String>.from(data['tags'] ?? const []),
      ownerUserId: data['ownerUserId'] as String? ??
          data['userId'] as String? ??
          data['claimedByUserId'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      verificationStatus: data['verificationStatus'] as String?,
      photoUrls: List<String>.from(data['photoUrls'] ?? const []),
      contactMode: BusinessContactModeX.fromStorage(
        data['contactMode'] as String?,
      ),
      status: data['status'] as String?,
      categoryId: data['categoryId'] as String?,
      logoUrl: data['logoUrl'] as String?,
      coverUrl: data['coverUrl'] as String?,
      website: data['website'] as String?,
      openingHours: data['openingHours'] is Map
          ? Map<String, dynamic>.from(data['openingHours'] as Map)
          : null,
      socialLinks: _stringMap(data['socialLinks']),
      servicesOffered: List<String>.from(
        data['servicesOffered'] ?? const [],
      ),
      profileFields: data['profileFields'] is Map
          ? Map<String, dynamic>.from(data['profileFields'] as Map)
          : const {},
      employerIdentityVerification: EmployerIdentityVerification.fromFirestore(
        data['employerIdentityVerification'],
      ),
    );
  }

  static Map<String, String> _stringMap(Object? raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  }

  static DateTime? _parseTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String get searchableText =>
      '$name $category ${cuisine ?? ''} $location $speciality ${languages.join(' ')}'
          .toLowerCase();

  bool get isInAlKhor => location.toLowerCase().contains('al khor');

  bool isInArea(String area) {
    final needle = area.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return location.toLowerCase().contains(needle);
  }
}

BusinessListingDisplayStatus businessListingDisplayStatus(
  BusinessListing business,
) {
  if (business.isPendingReview) {
    return BusinessListingDisplayStatus.pendingReview;
  }
  if (business.verificationStatus == 'approved') {
    return BusinessListingDisplayStatus.listingApproved;
  }
  return BusinessListingDisplayStatus.directoryListing;
}

Map<String, dynamic> businessListingToMatchData(BusinessListing business) {
  return {
    'id': business.id,
    'name': business.name,
    'category': business.category,
    'cuisine': business.cuisine ?? business.speciality,
    'location': business.location,
    'area': business.location,
    'rating': business.rating,
    'reviewCount': business.reviewCount,
    'languages': business.languages,
    'weeklyViews': business.weeklyViews,
    'viewCount': business.weeklyViews,
  };
}
