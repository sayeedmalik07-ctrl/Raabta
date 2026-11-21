import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/models/community_nationality_suggestion.dart';
import 'package:raabta/features/community/models/community_pulse_snapshot.dart';
import 'package:raabta/features/community/services/community_moderation_dedup.dart';
import 'package:raabta/features/community/services/community_moderation_orchestrator.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_service.dart';
import 'package:raabta/features/community/services/lost_found_photo_service.dart';
import 'package:raabta/features/community/services/community_moderation_rephrase_service.dart';
import 'package:raabta/features/community/services/community_post_moderation_service.dart';
import 'package:raabta/features/community/services/community_pulse_service.dart';
import 'package:raabta/features/community/services/community_nationality_suggestion_service.dart';
import 'package:raabta/features/community/services/community_repository.dart';
import 'package:raabta/features/community/services/confidential_community_report_service.dart';
import 'package:raabta/features/eosb/providers/home_country_support_providers.dart';
import 'package:raabta/features/community/data/community_content_labels.dart';
import 'package:raabta/features/leaving_qatar/providers/leaving_qatar_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/services/news_service.dart';
import 'package:raabta/services/qatar_events_service.dart';

final communityPulseProvider =
    FutureProvider.autoDispose<CommunityPulseSnapshot>((ref) async {
  return CommunityPulseService(
    repository: ref.watch(communityRepositoryProvider),
  ).fetch();
});

