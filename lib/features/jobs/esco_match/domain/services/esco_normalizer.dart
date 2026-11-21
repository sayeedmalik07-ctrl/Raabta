import 'package:raabta/features/jobs/esco_match/data/esco_catalog.dart';
import 'package:raabta/features/jobs/esco_match/data/models/esco_models.dart';

/// Maps free-text skills/roles from CV Maker and Jobs Screen to bundled ESCO concepts.
///
/// Lookup order: exact label → Qatar alias → token overlap → Levenshtein fallback.
/// Zero AI / zero network — pure deterministic computation over bundled data.
class EscoNormalizer {
  EscoNormalizer({EscoNormalizerIndex? index})
      : _index = index ?? EscoNormalizerIndex.build();

  final EscoNormalizerIndex _index;

  /// Maps a single free-text skill or role string to the nearest ESCO concept.
  EscoNormalizationResult normalize(
    String input, {
    EscoConceptType? preferType,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return EscoNormalizationResult(
        input: input,
        confidence: EscoMatchConfidence.none,
      );
    }

    final normalized = EscoTextNormalizer.normalize(trimmed);

    final exact = _index.exactLookup(normalized, preferType: preferType);
    if (exact != null) {
      return _resultFromEntry(
        input: trimmed,
        entry: exact,
        confidence:
            exact.isAlias ? EscoMatchConfidence.alias : EscoMatchConfidence.exact,
        score: 100,
      );
    }

    final fuzzyCandidates = _index.fuzzyCandidates(
      trimmed,
      preferType: preferType,
    );
    if (fuzzyCandidates.isEmpty) {
      return EscoNormalizationResult(
        input: trimmed,
        confidence: EscoMatchConfidence.none,
      );
    }

    final best = fuzzyCandidates.first;
    final confidence = best.jaccard >= 0.72
        ? EscoMatchConfidence.alias
        : EscoMatchConfidence.fuzzy;
    return _resultFromCandidate(
      input: trimmed,
      candidate: best,
      confidence: confidence,
      score: (best.score * 100).round().clamp(1, 99),
    );
  }

  /// Normalizes many strings; skips empty inputs.
  List<EscoNormalizationResult> normalizeBatch(
    Iterable<String> inputs, {
    EscoConceptType? preferType,
  }) {
    return inputs
        .where((s) => s.trim().isNotEmpty)
        .map((s) => normalize(s, preferType: preferType))
        .toList(growable: false);
  }

  /// Returns top [limit] ESCO concepts for autocomplete / disambiguation.
  List<EscoNormalizationResult> suggest(
    String query, {
    int limit = 5,
    EscoConceptType? preferType,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final normalized = EscoTextNormalizer.normalize(trimmed);
    final exact = _index.exactLookup(normalized, preferType: preferType);
    if (exact != null) {
      return [
        _resultFromEntry(
          input: trimmed,
          entry: exact,
          confidence: exact.isAlias
              ? EscoMatchConfidence.alias
              : EscoMatchConfidence.exact,
          score: 100,
        ),
      ];
    }

    return _index
        .fuzzyCandidates(trimmed, preferType: preferType, limit: limit)
        .map(
          (c) => _resultFromCandidate(
            input: trimmed,
            candidate: c,
            confidence: c.jaccard >= 0.72
                ? EscoMatchConfidence.alias
                : EscoMatchConfidence.fuzzy,
            score: (c.score * 100).round().clamp(1, 99),
          ),
        )
        .toList(growable: false);
  }

  EscoNormalizationResult _resultFromEntry({
    required String input,
    required EscoLabelIndexEntry entry,
    required EscoMatchConfidence confidence,
    required int score,
  }) {
    if (entry.conceptType == EscoConceptType.skill) {
      final skill = EscoCatalog.skillByUri(entry.uri);
      if (skill == null) {
        return EscoNormalizationResult(
          input: input,
          confidence: EscoMatchConfidence.none,
        );
      }
      return EscoNormalizationResult(
        input: input,
        confidence: confidence,
        skill: skill,
        matchedLabel: skill.labelEn,
        score: score,
      );
    }

    final occupation = EscoCatalog.occupationByUri(entry.uri);
    if (occupation == null) {
      return EscoNormalizationResult(
        input: input,
        confidence: EscoMatchConfidence.none,
      );
    }
    return EscoNormalizationResult(
      input: input,
      confidence: confidence,
      occupation: occupation,
      matchedLabel: occupation.labelEn,
      score: score,
    );
  }

  EscoNormalizationResult _resultFromCandidate({
    required String input,
    required _ScoredCandidate candidate,
    required EscoMatchConfidence confidence,
    required int score,
  }) {
    if (candidate.conceptType == EscoConceptType.skill) {
      final skill = EscoCatalog.skillByUri(candidate.uri);
      if (skill == null) {
        return EscoNormalizationResult(
          input: input,
          confidence: EscoMatchConfidence.none,
        );
      }
      return EscoNormalizationResult(
        input: input,
        confidence: confidence,
        skill: skill,
        matchedLabel: candidate.matchedLabel,
        score: score,
      );
    }

    final occupation = EscoCatalog.occupationByUri(candidate.uri);
    if (occupation == null) {
      return EscoNormalizationResult(
        input: input,
        confidence: EscoMatchConfidence.none,
      );
    }
    return EscoNormalizationResult(
      input: input,
      confidence: confidence,
      occupation: occupation,
      matchedLabel: candidate.matchedLabel,
      score: score,
    );
  }
}

/// Pre-built lookup structures for fast normalization.
class EscoNormalizerIndex {
  EscoNormalizerIndex._({
    required this.exactByLabel,
    required this.candidates,
  });

