import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:share_plus/share_plus.dart';
import 'models/recurring_split_group.dart';

class MySplitsScreen extends StatelessWidget {
  const MySplitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScreenScaffold(
      title: 'My Recurring Splits',
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(RecurringSplitGroup.firestoreCollection)
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.sharePurple,
                strokeWidth: 2.5,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load splits.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final groups = docs.map((doc) {
            try {
              return RecurringSplitGroup.fromFirestore(doc);
            } catch (_) {
              return null;
            }
          }).whereType<RecurringSplitGroup>().toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (_, i) =>
                _RecurringGroupCard(group: groups[i]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔄',
              style: TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 16),
            Text(
              'No recurring splits yet',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a bill split and tap\n'
              '"Save as Recurring" to track\n'
              'monthly rent, utilities, and more.',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.sharePurple,
                size: 16,
              ),
              label: const Text(
                'Create a Split',
                style: TextStyle(
                  color: AppColors.sharePurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.sharePurple,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recurring group card ────────────────────────────────

class _RecurringGroupCard extends StatelessWidget {
  final RecurringSplitGroup group;

  const _RecurringGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final daysUntilNext = group.nextCycleDate
        .difference(DateTime.now())
        .inDays;
    final isOverdue = daysUntilNext < 0;
    final isDueSoon =
        daysUntilNext >= 0 && daysUntilNext <= 3;

    final statusColor = isOverdue
        ? AppColors.errorBright
        : isDueSoon
            ? AppColors.accentGold
            : AppColors.successBright;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      borderRadius: 16,
      glowColor: statusColor,
      glowIntensity: 0.1,
      child: Column(
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  group.billType.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.groupName,
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            group.recurrence.shortLabel,
                            style: TextStyle(
                              color: AppColors.isLight
                                  ? AppColors.textOnGlassMuted
                                  : Colors.white
                                      .withValues(alpha: 0.4),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '  •  ${group.members.length} people',
                            style: TextStyle(
                              color: AppColors.isLight
                                  ? AppColors.textOnGlassMuted
                                  : Colors.white
                                      .withValues(alpha: 0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'QAR ${group.totalQar.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOverdue
                            ? 'Overdue'
                            : isDueSoon
                                ? 'Due in ${daysUntilNext}d'
                                : '${daysUntilNext}d left',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(
            color: AppColors.isLight
                ? AppColors.glassBorder
                : Colors.white10,
            height: 1,
          ),

          // Member payment status list
          _MemberPaymentList(group: group),

          // Action row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              14, 10, 14, 14,
            ),
            child: Row(
              children: [
                // Send reminder via WhatsApp
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _sendWhatsAppReminder(group),
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Color(0xFF25D366),
                      size: 15,
                    ),
                    label: const Text(
                      'Send Reminder',
                      style: TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      side: const BorderSide(
                        color: Color(0xFF25D366),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Archive group
                OutlinedButton(
                  onPressed: () =>
                      _archiveGroup(context, group),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 14,
                    ),
                    side: BorderSide(
                      color: AppColors.isLight
                          ? AppColors.glassBorder
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Icon(
                    Icons.archive_outlined,
                    color: AppColors.isLight
                        ? AppColors.textTertiary
                        : Colors.white.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Reuses the SAME share mechanism as existing
  // bill splitter — just builds a different message string
  void _sendWhatsAppReminder(RecurringSplitGroup group) {
    final perPerson = group.members.isEmpty
        ? 0.0
        : group.totalQar / group.members.length;
    final lines = group.members.map((m) =>
      '${m.flag} ${m.name}: '
      'QAR ${m.shareQar.toStringAsFixed(2)}'
    ).join('\n');

    Share.share(
      '🔄 Monthly Split Reminder — RAABTA\n'
      '${group.billType.label}\n'
      '────────────────\n'
      '$lines\n'
      '────────────────\n'
      'Total: QAR ${group.totalQar.toStringAsFixed(2)}\n'
      'Each pays: QAR ${perPerson.toStringAsFixed(2)}\n\n'
      'Track splits with RAABTA • ${CommonStrings.publicWebsiteHost}',
    );
  }

  Future<void> _archiveGroup(
    BuildContext context,
    RecurringSplitGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(
          'Archive this split?',
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textPrimary
                : Colors.white,
          ),
        ),
        content: Text(
          'It will be removed from My Splits. '
          'History is preserved.',
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textOnGlassSecondary
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white38,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Archive',
              style: TextStyle(
                color: AppColors.errorBright,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection(
            RecurringSplitGroup.firestoreCollection,
          )
          .doc(group.id)
          .update({'isActive': false});
    }
  }
}

// ─── Member payment status list ──────────────────────────

class _MemberPaymentList extends StatelessWidget {
  final RecurringSplitGroup group;

  const _MemberPaymentList({required this.group});

  @override
  Widget build(BuildContext context) {
    final cycleStart = DateTime(
      group.nextCycleDate.year,
      group.nextCycleDate.month,
      1,
    );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(
            RecurringSplitGroup.firestoreCollection,
          )
          .doc(group.id)
          .collection(
            RecurringSplitGroup.paymentsSubcollection,
          )
          .where(
            'cycleDate',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(cycleStart),
          )
          .snapshots(),
      builder: (context, snapshot) {
        final paidIds = <String>{};
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final d =
                doc.data() as Map<String, dynamic>? ?? {};
            if (d['paid'] == true) {
              paidIds.add(d['memberId'] as String? ?? '');
            }
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: group.members.map((member) {
            final isPaid = paidIds.contains(member.id);
            return _MemberPaymentRow(
              member: member,
              isPaid: isPaid,
              groupId: group.id,
              cycleDate: group.nextCycleDate,
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Single member row with paid toggle ─────────────────

class _MemberPaymentRow extends StatelessWidget {
  final SplitMember member;
  final bool isPaid;
  final String groupId;
  final DateTime cycleDate;

  const _MemberPaymentRow({
    required this.member,
    required this.isPaid,
    required this.groupId,
    required this.cycleDate,
  });

  Future<void> _togglePaid() async {
    final col = FirebaseFirestore.instance
        .collection(
          RecurringSplitGroup.firestoreCollection,
        )
        .doc(groupId)
        .collection(
          RecurringSplitGroup.paymentsSubcollection,
        );

    if (isPaid) {
      // Find and remove the paid record
      final existing = await col
          .where('memberId', isEqualTo: member.id)
          .where(
            'cycleDate',
            isEqualTo: Timestamp.fromDate(cycleDate),
          )
          .get();
      for (final doc in existing.docs) {
        await doc.reference.delete();
      }
    } else {
      // Add paid record
      await col.add({
        'memberId':   member.id,
        'memberName': member.name,
        'paid':       true,
        'paidAt':     FieldValue.serverTimestamp(),
        'cycleDate':  Timestamp.fromDate(cycleDate),
        'amountQar':  member.shareQar,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text(
            member.flag,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.name,
              style: TextStyle(
                color: isPaid
                    ? (AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.35))
                    : (AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                decoration: isPaid
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          Text(
            'QAR ${member.shareQar.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _togglePaid,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isPaid
                    ? AppColors.successBright.withValues(alpha: 0.15)
                    : AppColors.isLight
                        ? AppColors.glassSurface
                        : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPaid
                      ? AppColors.successBright.withValues(alpha: 0.4)
                      : AppColors.isLight
                          ? AppColors.glassBorder
                          : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                isPaid ? '✓ Paid' : 'Pending',
                style: TextStyle(
                  color: isPaid
                      ? AppColors.successBright
                      : AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
