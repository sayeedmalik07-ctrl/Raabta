import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Vertical-specific Save / Preview / Publish button labels (Phase 5).
abstract final class PostFlowActions {
  static String saveDraftLabel(PostVertical vertical, String locale) {
    return switch (vertical) {
      PostVertical.business =>
        PostEngineStrings.t('action_save_business', locale),
      _ => PostEngineStrings.t('action_save_draft', locale),
    };
  }

  static String previewLabel(PostVertical vertical, String locale) {
    return switch (vertical) {
      PostVertical.housing =>
        PostEngineStrings.t('action_preview_housing', locale),
      PostVertical.jobs => PostEngineStrings.t('action_preview_job', locale),
      PostVertical.business =>
        PostEngineStrings.t('action_preview_business', locale),
      PostVertical.services =>
        PostEngineStrings.t('action_preview_service', locale),
      PostVertical.marketplace =>
        PostEngineStrings.t('action_preview_item', locale),
    };
  }

  static String publishLabel(PostVertical vertical, String locale) {
    return switch (vertical) {
      PostVertical.housing =>
        PostEngineStrings.t('action_publish_housing', locale),
      PostVertical.jobs => PostEngineStrings.t('action_publish_job', locale),
      PostVertical.business =>
        PostEngineStrings.t('action_publish_business', locale),
      PostVertical.services =>
        PostEngineStrings.t('action_publish_service', locale),
      PostVertical.marketplace =>
        PostEngineStrings.t('action_publish_item', locale),
    };
  }

  static String flowTitle(PostVertical vertical, String locale) {
    return switch (vertical) {
      PostVertical.housing =>
        PostEngineStrings.t('flow_title_housing', locale),
      PostVertical.jobs => PostEngineStrings.t('flow_title_job', locale),
      PostVertical.business =>
        PostEngineStrings.t('flow_title_business', locale),
      PostVertical.services =>
        PostEngineStrings.t('flow_title_service', locale),
      PostVertical.marketplace =>
        PostEngineStrings.t('flow_title_marketplace', locale),
    };
  }

  /// Reads pre-selected category from post-flow deep links (`category` or legacy `categoryId`).
  static String? categoryPathFromQuery(Map<String, String> query) {
    final category = query['category'];
    if (category != null && category.isNotEmpty) return category;
    final categoryId = query['categoryId'];
    if (categoryId != null && categoryId.isNotEmpty) return categoryId;
    return null;
  }

  /// Services listing type from query (`listingType=request|provider`).
  static ServiceListingType? listingTypeFromQuery(Map<String, String> query) {
    final raw = query['listingType']?.trim().toLowerCase();
    if (raw == null || raw.isEmpty) return null;
    return ServiceListingType.fromStored(raw);
  }
}
