import 'package:firebase_auth/firebase_auth.dart';

/// True when the signed-in user owns this listing (Firestore `ownerUserId` / `userId`).
bool isListingOwnedByCurrentUser(String? ownerUserId) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || ownerUserId == null || ownerUserId.isEmpty) return false;
  return uid == ownerUserId;
}
