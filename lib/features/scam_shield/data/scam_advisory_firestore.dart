import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_advisory_models.dart';

/// Firestore deserialization kept in the app layer (not in [scam_shield_core]).
abstract final class ScamAdvisoryFirestore {
  static ScamAdvisory fromDocument(String id, Map<String, dynamic> data) {
    return ScamAdvisory.fromMap(id, _sanitizeDates(data));
  }

  static Map<String, dynamic> _sanitizeDates(Map<String, dynamic> data) {
    final out = Map<String, dynamic>.from(data);
    for (final key in ['sourceDate', 'publishedAt', 'expiresAt']) {
      final value = out[key];
      if (value is Timestamp) {
        out[key] = value.toDate().toIso8601String();
      }
    }
    return out;
  }
}
