import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_cache.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_config.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_matcher.dart';
import 'package:raabta/features/community/services/community_repository.dart';

class AskQatarSimilarQuestionHit {
  const AskQatarSimilarQuestionHit({
    required this.questionId,
    required this.title,
    required this.answerCount,
    required this.isSolved,
    this.overlapScore = 0,
    this.aiReason,
  });

  final String questionId;
  final String title;
  final int answerCount;
  final bool isSolved;
  final int overlapScore;
  final String? aiReason;
}

typedef SimilarQuestionRanker = Future<List<AskQatarSimilarQuestionHit>> Function({
  required String draftTitle,
  required String language,
  required List<AskQatarSimilarCandidate> candidates,
});

/// One-shot candidate fetch + local rank + optional capped Claude disambiguation.
class AskQatarSimilarQuestionService {
  AskQatarSimilarQuestionService({
    required CommunityRepository repository,
    SimilarQuestionRanker? rankWithClaude,
  })  : _repository = repository,
        _rankWithClaude = rankWithClaude ?? _defaultRankWithClaude;

  final CommunityRepository _repository;
  final SimilarQuestionRanker _rankWithClaude;

  Future<List<AskQatarSimilarQuestionHit>> findSimilar({
    required String draftTitle,
    required String category,
    required String userId,
    required String language,
    bool skipAiRanking = false,
  }) async {
    final trimmed = draftTitle.trim();
    if (trimmed.length < AskQatarSimilarQuestionConfig.minTitleLengthForLookup) {
      return const [];
    }

    final cacheKey = AskQatarSimilarQuestionMatcher.normalizeCacheKey(
      trimmed,
      category,
    );
    final cachedIds = AskQatarSimilarQuestionCache.get(cacheKey);
    List<AskQatarQuestion> pool;
    if (cachedIds != null) {
      pool = await _repository.fetchQuestionsByIds(cachedIds);
    } else {
      pool = await _repository.fetchRecentQuestionsForSimilarity(
        category: category,
        limit: AskQatarSimilarQuestionConfig.maxCandidateFetch,
      );
      AskQatarSimilarQuestionCache.put(
        cacheKey,
        pool.map((q) => q.id).toList(),
      );
    }

    final ranked = AskQatarSimilarQuestionMatcher.rankCandidates(
      draftTitle: trimmed,
      pool: pool,
    );
    if (ranked.isEmpty) return const [];

    final ambiguous = ranked.length >=
        AskQatarSimilarQuestionConfig.minCandidatesForAiRanking;

    if (!skipAiRanking && ambiguous) {
      try {
        return await _rankWithClaude(
          draftTitle: trimmed,
          language: language,
          candidates: ranked,
        );
      } catch (_) {
        // Fall through to local-only display (429, provider errors, etc.).
      }
    }

    return ranked
        .take(AskQatarSimilarQuestionConfig.maxDisplay)
        .map(_hitFromCandidate)
        .toList();
  }

  static AskQatarSimilarQuestionHit _hitFromCandidate(
    AskQatarSimilarCandidate c,
  ) {
    final q = c.question;
    return AskQatarSimilarQuestionHit(
      questionId: q.id,
      title: q.title,
      answerCount: q.answers,
      isSolved: q.isSolved,
      overlapScore: c.overlapScore,
    );
  }

  static Future<List<AskQatarSimilarQuestionHit>> rankWithClaudeReply({
    required String draftTitle,
    required String language,
    required List<AskQatarSimilarCandidate> candidates,
    required String claudeReply,
  }) async {
    final parsed = parseClaudeRankingJson(claudeReply);
    final sameIds = parsed
        .where((m) => m.isSameQuestion)
        .map((m) => m.candidateId)
        .toSet();

    final reasonById = {
      for (final m in parsed) m.candidateId: m.reason,
    };

    final hits = <AskQatarSimilarQuestionHit>[];
    for (final c in candidates) {
      final id = c.question.id;
      if (sameIds.isNotEmpty && !sameIds.contains(id)) continue;
      hits.add(
        AskQatarSimilarQuestionHit(
          questionId: id,
          title: c.question.title,
          answerCount: c.question.answers,
          isSolved: c.question.isSolved,
          overlapScore: c.overlapScore,
          aiReason: reasonById[id],
        ),
      );
    }

    if (hits.isEmpty) {
      return candidates
          .take(AskQatarSimilarQuestionConfig.maxDisplay)
          .map(_hitFromCandidate)
          .toList();
    }

    hits.sort((a, b) => b.overlapScore.compareTo(a.overlapScore));
    return hits.take(AskQatarSimilarQuestionConfig.maxDisplay).toList();
  }

  static List<({String candidateId, bool isSameQuestion, String? reason})>
      parseClaudeRankingJson(String reply) {
    try {
      final start = reply.indexOf('{');
      final end = reply.lastIndexOf('}');
      if (start < 0 || end <= start) return const [];
      final json =
          jsonDecode(reply.substring(start, end + 1)) as Map<String, dynamic>;
      final matches = json['matches'] as List<dynamic>? ?? const [];
      return [
        for (final raw in matches)
          if (raw is Map<String, dynamic>)
            (
              candidateId: raw['candidate_id'] as String? ?? '',
              isSameQuestion: raw['is_same_question'] as bool? ?? false,
              reason: raw['reason'] as String?,
            ),
      ].where((m) => m.candidateId.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  static String buildClaudeRankingPrompt({
    required String draftTitle,
    required String language,
    required List<AskQatarSimilarCandidate> candidates,
  }) {
    final lines = candidates
        .map(
          (c) =>
              '- candidate_id: "${c.question.id}" | title: "${c.question.title.replaceAll('"', '\\"')}"',
        )
        .join('\n');

    return '''
You help reduce duplicate questions on Raabta Ask Qatar (Qatar expat Q&A).
The user draft title is in $language (cross-language matches are allowed).

Draft title: "$draftTitle"

Existing questions:
$lines

Respond ONLY with valid JSON (no markdown):
{"matches":[{"candidate_id":"<id>","is_same_question":true|false,"reason":"short neutral phrase"}]}

Mark is_same_question true when the draft is asking the same practical question as the candidate, even if wording or language differs.
Mark false for merely related topics (same category but different problem).
''';
  }

  static Future<List<AskQatarSimilarQuestionHit>> _defaultRankWithClaude({
    required String draftTitle,
    required String language,
    required List<AskQatarSimilarCandidate> candidates,
  }) async {
    throw UnimplementedError('Inject rankWithClaude via provider');
  }
}
