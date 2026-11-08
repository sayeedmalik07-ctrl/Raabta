import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:raabta/features/arabic_companion/arabic_companion_config.dart';
import 'package:raabta/features/quick_actions/landmark_translator/services/landmark_translation_cache.dart';

/// Shared Firestore cache for factual English→Arabic location translations.
class CachedArabicTranslation {
  const CachedArabicTranslation({
    required this.input,
    required this.arabic,
    required this.englishGps,
    this.area,
    this.confidence,
  });

  final String input;
  final String arabic;
  final String englishGps;
  final String? area;
  final String? confidence;

  factory CachedArabicTranslation.fromFirestore(Map<String, dynamic> data) {
    return CachedArabicTranslation(
      input: data['input'] as String? ?? '',
      arabic: data['arabic'] as String? ?? '',
      englishGps: data['englishGps'] as String? ?? '',
      area: data['area'] as String?,
      confidence: data['confidence'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'input': input,
        'arabic': arabic,
        'englishGps': englishGps,
        if (area != null) 'area': area,
        if (confidence != null) 'confidence': confidence,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  CachedLandmarkTranslation toLocalEntry() => CachedLandmarkTranslation(
        input: input,
        arabic: arabic,
        englishGps: englishGps,
        area: area,
        confidence: confidence,
      );
}

class ArabicTranslationsCacheService {
  ArabicTranslationsCacheService({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static String normalizeInput(String input) =>
      LandmarkTranslationCache.normalizeInput(input);

  static String docIdForInput(String input) {
    final normalized = normalizeInput(input);
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  Future<CachedArabicTranslation?> find(String input) async {
    if (input.trim().isEmpty) return null;
    try {
      final firestore = _firestoreOverride ?? FirebaseFirestore.instance;
      final doc = await firestore
          .collection(ArabicCompanionConfig.translationsCacheCollection)
          .doc(docIdForInput(input))
          .get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return CachedArabicTranslation.fromFirestore(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> persist(CachedArabicTranslation entry) async {
    if (entry.arabic.trim().isEmpty) return;
    try {
      final firestore = _firestoreOverride ?? FirebaseFirestore.instance;
      await firestore
          .collection(ArabicCompanionConfig.translationsCacheCollection)
          .doc(docIdForInput(entry.input))
          .set(entry.toFirestore(), SetOptions(merge: true));
    } catch (_) {
      // Offline — local device cache still updated by caller.
    }
  }
}
