import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminReportType {
  listing,
  chat,
  bug,
  job,
  business,
  other,
}

enum AdminReportStatus {
  open,
  reviewing,
  resolved,
  dismissed,
}

class AdminReportModel {
  const AdminReportModel({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    this.targetId,
    this.targetType,
    this.reporterId,
    this.reporterContact,
    this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
    this.resolutionNote,
    this.chatSnapshot,
  });

  final String id;
  final AdminReportType type;
  final AdminReportStatus status;
  final String title;
  final String description;
  final String? targetId;
  final String? targetType;
  final String? reporterId;
  final String? reporterContact;
  final DateTime? createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolutionNote;
  final Map<String, dynamic>? chatSnapshot;

  factory AdminReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AdminReportModel(
      id: doc.id,
      type: _parseType(data['type'] as String?),
      status: _parseStatus(data['status'] as String?),
      title: data['title'] as String? ?? 'Report',
      description: data['description'] as String? ?? '',
      targetId: data['targetId'] as String?,
      targetType: data['targetType'] as String?,
      reporterId: data['reporterId'] as String?,
      reporterContact: data['reporterContact'] as String?,
      createdAt: _toDateTime(data['createdAt']),
      reviewedBy: data['reviewedBy'] as String?,
      reviewedAt: _toDateTime(data['reviewedAt']),
      resolutionNote: data['resolutionNote'] as String?,
      chatSnapshot: data['chatSnapshot'] is Map
          ? Map<String, dynamic>.from(data['chatSnapshot'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type.name,
        'status': status.name,
        'title': title,
        'description': description,
        if (targetId != null) 'targetId': targetId,
        if (targetType != null) 'targetType': targetType,
        if (reporterId != null) 'reporterId': reporterId,
        if (reporterContact != null) 'reporterContact': reporterContact,
        'createdAt': FieldValue.serverTimestamp(),
        if (chatSnapshot != null) 'chatSnapshot': chatSnapshot,
      };

  static AdminReportType _parseType(String? value) {
    return AdminReportType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AdminReportType.other,
    );
  }

  static AdminReportStatus _parseStatus(String? value) {
    return AdminReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AdminReportStatus.open,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
