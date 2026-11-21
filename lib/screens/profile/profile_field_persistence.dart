import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';

/// Shared persistence for approved profile fields — used by Personal Info and
/// progressive capture. Preserves nationality dual-write semantics.
abstract final class ProfileFieldPersistence {
  ProfileFieldPersistence._();

  static bool canPersist({
    required String uid,
    String? authUid,
    WidgetRef? ref,
  }) {
    final resolved = authUid ?? ref?.read(currentUserProvider)?.uid;
    return resolved != null && resolved == uid;
  }

  static Future<bool> saveProfession(
    WidgetRef ref, {
    required String uid,
    required String value,
    String? authUid,
  }) async {
    if (!canPersist(uid: uid, authUid: authUid, ref: ref)) return false;
    await ref.read(userAIProfileProvider.notifier).updateProfile({
      'profession': value.trim(),
    });
    return true;
  }

  static Future<bool> saveNationality(
    WidgetRef ref, {
    required String uid,
    required String value,
    String? authUid,
    Future<void> Function(String uid, String nationality)? firestoreWriter,
  }) async {
    if (!canPersist(uid: uid, authUid: authUid, ref: ref)) return false;
    final trimmed = value.trim();

    if (firestoreWriter != null) {
      await firestoreWriter(uid, trimmed);
    } else if (FirebaseService.isReady) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'nationality': trimmed,
          'lastActive': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await ref.read(userAIProfileProvider.notifier).updateProfile({
      'nationality': trimmed,
    });
    return true;
  }

  static Future<bool> savePreferredArea(
    WidgetRef ref, {
    required String uid,
    required String value,
    String? authUid,
  }) async {
    if (!canPersist(uid: uid, authUid: authUid, ref: ref)) return false;
    await ref.read(userAIProfileProvider.notifier).updateProfile({
      'preferredArea': value.trim(),
    });
    return true;
  }
}
