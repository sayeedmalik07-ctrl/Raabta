import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/bill_splitter/data/bill_splitter_currencies.dart';
import 'package:raabta/features/quick_actions/bill_splitter/l10n/bill_splitter_strings.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';
import 'package:raabta/features/quick_actions/bill_splitter/widgets/add_person_sheet.dart';
import 'package:raabta/features/quick_actions/bill_splitter/widgets/minimum_settlement_panel.dart';
import 'package:raabta/features/quick_actions/bill_splitter/widgets/receipt_scan_widget.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/exchange_rate_service.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

import 'bill_splitter/models/recurring_split_group.dart';
import 'bill_splitter/widgets/save_recurring_sheet.dart';

enum _SplitEntryMode { manual, scan }

class BillSplitterScreen extends ConsumerStatefulWidget {
  const BillSplitterScreen({super.key});

  @override
  ConsumerState<BillSplitterScreen> createState() => _BillSplitterScreenState();
}

class _BillSplitterScreenState extends ConsumerState<BillSplitterScreen> {
  final _billController = TextEditingController(text: '');
  double _taxPercent = 0;
  _SplitEntryMode _entryMode = _SplitEntryMode.manual;

  final List<SplitPerson> _people = [];
  String? _payerId;
  final String _selectedCurrency = 'INR';

  double get _billAmount =>
      double.tryParse(_billController.text.replaceAll(',', '')) ?? 0;

  double get _taxAmount => _billAmount * (_taxPercent / 100);

  double get _totalWithTax => _billAmount + _taxAmount;

  double get _perPerson =>
      _people.isEmpty ? 0 : _totalWithTax / _people.length;

