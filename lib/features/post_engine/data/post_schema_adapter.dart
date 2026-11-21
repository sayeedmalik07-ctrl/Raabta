import 'package:raabta/data/models/job_requirements.dart';
import 'package:raabta/features/business/domain/business_category_catalog.dart';
import 'package:raabta/features/post_engine/data/post_schema_persistence.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Thin adapter — maps schema field values to vertical submission maps.
/// Does NOT modify existing listing model classes.
abstract final class PostSchemaAdapter {
  /// Marketplace → fields compatible with [MarketplaceListingSubmission].
  static Map<String, dynamic> toMarketplaceFields(
    Map<String, dynamic> values, {
    required String categoryLeafId,
  }) {
    final schemaFields = PostSchemaPersistence.isVehicleCategory(categoryLeafId)
        ? PostSchemaPersistence.buildVehicleSchemaFields(values)
        : const <String, dynamic>{};

    return {
      'categoryId': categoryLeafId,
      'title': _titleFromValues(values),
      'priceQar': _parsePrice(values['price']),
      'description': values['description']?.toString() ?? '',
      'condition': _localizedConditionToStored(values['condition']),
      'area': values['location']?.toString() ?? '',
      'photoUrls': _photoList(values['photos']),
      if (schemaFields.isNotEmpty) 'schemaFields': schemaFields,
    };
  }

  /// Services → fields compatible with [ServiceListingSubmission] shape.
  static Map<String, dynamic> toServiceFields(
    Map<String, dynamic> values, {
    required String categoryId,
    required String serviceName,
    required String userId,
    ServiceListingType listingType = ServiceListingType.provider,
  }) {
    final schemaFields = PostSchemaPersistence.buildServiceSchemaFields(values);
    final isRequest = listingType == ServiceListingType.request;
    return {
      'userId': userId,
      'serviceCategoryId': categoryId,
      'serviceCategory': values['serviceCategory']?.toString() ?? categoryId,
      'serviceName': serviceName,
      'title': isRequest
          ? _serviceRequestTitle(values, serviceName)
          : values['title']?.toString() ?? serviceName,
      'description': isRequest
          ? _serviceRequestDescription(values)
          : values['description']?.toString() ?? '',
      'providerName': isRequest
          ? values['contactName']?.toString() ?? ''
          : values['providerName']?.toString() ?? '',
      'phone': values['phone']?.toString() ?? '',
      'area': values['location']?.toString() ?? '',
      'imageUrl': _firstPhoto(values['photos']),
      'listingType': listingType.id,
      if (schemaFields.isNotEmpty) 'schemaFields': schemaFields,
    };
  }

  static String _serviceRequestTitle(
    Map<String, dynamic> values,
    String serviceName,
  ) {
    final problem = values['problem']?.toString();
    if (problem != null && problem.isNotEmpty && problem != 'svc_prob_other') {
      return '$serviceName — ${_humanizeOptionKey(problem)}';
    }
    final need = values['need_description']?.toString().trim();
    if (need != null && need.isNotEmpty) {
      return need.length > 60 ? '${need.substring(0, 57)}…' : need;
    }
    return '$serviceName request';
  }

  static String _serviceRequestDescription(Map<String, dynamic> values) {
    final notes = values['notes']?.toString().trim();
    if (notes != null && notes.isNotEmpty) return notes;
    final need = values['need_description']?.toString().trim();
    if (need != null && need.isNotEmpty) return need;
    final problemOther = values['problem_other']?.toString().trim();
    if (problemOther != null && problemOther.isNotEmpty) return problemOther;
    return 'Service request';
  }

  static String _humanizeOptionKey(String key) {
    return key
        .replaceFirst('svc_prob_', '')
        .replaceAll('_', ' ')
        .trim();
  }

  /// Housing → [CreateListingRequest] field map (caller builds request).
  static Map<String, dynamic> toHousingFields(
    Map<String, dynamic> values, {
    required String categoryLeafId,
  }) {
    final schemaFields = PostSchemaPersistence.buildHousingSchemaFields(values);

    return {
      'title': values['title']?.toString() ?? '',
      'area': values['location']?.toString() ?? '',
      'pricePerMonth': _parsePrice(values['price']),
      'type': _housingTypeFromCategory(categoryLeafId),
      'description': values['description']?.toString() ?? '',
      'photoUrls': _photoList(values['photos']),
      'genderPreference': _genderFromValue(values['gender_preference']),
      'zone': PostSchemaPersistence.optionalText(values, 'zone'),
      'streetNumber': PostSchemaPersistence.optionalText(values, 'street_number'),
      'buildingNumber':
          PostSchemaPersistence.optionalText(values, 'building_number'),
      if (schemaFields.isNotEmpty) 'schemaFields': schemaFields,
    };
  }

