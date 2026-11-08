import 'package:raabta/features/post_engine/domain/post_trust_engine.dart';

/// Deterministic duplicate listing detection via content fingerprint.
class PostDuplicateDetector {
  const PostDuplicateDetector();

  bool isDuplicate({
    required Map<String, dynamic> fieldValues,
    required String categoryPath,
    required List<Map<String, dynamic>> existingListings,
    String? resumeListingId,
  }) {
    if (existingListings.isEmpty) return false;
    final fingerprint = postListingFingerprint(
      fieldValues: fieldValues,
      categoryPath: categoryPath,
    );
    for (final existing in existingListings) {
      final listingId = existing['_listingId']?.toString();
      if (resumeListingId != null &&
          listingId != null &&
          listingId == resumeListingId) {
        continue;
      }
      final other = postListingFingerprint(
        fieldValues: existing,
        categoryPath: categoryPath,
      );
      if (other == fingerprint) return true;
    }
    return false;
  }

  List<PostDuplicateMatch> detectDuplicates({
    required Map<String, dynamic> fieldValues,
    required String categoryPath,
    required List<({String id, Map<String, dynamic> values})> candidates,
    double threshold = 1.0,
  }) {
    final fingerprint = postListingFingerprint(
      fieldValues: fieldValues,
      categoryPath: categoryPath,
    );
    final matches = <PostDuplicateMatch>[];
    for (final c in candidates) {
      final other = postListingFingerprint(
        fieldValues: c.values,
        categoryPath: categoryPath,
      );
      final similarity = fingerprint == other ? 1.0 : 0.0;
      if (similarity >= threshold) {
        matches.add(PostDuplicateMatch(listingId: c.id, similarity: similarity));
      }
    }
    return matches;
  }
}

class PostDuplicateMatch {
  const PostDuplicateMatch({required this.listingId, required this.similarity});

  final String listingId;
  final double similarity;
}
