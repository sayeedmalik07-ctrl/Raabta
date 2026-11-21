import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/community/models/confidential_community_report_models.dart';
import 'package:raabta/features/community/services/community_repository.dart';
import 'package:raabta/services/firebase_service.dart';

/// Split-collection confidential report submission (Part E).
///
/// Public content lives in [contentCollection]; reporter UID lives only in
/// [identityCollection]. No full submission UI — composers call [submit] when wired.
abstract final class ConfidentialCommunityReportCollections {
  static const contentCollection = 'confidential_community_reports';
  static const identityCollection = 'confidential_community_report_identities';
}

class ConfidentialCommunityReportService {
  ConfidentialCommunityReportService({
    FirebaseFirestore? firestore,
    CommunityRepository? communityRepository,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _communityRepository = communityRepository ?? CommunityRepository();

  final FirebaseFirestore _db;
  final CommunityRepository _communityRepository;

  static const minDescriptionLength = 20;

  /// Atomically writes content + identity mapping with the same opaque report ID.
  Future<String> submit({
    required ConfidentialReportCategory category,
    required String description,
    ConfidentialReportVisibility visibility =
        ConfidentialReportVisibility.moderators,
    String? contextType,
    String? contextRef,
    List<String> relevantGroupIds = const [],
  }) async {
    if (!FirebaseService.isReady) {
      throw StateError('Firebase is not initialized');
    }

    final trimmed = description.trim();
    if (trimmed.length < minDescriptionLength) {
      throw ArgumentError(
        'Description must be at least $minDescriptionLength characters.',
      );
    }

    final reporterUid = await _communityRepository.currentUserId();
    final contentRef =
        _db.collection(ConfidentialCommunityReportCollections.contentCollection)
            .doc();
    final reportId = contentRef.id;

    final batch = _db.batch();
    batch.set(
      contentRef,
      ConfidentialCommunityReport.contentPayload(
        category: category,
        description: trimmed,
        visibility: visibility,
        contextType: contextType,
        contextRef: contextRef,
        relevantGroupIds: relevantGroupIds,
      ),
    );
    batch.set(
      _db
          .collection(
            ConfidentialCommunityReportCollections.identityCollection,
          )
          .doc(reportId),
      ConfidentialCommunityReportIdentity.identityPayload(
        reportId: reportId,
        reporterUid: reporterUid,
        visibility: visibility,
      ),
    );
    await batch.commit();
    return reportId;
  }

  /// Moderator-facing content list — identity fields are never returned here.
  Future<List<ConfidentialCommunityReport>> fetchReportsForModeration({
    int limit = 50,
  }) async {
    if (!FirebaseService.isReady) return [];
    final snap = await _db
        .collection(ConfidentialCommunityReportCollections.contentCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(ConfidentialCommunityReport.fromFirestore).toList();
  }

  /// Admin/safety-team identity lookup — separate restricted read path.
  Future<ConfidentialCommunityReportIdentity?> fetchReporterIdentity(
    String reportId,
  ) async {
    if (!FirebaseService.isReady) return null;
    final snap = await _db
        .collection(ConfidentialCommunityReportCollections.identityCollection)
        .doc(reportId)
        .get();
    if (!snap.exists) return null;
    return ConfidentialCommunityReportIdentity.fromFirestore(snap);
  }
}
