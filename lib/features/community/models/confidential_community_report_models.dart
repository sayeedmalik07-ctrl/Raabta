import 'package:cloud_firestore/cloud_firestore.dart';

/// Who may read the reporter identity mapping (Part E).
enum ConfidentialReportVisibility {
  /// Moderators/admins review content; identity mapping admin-only.
  moderators('moderators'),

  /// Explicit safety-team visibility flag on the identity doc (admin-gated).
  safetyTeam('safety_team');

  const ConfidentialReportVisibility(this.firestoreValue);
  final String firestoreValue;

  static ConfidentialReportVisibility parse(String? value) {
    return ConfidentialReportVisibility.values.firstWhere(
      (v) => v.firestoreValue == value,
      orElse: () => ConfidentialReportVisibility.moderators,
    );
  }
}

enum ConfidentialReportCategory {
  harassment('harassment'),
  safety('safety'),
  fraud('fraud'),
  discrimination('discrimination'),
  other('other');

  const ConfidentialReportCategory(this.firestoreValue);
  final String firestoreValue;

  static ConfidentialReportCategory parse(String? value) {
    return ConfidentialReportCategory.values.firstWhere(
      (v) => v.firestoreValue == value,
      orElse: () => ConfidentialReportCategory.other,
    );
  }
}

enum ConfidentialReportStatus {
  submitted('submitted'),
  reviewing('reviewing'),
  resolved('resolved'),
  dismissed('dismissed');

  const ConfidentialReportStatus(this.firestoreValue);
  final String firestoreValue;

  static ConfidentialReportStatus parse(String? value) {
    return ConfidentialReportStatus.values.firstWhere(
      (v) => v.firestoreValue == value,
      orElse: () => ConfidentialReportStatus.submitted,
    );
  }
}

/// Public / moderator-visible report content — **never** stores reporter UID.
class ConfidentialCommunityReport {
  const ConfidentialCommunityReport({
    required this.id,
    required this.category,
    required this.description,
    required this.status,
    required this.visibilityScope,
    this.contextType,
    this.contextRef,
    this.relevantGroupIds = const [],
    this.createdAt,
  });

  final String id;
  final ConfidentialReportCategory category;
  final String description;
  final ConfidentialReportStatus status;
  final ConfidentialReportVisibility visibilityScope;
  final String? contextType;
  final String? contextRef;
  final List<String> relevantGroupIds;
  final DateTime? createdAt;

  /// Fields that must never appear on the public content document.
  static const forbiddenIdentityFields = {
    'userId',
    'reporterUid',
    'createdBy',
    'reporterId',
    'reporterContact',
  };

  factory ConfidentialCommunityReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ConfidentialCommunityReport(
      id: doc.id,
      category: ConfidentialReportCategory.parse(data['category'] as String?),
      description: data['description'] as String? ?? '',
      status: ConfidentialReportStatus.parse(data['status'] as String?),
      visibilityScope: ConfidentialReportVisibility.parse(
        data['visibilityScope'] as String?,
      ),
      contextType: data['contextType'] as String?,
      contextRef: data['contextRef'] as String?,
      relevantGroupIds: List<String>.from(
        data['relevantGroupIds'] as List? ?? const [],
      ),
      createdAt: _toDate(data['createdAt']),
    );
  }

  static Map<String, dynamic> contentPayload({
    required ConfidentialReportCategory category,
    required String description,
    ConfidentialReportVisibility visibility =
        ConfidentialReportVisibility.moderators,
    String? contextType,
    String? contextRef,
    List<String> relevantGroupIds = const [],
  }) {
    final payload = <String, dynamic>{
      'category': category.firestoreValue,
      'description': description.trim(),
      'status': ConfidentialReportStatus.submitted.firestoreValue,
      'visibilityScope': visibility.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
      if (contextType != null && contextType.isNotEmpty)
        'contextType': contextType,
      if (contextRef != null && contextRef.isNotEmpty) 'contextRef': contextRef,
      if (relevantGroupIds.isNotEmpty) 'relevantGroupIds': relevantGroupIds,
    };

    for (final key in forbiddenIdentityFields) {
      assert(!payload.containsKey(key));
    }
    return payload;
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Restricted identity mapping — linked by opaque [reportId], admin read only.
class ConfidentialCommunityReportIdentity {
  const ConfidentialCommunityReportIdentity({
    required this.reportId,
    required this.reporterUid,
    required this.visibilityScope,
    this.createdAt,
  });

  final String reportId;
  final String reporterUid;
  final ConfidentialReportVisibility visibilityScope;
  final DateTime? createdAt;

  factory ConfidentialCommunityReportIdentity.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ConfidentialCommunityReportIdentity(
      reportId: data['reportId'] as String? ?? doc.id,
      reporterUid: data['reporterUid'] as String? ?? '',
      visibilityScope: ConfidentialReportVisibility.parse(
        data['visibilityScope'] as String?,
      ),
      createdAt: ConfidentialCommunityReport._toDate(data['createdAt']),
    );
  }

  static Map<String, dynamic> identityPayload({
    required String reportId,
    required String reporterUid,
    ConfidentialReportVisibility visibility =
        ConfidentialReportVisibility.moderators,
  }) {
    return {
      'reportId': reportId,
      'reporterUid': reporterUid,
      'visibilityScope': visibility.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
