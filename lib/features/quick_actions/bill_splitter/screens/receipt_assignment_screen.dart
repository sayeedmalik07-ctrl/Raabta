import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/bill_splitter/data/bill_splitter_currencies.dart';
import 'package:raabta/features/quick_actions/bill_splitter/domain/receipt_split_calculator.dart';
import 'package:raabta/features/quick_actions/bill_splitter/l10n/bill_splitter_strings.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/receipt_split_draft.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';
import 'package:raabta/features/quick_actions/bill_splitter/widgets/add_person_sheet.dart';
import 'package:raabta/features/quick_actions/bill_splitter/widgets/minimum_settlement_panel.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/exchange_rate_service.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

class ReceiptAssignmentScreen extends ConsumerStatefulWidget {
  const ReceiptAssignmentScreen({super.key, required this.draft});

  final ReceiptSplitDraft draft;

  @override
  ConsumerState<ReceiptAssignmentScreen> createState() =>
      _ReceiptAssignmentScreenState();
}

class _ReceiptAssignmentScreenState
    extends ConsumerState<ReceiptAssignmentScreen> {
  late List<SplitPerson> _people;
  late Map<int, Set<String>> _assignments;
  ReceiptChargeSplitMode _chargeMode = ReceiptChargeSplitMode.proportional;
  String? _payerId;

  @override
  void initState() {
    super.initState();
    _people = widget.draft.people
        .map((p) => p.copyWith(id: p.id ?? p.name))
        .toList(growable: true);
    _assignments = {
      for (var i = 0; i < widget.draft.receipt.lineItems.length; i++)
        i: <String>{},
    };
    if (_people.isNotEmpty) {
      _payerId = _people.first.stableId;
    }
  }

  Map<String, double> _sharesByPerson(List<ReceiptSplitPersonTotal> totals) {
    return {for (final row in totals) row.person.stableId: row.totalQar};
  }

  String _effectivePayerId() {
    if (_payerId != null && _people.any((p) => p.stableId == _payerId)) {
      return _payerId!;
    }
    return _people.isNotEmpty ? _people.first.stableId : '';
  }

  Future<void> _addPerson(String locale) async {
    final person = await showAddPersonSheet(context, locale: locale);
    if (person == null) return;
    setState(() {
      _people.add(person.copyWith(id: person.name));
      _payerId ??= person.name;
    });
  }

  void _toggleAssignee(int itemIndex, String personId) {
    setState(() {
      final set = _assignments[itemIndex] ?? {};
      if (set.contains(personId)) {
        set.remove(personId);
      } else {
        set.add(personId);
      }
      _assignments[itemIndex] = set;
    });
  }

  List<ReceiptSplitPersonTotal> _totals() {
    return ReceiptSplitCalculator.compute(
      people: _people,
      items: widget.draft.receipt.lineItems,
      assignmentsByItemIndex: _assignments,
      tax: widget.draft.receipt.tax,
      serviceCharge: widget.draft.receipt.serviceCharge,
      tip: widget.draft.receipt.tip,
      chargeMode: _chargeMode,
    );
  }

  double get _grandTotal {
    final receipt = widget.draft.receipt;
    final computed = ReceiptSplitCalculator.lineItemsSubtotal(
          receipt.lineItems,
        ) +
        ReceiptSplitCalculator.chargesTotal(
          tax: receipt.tax,
          serviceCharge: receipt.serviceCharge,
          tip: receipt.tip,
        );
    return receipt.total ?? computed;
  }

  void _share(String locale, Map<String, double> rates) {
    if (_people.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            BillSplitterStrings.t('snack_need_bill_and_person', locale),
          ),
        ),
      );
      return;
    }

    final totals = _totals();
    final currency = widget.draft.billCurrency;
    final settlementLines = settlementShareLines(
      locale: locale,
      currency: currency,
      people: _people,
      sharesByPersonId: _sharesByPerson(totals),
      totalBill: _grandTotal,
      payerId: _effectivePayerId(),
    );

    ShareCardSheet.show(
      context,
      BillSplitCardData(
        totalQar: _grandTotal,
        taxPercent: 0,
        people: totals.map((row) {
          final rate = rates[row.person.currency] ?? 1.0;
          return SplitPersonRow(
            name: row.person.name,
            flag: row.person.flag,
            currency: row.person.currency,
            formattedHomeAmount: BillSplitterCurrencies.formatHomeAmount(
              row.person.currency,
              row.totalQar,
              rate,
            ),
            shareQar: row.totalQar,
          );
        }).toList(),
        isRecurring: false,
        shareCaption:
            '💳 RAABTA Bill Split (Receipt)\n'
            'Total: $currency ${_grandTotal.toStringAsFixed(2)}\n\n'
            '${totals.map((r) => '${r.person.flag} ${r.person.name}: '
                '$currency ${r.totalQar.toStringAsFixed(2)}').join('\n')}\n\n'
            '${settlementLines.isEmpty ? '' : '${BillSplitterStrings.t('settlement_share_heading', locale)}\n${settlementLines.join('\n')}\n\n'}'
            '${CommonStrings.publicWebsiteHost}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final ratesAsync = ref.watch(billSplitterRatesProvider);
    final rates = ratesAsync.valueOrNull?.rates ?? kBillSplitterFallbackRates;
    final items = widget.draft.receipt.lineItems;
    final currency = widget.draft.billCurrency;
    final totals = _people.isEmpty ? <ReceiptSplitPersonTotal>[] : _totals();

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: BillSplitterStrings.t('receipt_assign_title', locale),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BillSplitterStrings.t('receipt_assign_instructions', locale),
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textOnGlassSecondary
                            : Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _people.isEmpty
                              ? BillSplitterStrings.t('add_people', locale)
                              : BillSplitterStrings.format(
                                  'people_count',
                                  locale,
                                  {'count': '${_people.length}'},
                                ),
                          style: AppTypography.headline2.copyWith(
                            color: AppColors.isLight
                                ? AppColors.textPrimary
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _addPerson(locale),
                          icon: const Icon(Icons.add, color: AppColors.accentGold),
                          label: Text(
                            BillSplitterStrings.t('add_person', locale),
                            style: const TextStyle(color: AppColors.accentGold),
                          ),
                        ),
                      ],
                    ),
                    if (_people.isEmpty)
                      GlassEmptyState(
                        icon: Icons.groups_outlined,
                        title: BillSplitterStrings.t(
                          'empty_people_title',
                          locale,
                        ),
                        description: BillSplitterStrings.t(
                          'empty_people_description',
                          locale,
                        ),
                        actionLabel:
                            BillSplitterStrings.t('add_person', locale),
                        onAction: () => _addPerson(locale),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _chargeMode == ReceiptChargeSplitMode.proportional
                            ? BillSplitterStrings.t(
                                'receipt_prorate_charges',
                                locale,
                              )
                            : BillSplitterStrings.t(
                                'receipt_equal_charges',
                                locale,
                              ),
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        BillSplitterStrings.t('receipt_charge_mode_hint', locale),
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassMuted
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                      value: _chargeMode == ReceiptChargeSplitMode.proportional,
                      activeThumbColor: AppColors.accentGold,
                      onChanged: (v) {
                        setState(() {
                          _chargeMode = v
                              ? ReceiptChargeSplitMode.proportional
                              : ReceiptChargeSplitMode.equalAmongAll;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final assignees = _assignments[index] ?? {};
                      return GlassContainer(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      color: AppColors.isLight
                                          ? AppColors.textPrimary
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$currency ${item.lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _people.map((person) {
                                final selected =
                                    assignees.contains(person.stableId);
                                return _PersonAssignChip(
                                  label: '${person.flag} ${person.name}',
                                  selected: selected,
                                  onTap: () =>
                                      _toggleAssignee(index, person.stableId),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (totals.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        BillSplitterStrings.t('receipt_settlement_title', locale),
                        style: AppTypography.headline2.copyWith(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...totals.map((row) {
                        final rate = rates[row.person.currency] ?? 1.0;
                        final home = BillSplitterCurrencies.formatHomeAmount(
                          row.person.currency,
                          row.totalQar,
                          rate,
                        );
                        return GlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          borderRadius: 12,
                          child: Row(
                            children: [
                              Text(row.person.flag,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  row.person.name,
                                  style: TextStyle(
                                    color: AppColors.isLight
                                        ? AppColors.textPrimary
                                        : Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    home,
                                    style: TextStyle(
                                      color: BillSplitterCurrencies.colorFor(
                                        row.person.currency,
                                      ),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '$currency ${row.totalQar.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: AppColors.isLight
                                          ? AppColors.textOnGlassMuted
                                          : Colors.white.withValues(alpha: 0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.lg),
                      MinimumSettlementPanel(
                        locale: locale,
                        currency: currency,
                        people: _people,
                        sharesByPersonId: _sharesByPerson(totals),
                        totalBill: _grandTotal,
                        payerId: _effectivePayerId(),
                        onPayerChanged: (id) => setState(() => _payerId = id),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: GlassPrimaryButton(
                label: BillSplitterStrings.t('send_to_group', locale),
                expand: true,
                accentColor: const Color(0xFF25D366),
                icon: Icons.share_rounded,
                onPressed: _people.isEmpty ? null : () => _share(locale, rates),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonAssignChip extends StatelessWidget {
  const _PersonAssignChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? AppColors.accentGold
        : (AppColors.isLight
            ? AppColors.textOnGlassSecondary
            : Colors.white.withValues(alpha: 0.35));
    return GlassCard(
      onTap: onTap,
      height: 40,
      borderRadius: AppSpacing.radiusFull,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      glowColor: selected
          ? AppColors.accentGold
          : (AppColors.isLight ? AppColors.glassBorder : Colors.white24),
      glowIntensity: selected ? 0.2 : 0.05,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
