import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/post_engine/data/post_schema_persistence.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';

/// Renders persisted post-engine schema fields on listing detail screens.
abstract final class PostSchemaListingDisplay {
  static String formatFieldValue(
    String fieldId,
    dynamic value,
    String locale,
  ) {
    if (value == null) return '';

    if (value is bool) {
      return PostEngineStrings.t(
        value ? 'warranty_yes' : 'warranty_no',
        locale,
      );
    }

    if (value is num) {
      return value.toString();
    }

    if (value is Iterable && value is! String) {
      final labels = PostSchemaValueCoercion.asStringList(value)
          .map((key) => PostEngineStrings.label(key, locale))
          .where((label) => label.isNotEmpty)
          .toList();
      return labels.join(', ');
    }

    final text = value.toString().trim();
    if (text.isEmpty) return '';
    return PostEngineStrings.label(text, locale);
  }

  static bool hasDisplayValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return true;
    if (value is num) return true;
    if (value is Iterable && value is! String) {
      return PostSchemaValueCoercion.asStringList(value).isNotEmpty;
    }
    return value.toString().trim().isNotEmpty;
  }

  static bool isFeatureGroup(String fieldId) {
    return PostSchemaPersistence.vehicleFeatureGroupFieldIds.contains(fieldId) ||
        PostSchemaPersistence.housingFeatureGroupFieldIds.contains(fieldId);
  }

  /// Resolves Part 8 service field labels without duplicating option logic.
  static String serviceFieldLabel(String fieldId, String locale) {
    const labelKeyOverrides = {
      'ac_type': 'field_svc_ac_type',
      'problem': 'field_service_problem',
    };
    if (labelKeyOverrides.containsKey(fieldId)) {
      return PostEngineStrings.label(labelKeyOverrides[fieldId]!, locale);
    }
    if (fieldId == 'service_type') {
      for (final key in [
        'field_beauty_service',
        'field_landscape_service',
      ]) {
        final resolved = PostEngineStrings.t(key, locale);
        if (resolved != key) return resolved;
      }
    }
    return PostEngineStrings.label('field_$fieldId', locale);
  }
}

class PostSchemaListingAttributesSection extends StatelessWidget {
  const PostSchemaListingAttributesSection({
    super.key,
    required this.schemaFields,
    required this.locale,
    required this.scalarFieldIds,
    required this.featureGroupFieldIds,
    this.sectionTitle,
    this.extraRows = const {},
    this.fieldLabelForId,
  });

  final Map<String, dynamic> schemaFields;
  final String locale;
  final List<String> scalarFieldIds;
  final List<String> featureGroupFieldIds;
  final String? sectionTitle;
  final Map<String, String> extraRows;
  final String Function(String fieldId)? fieldLabelForId;

