import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';

class BuddyThread {
  const BuddyThread({
    required this.id,
    required this.participantUids,
    required this.newcomerUid,
    required this.helperUid,
    required this.requestId,
    required this.status,
    required this.createdAt,
    this.endedAt,
    this.endedByUid,
  });

  final String id;
  final List<String> participantUids;
  final String newcomerUid;
  final String helperUid;
  final String requestId;
  final String status;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String? endedByUid;

  bool get isActive => status == BuddyConstants.threadStatusActive;

  factory BuddyThread.fromFirestore(String id, Map<String, dynamic> data) {
    return BuddyThread(
      id: id,
      participantUids: (data['participantUids'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      newcomerUid: data['newcomerUid'] as String? ?? '',
      helperUid: data['helperUid'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      status: data['status'] as String? ?? BuddyConstants.threadStatusActive,
      createdAt: _ts(data['createdAt']) ?? DateTime.now(),
      endedAt: _ts(data['endedAt']),
      endedByUid: data['endedByUid'] as String?,
    );
  }

  static DateTime? _ts(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }
}
