import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_picker_sheet.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/screens/community/widgets/community_section_primitives.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/services/community_moderation_confirm_flow.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_banner.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_section.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/community/widgets/community_cross_post_prompt.dart';
import 'package:raabta/features/community/widgets/community_why_seeing_affordance.dart';
import 'package:raabta/features/community/utils/community_visibility_reasons.dart';
import 'package:raabta/features/community/widgets/community_group_tag_selector.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/community/widgets/ask_qatar_similar_questions_panel.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_question_presentation.dart';
import 'package:raabta/features/community/widgets/rumour_check_composer_sheet.dart';
import 'package:raabta/features/community/widgets/rumour_question_status_chip.dart';
import 'package:raabta/screens/community/ask_qatar_question_screen.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';

class AskQatarScreen extends ConsumerStatefulWidget {
  const AskQatarScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<AskQatarScreen> createState() => _AskQatarScreenState();
}

class _AskQatarScreenState extends ConsumerState<AskQatarScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _sortIndex = 0;
  String? _categoryFilter;
  bool _solvedOnly = false;
  bool _submitting = false;

  static const List<String> _sortKeys = [
    'community_sort_recent',
    'community_sort_popular',
    'community_sort_unanswered',
  ];

  static const List<String> _categories = [
    'General',
    'Visa',
    'Jobs',
    'Transport',
    'Education',
    'Housing',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AskQatarQuestion> _filterAndSort(List<AskQatarQuestion> questions) {
    var list = List<AskQatarQuestion>.from(questions);
    final query = _searchController.text.trim().toLowerCase();

    if (_categoryFilter != null) {
      list = list.where((q) => q.category == _categoryFilter).toList();
    }
    if (_solvedOnly) {
      list = list.where((q) => q.isSolved).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where(
            (q) =>
                q.title.toLowerCase().contains(query) ||
                q.body.toLowerCase().contains(query),
          )
          .toList();
    }

    if (_sortIndex == 1) {
      list.sort((a, b) => b.votes.compareTo(a.votes));
    } else if (_sortIndex == 2) {
      list.sort((a, b) => a.answers.compareTo(b.answers));
    }
    return list;
  }

  void _openQuestion(AskQatarQuestion question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AskQatarQuestionScreen(questionId: question.id),
      ),
    );
  }

  String _categoryLabel(String category, String locale) =>
      _AskQatarLabels.categoryLabel(category, locale);

  Future<void> _showRumourCheckSheet() async {
    final joinedGroupIds =
        ref.read(communityMembershipProvider).value ?? const {};
    final suggestedLabels =
        ref.read(suggestedCommunityContentLabelIdsProvider);
    await showRumourCheckComposerSheet(
      context: context,
      ref: ref,
      joinedGroupIds: joinedGroupIds,
      suggestedContentLabelIds: suggestedLabels,
      onSubmitStarted: () => setState(() => _submitting = true),
      onSubmitFinished: () {
        if (mounted) setState(() => _submitting = false);
      },
    );
  }

  Future<void> _showAskQuestionSheet() async {
    final joinedGroupIds =
        ref.read(communityMembershipProvider).value ?? const {};
    final suggestedLabels =
        ref.read(suggestedCommunityContentLabelIdsProvider);
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    var category = _categories.first;
    var loading = false;
    String? moderationErrorKey;
    CommunityModerationBlockCopy? moderationBlock;
    var rephraseAttempts = 0;
    var selectedGroupTags = <String>{};
    final uid = await ref.read(communityRepositoryProvider).currentUserId();

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
              formId: DraftBoxKeys.askQatarComposer,
              controllers: [titleController, bodyController],
              serialize: () => {
                'title': titleController.text,
                'body': bodyController.text,
                'category': category,
              },
              applyDraft: (data) {
                setSheetState(() {
                  titleController.text = data['title']?.toString() ?? '';
                  bodyController.text = data['body']?.toString() ?? '';
                  category =
                      data['category']?.toString() ?? _categories.first;
                });
              },
              builder: (context, draft) {
                return HubPickerSheet(
                  title: CommunityStrings.t('community_ask_sheet_title', locale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GlassField(
                          controller: titleController,
                          hint: CommunityStrings.t(
                            'community_ask_title_hint',
                            locale,
                          ),
                          maxLength: 200,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          borderRadius: AppSpacing.radiusSm,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: category,
                              isExpanded: true,
                              items: [
                                for (final c in _categories)
                                  DropdownMenuItem(
                                    value: c,
                                    child: Text(_categoryLabel(c, locale)),
                                  ),
                              ],
                              onChanged: loading
                                  ? null
                                  : (v) {
                                      setSheetState(
                                        () => category = v ?? category,
                                      );
                                      draft.notifyChanged();
                                    },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _GlassField(
                          controller: bodyController,
                          hint: CommunityStrings.t(
                            'community_ask_body_hint',
                            locale,
                          ),
                          maxLines: 4,
                        ),
                        if (joinedGroupIds.isNotEmpty ||
                            suggestedLabels.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          CommunityGroupTagSelector(
                            joinedGroupIds: joinedGroupIds,
                            selectedIds: selectedGroupTags,
                            locale: locale,
                            suggestedContentLabelIds: suggestedLabels,
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
                        AskQatarSimilarQuestionsPanel(
                          titleController: titleController,
                          category: category,
                          locale: locale,
                          userId: uid,
                          enabled: !loading,
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
                        const SizedBox(height: AppSpacing.lg),
                        GlassCard(
                          onTap: loading
                              ? null
                              : () async {
                                  final title = titleController.text.trim();
                                  final body = bodyController.text.trim();
                                  if (title.length < 8) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                                  setState(() => _submitting = true);

                                  try {
                                    final repo = ref.read(
                                      communityRepositoryProvider,
                                    );
                                    final moderation = ref.read(
                                      communityPostModerationServiceProvider,
                                    );
                                    final uid = await repo.currentUserId();
                                    // Snapshot for moderation — language model matches locale when submitted.
                                    final locale = ref.read(appLocaleProvider);
                                    final fullText =
                                        body.isEmpty ? title : '$title\n$body';

                                    var result =
                                        await moderation.moderateContent(
                                      text: fullText,
                                      language: locale,
                                      userId: uid,
                                      contentType: 'ask_qatar_question',
                                    );

                                    result = await resolveCommunityModeration(
                                      context: context,
                                      locale: locale,
                                      initialResult: result,
                                      runModeration: ({
                                        investmentWarningAcknowledged = false,
                                        fundraisingWarningAcknowledged = false,
                                      }) =>
                                          moderation.moderateContent(
                                        text: fullText,
                                        language: locale,
                                        userId: uid,
                                        contentType: 'ask_qatar_question',
                                        investmentWarningAcknowledged:
                                            investmentWarningAcknowledged,
                                        fundraisingWarningAcknowledged:
                                            fundraisingWarningAcknowledged,
                                      ),
                                      onCancelled: (warnResult) =>
                                          moderation.logModerationWarningCancelled(
                                        category: warnResult.category!,
                                        text: fullText,
                                        language: locale,
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

                                    final joinedGroupIds = ref.read(
                                      communityMembershipProvider,
                                    ).value ?? const {};
                                    final finalTags =
                                        await CommunityCrossPostPrompt.resolveTags(
                                      context: context,
                                      selectedTags: selectedGroupTags,
                                      joinedGroupIds: joinedGroupIds,
                                      locale: locale,
                                    );
                                    if (!context.mounted) return;

                                    await repo.submitQuestion(
                                      title: title,
                                      category: category,
                                      body: body,
                                      relevantGroupIds: finalTags,
                                    );
                                    await draft.clearDraft();
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            CommunityStrings.t(
                                              'community_ask_success',
                                              locale,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
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
                                    if (mounted) {
                                      setState(() => _submitting = false);
                                    }
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
                                      'community_ask_submit',
                                      locale,
                                    ),
                                    style: AppTypography.button.copyWith(
                                      color: AppColors.brandFamilyText,
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

    titleController.dispose();
    bodyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(askQatarQuestionsProvider);
    final body = _buildBody(questionsAsync);

    if (widget.embedded) return body;

    final locale = ref.watch(userLanguageProvider);
    return CommunitySectionPrimitives.standaloneScaffold(
      context: context,
      title: CommunityStrings.t('community_ask_qatar_title', locale),
      subtitle: CommunityStrings.t('community_ask_qatar_subtitle', locale),
      body: body,
    );
  }

  Widget _buildBody(AsyncValue<List<AskQatarQuestion>> questionsAsync) {
    final locale = ref.watch(userLanguageProvider);
    return RefreshIndicator(
      color: CommunitySectionPrimitives.refreshColor,
      onRefresh: () async {
        ref.invalidate(askQatarQuestionsProvider);
        await ref.read(askQatarQuestionsProvider.future);
      },
      child: ListView(
        padding: CommunitySectionPrimitives.embeddedListPadding(
          embedded: widget.embedded,
        ),
        children: [
          if (widget.embedded) ...[
            CommunitySectionPrimitives.embeddedSectionHeader(
              title: CommunityStrings.t('community_ask_qatar_title', locale),
              subtitle: CommunityStrings.t(
                'community_ask_qatar_subtitle',
                locale,
              ),
              leadingIcon: Icons.live_help_outlined,
              trailing: CommunityLiveDot(locale: locale),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: hubSearchInputDecoration(
              hintText: CommunityStrings.t(
                'community_ask_search_hint',
                locale,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GlassCard(
              onTap: _submitting ? null : _showAskQuestionSheet,
              glowColor: AppColors.brandFamilyMain,
              glowIntensity: 0.15,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_submitting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      CommunityHubIcons.ctaLeading(Icons.add),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      CommunityStrings.t('community_ask_cta', locale),
                      style: AppTypography.button.copyWith(
                        color: AppColors.brandFamilyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GlassCard(
              onTap: _submitting ? null : _showRumourCheckSheet,
              glowColor: AppColors.brandFamilyMain,
              glowIntensity: 0.12,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommunityHubIcons.ctaLeading(Icons.fact_check_outlined),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      CommunityStrings.t('community_rumour_cta', locale),
                      style: AppTypography.button.copyWith(
                        color: AppColors.brandFamilyText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sortKeys.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return buildHubFilterChip(
                  label: Text(CommunityStrings.t(_sortKeys[index], locale)),
                  selected: _sortIndex == index,
                  onSelected: (_) => setState(() => _sortIndex = index),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return buildHubFilterChip(
                  label: Text(
                    CommunityStrings.t('community_ask_solved_chip', locale),
                  ),
                  selected: _solvedOnly,
                  onSelected: (_) =>
                      setState(() => _solvedOnly = !_solvedOnly),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildHubFilterChip(
                    label: Text(
                      CommunityStrings.t('community_filter_all', locale),
                    ),
                    selected: _categoryFilter == null,
                    onSelected: (_) =>
                        setState(() => _categoryFilter = null),
                  );
                }
                final cat = _categories[index - 1];
                return buildHubFilterChip(
                  label: Text(_categoryLabel(cat, locale)),
                  selected: _categoryFilter == cat,
                  onSelected: (_) => setState(() => _categoryFilter = cat),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          questionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: HubLoadingPlaceholder(
                height: 160,
                width: 360,
                silhouette: HubLoadingSilhouette.postCard,
              ),
            ),
            error: (e, _) => GlassEmptyState(
              accent: GlassEmptyStateAccent.teal,
              icon: Icons.error_outline,
              title: CommunityStrings.t(
                'community_ask_err_load',
                locale,
              ),
              description: CommunityStrings.t(
                'community_ask_err_load_hint',
                locale,
              ),
            ),
            data: (questions) {
              final filtered = _filterAndSort(questions);
              if (filtered.isEmpty) {
                return GlassEmptyState(
                  accent: GlassEmptyStateAccent.teal,
                  icon: Icons.help_outline,
                  title: CommunityStrings.t(
                    'community_ask_empty',
                    locale,
                  ),
                  description: _searchQuery.isNotEmpty ||
                          _categoryFilter != null ||
                          _solvedOnly
                      ? CommunityStrings.t(
                          'community_ask_empty_filter',
                          locale,
                        )
                      : CommunityStrings.t(
                          'community_ask_empty_first',
                          locale,
                        ),
                );
              }
              return Column(
                children: [
                  for (final q in filtered)
                    _QuestionCard(
                      question: q,
                      onTap: () => _openQuestion(q),
                      locale: locale,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String get _searchQuery => _searchController.text.trim().toLowerCase();
}

abstract final class _AskQatarLabels {
  static String categoryLabel(String category, String locale) =>
      CommunityStrings.t('community_cat_${category.toLowerCase()}', locale);
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusSm,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: AppTypography.subtitle,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          counterText: '',
        ),
      ),
    );
  }
}

class _QuestionCard extends ConsumerStatefulWidget {
  const _QuestionCard({
    required this.question,
    required this.onTap,
    required this.locale,
  });

  final AskQatarQuestion question;
  final VoidCallback onTap;
  final String locale;

  @override
  ConsumerState<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends ConsumerState<_QuestionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _authorInitial(AskQatarQuestion q) {
    final name = q.authorDisplayName.trim();
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  String _metaLine(AskQatarQuestion q, String locale) {
    final answerLabel = q.answers == 1
        ? CommunityStrings.t('community_ask_answer', locale)
        : CommunityStrings.t('community_ask_answers', locale);
    final votesLabel = CommunityStrings.t('community_ask_votes', locale);
    final viewsLabel = CommunityStrings.t('community_ask_views', locale);
    return '${q.answers} $answerLabel · ${q.votes} $votesLabel · ${q.views} $viewsLabel';
  }

  Widget _statusFooter(
    AskQatarQuestion q,
    String locale, {
    required bool isRumour,
    required RumourDisplayStatus? rumourStatus,
  }) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        if (isRumour) ...[
          StatusBadge(
            label: CommunityStrings.t('community_rumour_type_chip', locale),
            color: AppColors.brandFamilyMain,
            icon: Icons.fact_check_outlined,
          ),
          if (q.rumourCategoryId != null && q.rumourCategoryId!.isNotEmpty)
            StatusBadge(
              label: CommunityStrings.rumourCategoryLabel(
                q.rumourCategoryId!,
                locale,
              ),
              color: AppColors.brandFamilyMain,
            ),
          if (rumourStatus != null)
            RumourQuestionStatusChip(status: rumourStatus, locale: locale),
        ] else ...[
          StatusBadge(
            label: _AskQatarLabels.categoryLabel(q.category, locale),
            color: AppColors.brandFamilyMain,
          ),
          if (q.isSolved)
            AskQatarSolvedChip(locale: locale)
          else if (q.isUnanswered)
            StatusBadge(
              label: CommunityStrings.t('community_ask_unanswered', locale),
              color: AppColors.warning,
              icon: Icons.help_outline,
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final locale = widget.locale;
    final isRumour = RumourQuestionPresentation.isRumourCheck(q);
    final rumourStatus = isRumour
        ? RumourQuestionPresentation.displayStatus(q)
        : null;
    final visibility = CommunityVisibilityInput(
      relevantGroupIds: q.relevantGroupIds,
      voteCount: q.votes,
      commentCount: q.answers,
    );
    final askSection = CommunityStrings.t('community_tab_ask_qatar', locale);
    final topicLabel = isRumour
        ? CommunityStrings.t('community_rumour_type_chip', locale)
        : _AskQatarLabels.categoryLabel(q.category, locale);
    final sectionContext =
        '$askSection · $topicLabel · ${communityRelativeTime(q.createdAt, locale)}';
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);
    final whyLabel = CommunityStrings.t('community_why_seeing_link', locale);

    return FadeTransition(
      opacity: _fade,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: HubPostCard(
          authorName: q.authorDisplayName,
          authorInitial: _authorInitial(q),
          sectionContextLine: sectionContext,
          trustTierBadge: (
            label: trustLabel,
            tier: HubContentTrustTier.community,
          ),
          bodyChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.title, style: AppTypography.title),
              if (q.body.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  q.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body,
                ),
              ],
            ],
          ),
          metaLine: _metaLine(q, locale),
          whySeeingLabel: whyLabel,
          onWhySeeingTap: () => CommunityWhySeeingAffordance.showForInput(
            context,
            ref,
            visibility,
          ),
          footer: _statusFooter(
            q,
            locale,
            isRumour: isRumour,
            rumourStatus: rumourStatus,
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