final confidentialCommunityReportServiceProvider =
    Provider<ConfidentialCommunityReportService>((ref) {
  return ConfidentialCommunityReportService(
    communityRepository: ref.watch(communityRepositoryProvider),
  );
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

final communityUserIdProvider = FutureProvider<String>((ref) async {
  return ref.watch(communityRepositoryProvider).currentUserId();
});

class CommunityMembershipNotifier extends StateNotifier<AsyncValue<Set<int>>> {
  CommunityMembershipNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  final CommunityRepository _repo;
  String? _uid;

  Future<void> _init() async {
    try {
      _uid = await _repo.currentUserId();
      _repo.watchMembershipIds(_uid!).listen(
        (ids) => state = AsyncValue.data(ids),
        onError: (e, st) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            state = const AsyncValue.data({0, 1});
            return;
          }
          state = AsyncValue.error(e, st);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(int groupId) async {
    final uid = _uid ?? await _repo.currentUserId();
    _uid = uid;
    final current = state.value ?? {0, 1};
    final joined = current.contains(groupId);
    final next = Set<int>.from(current);
    if (joined) {
      next.remove(groupId);
    } else {
      next.add(groupId);
    }
    state = AsyncValue.data(next);
    try {
      await _repo.setMembership(uid, groupId, !joined);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final communityMembershipProvider =
    StateNotifierProvider<CommunityMembershipNotifier, AsyncValue<Set<int>>>(
  (ref) => CommunityMembershipNotifier(ref.watch(communityRepositoryProvider)),
);

final communityNationalitySuggestionProvider =
    FutureProvider.autoDispose<CommunityNationalitySuggestionView>((ref) async {
  final userContext = await ref.watch(homeCountryUserContextProvider.future);
  final joined = ref.watch(communityMembershipProvider).value ?? {0, 1};
  final locale = ref.watch(userLanguageProvider);
  return CommunityNationalitySuggestionService.resolve(
    nationality: userContext.nationality,
    joinedGroupIds: joined,
    locale: locale,
  );
});

final askQatarQuestionsProvider =
    StreamProvider.autoDispose<List<AskQatarQuestion>>((ref) {
  return ref.watch(communityRepositoryProvider).watchQuestions();
});

final askQatarQuestionProvider =
    StreamProvider.autoDispose.family<AskQatarQuestion?, String>((ref, id) {
  return ref.watch(communityRepositoryProvider).watchQuestion(id);
});

final askQatarAnswersProvider =
    StreamProvider.autoDispose.family<List<AskQatarAnswer>, String>(
  (ref, questionId) {
    return ref
        .watch(communityRepositoryProvider)
        .watchQuestionAnswers(questionId);
  },
);

final approvedEventsProvider =
    StreamProvider.autoDispose<List<CommunityEvent>>((ref) {
  return ref.watch(communityRepositoryProvider).watchApprovedEvents();
});

final creatorPendingEventsProvider =
    StreamProvider.autoDispose<List<CommunityEvent>>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  return Stream.fromFuture(ref.watch(communityUserIdProvider.future))
      .asyncExpand(repo.watchCreatorPendingEvents);
});

final lostFoundOpenProvider =
    StreamProvider.autoDispose.family<List<LostFoundItem>, String?>(
  (ref, type) {
    return ref.watch(communityRepositoryProvider).watchLostFound(type: type);
  },
);

final lostFoundResolvedProvider =
    StreamProvider.autoDispose<List<LostFoundItem>>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  return Stream.fromFuture(ref.watch(communityUserIdProvider.future))
      .asyncExpand(repo.watchResolvedLostFound);
});

final lostFoundMatchesProvider =
    StreamProvider.autoDispose.family<List<LostFoundMatchSummary>, String>(
  (ref, itemId) {
    return ref.watch(communityRepositoryProvider).watchLostFoundMatches(itemId);
  },
);

final qatarExpatNewsProvider =
    FutureProvider.autoDispose<QatarNewsResponse>((ref) async {
  return NewsService().fetchQatarExpatNews();
});

final qatarLiveEventsProvider =
    FutureProvider.autoDispose<QatarLiveEventsResponse>((ref) async {
  return QatarEventsService().fetchLiveEvents();
});

final groupPostsProvider =
    StreamProvider.autoDispose.family<List<GroupPost>, String>((ref, groupId) {
  return ref.watch(communityRepositoryProvider).watchGroupPosts(groupId);
});

final recentGroupPostsProvider =
    StreamProvider.autoDispose<List<GroupPost>>((ref) {
  return ref.watch(communityRepositoryProvider).watchRecentGroupPosts();
});

final trendingGroupPostsProvider =
    StreamProvider.autoDispose<List<GroupPost>>((ref) {
  return ref.watch(communityRepositoryProvider).watchTrendingGroupPosts();
});

final groupPostCommentsProvider =
    StreamProvider.autoDispose.family<List<GroupComment>, String>((ref, postId) {
  return ref.watch(communityRepositoryProvider).watchPostComments(postId);
});

final moderationLogProvider =
    StreamProvider.autoDispose<List<ModerationLogEntry>>((ref) {
  return ref.watch(communityRepositoryProvider).watchModerationLog();
});

final askQatarSimilarQuestionServiceProvider =
    Provider<AskQatarSimilarQuestionService>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  final ai = ref.watch(claudeAIServiceProvider);
  return AskQatarSimilarQuestionService(
    repository: repo,
    rankWithClaude: ({
      required draftTitle,
      required language,
      required candidates,
    }) async {
      final prompt = AskQatarSimilarQuestionService.buildClaudeRankingPrompt(
        draftTitle: draftTitle,
        language: language,
        candidates: candidates,
      );
      final reply = await ai.sendMessage(
        prompt,
        requestType: 'ask_qatar_similar_question_rank',
      );
      return AskQatarSimilarQuestionService.rankWithClaudeReply(
        draftTitle: draftTitle,
        language: language,
        candidates: candidates,
        claudeReply: reply,
      );
    },
  );
});

final lostFoundPhotoServiceProvider = Provider<LostFoundPhotoService>((ref) {
  return LostFoundPhotoService();
});

final communityModerationRephraseServiceProvider =
    Provider<CommunityModerationRephraseService>((ref) {
  final ai = ref.watch(claudeAIServiceProvider);
  return CommunityModerationRephraseService(ai: ai);
});

final communityPostModerationServiceProvider =
    Provider<CommunityPostModerationService>((ref) {
  final ai = ref.watch(claudeAIServiceProvider);
  return CommunityPostModerationService(
    classifyWithClaude: ({
      required text,
      required language,
      contentType = 'group_post',
    }) async {
      final prompt = CommunityPostModerationService.buildClaudePrompt(
        text: text,
        language: language,
        contentType: contentType,
      );
      final reply = await ai.sendMessage(
        prompt,
        requestType: 'community_content_moderation',
      );
      if (reply == ClaudeAIService.moderationHourlyLimitReply) {
        return (allowed: false, category: 'rate-limit');
      }
      return CommunityPostModerationService.parseClaudeJson(reply);
    },
  );
});

final communityModerationDedupProvider = Provider<CommunityModerationDedup>((ref) {
  return CommunityModerationDedup();
});

final communityModerationOrchestratorProvider =
    Provider<CommunityModerationOrchestrator>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  final dedup = ref.watch(communityModerationDedupProvider);
  final ai = ref.watch(claudeAIServiceProvider);
  return CommunityModerationOrchestrator(
    repository: repo,
    dedup: dedup,
    verifyWithClaude: ({
      required String title,
      required String description,
      required String location,
      List<String> suspiciousLinkDomains = const [],
    }) async {
      final suspiciousNote = suspiciousLinkDomains.isEmpty
          ? ''
          : '\nNote: submission contains links to non-common domains: '
              '${suspiciousLinkDomains.join(', ')}. Review carefully but '
              'legitimate event ticketing links may be valid.\n';

      final prompt =
          'You are moderating community events for Raabta, a Qatar expat app. '
          'Review this event submission and respond ONLY with valid JSON (no markdown): '
          '{"verdict":"approve" or "reject","reason":"short explanation"}\n\n'
          'Reject spam, scams, offensive content, obviously fake events, or '
          'pure promotional posts disguised as events.'
          '$suspiciousNote\n\n'
          'Title: $title\n'
          'Description: $description\n'
          'Location: $location';

      final reply = await ai.sendMessage(
        prompt,
        requestType: 'event_verification',
      );
      final parsed = EventVerificationService.parseClaudeJson(reply);
      return (approved: parsed.approved, reason: parsed.reason);
    },
  );
});

/// Content labels suggested in composers when Leaving Qatar Mode was recently used.
final suggestedCommunityContentLabelIdsProvider =
    Provider<List<String>>((ref) {
  final engaged = ref.watch(leavingQatarRecentlyEngagedProvider).value ?? false;
  if (!engaged) return const [];
  return const [CommunityContentLabels.leavingQatarId];
});
