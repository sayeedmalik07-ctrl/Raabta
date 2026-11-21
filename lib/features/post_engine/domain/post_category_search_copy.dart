import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Resolves vertical/intent-specific category search label and hint (Phase 12).
abstract final class PostCategorySearchCopy {
  static String labelKey(
    PostVertical vertical, {
    ServiceListingType? serviceListingType,
  }) {
    return switch (vertical) {
      PostVertical.marketplace => 'category_search_label_marketplace',
      PostVertical.housing => 'category_search_label_housing',
      PostVertical.jobs => 'category_search_label_jobs',
      PostVertical.business => 'category_search_label_business',
      PostVertical.services =>
        serviceListingType == ServiceListingType.request
            ? 'category_search_label_services_request'
            : 'category_search_label_services_provider',
    };
  }

  static String hintKey(
    PostVertical vertical, {
    ServiceListingType? serviceListingType,
  }) {
    return switch (vertical) {
      PostVertical.marketplace => 'category_search_hint_marketplace',
      PostVertical.housing => 'category_search_hint_housing',
      PostVertical.jobs => 'category_search_hint_jobs',
      PostVertical.business => 'category_search_hint_business',
      PostVertical.services =>
        serviceListingType == ServiceListingType.request
            ? 'category_search_hint_services_request'
            : 'category_search_hint_services_provider',
    };
  }

  static String label(
    PostVertical vertical,
    String locale, {
    ServiceListingType? serviceListingType,
  }) {
    return PostEngineStrings.t(
      labelKey(vertical, serviceListingType: serviceListingType),
      locale,
    );
  }

  static String hint(
    PostVertical vertical,
    String locale, {
    ServiceListingType? serviceListingType,
  }) {
    return PostEngineStrings.t(
      hintKey(vertical, serviceListingType: serviceListingType),
      locale,
    );
  }
}
