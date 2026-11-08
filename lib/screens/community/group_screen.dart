import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/services/community_moderation_confirm_flow.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/community/widgets/group_feed_composer.dart';
import 'package:raabta/features/community/widgets/group_post_card.dart';
import 'package:raabta/features/community/widgets/community_cross_post_prompt.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_form_controller.dart';
import 'package:raabta/services/drafts/draft_service.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({
    super.key,
    required this.groupId,
    required this.emoji,
    required this.name,
    required this.memberCount,
    required this.isJoined,
    required this.onJoinToggle,
  });

  final int groupId;
  final String emoji;
  final String name;
  final int memberCount;
  final bool isJoined;
  final VoidCallback onJoinToggle;

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  final TextEditingController _postController = TextEditingController();
  late DraftFormController _postDraft;
  DraftRecord? _postDraftRecord;
  bool _showPostDraftBanner = false;
  bool _submitting = false;
  CommunityUiError? _moderationError;
  CommunityModerationBlockCopy? _moderationBlock;
  int _rephraseAttempts = 0;
  String? _currentUserId;
  Set<String> _selectedGroupTags = {};

  String get _groupIdStr => '${widget.groupId}';

  @override
  void initState() {
    super.initState();
    _selectedGroupTags = {_groupIdStr};
    _postDraft = DraftFormController(
      formId: DraftBoxKeys.groupPostComposer(widget.name),
    );
    _initPostDraft();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final uid =
        await ref.read(communityRepositoryProvider).currentUserId();
    if (mounted) setState(() => _currentUserId = uid);
  }

  Future<void> _initPostDraft() async {
    await _postDraft.init();
    _postDraft.bindControllers(
      [_postController],
      () => {'text': _postController.text},
    );
    final draft = await _postDraft.loadRestorableDraft();
    if (draft != null && mounted) {
      setState(() {
        _postDraftRecord = draft;
        _showPostDraftBanner = true;
      });
    }
  }

  @override
  void dispose() {
    _postDraft.dispose();
    _postController.dispose();
    super.dispose();
  }

  String _formatMembers(int count) {
    return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  Future<void> _refreshFeed() async {
    ref.invalidate(groupPostsProvider(_groupIdStr));
    await ref.read(groupPostsProvider(_groupIdStr).future);
  }

  Future<void> _submitPost() async {
    if (!widget.isJoined || _submitting) return;
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _submitting = true;
      _moderationError = null;
      _moderationBlock = null;
      _rephraseAttempts = 0;
    });

    final repo = ref.read(communityRepositoryProvider);
    final moderation = ref.read(communityPostModerationServiceProvider);
    final uid = _currentUserId ?? await repo.currentUserId();
    // Snapshot for moderation — language model matches locale when user posted.
    final locale = ref.read(appLocaleProvider);

    var result = await moderation.moderatePost(
      text: text,
      language: locale,
      userId: uid,
      groupId: _groupIdStr,
    );

    result = await resolveCommunityModeration(
      context: context,
      locale: locale,
      initialResult: result,
      runModeration: ({
        investmentWarningAcknowledged = false,
        fundraisingWarningAcknowledged = false,
      }) =>
          moderation.moderatePost(
        text: text,
        language: locale,
        userId: uid,
        groupId: _groupIdStr,
        investmentWarningAcknowledged: investmentWarningAcknowledged,
        fundraisingWarningAcknowledged: fundraisingWarningAcknowledged,
      ),
      onCancelled: (warnResult) => moderation.logModerationWarningCancelled(
        category: warnResult.category!,
        text: text,
        language: locale,
        userId: uid,
        contentType: 'group_post',
        groupId: _groupIdStr,
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
      final joinedGroupIds =
          ref.read(communityMembershipProvider).value ?? {widget.groupId};
      final draftTags = _resolvePostGroupTags();
      final finalTags = await CommunityCrossPostPrompt.resolveTags(
        context: context,
        selectedTags: draftTags,
        joinedGroupIds: joinedGroupIds,
        locale: ref.read(appLocaleProvider),
      );
      if (!mounted) return;

      await repo.createGroupPost(
        relevantGroupIds: finalTags,
        text: text,
      );
      await _postDraft.clear();
      _postController.clear();
      if (mounted) {
        setState(() {
          _submitting = false;
          _moderationError = null;
          _moderationBlock = null;
          _showPostDraftBanner = false;
          _postDraftRecord = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _moderationError = (
            catalogKey: 'community_group_err_post',
            rawMessage: null,
          );
        });
      }
    }
  }

  List<String> _resolvePostGroupTags() {
    if (_selectedGroupTags.isNotEmpty) {
      return _selectedGroupTags.toList();
    }
    if (widget.isJoined) return [_groupIdStr];
    return const [];
  }

  Future<
      ({
        CommunityModerationBlockCopy? block,
        CommunityUiError? error,
      })> _submitComment(
    String postId,
    String text,
  ) async {
    final repo = ref.read(communityRepositoryProvider);
    final moderation = ref.read(communityPostModerationServiceProvider);
    final uid = _currentUserId ?? await repo.currentUserId();
    // Snapshot for moderation — language model matches locale when comment posted.
    final locale = ref.read(appLocaleProvider);

    var result = await moderation.moderatePost(
      text: text,
      language: locale,
      userId: uid,
      groupId: _groupIdStr,
      isComment: true,
    );

    result = await resolveCommunityModeration(
      context: context,
      locale: locale,
      initialResult: result,
      runModeration: ({
        investmentWarningAcknowledged = false,
        fundraisingWarningAcknowledged = false,
      }) =>
          moderation.moderatePost(
        text: text,
        language: locale,
        userId: uid,
        groupId: _groupIdStr,
        isComment: true,
        investmentWarningAcknowledged: investmentWarningAcknowledged,
        fundraisingWarningAcknowledged: fundraisingWarningAcknowledged,
      ),
      onCancelled: (warnResult) => moderation.logModerationWarningCancelled(
        category: warnResult.category!,
        text: text,
        language: locale,
        userId: uid,
        contentType: 'group_comment',
        groupId: _groupIdStr,
        layer: warnResult.layer,
      ),
    );

    if (!result.allowed) {
      if (result.requiresConfirmation) {
        return (block: null, error: null);
      }
      return (
        block: CommunityModerationBlockPresentation.resolveCopy(
          result: result,
          locale: locale,
        ),
        error: null,
      );
    }

    try {
      await repo.createGroupComment(postId: postId, text: text);
      return (block: null, error: null);
    } catch (_) {
      return (
        block: null,
        error: (catalogKey: 'community_comment_err_post', rawMessage: null),
      );
    }
  }

  Future<void> _toggleLike(String postId, bool currentlyLiked) async {
    final uid = _currentUserId;
    if (uid == null) return;
    await ref.read(communityRepositoryProvider).toggleGroupPostLike(
          postId: postId,
          uid: uid,
          like: !currentlyLiked,
        );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final suggestedLabels = ref.watch(suggestedCommunityContentLabelIdsProvider);
    final postsAsync = ref.watch(groupPostsProvider(_groupIdStr));
    final joinedGroupIds =
        ref.watch(communityMembershipProvider).value ?? {widget.groupId};
    final uid = _currentUserId ?? '';

    final memberSubtitle = CommunityStrings.format(
      'community_members_count',
      locale,
      params: {'count': _formatMembers(widget.memberCount)},
    );

    return HubSubscreenScaffold(
      title: '${widget.emoji} ${widget.name}',
      subtitle: memberSubtitle,
      onBack: () => Navigator.of(context).pop(),
      headerTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommunityLiveDot(locale: locale),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: widget.onJoinToggle,
            child: Text(
              widget.isJoined
                  ? CommunityStrings.t('community_group_joined_badge', locale)
                  : CommunityStrings.t('community_join', locale),
              style: AppTypography.button.copyWith(
                color: widget.isJoined
                    ? AppColors.textSecondary
                    : AppColors.brandFamilyText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.brandFamilyMain,
              onRefresh: _refreshFeed,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                children: [
                  postsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                      child: HubLoadingPlaceholder(
                        height: 160,
                        width: 360,
                        silhouette: HubLoadingSilhouette.postCard,
                      ),
                    ),
                    error: (e, _) => GlassEmptyState(
                      accent: GlassEmptyStateAccent.teal,
                      icon: Icons.cloud_off_outlined,
                      title: CommunityStrings.t(
                        'community_group_err_feed',
                        locale,
                      ),
                      description: CommunityStrings.t(
                        'community_group_err_feed_hint',
                        locale,
                      ),
                    ),
                    data: (posts) {
                      if (posts.isEmpty) {
                        return GlassEmptyState(
                          accent: GlassEmptyStateAccent.teal,
                          icon: Icons.forum_outlined,
                          title: CommunityStrings.t(
                            'community_group_empty',
                            locale,
                          ),
                          description: widget.isJoined
                              ? CommunityStrings.format(
                                  'community_group_empty_joined',
                                  locale,
                                  params: {'groupName': widget.name},
                                )
                              : CommunityStrings.t(
                                  'community_group_empty_not_joined',
                                  locale,
                                ),
                        );
                      }
                      return Column(
                        children: posts
                            .map(
                              (post) => GroupPostCard(
                                post: post,
                                currentUserId: uid,
                                onLikeToggle: () => _toggleLike(
                                  post.id,
                                  post.isLikedBy(uid),
                                ),
                                onSubmitComment: (text) =>
                                    _submitComment(post.id, text),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          GroupFeedComposer(
            controller: _postController,
            draftController: _postDraft,
            showDraftBanner: _showPostDraftBanner,
            draftRecord: _postDraftRecord,
            isJoined: widget.isJoined,
            isSubmitting: _submitting,
            moderationBlock: _moderationBlock,
            moderationError: resolveCommunityUiError(_moderationError, locale),
            rephraseAttemptsUsed: _rephraseAttempts,
            onRephraseAttemptConsumed: () {
              setState(() => _rephraseAttempts++);
            },
            onApplyRephraseSuggestion: (text) {
              _postController.text = text;
              setState(() {
                _moderationBlock = null;
                _rephraseAttempts = 0;
              });
            },
            onRestoreDraft: () {
              _postController.text =
                  _postDraftRecord?.data['text']?.toString() ?? '';
              setState(() {
                _showPostDraftBanner = false;
                _postDraftRecord = null;
              });
            },
            onDiscardDraft: () async {
              await _postDraft.clear();
              setState(() {
                _showPostDraftBanner = false;
                _postDraftRecord = null;
              });
            },
            onSubmit: _submitPost,
            onJoinPrompt: widget.onJoinToggle,
            joinedGroupIds: joinedGroupIds,
            selectedGroupTags: _selectedGroupTags,
            onGroupTagsChanged: (tags) {
              setState(() => _selectedGroupTags = tags);
            },
            locale: locale,
            suggestedContentLabelIds: suggestedLabels,
          ),
        ],
      ),
    );
  }
}
