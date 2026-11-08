/// Unified publishing lifecycle states for all Post Engine verticals.
enum PostListingLifecycleState {
  draft('DRAFT'),
  ready('READY'),
  submitted('SUBMITTED'),
  underReview('UNDER_REVIEW'),
  rejected('REJECTED'),
  approved('APPROVED'),
  published('PUBLISHED'),
  active('ACTIVE'),
  expiringSoon('EXPIRING_SOON'),
  expired('EXPIRED'),
  archived('ARCHIVED');

  const PostListingLifecycleState(this.id);
  final String id;

  static PostListingLifecycleState? fromId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final s in values) {
      if (s.id == raw || s.name == raw) return s;
    }
    return null;
  }

  bool get isVisibleToPublic =>
      this == active || this == published || this == expiringSoon;
}
