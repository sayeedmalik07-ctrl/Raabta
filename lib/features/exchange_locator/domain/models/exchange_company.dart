import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_data_status.dart';

class ExchangeCompany {
  const ExchangeCompany({
    required this.id,
    required this.name,
    this.logo,
    this.description = '',
    this.website,
    this.supportPhone,
    this.supportWhatsapp,
    this.email,
    this.totalBranches = 0,
    this.rating = 0,
    this.totalReviews = 0,
    this.isFeatured = false,
    this.isVerified = false,
    this.dataStatus = ExchangeDataStatus.verified,
    this.coverageNote,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? logo;
  final String description;
  final String? website;
  final String? supportPhone;
  final String? supportWhatsapp;
  final String? email;
  final int totalBranches;
  final double rating;
  final int totalReviews;
  final bool isFeatured;
  final bool isVerified;
  final ExchangeDataStatus dataStatus;
  final String? coverageNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Honest subtitle for directory cards — never implies unseeded branch coverage.
  String get branchListingLabel {
    if (dataStatus == ExchangeDataStatus.pendingVerification) {
      return 'Details being confirmed';
    }
    if (totalBranches <= 0) {
      return 'No branches listed yet';
    }
    final countLabel =
        '$totalBranches branch${totalBranches == 1 ? '' : 'es'} listed';
    if (dataStatus == ExchangeDataStatus.partial && coverageNote != null) {
      return countLabel;
    }
    return countLabel;
  }

  factory ExchangeCompany.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ExchangeCompany.fromJson({...data, 'companyId': doc.id});
  }

  factory ExchangeCompany.fromJson(Map<String, dynamic> json) {
    return ExchangeCompany(
      id: json['companyId'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      description: json['description'] as String? ?? '',
      website: json['website'] as String?,
      supportPhone: json['supportPhone'] as String?,
      supportWhatsapp: json['supportWhatsapp'] as String?,
      email: json['email'] as String?,
      totalBranches: (json['totalBranches'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      dataStatus: ExchangeDataStatus.fromValue(json['dataStatus'] as String?),
      coverageNote: json['coverageNote'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'companyId': id,
        'name': name,
        'logo': logo,
        'description': description,
        'website': website,
        'supportPhone': supportPhone,
        'supportWhatsapp': supportWhatsapp,
        'email': email,
        'totalBranches': totalBranches,
        'rating': rating,
        'totalReviews': totalReviews,
        'isFeatured': isFeatured,
        'isVerified': isVerified,
        'dataStatus': dataStatus.value,
        if (coverageNote != null) 'coverageNote': coverageNote,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  ExchangeCompany copyWith({
    String? id,
    String? name,
    String? logo,
    String? description,
    String? website,
    String? supportPhone,
    String? supportWhatsapp,
    String? email,
    int? totalBranches,
    double? rating,
    int? totalReviews,
    bool? isFeatured,
    bool? isVerified,
    ExchangeDataStatus? dataStatus,
    String? coverageNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExchangeCompany(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      website: website ?? this.website,
      supportPhone: supportPhone ?? this.supportPhone,
      supportWhatsapp: supportWhatsapp ?? this.supportWhatsapp,
      email: email ?? this.email,
      totalBranches: totalBranches ?? this.totalBranches,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      dataStatus: dataStatus ?? this.dataStatus,
      coverageNote: coverageNote ?? this.coverageNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
