import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_models.dart';

abstract final class ScamTypeCatalog {
  static const assetPath = 'assets/scam_shield/scam_types.json';
  static List<ScamTypeDefinition>? _cache;

  @visibleForTesting
  static void installForTest(List<ScamTypeDefinition> types) {
    _cache = types;
  }

  @visibleForTesting
  static void resetForTest() {
    _cache = null;
  }

  static Future<List<ScamTypeDefinition>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['types'] as List<dynamic>? ?? [];
    _cache = [
      for (final item in list)
        if (item is Map<String, dynamic>) _parseType(item),
    ];
    return _cache!;
  }

  static List<ScamTypeDefinition> verifiedOnly(List<ScamTypeDefinition> all) {
    return all.where((t) => t.verified).toList(growable: false);
  }

  static ScamTypeDefinition? byId(List<ScamTypeDefinition> all, String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  static ScamTypeDefinition _parseType(Map<String, dynamic> json) {
    final matchRaw = json['match'] as Map<String, dynamic>? ?? {};
    final stepsRaw = json['whatToDo'] as List<dynamic>? ?? [];
    final reviewed = json['lastReviewed']?.toString() ?? '';
    return ScamTypeDefinition(
      id: json['id']?.toString() ?? '',
      titleKey: json['titleKey']?.toString() ?? '',
      howItWorksKey: json['howItWorksKey']?.toString() ?? '',
      redFlagKeys: [
        for (final k in (json['redFlagKeys'] as List<dynamic>? ?? []))
          k.toString(),
      ],
      whatToDo: [
        for (final step in stepsRaw)
          if (step is Map<String, dynamic>)
            ScamTypeWhatToDoStep(
              labelKey: step['labelKey']?.toString() ?? '',
              link: _parseLink(step['link']?.toString()),
            ),
      ],
      exampleKey: json['exampleKey']?.toString() ?? '',
      sourceLabelKeys: [
        for (final k in (json['sourceLabelKeys'] as List<dynamic>? ?? []))
          k.toString(),
      ],
      lastReviewed: DateTime.tryParse(reviewed) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      verified: json['verified'] == true,
      match: ScamTypeMatchRules(
        patternIds: _stringList(matchRaw['patternIds']),
        topics: _stringList(matchRaw['topics']),
        contentTypes: _stringList(matchRaw['contentTypes']),
        localFlags: _stringList(matchRaw['localFlags']),
        terms: _stringList(matchRaw['terms']),
        minTermMatches: (matchRaw['minTermMatches'] as num?)?.toInt() ?? 2,
      ),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return [for (final v in raw) v.toString()];
  }

  static ScamTypeActionLink _parseLink(String? raw) {
    return switch (raw) {
      'paymentCheck' => ScamTypeActionLink.paymentCheck,
      'incident' => ScamTypeActionLink.incident,
      'familyVerification' => ScamTypeActionLink.familyVerification,
      'authorityDirectory' => ScamTypeActionLink.authorityDirectory,
      'academy' => ScamTypeActionLink.academy,
      'checkup' => ScamTypeActionLink.checkup,
      'simSwap' => ScamTypeActionLink.simSwap,
      'tenancyHub' => ScamTypeActionLink.tenancyHub,
      _ => ScamTypeActionLink.officialDirectory,
    };
  }

  /// Validates bundled schema for tests.
  static void assertSchema(List<ScamTypeDefinition> types) {
    final ids = <String>{};
    for (final t in types) {
      assert(t.id.isNotEmpty);
      assert(ids.add(t.id));
      assert(t.titleKey.startsWith('ss_stype_'));
      assert(t.howItWorksKey.isNotEmpty);
      assert(t.redFlagKeys.isNotEmpty);
      assert(t.whatToDo.length >= 3);
      assert(t.exampleKey.isNotEmpty);
      assert(t.sourceLabelKeys.isNotEmpty);
      assert(t.lastReviewed.year >= 2024);
    }
  }
}
