import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';

/// Maps post-engine form values to Firestore-safe schema field payloads.
abstract final class PostSchemaPersistence {
  static const vehicleFieldIds = {
    'make',
    'year',
    'brand_new',
    'model',
    'variant',
    'mileage',
    'service_history',
    'doors_count',
    'seats_count',
    'color',
    'inside_color',
    'seat_type',
    'fuel',
    'gear_type',
    'wheel_drive',
    'cylinders',
    'engine_size',
    'engine',
    'import_origin',
    'body_type',
    'ownership',
    'registration',
    'insurance_type',
    'under_warranty',
    'computer_check',
    'warranty',
    'vehicle_features_convenience',
    'vehicle_features_entertainment',
    'vehicle_features_exterior',
    'vehicle_features_safety',
  };

  static const housingSchemaFieldIds = {
    'housing_purpose',
    'housing_category',
    'real_estate_type',
    'square_meters',
    'kitchen',
    'parking',
    'ac_type_housing',
    'kahramaa',
    'internet',
    'rental_period',
    'price_on_request',
    'housing_features',
    'housing_health_fitness',
    'housing_property_details',
    'housing_food_beverage',
    'housing_services',
    'housing_entertainment',
    'housing_shops',
  };

  static const housingLocationFieldIds = {
    'zone',
    'street_number',
    'building_number',
  };

  static const vehicleDetailScalarFieldIds = [
    'make',
    'model',
    'variant',
    'year',
    'brand_new',
    'mileage',
    'service_history',
    'doors_count',
    'seats_count',
    'color',
    'inside_color',
    'seat_type',
    'fuel',
    'gear_type',
    'wheel_drive',
    'cylinders',
    'engine_size',
    'engine',
    'import_origin',
    'body_type',
    'ownership',
    'registration',
    'insurance_type',
    'under_warranty',
    'computer_check',
    'warranty',
  ];

  static const vehicleFeatureGroupFieldIds = [
    'vehicle_features_convenience',
    'vehicle_features_entertainment',
    'vehicle_features_exterior',
    'vehicle_features_safety',
  ];

  static const housingDetailScalarFieldIds = [
    'housing_purpose',
    'housing_category',
    'real_estate_type',
    'square_meters',
    'kitchen',
    'parking',
    'ac_type_housing',
    'kahramaa',
    'internet',
    'rental_period',
    'price_on_request',
  ];

  static const housingFeatureGroupFieldIds = [
    'housing_features',
    'housing_health_fitness',
    'housing_property_details',
    'housing_food_beverage',
    'housing_services',
    'housing_entertainment',
    'housing_shops',
  ];

  static const _multiSelectFieldIds = {
    'vehicle_features_convenience',
    'vehicle_features_entertainment',
    'vehicle_features_exterior',
    'vehicle_features_safety',
    'housing_features',
    'housing_health_fitness',
    'housing_property_details',
    'housing_food_beverage',
    'housing_services',
    'housing_entertainment',
    'housing_shops',
    'gym_facilities',
    'ac_service_types',
    'travel_services',
    'pro_service_types',
  };

  static const _booleanFieldIds = {
    'brand_new',
    'under_warranty',
    'computer_check',
    'price_on_request',
    'iftar_deals',
  };

  static const _stringListFieldIds = {
    'services_offered',
    'membership_plans',
    'clinic_specialties',
  };

  static const _numericFieldIds = {
    'mileage',
    'square_meters',
  };

  static const _gridNumericFieldIds = {
    'year',
  };

  static bool isVehicleCategory(String categoryLeafId) {
    return categoryLeafId == 'cars' || categoryLeafId == 'motorcycles_bikes';
  }

  static Map<String, dynamic> buildVehicleSchemaFields(
    Map<String, dynamic> values,
  ) {
    return _buildFields(values, vehicleFieldIds);
  }

  static Map<String, dynamic> buildHousingSchemaFields(
    Map<String, dynamic> values,
  ) {
    return _buildFields(values, housingSchemaFieldIds);
  }

  /// Core service form keys persisted as top-level listing fields, not schemaFields.
  static const serviceCoreFieldIds = {
    'title',
    'description',
    'providerName',
    'contactName',
    'phone',
    'location',
    'photos',
    'serviceName',
    'serviceCategory',
    'listingType',
    'notes',
    'need_description',
  };

  static const businessCoreFieldIds = {
    'name',
    'location',
    'phone',
    'whatsapp',
    'description',
    'languages',
    'photos',
    'logo',
    'cover_photo',
    'contactMode',
  };

  static Map<String, dynamic> buildBusinessProfileFields(
    Map<String, dynamic> values,
  ) {
    final out = <String, dynamic>{};
    for (final entry in values.entries) {
      if (businessCoreFieldIds.contains(entry.key)) continue;
      final normalized = normalizeFieldValue(entry.key, entry.value);
      if (!_isEmpty(normalized)) {
        out[entry.key] = normalized;
      }
    }
    return out;
  }

  static Map<String, dynamic> buildServiceSchemaFields(
    Map<String, dynamic> values,
  ) {
    final out = <String, dynamic>{};
    for (final entry in values.entries) {
      if (serviceCoreFieldIds.contains(entry.key)) continue;
      final normalized = normalizeFieldValue(entry.key, entry.value);
      if (!_isEmpty(normalized)) {
        out[entry.key] = normalized;
      }
    }
    return out;
  }

  static String? optionalText(Map<String, dynamic> values, String key) {
    final text = values[key]?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static Map<String, dynamic> _buildFields(
    Map<String, dynamic> values,
    Set<String> fieldIds,
  ) {
    final out = <String, dynamic>{};
    for (final fieldId in fieldIds) {
      if (!values.containsKey(fieldId)) continue;
      final normalized = normalizeFieldValue(fieldId, values[fieldId]);
      if (!_isEmpty(normalized)) {
        out[fieldId] = normalized;
      }
    }
    return out;
  }

  static dynamic normalizeFieldValue(String fieldId, dynamic raw) {
    if (raw == null) return null;

    if (raw is num &&
        !_multiSelectFieldIds.contains(fieldId) &&
        !_booleanFieldIds.contains(fieldId)) {
      return raw;
    }

    if (_multiSelectFieldIds.contains(fieldId) ||
        _stringListFieldIds.contains(fieldId)) {
      final list = PostSchemaValueCoercion.asStringList(raw);
      return list.isEmpty ? null : list;
    }

    if (fieldId == 'opening_hours' && raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    if (_booleanFieldIds.contains(fieldId)) {
      if (raw is bool) return raw;
      final text = raw.toString().trim().toLowerCase();
      if (text.isEmpty) return null;
      return text == 'true';
    }

    if (_numericFieldIds.contains(fieldId)) {
      if (raw is num) return raw;
      final parsed = num.tryParse(raw.toString().trim());
      return parsed;
    }

    if (_gridNumericFieldIds.contains(fieldId)) {
      final parsed = PostSchemaValueCoercion.parseGridCount(raw);
      if (parsed != null) return parsed;
    }

    if (raw is Iterable && raw is! String) {
      final list = PostSchemaValueCoercion.asStringList(raw);
      return list.isEmpty ? null : list.first;
    }

    final text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    return false;
  }

  /// Normalizes persisted schema field values on read for display-safe types.
  static Map<String, dynamic> parseSchemaFieldsForRead(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, dynamic>{};
    for (final entry in raw.entries) {
      final fieldId = entry.key.toString();
      final normalized = normalizeFieldValue(fieldId, entry.value);
      if (!_isEmpty(normalized)) {
        out[fieldId] = normalized;
      }
    }
    return out;
  }
}
