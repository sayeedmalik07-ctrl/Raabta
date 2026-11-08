import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_dropdown_field.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/post_engine/domain/models/post_schema_models.dart';
import 'package:raabta/features/post_engine/domain/post_location_engine.dart';
import 'package:raabta/features/post_engine/domain/post_media_engine.dart';
import 'package:raabta/features/post_engine/domain/post_schema_value_coercion.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_schema_extended_fields.dart';

/// Dynamically renders post form fields from a Firestore schema.
class PostSchemaForm extends StatefulWidget {
  const PostSchemaForm({
    super.key,
    required this.schema,
    required this.values,
    required this.locale,
    required this.onChanged,
    this.errors = const {},
    this.mediaEngine,
  });

  final PostCategoryFieldSchema schema;
  final Map<String, dynamic> values;
  final String locale;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final Map<String, String> errors;
  final PostMediaEngine? mediaEngine;

  @override
  State<PostSchemaForm> createState() => PostSchemaFormState();
}

/// State for [PostSchemaForm] — exposes [collectValues] for pre-validate sync.
class PostSchemaFormState extends State<PostSchemaForm> {
  final Map<String, TextEditingController> _controllers = {};

  /// Merges committed [widget.values] with current text controller contents.
  Map<String, dynamic> collectValues() {
    final merged = Map<String, dynamic>.from(widget.values);
    for (final field in widget.schema.visibleFields(merged)) {
      switch (field.type) {
        case PostFieldType.text:
        case PostFieldType.url:
        case PostFieldType.number:
        case PostFieldType.currency:
        case PostFieldType.textarea:
          final controller = _controllers[field.id];
          if (controller != null) {
            merged[field.id] = PostSchemaValueCoercion.coerceForField(
              field,
              controller.text,
            );
          }
        default:
          break;
      }
    }
    return merged;
  }

