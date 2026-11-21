import 'package:scam_shield_core/features/scam_shield/data/scam_community_patterns_config.dart';

class ScamCommunityPatternMatch {
  const ScamCommunityPatternMatch({
    required this.patternId,
    required this.labelKey,
    required this.matchedTerms,
    required this.score,
  });

  final String patternId;
  final String labelKey;
  final List<String> matchedTerms;
  final double score;
}

class ScamCommunityCorrelationResult {
  const ScamCommunityCorrelationResult({
    required this.matches,
  });

  static const empty = ScamCommunityCorrelationResult(matches: []);

  final List<ScamCommunityPatternMatch> matches;

  bool get hasMatches => matches.isNotEmpty;

  bool get isStrongMatch =>
      matches.any((m) => m.score >= ScamCommunityCorrelator.strongMatchScore);

  ScamCommunityPatternMatch? get strongest =>
      matches.isEmpty ? null : matches.first;
}

/// Matches pasted text against bundled community-reported scam archetypes.
abstract final class ScamCommunityCorrelator {
  static const strongMatchScore = 1.0;

  static ScamCommunityCorrelationResult analyze(String text) {
    final lower = text.toLowerCase();
    final matches = <ScamCommunityPatternMatch>[];

    for (final pattern in ScamCommunityPatternsConfig.patterns) {
      final matched = <String>[];
      for (final term in pattern.terms) {
        if (lower.contains(term.toLowerCase())) {
          matched.add(term);
        }
      }
      if (matched.length < pattern.minTermMatches) continue;

      final score = matched.length / pattern.minTermMatches;
      matches.add(
        ScamCommunityPatternMatch(
          patternId: pattern.id,
          labelKey: pattern.labelKey,
          matchedTerms: matched,
          score: score,
        ),
      );
    }

    matches.sort((a, b) => b.score.compareTo(a.score));
    return ScamCommunityCorrelationResult(matches: matches);
  }
}
