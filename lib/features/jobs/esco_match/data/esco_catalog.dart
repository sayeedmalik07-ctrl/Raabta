import 'package:raabta/features/jobs/esco_match/data/esco_catalog_data.dart';
import 'package:raabta/features/jobs/esco_match/data/models/esco_models.dart';

/// Bundled ESCO occupation↔skill subgraph for Qatar-relevant roles.
///
/// Data is seeded from the official EU ESCO Web Services API (v1.2.1) and
/// shipped offline — matching must not depend on live API calls.
abstract final class EscoCatalog {
  static const escoVersion = EscoCatalogData.escoVersion;
  static const lastSeeded = EscoCatalogData.lastSeeded;
  static const lastContentReview = '2026-08-27';

  static const occupations = EscoCatalogData.occupations;
  static const skills = EscoCatalogData.skills;

  static final Map<String, EscoOccupationDef> _occupationsByUri = {
    for (final o in occupations) o.uri: o,
  };

  static final Map<String, EscoSkillDef> _skillsByUri = {
    for (final s in skills) s.uri: s,
  };

  static final Map<String, EscoOccupationDef> _occupationsByCode = {
    for (final o in occupations)
      if (o.code.isNotEmpty) o.code: o,
  };

  static EscoOccupationDef? occupationByUri(String uri) =>
      _occupationsByUri[uri];

  static EscoSkillDef? skillByUri(String uri) => _skillsByUri[uri];

  static EscoOccupationDef? occupationByCode(String code) =>
      _occupationsByCode[code];

  static EscoOccupationDef? occupationById(String id) {
    for (final o in occupations) {
      if (o.id == id) return o;
    }
    return null;
  }