  @override
  Widget build(BuildContext context) {
    final scalarRows = <MapEntry<String, String>>[];
    for (final fieldId in scalarFieldIds) {
      final value = schemaFields[fieldId];
      if (!PostSchemaListingDisplay.hasDisplayValue(value)) continue;
      final label = fieldLabelForId?.call(fieldId) ??
          PostEngineStrings.label('field_$fieldId', locale);
      scalarRows.add(
        MapEntry(
          label,
          PostSchemaListingDisplay.formatFieldValue(fieldId, value, locale),
        ),
      );
    }

    for (final entry in extraRows.entries) {
      if (entry.value.trim().isEmpty) continue;
      scalarRows.add(MapEntry(entry.key, entry.value));
    }

    final featureGroups = <String, List<String>>{};
    for (final fieldId in featureGroupFieldIds) {
      final raw = schemaFields[fieldId];
      if (!PostSchemaListingDisplay.hasDisplayValue(raw)) continue;
      final labels = PostSchemaValueCoercion.asStringList(raw)
          .map((key) => PostEngineStrings.label(key, locale))
          .where((label) => label.isNotEmpty)
          .toList();
      if (labels.isEmpty) continue;
      featureGroups[fieldId] = labels;
    }

    if (scalarRows.isEmpty && featureGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null) ...[
          Text(sectionTitle!, style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (scalarRows.isNotEmpty) ...[
          ...scalarRows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.key,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(row.value, style: AppTypography.body),
                  ),
                ],
              ),
            ),
          ),
          if (featureGroups.isNotEmpty) const SizedBox(height: AppSpacing.md),
        ],
        ...featureGroups.entries.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PostEngineStrings.label('field_${group.key}', locale),
                  style: AppTypography.title.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: group.value
                      .map(
                        (label) => GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          borderRadius: AppSpacing.radiusFull,
                          child: Text(label, style: AppTypography.caption),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Vehicle listing schema attributes (Part D).
class VehicleListingAttributesSection extends StatelessWidget {
  const VehicleListingAttributesSection({
    super.key,
    required this.schemaFields,
    required this.locale,
    this.sectionTitle,
  });

  final Map<String, dynamic> schemaFields;
  final String locale;
  final String? sectionTitle;

  @override
  Widget build(BuildContext context) {
    return PostSchemaListingAttributesSection(
      schemaFields: schemaFields,
      locale: locale,
      scalarFieldIds: PostSchemaPersistence.vehicleDetailScalarFieldIds,
      featureGroupFieldIds: PostSchemaPersistence.vehicleFeatureGroupFieldIds,
      sectionTitle: sectionTitle,
    );
  }
}

/// Services differentiated schema attributes (Part 8 / 9A).
class ServiceListingAttributesSection extends StatelessWidget {
  const ServiceListingAttributesSection({
    super.key,
    required this.schemaFields,
    required this.locale,
    this.sectionTitle,
  });

  final Map<String, dynamic> schemaFields;
  final String locale;
  final String? sectionTitle;

  static const _preferredOrder = [
    'ac_type',
    'ac_brand',
    'ac_brand_other',
    'problem',
    'problem_other',
    'property_type',
    'emergency',
    'urgency',
    'preferred_time',
    'preferred_date',
    'event_type',
    'event_other',
    'duration',
    'vehicle_type',
    'wash_package',
    'detail_package',
    'service_location',
    'brand',
  ];

  List<String> _orderedFieldIds() {
    final keys = schemaFields.keys
        .where((id) => PostSchemaListingDisplay.hasDisplayValue(schemaFields[id]))
        .toList();
    keys.sort((a, b) {
      final ai = _preferredOrder.indexOf(a);
      final bi = _preferredOrder.indexOf(b);
      if (ai >= 0 && bi >= 0) return ai.compareTo(bi);
      if (ai >= 0) return -1;
      if (bi >= 0) return 1;
      return a.compareTo(b);
    });
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    return PostSchemaListingAttributesSection(
      schemaFields: schemaFields,
      locale: locale,
      scalarFieldIds: _orderedFieldIds(),
      featureGroupFieldIds: const [],
      sectionTitle: sectionTitle,
      fieldLabelForId: (fieldId) =>
          PostSchemaListingDisplay.serviceFieldLabel(fieldId, locale),
    );
  }
}

/// Housing extended schema attributes (Part E).
class HousingListingAttributesSection extends StatelessWidget {
  const HousingListingAttributesSection({
    super.key,
    required this.schemaFields,
    required this.locale,
    this.zone,
    this.streetNumber,
    this.buildingNumber,
    this.sectionTitle,
  });

  final Map<String, dynamic> schemaFields;
  final String locale;
  final String? zone;
  final String? streetNumber;
  final String? buildingNumber;
  final String? sectionTitle;

  @override
  Widget build(BuildContext context) {
    final extraRows = <String, String>{};
    if (zone != null && zone!.trim().isNotEmpty) {
      extraRows[PostEngineStrings.t('field_zone', locale)] =
          PostSchemaListingDisplay.formatFieldValue('zone', zone, locale);
    }
    if (streetNumber != null && streetNumber!.trim().isNotEmpty) {
      extraRows[PostEngineStrings.t('field_street_number', locale)] =
          streetNumber!.trim();
    }
    if (buildingNumber != null && buildingNumber!.trim().isNotEmpty) {
      extraRows[PostEngineStrings.t('field_building_number', locale)] =
          buildingNumber!.trim();
    }

    return PostSchemaListingAttributesSection(
      schemaFields: schemaFields,
      locale: locale,
      scalarFieldIds: PostSchemaPersistence.housingDetailScalarFieldIds,
      featureGroupFieldIds: PostSchemaPersistence.housingFeatureGroupFieldIds,
      sectionTitle: sectionTitle,
      extraRows: extraRows,
    );
  }
}
