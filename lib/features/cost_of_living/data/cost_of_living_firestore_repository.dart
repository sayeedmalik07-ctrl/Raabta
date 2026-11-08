import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';

/// Firestore fallback when backend API is unavailable — never calls data.gov.qa.
class CostOfLivingFirestoreRepository {
  CostOfLivingFirestoreRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const collection = 'cost_of_living_snapshots';

  Future<CostOfLivingSnapshot?> fetchLatest() async {
    final snap = await _db
        .collection(collection)
        .orderBy('fetched_at', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final data = doc.data();
    final fetchedAt = data['fetched_at'];
    return CostOfLivingSnapshot.fromJson(
      {
        'id': doc.id,
        ...data,
        'fetched_at': fetchedAt is Timestamp
            ? fetchedAt.toDate().toIso8601String()
            : fetchedAt?.toString(),
      },
      isFromCache: true,
    );
  }
}
