import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_media_limits.dart';

/// Global mandatory fields injected for every Marketplace category.
abstract final class MarketplaceGlobalFields {
  static const schemaGroupId = 'marketplace_global_mandatory';

  static List<PostFieldSchema> fields() => const [
        PostFieldSchema(
          id: 'condition',
          type: PostFieldType.singleSelect,
          labelKey: 'field_condition',
          placeholderKey: 'field_condition_placeholder',
          required: true,
          order: 10,
          validationRules: ['required'],
          allowedValueKeys: [
            'condition_new',
            'condition_used',
            'condition_refurbished',
          ],
        ),
        PostFieldSchema(
          id: 'price',
          type: PostFieldType.currency,
          labelKey: 'field_price',
          placeholderKey: 'field_price_placeholder',
          required: true,
          order: 20,
          validationRules: ['required', 'min_value'],
          defaultValue: 'QAR',
        ),
        PostFieldSchema(
          id: 'location',
          type: PostFieldType.location,
          labelKey: 'field_location',
          placeholderKey: 'field_location_placeholder',
          required: true,
          order: 30,
          validationRules: ['required'],
        ),
        PostFieldSchema(
          id: 'photos',
          type: PostFieldType.photo,
          labelKey: 'field_photos',
          placeholderKey: 'field_photos_placeholder',
          required: true,
          order: 40,
          validationRules: ['required', 'min_photos'],
          mediaRequirements: PostMediaRequirements(minCount: 1, maxCount: 10),
        ),
        PostFieldSchema(
          id: 'description',
          type: PostFieldType.textarea,
          labelKey: 'field_description',
          placeholderKey: 'field_description_placeholder',
          required: true,
          order: 1000,
          validationRules: ['required', 'min_length'],
        ),
      ];
}

/// Resolves effective fields for a category path within a vertical schema.
class PostSchemaResolver {
  const PostSchemaResolver();

  PostCategoryFieldSchema resolve({
    required PostVerticalSchema schema,
    required String categoryPath,
    PostVertical? vertical,
    bool forServiceRequest = false,
  }) {
    final groupId = schema.schemaGroupForCategory(
      categoryPath,
      forRequest: forServiceRequest,
    );
    final custom = groupId != null
        ? schema.schemaGroups[groupId] ?? const <PostFieldSchema>[]
        : const <PostFieldSchema>[];

    final merged = <PostFieldSchema>[];
    if (vertical == PostVertical.marketplace ||
        schema.verticalId == PostVertical.marketplace.id) {
      merged.addAll(MarketplaceGlobalFields.fields());
    }
    merged.addAll(custom);

    // De-dupe by id — custom fields can extend but not override globals.
    final seen = <String>{};
    final unique = <PostFieldSchema>[];
    for (final field in merged) {
      if (seen.add(field.id)) unique.add(field);
    }
    unique.sort((a, b) => a.order.compareTo(b.order));

    final verticalId =
        vertical ?? PostVertical.fromId(schema.verticalId) ?? PostVertical.housing;
    final withPhotoLimits = unique
        .map(
          (field) => PostMediaLimits.withPhotoLimit(
            field,
            vertical: verticalId,
            categoryPath: categoryPath,
          ),
        )
        .toList();

    return PostCategoryFieldSchema(
      categoryPath: categoryPath,
      schemaGroupId: groupId,
      fields: withPhotoLimits,
    );
  }
}