  String _toHomeCurrency(String currency, double qar, Map<String, double> rates) {
    final rate = rates[currency] ?? 1.0;
    return BillSplitterCurrencies.formatHomeAmount(currency, qar, rate);
  }

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  Future<void> _showAddPersonSheet() async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final person = await showAddPersonSheet(
      context,
      locale: locale,
      defaultCurrency: _selectedCurrency,
    );
    if (person == null) return;
    setState(() {
      _people.add(person.copyWith(id: person.name));
      _payerId ??= person.name;
    });
  }

  Map<String, double> _manualSharesByPerson() {
    return {
      for (final p in _people) p.stableId: _perPerson,
    };
  }

  String get _effectivePayerId =>
      _payerId != null && _people.any((p) => p.stableId == _payerId)
          ? _payerId!
          : (_people.isNotEmpty ? _people.first.stableId : '');

  void _shareToGroup(Map<String, double> rates) {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    if (_people.isEmpty || _billAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            BillSplitterStrings.t('snack_need_bill_and_person', locale),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1A1035),
        ),
      );
      return;
    }

    final settlementLines = settlementShareLines(
      locale: locale,
      currency: 'QAR',
      people: _people,
      sharesByPersonId: _manualSharesByPerson(),
      totalBill: _totalWithTax,
      payerId: _effectivePayerId,
    );

    final shareData = BillSplitCardData(
      totalQar:   _totalWithTax,
      taxPercent: _taxPercent,
      people: _people.asMap().entries.map((entry) {
        final p = entry.value;
        return SplitPersonRow(
          name: p.name,
          flag: p.flag,
          currency: p.currency,
          formattedHomeAmount: _toHomeCurrency(
            p.currency,
            _perPerson,
            rates,
          ),
          shareQar: _perPerson,
        );
      }).toList(),
      groupName:   null,
      isRecurring: false,
      shareCaption:
          '💳 RAABTA Bill Split\n'
          'Total: QAR ${_totalWithTax.toStringAsFixed(2)}\n'
          'Each person pays: QAR ${_perPerson.toStringAsFixed(2)}\n\n'
          '${_people.map((p) => '${p.flag} ${p.name}: '
            '${_toHomeCurrency(p.currency, _perPerson, rates)}').join('\n')}\n\n'
          '${settlementLines.isEmpty ? '' : '${BillSplitterStrings.t('settlement_share_heading', locale)}\n${settlementLines.join('\n')}\n\n'}'
          'Split bills in any currency with RAABTA\n'
          '${CommonStrings.publicWebsiteHost}',
    );

    ShareCardSheet.show(context, shareData);
  }

  List<SplitMember> _toSplitMembers() {
    return _people.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      return SplitMember(
        id:        'member_$i',
        name:      p.name,
        flag:      p.flag,
        currency:  p.currency,
        shareQar:  _perPerson,
      );
    }).toList();
  }

  void _showSaveRecurringSheet() {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    if (_people.isEmpty || _billAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            BillSplitterStrings.t('snack_need_bill_and_person', locale),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    SaveRecurringSheet.show(
      context,
      totalQar:   _totalWithTax,
      taxPercent: _taxPercent,
      members:    _toSplitMembers(),
      onSaved: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              BillSplitterStrings.t('snack_recurring_saved', locale),
            ),
            backgroundColor: AppColors.successBright,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final ratesAsync = ref.watch(billSplitterRatesProvider);
    final rates = ratesAsync.valueOrNull?.rates ?? kBillSplitterFallbackRates;
    final ratesLabel = ratesAsync.isLoading
        ? BillSplitterStrings.t('rates_loading', locale)
        : ratesAsync.hasError || ratesAsync.value?.isFallback == true
            ? BillSplitterStrings.t('rates_offline', locale)
            : BillSplitterStrings.t('rates_live', locale);
    final ratesLoaded = ratesAsync.hasValue && ratesAsync.value?.isFallback != true;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: BillSplitterStrings.t('screen_title', locale),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ratesLoaded
                        ? AppColors.successBright
                        : ratesAsync.isLoading
                            ? AppColors.accentGold
                            : (AppColors.isLight
                                ? AppColors.textTertiary
                                : Colors.white24),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  ratesLabel,
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EntryModeToggle(
                      locale: locale,
                      mode: _entryMode,
                      onChanged: (mode) => setState(() => _entryMode = mode),
                    ),
                    const SizedBox(height: 16),
                    if (_entryMode == _SplitEntryMode.scan)
                      ReceiptScanWidget(
                        locale: locale,
                        initialPeople: List<SplitPerson>.from(_people),
                      )
                    else
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            BillSplitterStrings.t('total_bill', locale),
                            style: TextStyle(
                              color: AppColors.isLight
                                  ? AppColors.textOnGlassSecondary
                                  : Colors.white.withValues(alpha: 0.45),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'QAR',
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassMuted
                                    : Colors.white.withValues(alpha: 0.4),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _billController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d.]'),
                                  ),
                                ],
                                style: TextStyle(
                                  color: AppColors.isLight
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                    color: AppColors.isLight
                                        ? AppColors.textOnGlassMuted
                                        : Colors.white.withValues(alpha: 0.15),
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: AppColors.isLight
                              ? AppColors.glassBorder
                              : Colors.white10,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              BillSplitterStrings.t('service_tax', locale),
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassSecondary
                                    : Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_taxPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.accentGold,
                            inactiveTrackColor: AppColors.isLight
                                ? AppColors.glassBorder
                                : Colors.white.withValues(alpha: 0.08),
                            thumbColor: AppColors.accentGold,
                            overlayColor:
                                AppColors.accentGold.withValues(alpha: 0.15),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: _taxPercent,
                            min: 0,
                            max: 20,
                            divisions: 20,
                            onChanged: (v) => setState(() => _taxPercent = v),
                          ),
                        ),
                        if (_billAmount > 0) ...[
                          Divider(
                            color: AppColors.isLight
                                ? AppColors.glassBorder
                                : Colors.white10,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TotalChip(
                                label: BillSplitterStrings.t(
                                  'label_total',
                                  locale,
                                ),
                                value:
                                    'QAR ${_totalWithTax.toStringAsFixed(2)}',
                                color: AppColors.isLight
                                    ? AppColors.textPrimary
                                    : Colors.white70,
                              ),
                              _TotalChip(
                                label: BillSplitterStrings.t(
                                  'label_per_person',
                                  locale,
                                ),
                                value:
                                    'QAR ${_perPerson.toStringAsFixed(2)}',
                                color: AppColors.accentGold,
                                bold: true,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _people.isEmpty
                            ? BillSplitterStrings.t('add_people', locale)
                            : BillSplitterStrings.t('people_count', locale)
                                .replaceAll('{count}', '${_people.length}'),
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddPersonSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppColors.accentGold.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: AppColors.accentGold,
                                size: 15,
                              ),
                              SizedBox(width: 4),
                              Text(
                                BillSplitterStrings.t('add_person', locale),
                                style: TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                      onAction: _showAddPersonSheet,
                    ),
                  ..._people.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final homeAmount =
                        _toHomeCurrency(p.currency, _perPerson, rates);
                    final qar = _perPerson.toStringAsFixed(2);
                    final flagColor = BillSplitterCurrencies.colorFor(p.currency);

                    return Dismissible(
                      key: Key('person_$i'),
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
                          Icons.delete_outline,
                          color: AppColors.errorBright,
                        ),
                      ),
                      onDismissed: (_) => setState(() {
                        final removed = _people.removeAt(i);
                        if (_payerId == removed.stableId) {
                          _payerId =
                              _people.isNotEmpty ? _people.first.stableId : null;
                        }
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.isLight
                              ? AppColors.glassBorder.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.isLight
                                ? AppColors.glassBorder
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: flagColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  p.flag,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      color: AppColors.isLight
                                          ? AppColors.textPrimary
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.currency,
                                    style: TextStyle(
                                      color: AppColors.isLight
                                          ? AppColors.textOnGlassMuted
                                          : Colors.white.withValues(alpha: 0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  homeAmount,
                                  style: TextStyle(
                                    color: flagColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'QAR $qar',
                                  style: TextStyle(
                                    color: AppColors.isLight
                                        ? AppColors.textOnGlassMuted
                                        : Colors.white.withValues(alpha: 0.3),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_people.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        BillSplitterStrings.t('swipe_hint', locale),
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassMuted
                              : Colors.white.withValues(alpha: 0.2),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (_entryMode == _SplitEntryMode.manual &&
                      _billAmount > 0 &&
                      _people.length >= 2) ...[
                    const SizedBox(height: 16),
                    MinimumSettlementPanel(
                      locale: locale,
                      currency: 'QAR',
                      people: _people,
                      sharesByPersonId: _manualSharesByPerson(),
                      totalBill: _totalWithTax,
                      payerId: _effectivePayerId,
                      onPayerChanged: (id) => setState(() => _payerId = id),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/my-splits'),
                        icon: const Icon(
                          Icons.repeat_rounded,
                          color: AppColors.sharePurple,
                          size: 16,
                        ),
                        label: Text(
                          BillSplitterStrings.t('my_splits', locale),
                          style: TextStyle(
                            color: AppColors.sharePurple,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          side: const BorderSide(
                            color: AppColors.sharePurple,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showSaveRecurringSheet,
                        icon: const Icon(
                          Icons.bookmark_add_rounded,
                          color: AppColors.accentGold,
                          size: 16,
                        ),
                        label: Text(
                          BillSplitterStrings.t('save_recurring', locale),
                          style: TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          side: const BorderSide(
                            color: AppColors.accentGold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareToGroup(rates),
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      BillSplitterStrings.t('send_to_group', locale),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

}

class _EntryModeToggle extends StatelessWidget {
  const _EntryModeToggle({
    required this.locale,
    required this.mode,
    required this.onChanged,
  });

  final String locale;
  final _SplitEntryMode mode;
  final ValueChanged<_SplitEntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: BillSplitterStrings.t('entry_mode_manual', locale),
            selected: mode == _SplitEntryMode.manual,
            onTap: () => onChanged(_SplitEntryMode.manual),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeChip(
            label: BillSplitterStrings.t('entry_mode_scan', locale),
            selected: mode == _SplitEntryMode.scan,
            onTap: () => onChanged(_SplitEntryMode.scan),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGold.withValues(alpha: 0.15)
              : (AppColors.isLight
                  ? AppColors.glassBorder.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.accentGold.withValues(alpha: 0.5)
                : (AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.accentGold
                : (AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white70),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  const _TotalChip({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textOnGlassMuted
                : Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            fontSize: bold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
