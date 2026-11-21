import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/bill_splitter/data/bill_splitter_currencies.dart';
import 'package:raabta/features/quick_actions/bill_splitter/l10n/bill_splitter_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/receipt_split_draft.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const ReceiptReviewScreen({
    super.key,
    required this.initialExtraction,
    required this.people,
  });

  final ReceiptLineItemsExtractionResult initialExtraction;
  final List<SplitPerson> people;

  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  late List<ReceiptLineItemRow> _items;
  late TextEditingController _merchantController;
  late TextEditingController _subtotalController;
  late TextEditingController _taxController;
  late TextEditingController _serviceController;
  late TextEditingController _tipController;
  late TextEditingController _totalController;
  late String _billCurrency;

  @override
  void initState() {
    super.initState();
    final e = widget.initialExtraction;
    _items = e.lineItems.map((i) => i.copyWith()).toList(growable: true);
    _merchantController = TextEditingController(text: e.merchant ?? '');
    _subtotalController =
        TextEditingController(text: _amountText(e.subtotal));
    _taxController = TextEditingController(text: _amountText(e.tax));
    _serviceController =
        TextEditingController(text: _amountText(e.serviceCharge));
    _tipController = TextEditingController(text: _amountText(e.tip));
    _totalController = TextEditingController(text: _amountText(e.total));
    _billCurrency = _resolveBillCurrency(e.currency);
  }

  String _resolveBillCurrency(String? extracted) {
    final raw = extracted?.trim().toUpperCase();
    if (raw == null || raw.isEmpty) return 'QAR';
    if (raw == 'QAR' || BillSplitterCurrencies.codes.contains(raw)) {
      return raw;
    }
    return 'QAR';
  }

  String _amountText(double? value) =>
      value == null ? '' : value.toStringAsFixed(2);

  double? _parseAmount(TextEditingController c) {
    final raw = c.text.replaceAll(',', '').trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _subtotalController.dispose();
    _taxController.dispose();
    _serviceController.dispose();
    _tipController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _continueToAssignment(String locale) {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(BillSplitterStrings.t('receipt_need_items', locale)),
        ),
      );
      return;
    }

    final receipt = ReceiptLineItemsExtractionResult(
      merchant: _merchantController.text.trim().isEmpty
          ? null
          : _merchantController.text.trim(),
      date: widget.initialExtraction.date,
      currency: _billCurrency,
      lineItems: _items,
      subtotal: _parseAmount(_subtotalController),
      tax: _parseAmount(_taxController),
      serviceCharge: _parseAmount(_serviceController),
      tip: _parseAmount(_tipController),
      total: _parseAmount(_totalController),
      confidence: widget.initialExtraction.confidence,
    );

    context.push(
      '/bill-splitter/receipt/assign',
      extra: ReceiptSplitDraft(
        receipt: receipt,
        people: widget.people,
        billCurrency: _billCurrency,
      ),
    );
  }

  Future<void> _confirmCurrencyIfNeeded(String locale) async {
    final extracted = widget.initialExtraction.currency?.trim().toUpperCase();
    if (extracted == null ||
        extracted.isEmpty ||
        extracted == _billCurrency) {
      _continueToAssignment(locale);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(
          BillSplitterStrings.t('receipt_currency_confirm_title', locale),
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textPrimary
                : Colors.white,
          ),
        ),
        content: Text(
          BillSplitterStrings.format(
            'receipt_currency_confirm_body',
            locale,
            {
              'detected': extracted,
              'selected': _billCurrency,
            },
          ),
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textOnGlassSecondary
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(BillSplitterStrings.t('receipt_currency_change', locale)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(BillSplitterStrings.t('receipt_currency_keep', locale)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _continueToAssignment(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final extraction = widget.initialExtraction;
    final showWarning = extraction.shouldShowReviewWarning;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: BillSplitterStrings.t('receipt_review_title', locale),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showWarning)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          BillSplitterStrings.t(
                            'receipt_low_confidence_note',
                            locale,
                          ),
                          style: TextStyle(
                            color: AppColors.accentGold.withValues(alpha: 0.95),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            BillSplitterStrings.t('receipt_merchant', locale),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.isLight
                                  ? AppColors.textOnGlassMuted
                                  : Colors.white54,
                            ),
                          ),
                          TextField(
                            controller: _merchantController,
                            style: TextStyle(
                              color: AppColors.isLight
                                  ? AppColors.textPrimary
                                  : Colors.white,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            BillSplitterStrings.t(
                              'receipt_bill_currency',
                              locale,
                            ),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.isLight
                                  ? AppColors.textOnGlassMuted
                                  : Colors.white54,
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: ['QAR', ...BillSplitterCurrencies.codes]
                                      .contains(_billCurrency)
                                  ? _billCurrency
                                  : 'QAR',
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceElevated,
                              style: TextStyle(
                                color: AppColors.isLight
                                    ? AppColors.textPrimary
                                    : Colors.white,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'QAR',
                                  child: Text('🇶🇦 QAR'),
                                ),
                                ...BillSplitterCurrencies.codes.map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      '${BillSplitterCurrencies.flagFor(c)} $c',
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _billCurrency = v);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      BillSplitterStrings.t('receipt_line_items', locale),
                      style: AppTypography.headline2.copyWith(
                        color: AppColors.isLight
                            ? AppColors.textPrimary
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._items.asMap().entries.map(
                          (entry) => _LineItemEditor(
                            key: ValueKey('item_${entry.key}'),
                            item: entry.value,
                            locale: locale,
                            onChanged: (updated) {
                              setState(() => _items[entry.key] = updated);
                            },
                            onRemove: _items.length <= 1
                                ? null
                                : () {
                                    setState(() => _items.removeAt(entry.key));
                                  },
                          ),
                        ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _items.add(
                            const ReceiptLineItemRow(
                              name: '',
                              price: 0,
                              quantity: 1,
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add, color: AppColors.accentGold),
                      label: Text(
                        BillSplitterStrings.t('receipt_add_item', locale),
                        style: const TextStyle(color: AppColors.accentGold),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AmountField(
                      label: BillSplitterStrings.t('receipt_subtotal', locale),
                      controller: _subtotalController,
                    ),
                    _AmountField(
                      label: BillSplitterStrings.t('receipt_tax', locale),
                      controller: _taxController,
                    ),
                    _AmountField(
                      label:
                          BillSplitterStrings.t('receipt_service_charge', locale),
                      controller: _serviceController,
                    ),
                    _AmountField(
                      label: BillSplitterStrings.t('receipt_tip', locale),
                      controller: _tipController,
                    ),
                    _AmountField(
                      label: BillSplitterStrings.t('label_total', locale),
                      controller: _totalController,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: GlassPrimaryButton(
                label: BillSplitterStrings.t('receipt_continue', locale),
                expand: true,
                accentColor: AppColors.accentGold,
                onPressed: () => _confirmCurrencyIfNeeded(locale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItemEditor extends StatefulWidget {
  const _LineItemEditor({
    super.key,
    required this.item,
    required this.locale,
    required this.onChanged,
    this.onRemove,
  });

  final ReceiptLineItemRow item;
  final String locale;
  final ValueChanged<ReceiptLineItemRow> onChanged;
  final VoidCallback? onRemove;

  @override
  State<_LineItemEditor> createState() => _LineItemEditorState();
}

class _LineItemEditorState extends State<_LineItemEditor> {
  late TextEditingController _name;
  late TextEditingController _price;
  late TextEditingController _qty;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item.name);
    _price = TextEditingController(
      text: widget.item.price.toStringAsFixed(2),
    );
    _qty = TextEditingController(
      text: widget.item.quantity.toStringAsFixed(
        widget.item.quantity.truncateToDouble() == widget.item.quantity ? 0 : 1,
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      ReceiptLineItemRow(
        name: _name.text.trim(),
        price: double.tryParse(_price.text.replaceAll(',', '')) ?? 0,
        quantity: double.tryParse(_qty.text.replaceAll(',', '')) ?? 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  onChanged: (_) => _emit(),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: BillSplitterStrings.t(
                      'receipt_item_name_hint',
                      widget.locale,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: Icon(
                    Icons.close,
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white38,
                    size: 18,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _price,
                  onChanged: (_) => _emit(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: const TextStyle(color: AppColors.accentGold),
                  decoration: InputDecoration(
                    labelText: BillSplitterStrings.t(
                      'receipt_item_price',
                      widget.locale,
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: _qty,
                  onChanged: (_) => _emit(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: BillSplitterStrings.t(
                      'receipt_item_qty',
                      widget.locale,
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        borderRadius: 12,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassSecondary
                      : Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textPrimary
                      : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
