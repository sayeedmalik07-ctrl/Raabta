import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/post_engine/data/my_posts_repository.dart';
import 'package:raabta/features/post_engine/domain/models/my_post_item.dart';

final myPostsRepositoryProvider = Provider<MyPostsRepository>((ref) {
  return MyPostsRepository();
});

final myPostsProvider = FutureProvider.autoDispose
    .family<List<MyPostItem>, String>((ref, uid) async {
  if (uid.isEmpty) return const [];
  return ref.watch(myPostsRepositoryProvider).loadAll(uid);
});
