import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';
import 'package:raabta/features/community/services/community_moderation_rephrase_service.dart';

/// Optional respectful rewrite UI for eligible hard blocks (Part B).
class CommunityModerationRephrasePanel extends StatefulWidget {
  const CommunityModerationRephrasePanel({
    super.key,
    required this.locale,
    required this.sourceText,
    required this.attemptsUsed,
    required this.onRequestRephrase,
    required this.onAttemptConsumed,
    required this.onApplySuggestion,
    this.compact = false,
  });

  final String locale;
  final String sourceText;
  final int attemptsUsed;
  final Future<CommunityRephraseResult> Function() onRequestRephrase;
  final VoidCallback onAttemptConsumed;
  final ValueChanged<String> onApplySuggestion;
  final bool compact;

  @override
  State<CommunityModerationRephrasePanel> createState() =>
      _CommunityModerationRephrasePanelState();
}

class _CommunityModerationRephrasePanelState
    extends State<CommunityModerationRephrasePanel> {
  bool _loading = false;
  CommunityRephraseFailureKind? _failure;
  CommunityRephraseSuggestion? _suggestion;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  bool get _attemptsExhausted =>
      widget.attemptsUsed >=
      CommunityModerationConfig.maxRephraseAttemptsPerDraft;

  Future<void> _runRephrase() async {
    if (_loading || _attemptsExhausted) return;
    setState(() {
      _loading = true;
      _failure = null;
      _suggestion = null;
    });
    final result = await widget.onRequestRephrase();
    if (!mounted) return;
    widget.onAttemptConsumed();
    setState(() {
      _loading = false;
      if (result.success && result.suggestion != null) {
        _suggestion = result.suggestion;
        _editController.text = result.suggestion!.rewrite;
        _failure = null;
      } else {
        _failure = result.failure ?? CommunityRephraseFailureKind.provider;
      }
    });
  }

  String _failureMessage(CommunityRephraseFailureKind kind) {
    return switch (kind) {
      CommunityRephraseFailureKind.dailyLimit =>
        CommunityStrings.t('community_mod_rephrase_daily_limit', widget.locale),
      CommunityRephraseFailureKind.authRequired =>
        CommunityStrings.t('community_mod_rephrase_auth_required', widget.locale),
      CommunityRephraseFailureKind.cannotRephrase =>
        CommunityStrings.t('community_mod_rephrase_cannot', widget.locale),
      CommunityRephraseFailureKind.invalidResponse ||
      CommunityRephraseFailureKind.provider =>
        CommunityStrings.t('community_mod_rephrase_failed', widget.locale),
    };
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final padding = widget.compact ? AppSpacing.xs : AppSpacing.sm;

    return Padding(
      padding: EdgeInsets.only(top: padding, bottom: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_suggestion == null && !_attemptsExhausted) ...[
            Text(
              CommunityStrings.t('community_mod_rephrase_hint', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: widget.compact ? AppSpacing.xs : AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('community_mod_rephrase_action'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandFamilyText,
                ),
                onPressed: _loading ? null : _runRephrase,
                icon: _loading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brandFamilyMain,
                        ),
                      )
                    : const Icon(Icons.auto_fix_high_outlined, size: 18),
                label: Text(
                  _loading
                      ? CommunityStrings.t(
                          'community_mod_rephrase_loading',
                          locale,
                        )
                      : CommunityStrings.t(
                          'community_mod_rephrase_action',
                          locale,
                        ),
                ),
              ),
            ),
          ],
          if (_attemptsExhausted && _suggestion == null)
            Text(
              CommunityStrings.t('community_mod_rephrase_attempts_exhausted', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (_failure != null && _suggestion == null) ...[
            Text(
              _failureMessage(_failure!),
              style: AppTypography.caption.copyWith(
                color: AppColors.error,
              ),
            ),
            if (!_attemptsExhausted)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _loading ? null : _runRephrase,
                  child: Text(
                    CommunityStrings.t('community_mod_rephrase_retry', locale),
                  ),
                ),
              ),
          ],
          if (_suggestion != null) ...[
            Text(
              CommunityStrings.t('community_mod_rephrase_review_hint', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_suggestion!.keptMeaning != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _suggestion!.keptMeaning!,
                style: AppTypography.caption.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _editController,
              maxLines: widget.compact ? 3 : 4,
              style: AppTypography.bodySmall,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandFamilyMain,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final text = _editController.text.trim();
                    if (text.isEmpty) return;
                    widget.onApplySuggestion(text);
                    setState(() {
                      _suggestion = null;
                      _failure = null;
                    });
                  },
                  child: Text(
                    CommunityStrings.t(
                      'community_mod_rephrase_use_suggestion',
                      locale,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _suggestion = null;
                      _failure = null;
                    });
                  },
                  child: Text(
                    CommunityStrings.t(
                      'community_mod_rephrase_edit_myself',
                      locale,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
