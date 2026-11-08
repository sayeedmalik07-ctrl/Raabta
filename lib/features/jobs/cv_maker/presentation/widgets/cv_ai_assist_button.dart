import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/providers/cv_providers.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_ai_service.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_analytics_service.dart';

class CvAiAssistButton extends ConsumerStatefulWidget {
  const CvAiAssistButton({
    super.key,
    required this.cv,
    required this.fieldId,
    required this.roughInput,
    required this.contextFacts,
    required this.onSelected,
    this.language = 'English',
  });

  final CvDocument cv;
  final String fieldId;
  final String roughInput;
  final Map<String, dynamic> contextFacts;
  final ValueChanged<String> onSelected;
  final String language;

  @override
  ConsumerState<CvAiAssistButton> createState() => _CvAiAssistButtonState();
}

class _CvAiAssistButtonState extends ConsumerState<CvAiAssistButton> {
  bool _loading = false;

  bool get _canAssist => widget.cv.canAssistField(widget.fieldId);

  bool get _fieldLimit =>
      widget.cv.assistCountFor(widget.fieldId) >= CvDocument.maxAiAssistPerField;

  bool get _totalLimit =>
      widget.cv.totalAiAssistCalls >= CvDocument.maxAiAssistTotal;

  String get _label {
    if (_totalLimit || _fieldLimit) return 'Limit reached — edit manually';
    return 'Help me write this';
  }

  Future<void> _assist() async {
    if (!_canAssist || _loading) return;
    setState(() => _loading = true);

    final result = await ref.read(cvAiServiceProvider).assistField(
          cvId: widget.cv.id,
          fieldId: widget.fieldId,
          roughInput: widget.roughInput,
          contextFacts: widget.contextFacts,
          language: widget.language,
        );

    await ref.read(cvBuilderProvider.notifier).refreshAiCounts();

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.totalLimitReached || result.fieldLimitReached
                ? 'AI assist limit reached for this CV.'
                : 'Could not generate suggestions. Try again.',
          ),
        ),
      );
      return;
    }

    if (!result.cached) {
      CvAnalyticsService.cvAiAssistUsed(widget.fieldId);
    }
    await _showOptions(result.options);
  }

  Future<void> _showOptions(List<String> options) async {
    if (!mounted || options.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick a phrasing', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              ...options.map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Material(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: InkWell(
                      onTap: () {
                        widget.onSelected(opt);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(opt, style: AppTypography.body),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _canAssist && !_loading ? _assist : null,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.auto_awesome, size: 18),
      label: Text(_label, style: AppTypography.caption),
      style: TextButton.styleFrom(
        foregroundColor:
            _canAssist ? AppColors.brandFamilyMain : AppColors.textSecondary,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