  /// Business → [BusinessesRepository.createBusiness] arguments.
  static Map<String, dynamic> toBusinessFields(
    Map<String, dynamic> values, {
    required String categoryLeafId,
  }) {
    final languagesRaw = values['languages']?.toString() ?? '';
    final tags = <String>[];
    if (values['iftar_deals'] == true) {
      tags.add('ramadan_iftar');
    }
    final profileFields =
        PostSchemaPersistence.buildBusinessProfileFields(values);
    return {
      'name': values['name']?.toString() ?? '',
      'categoryId': categoryLeafId,
      'category': BusinessCategoryCatalog.displayLabel(categoryLeafId),
      'location': values['location']?.toString() ?? '',
      'phone': values['phone']?.toString() ?? '',
      'whatsapp': values['whatsapp']?.toString(),
      'description': values['description']?.toString(),
      'languages': JobRequirementsSpec.parseCommaSeparated(languagesRaw),
      'contactMode': values['contactMode']?.toString() ?? 'message_only',
      'website': values['website']?.toString(),
      'tags': tags,
      'profileFields': profileFields,
      'openingHours': values['opening_hours'],
      'socialLinks': {
        if ((values['social_instagram']?.toString().trim().isNotEmpty ?? false))
          'instagram': values['social_instagram'],
        if ((values['social_facebook']?.toString().trim().isNotEmpty ?? false))
          'facebook': values['social_facebook'],
        if ((values['social_linkedin']?.toString().trim().isNotEmpty ?? false))
          'linkedin': values['social_linkedin'],
        if ((values['social_tiktok']?.toString().trim().isNotEmpty ?? false))
          'tiktok': values['social_tiktok'],
        if ((values['social_youtube']?.toString().trim().isNotEmpty ?? false))
          'youtube': values['social_youtube'],
      },
      'servicesOffered': PostSchemaValueCoercion.asStringList(
        values['services_offered'],
      ),
    };
  }

  /// Jobs → repository args; [requirements] must be supplied separately.
  static Map<String, dynamic> toJobFields(
    Map<String, dynamic> values, {
    required String category,
    required JobRequirementsSpec requirements,
    List<String> benefits = const [],
    String type = 'Full Time',
  }) {
    return {
      'title': values['title']?.toString() ?? '',
      'company': values['company']?.toString() ?? '',
      'salary': values['salary']?.toString().trim().isEmpty == true
          ? 'Contact for salary'
          : values['salary']?.toString() ?? '',
      'location': values['location']?.toString() ?? 'Qatar',
      'description': values['description']?.toString() ?? '',
      'contact': values['contact']?.toString() ?? '',
      'email': values['email']?.toString(),
      'category': category,
      'benefits': benefits,
      'requirements': requirements,
      'type': type,
    };
  }

  static ListingType housingListingTypeForCategoryLeaf(String leafId) {
    return switch (leafId) {
      'room' => ListingType.room,
      'flat' => ListingType.flat,
      'sharing' => ListingType.sharing,
      'studio' => ListingType.studio,
      _ => ListingType.room,
    };
  }

  static ListingType _housingTypeFromCategory(String leafId) =>
      housingListingTypeForCategoryLeaf(leafId);

  static GenderPreference _genderFromValue(dynamic raw) {
    return switch (raw?.toString()) {
      'gender_male' => GenderPreference.maleOnly,
      'gender_female' => GenderPreference.femaleOnly,
      'gender_family' => GenderPreference.family,
      _ => GenderPreference.any,
    };
  }

  static String _titleFromValues(Map<String, dynamic> values) {
    for (final key in ['title', 'brand', 'model', 'name']) {
      final v = values[key]?.toString().trim();
      if (v != null && v.isNotEmpty) {
        final model = values['model']?.toString().trim();
        if (key == 'brand' && model != null && model.isNotEmpty) {
          return '$v $model';
        }
        return v;
      }
    }
    return values['description']?.toString().split('\n').first ?? 'Listing';
  }

  static int _parsePrice(dynamic raw) {
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static String _localizedConditionToStored(dynamic raw) {
    return switch (raw?.toString()) {
      'condition_new' => 'New',
      'condition_used' => 'Used',
      'condition_refurbished' => 'Refurbished',
      _ => raw?.toString() ?? 'Used',
    };
  }

  static List<String> _photoList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw != null && raw.toString().isNotEmpty) return [raw.toString()];
    return const [];
  }

  static String _firstPhoto(dynamic raw) {
    final list = _photoList(raw);
    return list.isEmpty ? '' : list.first;
  }

  static String leafCategoryId(String categoryPath) {
    final parts = categoryPath.split('.');
    return parts.isEmpty ? categoryPath : parts.last;
  }

  static PostVertical verticalFromId(String id) =>
      PostVertical.fromId(id) ?? PostVertical.marketplace;
}
