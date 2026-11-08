import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';

/// Chronological case event linked to a Truth Engine case record.
class CaseTimelineEntry {
  const CaseTimelineEntry({
    required this.entryId,
    required this.userId,
    required this.engineType,
    required this.caseId,
    required this.entryDate,
    required this.entryType,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.linkedDocumentRef,
    this.checklistItemId,
  });

  final String entryId;
  final String userId;
  final CaseTimelineEngineType engineType;
  final String caseId;

  /// When the event happened (not when logged).
  final DateTime entryDate;
  final CaseTimelineEntryType entryType;
  final String title;
  final String? description;

  /// Pointer to `scanned_documents/{id}` — no duplicate storage.
  final String? linkedDocumentRef;

  /// When set, satisfies gap detection for this checklist item id.
  final String? checklistItemId;

  final DateTime createdAt;
  final DateTime updatedAt;

  CaseTimelineEntry copyWith({
    String? entryId,
    String? userId,
    CaseTimelineEngineType? engineType,
    String? caseId,
    DateTime? entryDate,
    CaseTimelineEntryType? entryType,
    String? title,
    String? description,
    String? linkedDocumentRef,
    String? checklistItemId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearLinkedDocumentRef = false,
    bool clearChecklistItemId = false,
  }) {
    return CaseTimelineEntry(
      entryId: entryId ?? this.entryId,
      userId: userId ?? this.userId,
      engineType: engineType ?? this.engineType,
      caseId: caseId ?? this.caseId,
      entryDate: entryDate ?? this.entryDate,
      entryType: entryType ?? this.entryType,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      linkedDocumentRef: clearLinkedDocumentRef
          ? null
          : (linkedDocumentRef ?? this.linkedDocumentRef),
      checklistItemId: clearChecklistItemId
          ? null
          : (checklistItemId ?? this.checklistItemId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'entryId': entryId,
        'userId': userId,
        'engineType': engineType.storageValue,
        'caseId': caseId,
        'entryDate': entryDate.toIso8601String(),
        'entryType': entryType.storageValue,
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (linkedDocumentRef != null) 'linkedDocumentRef': linkedDocumentRef,
        if (checklistItemId != null) 'checklistItemId': checklistItemId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CaseTimelineEntry.fromJson(Map<String, dynamic> json) {
    final engine = CaseTimelineEngineTypeX.fromStorage(
          json['engineType'] as String?,
        ) ??
        CaseTimelineEngineType.eosb;
    final entryType = CaseTimelineEntryTypeX.fromStorage(
          json['entryType'] as String?,
        ) ??
        CaseTimelineEntryType.note;

    return CaseTimelineEntry(
      entryId: json['entryId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      engineType: engine,
      caseId: json['caseId'] as String? ?? '',
      entryDate: DateTime.tryParse(json['entryDate'] as String? ?? '') ??
          DateTime.now(),
      entryType: entryType,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      linkedDocumentRef: json['linkedDocumentRef'] as String?,
      checklistItemId: json['checklistItemId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
