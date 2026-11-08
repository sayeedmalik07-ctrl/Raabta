import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/e_number_localizations.dart';
import '../food_local_analyzer.dart';
import '../models/e_number_entry.dart';

/// Shared Firestore collection for Claude-resolved and community-expanded codes.
const kENumberReferenceCollection = 'e_number_reference';

/// Local bundled + shared Firestore E-number lookup.
class ENumberLookupService {
  ENumberLookupService({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  final Map<String, ENumberEntry> _bundled = {};
  final Map<String, ENumberEntry> _sharedCache = {};
  bool _bundledLoaded = false;
  bool _sharedCacheLoaded = false;

  static final RegExp _eNumberPattern = RegExp(
    r'\bE\s*-?\s*(\d{3,4}[a-z]?)\b',
    caseSensitive: false,
  );

  static const _ingredientAliases = <String, String>{
    'monosodium glutamate': 'E621',
    'msg': 'E621',
    'aspartame': 'E951',
    'sodium benzoate': 'E211',
    'potassium sorbate': 'E202',
    'sorbic acid': 'E200',
    'citric acid': 'E330',
    'ascorbic acid': 'E300',
    'carrageenan': 'E407',
    'xanthan gum': 'E415',
    'guar gum': 'E412',
    'lecithin': 'E322',
    'sunset yellow': 'E110',
    'tartrazine': 'E102',
    'saccharin': 'E954',
    'sucralose': 'E955',
    'stevia': 'E960',
    'acesulfame': 'E950',
  };

  Future<void> ensureLoaded() async {
    await Future.wait([
      _ensureBundledLoaded(),
      _ensureSharedCacheLoaded(),
    ]);
  }

  Future<void> _ensureBundledLoaded() async {
    if (_bundledLoaded) return;
    final raw = await rootBundle.loadString(
      'lib/features/quick_actions/barcode_scanner/data/e_numbers.json',
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final entries = data['entries'] as List<dynamic>? ?? [];
    for (final item in entries) {
      final entry = ENumberEntry.fromJson(Map<String, dynamic>.from(item as Map));
      _bundled[normalizeCode(entry.code)] = entry;
    }
    _bundledLoaded = true;
  }

  Future<void> _ensureSharedCacheLoaded() async {
    if (_sharedCacheLoaded) return;
    try {
      final firestore = _firestoreOverride ?? FirebaseFirestore.instance;
      final snap = await firestore
          .collection(kENumberReferenceCollection)
          .limit(500)
          .get();
      for (final doc in snap.docs) {
        final entry = ENumberEntry.fromFirestore(doc.data());
        if (entry.code.isEmpty) continue;
        _sharedCache[normalizeCode(entry.code)] = entry.copyWith(
          source: ENumberSource.firestore,
        );
      }
    } catch (_) {
      // Offline or permission — bundled table still works.
    }
    _sharedCacheLoaded = true;
  }

  static String normalizeCode(String raw) {
    var code = raw.trim().toUpperCase();
    if (code.startsWith('EN:')) {
      code = code.substring(3);
    }
    if (code.contains(':')) {
      code = code.split(':').last;
    }
    code = code.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'^\d{3,4}[A-Z]?$').hasMatch(code)) {
      code = 'E$code';
    }
    return code;
  }

  /// Extract additive codes from Open Food Facts product + ingredient text.
  List<String> extractCodes({
    required Map<String, dynamic> product,
    required String ingredientsLower,
  }) {
    final codes = <String>{};

    final tags = product['additives_tags'] as List<dynamic>? ?? [];
    for (final tag in tags) {
      final normalized = normalizeCode(tag.toString());
      if (normalized.startsWith('E') || normalized == 'MSG') {
        codes.add(normalized);
      }
    }

    for (final match in _eNumberPattern.allMatches(ingredientsLower)) {
      codes.add(normalizeCode('E${match.group(1)}'));
    }

    for (final alias in _ingredientAliases.entries) {
      if (ingredientsLower.contains(alias.key)) {
        codes.add(alias.value);
      }
    }

    final sorted = codes.toList()..sort();
    return sorted;
  }

  ENumberEntry? lookupEntry(String code) {
    final key = normalizeCode(code);
    return _sharedCache[key] ?? _bundled[key];
  }

  LocalAdditiveInfo? lookupLocalized(String code, String uiLanguage) {
    final entry = lookupEntry(code);
    if (entry == null) return null;

    final localized = ENumberLocalizations.forCode(entry.code, uiLanguage);
    return LocalAdditiveInfo(
      code: entry.code,
      plainName: localized?.plainName ?? entry.plainName,
      status: entry.status,
      reason: localized?.reason ?? entry.reason,
    );
  }

  /// Resolve all codes; returns resolved additives and still-unknown codes.
  Future<ENumberResolution> resolveAdditives({
    required List<String> codes,
    required String uiLanguage,
  }) async {
    await ensureLoaded();

    final resolved = <LocalAdditiveInfo>[];
    final unknown = <String>[];
    var bundledHits = 0;
    var sharedHits = 0;

    for (final code in codes) {
      final key = normalizeCode(code);
      final shared = _sharedCache[key];
      final bundled = _bundled[key];
      final entry = shared ?? bundled;

      if (entry == null) {
        unknown.add(key);
        continue;
      }

      if (shared != null) {
        sharedHits++;
      } else {
        bundledHits++;
      }

      final localized = ENumberLocalizations.forCode(entry.code, uiLanguage);
      resolved.add(
        LocalAdditiveInfo(
          code: entry.code,
          plainName: localized?.plainName ?? entry.plainName,
          status: entry.status,
          reason: localized?.reason ?? entry.reason,
        ),
      );
    }

    return ENumberResolution(
      additives: resolved.take(8).toList(),
      unknownCodes: unknown,
      bundledHits: bundledHits,
      sharedCacheHits: sharedHits,
    );
  }

  /// Persist Claude-resolved reference data for all users.
  Future<void> persistFallbackEntries({
    required List<ENumberEntry> entries,
    required String language,
  }) async {
    if (entries.isEmpty) return;

    final firestore = _firestoreOverride ?? FirebaseFirestore.instance;
    final batch = firestore.batch();
    for (final entry in entries) {
      final key = normalizeCode(entry.code);
      final docRef =
          firestore.collection(kENumberReferenceCollection).doc(key);
      batch.set(
        docRef,
        entry.copyWith(source: ENumberSource.claudeFallback).toFirestore(
              language: language,
            ),
        SetOptions(merge: true),
      );
      _sharedCache[key] = entry.copyWith(source: ENumberSource.claudeFallback);
    }

    try {
      await batch.commit();
    } catch (_) {
      // Still update in-memory cache for this session.
    }
  }
}

class ENumberResolution {
  const ENumberResolution({
    required this.additives,
    required this.unknownCodes,
    required this.bundledHits,
    required this.sharedCacheHits,
  });

  final List<LocalAdditiveInfo> additives;
  final List<String> unknownCodes;
  final int bundledHits;
  final int sharedCacheHits;
}