  @override
  void didUpdateWidget(PostSchemaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _syncControllersFromValues();
    }
  }

  void _syncControllersFromValues() {
    for (final field in widget.schema.fields) {
      switch (field.type) {
        case PostFieldType.text:
        case PostFieldType.url:
        case PostFieldType.number:
        case PostFieldType.currency:
        case PostFieldType.textarea:
          final text = widget.values[field.id]?.toString() ?? '';
          final controller = _controllers[field.id];
          if (controller != null) {
            if (controller.text != text) controller.text = text;
          } else if (text.isNotEmpty) {
            _controllerFor(field.id, text);
          }
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String fieldId, String? initial) {
    return _controllers.putIfAbsent(
      fieldId,
      () => TextEditingController(text: initial ?? ''),
    );
  }

  void _set(PostFieldSchema field, dynamic value) {
    final next = _pruneHiddenFields({
      ...widget.values,
      field.id: PostSchemaValueCoercion.coerceForField(field, value),
    });
    widget.onChanged(next);
  }

  /// Drops values for fields hidden by conditional visibility rules.
  Map<String, dynamic> _pruneHiddenFields(Map<String, dynamic> values) {
    final fieldIds = widget.schema.fields.map((f) => f.id).toSet();
    final visibleIds =
        widget.schema.visibleFields(values).map((f) => f.id).toSet();
    final result = Map<String, dynamic>.from(values);
    for (final id in fieldIds) {
      if (!visibleIds.contains(id)) {
        result.remove(id);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.schema.visibleFields(widget.values);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in fields) ...[
          _FieldTile(
            field: field,
            value: widget.values[field.id],
            locale: widget.locale,
            error: widget.errors[field.id],
            controller: _textController(field),
            mediaEngine: widget.mediaEngine ?? PostMediaEngine(),
            onChanged: (v) => _set(field, v),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  TextEditingController? _textController(PostFieldSchema field) {
    switch (field.type) {
      case PostFieldType.text:
      case PostFieldType.url:
      case PostFieldType.number:
      case PostFieldType.currency:
      case PostFieldType.textarea:
        return _controllerFor(field.id, widget.values[field.id]?.toString());
      default:
        return null;
    }
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.field,
    required this.value,
    required this.locale,
    required this.onChanged,
    this.error,
    this.controller,
    this.mediaEngine,
  });

  final PostFieldSchema field;
  final dynamic value;
  final String locale;
  final ValueChanged<dynamic> onChanged;
  final String? error;
  final TextEditingController? controller;
  final PostMediaEngine? mediaEngine;

  @override
  Widget build(BuildContext context) {
    final label = PostEngineStrings.t(field.labelKey, locale);
    final placeholder = field.placeholderKey != null
        ? PostEngineStrings.t(field.placeholderKey!, locale)
        : null;

    switch (field.type) {
      case PostFieldType.text:
      case PostFieldType.url:
      case PostFieldType.number:
      case PostFieldType.currency:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassTextField(
              controller: controller!,
              label: label,
              hint: placeholder,
              keyboardType: field.type == PostFieldType.number ||
                      field.type == PostFieldType.currency
                  ? TextInputType.number
                  : field.type == PostFieldType.url
                      ? TextInputType.url
                      : TextInputType.text,
              onChanged: onChanged,
            ),
            if (error != null) _errorText(context, error!),
          ],
        );
      case PostFieldType.stringList:
        return PostStringListField(
          label: label,
          locale: locale,
          placeholder: placeholder,
          items: coerceStringList(value),
          error: error,
          onChanged: onChanged,
        );
      case PostFieldType.openingHours:
        return PostOpeningHoursField(
          label: label,
          locale: locale,
          value: coerceOpeningHours(value),
          error: error,
          onChanged: onChanged,
        );
      case PostFieldType.textarea:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassTextField(
              controller: controller!,
              label: label,
              hint: placeholder,
              maxLines: 4,
              onChanged: onChanged,
            ),
            if (error != null) _errorText(context, error!),
          ],
        );
      case PostFieldType.singleSelect:
        final options =
            PostSchemaValueCoercion.optionKeys(field.allowedValueKeys);
        return switch (field.uiHint) {
          'searchable' => _SearchableSelectField(
              label: label,
              value: value?.toString(),
              options: options,
              locale: locale,
              hint: placeholder,
              error: error,
              onChanged: onChanged,
            ),
          'grid' => _GridSelectField(
              label: label,
              value: value?.toString(),
              options: options,
              locale: locale,
              error: error,
              onChanged: onChanged,
            ),
          'swatch' || 'searchable_swatch' => _SwatchSelectField(
              label: label,
              value: value?.toString(),
              options: options,
              locale: locale,
              error: error,
              searchable: field.uiHint == 'searchable_swatch',
              onChanged: onChanged,
            ),
          _ => _SelectField(
              label: label,
              value: value?.toString(),
              options: options,
              locale: locale,
              hint: placeholder,
              error: error,
              onChanged: onChanged,
            ),
        };
      case PostFieldType.location:
        return _LocationField(
          label: label,
          value: value?.toString(),
          locale: locale,
          hint: placeholder,
          error: error,
          onChanged: onChanged,
        );
      case PostFieldType.photo:
        final mismatchKey = PostSchemaValueCoercion.photoCategoryMismatchMessage(value);
        final mismatchMessage = mismatchKey == null
            ? null
            : (mismatchKey == 'photo_category_mismatch'
                ? PostEngineStrings.t('photo_category_mismatch', locale)
                : mismatchKey);
        return _PhotoField(
          label: label,
          hint: placeholder,
          locale: locale,
          paths: PostSchemaValueCoercion.asStringList(
            PostSchemaValueCoercion.extractPhotoRaw(value),
          ),
          error: error ?? mismatchMessage,
          mediaEngine: mediaEngine ?? PostMediaEngine(),
          maxCount: field.mediaRequirements?.maxCount ?? 10,
          onChanged: onChanged,
        );
      case PostFieldType.boolean:
        return SwitchListTile(
          title: Text(label, style: AppTypography.body),
          value: value == true,
          onChanged: (v) => onChanged(v),
        );
      case PostFieldType.multiSelect:
        return _MultiSelectField(
          label: label,
          value: PostSchemaValueCoercion.asStringList(value),
          options: PostSchemaValueCoercion.optionKeys(field.allowedValueKeys),
          locale: locale,
          error: error,
          onChanged: onChanged,
        );
    }
  }

  Widget _errorText(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _LocationField extends StatefulWidget {
  const _LocationField({
    required this.label,
    required this.value,
    required this.locale,
    required this.onChanged,
    this.hint,
    this.error,
  });

  final String label;
  final String? value;
  final String locale;
  final String? hint;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  @override
  State<_LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<_LocationField> {
  bool _resolving = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _resolving = true);
    try {
      final area = await const PostLocationEngine().resolveCurrentArea();
      if (!mounted) return;
      if (area == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              PostEngineStrings.t('location_permission_denied', widget.locale),
            ),
          ),
        );
        return;
      }
      widget.onChanged(area);
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPrimaryButton(
          expand: true,
          icon: Icons.my_location_outlined,
          label: PostEngineStrings.t(
            'action_use_current_location',
            widget.locale,
          ),
          onPressed: _resolving ? null : _useCurrentLocation,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          PostEngineStrings.t('location_visibility_hint', widget.locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          PostEngineStrings.t('location_manual_hint', widget.locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SelectField(
          label: widget.label,
          value: widget.value,
          options: PostSchemaValueCoercion.optionKeys(
            const PostLocationEngine().qatarAreas(),
          ),
          locale: widget.locale,
          hint: widget.hint,
          error: widget.error,
          useRawOptions: true,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.locale,
    required this.onChanged,
    this.error,
  });

  final String label;
  final List<String> value;
  final List<String> options;
  final String locale;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((key) {
            final selected = value.contains(key);
            return FilterChip(
              label: Text(PostEngineStrings.label(key, locale)),
              selected: selected,
              onSelected: (next) {
                final updated = List<String>.from(value);
                if (next) {
                  updated.add(key);
                } else {
                  updated.remove(key);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _SearchableSelectField extends StatelessWidget {
  const _SearchableSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.locale,
    required this.onChanged,
    this.hint,
    this.error,
  });

  final String label;
  final String? value;
  final List<String> options;
  final String locale;
  final String? hint;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Autocomplete<String>(
          initialValue: value != null
              ? TextEditingValue(text: PostEngineStrings.label(value!, locale))
              : null,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            if (query.isEmpty) return options;
            return options.where(
              (key) =>
                  PostEngineStrings.label(key, locale).toLowerCase().contains(query),
            );
          },
          displayStringForOption: (key) => PostEngineStrings.label(key, locale),
          onSelected: onChanged,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return GlassTextField(
              controller: controller,
              focusNode: focusNode,
              label: label,
              hint: hint ?? PostEngineStrings.t('field_select_placeholder', locale),
              onChanged: (_) {},
            );
          },
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _GridSelectField extends StatelessWidget {
  const _GridSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.locale,
    required this.onChanged,
    this.error,
  });

  final String label;
  final String? value;
  final List<String> options;
  final String locale;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((key) {
            final selected = value == key;
            return ChoiceChip(
              label: Text(PostEngineStrings.label(key, locale)),
              selected: selected,
              onSelected: (_) => onChanged(key),
            );
          }).toList(),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _SwatchSelectField extends StatefulWidget {
  const _SwatchSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.locale,
    required this.onChanged,
    this.error,
    this.searchable = false,
  });

  final String label;
  final String? value;
  final List<String> options;
  final String locale;
  final String? error;
  final bool searchable;
  final ValueChanged<dynamic> onChanged;

  @override
  State<_SwatchSelectField> createState() => _SwatchSelectFieldState();
}

class _SwatchSelectFieldState extends State<_SwatchSelectField> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static Color? _swatchColor(String key) => switch (key) {
        'color_white' || 'color_pearl' => Colors.white,
        'color_black' => Colors.black,
        'color_silver' || 'color_grey' => Colors.blueGrey,
        'color_blue' => Colors.blue,
        'color_red' || 'color_maroon' => Colors.red,
        'color_brown' => Colors.brown,
        'color_beige' || 'color_gold' => Colors.amber,
        'color_green' => Colors.green,
        'color_orange' => Colors.orange,
        'color_yellow' => Colors.yellow,
        'color_purple' => Colors.purple,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final filtered = widget.searchable && query.isNotEmpty
        ? widget.options.where(
            (key) => PostEngineStrings.label(key, widget.locale)
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
        : widget.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        if (widget.searchable) ...[
          const SizedBox(height: AppSpacing.sm),
          GlassTextField(
            controller: _searchController,
            hint: PostEngineStrings.t('field_search_color', widget.locale),
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: filtered.map((key) {
            final selected = widget.value == key;
            final swatch = _swatchColor(key);
            return InkWell(
              onTap: () => widget.onChanged(key),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: swatch ?? AppColors.surfaceElevated,
                  border: Border.all(
                    color: selected ? AppColors.cyanGlow : AppColors.glassBorderBright,
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: swatch == null
                    ? Center(
                        child: Text(
                          PostEngineStrings.label(key, widget.locale)[0],
                          style: AppTypography.caption,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        if (widget.value != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              PostEngineStrings.label(widget.value!, widget.locale),
              style: AppTypography.caption,
            ),
          ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.locale,
    required this.onChanged,
    this.hint,
    this.error,
    this.useRawOptions = false,
  });

  final String label;
  final String? value;
  final List<String> options;
  final String locale;
  final String? hint;
  final ValueChanged<dynamic> onChanged;
  final String? error;
  final bool useRawOptions;

  String _optionLabel(String key) =>
      useRawOptions ? key : PostEngineStrings.label(key, locale);

  TextStyle get _valueStyle =>
      AppTypography.body.copyWith(color: AppColors.textPrimary);

  @override
  Widget build(BuildContext context) {
    final selected = options.contains(value) ? value : null;
    final displayHint =
        hint ?? PostEngineStrings.t('field_select_placeholder', locale);

    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassDropdownField<String>(
            label: label,
            hint: displayHint,
            value: selected,
            selectedItemBuilder: (context) => options
                .map(
                  (key) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _optionLabel(key),
                      style: _valueStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            items: options
                .map(
                  (key) => DropdownMenuItem(
                    value: key,
                    child: Text(
                      _optionLabel(key),
                      style: _valueStyle.copyWith(
                        fontWeight:
                            key == selected ? FontWeight.w600 : FontWeight.w400,
                        color: key == selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoField extends StatefulWidget {
  const _PhotoField({
    required this.label,
    required this.hint,
    required this.locale,
    required this.paths,
    required this.onChanged,
    required this.mediaEngine,
    this.maxCount = 10,
    this.error,
  });

  final String label;
  final String? hint;
  final String locale;
  final List<String> paths;
  final ValueChanged<dynamic> onChanged;
  final PostMediaEngine mediaEngine;
  final int maxCount;
  final String? error;

  @override
  State<_PhotoField> createState() => _PhotoFieldState();
}

class _PhotoFieldState extends State<_PhotoField> {
  bool _picking = false;

  Future<void> _pick() async {
    if (_picking || widget.paths.length >= widget.maxCount) return;
    setState(() => _picking = true);
    try {
      final files = await widget.mediaEngine.pickPhotosWithSource(
        context: context,
        maxCount: widget.maxCount - widget.paths.length,
      );
      if (!mounted || files.isEmpty) return;
      final nextPaths = PostSchemaValueCoercion.asStringList([
        ...widget.paths,
        ...files.map((f) => f.path),
      ]);
      widget.onChanged(nextPaths);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngineStrings.t('photo_pick_error', widget.locale),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.caption),
        if (widget.hint != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(widget.hint!, style: AppTypography.caption),
        ],
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed:
              _picking || widget.paths.length >= widget.maxCount ? null : _pick,
          icon: _picking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_a_photo_outlined),
          label: Text(PostEngineStrings.t('action_add_photo', widget.locale)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            PostEngineStrings.format(
              'photo_count',
              widget.locale,
              params: {
                'count': '${widget.paths.length}',
                'max': '${widget.maxCount}',
              },
            ),
            style: AppTypography.caption.copyWith(
              color: widget.paths.length >= widget.maxCount
                  ? AppColors.textSecondary
                  : null,
            ),
          ),
        ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
