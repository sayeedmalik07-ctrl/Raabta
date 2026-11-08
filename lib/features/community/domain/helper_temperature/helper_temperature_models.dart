// Input events for Helper Temperature scoring (Part A). Times use UTC for caps/decay.

class AcceptedAnswerCreditEvent {
  const AcceptedAnswerCreditEvent({
    required this.eventId,
    required this.occurredAt,
    required this.questionAuthorId,
    required this.answerAuthorId,
  });

  final String eventId;
  final DateTime occurredAt;
  final String questionAuthorId;
  final String answerAuthorId;
}

/// Placeholder for Part B+; ignored while [HelperTemperatureConfig.helpfulVotesEnabled] is false.
class HelpfulVoteCreditEvent {
  const HelpfulVoteCreditEvent({
    required this.eventId,
    required this.occurredAt,
    required this.voterId,
    required this.contentAuthorId,
  });

  final String eventId;
  final DateTime occurredAt;
  final String voterId;
  final String contentAuthorId;
}

class GroupLikeCreditEvent {
  const GroupLikeCreditEvent({
    required this.eventId,
    required this.occurredAt,
    required this.likerId,
    required this.postAuthorId,
  });

  final String eventId;
  final DateTime occurredAt;
  final String likerId;
  final String postAuthorId;
}

class ModerationBlockEvent {
  const ModerationBlockEvent({
    required this.eventId,
    required this.occurredAt,
    required this.userId,
  });

  final String eventId;
  final DateTime occurredAt;
  final String userId;
}

class LostFoundResolvedEvent {
  const LostFoundResolvedEvent({
    required this.eventId,
    required this.occurredAt,
    required this.posterId,
  });

  final String eventId;
  final DateTime occurredAt;
  final String posterId;
}

class QuestionUpvoteCreditEvent {
  const QuestionUpvoteCreditEvent({
    required this.eventId,
    required this.occurredAt,
    required this.voterId,
    required this.questionAuthorId,
  });

  final String eventId;
  final DateTime occurredAt;
  final String voterId;
  final String questionAuthorId;
}

/// Snapshot of behaviour signals for one community member at [asOf].
class HelperTemperatureStats {
  const HelperTemperatureStats({
    required this.userId,
    required this.asOf,
    this.acceptedAnswers = const [],
    this.helpfulVotes = const [],
    this.groupLikes = const [],
    this.moderationBlocks = const [],
    this.lostFoundResolved = const [],
    this.questionUpvotes = const [],
  });

  final String userId;
  final DateTime asOf;
  final List<AcceptedAnswerCreditEvent> acceptedAnswers;
  final List<HelpfulVoteCreditEvent> helpfulVotes;
  final List<GroupLikeCreditEvent> groupLikes;
  final List<ModerationBlockEvent> moderationBlocks;
  final List<LostFoundResolvedEvent> lostFoundResolved;
  final List<QuestionUpvoteCreditEvent> questionUpvotes;
}
