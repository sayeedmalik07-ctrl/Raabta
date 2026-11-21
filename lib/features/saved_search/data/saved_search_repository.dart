import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/saved_search/domain/saved_search.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/services/firebase_service.dart';

class SavedSearchRepository {
  SavedSearchRepository({FirebaseFirestore? firestore})
      : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _db;

  static const collection = 'saved_searches';

  CollectionReference<Map<String, dynamic>>? _userCollection(String uid) {
    if (_db == null || uid.isEmpty) return null;
    return _db.collection('users').doc(uid).collection(collection);
  }

  Stream<List<SavedSearch>> watchUserSavedSearches(String uid) {
    final col = _userCollection(uid);
    if (col == null) return Stream.value(const []);

    return col.orderBy('updatedAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((doc) => SavedSearch.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<SavedSearch>> watchUserSavedSearchesForVertical(
    String uid,
    SavedSearchVertical vertical,
  ) {
    return watchUserSavedSearches(uid).map(
      (searches) =>
          searches.where((search) => search.vertical == vertical).toList(),
    );
  }

  Future<SavedSearch?> create({
    required String uid,
    required SavedSearchVertical vertical,
    required String name,
    required SavedSearchCriteria criteria,
  }) async {
    final col = _userCollection(uid);
    if (col == null) return null;

    final now = DateTime.now();
    final doc = col.doc();
    final search = SavedSearch(
      id: doc.id,
      userId: uid,
      vertical: vertical,
      name: name.trim(),
      criteria: criteria,
      active: true,
      createdAt: now,
      updatedAt: now,
    );
    await doc.set(search.toFirestore());
    return search;
  }

  Future<void> rename({
    required String uid,
    required String searchId,
    required String name,
  }) async {
    final col = _userCollection(uid);
    if (col == null) return;
    await col.doc(searchId).update({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete({
    required String uid,
    required String searchId,
  }) async {
    final col = _userCollection(uid);
    if (col == null) return;
    await col.doc(searchId).delete();
  }

  Future<void> setActive({
    required String uid,
    required String searchId,
    required bool active,
  }) async {
    final col = _userCollection(uid);
    if (col == null) return;
    await col.doc(searchId).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
