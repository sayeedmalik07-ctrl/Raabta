import 'dart:async';

import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/services/lost_found_match_client.dart';
import 'package:raabta/features/community/domain/lost_found_private_detail.dart';
import 'package:raabta/features/community/services/community_moderation_dedup.dart';
import 'package:raabta/features/community/services/community_repository.dart';
import 'package:raabta/features/community/services/community_routing_log.dart';
import 'package:raabta/features/community/services/community_submission_prefilter.dart';

class EventModerationOutcome {
  const EventModerationOutcome({
    required this.eventId,
    required this.approved,
    required this.reason,
    this.skippedClaude = false,
  });

  final String eventId;
  final bool approved;
  final String reason;
  final bool skippedClaude;
}

class LostFoundPostOutcome {
  const LostFoundPostOutcome({
    required this.posted,
    required this.message,
    this.duplicateBlocked = false,
  });

  final bool posted;
  final String message;
  final bool duplicateBlocked;
}

/// Pre-filter → dedup → Claude moderation orchestration for community posts.
class CommunityModerationOrchestrator {
  CommunityModerationOrchestrator({
    required CommunityRepository repository,
    required CommunityModerationDedup dedup,
    required Future<({bool approved, String reason})> Function({
      required String title,
      required String description,
      required String location,
      List<String> suspiciousLinkDomains,
    }) verifyWithClaude,
  })  : _repository = repository,
        _dedup = dedup,
        _verifyWithClaude = verifyWithClaude;

  final CommunityRepository _repository;
  final CommunityModerationDedup _dedup;
  final Future<({bool approved, String reason})> Function({
    required String title,
    required String description,
    required String location,
    List<String> suspiciousLinkDomains,
  }) _verifyWithClaude;

  Future<({bool ok, String message, EventModerationOutcome? outcome})>
      submitEvent({
    String groupId = '',
    List<String> relevantGroupIds = const [],
    required String title,
    required String description,
    required String location,
    required DateTime dateTime,
  }) async {
    final pre = CommunitySubmissionPrefilter.validateEvent(
      title: title,
      description: description,
      location: location,
    );
    if (!pre.passed) {
      CommunityRoutingLog.prefilterBlock(
        contentType: 'event',
        reason: 'validation',
      );
      return (ok: false, message: pre.blockMessage!, outcome: null);
    }

    final uid = await _repository.currentUserId();
    final normalized = CommunityModerationDedup.normalizeEvent(
      title: title,
      description: description,
      location: location,
    );
    final hash = CommunityModerationDedup.hashContent(normalized);

    final cached = await _dedup.findRecent(
      userId: uid,
      contentType: 'event',
      contentHash: hash,
    );

    if (cached != null && !cached.isPending) {
      CommunityRoutingLog.dedupHit(
        contentType: 'event',
        verdict: cached.verdict,
      );
      if (cached.linkedDocId != null) {
        await _repository.updateEventVerification(
          eventId: cached.linkedDocId!,
          status: cached.isApprove ? 'approved' : 'rejected',
          note: cached.reason,
        );
        return (
          ok: true,
          message: '',
          outcome: EventModerationOutcome(
            eventId: cached.linkedDocId!,
            approved: cached.isApprove,
            reason: cached.reason,
            skippedClaude: true,
          ),
        );
      }
    }

    if (cached != null && cached.isPending && cached.linkedDocId != null) {
      CommunityRoutingLog.dedupHit(contentType: 'event', verdict: 'pending');
      return (
        ok: true,
        message: '',
        outcome: EventModerationOutcome(
          eventId: cached.linkedDocId!,
          approved: false,
          reason: 'Your event is already being reviewed.',
          skippedClaude: true,
        ),
      );
    }

    final eventId = await _repository.createEvent(
      groupId: groupId,
      relevantGroupIds: relevantGroupIds,
      title: title,
      description: description,
      location: location,
      dateTime: dateTime,
    );

    await _dedup.save(
      userId: uid,
      contentType: 'event',
      contentHash: hash,
      verdict: 'pending',
      reason: 'Awaiting AI review',
      linkedDocId: eventId,
    );

    CommunityRoutingLog.claudeModeration(
      contentType: 'event',
      suspiciousLinks: pre.suspiciousLinkDomains.isNotEmpty,
    );

    final result = await _verifyWithClaude(
      title: title,
      description: description,
      location: location,
      suspiciousLinkDomains: pre.suspiciousLinkDomains,
    );

    await _repository.updateEventVerification(
      eventId: eventId,
      status: result.approved ? 'approved' : 'rejected',
      note: result.reason,
    );

    await _dedup.save(
      userId: uid,
      contentType: 'event',
      contentHash: hash,
      verdict: result.approved ? 'approve' : 'reject',
      reason: result.reason,
      linkedDocId: eventId,
    );

    return (
      ok: true,
      message: '',
      outcome: EventModerationOutcome(
        eventId: eventId,
        approved: result.approved,
        reason: result.reason,
      ),
    );
  }

