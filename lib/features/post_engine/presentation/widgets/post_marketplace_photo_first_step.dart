import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/post_engine/domain/post_media_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';

class PostMarketplacePhotoFirstStep extends StatefulWidget {
  const PostMarketplacePhotoFirstStep({
    super.key,
    required this.locale,
    required this.totalSteps,
    required this.mediaEngine,
    required this.initialPhotoPaths,
    required this.initialHint,
    required this.analyzing,
    required this.onContinue,
    required this.onManualCategory,
    required this.onManualForm,
  });

  final String locale;
  final int totalSteps;
  final PostMediaEngine mediaEngine;
  final List<String> initialPhotoPaths;
  final String initialHint;
  final bool analyzing;
  final void Function(List<String> photoPaths, String hint) onContinue;
  final VoidCallback onManualCategory;
  final VoidCallback onManualForm;

  @override
  State<PostMarketplacePhotoFirstStep> createState() =>
      _PostMarketplacePhotoFirstStepState();
}

class _PostMarketplacePhotoFirstStepState
    extends State<PostMarketplacePhotoFirstStep> {
  late List<String> _photoPaths;
  late final TextEditingController _hintController;

  @override
  void initState() {
    super.initState();
    _photoPaths = List<String>.from(widget.initialPhotoPaths);
    _hintController = TextEditingController(text: widget.initialHint);
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      final files = await widget.mediaEngine.pickPhotosWithSource(
        context: context,
      );
      if (files.isEmpty) return;
      setState(() {
        for (final file in files) {
          if (!_photoPaths.contains(file.path)) {
            _photoPaths.add(file.path);
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngineStrings.t('photo_pick_error', widget.locale),
          ),
        ),
      );
    }
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
          stepLabelKey: 'flow_step_photos',
          locale: locale,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          PostEngineStrings.t('marketplace_photo_first_title', locale),
          style: AppTypography.headline2,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          PostEngineStrings.t('marketplace_photo_first_body', locale),
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final path in _photoPaths)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    child: Image.file(
                      File(path),
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 88,
                        height: 88,
                        color: AppColors.surface,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () =>
                        setState(() => _photoPaths.remove(path)),
                  ),
                ],
              ),
            OutlinedButton.icon(
              onPressed: widget.analyzing ? null : _pickPhotos,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(PostEngineStrings.t('marketplace_photo_add', locale)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassTextField(
          controller: _hintController,
          label: PostEngineStrings.t('marketplace_photo_hint_label', locale),
          hint: PostEngineStrings.t(
            'marketplace_photo_hint_placeholder',
            locale,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassPrimaryButton(
          label: widget.analyzing
              ? PostEngineStrings.t('marketplace_ai_analyzing', locale)
              : PostEngineStrings.t('marketplace_photo_continue', locale),
          onPressed: _photoPaths.isEmpty || widget.analyzing
              ? null
              : () => widget.onContinue(_photoPaths, _hintController.text.trim()),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassSecondaryButton(
          label: PostEngineStrings.t('marketplace_photo_manual_category', locale),
          onPressed: widget.analyzing ? null : widget.onManualCategory,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: widget.analyzing ? null : widget.onManualForm,
          child: Text(
            PostEngineStrings.t('marketplace_photo_manual_form', locale),
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
