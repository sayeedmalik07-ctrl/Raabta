import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/data/models/loan_entry_model.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_actions.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_balance_calculator.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/providers/loan_providers.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/widgets/loan_share_card.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/raabta_notification_service.dart';
import 'package:share_plus/share_plus.dart';

class PersonLoanDetailScreen extends ConsumerWidget {
  const PersonLoanDetailScreen({super.key, required this.personKey});

  final String personKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final summaries = ref.watch(personLoanSummariesProvider);
    PersonLoanSummary? summary;
    for (final s in summaries) {
      if (s.personKey == personKey) {
        summary = s;
        break;
      }
    }

    if (summary == null) {
      return GlassScreenScaffold(
        title: BillTrackerStrings.t('loan_details_title', locale),
        body: Center(
          child: Text(BillTrackerStrings.t('loan_person_not_found', locale)),
        ),
      );
    }

    final resolved = summary;
    final net = resolved.netBalance;
    final theyOweYou = net >= 0;
    final allEntries = [...resolved.activeEntries, ...resolved.settledEntries];

    return GlassScreenScaffold(
      title: resolved.personName,
      actions: [
        IconButton(
          tooltip: BillTrackerStrings.t('loan_share_summary', locale),
          onPressed: () => showLoanShareCard(
            context,
            summary: resolved,
            locale: locale,
          ),
          icon: const Icon(Icons.ios_share_rounded, color: AppColors.cyanGlow),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BillTrackerStrings.t('loan_running_balance', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'QAR ${net.abs().toStringAsFixed(2)}',
                  style: AppTypography.headline2.copyWith(
                    color: theyOweYou
                        ? AppColors.successBright
                        : AppColors.errorBright,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  theyOweYou
                      ? BillTrackerStrings.t('loan_net_owed_to_you', locale)
                      : BillTrackerStrings.t('loan_net_you_owe', locale),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendReminder(context, resolved, locale),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(BillTrackerStrings.t('loan_send_reminder', locale)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/bill-tracker/loans/add'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(BillTrackerStrings.t('loan_add_title', locale)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sharePurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            BillTrackerStrings.t('loan_history', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final entry in allEntries) ...[
            _LoanEntryTile(
              entry: entry,
              locale: locale,
              onRepay: () => _recordRepayment(context, ref, entry, locale),
              onArchive: () => _archiveEntry(context, ref, entry),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (resolved.activeEntries.isNotEmpty)
            TextButton(
              onPressed: () => _confirmDeletePerson(context, ref, resolved, locale),
              child: Text(
                BillTrackerStrings.t('loan_remove_all_records', locale),
                style: const TextStyle(color: AppColors.errorBright),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _recordRepayment(
    BuildContext context,
    WidgetRef ref,
    LoanEntryModel entry,
    String locale,
  ) async {
    final amountCtrl = TextEditingController();
    final remaining = remainingBalance(entry);

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(BillTrackerStrings.t('loan_record_repayment', locale)),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: BillTrackerStrings.t('label_amount', locale),
            helperText: BillTrackerStrings.format(
              'loan_remaining_helper',
              locale,
              {'amount': remaining.toStringAsFixed(2)},
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(BillTrackerStrings.t('loan_cancel', locale)),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amountCtrl.text.trim());
              if (value == null || value <= 0) return;
              if (value > remaining + 0.001) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      BillTrackerStrings.format(
                        'loan_repayment_exceeds',
                        locale,
                        {'amount': remaining.toStringAsFixed(2)},
                      ),
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(ctx, value);
            },
            child: Text(BillTrackerStrings.t('loan_save', locale)),
          ),
        ],
      ),
    );

    if (amount == null) return;

    final userId =
        await RaabtaNotificationService.instance.getOrCreateUserId();
    final repo = ref.read(loanRepositoryProvider);
    await repo.addRepayment(
      loanId: entry.id,
      userId: userId,
      amount: amount,
      date: DateTime.now(),
    );

    final updated = entry.copyWith(
      repayments: [
        ...entry.repayments,
        LoanRepayment(amount: amount, date: DateTime.now()),
      ],
      updatedAt: DateTime.now(),
    );
    await syncLoanReminders(updated);
  }

  Future<void> _archiveEntry(
    BuildContext context,
    WidgetRef ref,
    LoanEntryModel entry,
  ) async {
    final userId =
        await RaabtaNotificationService.instance.getOrCreateUserId();
    await ref.read(loanRepositoryProvider).archiveLoan(
          entry.id,
          userId: userId,
        );
    await cancelLoanReminders(entry.id);
  }

  Future<void> _confirmDeletePerson(
    BuildContext context,
    WidgetRef ref,
    PersonLoanSummary summary,
    String locale,
  ) async {
    if (summary.activeEntries.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(BillTrackerStrings.t('loan_delete_active_title', locale)),
          content: Text(
            BillTrackerStrings.format(
              'loan_delete_body_named',
              locale,
              {
                'name': summary.personName,
                'amount': summary.netBalance.abs().toStringAsFixed(2),
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(BillTrackerStrings.t('loan_cancel', locale)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorBright,
              ),
              child: Text(BillTrackerStrings.t('loan_delete', locale)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final userId =
        await RaabtaNotificationService.instance.getOrCreateUserId();
    for (final entry in [...summary.activeEntries, ...summary.settledEntries]) {
      await cancelLoanReminders(entry.id);
    }
    await ref.read(loanRepositoryProvider).deleteAllForPerson(
          userId: userId,
          personKey: summary.personKey,
        );
    if (context.mounted) context.pop();
  }

  void _sendReminder(
    BuildContext context,
    PersonLoanSummary summary,
    String locale,
  ) {
    if (summary.activeEntries.isEmpty) return;
    final entry = summary.activeEntries.first;
    final remaining = remainingBalance(entry);
    final message = buildLoanReminderShareMessage(
      direction: entry.direction,
      personName: summary.personName,
      remainingAmount: remaining,
      dueDate: entry.dueDate,
      locale: locale,
    );

    final messageCtrl = TextEditingController(text: message);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(BillTrackerStrings.t('loan_send_reminder_title', locale)),
        content: TextField(
          controller: messageCtrl,
          maxLines: 5,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: BillTrackerStrings.t('loan_edit_message', locale),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(BillTrackerStrings.t('loan_cancel', locale)),
          ),
          FilledButton(
            onPressed: () {
              Share.share(messageCtrl.text);
              Navigator.pop(ctx);
            },
            child: Text(BillTrackerStrings.t('loan_share_via', locale)),
          ),
        ],
      ),
    );
  }
}

class _LoanEntryTile extends StatelessWidget {
  const _LoanEntryTile({
    required this.entry,
    required this.locale,
    required this.onRepay,
    required this.onArchive,
  });

  final LoanEntryModel entry;
  final String locale;
  final VoidCallback onRepay;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final remaining = remainingBalance(entry);
    final status = computeLoanStatus(entry);
    final statusColor = switch (status) {
      LoanStatus.overdue => AppColors.errorBright,
      LoanStatus.settled => AppColors.textSecondary,
      LoanStatus.active => AppColors.cyanGlow,
    };

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDirectionLabel(entry.direction, locale),
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                formatLoanStatusLabel(status, locale),
                style: AppTypography.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            BillTrackerStrings.format(
              'loan_entry_amount_line',
              locale,
              {
                'amount': entry.amount.toStringAsFixed(2),
                'remaining': remaining.toStringAsFixed(2),
              },
            ),
            style: AppTypography.subtitle.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            BillTrackerStrings.format(
              'loan_entry_dates_line',
              locale,
              {
                'loanDate':
                    '${entry.loanDate.day}/${entry.loanDate.month}/${entry.loanDate.year}',
                'dueDate':
                    '${entry.dueDate.day}/${entry.dueDate.month}/${entry.dueDate.year}',
              },
            ),
            style: AppTypography.caption,
          ),
          if (entry.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(entry.notes, style: AppTypography.caption),
          ],
          if (entry.repayments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              BillTrackerStrings.format(
                'loan_repayments_count',
                locale,
                {'count': '${entry.repayments.length}'},
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (remaining > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton(
                  onPressed: onRepay,
                  child: Text(
                    BillTrackerStrings.t('loan_record_repayment_btn', locale),
                  ),
                ),
                TextButton(
                  onPressed: onArchive,
                  child: Text(BillTrackerStrings.t('loan_archive_btn', locale)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