  final Map<String, List<EscoLabelIndexEntry>> exactByLabel;
  final List<_IndexedCandidate> candidates;

  static EscoNormalizerIndex? _cached;

  static EscoNormalizerIndex build() {
    return _cached ??= EscoNormalizerIndex._fromCatalog();
  }

  static EscoNormalizerIndex _fromCatalog() {
    final indexEntries = EscoCatalog.buildLabelIndex();
    final exactByLabel = <String, List<EscoLabelIndexEntry>>{};

    for (final entry in indexEntries) {
      exactByLabel.putIfAbsent(entry.normalizedLabel, () => []).add(entry);
    }

    final candidates = <_IndexedCandidate>[];

    for (final skill in EscoCatalog.skills) {
      _addCandidate(
        candidates,
        uri: skill.uri,
        type: EscoConceptType.skill,
        labels: [skill.labelEn, skill.labelAr, ...skill.altLabelsEn],
      );
    }

    for (final occ in EscoCatalog.occupations) {
      _addCandidate(
        candidates,
        uri: occ.uri,
        type: EscoConceptType.occupation,
        labels: [occ.labelEn, occ.labelAr, ...occ.altLabelsEn],
      );
    }

    return EscoNormalizerIndex._(
      exactByLabel: exactByLabel,
      candidates: candidates,
    );
  }

  static void _addCandidate(
    List<_IndexedCandidate> out, {
    required String uri,
    required EscoConceptType type,
    required List<String> labels,
  }) {
    for (final label in labels) {
      if (label.trim().isEmpty) continue;
      out.add(
        _IndexedCandidate(
          uri: uri,
          conceptType: type,
          matchedLabel: label,
          normalizedLabel: EscoTextNormalizer.normalize(label),
        ),
      );
    }
  }

  EscoLabelIndexEntry? exactLookup(
    String normalizedInput, {
    EscoConceptType? preferType,
  }) {
    final hits = exactByLabel[normalizedInput];
    if (hits == null || hits.isEmpty) return null;
    if (preferType == null) return hits.first;
    return hits.firstWhere(
      (h) => h.conceptType == preferType,
      orElse: () => hits.first,
    );
  }

  List<_ScoredCandidate> fuzzyCandidates(
    String input, {
    EscoConceptType? preferType,
    int limit = 5,
  }) {
    const minScore = 0.52;
    const minLevenshtein = 0.80;

    final normalizedInput = EscoTextNormalizer.normalize(input);
    final bestByUri = <String, _ScoredCandidate>{};

    for (final candidate in candidates) {
      if (preferType != null && candidate.conceptType != preferType) {
        continue;
      }

      final jaccard =
          EscoTextNormalizer.tokenJaccard(input, candidate.matchedLabel);
      final lev = EscoTextNormalizer.levenshteinRatio(
        input,
        candidate.matchedLabel,
      );
      final prefix = _prefixOverlapScore(
        normalizedInput,
        candidate.normalizedLabel,
      );
      final combined = _combineScores(jaccard, lev, prefix);

      if (jaccard < 0.35 && lev < minLevenshtein && prefix < 0.5) continue;
      if (combined < minScore) continue;

      final scored = _ScoredCandidate(
        uri: candidate.uri,
        conceptType: candidate.conceptType,
        matchedLabel: candidate.matchedLabel,
        jaccard: jaccard,
        levenshtein: lev,
        score: combined,
        isAlias: false,
      );

      final existing = bestByUri[candidate.uri];
      if (existing == null || scored.score > existing.score) {
        bestByUri[candidate.uri] = scored;
      }
    }

    final sorted = bestByUri.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return sorted.take(limit).toList(growable: false);
  }

  static double _combineScores(double jaccard, double lev, double prefix) {
    final best = jaccard > lev ? jaccard : lev;
    return (best * 0.55) + (prefix * 0.25) + (lev * 0.20);
  }

  /// Boosts short query tokens that prefix-match occupation/skill labels.
  static double _prefixOverlapScore(String query, String label) {
    if (query.isEmpty || label.isEmpty) return 0;
    if (label.contains(query)) return 0.95;
    if (query.length >= 3 && label.startsWith(query)) return 0.9;

    final queryTokens = query.split(' ');
    final labelTokens = label.split(' ');
    var hits = 0;
    for (final qt in queryTokens) {
      if (qt.length < 3) continue;
      for (final lt in labelTokens) {
        if (lt.startsWith(qt) || qt.startsWith(lt)) {
          hits++;
          break;
        }
      }
    }
    if (queryTokens.isEmpty) return 0;
    return hits / queryTokens.length;
  }
}

class _IndexedCandidate {
  const _IndexedCandidate({
    required this.uri,
    required this.conceptType,
    required this.matchedLabel,
    required this.normalizedLabel,
  });

  final String uri;
  final EscoConceptType conceptType;
  final String matchedLabel;
  final String normalizedLabel;
}

class _ScoredCandidate {
  const _ScoredCandidate({
    required this.uri,
    required this.conceptType,
    required this.matchedLabel,
    required this.jaccard,
    required this.levenshtein,
    required this.score,
    required this.isAlias,
  });

  final String uri;
  final EscoConceptType conceptType;
  final String matchedLabel;
  final double jaccard;
  final double levenshtein;
  final double score;
  final bool isAlias;
}
