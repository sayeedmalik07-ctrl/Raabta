import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/draft_restore_banner.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/services/drafts/draft_form_controller.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_banner.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_section.dart';
import 'package:raabta/features/community/widgets/community_group_tag_selector.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/link_safety_author_compose_hint.dart';

class GroupFeedComposer extends StatefulWidget {
  const GroupFeedComposer({
    super.key,
    required this.controller,
    required this.draftController,
    required this.showDraftBanner,
    required this.draftRecord,
    required this.isJoined,
    required this.isSubmitting,
    this.moderationBlock,
    this.moderationError,
    this.rephraseAttemptsUsed = 0,
    this.onRephraseAttemptConsumed,
    this.onApplyRephraseSuggestion,
    required this.onRestoreDraft,
    required this.onDiscardDraft,
    required this.onSubmit,
    required this.onJoinPrompt,
    this.joinedGroupIds = const {},
    this.selectedGroupTags = const {},
    this.onGroupTagsChanged,
    this.locale = 'English',
    this.suggestedContentLabelIds = const [],
  });

  final TextEditingController controller;
  final DraftFormController draftController;
  final bool showDraftBanner;
  final DraftRecord? draftRecord;
  final bool isJoined;
  final bool isSubmitting;
  final CommunityModerationBlockCopy? moderationBlock;
  final String? moderationError;
  final int rephraseAttemptsUsed;
  final VoidCallback? onRephraseAttemptConsumed;
  final ValueChanged<String>? onApplyRephraseSuggestion;
  final VoidCallback onRestoreDraft;
  final VoidCallback onDiscardDraft;
  final VoidCallback onSubmit;
  final VoidCallback onJoinPrompt;
  final Set<int> joinedGroupIds;
  final Set<String> selectedGroupTags;
  final ValueChanged<Set<String>>? onGroupTagsChanged;
  final String locale;
  final List<String> suggestedContentLabelIds;

  @override
  State<GroupFeedComposer> createState() => _GroupFeedComposerState();
}

class _GroupFeedComposerState extends State<GroupFeedComposer> {
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
    final controller = widget.controller;
    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      borderRadius: 0,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isJoined)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  CommunityStrings.t('community_composer_join_prompt', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            if (widget.showDraftBanner && widget.draftRecord != null)
              DraftRestoreBanner(
                savedAt: widget.draftRecord!.savedAt,
                onRestore: widget.onRestoreDraft,
                onDiscard: widget.onDiscardDraft,
              ),
            if (widget.moderationBlock != null &&
                widget.onRephraseAttemptConsumed != null &&
                widget.onApplyRephraseSuggestion != null)
              CommunityModerationBlockSection(
                block: widget.moderationBlock!,
                locale: locale,
                sourceText: controller.text,
                rephraseAttemptsUsed: widget.rephraseAttemptsUsed,
                onRephraseAttemptConsumed: widget.onRephraseAttemptConsumed!,
                onApplySuggestion: widget.onApplyRephraseSuggestion!,
              )
            else if (widget.moderationBlock != null)
              CommunityModerationBlockBanner(
                message: widget.moderationBlock!.message,
                guidelinesLine: widget.moderationBlock!.guidelinesLine,
              )
            else if (widget.moderationError != null)
              CommunityModerationBlockBanner(
                message: widget.moderationError!,
              ),
            if (widget.onGroupTagsChanged != null &&
                (widget.isJoined ||
                    widget.joinedGroupIds.isNotEmpty ||
                    widget.suggestedContentLabelIds.isNotEmpty)) ...[
              CommunityGroupTagSelector(
                joinedGroupIds: widget.joinedGroupIds,
                selectedIds: widget.selectedGroupTags,
                locale: locale,
                suggestedContentLabelIds: widget.suggestedContentLabelIds,
                onChanged: widget.onGroupTagsChanged!,
                enabled: !widget.isSubmitting && widget.isJoined,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            LinkSafetyAuthorComposeHint(
              text: controller.text,
              locale: locale,
              surface: LinkSafetySurface.communityFeed,
              onRemoveLink: () {
                controller.text = controller.text.replaceAll(
                  RegExp(
                    r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
                    caseSensitive: false,
                  ),
                  '',
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: AppSpacing.radiusFull,
                    child: TextField(
                      controller: controller,
                      enabled: widget.isJoined && !widget.isSubmitting,
                      onTap: widget.isJoined ? null : widget.onJoinPrompt,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isJoined
                            ? CommunityStrings.t(
                                'community_composer_hint_joined',
                                locale,
                              )
                            : CommunityStrings.t(
                                'community_composer_hint_not_joined',
                                locale,
                              ),
                        hintStyle: AppTypography.body,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GlassCard(
                  onTap: widget.isJoined && !widget.isSubmitting
                      ? widget.onSubmit
                      : widget.onJoinPrompt,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  borderRadius: AppSpacing.radiusFull,
                  glowColor: AppColors.brandFamilyMain,
                  glowIntensity: 0.2,
                  child: widget.isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brandFamilyMain,
                          ),
                        )
                      : CommunityHubIcons.composerSend(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
