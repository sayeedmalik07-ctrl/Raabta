import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';

/// Optional AI entry for customer service requests (Part 11A).
class PostServiceRequestAiEntryStep extends StatefulWidget {
  const PostServiceRequestAiEntryStep({
    super.key,
    required this.locale,
    required this.controller,
    required this.analyzing,
    required this.onAnalyze,
    required this.onManual,
    this.totalSteps = 3,
  });

  final String locale;
  final TextEditingController controller;
  final bool analyzing;
  final VoidCallback onAnalyze;
  final VoidCallback onManual;
  final int totalSteps;

  @override
  State<PostServiceRequestAiEntryStep> createState() =>
      _PostServiceRequestAiEntryStepState();
}

class _PostServiceRequestAiEntryStepState
    extends State<PostServiceRequestAiEntryStep> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final canAnalyze =
        widget.controller.text.trim().length >= 8 && !widget.analyzing;

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
          PostEngineStrings.t('request_ai_title', locale),
          style: AppTypography.headline2.copyWith(fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          PostEngineStrings.t('request_ai_subtitle', locale),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassTextField(
          controller: widget.controller,
          maxLines: 5,
          hint: PostEngineStrings.t('request_ai_hint', locale),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassPrimaryButton(
          label: widget.analyzing
              ? PostEngineStrings.t('request_ai_analyzing', locale)
              : PostEngineStrings.t('request_ai_analyze', locale),
          onPressed: canAnalyze ? widget.onAnalyze : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassSecondaryButton(
          label: PostEngineStrings.t('request_ai_manual', locale),
          onPressed: widget.analyzing ? null : widget.onManual,
        ),
      ],
    );
  }
}
