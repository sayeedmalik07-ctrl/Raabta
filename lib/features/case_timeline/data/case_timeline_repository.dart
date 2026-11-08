import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';

/// Shared `case_timeline_entries` collection — all Truth Engines.
class CaseTimelineRepository {
  CaseTimelineRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const collectionName = 'case_timeline_entries';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionName);

  Future<CaseTimelineEntry> upsert(CaseTimelineEntry draft) async {
    if (draft.title.trim().isEmpty) {
      throw ArgumentError.value(draft.title, 'title', 'Title is required');
    }
    if (draft.userId.isEmpty) {
      throw ArgumentError.value(draft.userId, 'userId', 'userId is required');
    }
    if (draft.caseId.isEmpty) {
      throw ArgumentError.value(draft.caseId, 'caseId', 'caseId is required');
    }

    final ref = draft.entryId.isNotEmpty
        ? _collection.doc(draft.entryId)
        : _collection.doc();
    final now = DateTime.now();
    final entry = draft.copyWith(
      entryId: ref.id,
      createdAt: draft.entryId.isEmpty ? now : draft.createdAt,
      updatedAt: now,
    );

    await ref.set(entry.toJson(), SetOptions(merge: true));
    return entry;
  }

  Future<void> delete(String entryId) async {
    if (entryId.isEmpty) return;
    await _collection.doc(entryId).delete();
  }

  Future<List<CaseTimelineEntry>> listForCase({
    required String userId,
    required CaseTimelineEngineType engineType,
    required String caseId,
  }) async {
    if (userId.isEmpty || caseId.isEmpty) return const [];

    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('engineType', isEqualTo: engineType.storageValue)
        .where('caseId', isEqualTo: caseId)
        .orderBy('entryDate', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => CaseTimelineEntry.fromJson({...doc.data(), 'entryId': doc.id}))
        .toList();
  }

  Stream<List<CaseTimelineEntry>> watchForCase({
    required String userId,
    required CaseTimelineEngineType engineType,
    required String caseId,
  }) {
    if (userId.isEmpty || caseId.isEmpty) {
      return Stream.value(const []);
    }

    return _collection
        .where('userId', isEqualTo: userId)
        .where('engineType', isEqualTo: engineType.storageValue)
        .where('caseId', isEqualTo: caseId)
        .orderBy('entryDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CaseTimelineEntry.fromJson({
                  ...doc.data(),
                  'entryId': doc.id,
                }),
              )
              .toList(),
        );
  }
}
