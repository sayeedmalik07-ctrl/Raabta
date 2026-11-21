import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/post_engine/data/post_schema_persistence.dart';

/// Provider offer vs. customer request within `service_listings`.
enum ServiceListingType {
  provider('provider'),
  request('request');

  const ServiceListingType(this.id);
  final String id;

  static ServiceListingType fromStored(String? raw) {
    if (raw == request.id) return ServiceListingType.request;
    return ServiceListingType.provider;
  }
}

/// Published service listing in Firestore `service_listings`.
class ServiceListing {
  const ServiceListing({
    required this.id,
    required this.userId,
    required this.serviceCategoryId,
    required this.serviceCategory,
    required this.serviceName,
    required this.title,
    required this.description,
    required this.providerName,
    required this.phone,
    required this.area,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    this.listingType = ServiceListingType.provider,
    this.latitude,
    this.longitude,
    this.schemaFields = const {},
    this.posterIdentityVerified = false,
    this.quotesOpen = true,
    this.selectedQuoteProviderId,
  });

  final String id;
  final String userId;
  final String serviceCategoryId;
  final String serviceCategory;
  final String serviceName;
  final String title;
  final String description;
  final String providerName;
  final String phone;
  final String area;
  final String imageUrl;
  final String status;
  final DateTime createdAt;
  final ServiceListingType listingType;

  /// Optional coordinates when present in Firestore (read-only for S6 proximity).
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic> schemaFields;

  /// Set at publish when Firebase identity was verified (Part 11C).
  final bool posterIdentityVerified;

  /// When false, providers can no longer submit new quotes on this request.
  final bool quotesOpen;

  /// Provider UID whose quote the customer chose to proceed with.
  final String? selectedQuoteProviderId;

  String get displayTitle =>
      title.trim().isNotEmpty ? title.trim() : serviceName;

  bool get hasSchemaAttributes => schemaFields.isNotEmpty;

  bool get isRequest => listingType == ServiceListingType.request;

  bool get acceptsQuotes => isRequest && quotesOpen;

  factory ServiceListing.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final createdAtRaw = data['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return ServiceListing(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      serviceCategoryId: data['serviceCategoryId'] as String? ?? '',
      serviceCategory: data['serviceCategory'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      providerName: data['providerName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      area: data['area'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      status: data['status'] as String? ?? 'active',
      createdAt: createdAt,
      listingType: ServiceListingType.fromStored(
        data['listingType'] as String?,
      ),
      latitude: _readCoordinate(data, 'latitude', 'lat'),
      longitude: _readCoordinate(data, 'longitude', 'lng'),
      schemaFields:
          PostSchemaPersistence.parseSchemaFieldsForRead(data['schemaFields']),
      posterIdentityVerified:
          data['posterIdentityVerified'] as bool? ?? false,
      quotesOpen: data['quotesOpen'] as bool? ?? true,
      selectedQuoteProviderId:
          data['selectedQuoteProviderId'] as String?,
    );
  }

  static double? _readCoordinate(
    Map<String, dynamic> data,
    String primaryKey,
    String altKey,
  ) {
    final raw = data[primaryKey] ?? data[altKey];
    if (raw is num && raw.isFinite) return raw.toDouble();
    return null;
  }
}

class ServiceListingSubmission {
  const ServiceListingSubmission({
    required this.userId,
    required this.serviceCategoryId,
    required this.serviceCategory,
    required this.serviceName,
    required this.title,
    required this.description,
    required this.providerName,
    required this.phone,
    required this.area,
    required this.imageUrl,
    this.listingType = ServiceListingType.provider,
    this.schemaFields = const {},
    this.posterIdentityVerified = false,
  });

  final String userId;
  final String serviceCategoryId;
  final String serviceCategory;
  final String serviceName;
  final String title;
  final String description;
  final String providerName;
  final String phone;
  final String area;
  final String imageUrl;
  final ServiceListingType listingType;
  final Map<String, dynamic> schemaFields;
  final bool posterIdentityVerified;

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'serviceCategoryId': serviceCategoryId,
        'serviceCategory': serviceCategory,
        'serviceName': serviceName,
        'title': title,
        'description': description,
        'providerName': providerName,
        'phone': phone,
        'area': area,
        'imageUrl': imageUrl,
        'listingType': listingType.id,
        if (schemaFields.isNotEmpty) 'schemaFields': schemaFields,
        if (posterIdentityVerified) 'posterIdentityVerified': true,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        if (listingType == ServiceListingType.request) 'quotesOpen': true,
      };
}

/// Tuple for category + optional sub-service filter and listing type.
typedef ServiceListingFilter = ({
  String categoryId,
  String? serviceName,
  ServiceListingType listingType,
});
