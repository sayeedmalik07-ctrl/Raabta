import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';
import 'package:raabta/services/firebase_service.dart';

class BuddyProfileRepository {
  BuddyProfileRepository({FirebaseFirestore? firestore})
      : _db = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _db;

  static const collection = 'buddy_profiles';

  DocumentReference<Map<String, dynamic>>? _doc(String uid) {
    if (_db == null || uid.isEmpty) return null;
    return _db.collection(collection).doc(uid);
  }

  Future<BuddyProfile?> fetch(String uid) async {
    final ref = _doc(uid);
    if (ref == null) return null;
    final snap = await ref.get();
    if (!snap.exists || snap.data() == null) return null;
    return BuddyProfile.fromFirestore(snap.id, snap.data()!);
  }

  Future<void> save(BuddyProfile profile, {required bool isCreate}) async {
    final ref = _doc(profile.uid);
    if (ref == null) {
      throw StateError('Firebase unavailable');
    }
    final payload = profile.toFirestore(isCreate: isCreate);
    if (isCreate) {
      await ref.set(payload);
    } else {
      final updatePayload = Map<String, dynamic>.from(payload)
        ..remove('optInAt');
      await ref.update(updatePayload);
    }
  }

  Future<void> delete(String uid) async {
    final ref = _doc(uid);
    if (ref == null) return;
    await ref.delete();
  }
}
