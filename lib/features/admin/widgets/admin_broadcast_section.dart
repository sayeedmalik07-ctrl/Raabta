import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/models/admin_broadcast_models.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';

/// Broadcast composer + send history for the Config & Flags admin screen.
class AdminBroadcastSection extends ConsumerStatefulWidget {
  const AdminBroadcastSection({
    super.key,
    required this.saving,
    required this.onSavingChanged,
  });

  final bool saving;
  final ValueChanged<bool> onSavingChanged;

  @override
  ConsumerState<AdminBroadcastSection> createState() =>
      _AdminBroadcastSectionState();
}

class _AdminBroadcastSectionState extends ConsumerState<AdminBroadcastSection> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  AdminBroadcastTarget _target = AdminBroadcastTarget.allUsers;
  List<AdminAuditLogEntry> _history = [];
  bool _historyExpanded = true;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _titleController.addListener(_onFieldsChanged);
    _bodyController.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onFieldsChanged)
      ..dispose();
    _bodyController
      ..removeListener(_onFieldsChanged)
      ..dispose();
    super.dispose();
  }

  void _onFieldsChanged() => setState(() {});

  bool get _canSend {
    if (widget.saving) return false;
    return _titleController.text.trim().isNotEmpty &&
        _bodyController.text.trim().isNotEmpty;
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final entries = await ref
          .read(adminRepositoryProvider)
          .fetchBroadcastAuditHistory();
      if (mounted) setState(() => _history = entries);
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _confirmAndSend() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send broadcast?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will notify ${_target.displayLabel.toLowerCase()}. '
              'Users who disabled admin announcements will not receive it.',
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Title: $title', style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Text('Body: $body', style: AppTypography.bodySmall, maxLines: 4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AdminAppBar.adminAccent,
            ),
            child: const Text('Send broadcast'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.onSavingChanged(true);
    try {
      var adminUid = 'admin';
      var adminEmail = 'unknown@raabta.app';
      try {
        final user = FirebaseAuth.instance.currentUser;
        adminUid = user?.uid ?? adminUid;
        adminEmail = user?.email ?? adminEmail;
      } catch (_) {
        // Platform plugins unavailable (e.g. widget tests).
      }

      await ref.read(adminRepositoryProvider).sendAdminBroadcast(
            title: title,
            body: body,
            adminUid: adminUid,
            adminEmail: adminEmail,
            target: _target,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast sent successfully')),
        );
        _titleController.clear();
        _bodyController.clear();
        await _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Broadcast failed: $e')),
        );
      }
    } finally {
      if (mounted) widget.onSavingChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy · HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Admin Broadcast', style: AppTypography.headline2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Routes through the Smart Notification Engine (admin announcement type). '
          'Respects user preferences and quiet-hours rules.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _titleController,
          enabled: !widget.saving,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _bodyController,
          enabled: !widget.saving,
          decoration: const InputDecoration(labelText: 'Body'),
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Target audience', style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<AdminBroadcastTarget>(
          segments: const [
            ButtonSegment(
              value: AdminBroadcastTarget.allUsers,
              label: Text('All Users'),
              icon: Icon(Icons.groups),
            ),
            ButtonSegment(
              value: AdminBroadcastTarget.optedInOnly,
              label: Text('Opted-in Only'),
              icon: Icon(Icons.notifications_active),
            ),
          ],
          selected: {_target},
          onSelectionChanged: widget.saving
              ? null
              : (selection) {
                  setState(() => _target = selection.first);
                },
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          key: const Key('admin_broadcast_send'),
          onPressed: _canSend ? _confirmAndSend : null,
          icon: widget.saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.campaign),
          label: Text(widget.saving ? 'Sending…' : 'Send broadcast'),
          style: FilledButton.styleFrom(
            backgroundColor: AdminAppBar.adminAccent,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        InkWell(
          onTap: () => setState(() => _historyExpanded = !_historyExpanded),
          child: Row(
            children: [
              Icon(
                _historyExpanded ? Icons.expand_less : Icons.expand_more,
                color: AdminAppBar.adminAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Send history', style: AppTypography.headline2),
              const Spacer(),
              if (_loadingHistory)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        if (_historyExpanded) ...[
          const SizedBox(height: AppSpacing.sm),
          if (_history.isEmpty && !_loadingHistory)
            Text(
              'No broadcasts sent yet.',
              style: AppTypography.bodySmall,
            )
          else
            for (final entry in _history)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.history,
                  color: AdminAppBar.adminAccent,
                ),
                title: Text(
                  entry.broadcastTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${entry.targetModeLabel} · ${entry.adminEmail}\n'
                  '${entry.timestamp != null ? dateFormat.format(entry.timestamp!) : '—'}',
                ),
                isThreeLine: true,
              ),
        ],
      ],
    );
  }
}
