import 'package:cloud_firestore/cloud_firestore.dart';

/// Target audience for an admin broadcast.
enum AdminBroadcastTarget {
  allUsers,
  optedInOnly,
}

extension AdminBroadcastTargetX on AdminBroadcastTarget {
  String get firestoreValue =>
      this == AdminBroadcastTarget.optedInOnly ? 'opted_in' : 'all';

  String get displayLabel => switch (this) {
        AdminBroadcastTarget.allUsers => 'All Users',
        AdminBroadcastTarget.optedInOnly => 'Opted-in Only',
      };
}

/// Read model for broadcast entries in [admin_audit_log].
class AdminAuditLogEntry {
  const AdminAuditLogEntry({
    required this.id,
    required this.adminUid,
    required this.adminEmail,
    required this.action,
    required this.targetType,
    required this.referenceId,
    this.metadata,
    this.timestamp,
  });

  final String id;
  final String adminUid;
  final String adminEmail;
  final String action;
  final String targetType;
  final String referenceId;
  final Map<String, dynamic>? metadata;
  final DateTime? timestamp;

  String get broadcastTitle =>
      metadata?['title'] as String? ?? referenceId;

  String get targetModeLabel {
    final mode = metadata?['targetMode'] as String? ?? 'all';
    return mode == 'opted_in' ? 'Opted-in Only' : 'All Users';
  }

  factory AdminAuditLogEntry.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return AdminAuditLogEntry(
      id: doc.id,
      adminUid: data['adminUid'] as String? ?? '',
      adminEmail: data['adminEmail'] as String? ?? '',
      action: data['action'] as String? ?? '',
      targetType: data['targetType'] as String? ?? '',
      referenceId: data['referenceId'] as String? ?? '',
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
      timestamp: _parseTimestamp(data['timestamp']),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
