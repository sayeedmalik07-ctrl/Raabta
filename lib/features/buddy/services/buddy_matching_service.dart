import 'package:raabta/features/buddy/data/buddy_candidate_repository.dart';
import 'package:raabta/features/buddy/data/buddy_request_repository.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_matching_engine.dart';
import 'package:raabta/features/buddy/domain/buddy_profile_validation.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';
import 'package:raabta/features/buddy/services/buddy_match_cache.dart';
import 'package:raabta/services/classifieds/block_user_repository.dart';

class BuddyMatchingService {
  BuddyMatchingService({
    BuddyCandidateRepository? candidates,
    BlockUserRepository? blocks,
    BuddyRequestRepository? requests,
  })  : _candidates = candidates ?? BuddyCandidateRepository(),
        _blocks = blocks ?? BlockUserRepository(),
        _requests = requests ?? BuddyRequestRepository();

  final BuddyCandidateRepository _candidates;
  final BlockUserRepository _blocks;
  final BuddyRequestRepository _requests;

  Future<List<BuddyMatchCandidate>> suggestionsForNewcomer({
    required BuddyProfile newcomer,
    bool forceRefresh = false,
  }) async {
    if (!newcomer.isNewcomer ||
        newcomer.paused ||
        !BuddyProfileValidation.isValid(newcomer)) {
      return const [];
    }

    if (!forceRefresh) {
      final cached = BuddyMatchCache.get(newcomer.uid);
      if (cached != null) return cached;
    }

    final blocked = await _blocks.fetchBlockedUserIds(uid: newcomer.uid);
    final outgoing = await _requests.fetchOutgoingForNewcomer(newcomer.uid);
    final pendingHelperIds = outgoing
        .where((r) => r.effectiveStatus == BuddyConstants.requestStatusPending)
        .map((r) => r.toUid)
        .toSet();

    final helpers = await _candidates.fetchHelperCandidates(
      nationalityCountryId: newcomer.nationalityCountryId,
    );

    final excluded = {...blocked, ...pendingHelperIds, newcomer.uid};
    final ranked = BuddyMatchingEngine.rankTopHelpers(
      newcomer: newcomer,
      helpers: helpers,
      excludedHelperUids: excluded,
    );

    BuddyMatchCache.put(newcomer.uid, ranked);
    return ranked;
  }
}
