import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_validation_debug.dart';
import 'package:raabta/features/post_engine/domain/post_validation_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_schema_providers.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_schema_form.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_vertical_preview.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';

enum _PreviewStep { form, validatedPreview }

/// Dev / Part 2 verification screen — dynamic schema-driven form preview.
class PostSchemaPreviewScreen extends ConsumerStatefulWidget {
  const PostSchemaPreviewScreen({
    super.key,
    required this.vertical,
    required this.categoryPath,
    this.initialValues = const {},
  });

  final PostVertical vertical;
  final String categoryPath;
  final Map<String, dynamic> initialValues;

  @override
  ConsumerState<PostSchemaPreviewScreen> createState() =>
      _PostSchemaPreviewScreenState();
}

class _PostSchemaPreviewScreenState extends ConsumerState<PostSchemaPreviewScreen> {
  late Map<String, dynamic> _values;
  final GlobalKey<PostSchemaFormState> _formKey = GlobalKey();
  Map<String, String> _errors = {};
  _PreviewStep _step = _PreviewStep.form;

  @override
  void initState() {
    super.initState();
    _values = Map<String, dynamic>.from(widget.initialValues);
  }

  void _applyValues(Map<String, dynamic> next) {
    setState(() {
      _values
        ..clear()
        ..addAll(next);
      _errors = {};
    });
  }

  void _validateAndAdvance() {
    final locale = ref.read(appLocaleProvider);
    final schema = ref
        .read(
          postCategoryFieldSchemaProvider(
            (
              vertical: widget.vertical,
              categoryPath: widget.categoryPath,
              forServiceRequest: false,
            ),
          ),
        )
        .value;
    if (schema == null) return;

    final values = _formKey.currentState?.collectValues() ?? _values;
    _applyValues(values);

    final validation = const PostValidationEngine().validate(
      schema: schema,
      values: values,
      locale: locale,
      debug: true,
      debugVertical: widget.vertical.id,
      debugCategoryPath: widget.categoryPath,
    );

    if (validation.isEmpty) {
      PostValidationDebug.logNavigation(
        nextRoute: 'preview/validated',
        allowed: true,
      );
      setState(() {
        _errors = {};
        _step = _PreviewStep.validatedPreview;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PostEngineStrings.t('validation_success', locale)),
        ),
      );
      return;
    }

    PostValidationDebug.logNavigation(
      nextRoute: 'preview/validated',
      allowed: false,
      reason: '${validation.length} validation error(s)',
    );
    setState(() => _errors = validation);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final schemaAsync = ref.watch(
      postCategoryFieldSchemaProvider(
        (
          vertical: widget.vertical,
          categoryPath: widget.categoryPath,
          forServiceRequest: false,
        ),
      ),
    );

    return GlassScreenScaffold(
      title: PostEngineStrings.t('ui_schema_preview_title', locale),
      body: schemaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: PostEngineStrings.t('schema_load_error', locale),
          onRetry: () => ref.invalidate(
            postCategoryFieldSchemaProvider(
              (
                vertical: widget.vertical,
                categoryPath: widget.categoryPath,
                forServiceRequest: false,
              ),
            ),
          ),
        ),
        data: (schema) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                '${widget.vertical.id} → ${widget.categoryPath}',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              ),
              if (schema.schemaGroupId != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'Schema group: ${schema.schemaGroupId}',
                    style: AppTypography.caption,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              if (_step == _PreviewStep.form)
                PostSchemaForm(
                  key: _formKey,
                  schema: schema,
                  values: _values,
                  locale: locale,
                  errors: _errors,
                  onChanged: _applyValues,
                )
              else
                PostVerticalPreview(
                  vertical: widget.vertical,
                  categoryPath: widget.categoryPath,
                  values: _values,
                  locale: locale,
                ),
              const SizedBox(height: AppSpacing.lg),
              if (_step == _PreviewStep.form)
                GlassPrimaryButton(
                  label: PostEngineStrings.t('action_validate', locale),
                  onPressed: _validateAndAdvance,
                )
              else ...[
                GlassSecondaryButton(
                  label: PostEngineStrings.t('action_back_to_edit', locale),
                  onPressed: () => setState(() => _step = _PreviewStep.form),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: PostEngineStrings.t('action_validate', locale),
                  onPressed: _validateAndAdvance,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: PostEngineStrings.t('schema_retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
