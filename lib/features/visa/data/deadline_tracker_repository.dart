import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/models/visa_models.dart';

/// Firestore persistence for Visa & Documents Deadline Tracker.
class DeadlineTrackerRepository {
  DeadlineTrackerRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const collection = 'deadline_tracker';
  static const limit = 50;

  Stream<List<DocumentDeadline>> watchDeadlines(String userId) {
    return Stream<List<DocumentDeadline>>.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;

      void attach(Stream<QuerySnapshot<Map<String, dynamic>>> stream) {
        sub?.cancel();
        sub = stream.listen(
          (snapshot) => controller.add(_mapDocs(snapshot.docs)),
          onError: (Object error, StackTrace stack) {
            if (_isMissingIndexError(error)) {
              attach(_fallbackQuery(userId).snapshots());
              return;
            }
            controller.addError(error, stack);
          },
        );
      }

      attach(_indexedQuery(userId).snapshots());
      controller.onCancel = () => sub?.cancel();
    });
  }

  Query<Map<String, dynamic>> _indexedQuery(String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('expiryDate')
        .limit(limit);
  }

  Query<Map<String, dynamic>> _fallbackQuery(String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .limit(limit);
  }

  List<DocumentDeadline> _mapDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final items = docs.map((doc) => DocumentDeadline.fromFirestore(doc)).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return items;
  }

  Future<String> add({
    required String userId,
    required DocumentDeadline deadline,
  }) async {
    final data = deadline.toFirestore(userId: userId);
    if (deadline.id.isNotEmpty) {
      await _db.collection(collection).doc(deadline.id).set(data);
      return deadline.id;
    }
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> fields) async {
    await _db.collection(collection).doc(id).update(fields);
  }

  Future<void> delete(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  bool _isMissingIndexError(Object error) {
    final msg = error.toString();
    return msg.contains('failed-precondition') || msg.contains('requires an index');
  }
}
