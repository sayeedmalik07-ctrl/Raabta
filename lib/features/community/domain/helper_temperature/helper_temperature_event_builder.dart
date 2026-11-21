import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:raabta/features/community/domain/helper_temperature/helper_temperature_models.dart';

/// Ask Qatar question + answers snapshot for pure acceptance-event extraction.
///
/// **Limitation:** Only the *current* accepted answer on each question is credited.
/// Re-acceptance moves credit to the new answer author; superseded accepts are
/// not kept as historical events.
class HelperTemperatureQuestionSnapshot {
  const HelperTemperatureQuestionSnapshot({
    required this.questionId,
    required this.questionAuthorId,
    this.acceptedAnswerId,
    this.solvedAt,
    this.answers = const [],
  });

  final String questionId;
  final String questionAuthorId;
  final String? acceptedAnswerId;
  final DateTime? solvedAt;
  final List<HelperTemperatureAnswerSnapshot> answers;
}

class HelperTemperatureAnswerSnapshot {
  const HelperTemperatureAnswerSnapshot({
    required this.answerId,
    required this.answerAuthorId,
    this.isAccepted = false,
  });

  final String answerId;
  final String answerAuthorId;
  final bool isAccepted;
}

/// Builds [AcceptedAnswerCreditEvent] list from stored question/answer fields only.
///
/// [eventId] is always [HelperTemperatureQuestionSnapshot.questionId].
/// Duplicate [questionId] entries must be credit-equivalent; otherwise that
/// question is skipped. Identical duplicates produce at most one event.
List<AcceptedAnswerCreditEvent> buildAcceptedAnswerCreditEvents({
  required DateTime asOf,
  required Iterable<HelperTemperatureQuestionSnapshot> questions,
}) {
  final asOfUtc = asOf.toUtc();
  final grouped = <String, List<HelperTemperatureQuestionSnapshot>>{};

  for (final question in questions) {
    final questionId = question.questionId.trim();
    if (questionId.isEmpty) continue;
    grouped.putIfAbsent(questionId, () => []).add(question);
  }

  final events = <AcceptedAnswerCreditEvent>[];
  final sortedIds = grouped.keys.toList()..sort();
  for (final questionId in sortedIds) {
    final snapshots = grouped[questionId]!;
    if (!_snapshotsAreCreditEquivalent(snapshots)) continue;
    final event = _buildEventForQuestion(snapshots.first, asOfUtc);
    if (event != null) {
      events.add(event);
    }
  }

  return events;
}

/// Convenience wrapper for Part A scoring (compute-only integration).
HelperTemperatureStats buildHelperTemperatureStats({
  required String userId,
  required DateTime asOf,
  required Iterable<HelperTemperatureQuestionSnapshot> questions,
}) {
  return HelperTemperatureStats(
    userId: userId,
    asOf: asOf,
    acceptedAnswers: buildAcceptedAnswerCreditEvents(
      asOf: asOf,
      questions: questions,
    ),
  );
}

AcceptedAnswerCreditEvent? _buildEventForQuestion(
  HelperTemperatureQuestionSnapshot question,
  DateTime asOfUtc,
) {
  final questionId = question.questionId.trim();
  final questionAuthorId = question.questionAuthorId.trim();
  final acceptedAnswerId = question.acceptedAnswerId?.trim() ?? '';

  if (questionId.isEmpty) return null;
  if (questionAuthorId.isEmpty) return null;
  if (acceptedAnswerId.isEmpty) return null;

  final solvedAt = _toUtcDateTime(question.solvedAt);
  if (solvedAt == null) return null;
  if (solvedAt.isAfter(asOfUtc)) return null;

  final answer = _findAcceptedAnswer(question, acceptedAnswerId);
  if (answer == null) return null;

  final answerAuthorId = answer.answerAuthorId.trim();
  if (answerAuthorId.isEmpty) return null;
  if (answerAuthorId == questionAuthorId) return null;
  if (!answer.isAccepted) return null;
  if (answer.answerId.trim() != acceptedAnswerId) return null;

  return AcceptedAnswerCreditEvent(
    eventId: questionId,
    occurredAt: solvedAt,
    questionAuthorId: questionAuthorId,
    answerAuthorId: answerAuthorId,
  );
}

HelperTemperatureAnswerSnapshot? _findAcceptedAnswer(
  HelperTemperatureQuestionSnapshot question,
  String acceptedAnswerId,
) {
  for (final answer in question.answers) {
    if (answer.answerId.trim() == acceptedAnswerId) {
      return answer;
    }
  }
  return null;
}

/// UTC normalization for Firestore-style values (no fallback to other fields).
DateTime? parseHelperTemperatureTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toUtc();
  if (value is DateTime) return value.toUtc();
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return parsed.toUtc();
  }
  return null;
}

DateTime? _toUtcDateTime(DateTime? value) {
  if (value == null) return null;
  return value.toUtc();
}

bool _snapshotsAreCreditEquivalent(
  List<HelperTemperatureQuestionSnapshot> snapshots,
) {
  if (snapshots.length <= 1) return true;
  final first = snapshots.first;
  for (var i = 1; i < snapshots.length; i++) {
    if (!_snapshotCreditEquivalent(first, snapshots[i])) {
      return false;
    }
  }
  return true;
}

bool _snapshotCreditEquivalent(
  HelperTemperatureQuestionSnapshot a,
  HelperTemperatureQuestionSnapshot b,
) {
  if (a.questionId.trim() != b.questionId.trim()) return false;
  if (a.questionAuthorId.trim() != b.questionAuthorId.trim()) return false;
  if ((a.acceptedAnswerId?.trim() ?? '') != (b.acceptedAnswerId?.trim() ?? '')) {
    return false;
  }

  final solvedA = _toUtcDateTime(a.solvedAt);
  final solvedB = _toUtcDateTime(b.solvedAt);
  if (solvedA == null && solvedB == null) {
    // Same missing solvedAt — continue to answer comparison.
  } else if (solvedA == null || solvedB == null) {
    return false;
  } else if (solvedA.microsecondsSinceEpoch != solvedB.microsecondsSinceEpoch) {
    return false;
  }

  final acceptedId = a.acceptedAnswerId?.trim() ?? '';
  if (acceptedId.isEmpty) {
    return (b.acceptedAnswerId?.trim() ?? '').isEmpty;
  }

  final answerA = _findAcceptedAnswer(a, acceptedId);
  final answerB = _findAcceptedAnswer(b, acceptedId);
  if (answerA == null && answerB == null) return true;
  if (answerA == null || answerB == null) return false;

  return answerA.answerId.trim() == answerB.answerId.trim() &&
      answerA.answerAuthorId.trim() == answerB.answerAuthorId.trim() &&
      answerA.isAccepted == answerB.isAccepted;
}
