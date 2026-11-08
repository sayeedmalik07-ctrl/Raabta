/// Supported dynamic field types rendered by [PostSchemaForm].
enum PostFieldType {
  text('text'),
  textarea('textarea'),
  number('number'),
  currency('currency'),
  singleSelect('single_select'),
  multiSelect('multi_select'),
  boolean('boolean'),
  location('location'),
  photo('photo'),
  url('url'),
  stringList('string_list'),
  openingHours('opening_hours');

  const PostFieldType(this.id);
  final String id;

  static PostFieldType fromId(String? raw) {
    return PostFieldType.values.firstWhere(
      (t) => t.id == raw,
      orElse: () => PostFieldType.text,
    );
  }
}

/// Validation rule identifiers resolved by [PostValidationEngine].
enum PostValidationRule {
  required('required'),
  minLength('min_length'),
  maxLength('max_length'),
  minValue('min_value'),
  maxValue('max_value'),
  email('email'),
  phone('phone'),
  minPhotos('min_photos');

  const PostValidationRule(this.id);
  final String id;

  static PostValidationRule? fromId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final r in PostValidationRule.values) {
      if (r.id == raw) return r;
    }
    return null;
  }
}

/// Conditional visibility for a schema field.
class PostFieldVisibility {
  const PostFieldVisibility({
    required this.fieldId,
    this.equals = '',
    this.equalsAny = const [],
  });

  final String fieldId;

  /// Show when the parent field equals this single value.
  final String equals;

  /// Show when the parent field equals any of these values (OR).
  final List<String> equalsAny;

