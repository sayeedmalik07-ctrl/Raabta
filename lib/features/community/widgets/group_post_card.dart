import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_banner.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_section.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/community/widgets/community_why_seeing_affordance.dart';
import 'package:raabta/features/community/utils/community_visibility_reasons.dart';
import 'package:raabta/features/link_safety/link_safety_models.dart';
import 'package:raabta/features/link_safety/presentation/link_safety_author_compose_hint.dart';
import 'package:raabta/features/link_safety/presentation/user_generated_text_with_link_safety.dart';
import 'package:raabta/providers/visa_providers.dart';

class GroupPostCard extends ConsumerStatefulWidget {
  const GroupPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLikeToggle,
    required this.onSubmitComment,
    this.moderationMessage,
  });

  final GroupPost post;
  final String currentUserId;
  final VoidCallback onLikeToggle;
  final Future<
      ({
        CommunityModerationBlockCopy? block,
        CommunityUiError? error,
      })> Function(String text) onSubmitComment;
  final String? moderationMessage;

  @override
  ConsumerState<GroupPostCard> createState() => _GroupPostCardState();
}

class _GroupPostCardState extends ConsumerState<GroupPostCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _commentsOpen = false;
  bool _submittingComment = false;
  CommunityUiError? _commentError;
  CommunityModerationBlockCopy? _commentBlock;
  int _commentRephraseAttempts = 0;
  final _commentController = TextEditingController();
  late final AnimationController _arrivalController;
  late final Animation<double> _fadeIn;

  static const _truncateLength = 220;

  @override
  void initState() {
    super.initState();
    _arrivalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeIn = CurvedAnimation(
      parent: _arrivalController,
      curve: Curves.easeOutCubic,
    );
    _arrivalController.forward();
    _commentController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _submittingComment) return;
    setState(() {
      _submittingComment = true;
      _commentError = null;
      _commentBlock = null;
      _commentRephraseAttempts = 0;
    });
    final outcome = await widget.onSubmitComment(text);
    if (!mounted) return;
    setState(() {
      _submittingComment = false;
      if (outcome.block == null && outcome.error == null) {
        _commentController.clear();
      } else {
        _commentBlock = outcome.block;
        _commentError = outcome.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final post = widget.post;
    final isLiked = post.isLikedBy(widget.currentUserId);
    final needsTruncate = post.text.length > _truncateLength;
    final displayText = _expanded || !needsTruncate
        ? post.text
        : '${post.text.substring(0, _truncateLength)}…';

    final commentsAsync = _commentsOpen
        ? ref.watch(groupPostCommentsProvider(post.id))
        : null;

    final visibility = CommunityVisibilityInput(
      relevantGroupIds: post.relevantGroupIds,
      likeCount: post.likes,
      commentCount: post.commentCount,
    );
    final authorLine = post.authorFlag.isNotEmpty
        ? '${post.authorDisplayName} ${post.authorFlag}'
        : post.authorDisplayName;
    final trustLabel =
        CommunityStrings.t('community_trust_tier_community', locale);

    return FadeTransition(
      opacity: _fadeIn,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: HubPostCard(
          pinnedLabel: post.isPinned
              ? CommunityStrings.t('community_post_pinned', locale)
              : null,
          authorName: authorLine,
          authorInitial: post.authorInitials,
          sectionContextLine:
              communityRelativeTime(post.createdAt, locale),
          trustTierBadge: (
            label: trustLabel,
            tier: HubContentTrustTier.community,
          ),
          bodyChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserGeneratedTextWithLinkSafety(
                text: displayText,
                locale: locale,
                surface: LinkSafetySurface.communityFeed,
                style: AppTypography.subtitle,
              ),
              if (needsTruncate)
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? CommunityStrings.t(
                            'community_post_show_less',
                            locale,
                          )
                        : CommunityStrings.t(
                            'community_post_read_more',
                            locale,
                          ),
                    style: AppTypography.link.copyWith(fontSize: 12),
                  ),
                ),
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.network(
                    post.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => GlassContainer(
                      height: 160,
                      padding: EdgeInsets.zero,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          whySeeingLabel:
              CommunityStrings.t('community_why_seeing_link', locale),
          onWhySeeingTap: () =>
              CommunityWhySeeingAffordance.showForInput(
            context,
            ref,
            visibility,
          ),
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.moderationMessage != null &&
                  widget.moderationMessage!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    widget.moderationMessage!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              Row(
                children: [
                  _ReactionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likes}',
                    active: isLiked,
                    onTap: widget.onLikeToggle,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _ReactionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentCount}',
                    active: _commentsOpen,
                    onTap: () => setState(() => _commentsOpen = !_commentsOpen),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _ReactionButton(
                    icon: Icons.share_outlined,
                    label: CommunityStrings.t('community_post_share', locale),
                    onTap: () {},
                  ),
                ],
              ),
              if (_commentsOpen) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(color: AppColors.glassBorder, height: 1),
              const SizedBox(height: AppSpacing.sm),
              commentsAsync?.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Center(
                        child: HubLoadingPlaceholder(
                          height: 72,
                          width: double.infinity,
                          silhouette: HubLoadingSilhouette.formTool,
                        ),
                      ),
                    ),
                    error: (_, _) => Text(
                      CommunityStrings.t('community_comments_err_load', locale),
                      style: AppTypography.bodySmall,
                    ),
                    data: (comments) {
                      if (comments.isEmpty) {
                        return Text(
                          CommunityStrings.t('community_comments_empty', locale),
                          style: AppTypography.bodySmall,
                        );
                      }
                      return Column(
                        children: comments
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommunityHubIcons.actionGlyph(
                                      Icons.subdirectory_arrow_right_rounded,
                                      size: 18,
                                    ),
                                    const SizedBox(width: AppSpacing.xxs),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.authorDisplayName,
                                            style: AppTypography.caption.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          UserGeneratedTextWithLinkSafety(
                                            text: c.text,
                                            locale: locale,
                                            surface: LinkSafetySurface.communityFeed,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),
              const SizedBox(height: AppSpacing.sm),
              if (_commentBlock != null)
                CommunityModerationBlockSection(
                  block: _commentBlock!,
                  locale: locale,
                  sourceText: _commentController.text,
                  rephraseAttemptsUsed: _commentRephraseAttempts,
                  compact: true,
                  onRephraseAttemptConsumed: () {
                    setState(() => _commentRephraseAttempts++);
                  },
                  onApplySuggestion: (text) {
                    _commentController.text = text;
                    setState(() {
                      _commentBlock = null;
                      _commentRephraseAttempts = 0;
                    });
                  },
                ),
              if (_commentError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    resolveCommunityUiError(_commentError, locale)!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              LinkSafetyAuthorComposeHint(
                text: _commentController.text,
                locale: locale,
                surface: LinkSafetySurface.communityFeed,
                onRemoveLink: () {
                  _commentController.text = _commentController.text.replaceAll(
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
                        controller: _commentController,
                        style: AppTypography.body,
                        decoration: InputDecoration(
                          hintText: CommunityStrings.t(
                            'community_comment_hint',
                            locale,
                          ),
                          hintStyle: AppTypography.bodySmall,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GlassCard(
                    onTap: _submittingComment ? null : _submitComment,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    borderRadius: AppSpacing.radiusFull,
                    glowColor: AppColors.brandFamilyMain,
                    glowIntensity: 0.15,
                    child: _submittingComment
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : CommunityHubIcons.composerSend(),
                  ),
                ],
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? communityHubAccentText : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommunityHubIcons.actionGlyph(icon, active: active, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
