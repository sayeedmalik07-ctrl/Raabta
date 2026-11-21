import 'package:raabta/features/case_timeline/data/case_timeline_repository.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_gap_analyzer.dart';

class CaseTimelineService {
  CaseTimelineService({CaseTimelineRepository? repository})
      : _repository = repository ?? CaseTimelineRepository();

  final CaseTimelineRepository _repository;

  Future<CaseTimelineEntry> addEntry({
    required String userId,
    required CaseTimelineEngineType engineType,
    required String caseId,
    required DateTime entryDate,
    required CaseTimelineEntryType entryType,
    required String title,
    String? description,
    String? linkedDocumentRef,
    String? checklistItemId,
  }) {
    final now = DateTime.now();
    return _repository.upsert(
      CaseTimelineEntry(
        entryId: '',
        userId: userId,
        engineType: engineType,
        caseId: caseId,
        entryDate: entryDate,
        entryType: entryType,
        title: title.trim(),
        description: description?.trim(),
        linkedDocumentRef: linkedDocumentRef,
        checklistItemId: checklistItemId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<CaseTimelineEntry> addMilestoneFromStep({
    required String userId,
    required CaseTimelineEngineType engineType,
    required String caseId,
    required DateTime entryDate,
    required String title,
    required String checklistItemId,
  }) {
    return addEntry(
      userId: userId,
      engineType: engineType,
      caseId: caseId,
      entryDate: entryDate,
      entryType: CaseTimelineEntryType.milestone,
      title: title,
      checklistItemId: checklistItemId,
    );
  }

  Future<void> deleteEntry(String entryId) => _repository.delete(entryId);

  Future<List<CaseTimelineEntry>> listForCase({
    required String userId,
    required CaseTimelineEngineType engineType,
    required String caseId,
  }) =>
      _repository.listForCase(
        userId: userId,
        engineType: engineType,
        caseId: caseId,
      );

  Stream<List<CaseTimelineEntry>> watchForCase({
    required String userId,
    required CaseTimelineEngineType engineType,
    required String caseId,
  }) =>
      _repository.watchForCase(
        userId: userId,
        engineType: engineType,
        caseId: caseId,
      );

  static List<CaseTimelineEntry> sortedChronologically(
    List<CaseTimelineEntry> entries,
  ) {
    final copy = [...entries];
    copy.sort((a, b) {
      final byDate = a.entryDate.compareTo(b.entryDate);
      if (byDate != 0) return byDate;
      return a.createdAt.compareTo(b.createdAt);
    });
    return copy;
  }

  static Set<String> coveredChecklistIds(List<CaseTimelineEntry> entries) =>
      CaseTimelineGapAnalyzer.coveredChecklistIds(entries);
}
