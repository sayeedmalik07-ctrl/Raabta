import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_config.dart';

class AskQatarSimilarCandidate {
  const AskQatarSimilarCandidate({
    required this.question,
    required this.overlapScore,
  });

  final AskQatarQuestion question;
  final int overlapScore;
}

/// Deterministic title/keyword overlap for similar-question pre-filter.
abstract final class AskQatarSimilarQuestionMatcher {
  static List<AskQatarSimilarCandidate> rankCandidates({
    required String draftTitle,
    required List<AskQatarQuestion> pool,
    String? excludeQuestionId,
  }) {
    final draftTokens = _meaningfulTokens(draftTitle);
    if (draftTokens.isEmpty) return const [];

    final scored = <AskQatarSimilarCandidate>[];
    for (final q in pool) {
      if (excludeQuestionId != null && q.id == excludeQuestionId) continue;
      final score = overlapScore(
        draftTokens: draftTokens,
        candidateTitle: q.title,
        searchKeywords: q.searchKeywords,
      );
      if (score >= AskQatarSimilarQuestionConfig.minOverlapScore) {
        scored.add(AskQatarSimilarCandidate(question: q, overlapScore: score));
      }
    }

    scored.sort((a, b) {
      final byScore = b.overlapScore.compareTo(a.overlapScore);
      if (byScore != 0) return byScore;
      final aTime = a.question.createdAt ?? DateTime(0);
      final bTime = b.question.createdAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    return scored.take(AskQatarSimilarQuestionConfig.maxLocalCandidates).toList();
  }

  static int overlapScore({
    required Set<String> draftTokens,
    required String candidateTitle,
    List<String> searchKeywords = const [],
  }) {
    final titleTokens = _meaningfulTokens(candidateTitle);
    final keywordTokens = searchKeywords
        .map((k) => k.toLowerCase().trim())
        .where((k) => k.isNotEmpty && !_isStopWord(k))
        .toSet();

    var hits = 0;
    for (final token in draftTokens) {
      if (titleTokens.contains(token) || keywordTokens.contains(token)) {
        hits++;
      }
    }
    return hits;
  }

  static Set<String> _meaningfulTokens(String text) {
    return SearchKeywordTokenizer.tokenize(text)
        .where((t) => !_isStopWord(t))
        .toSet();
  }

  static String normalizeCacheKey(String title, String category) {
    final tokens = SearchKeywordTokenizer.tokenize(title)..sort();
    return '${category.trim().toLowerCase()}|${tokens.join(' ')}';
  }

  static bool _isStopWord(String token) =>
      AskQatarSimilarQuestionConfig.stopWords.contains(token.toLowerCase());
}
