import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/hub/hub_picker_sheet.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_check_config.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/services/community_moderation_confirm_flow.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_banner.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_section.dart';
import 'package:raabta/features/community/widgets/community_cross_post_prompt.dart';
import 'package:raabta/features/community/widgets/community_group_tag_selector.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';

Future<void> showRumourCheckComposerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Set<int> joinedGroupIds,
  required List<String> suggestedContentLabelIds,
  required VoidCallback onSubmitStarted,
  required VoidCallback onSubmitFinished,
}) async {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  var rumourCategory = RumourCategory.visa;
  var loading = false;
  var disclaimerAccepted = false;
  String? moderationErrorKey;
  CommunityModerationBlockCopy? moderationBlock;
  var rephraseAttempts = 0;
  var selectedGroupTags = <String>{};

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return CommunityReactiveLocale(
        builder: (context, locale) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              final moderationError = moderationErrorKey == null
                  ? null
                  : CommunityStrings.t(moderationErrorKey!, locale);
              return DraftAwareSheet(
                formId: DraftBoxKeys.rumourCheckComposer,
                controllers: [titleController, bodyController],
                serialize: () => {
                  'title': titleController.text,
                  'body': bodyController.text,
                  'rumourCategory': rumourCategory.name,
                  'disclaimerAccepted': disclaimerAccepted,
                },
                applyDraft: (data) {
                  setSheetState(() {
                    titleController.text = data['title']?.toString() ?? '';
                    bodyController.text = data['body']?.toString() ?? '';
                    rumourCategory = RumourCheckModelParsing.categoryFromId(
                          data['rumourCategory']?.toString(),
                        ) ??
                        RumourCategory.visa;
                    disclaimerAccepted =
                        data['disclaimerAccepted'] == true;
                  });
                },
                builder: (context, draft) {
                  return HubPickerSheet(
                    title: CommunityStrings.t(
                      'community_rumour_sheet_title',
                      locale,
                    ),
                    subtitle: CommunityStrings.t(
                      'community_rumour_presubmit_notice',
                      locale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                            controller: titleController,
                            maxLength: RumourCheckConfig.maxTitleLength,
                            onChanged: (_) => draft.notifyChanged(),
                            decoration: InputDecoration(
                              hintText: CommunityStrings.t(
                                'community_rumour_claim_hint',
                                locale,
                              ),
                              counterStyle: AppTypography.caption,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: bodyController,
                            maxLines: 4,
                            maxLength: RumourCheckConfig.maxClaimTextLength,
                            onChanged: (_) => draft.notifyChanged(),
                            decoration: InputDecoration(
                              hintText: CommunityStrings.t(
                                'community_rumour_body_hint',
                                locale,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            CommunityStrings.t(
                              'community_rumour_category_label',
                              locale,
                            ),
                            style: AppTypography.subtitle,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final id in RumourCheckConfig.rumourCategoryIds)
                                FilterChip(
                                  label: Text(
                                    CommunityStrings.rumourCategoryLabel(
                                      id,
                                      locale,
                                    ),
                                  ),
                                  selected: rumourCategory.name == id,
                                  onSelected: loading
                                      ? null
                                      : (_) {
                                          setSheetState(() {
                                            rumourCategory =
                                                RumourCheckModelParsing
                                                        .categoryFromId(id) ??
                                                    RumourCategory.other;
                                          });
                                          draft.notifyChanged();
                                        },
                                ),
                            ],
                          ),
                          if (joinedGroupIds.isNotEmpty ||
                              suggestedContentLabelIds.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            CommunityGroupTagSelector(
                              joinedGroupIds: joinedGroupIds,
                              selectedIds: selectedGroupTags,
                              locale: locale,
                              suggestedContentLabelIds:
                                  suggestedContentLabelIds,
                              onChanged: loading
                                  ? (_) {}
                                  : (tags) {
                                      setSheetState(
                                        () => selectedGroupTags = tags,
                                      );
                                      draft.notifyChanged();
                                    },
                              enabled: !loading,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          CheckboxListTile(
                            value: disclaimerAccepted,
                            onChanged: loading
                                ? null
                                : (v) {
                                    setSheetState(
                                      () => disclaimerAccepted = v ?? false,
                                    );
                                    draft.notifyChanged();
                                  },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              CommunityStrings.t(
                                'community_rumour_disclaimer_ack',
                                locale,
                              ),
                              style: AppTypography.bodySmall,
                            ),
                          ),
                          if (moderationBlock != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            CommunityModerationBlockSection(
                              block: moderationBlock!,
                              locale: locale,
                              sourceText: bodyController.text.trim().isEmpty
                                  ? titleController.text
                                  : '${titleController.text.trim()}\n${bodyController.text.trim()}',
                              rephraseAttemptsUsed: rephraseAttempts,
                              onRephraseAttemptConsumed: () {
                                setSheetState(() => rephraseAttempts++);
                              },
                              onApplySuggestion: (text) {
                                final lines = text.split('\n');
                                if (lines.length > 1) {
                                  titleController.text = lines.first.trim();
                                  bodyController.text =
                                      lines.sublist(1).join('\n').trim();
                                } else if (bodyController.text.trim().isNotEmpty) {
                                  bodyController.text = text;
                                } else {
                                  titleController.text = text;
                                }
                                setSheetState(() {
                                  moderationBlock = null;
                                  rephraseAttempts = 0;
                                });
                                draft.notifyChanged();
                              },
                            ),
                          ] else if (moderationError != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            CommunityModerationBlockBanner(
                              message: moderationError,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          GlassCard(
                            onTap: loading || !disclaimerAccepted
                                ? null
                                : () async {
                                    final title = titleController.text.trim();
                                    final body = bodyController.text.trim();
                                    if (title.length <
                                        RumourCheckConfig.minClaimLength) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            CommunityStrings.t(
                                              'community_ask_err_min_length',
                                              locale,
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setSheetState(() {
                                      loading = true;
                                      moderationErrorKey = null;
                                      moderationBlock = null;
                                      rephraseAttempts = 0;
                                    });
                                    onSubmitStarted();

                                    try {
                                      final repo = ref.read(
                                        communityRepositoryProvider,
                                      );
                                      final moderation = ref.read(
                                        communityPostModerationServiceProvider,
                                      );
                                      final uid = await repo.currentUserId();
                                      final appLocale =
                                          ref.read(appLocaleProvider);
                                      final fullText = body.isEmpty
                                          ? title
                                          : '$title\n$body';

                                      var result =
                                          await moderation.moderateContent(
                                        text: fullText,
                                        language: appLocale,
                                        userId: uid,
                                        contentType: 'ask_qatar_question',
                                      );

                                      result = await resolveCommunityModeration(
                                        context: context,
                                        locale: locale,
                                        initialResult: result,
                                        runModeration: ({
                                          investmentWarningAcknowledged =
                                              false,
                                          fundraisingWarningAcknowledged =
                                              false,
                                        }) =>
                                            moderation.moderateContent(
                                          text: fullText,
                                          language: appLocale,
                                          userId: uid,
                                          contentType: 'ask_qatar_question',
                                          investmentWarningAcknowledged:
                                              investmentWarningAcknowledged,
                                          fundraisingWarningAcknowledged:
                                              fundraisingWarningAcknowledged,
                                        ),
                                        onCancelled: (warnResult) =>
                                            moderation
                                                .logModerationWarningCancelled(
                                          category: warnResult.category!,
                                          text: fullText,
                                          language: appLocale,
                                          userId: uid,
                                          contentType: 'ask_qatar_question',
                                          layer: warnResult.layer,
                                        ),
                                      );

                                      if (!result.allowed) {
                                        setSheetState(() {
                                          loading = false;
                                          if (result.requiresConfirmation) {
                                            moderationBlock = null;
                                            moderationErrorKey =
                                                'community_post_cancelled';
                                          } else {
                                            moderationErrorKey = null;
                                            moderationBlock =
                                                CommunityModerationBlockPresentation
                                                    .resolveCopy(
                                              result: result,
                                              locale: locale,
                                            );
                                          }
                                        });
                                        return;
                                      }

                                      final finalTags =
                                          await CommunityCrossPostPrompt
                                              .resolveTags(
                                        context: context,
                                        selectedTags: selectedGroupTags,
                                        joinedGroupIds: joinedGroupIds,
                                        locale: locale,
                                      );
                                      if (!context.mounted) return;

                                      await repo.submitRumourCheckQuestion(
                                        title: title,
                                        body: body,
                                        rumourCategoryId: rumourCategory.name,
                                        relevantGroupIds: finalTags,
                                      );
                                      await draft.clearDraft();
                                      if (context.mounted) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              CommunityStrings.t(
                                                'community_rumour_success',
                                                locale,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              CommunityStrings.t(
                                                'community_ask_err_post',
                                                locale,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      onSubmitFinished();
                                      setSheetState(() => loading = false);
                                    }
                                  },
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            glowColor: AppColors.brandFamilyMain,
                            glowIntensity: 0.18,
                            child: Center(
                              child: loading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.brandFamilyMain,
                                      ),
                                    )
                                  : Text(
                                      CommunityStrings.t(
                                        'community_rumour_submit',
                                        locale,
                                      ),
                                      style: AppTypography.button.copyWith(
                                        color: disclaimerAccepted
                                            ? AppColors.brandFamilyText
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );

}