  Future<LostFoundPostOutcome> submitLostFound({
    String groupId = '',
    List<String> relevantGroupIds = const [],
    required String type,
    required String title,
    required String itemDescription,
    required String location,
    required DateTime dateOccurred,
    required String contactInfo,
    String? areaCode,
    String? photoUrl,
    LostFoundListingAttributes? attributes,
    String? finderHiddenDetail,
    String? itemType,
    String? marks,
  }) async {
    final pre = CommunitySubmissionPrefilter.validateLostFound(
      title: title,
      itemDescription: itemDescription,
      location: location,
      contactInfo: contactInfo,
      itemType: itemType ?? attributes?.itemType,
      marks: marks ?? attributes?.marks,
      hiddenDetail: finderHiddenDetail,
    );
    if (!pre.passed) {
      CommunityRoutingLog.prefilterBlock(
        contentType: 'lost_found',
        reason: 'validation',
      );
      return LostFoundPostOutcome(posted: false, message: pre.blockMessage!);
    }

    final uid = await _repository.currentUserId();
    final normalized = CommunityModerationDedup.normalizeLostFound(
      type: type,
      title: title,
      itemDescription: itemDescription,
      location: location,
      contactInfo: contactInfo,
    );
    final hash = CommunityModerationDedup.hashContent(normalized);

    final cached = await _dedup.findRecent(
      userId: uid,
      contentType: 'lost_found',
      contentHash: hash,
    );
    if (cached != null) {
      CommunityRoutingLog.dedupHit(
        contentType: 'lost_found',
        verdict: 'duplicate',
      );
      return LostFoundPostOutcome(
        posted: false,
        message: 'You already posted this listing recently.',
        duplicateBlocked: true,
      );
    }

    if (type == 'found' &&
        finderHiddenDetail != null &&
        finderHiddenDetail.trim().isNotEmpty &&
        LostFoundPrivateDetail.normalize(finderHiddenDetail) == null) {
      return const LostFoundPostOutcome(
        posted: false,
        message: 'community_lf_err_hidden_detail',
      );
    }

    var safePhotoUrl = photoUrl;
    if (LostFoundCategory.blocksPhoto(attributes?.category) &&
        safePhotoUrl != null &&
        safePhotoUrl.trim().isNotEmpty) {
      safePhotoUrl = null;
    }

    final itemId = await _repository.createLostFound(
      groupId: groupId,
      relevantGroupIds: relevantGroupIds,
      type: type,
      title: title,
      itemDescription: itemDescription,
      location: location,
      dateOccurred: dateOccurred,
      contactInfo: contactInfo,
      areaCode: areaCode,
      photoUrl: safePhotoUrl,
      attributes: attributes,
      finderHiddenDetail: finderHiddenDetail,
    );

    unawaited(LostFoundMatchClient().triggerMatch(listingId: itemId));

    await _dedup.save(
      userId: uid,
      contentType: 'lost_found',
      contentHash: hash,
      verdict: 'posted',
      reason: 'open',
    );

    return const LostFoundPostOutcome(
      posted: true,
      message: 'Listing posted successfully.',
    );
  }
}
