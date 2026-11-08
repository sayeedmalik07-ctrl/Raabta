import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/bill_splitter/domain/minimum_settlement_calculator.dart';
import 'package:raabta/features/quick_actions/bill_splitter/l10n/bill_splitter_strings.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';

/// Shows who paid and the minimized list of payments to settle the group.
class MinimumSettlementPanel extends StatelessWidget {
  const MinimumSettlementPanel({
    super.key,
    required this.locale,
    required this.currency,
    required this.people,
    required this.sharesByPersonId,
    required this.totalBill,
    required this.payerId,
    required this.onPayerChanged,
  });

  final String locale;
  final String currency;
  final List<SplitPerson> people;
  final Map<String, double> sharesByPersonId;
  final double totalBill;
  final String payerId;
  final ValueChanged<String> onPayerChanged;

  SplitPerson? _person(String id) {
    for (final p in people) {
      if (p.stableId == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (people.length < 2 || totalBill <= 0) return const SizedBox.shrink();

    final balances = MinimumSettlementCalculator.netBalances(
      sharesByPersonId: sharesByPersonId,
      totalBill: totalBill,
      payerId: payerId,
    );
    final payments = MinimumSettlementCalculator.simplify(balances);
    if (payments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BillSplitterStrings.format(
            'settlement_payments_count',
            locale,
            {'count': '${payments.length}'},
          ),
          style: AppTypography.headline2.copyWith(
            color: AppColors.isLight
                ? AppColors.textPrimary
                : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          BillSplitterStrings.t('settlement_payer_hint', locale),
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textOnGlassMuted
                : Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: people.map((person) {
            final selected = person.stableId == payerId;
            return GestureDetector(
              onTap: () => onPayerChanged(person.stableId),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.sharePurple.withValues(alpha: 0.2)
                      : AppColors.isLight
                          ? AppColors.glassSurface
                          : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.sharePurple.withValues(alpha: 0.6)
                        : AppColors.isLight
                            ? AppColors.glassBorder
                            : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  selected
                      ? '${person.flag} ${person.name} · ${BillSplitterStrings.t('settlement_payer_badge', locale)}'
                      : '${person.flag} ${person.name}',
                  style: TextStyle(
                    color: selected
                        ? AppColors.sharePurple
                        : AppColors.isLight
                            ? AppColors.textOnGlassSecondary
                            : Colors.white70,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        ...payments.map((payment) {
          final from = _person(payment.fromPersonId);
          final to = _person(payment.toPersonId);
          if (from == null || to == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      BillSplitterStrings.format(
                        'settlement_payment_line',
                        locale,
                        {
                          'from': from.name,
                          'to': to.name,
                          'amount':
                              '$currency ${payment.amount.toStringAsFixed(2)}',
                        },
                      ),
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.isLight
                        ? AppColors.textTertiary
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Builds share-caption lines for optimized settlement payments.
List<String> settlementShareLines({
  required String locale,
  required String currency,
  required List<SplitPerson> people,
  required Map<String, double> sharesByPersonId,
  required double totalBill,
  required String payerId,
}) {
  SplitPerson? person(String id) {
    for (final p in people) {
      if (p.stableId == id) return p;
    }
    return null;
  }

  final balances = MinimumSettlementCalculator.netBalances(
    sharesByPersonId: sharesByPersonId,
    totalBill: totalBill,
    payerId: payerId,
  );
  final payments = MinimumSettlementCalculator.simplify(balances);

  return payments.map((payment) {
    final from = person(payment.fromPersonId);
    final to = person(payment.toPersonId);
    if (from == null || to == null) return '';
    return BillSplitterStrings.format(
      'settlement_payment_line',
      locale,
      {
        'from': from.name,
        'to': to.name,
        'amount': '$currency ${payment.amount.toStringAsFixed(2)}',
      },
    );
  }).where((line) => line.isNotEmpty).toList(growable: false);
}
