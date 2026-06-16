import 'package:flutter/material.dart';

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
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  final TextEditingController _postController = TextEditingController();
  final Set<int> _expandedComments = {};

  static const List<_GroupPost> _posts = [
    _GroupPost(
      id: 0,
      author: 'Rahul M.',
      initials: 'RM',
      flag: '🇮🇳',
      text:
          'Anyone know a good Indian restaurant in Al Khor that delivers? 🍛',
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
      author: 'Ahmed K.',
      initials: 'AK',
      flag: '🇵🇰',
      text: 'Iqama renewal fee increased to 200 QR from this month 📋',
      time: '5 hours ago',
      likes: 45,
      comments: 23,
      replies: [
        'Confirmed on Metrash2 yesterday.',
        'My company said they will cover it.',
        'Is this for all professions?',
      ],
    ),
    _GroupPost(
      id: 2,
      author: 'Sara P.',
      initials: 'SP',
      flag: '🇵🇭',
      text:
          'Looking for 1BHK flat near Industrial Area, budget 2000 QR',
      time: '1 day ago',
      likes: 5,
      comments: 12,
      replies: [
        'Check Raabta Housing section!',
        'I saw one in Al Wakrah for 1800 QR.',
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                Row(
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatMembers(widget.memberCount)} members',
                            style: const TextStyle(
                              color: _subtitleColor,
                              fontSize: 14,
                            ),
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
                              widget.isJoined ? _surfaceColor : _cyanColor,
                          foregroundColor:
                              widget.isJoined ? _subtitleColor : _backgroundColor,
                          elevation: 0,
                          side: widget.isJoined
                              ? const BorderSide(color: _subtitleColor)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.isJoined ? 'Joined' : 'Join',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ..._posts.map(
                  (post) => _PostCard(
                    post: post,
                    commentsExpanded: _expandedComments.contains(post.id),
                    onCommentTap: () => _toggleComments(post.id),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: _surfaceColor,
              border: Border(top: BorderSide(color: Color(0xFF1A2535))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Write a post...',
                        hintStyle: const TextStyle(color: _subtitleColor),
                        filled: true,
                        fillColor: _backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: _cyanColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send,
                        color: _backgroundColor,
                        size: 20,
                      ),
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
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.commentsExpanded,
    required this.onCommentTap,
  });

  final _GroupPost post;
  final bool commentsExpanded;
  final VoidCallback onCommentTap;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _cyanColor.withValues(alpha: 0.2),
                child: Text(
                  post.initials,
                  style: const TextStyle(
                    color: _cyanColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(post.flag, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    Text(
                      post.time,
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionChip(icon: Icons.favorite_border, label: '${post.likes}'),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onCommentTap,
                child: _ActionChip(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.comments}',
                  highlighted: commentsExpanded,
                ),
              ),
              const SizedBox(width: 16),
              _ActionChip(icon: Icons.share_outlined, label: 'Share'),
            ],
          ),
          if (commentsExpanded) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF1A2535), height: 1),
            const SizedBox(height: 10),
            ...post.replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.subdirectory_arrow_right,
                        color: _subtitleColor, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reply,
                        style: const TextStyle(
                          color: _subtitleColor,
                          fontSize: 13,
                        ),
                      ),
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? _cyanColor : _subtitleColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 13),
        ),
      ],
    );
  }
}
