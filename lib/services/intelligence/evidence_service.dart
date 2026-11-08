import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/services/intelligence/evidence_attachment_service.dart';
import 'package:raabta/services/intelligence/evidence_repository.dart';

/// Business rules for the labour evidence trail — append-only, zero AI.
class EvidenceService {
  EvidenceService({EvidenceRepository? repository})
      : _repository = repository ?? EvidenceRepository();

  final EvidenceRepository _repository;

  Future<EvidenceEntry> recordEntry({
    required String userId,
    required DateTime entryDate,
    required String note,
    required String claimType,
    String? attachmentDocumentId,
    EvidencePhotoAttachment? attachment,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    return _repository.append(
      EvidenceEntry(
        id: '',
        userId: userId,
        entryDate: entryDate,
        note: note.trim(),
        claimType: claimType,
        attachmentDocumentId:
            attachment?.documentId ?? attachmentDocumentId,
        attachmentCaptureSource: attachment?.captureSourceValue,
        attachmentCapturedAt: attachment?.capturedAt,
        attachmentCapturedLatitude: attachment?.capturedLatitude,
        attachmentCapturedLongitude: attachment?.capturedLongitude,
        attachmentUploadedAt: attachment?.uploadedAt,
        createdAt: clock,
      ),
    );
  }

  /// "Edit" by convention: creates a new entry referencing [original.id].
  Future<EvidenceEntry> supplementEntry({
    required EvidenceEntry original,
    required DateTime entryDate,
    required String note,
    String? claimType,
    String? attachmentDocumentId,
    EvidencePhotoAttachment? attachment,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    return _repository.append(
      EvidenceEntry(
        id: '',
        userId: original.userId,
        entryDate: entryDate,
        note: note.trim(),
        claimType: claimType ?? original.claimType,
        attachmentDocumentId:
            attachment?.documentId ?? attachmentDocumentId ?? original.attachmentDocumentId,
        attachmentCaptureSource:
            attachment?.captureSourceValue ?? original.attachmentCaptureSource,
        attachmentCapturedAt: attachment?.capturedAt ?? original.attachmentCapturedAt,
        attachmentCapturedLatitude:
            attachment?.capturedLatitude ?? original.attachmentCapturedLatitude,
        attachmentCapturedLongitude:
            attachment?.capturedLongitude ?? original.attachmentCapturedLongitude,
        attachmentUploadedAt: attachment?.uploadedAt ?? original.attachmentUploadedAt,
        createdAt: clock,
        supersedesEntryId: original.id,
      ),
    );
  }

  Future<List<EvidenceEntry>> listEntries(String userId) =>
      _repository.listAll(userId);

  Stream<List<EvidenceEntry>> watchEntries(String userId) =>
      _repository.watchAll(userId);

  /// Chronological order for export (oldest incident first).
  static List<EvidenceEntry> sortedForExport(List<EvidenceEntry> entries) {
    final copy = [...entries];
    copy.sort((a, b) {
      final byDate = a.entryDate.compareTo(b.entryDate);
      if (byDate != 0) return byDate;
      return a.createdAt.compareTo(b.createdAt);
    });
    return copy;
  }
}
