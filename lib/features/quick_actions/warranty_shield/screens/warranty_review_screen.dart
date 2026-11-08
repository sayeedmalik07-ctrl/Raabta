import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/warranty_categories.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

class WarrantyReviewScreen extends ConsumerStatefulWidget {
  const WarrantyReviewScreen({
    super.key,
    required this.initialExtraction,
    required this.sourceImagePath,
  });

  final WarrantyExtractionResult initialExtraction;
  final String sourceImagePath;

  @override
  ConsumerState<WarrantyReviewScreen> createState() =>
      _WarrantyReviewScreenState();
}

class _WarrantyReviewScreenState extends ConsumerState<WarrantyReviewScreen> {
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _retailerController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late String _category;
  late String _currency;
  late DateTime _purchaseDate;
  late DateTime _expiryDate;
  bool _expiryManuallySet = false;

  @override
  void initState() {
    super.initState();
    final e = widget.initialExtraction;
    _nameController = TextEditingController(text: e.itemName ?? '');
    _brandController = TextEditingController(text: e.brand ?? '');
    _retailerController = TextEditingController(text: e.retailer ?? '');
    _priceController = TextEditingController(
      text: e.price != null ? e.price!.toStringAsFixed(2) : '',
    );
    _durationController = TextEditingController(
      text: e.warrantyDurationMonths?.toString() ?? '',
    );
    _category = _normalizeCategory(e.category);
    _currency = (e.currency?.trim().toUpperCase().isNotEmpty == true)
        ? e.currency!.trim().toUpperCase()
        : 'QAR';
    _purchaseDate = e.purchaseDate ?? DateTime.now();
    _expiryDate = e.warrantyExpiryDate ??
        (e.warrantyDurationMonths != null
            ? _addMonths(_purchaseDate, e.warrantyDurationMonths!)
            : _purchaseDate.add(const Duration(days: 365)));
    _expiryManuallySet = e.warrantyExpiryDate != null;
  }

  String _normalizeCategory(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'General';
    final trimmed = raw.trim();
    for (final code in WarrantyCategories.codes) {
      if (code.toLowerCase() == trimmed.toLowerCase()) return code;
    }
    return 'General';
  }

  DateTime _addMonths(DateTime from, int months) {
    return DateTime(from.year, from.month + months, from.day);
  }

  void _syncExpiryFromDuration() {
    if (_expiryManuallySet) return;
    final months = int.tryParse(_durationController.text.trim());
    if (months != null && months > 0) {
      setState(() => _expiryDate = _addMonths(_purchaseDate, months));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _retailerController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<String> _persistReceiptImage() async {
    final sourcePath = widget.sourceImagePath;
    if (sourcePath.isEmpty) return '';
    final source = File(sourcePath);
    if (!await source.exists()) return '';

    final dir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${dir.path}/warranty_receipts');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final dest = File(
      '${receiptsDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await source.copy(dest.path);
    return dest.path;
  }

  Future<void> _save(String locale) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(WarrantyStrings.t('warr_review_need_product', locale)),
        ),
      );
      return;
    }

    if (_expiryDate.isBefore(_purchaseDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(WarrantyStrings.t('warr_review_expiry_before', locale)),
        ),
      );
      return;
    }

    final savedPath = await _persistReceiptImage();
    if (!mounted) return;

    final item = WarrantyItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? WarrantyStrings.t('warr_fallback_brand', locale)
          : _brandController.text.trim(),
      retailer: _retailerController.text.trim(),
      category: _category,
      purchaseDate: _purchaseDate,
      expiryDate: _expiryDate,
      purchasePriceQar: double.tryParse(_priceController.text.trim()) ?? 0,
      currency: _currency,
      receiptImagePath: savedPath,
    );

    context.pop(item);
  }

  Future<void> _pickDate({
    required bool isPurchase,
    required String locale,
  }) async {
    final initial = isPurchase ? _purchaseDate : _expiryDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2015),
      lastDate: DateTime(2045),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.successBright,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isPurchase) {
        _purchaseDate = picked;
        _syncExpiryFromDuration();
      } else {
        _expiryDate = picked;
        _expiryManuallySet = true;
      }
    });
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get _showLowConfidenceNote {
    final e = widget.initialExtraction;
    return e.isLowConfidence || e.needsExpiryConfirmation;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final rtl = AppLocale.isRtl(locale);
    final e = widget.initialExtraction;

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: WarrantyStrings.t('warr_review_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            if (_showLowConfidenceNote) ...[
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor: AppColors.accentGold,
                glowIntensity: 0.12,
                backgroundColor: AppColors.accentGold.withValues(alpha: 0.08),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.accentGold,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        e.isLowConfidence
                            ? WarrantyStrings.t(
                                'warr_review_low_confidence',
                                locale,
                              )
                            : WarrantyStrings.t(
                                'warr_review_missing_expiry',
                                locale,
                              ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _field(
              label: WarrantyStrings.t('warr_hint_product', locale),
              controller: _nameController,
            ),
            const SizedBox(height: AppSpacing.sm),
            _field(
              label: WarrantyStrings.t('warr_hint_brand', locale),
              controller: _brandController,
            ),
            const SizedBox(height: AppSpacing.sm),
            _field(
              label: WarrantyStrings.t('warr_field_retailer', locale),
              controller: _retailerController,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _category,
              dropdownColor: AppColors.surfaceElevated,
              decoration: _inputDecoration(
                WarrantyStrings.t('warr_field_category', locale),
              ),
              items: WarrantyCategories.codes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        WarrantyStrings.categoryLabel(c, locale),
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _field(
              label: WarrantyStrings.t('warr_hint_price', locale),
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            if (_currency != 'QAR') ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                WarrantyStrings.format(
                  'warr_review_currency_note',
                  locale,
                  params: {'currency': _currency},
                ),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _field(
              label: WarrantyStrings.t('warr_field_duration_months', locale),
              controller: _durationController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _syncExpiryFromDuration(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _dateRow(
              label: WarrantyStrings.t('warr_label_purchase_date', locale),
              value: _fmt(_purchaseDate),
              onTap: () => _pickDate(isPurchase: true, locale: locale),
            ),
            const SizedBox(height: AppSpacing.sm),
            _dateRow(
              label: WarrantyStrings.t('warr_label_expiry', locale),
              value: _fmt(_expiryDate),
              onTap: () => _pickDate(isPurchase: false, locale: locale),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: WarrantyStrings.t('warr_review_save', locale),
              onPressed: () => _save(locale),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.isLight
            ? AppColors.textOnGlassSecondary
            : Colors.white.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: AppColors.isLight
          ? AppColors.glassSurface
          : Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.isLight
              ? AppColors.glassBorder
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.successBright),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
      ),
      decoration: _inputDecoration(label),
    );
  }

  Widget _dateRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.isLight
              ? AppColors.glassSurface
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.isLight
                ? AppColors.glassBorder
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassSecondary
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.calendar_today,
              color: AppColors.successBright,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
