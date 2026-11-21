import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';
import 'package:raabta/services/firebase_service.dart';

/// Cached moderation decision for duplicate/near-duplicate resubmissions.
class ModerationDedupRecord {
  const ModerationDedupRecord({
    required this.verdict,
    required this.reason,
    this.linkedDocId,
    required this.createdAt,
  });

  final String verdict;
  final String reason;
  final String? linkedDocId;
  final DateTime createdAt;

  bool get isApprove => verdict == 'approve';
  bool get isReject => verdict == 'reject';
  bool get isPending => verdict == 'pending';
}

/// Short-lived Firestore dedup for same-user identical submissions.
class CommunityModerationDedup {
  CommunityModerationDedup({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static String hashContent(String normalized) {
    final bytes = utf8.encode(normalized);
    return base64Url.encode(bytes).replaceAll('=', '').substring(0, 32);
  }

  static String normalizeEvent({
    required String title,
    required String description,
    required String location,
  }) {
    return [
      title.trim().toLowerCase(),
      description.trim().toLowerCase(),
      location.trim().toLowerCase(),
    ].join('|');
  }

  static String normalizeLostFound({
    required String type,
    required String title,
    required String itemDescription,
    required String location,
    required String contactInfo,
  }) {
    return [
      type.trim().toLowerCase(),
      title.trim().toLowerCase(),
      itemDescription.trim().toLowerCase(),
      location.trim().toLowerCase(),
      contactInfo.replaceAll(RegExp(r'\s'), ''),
    ].join('|');
  }

  Future<ModerationDedupRecord?> findRecent({
    required String userId,
    required String contentType,
    required String contentHash,
  }) async {
    if (!FirebaseService.isReady) return null;

    final snap = await _db
        .collection('community_moderation_dedup')
        .where('userId', isEqualTo: userId)
        .where('contentType', isEqualTo: contentType)
        .where('contentHash', isEqualTo: contentHash)
        .limit(5)
        .get();

    final now = DateTime.now();
    ModerationDedupRecord? best;

    for (final doc in snap.docs) {
      final data = doc.data();
      final expiresAt = _toDate(data['expiresAt']);
      if (expiresAt != null && expiresAt.isBefore(now)) continue;

      final createdAt = _toDate(data['createdAt']) ?? now;
      final record = ModerationDedupRecord(
        verdict: data['verdict'] as String? ?? 'pending',
        reason: data['reason'] as String? ?? '',
        linkedDocId: data['linkedDocId'] as String?,
        createdAt: createdAt,
      );
      if (best == null || record.createdAt.isAfter(best.createdAt)) {
        best = record;
      }
    }
    return best;
  }

  Future<void> save({
    required String userId,
    required String contentType,
    required String contentHash,
    required String verdict,
    required String reason,
    String? linkedDocId,
  }) async {
    if (!FirebaseService.isReady) return;

    final now = DateTime.now();
    final expiresAt = now.add(CommunityModerationConfig.dedupTtl);

    await _db.collection('community_moderation_dedup').add({
      'userId': userId,
      'contentType': contentType,
      'contentHash': contentHash,
      'verdict': verdict,
      'reason': reason,
      'linkedDocId': linkedDocId,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
