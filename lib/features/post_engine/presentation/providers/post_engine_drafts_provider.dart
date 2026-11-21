import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/presentation/post_flow_actions.dart';
import 'package:raabta/features/post_engine/presentation/screens/post_category_picker_screen.dart';
import 'package:raabta/services/drafts/draft_service.dart';

class PostEngineDraftItem {
  const PostEngineDraftItem({
    required this.formId,
    required this.vertical,
    required this.title,
    required this.savedAt,
    required this.resumeRoute,
  });

  final String formId;
  final PostVertical vertical;
  final String title;
  final DateTime savedAt;
  final String resumeRoute;
}

final postEngineDraftsProvider =
    FutureProvider<List<PostEngineDraftItem>>((ref) async {
  final records = await DraftService.instance.listDraftsForUser(
    formIdPrefix: 'post_engine_',
  );
  return records.map((entry) {
    final data = entry.record.data;
    final verticalId = data['_vertical']?.toString() ?? 'marketplace';
    final vertical =
        PostVertical.fromId(verticalId) ?? PostVertical.marketplace;
    final title = data['title']?.toString() ??
        data['name']?.toString() ??
        data['brand']?.toString() ??
        PostFlowActions.flowTitle(vertical, 'English');
    return PostEngineDraftItem(
      formId: entry.formId,
      vertical: vertical,
      title: title,
      savedAt: entry.record.savedAt,
      resumeRoute: PostCategoryPickerScreen.postRoute(
        vertical,
        category: data['_categoryPath']?.toString(),
      ),
    );
  }).toList();
});
