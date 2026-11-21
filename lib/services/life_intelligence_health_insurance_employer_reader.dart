import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Read-only access to the latest Health Insurance compliance employer key.
abstract final class LifeIntelligenceHealthInsuranceEmployerReader {
  static Future<String?> loadLatestNormalizedEmployerKey({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) async {
    try {
      final user = (auth ?? FirebaseAuth.instance).currentUser;
      if (user == null) return null;

      final snap = await (firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(user.uid)
          .collection('health_insurance_compliance_checks')
          .orderBy('calculatedAt', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;

      final raw = snap.docs.first.data()['normalizedEmployerKey'];
      if (raw is! String) return null;
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }
}
