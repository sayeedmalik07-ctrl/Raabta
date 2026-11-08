import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';

/// Append-only evidence trail storage under existing `users/{uid}` scope.
///
/// No update/delete APIs — amendments create a new document (see [EvidenceService]).
class EvidenceRepository {
  EvidenceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const collectionName = 'evidence_entries';

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection(collectionName);

  /// Creates a new immutable entry. Returns the persisted row with its Firestore id.
  Future<EvidenceEntry> append(EvidenceEntry draft) async {
    if (draft.note.trim().isEmpty) {
      throw ArgumentError.value(draft.note, 'note', 'Evidence note is required');
    }
    if (!EvidenceClaimTypes.isValid(draft.claimType)) {
      throw ArgumentError.value(
        draft.claimType,
        'claimType',
        'Unknown evidence claim type',
      );
    }

    final ref = draft.id.isNotEmpty ? _collection(draft.userId).doc(draft.id) : _collection(draft.userId).doc();
    final createdAt = draft.createdAt;
    final entry = draft.copyWith(id: ref.id, createdAt: createdAt);

    await ref.set(entry.toJson());
    return entry;
  }

  Future<List<EvidenceEntry>> listAll(String uid) async {
    if (uid.isEmpty) return const [];

    final snapshot = await _collection(uid)
        .orderBy('entryDate', descending: false)
        .get();

    return snapshot.docs
        .map(
          (doc) => EvidenceEntry.fromJson({...doc.data(), 'id': doc.id}),
        )
        .toList();
  }

  Stream<List<EvidenceEntry>> watchAll(String uid) {
    if (uid.isEmpty) return Stream.value(const []);

    return _collection(uid)
        .orderBy('entryDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EvidenceEntry.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }
}