  static EscoSkillDef? skillById(String id) {
    for (final s in skills) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// All essential + optional skills linked to [occupationUri].
  static List<EscoSkillDef> skillsForOccupation(String occupationUri) {
    final occ = occupationByUri(occupationUri);
    if (occ == null) return const [];
    return occ.allLinkedSkillUris
        .map(skillByUri)
        .whereType<EscoSkillDef>()
        .toList(growable: false);
  }

  static List<EscoSkillDef> essentialSkillsForOccupation(String occupationUri) {
    final occ = occupationByUri(occupationUri);
    if (occ == null) return const [];
    return occ.essentialSkillUris
        .map(skillByUri)
        .whereType<EscoSkillDef>()
        .toList(growable: false);
  }

  /// Flat label index for exact/alias normalization lookups.
  static List<EscoLabelIndexEntry> buildLabelIndex() {
    final entries = <EscoLabelIndexEntry>[];

    void addConcept({
      required EscoConceptType type,
      required String uri,
      required String labelEn,
      required String labelAr,
      required List<String> altLabelsEn,
      required bool isAlias,
    }) {
      for (final label in [labelEn, labelAr, ...altLabelsEn]) {
        if (label.trim().isEmpty) continue;
        entries.add(
          EscoLabelIndexEntry(
            normalizedLabel: EscoTextNormalizer.normalize(label),
            conceptType: type,
            uri: uri,
            isAlias: isAlias || label != labelEn,
          ),
        );
      }
    }

    for (final s in skills) {
      addConcept(
        type: EscoConceptType.skill,
        uri: s.uri,
        labelEn: s.labelEn,
        labelAr: s.labelAr,
        altLabelsEn: s.altLabelsEn,
        isAlias: false,
      );
    }

    for (final o in occupations) {
      addConcept(
        type: EscoConceptType.occupation,
        uri: o.uri,
        labelEn: o.labelEn,
        labelAr: o.labelAr,
        altLabelsEn: o.altLabelsEn,
        isAlias: false,
      );
    }

    for (final alias in EscoQatarAliases.aliases.entries) {
      entries.add(
        EscoLabelIndexEntry(
          normalizedLabel: EscoTextNormalizer.normalize(alias.key),
          conceptType: alias.value.type,
          uri: alias.value.uri,
          isAlias: true,
        ),
      );
    }

    return entries;
  }
}

/// Qatar labour-market shorthand → official ESCO URI (supplements ESCO alt labels).
abstract final class EscoQatarAliases {
  static const aliases = <String, _AliasTarget>{
    'hse': _AliasTarget(
      type: EscoConceptType.occupation,
      uri: 'http://data.europa.eu/esco/occupation/789517fb-95ee-43d1-9530-c2860be1a439',
    ),
    'hse officer': _AliasTarget(
      type: EscoConceptType.occupation,
      uri: 'http://data.europa.eu/esco/occupation/789517fb-95ee-43d1-9530-c2860be1a439',
    ),
    'health safety officer': _AliasTarget(
      type: EscoConceptType.occupation,
      uri: 'http://data.europa.eu/esco/occupation/789517fb-95ee-43d1-9530-c2860be1a439',
    ),
    'forklift': _AliasTarget(
      type: EscoConceptType.skill,
      uri: 'http://data.europa.eu/esco/skill/28cb374e-6261-4133-8371-f9a5470145da',
    ),
    'forklift license': _AliasTarget(
      type: EscoConceptType.skill,
      uri: 'http://data.europa.eu/esco/skill/28cb374e-6261-4133-8371-f9a5470145da',
    ),
    'nebosh': _AliasTarget(
      type: EscoConceptType.skill,
      uri: 'http://data.europa.eu/esco/skill/dcc96a49-0bac-4a9c-8f8e-a32b4e47e6eb',
    ),
    'iosh': _AliasTarget(
      type: EscoConceptType.skill,
      uri: 'http://data.europa.eu/esco/skill/dcc96a49-0bac-4a9c-8f8e-a32b4e47e6eb',
    ),
    'store keeper': _AliasTarget(
      type: EscoConceptType.occupation,
      uri: 'http://data.europa.eu/esco/occupation/bea705fe-06ac-4147-b8e0-6e8ac1208d8f',
    ),
    'storekeeper': _AliasTarget(
      type: EscoConceptType.occupation,
      uri: 'http://data.europa.eu/esco/occupation/bea705fe-06ac-4147-b8e0-6e8ac1208d8f',
    ),
    'lorry driver': _AliasTarget(
      type: EscoConceptType.occupation,
      uri: 'http://data.europa.eu/esco/occupation/45037d43-a8f5-4f46-b332-b2935bc305f4',
    ),
    'heavy driver': _AliasTarget(
      type: EscoConceptType.occupation,
      uri: 'http://data.europa.eu/esco/occupation/45037d43-a8f5-4f46-b332-b2935bc305f4',
    ),
  };
}

class _AliasTarget {
  const _AliasTarget({required this.type, required this.uri});
  final EscoConceptType type;
  final String uri;
}

/// Shared text normalization for ESCO label matching.
abstract final class EscoTextNormalizer {
  static String normalize(String input) {
    var s = input.trim().toLowerCase();
    s = s.replaceAll(RegExp(r'[/\\|]+'), ' ');
    s = s.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF-]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  static Set<String> tokens(String input) {
    final n = normalize(input);
    if (n.isEmpty) return {};
    return n.split(' ').where((t) => t.length > 1).toSet();
  }

  /// Token Jaccard similarity 0.0–1.0.
  static double tokenJaccard(String a, String b) {
    final ta = tokens(a);
    final tb = tokens(b);
    if (ta.isEmpty || tb.isEmpty) return 0;
    final intersection = ta.intersection(tb).length;
    final union = ta.union(tb).length;
    if (union == 0) return 0;
    return intersection / union;
  }

  /// Normalized Levenshtein ratio 0.0–1.0.
  static double levenshteinRatio(String a, String b) {
    final sa = normalize(a);
    final sb = normalize(b);
    if (sa.isEmpty || sb.isEmpty) return 0;
    if (sa == sb) return 1;
    final dist = _levenshtein(sa, sb);
    final maxLen = sa.length > sb.length ? sa.length : sb.length;
    return 1 - (dist / maxLen);
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        curr[j + 1] = _min3(
          curr[j] + 1,
          prev[j + 1] + 1,
          prev[j] + cost,
        );
      }
      for (var j = 0; j <= b.length; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[b.length];
  }

  static int _min3(int a, int b, int c) {
    if (a <= b && a <= c) return a;
    if (b <= c) return b;
    return c;
  }
}
