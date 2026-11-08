import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_display_status_resolver.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_truth_engine_link.dart';
import 'package:raabta/features/community/models/community_models.dart';

/// Read-only presentation helpers for Rumour Check Ask Qatar questions.
abstract final class RumourQuestionPresentation {
  static bool isRumourCheck(AskQatarQuestion question) =>
      question.isRumourCheck;

  /// Trusted only when server set [communityVerifiedAt] (rules block client writes).
  static bool readTrustedCommunityVerified(AskQatarQuestion question) {
    if (!question.isRumourCheck) return false;
    return question.trustedCommunityVerified &&
        question.communityVerifiedAt != null;
  }

  static RumourDisplayStatus displayStatus(AskQatarQuestion question) {
    return RumourDisplayStatusResolver.resolve(
      RumourDisplayStatusInput(
        contextNoteCount: question.answers,
        trustedCommunityVerified: readTrustedCommunityVerified(question),
      ),
    );
  }

  static RumourCategory? rumourCategory(AskQatarQuestion question) {
    return RumourCheckModelParsing.categoryFromId(question.rumourCategoryId);
  }

  static RumourTruthEngineLink? truthEngineLink(AskQatarQuestion question) {
    if (!isRumourCheck(question)) return null;
    final category = rumourCategory(question) ?? RumourCategory.other;
    final claim = [
      question.title,
      question.body,
    ].where((s) => s.trim().isNotEmpty).join('\n');
    return RumourTruthEngineLinkResolver.resolve(
      category: category,
      claimText: claim,
    );
  }
}
