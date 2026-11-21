import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/domain/loan_balance_calculator.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

class LoanPersonCard extends StatelessWidget {
  const LoanPersonCard({
    super.key,
    required this.summary,
    required this.locale,
    required this.onTap,
  });

  final PersonLoanSummary summary;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final net = summary.netBalance;
    final theyOweYou = net >= 0;
    final balanceColor =
        theyOweYou ? AppColors.successBright : AppColors.errorBright;
    final count = summary.activeEntries.length;
    final countKey =
        count == 1 ? 'loan_active_count_one' : 'loan_active_count_many';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.sharePurple.withValues(alpha: 0.25),
              child: Text(
                summary.personName.isNotEmpty
                    ? summary.personName.characters.first.toUpperCase()
                    : '?',
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.personName,
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    BillTrackerStrings.format(
                      countKey,
                      locale,
                      {'count': '$count'},
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'QAR ${net.abs().toStringAsFixed(0)}',
                  style: AppTypography.subtitle.copyWith(
                    color: balanceColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  theyOweYou
                      ? BillTrackerStrings.t('loan_owes_you', locale)
                      : BillTrackerStrings.t('loan_you_owe', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (summary.hasOverdue) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorBright.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      BillTrackerStrings.t('loan_status_overdue', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.errorBright,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
