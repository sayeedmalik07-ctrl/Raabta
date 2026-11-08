import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_analytics_manager.dart';
import 'package:raabta/features/post_engine/domain/post_draft_manager.dart';
import 'package:raabta/services/drafts/draft_form_controller.dart';
import 'package:raabta/features/post_engine/data/post_intelligence_usage_repository.dart';
import 'package:raabta/features/post_engine/domain/post_intelligence_adapter.dart';
import 'package:raabta/features/post_engine/domain/post_lifecycle_manager.dart';
import 'package:raabta/features/post_engine/domain/post_location_engine.dart';
import 'package:raabta/features/post_engine/domain/post_media_engine.dart';
import 'package:raabta/features/post_engine/domain/post_moderation_engine.dart';
import 'package:raabta/features/post_engine/domain/post_preview_engine.dart';
import 'package:raabta/features/post_engine/domain/post_publish_engine.dart';
import 'package:raabta/features/post_engine/domain/post_schema_engine.dart';
import 'package:raabta/features/post_engine/domain/post_trust_engine.dart';
import 'package:raabta/features/post_engine/domain/post_validation_engine.dart';

export 'package:raabta/features/post_engine/domain/models/post_vertical.dart'
    show PostVertical;

/// Vertical-agnostic post engine facade — no hardcoded vertical UI logic.
class PostEngine {
  factory PostEngine({
    PostSchemaEngine? schemaEngine,
    PostValidationEngine? validationEngine,
    PostMediaEngine? mediaEngine,
    PostLocationEngine? locationEngine,
    PostPreviewEngine? previewEngine,
    PostTrustEngine? trustEngine,
    PostModerationEngine? moderationEngine,
    PostPublishEngine? publishEngine,
    PostLifecycleManager? lifecycleManager,
    PostAnalyticsManager? analyticsManager,
    PostIntelligenceAdapter? intelligenceAdapter,
  }) {
    final intelligence = intelligenceAdapter ??
        PostIntelligenceAdapter(
          usage: PostIntelligenceUsageRepository(),
        );
    return PostEngine._(
      schema: schemaEngine ?? PostSchemaEngine(),
      validation: validationEngine ?? const PostValidationEngine(),
      media: mediaEngine ?? PostMediaEngine(),
      location: locationEngine ?? const PostLocationEngine(),
      preview: previewEngine ?? const PostPreviewEngine(),
      intelligence: intelligence,
      trust: trustEngine ?? PostTrustEngine(intelligence: intelligence),
      moderation: moderationEngine ?? const PostModerationEngine(),
      publish: publishEngine ?? PostPublishEngine(),
      lifecycle: lifecycleManager ?? const PostLifecycleManager(),
      analytics: analyticsManager ?? const PostAnalyticsManager(),
    );
  }

  const PostEngine._({
    required this.schema,
    required this.validation,
    required this.media,
    required this.location,
    required this.preview,
    required this.intelligence,
    required this.trust,
    required this.moderation,
    required this.publish,
    required this.lifecycle,
    required this.analytics,
  });

  final PostSchemaEngine schema;
  final PostValidationEngine validation;
  final PostMediaEngine media;
  final PostLocationEngine location;
  final PostPreviewEngine preview;
  final PostTrustEngine trust;
  final PostModerationEngine moderation;
  final PostPublishEngine publish;
  final PostLifecycleManager lifecycle;
  final PostAnalyticsManager analytics;
  final PostIntelligenceAdapter intelligence;

  PostDraftManager drafts({
    required PostVertical vertical,
    required String categoryPath,
    int schemaVersion = 1,
    DraftSavedCallback? onSaved,
  }) {
    return PostDraftManager(
      vertical: vertical,
      categoryPath: categoryPath,
      schemaVersion: schemaVersion,
      onSaved: onSaved,
    );
  }
}
