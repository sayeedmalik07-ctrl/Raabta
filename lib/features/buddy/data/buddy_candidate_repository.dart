import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/buddy/data/buddy_profile_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';
import 'package:raabta/services/firebase_service.dart';

class BuddyCandidateRepository {
  BuddyCandidateRepository({FirebaseFirestore? firestore})
      : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _db;

  Future<List<BuddyProfile>> fetchHelperCandidates({
    required String nationalityCountryId,
  }) async {
    if (_db == null || nationalityCountryId.isEmpty) return const [];

    final snap = await _db
        .collection(BuddyProfileRepository.collection)
        .where('isHelper', isEqualTo: true)
        .where('paused', isEqualTo: false)
        .where('nationalityCountryId', isEqualTo: nationalityCountryId)
        .limit(BuddyConstants.candidateQueryLimit)
        .get();

    return snap.docs
        .map((d) => BuddyProfile.fromFirestore(d.id, d.data()))
        .toList();
  }
}
