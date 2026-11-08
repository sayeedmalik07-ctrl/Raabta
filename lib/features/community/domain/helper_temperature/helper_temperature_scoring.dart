import 'dart:math' as math;

import 'package:raabta/features/community/domain/helper_temperature/helper_temperature_config.dart';
import 'package:raabta/features/community/domain/helper_temperature/helper_temperature_models.dart';

/// Deterministic Helper Temperature from behaviour events (no I/O, no UI, no tiers).
double computeHelperTemperature(HelperTemperatureStats stats) {
  var score = HelperTemperatureConfig.baseline;
  final asOfUtc = stats.asOf.toUtc();

  final accepted = _eligibleAcceptedAnswers(stats, asOfUtc);
  if (HelperTemperatureConfig.acceptedAnswersEnabled && accepted.isNotEmpty) {
    score += _acceptedAnswerGain(accepted);
  }

  if (HelperTemperatureConfig.helpfulVotesEnabled) {
    score += _placeholderGain(stats.helpfulVotes.length);
  }
  if (HelperTemperatureConfig.groupLikesEnabled) {
    score += _placeholderGain(stats.groupLikes.length);
  }
  if (HelperTemperatureConfig.lostFoundResolvedEnabled) {
    score += _placeholderGain(stats.lostFoundResolved.length);
  }
  if (HelperTemperatureConfig.questionUpvotesEnabled) {
    score += _placeholderGain(stats.questionUpvotes.length);
  }
  if (HelperTemperatureConfig.moderationBlocksEnabled) {
    score -= _placeholderGain(stats.moderationBlocks.length);
  }

  if (HelperTemperatureConfig.decayEnabled && accepted.isNotEmpty) {
    score = _applyIdleDecay(
      score: score,
      lastCreditAt: accepted.last.occurredAt.toUtc(),
      asOfUtc: asOfUtc,
    );
  }

  return _clampScore(score);
}

List<AcceptedAnswerCreditEvent> _eligibleAcceptedAnswers(
  HelperTemperatureStats stats,
  DateTime asOfUtc,
) {
  final seen = <String>{};
  final eligible = <AcceptedAnswerCreditEvent>[];

  for (final raw in stats.acceptedAnswers) {
    if (!_isValidEventId(raw.eventId)) continue;
    if (!_isValidUserId(raw.questionAuthorId)) continue;
    if (!_isValidUserId(raw.answerAuthorId)) continue;
    if (raw.answerAuthorId != stats.userId) continue;
    if (raw.questionAuthorId == raw.answerAuthorId) continue;
    final at = raw.occurredAt.toUtc();
    if (at.isAfter(asOfUtc)) continue;
    if (seen.contains(raw.eventId)) continue;
    seen.add(raw.eventId);
    eligible.add(
      AcceptedAnswerCreditEvent(
        eventId: raw.eventId,
        occurredAt: at,
        questionAuthorId: raw.questionAuthorId,
        answerAuthorId: raw.answerAuthorId,
      ),
    );
  }

  eligible.sort((a, b) {
    final byTime = a.occurredAt.compareTo(b.occurredAt);
    if (byTime != 0) return byTime;
    return a.eventId.compareTo(b.eventId);
  });

  return eligible;
}

double _acceptedAnswerGain(List<AcceptedAnswerCreditEvent> accepted) {
  final dailyTotals = <String, double>{};
  var priorCount = 0;
  var totalGain = 0.0;

  for (final event in accepted) {
    final marginal = _marginalAcceptedGain(priorCount);
    priorCount++;

    final dayKey = _utcDayKey(event.occurredAt);
    final daySoFar = dailyTotals[dayKey] ?? 0.0;
    final room = HelperTemperatureConfig.maxDailyGain - daySoFar;
    if (room <= 0) continue;

    final applied = math.min(marginal, room);
    dailyTotals[dayKey] = daySoFar + applied;
    totalGain += applied;
  }

  return totalGain;
}

double _marginalAcceptedGain(int priorAcceptedCount) {
  final diminish = 1.0 /
      (1.0 + priorAcceptedCount * HelperTemperatureConfig.acceptedAnswerDiminishFactor);
  return HelperTemperatureConfig.acceptedAnswerBaseGain * diminish;
}

double _applyIdleDecay({
  required double score,
  required DateTime lastCreditAt,
  required DateTime asOfUtc,
}) {
  final baseline = HelperTemperatureConfig.baseline;
  if (score <= baseline) return score;

  final idleDays = asOfUtc.difference(lastCreditAt).inMicroseconds /
      Duration.microsecondsPerDay;
  if (idleDays < 1.0) return score;

  final excess = score - baseline;
  final retention = math.pow(
    1.0 - HelperTemperatureConfig.decayRatePerDay,
    idleDays,
  );
  return baseline + excess * retention;
}

double _clampScore(double score) {
  return score
      .clamp(HelperTemperatureConfig.minScore, HelperTemperatureConfig.maxScore)
      .toDouble();
}

String _utcDayKey(DateTime utc) {
  final u = utc.toUtc();
  return '${u.year.toString().padLeft(4, '0')}-'
      '${u.month.toString().padLeft(2, '0')}-'
      '${u.day.toString().padLeft(2, '0')}';
}

bool _isValidEventId(String id) => id.trim().isNotEmpty;

bool _isValidUserId(String id) => id.trim().isNotEmpty;

/// Reserved for disabled signals — must not affect score while toggles are false.
double _placeholderGain(int count) => count * 0.0;
