import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

Color _billPrimaryText({required bool dimmed, double darkDimAlpha = 0.35}) {
  if (AppColors.isLight) {
    return dimmed
        ? AppColors.textOnGlassMuted
        : AppColors.textPrimary;
  }
  return dimmed
      ? Colors.white.withValues(alpha: darkDimAlpha)
      : Colors.white;
}

Color _billMutedText(double darkAlpha) => AppColors.isLight
    ? AppColors.textOnGlassMuted
    : Colors.white.withValues(alpha: darkAlpha);

Color _billNeutralStatusColor() =>
    AppColors.isLight ? AppColors.textTertiary : Colors.white24;

class BillSectionHeader extends StatelessWidget {
  const BillSectionHeader({
    super.key,
    required this.title,
    required this.color,
  });

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
    );
  }
}

class BillStatsRow extends StatelessWidget {
  const BillStatsRow({
    super.key,
    required this.locale,
    required this.totalUnpaid,
    required this.overdueCount,
    required this.dueSoonCount,
    this.onShareOutstanding,
  });

  final String locale;
  final double totalUnpaid;
  final int overdueCount;
  final int dueSoonCount;
  final VoidCallback? onShareOutstanding;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onShareOutstanding,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                borderRadius: 12,
                glowColor: totalUnpaid > 0 ? AppColors.error : AppColors.success,
                glowIntensity: 0.1,
                backgroundColor: (totalUnpaid > 0
                        ? AppColors.error
                        : AppColors.success)
                    .withValues(alpha: 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            BillTrackerStrings.t('stat_outstanding', locale),
                            style: TextStyle(
                              color: _billMutedText(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (onShareOutstanding != null)
                          Icon(
                            Icons.ios_share_rounded,
                            size: 14,
                            color: _billMutedText(0.35),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'QAR ${totalUnpaid.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: totalUnpaid > 0
                            ? AppColors.errorBright
                            : AppColors.successBright,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _BillMiniStat(
                  label: BillTrackerStrings.t('stat_overdue', locale),
                  value: '$overdueCount',
                  color: overdueCount > 0
                      ? AppColors.errorBright
                      : AppColors.successBright,
                ),
                const SizedBox(height: 10),
                _BillMiniStat(
                  label: BillTrackerStrings.t('stat_due_soon', locale),
                  value: '$dueSoonCount',
                  color: dueSoonCount > 0
                      ? AppColors.accentGold
                      : AppColors.successBright,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillMiniStat extends StatelessWidget {
  const _BillMiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        borderRadius: 10,
        glowColor: color,
        glowIntensity: 0.08,
        backgroundColor: color.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: _billMutedText(0.35),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    required this.locale,
    required this.onMarkPaid,
    required this.onDelete,
    this.anomaly,
    this.dimmed = false,
  });

  final BillEntry bill;
  final String locale;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;
  final BillAnomaly? anomaly;
  final bool dimmed;

  Color get _statusColor {
    if (bill.isPaid) return AppColors.successBright;
    if (bill.isOverdue) return AppColors.errorBright;
    if (bill.isDueSoon) return AppColors.accentGold;
    return _billNeutralStatusColor();
  }

  String get _dueLabel => BillTrackerStrings.dueLabel(
        isPaid: bill.isPaid,
        daysUntilDue: bill.daysUntilDue,
        locale: locale,
      );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('bill_${bill.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.errorBright.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.errorBright,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 14,
        glowColor: _statusColor,
        glowIntensity: dimmed ? 0 : 0.08,
        backgroundColor: dimmed
            ? (AppColors.isLight
                ? AppColors.textPrimary.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.02))
            : null,
        child: Row(
          children: [
            Text(
              bill.displayEmoji,
              style: TextStyle(
                fontSize: 26,
                color: dimmed
                    ? (AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.3))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bill.displayProvider,
                    style: TextStyle(
                      color: _billPrimaryText(dimmed: dimmed),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      decoration:
                          bill.isPaid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (bill.isLegacyProvider) ...[
                    const SizedBox(height: 4),
                    Text(
                      BillTrackerStrings.t('legacy_provider_note', locale),
                      style: TextStyle(
                        color: AppColors.accentGold.withValues(alpha: 0.8),
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (anomaly != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      BillTrackerStrings.format('anomaly_bill_hint', locale, {
                        'percent': '${anomaly!.roundedPercentAbove}',
                        'average': anomaly!.averageAmount.toStringAsFixed(0),
                        'currency': anomaly!.currency,
                      }),
                      style: TextStyle(
                        color: AppColors.accentGold.withValues(alpha: 0.85),
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _dueLabel,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (bill.accountNumber.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '#${bill.accountNumber}',
                          style: TextStyle(
                            color: _billMutedText(0.2),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QAR ${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _billPrimaryText(dimmed: dimmed, darkDimAlpha: 0.25),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    decoration:
                        bill.isPaid ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onMarkPaid,
                  child: Tooltip(
                    message:
                        BillTrackerStrings.t('mark_paid_tooltip', locale),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bill.isPaid
                            ? AppColors.successBright.withValues(alpha: 0.1)
                            : (AppColors.isLight
                                ? AppColors.textPrimary.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: bill.isPaid
                              ? AppColors.successBright.withValues(alpha: 0.3)
                              : (AppColors.isLight
                                  ? AppColors.glassBorder
                                  : Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      child: Text(
                        bill.isPaid
                            ? BillTrackerStrings.t('paid_badge', locale)
                            : BillTrackerStrings.t('mark_paid_label', locale),
                        style: TextStyle(
                          color: bill.isPaid
                              ? AppColors.successBright
                              : (AppColors.isLight
                                  ? AppColors.textOnGlassSecondary
                                  : Colors.white38),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
