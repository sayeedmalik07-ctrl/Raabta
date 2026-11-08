import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/drafts/draft_service.dart';

/// Counts in-progress Post Engine drafts for the current user.
final postEngineDraftCountProvider = FutureProvider<int>((ref) async {
  final drafts = await DraftService.instance.listDraftsForUser(
    formIdPrefix: 'post_engine_',
  );
  return drafts.length;
});
