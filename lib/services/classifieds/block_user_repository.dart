import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/services/firebase_service.dart';

class BlockedUserEntry {
  const BlockedUserEntry({
    required this.blockedUid,
    required this.createdAt,
  });

  final String blockedUid;
  final DateTime? createdAt;
}

class BlockUserRepository {
  BlockUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  static const subcollection = 'blocked_users';

  CollectionReference<Map<String, dynamic>>? _blockedRef(String uid) {
    if (_firestore == null) return null;
    return _firestore.collection('users').doc(uid).collection(subcollection);
  }

  Stream<Set<String>> watchBlockedUserIds({String? uid}) {
    final resolved = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolved == null || resolved.isEmpty) {
      return Stream.value(<String>{});
    }
    final ref = _blockedRef(resolved);
    if (ref == null) return Stream.value(<String>{});

    return ref.snapshots().map(
          (snap) => snap.docs.map((d) => d.id).toSet(),
        );
  }

  Stream<List<BlockedUserEntry>> watchBlockedUsers({String? uid}) {
    final resolved = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolved == null || resolved.isEmpty) {
      return Stream.value(const []);
    }
    final ref = _blockedRef(resolved);
    if (ref == null) return Stream.value(const []);

    return ref.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map(
                (d) => BlockedUserEntry(
                  blockedUid: d.id,
                  createdAt: (d.data()['createdAt'] as Timestamp?)?.toDate(),
                ),
              )
              .toList(),
        );
  }

  Future<Set<String>> fetchBlockedUserIds({String? uid}) async {
    final resolved = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolved == null || resolved.isEmpty) return {};
    final ref = _blockedRef(resolved);
    if (ref == null) return {};
    final snap = await ref.get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<void> blockUser(String blockedUid, {String? uid}) async {
    final resolved = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolved == null || blockedUid.isEmpty || blockedUid == resolved) {
      return;
    }
    final ref = _blockedRef(resolved);
    if (ref == null) return;

    await ref.doc(blockedUid).set({
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblockUser(String blockedUid, {String? uid}) async {
    final resolved = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolved == null || blockedUid.isEmpty) return;
    final ref = _blockedRef(resolved);
    if (ref == null) return;
    await ref.doc(blockedUid).delete();
  }
}
