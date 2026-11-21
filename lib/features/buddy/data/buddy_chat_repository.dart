import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/buddy/data/buddy_request_repository.dart';
import 'package:raabta/features/buddy/data/buddy_thread_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_chat_message.dart';
import 'package:raabta/features/buddy/domain/buddy_thread_peers.dart';
import 'package:raabta/services/firebase_service.dart';

class BuddyChatRepository {
  BuddyChatRepository({
    FirebaseFirestore? firestore,
    BuddyThreadRepository? threads,
  })  : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _threads = threads ?? BuddyThreadRepository(firestore: firestore);

  final FirebaseFirestore? _firestore;
  final BuddyThreadRepository _threads;

  CollectionReference<Map<String, dynamic>>? _messagesRef(String threadId) {
    if (_firestore == null) return null;
    return _firestore
        .collection(BuddyRequestRepository.threadsCollection)
        .doc(threadId)
        .collection('messages');
  }

  Stream<List<BuddyChatMessage>> watchMessages(String threadId) {
    final ref = _messagesRef(threadId);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs
              .map((doc) => BuddyChatMessage.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<BuddyChatMessage?> sendMessage({
    required String threadId,
    required String text,
  }) async {
    final ref = _messagesRef(threadId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (ref == null || uid == null) return null;

    final thread = await _threads.fetchForParticipant(
      threadId: threadId,
      uid: uid,
    );
    if (thread == null || !thread.isActive) return null;

    final peerUid = BuddyThreadPeers.peerUidForParticipant(
      thread: thread,
      myUid: uid,
    );
    if (peerUid == null || peerUid.isEmpty) return null;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final doc = ref.doc();
    final message = BuddyChatMessage(
      id: doc.id,
      threadId: threadId,
      senderId: uid,
      text: trimmed,
      createdAt: DateTime.now(),
      peerUid: peerUid,
    );

    await doc.set(message.toJson());
    return message;
  }
}
