import 'package:raabta/features/buddy/domain/buddy_constants.dart';
import 'package:raabta/features/buddy/domain/buddy_matching_weights.dart';
import 'package:raabta/features/buddy/domain/buddy_profile_validation.dart';
import 'package:raabta/features/buddy/models/buddy_profile.dart';

class BuddyMatchCandidate {
  const BuddyMatchCandidate({
    required this.helper,
    required this.score,
  });

  final BuddyProfile helper;
  final int score;
}

abstract final class BuddyMatchingEngine {
  static int score({
    required BuddyProfile newcomer,
    required BuddyProfile helper,
  }) {
    var total = 0;

    if (newcomer.nationalityCountryId == helper.nationalityCountryId) {
      total += BuddyMatchingWeights.sameNationality;
    }

    var langScore = 0;
    for (final code in newcomer.spokenLanguageCodes) {
      if (helper.spokenLanguageCodes.contains(code)) {
        langScore += BuddyMatchingWeights.sharedLanguageEach;
      }
    }
    total += langScore.clamp(0, BuddyMatchingWeights.sharedLanguageCap);

    if (newcomer.areaCode == helper.areaCode) {
      total += BuddyMatchingWeights.sameArea;
    }

    var interestScore = 0;
    for (final tag in newcomer.interestTagIds) {
      if (helper.interestTagIds.contains(tag)) {
        interestScore += BuddyMatchingWeights.sharedInterestEach;
      }
    }
    total += interestScore.clamp(0, BuddyMatchingWeights.sharedInterestCap);

    total += BuddyMatchingWeights.yearsBandScores[helper.yearsInQatarBand] ?? 0;

    return total;
  }

  static List<BuddyMatchCandidate> rankTopHelpers({
    required BuddyProfile newcomer,
    required List<BuddyProfile> helpers,
    required Set<String> excludedHelperUids,
    int limit = BuddyConstants.maxSuggestionCount,
  }) {
    final scored = <BuddyMatchCandidate>[];
    for (final helper in helpers) {
      if (helper.uid == newcomer.uid) continue;
      if (excludedHelperUids.contains(helper.uid)) continue;
      if (!BuddyProfileValidation.isDiscoverableHelper(helper)) continue;
      scored.add(
        BuddyMatchCandidate(
          helper: helper,
          score: score(newcomer: newcomer, helper: helper),
        ),
      );
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final aMatch = a.helper.lastMatchedAt ??
          a.helper.updatedAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bMatch = b.helper.lastMatchedAt ??
          b.helper.updatedAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final byMatch = aMatch.compareTo(bMatch);
      if (byMatch != 0) return byMatch;
      return a.helper.uid.compareTo(b.helper.uid);
    });

    if (scored.length <= limit) return scored;
    return scored.sublist(0, limit);
  }
}
