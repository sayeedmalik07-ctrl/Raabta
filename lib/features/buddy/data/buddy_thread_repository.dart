import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/buddy/data/buddy_request_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/models/buddy_thread.dart';
import 'package:raabta/services/firebase_service.dart';

class BuddyThreadRepository {
  BuddyThreadRepository({FirebaseFirestore? firestore})
      : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _db;

  CollectionReference<Map<String, dynamic>>? get _threads =>
      _db?.collection(BuddyRequestRepository.threadsCollection);

  Future<BuddyThread?> fetchForParticipant({
    required String threadId,
    required String uid,
  }) async {
    final col = _threads;
    if (col == null) return null;
    final snap = await col.doc(threadId).get();
    if (!snap.exists || snap.data() == null) return null;
    final thread = BuddyThread.fromFirestore(snap.id, snap.data()!);
    if (!thread.participantUids.contains(uid)) return null;
    return thread;
  }

  Future<List<BuddyThread>> fetchActiveForUser(String uid) async {
    final col = _threads;
    if (col == null) return const [];

    final helperSnap = await col
        .where('helperUid', isEqualTo: uid)
        .where('status', isEqualTo: BuddyConstants.threadStatusActive)
        .limit(20)
        .get();
    final newcomerSnap = await col
        .where('newcomerUid', isEqualTo: uid)
        .where('status', isEqualTo: BuddyConstants.threadStatusActive)
        .limit(20)
        .get();

    final byId = <String, BuddyThread>{};
    for (final doc in [...helperSnap.docs, ...newcomerSnap.docs]) {
      byId[doc.id] = BuddyThread.fromFirestore(doc.id, doc.data());
    }
    final threads = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return threads;
  }
}
