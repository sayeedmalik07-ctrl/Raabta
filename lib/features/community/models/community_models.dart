import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/utils/community_group_tagging.dart';

class AskQatarQuestion {
  const AskQatarQuestion({
    required this.id,
    required this.title,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.body = '',
    this.votes = 0,
    this.answers = 0,
    this.views = 0,
    this.authorDisplayName = 'Member',
    this.votedBy = const [],
    this.acceptedAnswerId,
    this.solvedAt,
    this.relevantGroupIds = const [],
    this.searchKeywords = const [],
    this.kind,
    this.rumourCategoryId,
    this.trustedCommunityVerified = false,
    this.communityVerifiedAt,
    this.rumourRatingCount = 0,
    this.rumourRatingAverage = 0,
  });

  final String id;
  final String title;
  final String category;
  final String createdBy;
  final DateTime? createdAt;
  final String body;
  final int votes;
  final int answers;
  final int views;
  final String authorDisplayName;
  final List<String> votedBy;
  final String? acceptedAnswerId;
  final DateTime? solvedAt;
  final List<String> relevantGroupIds;
  final List<String> searchKeywords;
  final String? kind;
  final String? rumourCategoryId;

  /// Raw Firestore flag — use [RumourQuestionPresentation.readTrustedCommunityVerified].
  final bool trustedCommunityVerified;

  /// Set only by server admin verification (Part C).
  final DateTime? communityVerifiedAt;

  /// Server-maintained rumour rating aggregates (Part C).
  final int rumourRatingCount;
  final double rumourRatingAverage;

  AskQatarQuestionKind get questionKind =>
      RumourCheckModelParsing.questionKindFromStored(kind);

  bool get isRumourCheck => questionKind == AskQatarQuestionKind.rumourCheck;

  bool get isUnanswered => answers == 0;
  bool get isSolved =>
      !isRumourCheck &&
      acceptedAnswerId != null &&
      acceptedAnswerId!.trim().isNotEmpty;
  bool isUpvotedBy(String uid) => votedBy.contains(uid);
  bool isTaggedToGroup(String groupId) =>
      CommunityGroupTagging.isTaggedToGroup(relevantGroupIds, groupId);

