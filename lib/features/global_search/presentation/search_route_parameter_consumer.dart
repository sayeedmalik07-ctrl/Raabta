import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/housing_providers.dart';

/// Applies [SearchRouteParameters] from deep links to feature filter state (S4).
abstract final class SearchRouteParameterConsumer {
  static void applyHousingFilters(
    WidgetRef ref,
    SearchRouteParameters params,
  ) {
    var filters = ref.read(housingFiltersProvider);

    if (params.area != null && params.area!.trim().isNotEmpty) {
      filters = filters.copyWith(area: params.area!.trim());
    }
    if (params.maxPrice != null && params.maxPrice! > 0) {
      filters = filters.copyWith(maxPrice: params.maxPrice!.toDouble());
    }
    if (params.minPrice != null && params.minPrice! > 0) {
      filters = filters.copyWith(minPrice: params.minPrice!.toDouble());
    }
    if (params.propertyType != null) {
      final type = _parseListingType(params.propertyType!);
      if (type != null) {
        filters = filters.copyWith(type: type);
      }
    }
    if (params.bedrooms != null && params.bedrooms! > 0) {
      filters = filters.copyWith(minBedrooms: params.bedrooms);
    }

    ref.read(housingFiltersProvider.notifier).state = filters;
  }

  /// Maps visa topic tokens to an existing guide route when possible.
  static String? visaGuideRouteForTopic(String? topic) {
    final normalized = topic?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;

    final direct = switch (normalized) {
      'renewal' || 'iqama' => '/visa/guide/iqama_renewal',
      'qid' || 'qatar id' || 'qatar_id' => '/visa/guide/qatar_id',
      'exit' || 'exit_permit' => '/visa/guide/exit_permit',
      'family' || 'family_visa' => '/visa/guide/family_visa',
      'sponsor' || 'sponsor_transfer' => '/visa/guide/sponsor_transfer',
      'medical' => '/visa/guide/medical',
      _ => null,
    };
    if (direct != null) return direct;

    for (final cat in visaCategories) {
      if (cat.id.contains(normalized) ||
          cat.title.toLowerCase().contains(normalized)) {
        return '/visa/guide/${cat.id}';
      }
    }
    return null;
  }

  static ListingType? _parseListingType(String raw) {
    final normalized = raw.trim().toLowerCase();
    return switch (normalized) {
      'room' => ListingType.room,
      'flat' || 'apartment' => ListingType.flat,
      'sharing' || 'partition' => ListingType.sharing,
      'studio' => ListingType.studio,
      _ => null,
    };
  }
}
