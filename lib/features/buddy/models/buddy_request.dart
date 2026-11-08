import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';

class BuddyRequest {
  const BuddyRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.introTemplateId,
    required this.introText,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
    this.threadId,
  });

  final String id;
  final String fromUid;
  final String toUid;
  final String introTemplateId;
  final String introText;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final String? threadId;

  bool get isPending => status == BuddyConstants.requestStatusPending;

  bool get isExpired =>
      isPending && DateTime.now().isAfter(expiresAt);

  String get effectiveStatus =>
      isExpired ? BuddyConstants.requestStatusExpired : status;

  factory BuddyRequest.fromFirestore(String id, Map<String, dynamic> data) {
    return BuddyRequest(
      id: id,
      fromUid: data['fromUid'] as String? ?? '',
      toUid: data['toUid'] as String? ?? '',
      introTemplateId: data['introTemplateId'] as String? ?? '',
      introText: data['introText'] as String? ?? '',
      status: data['status'] as String? ?? BuddyConstants.requestStatusPending,
      createdAt: _ts(data['createdAt']) ?? DateTime.now(),
      expiresAt: _ts(data['expiresAt']) ?? DateTime.now(),
      respondedAt: _ts(data['respondedAt']),
      threadId: data['threadId'] as String?,
    );
  }

  static DateTime? _ts(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }
}
