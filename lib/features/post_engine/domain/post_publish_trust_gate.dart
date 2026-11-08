import 'package:raabta/features/post_engine/data/post_duplicate_candidate_loader.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/post_engine/domain/post_trust_engine.dart';

/// Pre-publish trust evaluation with same-user duplicate candidates supplied.
abstract final class PostPublishTrustGate {
  static Future<PostTrustEvaluation> evaluate({
    required PostVertical vertical,
    required String categoryPath,
    required Map<String, dynamic> fieldValues,
    required String ownerUserId,
    required String locale,
    String? resumeListingId,
    PostDuplicateCandidateLoader? candidateLoader,
    PostTrustEngine? trustEngine,
  }) async {
    final loader = candidateLoader ?? PostDuplicateCandidateLoader();
    final existingListings = await loader.loadActiveSameUserListings(
      vertical: vertical,
      ownerUserId: ownerUserId,
      categoryPath: categoryPath,
    );

    final trust = trustEngine ?? PostEngine().trust;
    return trust.evaluate(
      fieldValues: fieldValues,
      verticalId: vertical.id,
      categoryPath: categoryPath,
      userId: ownerUserId,
      locale: locale,
      existingListings: existingListings,
      resumeListingId: resumeListingId,
    );
  }
}
