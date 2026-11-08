import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_check_config.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_context_note_submit.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/services/community_pulse_service.dart';
import 'package:raabta/features/community/domain/lost_found_area.dart';
import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/domain/lost_found_match_policy.dart';
import 'package:raabta/features/community/domain/lost_found_match_visibility.dart';
import 'package:raabta/features/community/domain/lost_found_private_detail.dart';
import 'package:raabta/features/community/utils/community_group_tagging.dart';
import 'package:raabta/features/community/utils/community_visibility_reasons.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:raabta/services/smart_notification_engine.dart';

class CommunityRepository {
  CommunityRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static bool _isPermissionDenied(Object error) {
    return error is FirebaseException && error.code == 'permission-denied';
  }

  Stream<T> _withPermissionFallback<T>(Stream<T> stream, T fallback) {
    return stream.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) {
          if (_isPermissionDenied(error)) {
            sink.add(fallback);
            sink.close();
            return;
          }
          sink.addError(error, stackTrace);
        },
      ),
    );
  }

  Future<T> _withPermissionFallbackFuture<T>(
    Future<T> future,
    T fallback,
  ) async {
    try {
      return await future;
    } catch (error) {
      if (_isPermissionDenied(error)) return fallback;
      rethrow;
    }
  }

  Future<String> currentUserId() async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null) return authUid;
    return RaabtaNotificationService.instance.getOrCreateUserId();
  }

  // ─── Membership ─────────────────────────────────────────

  Stream<Set<int>> watchMembershipIds(String uid) {
    if (!FirebaseService.isReady) {
      return Stream.value({0, 1});
    }
    return _withPermissionFallback(
      _db
          .collection('users')
          .doc(uid)
          .collection('community_memberships')
          .snapshots()
          .map((snap) {
        if (snap.docs.isEmpty) return {0, 1};
        return snap.docs
            .map((d) =>
                int.tryParse(d.id) ?? int.tryParse('${d.data()['groupId']}') ?? -1)
            .where((id) => id >= 0)
            .toSet();
      }),
      {0, 1},
    );
  }

  Future<void> setMembership(String uid, int groupId, bool joined) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('community_memberships')
        .doc('$groupId');
    if (joined) {
      await ref.set({
        'groupId': '$groupId',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  // ─── Ask Qatar ────────────────────────────────────────────

  /// One-shot fetch for similar-question lookup (no stream listener).
  Future<List<AskQatarQuestion>> fetchRecentQuestionsForSimilarity({
    required String category,
    int limit = 50,
  }) async {
    try {
      final snap = await _db
          .collection('ask_qatar_questions')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map(AskQatarQuestion.fromFirestore).toList();
    } catch (_) {
      final snap = await _db
          .collection('ask_qatar_questions')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snap.docs
          .map(AskQatarQuestion.fromFirestore)
          .where((q) => q.category == category)
          .take(limit)
          .toList();
    }
  }

  Future<List<AskQatarQuestion>> fetchQuestionsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final results = <AskQatarQuestion>[];
    for (final id in ids) {
      final snap = await _db.collection('ask_qatar_questions').doc(id).get();
      if (snap.exists) {
        results.add(AskQatarQuestion.fromFirestore(snap));
      }
    }
    return results;
  }

  Stream<List<AskQatarQuestion>> watchQuestions() {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _withPermissionFallback(
      _db
          .collection('ask_qatar_questions')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map((snap) => snap.docs.map(AskQatarQuestion.fromFirestore).toList()),
      const [],
    );
  }

  Stream<AskQatarQuestion?> watchQuestion(String questionId) {
    if (!FirebaseService.isReady) return Stream.value(null);
    return _db
        .collection('ask_qatar_questions')
        .doc(questionId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return AskQatarQuestion.fromFirestore(snap);
    });
  }

  Stream<List<AskQatarAnswer>> watchQuestionAnswers(String questionId) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _db
        .collection('ask_qatar_questions')
        .doc(questionId)
        .collection('answers')
        .orderBy('createdAt', descending: false)
        .limit(50)
        .snapshots()
        .map(
          (snap) {
            final answers = snap.docs
                .map((d) => AskQatarAnswer.fromFirestore(d, questionId))
                .toList();
            answers.sort((a, b) {
              if (a.isAccepted && !b.isAccepted) return -1;
              if (b.isAccepted && !a.isAccepted) return 1;
              final helpful = b.helpfulCount.compareTo(a.helpfulCount);
              if (helpful != 0) return helpful;
              final da = a.createdAt ?? DateTime(0);
              final db = b.createdAt ?? DateTime(0);
              return da.compareTo(db);
            });
            return answers;
          },
        );
  }

  Future<void> submitQuestion({
    required String title,
    required String category,
    String body = '',
    List<String> relevantGroupIds = const [],
  }) async {
    final uid = await currentUserId();
    final display = _displayNameFor(uid);
    final tags = CommunityGroupTagging.normalize(relevantGroupIds);
    await _db.collection('ask_qatar_questions').add({
      'title': title.trim(),
      'category': category,
      'body': body.trim(),
      'createdBy': uid,
      'authorDisplayName': display.$1,
      'createdAt': FieldValue.serverTimestamp(),
      'votes': 0,
      'answers': 0,
      'views': 0,
      'votedBy': <String>[],
      'groupId': CommunityGroupTagging.primaryGroupId(tags),
      'relevantGroupIds': tags,
      'searchKeywords': SearchKeywordTokenizer.buildFromFields([
        title,
        category,
        body,
      ]),
    });
  }

  Future<void> submitRumourCheckQuestion({
    required String title,
    required String body,
    required String rumourCategoryId,
    List<String> relevantGroupIds = const [],
  }) async {
    final uid = await currentUserId();
    final display = _displayNameFor(uid);
    final tags = CommunityGroupTagging.normalize(relevantGroupIds);
    const categoryLabel = 'Rumour';
    await _db.collection('ask_qatar_questions').add({
      'kind': RumourCheckConfig.rumourCheckKind,
      'title': title.trim(),
      'category': categoryLabel,
      'rumourCategoryId': rumourCategoryId.trim(),
      'body': body.trim(),
      'createdBy': uid,
      'authorDisplayName': display.$1,
      'createdAt': FieldValue.serverTimestamp(),
      'votes': 0,
      'answers': 0,
      'views': 0,
      'votedBy': <String>[],
      'groupId': CommunityGroupTagging.primaryGroupId(tags),
      'relevantGroupIds': tags,
      'searchKeywords': SearchKeywordTokenizer.buildFromFields([
        title,
        categoryLabel,
        rumourCategoryId,
        body,
      ]),
    });
  }

  Future<void> submitAnswer({
    required String questionId,
    required String answerText,
  }) async {
    final uid = await currentUserId();
    final display = _displayNameFor(uid);
    final qRef = _db.collection('ask_qatar_questions').doc(questionId);
    final qSnap = await qRef.get();
    final qData = qSnap.data() ?? {};
    final authorId = qData['createdBy'] as String? ?? '';
    final questionTitle = qData['title'] as String? ?? 'your question';

    await qRef.collection('answers').add({
      'text': answerText.trim(),
      'createdBy': uid,
      'authorDisplayName': display.$1,
      'createdAt': FieldValue.serverTimestamp(),
      'helpfulCount': 0,
      'helpfulBy': <String>[],
      'isAccepted': false,
    });
    await qRef.update({'answers': FieldValue.increment(1)});

    if (authorId.isNotEmpty && authorId != uid) {
      final preview = answerText.trim();
      await SmartNotificationEngine.instance.notifyAskQatarAnswer(
        questionId: questionId,
        questionTitle: questionTitle,
        authorUserId: authorId,
        replyPreview: preview.length > 80
            ? '${preview.substring(0, 80)}…'
            : preview,
      );
    }
  }

  /// Rumour Check context note — same answers subcollection, optional source URL.
  Future<void> submitRumourContextNote({
    required String questionId,
    required String noteText,
    String officialSourceUrl = '',
  }) async {
    final decision =
        RumourContextNoteSubmit.evaluateSourceUrl(officialSourceUrl);
    if (!decision.canSubmit) {
      throw ArgumentError(decision.blockReasonKey ?? 'community_rumour_source_invalid');
    }

    final uid = await currentUserId();
    final display = _displayNameFor(uid);
    final qRef = _db.collection('ask_qatar_questions').doc(questionId);
    final qSnap = await qRef.get();
    final qData = qSnap.data() ?? {};
    final authorId = qData['createdBy'] as String? ?? '';
    final questionTitle = qData['title'] as String? ?? 'your question';

    final answerPayload = <String, dynamic>{
      'text': noteText.trim(),
      'createdBy': uid,
      'authorDisplayName': display.$1,
      'createdAt': FieldValue.serverTimestamp(),
      'helpfulCount': 0,
      'helpfulBy': <String>[],
      'isAccepted': false,
    };
    final urlToStore = decision.officialSourceUrlToStore;
    if (urlToStore != null && urlToStore.isNotEmpty) {
      answerPayload['officialSourceUrl'] = urlToStore;
    }

    await qRef.collection('answers').add(answerPayload);
    await qRef.update({'answers': FieldValue.increment(1)});

    if (authorId.isNotEmpty && authorId != uid) {
      final preview = noteText.trim();
      await SmartNotificationEngine.instance.notifyAskQatarAnswer(
        questionId: questionId,
        questionTitle: questionTitle,
        authorUserId: authorId,
        replyPreview: preview.length > 80
            ? '${preview.substring(0, 80)}…'
            : preview,
      );
    }
  }

  Future<void> toggleQuestionUpvote({
    required String questionId,
    required String uid,
    required bool upvote,
  }) async {
    final ref = _db.collection('ask_qatar_questions').doc(questionId);
    if (upvote) {
      await ref.update({
        'votes': FieldValue.increment(1),
        'votedBy': FieldValue.arrayUnion([uid]),
      });
    } else {
      await ref.update({
        'votes': FieldValue.increment(-1),
        'votedBy': FieldValue.arrayRemove([uid]),
      });
    }
  }

  Future<void> toggleAnswerHelpful({
    required String questionId,
    required String answerId,
    required String uid,
    required bool helpful,
  }) async {
    final ref = _db
        .collection('ask_qatar_questions')
        .doc(questionId)
        .collection('answers')
        .doc(answerId);
    if (helpful) {
      await ref.update({
        'helpfulCount': FieldValue.increment(1),
        'helpfulBy': FieldValue.arrayUnion([uid]),
      });
    } else {
      await ref.update({
        'helpfulCount': FieldValue.increment(-1),
        'helpfulBy': FieldValue.arrayRemove([uid]),
      });
    }
  }

  Future<void> markAcceptedAnswer({
    required String questionId,
    required String answerId,
    required String questionAuthorId,
  }) async {
    final qRef = _db.collection('ask_qatar_questions').doc(questionId);
    final qSnap = await qRef.get();
    final qData = qSnap.data() ?? {};
    if (qData['createdBy'] != questionAuthorId) {
      throw StateError('Only the question author may accept an answer.');
    }

    final answerRef = qRef.collection('answers').doc(answerId);
    final answerSnap = await answerRef.get();
    if (!answerSnap.exists) {
      throw StateError('Answer not found.');
    }
    final answerAuthorId = answerSnap.data()?['createdBy'] as String? ?? '';
    if (answerAuthorId == questionAuthorId) {
      throw StateError('Cannot accept your own answer.');
    }

    final questionTitle = qData['title'] as String? ?? 'your question';
    final previousAccepted = qData['acceptedAnswerId'] as String?;

    final answersSnap = await qRef.collection('answers').get();
    final batch = _db.batch();
    for (final doc in answersSnap.docs) {
      batch.update(doc.reference, {
        'isAccepted': doc.id == answerId,
      });
    }
    batch.update(qRef, {
      'acceptedAnswerId': answerId,
      'solvedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    if (answerAuthorId.isNotEmpty && previousAccepted != answerId) {
      try {
        await SmartNotificationEngine.instance.notifyAskQatarAnswerAccepted(
          questionId: questionId,
          questionTitle: questionTitle,
          answerAuthorUserId: answerAuthorId,
          answerId: answerId,
        );
      } catch (_) {
        // Best-effort — acceptance is already persisted.
      }
    }
  }

  Future<void> incrementQuestionViews(String questionId) async {
    await _db.collection('ask_qatar_questions').doc(questionId).update({
      'views': FieldValue.increment(1),
    });
  }

  // ─── Events ───────────────────────────────────────────────

  Stream<List<CommunityEvent>> watchApprovedEvents() {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _withPermissionFallback(
      _db
          .collection('community_events')
          .where('status', isEqualTo: 'approved')
          .limit(50)
          .snapshots()
          .map((snap) {
        final events = snap.docs.map(CommunityEvent.fromFirestore).toList();
        events.sort((a, b) {
          final da = a.dateTime ?? DateTime(2100);
          final db = b.dateTime ?? DateTime(2100);
          return da.compareTo(db);
        });
        return events;
      }),
      const [],
    );
  }

  Stream<List<CommunityEvent>> watchCreatorPendingEvents(String uid) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _db
        .collection('community_events')
        .where('createdBy', isEqualTo: uid)
        .where('status', whereIn: ['pending_review', 'rejected'])
        .snapshots()
        .map((snap) => snap.docs.map(CommunityEvent.fromFirestore).toList());
  }

  Future<String> createEvent({
    String groupId = '',
    List<String> relevantGroupIds = const [],
    required String title,
    required String description,
    required String location,
    required DateTime dateTime,
  }) async {
    final uid = await currentUserId();
    final tags = CommunityGroupTagging.normalize(
      relevantGroupIds.isNotEmpty ? relevantGroupIds : [if (groupId.isNotEmpty) groupId],
    );
    final doc = await _db.collection('community_events').add({
      'groupId': CommunityGroupTagging.primaryGroupId(tags),
      'relevantGroupIds': tags,
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'dateTime': Timestamp.fromDate(dateTime),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending_review',
      'aiVerificationNote': '',
      'searchKeywords': SearchKeywordTokenizer.buildFromFields([
        title,
        description,
        location,
      ]),
    });
    return doc.id;
  }

  Future<void> updateEventVerification({
    required String eventId,
    required String status,
    required String note,
  }) async {
    await _db.collection('community_events').doc(eventId).set({
      'status': status,
      'aiVerificationNote': note,
      'reviewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resubmitEvent({
    required String eventId,
    required String title,
    required String description,
    required String location,
    required DateTime dateTime,
  }) async {
    await _db.collection('community_events').doc(eventId).set({
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'dateTime': Timestamp.fromDate(dateTime),
      'status': 'pending_review',
      'aiVerificationNote': '',
      'searchKeywords': SearchKeywordTokenizer.buildFromFields([
        title,
        description,
        location,
      ]),
    }, SetOptions(merge: true));
  }

  // ─── Lost & Found ─────────────────────────────────────────

  Stream<List<LostFoundItem>> watchLostFound({String? type}) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _withPermissionFallback(
      _db
          .collection('lost_and_found')
          .where('status', isEqualTo: 'open')
          .limit(80)
          .snapshots()
          .map((snap) {
        var items = snap.docs.map(LostFoundItem.fromFirestore).toList();
        items.sort((a, b) {
          final da = a.createdAt ?? DateTime(0);
          final db = b.createdAt ?? DateTime(0);
          return db.compareTo(da);
        });
        if (type != null) {
          items = items.where((i) => i.type == type).toList();
        }
        return items;
      }),
      const [],
    );
  }

  Stream<List<LostFoundItem>> watchResolvedLostFound(String uid) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _db
        .collection('lost_and_found')
        .where('createdBy', isEqualTo: uid)
        .where('status', isEqualTo: 'resolved')
        .limit(20)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map(LostFoundItem.fromFirestore).toList();
      items.sort((a, b) {
        final da = a.createdAt ?? DateTime(0);
        final db = b.createdAt ?? DateTime(0);
        return db.compareTo(da);
      });
      return items;
    });
  }

  Future<String> createLostFound({
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
  }) async {
    final uid = await currentUserId();
    final normalizedArea = LostFoundArea.normalizeAreaCode(areaCode);
    final attrsMap = LostFoundAttributesValidation.toFirestore(attributes);
    final blocksPhoto = LostFoundCategory.blocksPhoto(
      attrsMap?['category'] as String?,
    );
    final tags = CommunityGroupTagging.normalize(
      relevantGroupIds.isNotEmpty ? relevantGroupIds : [if (groupId.isNotEmpty) groupId],
    );
    final primary = CommunityGroupTagging.primaryGroupId(tags);
    String? safePhotoUrl;
    if (!blocksPhoto &&
        photoUrl != null &&
        photoUrl.trim().isNotEmpty) {
      safePhotoUrl = photoUrl.trim();
    }
    final doc = await _db.collection('lost_and_found').add({
      'groupId': primary,
      'relevantGroupIds': tags,
      'type': type,
      'title': title.trim(),
      'itemDescription': itemDescription.trim(),
      'location': location.trim(),
      if (normalizedArea != null) 'areaCode': normalizedArea,
      'dateOccurred': Timestamp.fromDate(dateOccurred),
      'contactInfo': contactInfo.trim(),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'open',
      if (safePhotoUrl != null) 'photoUrl': safePhotoUrl,
      if (attrsMap != null) 'attributes': attrsMap,
      'searchKeywords': SearchKeywordTokenizer.buildFromFields([
        title,
        itemDescription,
        location,
        if (normalizedArea != null) normalizedArea,
        if (attrsMap != null) attrsMap['category']?.toString() ?? '',
        if (attrsMap != null) attrsMap['brand']?.toString() ?? '',
        if (attrsMap != null) attrsMap['item_type']?.toString() ?? '',
        type,
      ]),
    });

    if (type == 'found') {
      final hidden = LostFoundPrivateDetail.normalize(finderHiddenDetail);
      if (hidden != null) {
        await doc.collection(LostFoundPrivateDetail.subcollection).doc(
              LostFoundPrivateDetail.documentId,
            ).set({
          'hiddenDetail': hidden,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    if (primary.isNotEmpty) {
      await SmartNotificationEngine.instance.notifyLostFoundPosted(
        itemId: doc.id,
        groupId: primary,
        title: title.trim(),
        type: type,
        posterUserId: uid,
      );
    }

    return doc.id;
  }

  Stream<List<LostFoundMatchSummary>> watchLostFoundMatches(String itemId) {
    final matchesQuery = _db
        .collection('lost_and_found')
        .doc(itemId)
        .collection(LostFoundMatchPolicy.matchesSubcollection)
        .orderBy('matchedAt', descending: true);
    final dismissQuery = _db
        .collection('lost_and_found')
        .doc(itemId)
        .collection(LostFoundMatchPolicy.dismissalsSubcollection);

    return Stream<List<LostFoundMatchSummary>>.multi((controller) {
      QuerySnapshot<Map<String, dynamic>>? latestMatches;
      QuerySnapshot<Map<String, dynamic>>? latestDismissals;

      void emitCombined() {
        if (latestMatches == null || latestDismissals == null) return;
        final dismissed =
            latestDismissals!.docs.map((doc) => doc.id).toSet();
        final matches =
            latestMatches!.docs.map(LostFoundMatchSummary.fromFirestore).toList();
        controller.add(
          LostFoundMatchVisibility.withoutDismissed(
            matches: matches,
            dismissedPairIds: dismissed,
          ),
        );
      }

      late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
          matchesSub;
      late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
          dismissSub;

      matchesSub = matchesQuery.snapshots().listen(
        (snap) {
          latestMatches = snap;
          emitCombined();
        },
        onError: controller.addError,
      );
      dismissSub = dismissQuery.snapshots().listen(
        (snap) {
          latestDismissals = snap;
          emitCombined();
        },
        onError: controller.addError,
      );

      controller.onCancel = () async {
        await matchesSub.cancel();
        await dismissSub.cancel();
      };
    });
  }

  Future<void> dismissLostFoundMatch({
    required String itemId,
    required String pairId,
    required String otherItemId,
  }) async {
    final uid = await currentUserId();
    final ownerSnap = await _db.collection('lost_and_found').doc(itemId).get();
    final owner = ownerSnap.data()?['createdBy'] as String? ?? '';
    if (owner != uid) {
      throw StateError('not_owner');
    }
    await _db
        .collection('lost_and_found')
        .doc(itemId)
        .collection(LostFoundMatchPolicy.dismissalsSubcollection)
        .doc(pairId)
        .set({
      'pairId': pairId,
      'otherItemId': otherItemId,
      'dismissedBy': uid,
      'dismissedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveLostFound(String itemId) async {
    final snap = await _db.collection('lost_and_found').doc(itemId).get();
    final data = snap.data() ?? {};

    await _db.collection('lost_and_found').doc(itemId).set({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final posterId = data['createdBy'] as String? ?? '';
    if (posterId.isNotEmpty) {
      await SmartNotificationEngine.instance.notifyLostFoundResolved(
        itemId: itemId,
        title: data['title'] as String? ?? 'your item',
        posterUserId: posterId,
      );
    }
  }

  // ─── Group posts & comments ───────────────────────────────────────────────

  Stream<List<GroupPost>> watchGroupPosts(String groupId) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _db
        .collection('community_group_posts')
        .where(
          Filter.or(
            Filter('relevantGroupIds', arrayContains: groupId),
            Filter('groupId', isEqualTo: groupId),
          ),
        )
        .orderBy('createdAt', descending: true)
        .limit(80)
        .snapshots()
        .map((snap) {
      final posts = snap.docs.map(GroupPost.fromFirestore).toList();
      posts.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (b.isPinned && !a.isPinned) return 1;
        final da = a.createdAt ?? DateTime(0);
        final db = b.createdAt ?? DateTime(0);
        return db.compareTo(da);
      });
      return posts;
    });
  }

  Stream<List<GroupPost>> watchRecentGroupPosts({int limit = 100}) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _withPermissionFallback(
      _db
          .collection('community_group_posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(GroupPost.fromFirestore).toList()),
      const [],
    );
  }

  Stream<List<GroupPost>> watchTrendingGroupPosts({int limit = 10}) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _withPermissionFallback(
      _db
          .collection('community_group_posts')
          .orderBy('likes', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(GroupPost.fromFirestore).toList()),
      const [],
    );
  }

  Stream<List<GroupComment>> watchPostComments(String postId) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _db
        .collection('community_group_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => GroupComment.fromFirestore(d, postId))
              .toList(),
        );
  }

  Future<String> createGroupPost({
    String groupId = '',
    List<String> relevantGroupIds = const [],
    required String text,
    String? imageUrl,
  }) async {
    final uid = await currentUserId();
    final display = _displayNameFor(uid);
    final tags = CommunityGroupTagging.normalize(
      relevantGroupIds.isNotEmpty ? relevantGroupIds : [if (groupId.isNotEmpty) groupId],
    );
    final doc = await _db.collection('community_group_posts').add({
      'groupId': CommunityGroupTagging.primaryGroupId(tags),
      'relevantGroupIds': tags,
      'text': text.trim(),
      'createdBy': uid,
      'authorDisplayName': display.$1,
      'authorInitials': display.$2,
      'authorFlag': '',
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
      'commentCount': 0,
      'likedBy': <String>[],
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'isPinned': false,
      'type': 'text',
      'searchKeywords': SearchKeywordTokenizer.buildFromFields([text]),
    });
    return doc.id;
  }

  Future<void> createGroupComment({
    required String postId,
    required String text,
  }) async {
    final uid = await currentUserId();
    final display = _displayNameFor(uid);
    final postRef = _db.collection('community_group_posts').doc(postId);
    await postRef.collection('comments').add({
      'text': text.trim(),
      'createdBy': uid,
      'authorDisplayName': display.$1,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await postRef.update({'commentCount': FieldValue.increment(1)});
  }

  Future<void> toggleGroupPostLike({
    required String postId,
    required String uid,
    required bool like,
  }) async {
    final ref = _db.collection('community_group_posts').doc(postId);
    if (like) {
      await ref.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([uid]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([uid]),
      });
    }
  }

  Stream<List<ModerationLogEntry>> watchModerationLog({int limit = 100}) {
    if (!FirebaseService.isReady) return Stream.value([]);
    return _db
        .collection('moderation_log')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ModerationLogEntry.fromFirestore).toList());
  }

  /// Cheap count() aggregations for Community Pulse (Part D).
  Future<CommunityPulseCounts> fetchPulseCounts() async {
    if (!FirebaseService.isReady) {
      return const CommunityPulseCounts(
        trendingDiscussions: 0,
        eventsToday: 0,
        openQuestions: 0,
      );
    }

    return _withPermissionFallbackFuture(
      () async {
        final (dayStartUtc, dayEndUtc) = CommunityPulseTime.qatarTodayUtcRange();
        final trendingThreshold = CommunityVisibilityReasons.trendingLikeThreshold;

        final results = await Future.wait([
          _db
              .collection('community_group_posts')
              .where('likes', isGreaterThanOrEqualTo: trendingThreshold)
              .count()
              .get(),
          _db
              .collection('community_events')
              .where('status', isEqualTo: 'approved')
              .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStartUtc))
              .where('dateTime', isLessThan: Timestamp.fromDate(dayEndUtc))
              .count()
              .get(),
          _db
              .collection('ask_qatar_questions')
              .where('answers', isEqualTo: 0)
              .count()
              .get(),
        ]);

        return CommunityPulseCounts(
          trendingDiscussions: results[0].count ?? 0,
          eventsToday: results[1].count ?? 0,
          openQuestions: results[2].count ?? 0,
        );
      }(),
      const CommunityPulseCounts(
        trendingDiscussions: 0,
        eventsToday: 0,
        openQuestions: 0,
      ),
    );
  }

  (String, String) _displayNameFor(String uid) {
    if (uid.length >= 4) {
      return ('Member ${uid.substring(uid.length - 4)}', uid.substring(0, 2).toUpperCase());
    }
    return ('Raabta Member', 'RM');
  }
}

