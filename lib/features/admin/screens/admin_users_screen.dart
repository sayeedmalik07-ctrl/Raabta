import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/models/admin_stats.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';

/// Opens the same user detail sheet as [AdminUsersScreen] (suspend tier, etc.).
Future<void> showAdminUserDetailSheet(
  BuildContext context,
  WidgetRef ref,
  String uid,
) async {
  if (uid.trim().isEmpty) return;
  final row = await ref.read(adminRepositoryProvider).fetchUser(uid.trim());
  if (!context.mounted) return;
  if (row == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No user profile found for UID $uid')),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _UserDetailSheet(user: row),
  );
}

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  static const _pageSize = 20;

  final _searchController = TextEditingController();
  final _users = <AdminUserRow>[];
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadPage(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPage({required bool reset}) async {
    if (_loading) return;
    if (!reset && !_hasMore) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final result = await repo.fetchUsersPage(
        pageSize: _pageSize,
        startAfter: reset ? null : _lastDoc,
        query: _query,
      );

      setState(() {
        if (reset) _users.clear();
        _users.addAll(result.users);
        _lastDoc = result.lastDoc;
        _hasMore = result.users.length >= _pageSize;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String value) {
    _query = value;
    _loadPage(reset: true);
  }

  Future<void> _openUserDetail(AdminUserRow user) async {
    await showAdminUserDetailSheet(context, ref, user.uid);
    _loadPage(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'User Management'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search name, email, phone, UID…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.glassSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _onSearch,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadPage(reset: true),
                child: ListView.builder(
                  itemCount: _users.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _users.length) {
                      if (!_loading) _loadPage(reset: false);
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.purpleGlow.withValues(alpha: 0.3),
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(
                        '${user.email.isNotEmpty ? user.email : user.phone}\n'
                        'Joined ${user.createdAt != null ? DateFormat.yMMMd().format(user.createdAt!) : '—'}',
                      ),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _TierBadge(tier: user.subscriptionTier),
                          const SizedBox(height: 4),
                          _StatusBadge(status: user.status),
                        ],
                      ),
                      onTap: () => _openUserDetail(user),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});
  final String tier;

  @override
  Widget build(BuildContext context) {
    final color = switch (tier) {
      'pro' => AppColors.accentGold,
      'premium' => AppColors.cyanGlow,
      _ => AppColors.textTertiary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tier.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == 'suspended' || status == 'banned'
        ? AppColors.error
        : AppColors.success;
    return Text(
      status,
      style: TextStyle(color: color, fontSize: 10),
    );
  }
}

class _UserDetailSheet extends ConsumerStatefulWidget {
  const _UserDetailSheet({required this.user});
  final AdminUserRow user;

  @override
  ConsumerState<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends ConsumerState<_UserDetailSheet> {
  late String _tier;
  late bool _suspended;
  bool _busy = false;
  final _deleteConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tier = widget.user.subscriptionTier;
    _suspended = widget.user.status == 'suspended';
  }

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    super.dispose();
  }

  Future<void> _saveTier(String tier) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateUserSubscription(widget.user.uid, tier);
      setState(() => _tier = tier);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleSuspend(bool value) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setUserSuspended(widget.user.uid, value);
      setState(() => _suspended = value);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes the Firebase Auth account. '
              'Type DELETE to confirm.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deleteConfirmController,
              decoration: const InputDecoration(labelText: 'Confirmation'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (_deleteConfirmController.text.trim() == 'DELETE') {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(adminApiServiceProvider).deleteUserAccount(widget.user.uid);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final raw = u.raw ?? {};

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(u.displayName, style: AppTypography.headline2),
            const SizedBox(height: AppSpacing.sm),
            Text('UID: ${u.uid}', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.md),
            _Field('Email', u.email),
            _Field('Phone', u.phone),
            _Field('Nationality', u.nationality ?? '—'),
            _Field('Language', u.language ?? '—'),
            _Field('Level', u.level ?? '—'),
            _Field('Points', '${u.points ?? 0}'),
            _Field(
              'Last active',
              u.lastActive != null
                  ? DateFormat.yMMMd().add_jm().format(u.lastActive!)
                  : '—',
            ),
            const Divider(height: 32),
            Text('Subscription tier', style: AppTypography.subtitle),
            DropdownButtonFormField<String>(
              value: _tier,
              items: const [
                DropdownMenuItem(value: 'free', child: Text('Free')),
                DropdownMenuItem(value: 'premium', child: Text('Premium')),
                DropdownMenuItem(value: 'pro', child: Text('Pro')),
              ],
              onChanged: _busy ? null : (v) => v != null ? _saveTier(v) : null,
            ),
            SwitchListTile(
              title: const Text('Suspend account'),
              subtitle: const Text('Blocks sign-in for non-admin users'),
              value: _suspended,
              onChanged: _busy ? null : _toggleSuspend,
            ),
            const SizedBox(height: AppSpacing.md),
            ExpansionTile(
              title: const Text('Raw profile fields'),
              children: [
                for (final entry in raw.entries)
                  ListTile(
                    dense: true,
                    title: Text(entry.key, style: AppTypography.caption),
                    subtitle: Text('${entry.value}'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _confirmDelete,
                icon: const Icon(Icons.delete_forever, color: AppColors.error),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTypography.caption),
          ),
          Expanded(child: Text(value, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
