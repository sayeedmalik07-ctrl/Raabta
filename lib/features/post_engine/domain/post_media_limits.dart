import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';

/// Category-aware photo limits — Vehicles/Housing 20, general Marketplace 12, Services 8.
abstract final class PostMediaLimits {
  static const defaultMax = 12;
  static const vehicleMax = 20;
  static const housingMax = 20;
  static const servicesMax = 8;
  static const businessMax = 12;

  static int maxPhotosFor({
    required PostVertical vertical,
    required String categoryPath,
  }) {
    final path = categoryPath.toLowerCase();
    return switch (vertical) {
      PostVertical.housing => housingMax,
      PostVertical.services => servicesMax,
      PostVertical.business => businessMax,
      PostVertical.marketplace =>
        path.contains('vehicle') || path.contains('car')
            ? vehicleMax
            : defaultMax,
      PostVertical.jobs => 0,
    };
  }

  static PostFieldSchema withPhotoLimit(
    PostFieldSchema field, {
    required PostVertical vertical,
    required String categoryPath,
  }) {
    if (field.type != PostFieldType.photo) return field;
    final max = maxPhotosFor(vertical: vertical, categoryPath: categoryPath);
    final existing = field.mediaRequirements ?? const PostMediaRequirements();
    return PostFieldSchema(
      id: field.id,
      type: field.type,
      labelKey: field.labelKey,
      placeholderKey: field.placeholderKey,
      required: field.required,
      order: field.order,
      validationRules: field.validationRules,
      allowedValueKeys: field.allowedValueKeys,
      visibility: field.visibility,
      mediaRequirements: PostMediaRequirements(
        minCount: existing.minCount,
        maxCount: max,
      ),
      defaultValue: field.defaultValue,
      publishingKey: field.publishingKey,
      uiHint: field.uiHint,
    );
  }
}
