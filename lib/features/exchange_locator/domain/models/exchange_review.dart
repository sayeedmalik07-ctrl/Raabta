import 'package:cloud_firestore/cloud_firestore.dart';

enum ExchangeReviewSort { recent, highestRating }

class ExchangeReview {
  const ExchangeReview({
    required this.id,
    required this.branchId,
    required this.userId,
    required this.rating,
    this.review = '',
    this.userDisplayName,
    this.createdAt,
  });

  final String id;
  final String branchId;
  final String userId;
  final int rating;
  final String review;
  final String? userDisplayName;
  final DateTime? createdAt;

  factory ExchangeReview.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ExchangeReview.fromJson({...data, 'reviewId': doc.id});
  }

  factory ExchangeReview.fromJson(Map<String, dynamic> json) {
    return ExchangeReview(
      id: json['reviewId'] as String? ?? json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      review: json['review'] as String? ?? '',
      userDisplayName: json['userDisplayName'] as String?,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'reviewId': id,
        'branchId': branchId,
        'userId': userId,
        'rating': rating,
        'review': review,
        'userDisplayName': userDisplayName,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
