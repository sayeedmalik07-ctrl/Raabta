import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/features/post_engine/domain/models/post_listing_lifecycle.dart';
import 'package:raabta/features/post_engine/domain/post_analytics_manager.dart';

/// Centralized listing lifecycle for all five verticals.
class PostLifecycleManager {
  const PostLifecycleManager({PostAnalyticsManager? analytics})
      : _analytics = analytics ?? const PostAnalyticsManager();

  final PostAnalyticsManager _analytics;

  PostListingLifecycleState initialState({required bool requiresReview}) {
    return requiresReview
        ? PostListingLifecycleState.underReview
        : PostListingLifecycleState.published;
  }

  PostListingLifecycleState? transition({
    required PostListingLifecycleState current,
    required PostLifecycleEvent event,
  }) {
    return switch ((current, event)) {
      (PostListingLifecycleState.draft, PostLifecycleEvent.submit) =>
        PostListingLifecycleState.submitted,
      (PostListingLifecycleState.ready, PostLifecycleEvent.submit) =>
        PostListingLifecycleState.submitted,
      (PostListingLifecycleState.submitted, PostLifecycleEvent.startReview) =>
        PostListingLifecycleState.underReview,
      (PostListingLifecycleState.underReview, PostLifecycleEvent.approve) =>
        PostListingLifecycleState.approved,
      (PostListingLifecycleState.underReview, PostLifecycleEvent.reject) =>
        PostListingLifecycleState.rejected,
      (PostListingLifecycleState.rejected, PostLifecycleEvent.edit) =>
        PostListingLifecycleState.draft,
      (PostListingLifecycleState.rejected, PostLifecycleEvent.resubmit) =>
        PostListingLifecycleState.submitted,
      (PostListingLifecycleState.approved, PostLifecycleEvent.publish) =>
        PostListingLifecycleState.published,
      (PostListingLifecycleState.published, PostLifecycleEvent.activate) =>
        PostListingLifecycleState.active,
      (PostListingLifecycleState.active, PostLifecycleEvent.markExpiring) =>
        PostListingLifecycleState.expiringSoon,
      (PostListingLifecycleState.expiringSoon, PostLifecycleEvent.expire) =>
        PostListingLifecycleState.expired,
      (PostListingLifecycleState.expired, PostLifecycleEvent.renew) =>
        PostListingLifecycleState.active,
      (PostListingLifecycleState.active, PostLifecycleEvent.archive) ||
      (PostListingLifecycleState.expired, PostLifecycleEvent.archive) ||
      (PostListingLifecycleState.published, PostLifecycleEvent.archive) =>
        PostListingLifecycleState.archived,
      _ => null,
    };
  }

  Future<void> markSold({
    required String verticalId,
    required String listingId,
    String? userId,
  }) async {
    _analytics.trackCompletion(
      listingId: listingId,
      verticalId: verticalId,
      userId: userId ?? FirebaseAuth.instance.currentUser?.uid,
    );
  }

  Future<void> markExpired({
    required String verticalId,
    required String listingId,
    String? userId,
  }) async {
    _analytics.trackExpired(
      listingId: listingId,
      verticalId: verticalId,
      userId: userId ?? FirebaseAuth.instance.currentUser?.uid,
    );
  }
}

enum PostLifecycleEvent {
  submit,
  startReview,
  approve,
  reject,
  edit,
  resubmit,
  publish,
  activate,
  markExpiring,
  expire,
  renew,
  archive,
}
