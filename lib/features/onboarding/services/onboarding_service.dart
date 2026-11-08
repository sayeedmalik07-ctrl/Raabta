import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// First-run onboarding flag — device (SharedPreferences) + Firestore profile.
class OnboardingService {
  OnboardingService._();

  static final OnboardingService instance = OnboardingService._();

  static const prefsKey = 'hasCompletedOnboarding';
  static const firestoreField = 'hasCompletedOnboarding';

  Future<bool> isCompletedLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  /// Whether to show the EOSB onboarding funnel after a successful login.
  Future<bool> shouldShowOnboarding({required bool fromFreshLogin}) async {
    if (await isCompletedLocally()) return false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return fromFreshLogin;

    if (!FirebaseService.isReady) {
      return fromFreshLogin;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return fromFreshLogin;

      final data = doc.data() ?? {};
      if (data[firestoreField] == true) {
        await _setLocalCompleted(true);
        return false;
      }

      // Existing accounts created before onboarding — treat as completed.
      if (data[firestoreField] == null && data['createdAt'] != null) {
        await markCompleted();
        return false;
      }

      if (data[firestoreField] == false) return true;
    } catch (_) {
      return fromFreshLogin;
    }

    return fromFreshLogin;
  }

  Future<String> resolvePostLoginRoute() async {
    final show = await shouldShowOnboarding(fromFreshLogin: true);
    return show ? '/onboarding/welcome' : '/home';
  }

  Future<void> markCompleted() async {
    await _setLocalCompleted(true);
    await _mirrorToFirestore(true);
  }

  Future<void> _setLocalCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, value);
  }

  Future<void> _mirrorToFirestore(bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !FirebaseService.isReady) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {firestoreField: value},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}