  factory AskQatarQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AskQatarQuestion(
      id: doc.id,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
      body: data['body'] as String? ?? '',
      votes: data['votes'] as int? ?? 0,
      answers: data['answers'] as int? ?? 0,
      views: data['views'] as int? ?? 0,
      authorDisplayName: data['authorDisplayName'] as String? ?? 'Member',
      votedBy: List<String>.from(data['votedBy'] as List? ?? const []),
      acceptedAnswerId: data['acceptedAnswerId'] as String?,
      solvedAt: _toDate(data['solvedAt']),
      relevantGroupIds: CommunityGroupTagging.parseFromFirestore(data),
      searchKeywords: List<String>.from(
        data['searchKeywords'] as List? ?? const [],
      ),
      kind: data['kind'] as String?,
      rumourCategoryId: data['rumourCategoryId'] as String?,
      trustedCommunityVerified: data['communityVerified'] == true,
      communityVerifiedAt: _toDate(data['communityVerifiedAt']),
      rumourRatingCount: data['rumourRatingCount'] as int? ?? 0,
      rumourRatingAverage: (data['rumourRatingAverage'] as num?)?.toDouble() ?? 0,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// An answer on an Ask Qatar question.
class AskQatarAnswer {
  const AskQatarAnswer({
    required this.id,
    required this.questionId,
    required this.text,
    required this.createdBy,
    required this.authorDisplayName,
    required this.createdAt,
    this.helpfulCount = 0,
    this.helpfulBy = const [],
    this.isAccepted = false,
    this.officialSourceUrl,
  });

  final String id;
  final String questionId;
  final String text;
  final String createdBy;
  final String authorDisplayName;
  final DateTime? createdAt;
  final int helpfulCount;
  final List<String> helpfulBy;
  final bool isAccepted;

  /// Optional HTTPS source link for rumour context notes only.
  /// Trusted allowlist status is never read from Firestore — re-validate in UI.
  final String? officialSourceUrl;

  bool isMarkedHelpfulBy(String uid) => helpfulBy.contains(uid);

  factory AskQatarAnswer.fromFirestore(DocumentSnapshot doc, String questionId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AskQatarAnswer(
      id: doc.id,
      questionId: questionId,
      text: data['text'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      authorDisplayName: data['authorDisplayName'] as String? ?? 'Member',
      createdAt: _toDate(data['createdAt']),
      helpfulCount: data['helpfulCount'] as int? ?? 0,
      helpfulBy: List<String>.from(data['helpfulBy'] as List? ?? const []),
      isAccepted: data['isAccepted'] as bool? ?? false,
      officialSourceUrl: _optionalTrimmedString(data['officialSourceUrl']),
    );
  }

  static String? _optionalTrimmedString(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class CommunityEvent {
  const CommunityEvent({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    this.aiVerificationNote = '',
    this.relevantGroupIds = const [],
  });

  final String id;
  final String groupId;
  final String title;
  final String description;
  final String location;
  final DateTime? dateTime;
  final String createdBy;
  final DateTime? createdAt;
  final String status;
  final String aiVerificationNote;
  final List<String> relevantGroupIds;

  bool get isPending => status == 'pending_review';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool isTaggedToGroup(String groupId) =>
      CommunityGroupTagging.isTaggedToGroup(relevantGroupIds, groupId);

  factory CommunityEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CommunityEvent(
      id: doc.id,
      groupId: data['groupId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      dateTime: _toDate(data['dateTime']),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
      status: data['status'] as String? ?? 'pending_review',
      aiVerificationNote: data['aiVerificationNote'] as String? ?? '',
      relevantGroupIds: CommunityGroupTagging.parseFromFirestore(data),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class LostFoundItem {
  const LostFoundItem({
    required this.id,
    required this.groupId,
    required this.type,
    required this.itemDescription,
    required this.location,
    required this.dateOccurred,
    required this.contactInfo,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    this.photoUrl,
    this.title = '',
    this.areaCode,
    this.attributes,
    this.relevantGroupIds = const [],
  });

  final String id;
  final String groupId;
  final String type;
  final String itemDescription;
  final String location;
  final String? areaCode;
  final DateTime? dateOccurred;
  final String contactInfo;
  final String createdBy;
  final DateTime? createdAt;
  final String status;
  final String? photoUrl;
  final String title;
  final LostFoundListingAttributes? attributes;
  final List<String> relevantGroupIds;

  bool get isLost => type == 'lost';
  bool get isOpen => status == 'open';
  bool get isResolved => status == 'resolved';
  bool isTaggedToGroup(String groupId) =>
      CommunityGroupTagging.isTaggedToGroup(relevantGroupIds, groupId);

  factory LostFoundItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LostFoundItem(
      id: doc.id,
      groupId: data['groupId'] as String? ?? '',
      type: data['type'] as String? ?? 'lost',
      itemDescription: data['itemDescription'] as String? ?? '',
      location: data['location'] as String? ?? '',
      dateOccurred: _toDate(data['dateOccurred']),
      contactInfo: data['contactInfo'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
      status: data['status'] as String? ?? 'open',
      photoUrl: data['photoUrl'] as String?,
      areaCode: data['areaCode'] as String?,
      attributes: LostFoundAttributesValidation.parseFirestoreMap(
        data['attributes'] as Map<String, dynamic>?,
      ),
      title: data['title'] as String? ?? '',
      relevantGroupIds: CommunityGroupTagging.parseFromFirestore(data),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Owner-visible deterministic match hint (Stage 2 — no private fields).
class LostFoundMatchSummary {
  const LostFoundMatchSummary({
    required this.pairId,
    required this.otherItemId,
    required this.otherType,
    required this.otherTitle,
    required this.score,
    this.summary = '',
    this.matchedAt,
  });

  final String pairId;
  final String otherItemId;
  final String otherType;
  final String otherTitle;
  final int score;
  final String summary;
  final DateTime? matchedAt;

  factory LostFoundMatchSummary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LostFoundMatchSummary(
      pairId: data['pairId'] as String? ?? doc.id,
      otherItemId: data['otherItemId'] as String? ?? '',
      otherType: data['otherType'] as String? ?? '',
      otherTitle: data['otherTitle'] as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      summary: data['summary'] as String? ?? '',
      matchedAt: _lostFoundToDate(data['matchedAt']),
    );
  }

  static DateTime? _lostFoundToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// A post in a community group feed.
class GroupPost {
  const GroupPost({
    required this.id,
    required this.groupId,
    required this.text,
    required this.createdBy,
    required this.authorDisplayName,
    required this.authorInitials,
    required this.createdAt,
    this.authorFlag = '',
    this.likes = 0,
    this.commentCount = 0,
    this.likedBy = const [],
    this.imageUrl,
    this.isPinned = false,
    this.type = 'text',
    this.relevantGroupIds = const [],
  });

  final String id;
  final String groupId;
  final String text;
  final String createdBy;
  final String authorDisplayName;
  final String authorInitials;
  final DateTime? createdAt;
  final String authorFlag;
  final int likes;
  final int commentCount;
  final List<String> likedBy;
  final String? imageUrl;
  final bool isPinned;
  final String type;
  final List<String> relevantGroupIds;

  bool isLikedBy(String uid) => likedBy.contains(uid);
  bool isTaggedToGroup(String groupId) =>
      CommunityGroupTagging.isTaggedToGroup(relevantGroupIds, groupId);

  factory GroupPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GroupPost(
      id: doc.id,
      groupId: data['groupId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      authorDisplayName: data['authorDisplayName'] as String? ?? 'Member',
      authorInitials: data['authorInitials'] as String? ?? 'RM',
      createdAt: _toDate(data['createdAt']),
      authorFlag: data['authorFlag'] as String? ?? '',
      likes: data['likes'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? const []),
      imageUrl: data['imageUrl'] as String?,
      isPinned: data['isPinned'] as bool? ?? false,
      type: data['type'] as String? ?? 'text',
      relevantGroupIds: CommunityGroupTagging.parseFromFirestore(data),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// A comment on a group post.
class GroupComment {
  const GroupComment({
    required this.id,
    required this.postId,
    required this.text,
    required this.createdBy,
    required this.authorDisplayName,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String text;
  final String createdBy;
  final String authorDisplayName;
  final DateTime? createdAt;

  factory GroupComment.fromFirestore(DocumentSnapshot doc, String postId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GroupComment(
      id: doc.id,
      postId: postId,
      text: data['text'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      authorDisplayName: data['authorDisplayName'] as String? ?? 'Member',
      createdAt: _toDate(data['createdAt']),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Admin-visible moderation decision log entry.
class ModerationLogEntry {
  const ModerationLogEntry({
    required this.id,
    required this.userId,
    required this.contentType,
    required this.excerpt,
    required this.contentHash,
    required this.language,
    required this.allowed,
    required this.layer,
    required this.createdAt,
    this.category,
    this.groupId,
  });

  final String id;
  final String userId;
  final String contentType;
  final String excerpt;
  final String contentHash;
  final String language;
  final bool allowed;
  final String layer;
  final DateTime? createdAt;
  final String? category;
  final String? groupId;

  factory ModerationLogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ModerationLogEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      contentType: data['contentType'] as String? ?? '',
      excerpt: data['excerpt'] as String? ?? '',
      contentHash: data['contentHash'] as String? ?? '',
      language: data['language'] as String? ?? 'English',
      allowed: data['allowed'] as bool? ?? false,
      layer: data['layer'] as String? ?? 'local',
      createdAt: _toDate(data['createdAt']),
      category: data['category'] as String?,
      groupId: data['groupId'] as String?,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
