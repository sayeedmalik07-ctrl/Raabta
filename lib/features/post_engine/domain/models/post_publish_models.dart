/// Publish lifecycle phase persisted in the Post Engine draft.
enum PostPublishPhase {
  idle('idle'),
  creating('creating'),
  created('created'),
  uploading('uploading'),
  attaching('attaching'),
  finalizing('finalizing'),
  completed('completed');

  const PostPublishPhase(this.storageValue);
  final String storageValue;

  static PostPublishPhase fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) return PostPublishPhase.idle;
    return PostPublishPhase.values.firstWhere(
      (p) => p.storageValue == raw,
      orElse: () => PostPublishPhase.idle,
    );
  }
}

/// Outcome of a publish attempt — drives UX and side effects.
enum PostPublishOutcome {
  /// Listing fully published per vertical finalization rules.
  completed,

  /// Firestore listing exists but required media is incomplete.
  listingCreatedMediaIncomplete,

  /// Nothing authoritative was created, or ownership/resume failed.
  failed,
}

class PostPublishResult {
  const PostPublishResult({
    required this.listingId,
    required this.publishId,
    this.photoUrls = const [],
    this.outcome = PostPublishOutcome.completed,
    this.sideEffectsAlreadyEmitted = false,
    this.resumedExistingListing = false,
  });

  final String listingId;
  final String publishId;
  final List<String> photoUrls;
  final PostPublishOutcome outcome;
  final bool sideEffectsAlreadyEmitted;

  /// True when create was skipped because listing already existed for publishId.
  final bool resumedExistingListing;

  bool get isSuccess => outcome == PostPublishOutcome.completed;
  bool get isPartialMedia =>
      outcome == PostPublishOutcome.listingCreatedMediaIncomplete;
  bool get shouldEmitSideEffects =>
      isSuccess && !sideEffectsAlreadyEmitted;

  /// When true, listing already met finalization before this attempt (retry/resume).
  bool get skipsSideEffectsAsAlreadyComplete =>
      isSuccess && sideEffectsAlreadyEmitted && resumedExistingListing;
}

/// Recoverable media failure during publish.
class PostPublishMediaException implements Exception {
  PostPublishMediaException(this.message, {this.missingPhotoIndex});

  final String message;
  final int? missingPhotoIndex;

  @override
  String toString() => message;
}

/// Ownership mismatch when resuming a deterministic listing id.
class PostPublishOwnershipException implements Exception {
  PostPublishOwnershipException(this.message);

  final String message;

  @override
  String toString() => message;
}
