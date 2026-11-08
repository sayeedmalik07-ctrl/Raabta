import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_context_note_submit.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_question_presentation.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/widgets/rumour_context_note_source_badge.dart';
import 'package:raabta/features/community/widgets/rumour_question_status_chip.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/services/community_moderation_confirm_flow.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_banner.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_section.dart';
import 'package:raabta/features/community/widgets/ask_qatar_similar_questions_panel.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/link_safety_author_compose_hint.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_form_controller.dart';

class AskQatarQuestionScreen extends ConsumerStatefulWidget {
  const AskQatarQuestionScreen({
    super.key,
    required this.questionId,
  });

  final String questionId;

  @override
  ConsumerState<AskQatarQuestionScreen> createState() =>
      _AskQatarQuestionScreenState();
}

class _AskQatarQuestionScreenState extends ConsumerState<AskQatarQuestionScreen> {
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _rumourSourceUrlController =
      TextEditingController();
  late DraftFormController _answerDraft;
  bool _submitting = false;
  CommunityUiError? _moderationError;
  CommunityModerationBlockCopy? _moderationBlock;
  int _rephraseAttempts = 0;
  String? _currentUserId;
  bool _viewCounted = false;
  String? _optimisticAcceptedAnswerId;
  bool _acceptInFlight = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndCountView();
    _initAnswerDraft();
  }

  Future<void> _initAnswerDraft() async {
    _answerDraft = DraftFormController(
      formId: DraftBoxKeys.askQatarAnswerComposer(widget.questionId),
    );
    await _answerDraft.init();
    _answerDraft.bindControllers(
      [_answerController, _rumourSourceUrlController],
      () => {
        'text': _answerController.text,
        'officialSourceUrl': _rumourSourceUrlController.text,
      },
    );
  }

  Future<void> _loadUserAndCountView() async {
    final repo = ref.read(communityRepositoryProvider);
    final uid = await repo.currentUserId();
    if (mounted) setState(() => _currentUserId = uid);
    if (!_viewCounted) {
      _viewCounted = true;
      await repo.incrementQuestionViews(widget.questionId);
    }
  }

  @override
  void dispose() {
    _answerDraft.dispose();
    _answerController.dispose();
    _rumourSourceUrlController.dispose();
    super.dispose();
  }

  bool _isAcceptedForDisplay(AskQatarAnswer answer) {
    if (_optimisticAcceptedAnswerId != null) {
      return answer.id == _optimisticAcceptedAnswerId;
    }
    return answer.isAccepted;
  }

  Future<void> _refresh() async {
    ref.invalidate(askQatarQuestionProvider(widget.questionId));
    ref.invalidate(askQatarAnswersProvider(widget.questionId));
    await ref.read(askQatarQuestionProvider(widget.questionId).future);
  }

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty || _submitting) return;

    final question =
        ref.read(askQatarQuestionProvider(widget.questionId)).valueOrNull;
    final isRumour = question != null &&
        RumourQuestionPresentation.isRumourCheck(question);
    final sourceUrlRaw = _rumourSourceUrlController.text;

    if (isRumour) {
      final sourceDecision =
          RumourContextNoteSubmit.evaluateSourceUrl(sourceUrlRaw);
      if (!sourceDecision.canSubmit) {
        setState(() {
          _moderationError = (
            catalogKey: sourceDecision.blockReasonKey,
            rawMessage: null,
          );
        });
        return;
      }
    }

    setState(() {
      _submitting = true;
      _moderationError = null;
      _moderationBlock = null;
      _rephraseAttempts = 0;
    });

    final repo = ref.read(communityRepositoryProvider);
    final moderation = ref.read(communityPostModerationServiceProvider);
    final uid = _currentUserId ?? await repo.currentUserId();
    // Snapshot for moderation — language model matches locale when answer submitted.
    final locale = ref.read(appLocaleProvider);

    final moderationText = isRumour && sourceUrlRaw.trim().isNotEmpty
        ? '$text\n${sourceUrlRaw.trim()}'
        : text;

    var result = await moderation.moderateContent(
      text: moderationText,
      language: locale,
      userId: uid,
      contentType: 'ask_qatar_answer',
      useCommentLength: true,
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
        text: moderationText,
        language: locale,
        userId: uid,
        contentType: 'ask_qatar_answer',
        useCommentLength: true,
        investmentWarningAcknowledged: investmentWarningAcknowledged,
        fundraisingWarningAcknowledged: fundraisingWarningAcknowledged,
      ),
      onCancelled: (warnResult) => moderation.logModerationWarningCancelled(
        category: warnResult.category!,
        text: text,
        language: locale,
        userId: uid,
        contentType: 'ask_qatar_answer',
        layer: warnResult.layer,
      ),
    );

    if (!result.allowed) {
      if (mounted) {
        setState(() {
          _submitting = false;
          if (result.requiresConfirmation) {
            _moderationBlock = null;
            _moderationError = (
              catalogKey: 'community_post_cancelled',
              rawMessage: null,
            );
          } else {
            _moderationError = null;
            _moderationBlock =
                CommunityModerationBlockPresentation.resolveCopy(
              result: result,
              locale: locale,
            );
          }
        });
      }
      return;
    }

    try {
      if (isRumour) {
        await repo.submitRumourContextNote(
          questionId: widget.questionId,
          noteText: text,
          officialSourceUrl: sourceUrlRaw,
        );
      } else {
        await repo.submitAnswer(
          questionId: widget.questionId,
          answerText: text,
        );
      }
      await _answerDraft.clear();
      _answerController.clear();
      _rumourSourceUrlController.clear();
      if (mounted) {
        setState(() {
          _submitting = false;
          _moderationError = null;
          _moderationBlock = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _moderationBlock = null;
          _moderationError = (
            catalogKey: 'community_answer_err_post',
            rawMessage: null,
          );
        });
      }
    }
  }

  Future<void> _toggleUpvote(AskQatarQuestion question) async {
    final uid = _currentUserId;
    if (uid == null) return;
    await ref.read(communityRepositoryProvider).toggleQuestionUpvote(
          questionId: question.id,
          uid: uid,
          upvote: !question.isUpvotedBy(uid),
        );
  }

  Future<void> _toggleHelpful(AskQatarAnswer answer) async {
    final uid = _currentUserId;
    if (uid == null) return;
    await ref.read(communityRepositoryProvider).toggleAnswerHelpful(
          questionId: widget.questionId,
          answerId: answer.id,
          uid: uid,
          helpful: !answer.isMarkedHelpfulBy(uid),
        );
  }

  Future<void> _acceptAnswer(AskQatarAnswer answer, String authorId) async {
    final uid = _currentUserId;
    if (uid == null || uid != authorId || _acceptInFlight) return;
    if (answer.createdBy == authorId) return;

    final previous = _optimisticAcceptedAnswerId;
    setState(() {
      _acceptInFlight = true;
      _optimisticAcceptedAnswerId = answer.id;
    });

    try {
      await ref.read(communityRepositoryProvider).markAcceptedAnswer(
            questionId: widget.questionId,
            answerId: answer.id,
            questionAuthorId: authorId,
          );
      if (mounted) {
        setState(() => _optimisticAcceptedAnswerId = null);
      }
    } catch (_) {
      if (mounted) {
        final locale = ref.read(userLanguageProvider);
        setState(() => _optimisticAcceptedAnswerId = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CommunityStrings.t('community_answer_accept_err', locale),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _acceptInFlight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final questionAsync = ref.watch(askQatarQuestionProvider(widget.questionId));
    final answersAsync = ref.watch(askQatarAnswersProvider(widget.questionId));
    final uid = _currentUserId ?? '';
    final isRumourQuestion = questionAsync.maybeWhen(
      data: (q) =>
          q != null && RumourQuestionPresentation.isRumourCheck(q),
      orElse: () => false,
    );

    final questionTitle = questionAsync.valueOrNull?.title ??
        CommunityStrings.t('community_ask_qatar_title', locale);

    return HubSubscreenScaffold(
      title: questionTitle,
      subtitle: CommunityStrings.t('community_ask_qatar_subtitle', locale),
      onBack: () => Navigator.of(context).pop(),
      headerTrailing: CommunityLiveDot(locale: locale),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.brandFamilyMain,
              onRefresh: _refresh,
              child: questionAsync.when(
                loading: () => const Center(
                  child: HubLoadingPlaceholder(
                    height: 200,
                    width: 360,
                    silhouette: HubLoadingSilhouette.postCard,
                  ),
                ),
                error: (_, _) => ListView(
                  children: [
                    GlassEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: CommunityStrings.t(
                        'community_question_err_load',
                        locale,
                      ),
                      description: CommunityStrings.t(
                        'community_question_err_load_hint',
                        locale,
                      ),
                    ),
                  ],
                ),
                data: (question) {
                  if (question == null) {
                    return ListView(
                      children: [
                        GlassEmptyState(
                          icon: Icons.help_outline,
                          title: CommunityStrings.t(
                            'community_question_not_found',
                            locale,
                          ),
                          description: CommunityStrings.t(
                            'community_question_removed',
                            locale,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    children: [
                      _QuestionHeader(
                        question: question,
                        uid: uid,
                        locale: locale,
                        onUpvote: () => _toggleUpvote(question),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        CommunityStrings.format(
                          'community_answers_count',
                          locale,
                          params: {
                            'count':
                                '${answersAsync.value?.length ?? question.answers}',
                          },
                        ),
                        style: AppTypography.headline2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      answersAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, _) => GlassEmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: CommunityStrings.t(
                            'community_answers_err_load',
                            locale,
                          ),
                          description: CommunityStrings.t(
                            'community_answers_err_load_hint',
                            locale,
                          ),
                        ),
                        data: (answers) {
                          if (answers.isEmpty) {
                            return GlassEmptyState(
                              icon: Icons.chat_bubble_outline,
                              title: CommunityStrings.t(
                                'community_answers_empty',
                                locale,
                              ),
                              description: CommunityStrings.t(
                                'community_answers_empty_hint',
                                locale,
                              ),
                            );
                          }
                          final displayAnswers =
                              List<AskQatarAnswer>.from(answers);
                          displayAnswers.sort((a, b) {
                            final aAccepted = _isAcceptedForDisplay(a);
                            final bAccepted = _isAcceptedForDisplay(b);
                            if (aAccepted && !bAccepted) return -1;
                            if (bAccepted && !aAccepted) return 1;
                            final helpful =
                                b.helpfulCount.compareTo(a.helpfulCount);
                            if (helpful != 0) return helpful;
                            final da = a.createdAt ?? DateTime(0);
                            final db = b.createdAt ?? DateTime(0);
                            return da.compareTo(db);
                          });

                          final hideAccept =
                              RumourQuestionPresentation.isRumourCheck(
                            question,
                          );

                          return Column(
                            children: displayAnswers
                                .map(
                                  (a) => _AnswerCard(
                                    answer: a,
                                    uid: uid,
                                    locale: locale,
                                    isQuestionAuthor:
                                        question.createdBy == uid,
                                    isAccepted: hideAccept
                                        ? false
                                        : _isAcceptedForDisplay(a),
                                    hideAcceptAsSolution: hideAccept,
                                    showRumourContextSource: hideAccept,
                                    onHelpful: () => _toggleHelpful(a),
                                    onAccept: () => _acceptAnswer(
                                      a,
                                      question.createdBy,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          _AnswerComposer(
            controller: _answerController,
            rumourSourceUrlController: _rumourSourceUrlController,
            isRumourContextNote: isRumourQuestion,
            questionId: widget.questionId,
            isSubmitting: _submitting,
            moderationBlock: _moderationBlock,
            moderationError: _moderationError,
            locale: locale,
            rephraseAttemptsUsed: _rephraseAttempts,
            onRephraseAttemptConsumed: () {
              setState(() => _rephraseAttempts++);
            },
            onApplyRephraseSuggestion: (text) {
              _answerController.text = text;
              setState(() {
                _moderationBlock = null;
                _rephraseAttempts = 0;
              });
            },
            onSubmit: _submitAnswer,
          ),
        ],
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({
    required this.question,
    required this.uid,
    required this.locale,
    required this.onUpvote,
  });

  final AskQatarQuestion question;
  final String uid;
  final String locale;
  final VoidCallback onUpvote;

  @override
  Widget build(BuildContext context) {
    final upvoted = question.isUpvotedBy(uid);
    final isRumour = RumourQuestionPresentation.isRumourCheck(question);
    final rumourStatus = isRumour
        ? RumourQuestionPresentation.displayStatus(question)
        : null;
    final engineLink =
        isRumour ? RumourQuestionPresentation.truthEngineLink(question) : null;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor:
          isRumour ? AppColors.brandFamilyMain : communityHubAccent,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isRumour) ...[
                StatusBadge(
                  label: CommunityStrings.t(
                    'community_rumour_type_chip',
                    locale,
                  ),
                  color: AppColors.brandFamilyMain,
                  icon: Icons.fact_check_outlined,
                ),
                if (question.rumourCategoryId != null &&
                    question.rumourCategoryId!.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(
                    label: CommunityStrings.rumourCategoryLabel(
                      question.rumourCategoryId!,
                      locale,
                    ),
                    color: AppColors.brandFamilyMain,
                  ),
                ],
                if (rumourStatus != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  RumourQuestionStatusChip(
                    status: rumourStatus,
                    locale: locale,
                  ),
                ],
              ] else ...[
                StatusBadge(
                  label: CommunityStrings.t(
                    'community_cat_${question.category.toLowerCase()}',
                    locale,
                  ),
                  color: AppColors.brandFamilyMain,
                ),
                if (question.isUnanswered) ...[
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(
                    label: CommunityStrings.t(
                      'community_ask_unanswered',
                      locale,
                    ),
                    color: AppColors.warning,
                    icon: Icons.help_outline,
                  ),
                ],
              ],
              const Spacer(),
              Text(
                communityRelativeTime(question.createdAt, locale),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          if (isRumour) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              CommunityStrings.t('community_rumour_disclaimer', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (engineLink != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.push(engineLink.routePath),
                child: Text(
                  CommunityStrings.t(
                    'community_rumour_truth_engine_link',
                    locale,
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.md),
          Text(question.title, style: AppTypography.headline2),
          if (question.body.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            UserGeneratedTextWithLinkSafety(
              text: question.body,
              locale: locale,
              surface: LinkSafetySurface.askQatar,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                question.authorDisplayName,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              GlassCard(
                onTap: onUpvote,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                borderRadius: AppSpacing.radiusFull,
                glowColor: upvoted ? communityHubAccent : null,
                glowIntensity: upvoted ? 0.15 : 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommunityHubIcons.actionGlyph(
                      upvoted
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_upward_outlined,
                      size: 18,
                      active: upvoted,
                      color: upvoted
                          ? communityHubAccent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '${question.votes}',
                      style: AppTypography.caption.copyWith(
                        color: upvoted ? communityHubAccent : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.answer,
    required this.uid,
    required this.locale,
    required this.isQuestionAuthor,
    required this.isAccepted,
    required this.hideAcceptAsSolution,
    required this.showRumourContextSource,
    required this.onHelpful,
    required this.onAccept,
  });

  final AskQatarAnswer answer;
  final String uid;
  final String locale;
  final bool isQuestionAuthor;
  final bool isAccepted;
  final bool hideAcceptAsSolution;
  final bool showRumourContextSource;
  final VoidCallback onHelpful;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final helpful = answer.isMarkedHelpfulBy(uid);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: isAccepted ? AppColors.success : null,
      glowIntensity: isAccepted ? 0.12 : 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAccepted)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AskQatarAcceptedAnswerChip(locale: locale),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: communityHubAccent.withValues(alpha: 0.16),
                child: Text(
                  answer.authorDisplayName.isNotEmpty
                      ? answer.authorDisplayName[0].toUpperCase()
                      : 'M',
                  style: AppTypography.caption.copyWith(
                    color: communityHubAccentText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.authorDisplayName,
                      style: AppTypography.subtitle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      communityRelativeTime(answer.createdAt, locale),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          UserGeneratedTextWithLinkSafety(
            text: answer.text,
            locale: locale,
            surface: LinkSafetySurface.askQatar,
          ),
          if (showRumourContextSource) ...[
            const SizedBox(height: AppSpacing.sm),
            RumourContextNoteSourceBadge(
              officialSourceUrl: answer.officialSourceUrl,
              locale: locale,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              GlassCard(
                onTap: onHelpful,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                borderRadius: AppSpacing.radiusFull,
                glowColor: helpful ? communityHubAccent : null,
                glowIntensity: helpful ? 0.12 : 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommunityHubIcons.actionGlyph(
                      helpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 18,
                      active: helpful,
                      color: helpful
                          ? communityHubAccent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      CommunityStrings.format(
                        'community_answer_helpful',
                        locale,
                        params: {'count': '${answer.helpfulCount}'},
                      ),
                      style: AppTypography.caption.copyWith(
                        color: helpful ? communityHubAccent : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hideAcceptAsSolution &&
                  isQuestionAuthor &&
                  !isAccepted &&
                  answer.createdBy != uid) ...[
                const Spacer(),
                TextButton(
                  onPressed: onAccept,
                  child: Text(
                    CommunityStrings.t('community_answer_mark_accepted', locale),
                    style: AppTypography.link.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerComposer extends ConsumerWidget {
  const _AnswerComposer({
    required this.controller,
    required this.rumourSourceUrlController,
    required this.isRumourContextNote,
    required this.questionId,
    required this.isSubmitting,
    this.moderationBlock,
    required this.moderationError,
    required this.locale,
    required this.rephraseAttemptsUsed,
    required this.onRephraseAttemptConsumed,
    required this.onApplyRephraseSuggestion,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final TextEditingController rumourSourceUrlController;
  final bool isRumourContextNote;
  final String questionId;
  final bool isSubmitting;
  final CommunityModerationBlockCopy? moderationBlock;
  final CommunityUiError? moderationError;
  final String locale;
  final int rephraseAttemptsUsed;
  final VoidCallback onRephraseAttemptConsumed;
  final ValueChanged<String> onApplyRephraseSuggestion;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moderationText = resolveCommunityUiError(moderationError, locale);
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
        child: ListenableBuilder(
          listenable: Listenable.merge([controller, rumourSourceUrlController]),
          builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRumourContextNote) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  CommunityStrings.t(
                    'community_rumour_context_note_composer_notice',
                    locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            if (moderationBlock != null)
              CommunityModerationBlockSection(
                block: moderationBlock!,
                locale: locale,
                sourceText: controller.text,
                rephraseAttemptsUsed: rephraseAttemptsUsed,
                onRephraseAttemptConsumed: onRephraseAttemptConsumed,
                onApplySuggestion: onApplyRephraseSuggestion,
              )
            else if (moderationText != null)
              CommunityModerationBlockBanner(message: moderationText),
            LinkSafetyAuthorComposeHint(
              text: controller.text,
              locale: locale,
              surface: LinkSafetySurface.askQatar,
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
                      enabled: !isSubmitting,
                      style: AppTypography.subtitle,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: CommunityStrings.t(
                          isRumourContextNote
                              ? 'community_rumour_context_note_hint'
                              : 'community_answer_hint',
                          locale,
                        ),
                        hintStyle: AppTypography.body,
                        border: InputBorder.none,
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
                  onTap: isSubmitting ? null : onSubmit,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  borderRadius: AppSpacing.radiusFull,
                  glowColor: AppColors.brandFamilyMain,
                  glowIntensity: 0.2,
                  child: isSubmitting
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
            if (isRumourContextNote) ...[
              const SizedBox(height: AppSpacing.sm),
              GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: AppSpacing.radiusFull,
                child: TextField(
                  controller: rumourSourceUrlController,
                  enabled: !isSubmitting,
                  style: AppTypography.bodySmall,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: CommunityStrings.t(
                      'community_rumour_source_url_label',
                      locale,
                    ),
                    hintText: CommunityStrings.t(
                      'community_rumour_source_url_hint',
                      locale,
                    ),
                    hintStyle: AppTypography.bodySmall,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}
