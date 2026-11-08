import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecurityGuidanceTopic {
  const SecurityGuidanceTopic({
    required this.id,
    required this.titleKey,
    required this.sourceLabelKey,
    required this.lastReviewed,
    required this.verified,
    required this.variantKeys,
  });

  final String id;
  final String titleKey;
  final String sourceLabelKey;
  final DateTime lastReviewed;
  final bool verified;
  final List<String> variantKeys;
}

class SecuritySharedSomethingCopy {
  const SecuritySharedSomethingCopy({
    required this.headlineKey,
    required this.stepKeys,
    required this.lastReviewed,
    required this.verified,
  });

  final String headlineKey;
  final List<String> stepKeys;
  final DateTime lastReviewed;
  final bool verified;
}

abstract final class SecurityGuidanceCatalog {
  static const assetPath = 'assets/scam_shield/security_guidance.json';
  static List<SecurityGuidanceTopic>? _topics;
  static SecuritySharedSomethingCopy? _shared;

  @visibleForTesting
  static void installForTest({
    required List<SecurityGuidanceTopic> topics,
    required SecuritySharedSomethingCopy shared,
  }) {
    _topics = topics;
    _shared = shared;
  }

  @visibleForTesting
  static void resetForTest() {
    _topics = null;
    _shared = null;
  }

  static Future<List<SecurityGuidanceTopic>> loadTopics() async {
    if (_topics != null) return _topics!;
    await _load();
    return _topics!;
  }

  static Future<SecuritySharedSomethingCopy?> loadSharedSomething() async {
    if (_shared != null) return _shared;
    await _load();
    return _shared;
  }

  static List<SecurityGuidanceTopic> verifiedTopics(List<SecurityGuidanceTopic> all) {
    return all.where((t) => t.verified).toList(growable: false);
  }

  static Future<void> _load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['topics'] as List<dynamic>? ?? [];
    _topics = [
      for (final item in list)
        if (item is Map<String, dynamic>) _parseTopic(item),
    ];
    final sharedRaw = decoded['sharedSomething'] as Map<String, dynamic>?;
    _shared = sharedRaw == null ? null : _parseShared(sharedRaw);
  }

  static SecurityGuidanceTopic _parseTopic(Map<String, dynamic> json) {
    final reviewed = json['lastReviewed']?.toString() ?? '';
    return SecurityGuidanceTopic(
      id: json['id']?.toString() ?? '',
      titleKey: json['titleKey']?.toString() ?? '',
      sourceLabelKey: json['sourceLabelKey']?.toString() ?? '',
      lastReviewed: DateTime.tryParse(reviewed) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      verified: json['verified'] == true,
      variantKeys: [
        for (final k in (json['variantKeys'] as List<dynamic>? ?? []))
          k.toString(),
      ],
    );
  }

  static SecuritySharedSomethingCopy _parseShared(Map<String, dynamic> json) {
    final reviewed = json['lastReviewed']?.toString() ?? '';
    return SecuritySharedSomethingCopy(
      headlineKey: json['headlineKey']?.toString() ?? '',
      stepKeys: [
        for (final k in (json['stepKeys'] as List<dynamic>? ?? []))
          k.toString(),
      ],
      lastReviewed: DateTime.tryParse(reviewed) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      verified: json['verified'] == true,
    );
  }
}
