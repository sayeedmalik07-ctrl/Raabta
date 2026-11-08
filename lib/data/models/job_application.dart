import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/data/models/job_listing_source.dart';

enum JobApplicationStatus {
  applied,
  underReview,
  contacted,
  closed,
}

extension JobApplicationStatusX on JobApplicationStatus {
  String get storageValue => switch (this) {
        JobApplicationStatus.applied => 'applied',
        JobApplicationStatus.underReview => 'under_review',
        JobApplicationStatus.contacted => 'contacted',
        JobApplicationStatus.closed => 'closed',
      };

  static JobApplicationStatus fromStored(String? raw) {
    return switch (raw) {
      'under_review' => JobApplicationStatus.underReview,
      'contacted' => JobApplicationStatus.contacted,
      'closed' => JobApplicationStatus.closed,
      'submitted' => JobApplicationStatus.applied,
      _ => JobApplicationStatus.applied,
    };
  }

  String labelKey() => switch (this) {
        JobApplicationStatus.applied => 'jobs_app_status_applied',
        JobApplicationStatus.underReview => 'jobs_app_status_under_review',
        JobApplicationStatus.contacted => 'jobs_app_status_contacted',
        JobApplicationStatus.closed => 'jobs_app_status_closed',
      };
}

class JobApplication {
  /// Deterministic Firestore doc ID: `{jobId}_{applicantUid}`.
  /// Enables server-side binding of application chats to real applications.
  static String deterministicDocId(String jobId, String applicantUid) =>
      '${jobId}_$applicantUid';

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.applicantUid,
    required this.status,
    required this.listingSource,
    required this.createdAt,
    this.updatedAt,
    this.cvVaultDocumentId,
    this.cvDocumentId,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String applicantUid;
  final JobApplicationStatus status;
  final JobListingSource listingSource;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cvVaultDocumentId;
  final String? cvDocumentId;

  bool get isNativeTracked => listingSource.supportsApplicationTracking;

  Map<String, dynamic> toFirestore() => {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'company': company,
        'applicantUid': applicantUid,
        'status': status.storageValue,
        'listingSource': listingSource.storageValue,
        if (cvVaultDocumentId != null) 'cvVaultDocumentId': cvVaultDocumentId,
        if (cvDocumentId != null) 'cvDocumentId': cvDocumentId,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory JobApplication.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return JobApplication(
      id: doc.id,
      jobId: data['jobId'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      company: data['company'] as String? ?? '',
      applicantUid: data['applicantUid'] as String? ?? '',
      status: JobApplicationStatusX.fromStored(data['status'] as String?),
      listingSource: JobListingSource.fromStored(
        data['listingSource'] as String?,
      ),
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDateOrNull(data['updatedAt']),
      cvVaultDocumentId: data['cvVaultDocumentId'] as String?,
      cvDocumentId: data['cvDocumentId'] as String?,
    );
  }

  static DateTime _readDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _readDateOrNull(dynamic raw) {
    if (raw == null) return null;
    return _readDate(raw);
  }
}
