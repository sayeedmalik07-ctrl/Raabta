import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/models/employer_identity_verification.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/services/admin_repository.dart';
import 'package:raabta/features/admin/screens/admin_users_screen.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/widgets/community_widgets.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/models/admin_report_model.dart';

class AdminModerationScreen extends ConsumerStatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  ConsumerState<AdminModerationScreen> createState() =>
      _AdminModerationScreenState();
}

class _AdminModerationScreenState extends ConsumerState<AdminModerationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _jobs = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _housing = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _businesses = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _marketplace = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _services = [];
  List<AdminReportModel> _reports = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    try {
      final results = await Future.wait([
        repo.fetchModerationItems('jobs'),
        repo.fetchModerationItems('listings'),
        repo.fetchModerationItems('businesses'),
        repo.fetchModerationItems('marketplace_listings'),
        repo.fetchModerationItems('service_listings'),
        repo.fetchReports(),
      ]);
      setState(() {
        _jobs = results[0] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
        _housing = results[1] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
        _businesses =
            results[2] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
        _marketplace =
            results[3] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
        _services =
            results[4] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
        _reports = results[5] as List<AdminReportModel>;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _moderate({
    required String collection,
    required String docId,
    required String status,
  }) async {
    final reasonController = TextEditingController();
    if (status == 'rejected') {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rejection reason'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Optional reason'),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
          ],
        ),
      );
      if (proceed != true) {
        reasonController.dispose();
        return;
      }
    }

    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'admin';
    await ref.read(adminRepositoryProvider).moderateItem(
          collection: collection,
          docId: docId,
          status: status,
          adminUid: adminUid,
          reason: reasonController.text.trim(),
        );
    reasonController.dispose();
    await _loadAll();
  }

  Future<void> _moderateEmployerIdentity({
    required String businessId,
    required EmployerIdentityVerificationAction action,
  }) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null || adminUid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in as admin to update employer identity'),
        ),
      );
      return;
    }

    final reasonController = TextEditingController();
    if (action == EmployerIdentityVerificationAction.reject ||
        action == EmployerIdentityVerificationAction.revoke) {
      final dialogTitle = action == EmployerIdentityVerificationAction.reject
          ? 'Employer identity rejection reason'
          : 'Employer identity revocation reason';
      final confirmLabel = action == EmployerIdentityVerificationAction.reject
          ? 'Reject employer identity'
          : 'Revoke employer identity';
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(dialogTitle),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Optional reason'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
      if (proceed != true) {
        reasonController.dispose();
        return;
      }
    }

    try {
      await ref.read(adminRepositoryProvider).updateEmployerIdentityVerification(
            businessId: businessId,
            action: action,
            adminUid: adminUid,
            reason: reasonController.text.trim(),
          );
    } on EmployerIdentityVerificationUpdateException catch (e) {
      reasonController.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      return;
    }

    reasonController.dispose();
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AdminAppBar(
          title: 'Moderation',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAll,
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              controller: _tabs,
              isScrollable: true,
              indicatorColor: AdminAppBar.adminAccent,
              tabs: const [
                Tab(text: 'Jobs'),
                Tab(text: 'Housing'),
                Tab(text: 'Business'),
                Tab(text: 'Marketplace'),
                Tab(text: 'Services'),
                Tab(text: 'Reports'),
                Tab(text: 'Community'),
              ],
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        _ModerationList(
                          items: _jobs,
                          collection: 'jobs',
                          titleField: 'title',
                          onModerate: _moderate,
                        ),
                        _ModerationList(
                          items: _housing,
                          collection: 'listings',
                          titleField: 'title',
                          onModerate: _moderate,
                        ),
                        _BusinessModerationList(
                          items: _businesses,
                          onModerate: _moderate,
                          onEmployerIdentity: _moderateEmployerIdentity,
                        ),
                        _ModerationList(
                          items: _marketplace,
                          collection: 'marketplace_listings',
                          titleField: 'title',
                          onModerate: _moderate,
                        ),
                        _ModerationList(
                          items: _services,
                          collection: 'service_listings',
                          titleField: 'title',
                          onModerate: _moderate,
                        ),
                        _ReportsList(
                          reports: _reports,
                          onRefresh: _loadAll,
                        ),
                        const _CommunityModerationLogTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessModerationList extends StatelessWidget {
  const _BusinessModerationList({
    required this.items,
    required this.onModerate,
    required this.onEmployerIdentity,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> items;
  final Future<void> Function({
    required String collection,
    required String docId,
    required String status,
  }) onModerate;
  final Future<void> Function({
    required String businessId,
    required EmployerIdentityVerificationAction action,
  }) onEmployerIdentity;

  static String _employerIdentityStatusLabel(
    Map<String, dynamic> data,
  ) {
    final identity = EmployerIdentityVerification.fromFirestore(
      data['employerIdentityVerification'],
    );
    return identity?.status.storageValue ?? 'none';
  }

  static bool _canVerifyEmployerIdentity(Map<String, dynamic> data) {
    final identity = EmployerIdentityVerification.fromFirestore(
      data['employerIdentityVerification'],
    );
    final status = identity?.status;
    if (status == null) return true;
    return status == EmployerIdentityVerificationStatus.pending ||
        status == EmployerIdentityVerificationStatus.rejected ||
        status == EmployerIdentityVerificationStatus.revoked;
  }

  static bool _canRejectEmployerIdentity(Map<String, dynamic> data) {
    final identity = EmployerIdentityVerification.fromFirestore(
      data['employerIdentityVerification'],
    );
    final status = identity?.status;
    if (status == null) return true;
    return status != EmployerIdentityVerificationStatus.verified &&
        status != EmployerIdentityVerificationStatus.rejected;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('No items in businesses', style: AppTypography.body),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final doc = items[index];
        final data = doc.data();
        final title = data['name'] as String? ?? 'Untitled';
        final listingStatus = data['verificationStatus'] as String? ??
            data['status'] as String? ??
            'approved';
        final employerIdentityStatus = _employerIdentityStatusLabel(data);
        final created = data['createdAt'];
        DateTime? createdAt;
        if (created is Timestamp) createdAt = created.toDate();
        final showRevoke =
            employerIdentityStatus ==
                EmployerIdentityVerificationStatus.verified.storageValue;

        return Card(
          color: AppColors.glassSurface,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subtitle),
                const SizedBox(height: 4),
                Text(
                  'Listing status: $listingStatus · '
                  '${createdAt != null ? DateFormat.yMMMd().format(createdAt) : '—'}',
                  style: AppTypography.caption,
                ),
                Text(
                  'Employer identity: $employerIdentityStatus',
                  style: AppTypography.caption,
                ),
                if (data['photoUrls'] is List &&
                    (data['photoUrls'] as List).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Has photos',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => onModerate(
                        collection: 'businesses',
                        docId: doc.id,
                        status: 'approved',
                      ),
                      child: const Text('Approve listing'),
                    ),
                    TextButton(
                      onPressed: () => onModerate(
                        collection: 'businesses',
                        docId: doc.id,
                        status: 'rejected',
                      ),
                      child: const Text('Reject listing'),
                    ),
                    TextButton(
                      onPressed: () => _ModerationList.showDetailsStatic(
                        context,
                        title,
                        data,
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: _canVerifyEmployerIdentity(data)
                          ? () => onEmployerIdentity(
                                businessId: doc.id,
                                action:
                                    EmployerIdentityVerificationAction.verify,
                              )
                          : null,
                      child: const Text('Verify employer identity'),
                    ),
                    TextButton(
                      onPressed: _canRejectEmployerIdentity(data)
                          ? () => onEmployerIdentity(
                                businessId: doc.id,
                                action:
                                    EmployerIdentityVerificationAction.reject,
                              )
                          : null,
                      child: const Text('Reject employer identity'),
                    ),
                    if (showRevoke)
                      TextButton(
                        onPressed: () => onEmployerIdentity(
                          businessId: doc.id,
                          action: EmployerIdentityVerificationAction.revoke,
                        ),
                        child: const Text('Revoke employer identity'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModerationList extends StatelessWidget {
  const _ModerationList({
    required this.items,
    required this.collection,
    required this.titleField,
    required this.onModerate,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> items;
  final String collection;
  final String titleField;
  final Future<void> Function({
    required String collection,
    required String docId,
    required String status,
  }) onModerate;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('No items in $collection', style: AppTypography.body),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final doc = items[index];
        final data = doc.data();
        final title = data[titleField] as String? ?? 'Untitled';
        final status = collection == 'businesses'
            ? (data['verificationStatus'] as String? ??
                data['status'] as String? ??
                'approved')
            : data['status'] as String? ?? 'approved';
        final created = data['createdAt'];
        DateTime? createdAt;
        if (created is Timestamp) createdAt = created.toDate();

        return Card(
          color: AppColors.glassSurface,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subtitle),
                const SizedBox(height: 4),
                Text(
                  'Status: $status · '
                  '${createdAt != null ? DateFormat.yMMMd().format(createdAt) : '—'}',
                  style: AppTypography.caption,
                ),
                if (data['photoUrls'] is List &&
                    (data['photoUrls'] as List).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Has photos',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => onModerate(
                        collection: collection,
                        docId: doc.id,
                        status: 'approved',
                      ),
                      child: const Text('Approve'),
                    ),
                    TextButton(
                      onPressed: () => onModerate(
                        collection: collection,
                        docId: doc.id,
                        status: 'rejected',
                      ),
                      child: const Text('Reject'),
                    ),
                    TextButton(
                      onPressed: () => _showDetails(context, title, data),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showDetailsStatic(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
  ) {
    _showDetailsBody(context, title, data);
  }

  void _showDetails(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
  ) {
    _showDetailsBody(context, title, data);
  }

  static void _showDetailsBody(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ListView(
          children: [
            Text(title, style: AppTypography.headline2),
            const SizedBox(height: AppSpacing.md),
            for (final entry in data.entries)
              ListTile(
                dense: true,
                title: Text(entry.key, style: AppTypography.caption),
                subtitle: Text('${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

String? _reportedUserUid(AdminReportModel report) {
  final snapshot = report.chatSnapshot;
  if (snapshot == null) return null;
  final peerUid = snapshot['peerUid'] as String?;
  if (peerUid != null && peerUid.isNotEmpty) return peerUid;

  final reportedId = snapshot['reportedMessageId'] as String?;
  final messages = snapshot['messages'];
  if (reportedId == null || messages is! List) return null;
  for (final raw in messages) {
    if (raw is! Map) continue;
    if (raw['messageId'] != reportedId) continue;
    final senderId = raw['senderId'] as String?;
    if (senderId != null && senderId.isNotEmpty) return senderId;
  }
  return null;
}

String _chatSnapshotSummary(AdminReportModel report) {
  final snapshot = report.chatSnapshot;
  if (snapshot == null) return '';
  final messages = snapshot['messages'];
  if (messages is! List) return '';
  final reportedId = snapshot['reportedMessageId'] as String? ?? '';
  final peerUid = snapshot['peerUid'] as String? ?? '';
  final buffer = StringBuffer('Chat snapshot (${messages.length} msgs)');
  if (reportedId.isNotEmpty) buffer.write(' · reported: $reportedId');
  if (peerUid.isNotEmpty) buffer.write(' · peer: $peerUid');
  for (final raw in messages.take(3)) {
    if (raw is! Map) continue;
    final text = (raw['text'] as String? ?? '').trim();
    if (text.isEmpty) continue;
    final clipped = text.length > 80 ? '${text.substring(0, 80)}…' : text;
    buffer.write('\n• $clipped');
  }
  return buffer.toString();
}

class _ReportsList extends ConsumerWidget {
  const _ReportsList({
    required this.reports,
    required this.onRefresh,
  });

  final List<AdminReportModel> reports;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reports.isEmpty) {
      return Center(
        child: Text('No open reports', style: AppTypography.body),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final chatLines = _chatSnapshotSummary(report);
        final reportedUserUid = _reportedUserUid(report);
        return Card(
          color: AppColors.glassSurface,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            title: Text(report.title),
            subtitle: Text(
              [
                '${report.type.name} · ${report.status.name}',
                if (report.targetType != null) 'target: ${report.targetType}',
                report.description,
                if (chatLines.isNotEmpty) chatLines,
              ].join('\n'),
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'view_user') {
                  final uid = reportedUserUid;
                  if (uid == null) return;
                  await showAdminUserDetailSheet(context, ref, uid);
                  return;
                }
                final adminUid =
                    FirebaseAuth.instance.currentUser?.uid ?? 'admin';
                await ref.read(adminRepositoryProvider).updateReportStatus(
                      reportId: report.id,
                      status: value,
                      adminUid: adminUid,
                    );
                await onRefresh();
              },
              itemBuilder: (_) => [
                if (reportedUserUid != null)
                  const PopupMenuItem(
                    value: 'view_user',
                    child: Text('View reported user'),
                  ),
                const PopupMenuItem(value: 'resolved', child: Text('Resolve')),
                const PopupMenuItem(value: 'dismissed', child: Text('Dismiss')),
                const PopupMenuItem(value: 'reviewing', child: Text('Reviewing')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommunityModerationLogTab extends ConsumerWidget {
  const _CommunityModerationLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(moderationLogProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Could not load moderation log', style: AppTypography.body),
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Text(
              'No community moderation decisions yet.',
              style: AppTypography.body,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(moderationLogProvider);
            await ref.read(moderationLogProvider.future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              return _ModerationLogTile(entry: logs[index]);
            },
          ),
        );
      },
    );
  }
}

class _ModerationLogTile extends StatelessWidget {
  const _ModerationLogTile({required this.entry});

  final ModerationLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.glassSurface,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(
                  label: entry.allowed ? 'ALLOWED' : 'BLOCKED',
                  color: entry.allowed ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(entry.layer, style: AppTypography.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              entry.excerpt,
              style: AppTypography.subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${entry.contentType} · ${entry.language}'
              '${entry.category != null ? ' · ${entry.category}' : ''}',
              style: AppTypography.caption,
            ),
            Text(
              communityRelativeTime(entry.createdAt, 'English'),
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
