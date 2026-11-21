import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/firebase_service.dart';

/// Live Firestore profile for the signed-in user (`users/{uid}`).
final signedInUserFirestoreProfileProvider =
    StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null || uid.isEmpty || !FirebaseService.isReady) {
    return Stream.value(null);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) => snap.data());
});
