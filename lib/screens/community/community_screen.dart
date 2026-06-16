import 'package:flutter/material.dart';
import 'package:raabta/screens/community/ask_qatar_screen.dart';
import 'package:raabta/screens/community/events_screen.dart';
import 'package:raabta/screens/community/group_screen.dart';
import 'package:raabta/screens/community/lost_found_screen.dart';
import 'package:raabta/screens/community/news_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  late final TabController _tabController;

  final Set<int> _joinedGroupIds = {0, 1};
  final Map<int, int> _unreadCounts = {0: 3, 1: 7};

  static const List<_CommunityGroup> _allGroups = [
    _CommunityGroup(
      id: 0,
      emoji: '🇮🇳',
      name: 'Indians in Qatar',
      members: 45230,
      lastActivity: '5 min ago',
    ),
    _CommunityGroup(
      id: 1,
      emoji: '🇵🇰',
      name: 'Pakistanis in Qatar',
      members: 32100,
      lastActivity: '2 min ago',
    ),
    _CommunityGroup(
      id: 2,
      emoji: '🇧🇩',
      name: 'Bangladeshis in Qatar',
      members: 18500,
      lastActivity: '15 min ago',
    ),
    _CommunityGroup(
      id: 3,
      emoji: '🇳🇵',
      name: 'Nepalis in Qatar',
      members: 12300,
      lastActivity: '1 hour ago',
    ),
    _CommunityGroup(
      id: 4,
      emoji: '🇵🇭',
      name: 'Filipinos in Qatar',
      members: 28900,
      lastActivity: '20 min ago',
    ),
    _CommunityGroup(
      id: 5,
      emoji: '🇰🇪',
      name: 'Kenyans in Qatar',
      members: 5600,
      lastActivity: '3 hours ago',
    ),
    _CommunityGroup(
      id: 6,
      emoji: '⛑️',
      name: 'HSE Professionals Qatar',
      members: 8900,
      lastActivity: '30 min ago',
    ),
    _CommunityGroup(
      id: 7,
      emoji: '💼',
      name: 'Qatar Jobs Board',
      members: 67200,
      lastActivity: '1 min ago',
    ),
    _CommunityGroup(
      id: 8,
      emoji: '👨‍👩‍👧',
      name: 'Family Life Qatar',
      members: 22100,
      lastActivity: '45 min ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_CommunityGroup> get _yourGroups {
    return _allGroups.where((g) => _joinedGroupIds.contains(g.id)).toList();
  }

  void _toggleJoin(int groupId) {
    setState(() {
      if (_joinedGroupIds.contains(groupId)) {
        _joinedGroupIds.remove(groupId);
        _unreadCounts.remove(groupId);
      } else {
        _joinedGroupIds.add(groupId);
      }
    });
  }

  void _openGroup(_CommunityGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupScreen(
          emoji: group.emoji,
          name: group.name,
          memberCount: group.members,
          isJoined: _joinedGroupIds.contains(group.id),
          onJoinToggle: () => _toggleJoin(group.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '👥 Community',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: _cyanColor,
              labelColor: _cyanColor,
              unselectedLabelColor: _subtitleColor,
              dividerColor: const Color(0xFF1A2535),
              tabs: const [
                Tab(text: 'Groups'),
                Tab(text: 'Ask Qatar'),
                Tab(text: 'News'),
                Tab(text: 'Events'),
                Tab(text: 'Lost & Found'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGroupsTab(),
                  const AskQatarScreen(embedded: true),
                  const NewsScreen(embedded: true),
                  const EventsScreen(embedded: true),
                  const LostFoundScreen(embedded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        if (_yourGroups.isNotEmpty) ...[
          const Text(
            'Your Groups',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._yourGroups.map(
            (group) => _GroupTile(
              group: group,
              isJoined: true,
              unreadCount: _unreadCounts[group.id] ?? 0,
              onJoinToggle: () => _toggleJoin(group.id),
              onTap: () => _openGroup(group),
            ),
          ),
          const SizedBox(height: 28),
        ],
        const Text(
          'All Community Groups',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._allGroups.map(
          (group) => _GroupTile(
            group: group,
            isJoined: _joinedGroupIds.contains(group.id),
            unreadCount: _unreadCounts[group.id] ?? 0,
            onJoinToggle: () => _toggleJoin(group.id),
            onTap: () => _openGroup(group),
          ),
        ),
      ],
    );
  }
}

class _CommunityGroup {
  const _CommunityGroup({
    required this.id,
    required this.emoji,
    required this.name,
    required this.members,
    required this.lastActivity,
  });

  final int id;
  final String emoji;
  final String name;
  final int members;
  final String lastActivity;
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.isJoined,
    required this.unreadCount,
    required this.onJoinToggle,
    required this.onTap,
  });

  final _CommunityGroup group;
  final bool isJoined;
  final int unreadCount;
  final VoidCallback onJoinToggle;
  final VoidCallback onTap;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  String _formatMembers(int count) {
    return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(group.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isJoined && unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _cyanColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Color(0xFF050A0F),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatMembers(group.members)} members · ${group.lastActivity}',
                    style: const TextStyle(
                      color: _subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 34,
              child: OutlinedButton(
                onPressed: onJoinToggle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isJoined ? _subtitleColor : _cyanColor,
                  side: BorderSide(
                    color: isJoined ? _subtitleColor : _cyanColor,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isJoined ? 'Joined' : 'Join',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
