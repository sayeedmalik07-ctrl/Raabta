import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';

enum PostType { text, poll, announcement }

class PollOption {
  const PollOption({required this.label, required this.votes});

  final String label;
  final int votes;
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({
    super.key,
    required this.emoji,
    required this.name,
    required this.memberCount,
    required this.isJoined,
    required this.onJoinToggle,
  });

  final String emoji;
  final String name;
  final int memberCount;
  final bool isJoined;
  final VoidCallback onJoinToggle;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _postController = TextEditingController();
  final Set<int> _expandedComments = {};
  final Set<int> _expandedPosts = {};
  final Set<int> _likedPosts = {};
  final Set<int> _savedPosts = {};
  final Map<int, int?> _pollVotes = {};

  late List<_GroupPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _initialPosts;
    _posts.sort((a, b) {
      if (a.type == PostType.announcement && b.type != PostType.announcement) {
        return -1;
      }
      if (b.type == PostType.announcement && a.type != PostType.announcement) {
        return 1;
      }
      return 0;
    });
  }

  static final List<_GroupPost> _initialPosts = [
    const _GroupPost(
      id: 100,
      type: PostType.announcement,
      author: 'Group Admin',
      initials: 'GA',
      flag: '📢',
      text:
          'Welcome! Please read community guidelines before posting. Be respectful and helpful to fellow expats.',
      time: 'Pinned',
      likes: 120,
      comments: 4,
      replies: ['Thanks admin!', 'Very helpful guidelines.'],
      isPinned: true,
    ),
    const _GroupPost(
      id: 0,
      author: 'Rahul M.',
      initials: 'RM',
      flag: '🇮🇳',
      text:
          'Anyone know a good Indian restaurant in Al Khor that delivers? 🍛 We just moved here and looking for recommendations from the community.',
      time: '2 hours ago',
      likes: 12,
      comments: 8,
      replies: [
        'Try Spice Garden on WhatsApp delivery!',
        'Al Khor Fish Market area has good options too.',
      ],
    ),
    _GroupPost(
      id: 1,
      type: PostType.poll,
      author: 'Ahmed K.',
      initials: 'AK',
      flag: '🇵🇰',
      text: 'Which area has the best expat community facilities?',
      time: '5 hours ago',
      likes: 45,
      comments: 23,
      replies: [
        'Confirmed on Metrash2 yesterday.',
        'My company said they will cover it.',
      ],
      pollOptions: const [
        PollOption(label: 'Al Khor', votes: 89),
        PollOption(label: 'Doha', votes: 156),
        PollOption(label: 'Lusail', votes: 67),
      ],
    ),
    const _GroupPost(
      id: 2,
      author: 'Sara P.',
      initials: 'SP',
      flag: '🇵🇭',
      text:
          'Looking for 1BHK flat near Industrial Area, budget 2000 QR. Any leads appreciated!',
      time: '1 day ago',
      likes: 5,
      comments: 12,
      replies: [
        'Check Raabta Housing section!',
        'I saw one in Al Wakrah for 1800 QR.',
      ],
      hasPhoto: true,
    ),
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  String _formatMembers(int count) {
    return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  void _toggleComments(int postId) {
    setState(() {
      if (_expandedComments.contains(postId)) {
        _expandedComments.remove(postId);
      } else {
        _expandedComments.add(postId);
      }
    });
  }

  void _toggleExpandPost(int postId) {
    setState(() {
      if (_expandedPosts.contains(postId)) {
        _expandedPosts.remove(postId);
      } else {
        _expandedPosts.add(postId);
      }
    });
  }

  void _toggleLike(int postId) {
    setState(() {
      if (_likedPosts.contains(postId)) {
        _likedPosts.remove(postId);
      } else {
        _likedPosts.add(postId);
      }
    });
  }

  void _toggleSave(int postId) {
    setState(() {
      if (_savedPosts.contains(postId)) {
        _savedPosts.remove(postId);
      } else {
        _savedPosts.add(postId);
      }
    });
  }

  void _votePoll(int postId, int optionIndex) {
    setState(() => _pollVotes[postId] = optionIndex);
  }

  int _pollTotalVotes(_GroupPost post) {
    if (post.pollOptions == null || post.pollOptions!.isEmpty) return 1;
    return post.pollOptions!.fold(0, (sum, o) => sum + o.votes).clamp(1, 999999);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name, style: AppTextStyles.h2),
                          Text(
                            '${_formatMembers(widget.memberCount)} members',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: widget.onJoinToggle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.isJoined ? AppColors.surface : AppColors.primary,
                          foregroundColor:
                              widget.isJoined ? AppColors.textMuted : AppColors.background,
                          elevation: 0,
                          side: widget.isJoined
                              ? BorderSide(color: AppColors.textMuted)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: Text(
                          widget.isJoined ? '✓ Joined' : 'Join',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                ..._posts.map(
                  (post) => _PostCard(
                    post: post,
                    isLiked: _likedPosts.contains(post.id),
                    isSaved: _savedPosts.contains(post.id),
                    isExpanded: _expandedPosts.contains(post.id),
                    commentsExpanded: _expandedComments.contains(post.id),
                    votedOption: _pollVotes[post.id],
                    pollTotalVotes: _pollTotalVotes(post),
                    onLike: () => _toggleLike(post.id),
                    onSave: () => _toggleSave(post.id),
                    onExpand: () => _toggleExpandPost(post.id),
                    onCommentTap: () => _toggleComments(post.id),
                    onVote: (index) => _votePoll(post.id, index),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.surfaceElevated)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Write a post...',
                        hintStyle: AppTextStyles.bodyMedium,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupPost {
  const _GroupPost({
    required this.id,
    required this.author,
    required this.initials,
    required this.flag,
    required this.text,
    required this.time,
    required this.likes,
    required this.comments,
    required this.replies,
    this.type = PostType.text,
    this.isPinned = false,
    this.hasPhoto = false,
    this.pollOptions,
  });

  final int id;
  final String author;
  final String initials;
  final String flag;
  final String text;
  final String time;
  final int likes;
  final int comments;
  final List<String> replies;
  final PostType type;
  final bool isPinned;
  final bool hasPhoto;
  final List<PollOption>? pollOptions;
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.isLiked,
    required this.isSaved,
    required this.isExpanded,
    required this.commentsExpanded,
    required this.votedOption,
    required this.pollTotalVotes,
    required this.onLike,
    required this.onSave,
    required this.onExpand,
    required this.onCommentTap,
    required this.onVote,
  });

  final _GroupPost post;
  final bool isLiked;
  final bool isSaved;
  final bool isExpanded;
  final bool commentsExpanded;
  final int? votedOption;
  final int pollTotalVotes;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onExpand;
  final VoidCallback onCommentTap;
  final ValueChanged<int> onVote;

  static const int _truncateLength = 120;

  @override
  Widget build(BuildContext context) {
    final needsTruncate = post.text.length > _truncateLength;
    final displayText = isExpanded || !needsTruncate
        ? post.text
        : '${post.text.substring(0, _truncateLength)}…';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: post.type == PostType.announcement
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.type == PostType.announcement)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '📢 ANNOUNCEMENT',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: Text(
                  post.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.author,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(post.flag, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    Text(post.time, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (post.isPinned)
                const Icon(Icons.push_pin, size: 16, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            displayText,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.4),
          ),
          if (needsTruncate)
            GestureDetector(
              onTap: onExpand,
              child: Text(
                isExpanded ? 'Show less' : 'Read more',
                style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
              ),
            ),
          if (post.hasPhoto) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: LinearGradient(
                  colors: [Color(0xFF1A2535), Color(0xFF0D1520)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 48),
              ),
            ),
          ],
          if (post.type == PostType.poll && post.pollOptions != null) ...[
            const SizedBox(height: AppSpacing.md),
            ...post.pollOptions!.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final fraction = option.votes / pollTotalVotes;
              final isVoted = votedOption == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 32,
                        backgroundColor: AppColors.background,
                        color: isVoted
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${option.label} · ${option.votes} votes',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: votedOption == null ? () => onVote(index) : null,
                          child: Text(
                            isVoted ? 'Voted ✓' : 'Vote',
                            style: TextStyle(
                              fontSize: 12,
                              color: votedOption == null
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _ReactionButton(
                icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: '${post.likes + (isLiked ? 1 : 0)}',
                active: isLiked,
                onTap: onLike,
              ),
              const SizedBox(width: AppSpacing.lg),
              _ReactionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments}',
                active: commentsExpanded,
                onTap: onCommentTap,
              ),
              const SizedBox(width: AppSpacing.lg),
              _ReactionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () {},
              ),
              const SizedBox(width: AppSpacing.lg),
              _ReactionButton(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                active: isSaved,
                onTap: onSave,
              ),
            ],
          ),
          if (commentsExpanded) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.surfaceElevated, height: 1),
            const SizedBox(height: AppSpacing.sm),
            ...post.replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(reply, style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