class EventVerificationService {
  EventVerificationService(this._verifyViaBackend);

  final Future<Map<String, dynamic>> Function({
    required String title,
    required String description,
    required String location,
  }) _verifyViaBackend;

  Future<({bool approved, String reason})> verify({
    required String title,
    required String description,
    required String location,
  }) async {
    try {
      final result = await _verifyViaBackend(
        title: title,
        description: description,
        location: location,
      );
      final verdict = (result['verdict'] as String? ?? '').toLowerCase();
      final reason = result['reason'] as String? ?? 'Review complete';
      return (approved: verdict == 'approve', reason: reason);
    } catch (e) {
      return (approved: false, reason: 'Verification failed. Please try again.');
    }
  }

  static ({bool approved, String reason}) parseClaudeJson(String reply) {
    try {
      final start = reply.indexOf('{');
      final end = reply.lastIndexOf('}');
      if (start < 0 || end <= start) {
        return (approved: false, reason: 'Could not parse AI response');
      }
      final json = jsonDecode(reply.substring(start, end + 1)) as Map<String, dynamic>;
      final verdict = (json['verdict'] as String? ?? '').toLowerCase();
      return (
        approved: verdict == 'approve',
        reason: json['reason'] as String? ?? 'Review complete',
      );
    } catch (_) {
      return (approved: false, reason: 'Could not parse AI response');
    }
  }
}
