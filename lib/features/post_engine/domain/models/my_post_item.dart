import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';

enum MyPostItemKind { draft, published, pending, rejected, expired, archived }

class MyPostItem {
  const MyPostItem({
    required this.id,
    required this.vertical,
    required this.title,
    required this.status,
    required this.kind,
    required this.updatedAt,
    this.categoryPath,
    this.route,
  });

  final String id;
  final PostVertical vertical;
  final String title;
  final String status;
  final MyPostItemKind kind;
  final DateTime updatedAt;
  final String? categoryPath;
  final String? route;

  bool matchesVerticalFilter(PostVertical? filter) =>
      filter == null || vertical == filter;
}

enum MyPostsTab {
  all,
  drafts,
  pendingReview,
  published,
  expiringSoon,
  expired,
  rejected,
  archived,
}

extension MyPostsTabX on MyPostsTab {
  String labelKey() => switch (this) {
        MyPostsTab.all => 'tab_all',
        MyPostsTab.drafts => 'tab_drafts',
        MyPostsTab.pendingReview => 'tab_pending',
        MyPostsTab.published => 'tab_published',
        MyPostsTab.expiringSoon => 'tab_expiring',
        MyPostsTab.expired => 'tab_expired',
        MyPostsTab.rejected => 'tab_rejected',
        MyPostsTab.archived => 'tab_archived',
      };

  bool matches(MyPostItem item) => switch (this) {
        MyPostsTab.all => true,
        MyPostsTab.drafts => item.kind == MyPostItemKind.draft,
        MyPostsTab.pendingReview => item.kind == MyPostItemKind.pending,
        MyPostsTab.published => item.kind == MyPostItemKind.published,
        MyPostsTab.expiringSoon => false,
        MyPostsTab.expired => item.kind == MyPostItemKind.expired,
        MyPostsTab.rejected => item.kind == MyPostItemKind.rejected,
        MyPostsTab.archived => item.kind == MyPostItemKind.archived,
      };
}
