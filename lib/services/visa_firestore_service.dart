import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/services/firebase_service.dart';

class VisaFirestoreService {
  VisaFirestoreService({FirebaseFirestore? firestore})
      : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null;

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>>? get _guidesRef {
    if (_firestore == null) return null;
    return _firestore.collection('visa_guides');
  }

  Future<VisaGuide> fetchGuide({
    required String categoryId,
    required String language,
  }) async {
    final ref = _guidesRef;
    if (ref == null) {
      throw VisaFirestoreException('Firestore not initialized');
    }

    final doc = await ref.doc(categoryId).get();
    if (!doc.exists) {
      final query = await ref
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw VisaFirestoreException('Guide not found');
      }
      return VisaGuide.fromJson(
        {...query.docs.first.data(), 'id': query.docs.first.id},
        language,
      );
    }

    return VisaGuide.fromJson({...doc.data()!, 'id': doc.id}, language);
  }

  Stream<VisaGuide?> watchGuide({
    required String categoryId,
    required String language,
  }) {
    final ref = _guidesRef;
    if (ref == null) return Stream.value(null);

    return ref.doc(categoryId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return VisaGuide.fromJson({...doc.data()!, 'id': doc.id}, language);
    });
  }
}

class VisaFirestoreException implements Exception {
  VisaFirestoreException(this.message);
  final String message;

  @override
  String toString() => message;
}
