import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/data/models/job_application_chat_message.dart';
import 'package:raabta/services/firebase_service.dart';

class JobApplicationChatRepository {
  JobApplicationChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance,
        _usesDefaultFirestore = firestore == null;

  final FirebaseFirestore _db;
  final bool _usesDefaultFirestore;

  bool get _firebaseUnavailable =>
      _usesDefaultFirestore && !FirebaseService.isReady;

  CollectionReference<Map<String, dynamic>>? _messagesRef(
    String jobId,
    String applicantUid,
  ) {
    if (_firebaseUnavailable) return null;
    return _db
        .collection('jobs')
        .doc(jobId)
        .collection('application_chats')
        .doc(applicantUid)
        .collection('messages');
  }

  Stream<List<JobApplicationChatMessage>> watchMessages({
    required String jobId,
    required String applicantUid,
  }) {
    final ref = _messagesRef(jobId, applicantUid);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: false).snapshots().map(
          (snap) => snap.docs
              .map((doc) =>
                  JobApplicationChatMessage.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> sendStatusSystemMessage({
    required String jobId,
    required String applicantUid,
    required String statusKey,
  }) async {
    final ref = _messagesRef(jobId, applicantUid);
    final uid = _usesDefaultFirestore
        ? FirebaseAuth.instance.currentUser?.uid
        : 'test-user';
    if (ref == null || uid == null) return;

    final doc = ref.doc();
    await doc.set(
      JobApplicationChatMessage(
        id: doc.id,
        jobId: jobId,
        applicantUid: applicantUid,
        senderId: uid,
        createdAt: DateTime.now(),
        messageKind: 'application_system',
        applicationStatusKey: statusKey,
      ).toJson(),
    );
  }
}