  factory PostFieldVisibility.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PostFieldVisibility(fieldId: '');
    }
    return PostFieldVisibility(
      fieldId: json['fieldId'] as String? ?? '',
      equals: json['equals'] as String? ?? '',
      equalsAny: (json['equalsAny'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        if (equals.isNotEmpty) 'equals': equals,
        if (equalsAny.isNotEmpty) 'equalsAny': equalsAny,
      };

  bool isVisible(Map<String, dynamic> values) {
    if (fieldId.isEmpty) return true;
    final current = values[fieldId]?.toString() ?? '';
    if (equalsAny.isNotEmpty) {
      return equalsAny.contains(current);
    }
    if (equals.isNotEmpty) {
      return current == equals;
    }
    return true;
  }
}

/// Media requirements attached to photo fields or category-level rules.
class PostMediaRequirements {
  const PostMediaRequirements({
    this.minCount = 0,
    this.maxCount = 10,
  });

  final int minCount;
  final int maxCount;

  factory PostMediaRequirements.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PostMediaRequirements();
    return PostMediaRequirements(
      minCount: (json['minCount'] as num?)?.toInt() ?? 0,
      maxCount: (json['maxCount'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'minCount': minCount,
        'maxCount': maxCount,
      };
}

/// Single field definition within a category schema.
class PostFieldSchema {
  const PostFieldSchema({
    required this.id,
    required this.type,
    required this.labelKey,
    this.placeholderKey,
    this.required = false,
    this.order = 0,
    this.validationRules = const [],
    this.allowedValueKeys = const [],
    this.visibility,
    this.mediaRequirements,
    this.defaultValue,
    this.publishingKey,
    this.uiHint,
  });

  final String id;
  final PostFieldType type;
  final String labelKey;
  final String? placeholderKey;
  final bool required;
  final int order;
  final List<String> validationRules;
  final List<String> allowedValueKeys;
  final PostFieldVisibility? visibility;
  final PostMediaRequirements? mediaRequirements;
  final String? defaultValue;

  /// Firestore / submission key when different from [id].
  final String? publishingKey;

  /// Optional renderer hint: searchable | grid | swatch
  final String? uiHint;

  String get effectivePublishingKey => publishingKey ?? id;

  factory PostFieldSchema.fromJson(Map<String, dynamic> json) {
    return PostFieldSchema(
      id: json['id'] as String? ?? '',
      type: PostFieldType.fromId(json['type'] as String?),
      labelKey: json['labelKey'] as String? ?? '',
      placeholderKey: json['placeholderKey'] as String?,
      required: json['required'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      validationRules: (json['validationRules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      allowedValueKeys: (json['allowedValueKeys'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      visibility: json['visibility'] is Map<String, dynamic>
          ? PostFieldVisibility.fromJson(
              json['visibility'] as Map<String, dynamic>,
            )
          : null,
      mediaRequirements: json['mediaRequirements'] is Map<String, dynamic>
          ? PostMediaRequirements.fromJson(
              json['mediaRequirements'] as Map<String, dynamic>,
            )
          : null,
      defaultValue: json['defaultValue'] as String?,
      publishingKey: json['publishingKey'] as String?,
      uiHint: json['uiHint'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.id,
        'labelKey': labelKey,
        if (placeholderKey != null) 'placeholderKey': placeholderKey,
        'required': required,
        'order': order,
        'validationRules': validationRules,
        'allowedValueKeys': allowedValueKeys,
        if (visibility != null) 'visibility': visibility!.toJson(),
        if (mediaRequirements != null)
          'mediaRequirements': mediaRequirements!.toJson(),
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (publishingKey != null) 'publishingKey': publishingKey,
        if (uiHint != null) 'uiHint': uiHint,
      };
}

/// Category node — supports nested subcategories.
class PostCategoryNode {
  const PostCategoryNode({
    required this.id,
    required this.labelKey,
    this.emoji,
    this.children = const [],
    this.schemaGroupId,
    this.fallbackLabel,
    this.leaf = false,
    this.identityVerificationRequired = false,
    this.businessVerificationRequired = false,
    this.licenseVerificationRequired = false,
  });

  final String id;
  final String labelKey;
  final String? emoji;
  final List<PostCategoryNode> children;
  final String? schemaGroupId;

  /// English fallback when [labelKey] is not yet translated.
  final String? fallbackLabel;

  /// True when this node is a postable leaf category.
  final bool leaf;

  /// Config-driven trust flags (Part 11C) — enforced at publish when set.
  final bool identityVerificationRequired;
  final bool businessVerificationRequired;
  final bool licenseVerificationRequired;

  /// Dot-separated path from root, e.g. `electronics.mobiles`.
  String path([String prefix = '']) {
    final segment = prefix.isEmpty ? id : '$prefix.$id';
    return segment;
  }

  PostCategoryNode? findByPath(String path) {
    if (path == id || path.endsWith('.$id') && path.split('.').last == id) {
      // exact match at this level handled by caller
    }
    final parts = path.split('.');
    PostCategoryNode? current = this;
    for (var i = 0; i < parts.length; i++) {
      if (current == null) return null;
      if (i == 0) {
        if (current.id != parts[i]) {
          // search among siblings not supported — caller passes root
          return null;
        }
      } else {
        current = current.children.cast<PostCategoryNode?>().firstWhere(
              (c) => c?.id == parts[i],
              orElse: () => null,
            );
      }
    }
    return current;
  }

  factory PostCategoryNode.fromJson(Map<String, dynamic> json) {
    return PostCategoryNode(
      id: json['id'] as String? ?? '',
      labelKey: json['labelKey'] as String? ?? '',
      emoji: json['emoji'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => PostCategoryNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      schemaGroupId: json['schemaGroupId'] as String?,
      fallbackLabel: json['fallbackLabel'] as String? ??
          json['subServiceName'] as String?,
      leaf: json['leaf'] as bool? ?? false,
      identityVerificationRequired:
          json['identityVerificationRequired'] as bool? ?? false,
      businessVerificationRequired:
          json['businessVerificationRequired'] as bool? ?? false,
      licenseVerificationRequired:
          json['licenseVerificationRequired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'labelKey': labelKey,
        if (emoji != null) 'emoji': emoji,
        'children': children.map((c) => c.toJson()).toList(),
        if (schemaGroupId != null) 'schemaGroupId': schemaGroupId,
        if (fallbackLabel != null) 'fallbackLabel': fallbackLabel,
        'leaf': leaf,
        if (identityVerificationRequired)
          'identityVerificationRequired': identityVerificationRequired,
        if (businessVerificationRequired)
          'businessVerificationRequired': businessVerificationRequired,
        if (licenseVerificationRequired)
          'licenseVerificationRequired': licenseVerificationRequired,
      };
}

/// Resolved field list for a specific category path.
class PostCategoryFieldSchema {
  const PostCategoryFieldSchema({
    required this.categoryPath,
    required this.fields,
    this.schemaGroupId,
  });

  final String categoryPath;
  final List<PostFieldSchema> fields;
  final String? schemaGroupId;

  List<PostFieldSchema> visibleFields(Map<String, dynamic> values) {
    return fields
        .where((f) => f.visibility?.isVisible(values) ?? true)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}

/// Full vertical schema bundle loaded from Firestore / cache.
class PostVerticalSchema {
  const PostVerticalSchema({
    required this.verticalId,
    required this.version,
    required this.categories,
    required this.schemaGroups,
    required this.categoryOverrides,
    this.requestCategoryOverrides = const {},
    this.updatedAt,
    this.fromCache = false,
  });

  final String verticalId;
  final int version;
  final List<PostCategoryNode> categories;
  final Map<String, List<PostFieldSchema>> schemaGroups;
  final Map<String, String> categoryOverrides;

  /// Customer-request schema group overrides (Services Part 10).
  final Map<String, String> requestCategoryOverrides;
  final DateTime? updatedAt;
  final bool fromCache;

  factory PostVerticalSchema.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
  }) {
    final groupsRaw = json['schemaGroups'] as Map<String, dynamic>? ?? {};
    final groups = <String, List<PostFieldSchema>>{};
    groupsRaw.forEach((key, value) {
      if (value is List) {
        groups[key] = value
            .map((e) => PostFieldSchema.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });

    final overridesRaw = json['categoryOverrides'] as Map<String, dynamic>? ?? {};
    final overrides = overridesRaw.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final requestOverridesRaw =
        json['requestCategoryOverrides'] as Map<String, dynamic>? ?? {};
    final requestOverrides = requestOverridesRaw.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return PostVerticalSchema(
      verticalId: json['verticalId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => PostCategoryNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      schemaGroups: groups,
      categoryOverrides: overrides,
      requestCategoryOverrides: requestOverrides,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      fromCache: fromCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'verticalId': verticalId,
        'version': version,
        'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
        'categories': categories.map((c) => c.toJson()).toList(),
        'schemaGroups': schemaGroups.map(
          (key, value) => MapEntry(key, value.map((f) => f.toJson()).toList()),
        ),
        'categoryOverrides': categoryOverrides,
        if (requestCategoryOverrides.isNotEmpty)
          'requestCategoryOverrides': requestCategoryOverrides,
      };

  PostCategoryNode? findCategoryByPath(String categoryPath) {
    final parts = categoryPath.split('.');
    if (parts.isEmpty) return null;

    PostCategoryNode? walk(List<PostCategoryNode> nodes, int depth) {
      for (final node in nodes) {
        if (node.id == parts[depth]) {
          if (depth == parts.length - 1) return node;
          return walk(node.children, depth + 1);
        }
      }
      return null;
    }

    return walk(categories, 0);
  }

  String? schemaGroupForCategory(
    String categoryPath, {
    bool forRequest = false,
  }) {
    if (forRequest) {
      if (requestCategoryOverrides.containsKey(categoryPath)) {
        return requestCategoryOverrides[categoryPath];
      }
      return 'service_request';
    }
    if (categoryOverrides.containsKey(categoryPath)) {
      return categoryOverrides[categoryPath];
    }
    final node = findCategoryByPath(categoryPath);
    return node?.schemaGroupId;
  }
}
