import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';

/// User confirmation gate before AI suggestions populate the request form.
class PostServiceRequestAiConfirmStep extends StatefulWidget {
  const PostServiceRequestAiConfirmStep({
    super.key,
    required this.locale,
    required this.categoryPath,
    required this.categoryLabel,
    required this.fieldValues,
    required this.onConfirm,
    required this.onReject,
    this.totalSteps = 3,
  });

  final String locale;
  final String categoryPath;
  final String categoryLabel;
  final Map<String, dynamic> fieldValues;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  final VoidCallback onReject;
  final int totalSteps;

  @override
  State<PostServiceRequestAiConfirmStep> createState() =>
      _PostServiceRequestAiConfirmStepState();
}

class _PostServiceRequestAiConfirmStepState
    extends State<PostServiceRequestAiConfirmStep> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final entry in widget.fieldValues.entries)
        entry.key: TextEditingController(text: entry.value?.toString() ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _collectValues() {
    return {
      for (final entry in _controllers.entries)
        entry.key: entry.value.text.trim(),
    };
  }

  String _labelForField(String fieldId) {
    final key = switch (fieldId) {
      'need_description' => 'field_request_need',
      'urgency' => 'field_urgency',
      'preferred_time' => 'field_preferred_time',
      'budget_range' => 'field_budget_range',
      'notes' => 'field_request_notes',
      'problem' => 'field_service_problem',
      _ => 'field_$fieldId',
    };
    return PostEngineStrings.t(key, widget.locale);
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        PostFlowStepIndicator(
          currentStep: 1,
          totalSteps: widget.totalSteps,
          stepLabelKey: 'flow_step_category',
          locale: locale,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          PostEngineStrings.t('request_ai_confirm_title', locale),
          style: AppTypography.headline2.copyWith(fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          PostEngineStrings.t('request_ai_confirm_subtitle', locale),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassCard(
          borderRadius: AppSpacing.radiusLg,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PostEngineStrings.t('request_ai_confirm_category', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(widget.categoryLabel, style: AppTypography.subtitle),
              Text(
                widget.categoryPath,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          PostEngineStrings.t('request_ai_confirm_fields', locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final entry in _controllers.entries) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _labelForField(entry.key),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          GlassTextField(
            controller: entry.value,
            maxLines: entry.key == 'need_description' ? 4 : 1,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        GlassPrimaryButton(
          label: PostEngineStrings.t('request_ai_confirm_apply', locale),
          onPressed: () => widget.onConfirm(_collectValues()),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassSecondaryButton(
          label: PostEngineStrings.t('request_ai_confirm_reject', locale),
          onPressed: widget.onReject,
        ),
      ],
    );
  }
}
