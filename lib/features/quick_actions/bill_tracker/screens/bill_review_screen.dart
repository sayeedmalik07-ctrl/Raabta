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
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/qatar_bill_providers.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_date_formatter.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/presentation/bill_tracker_bill_actions.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_scan_pipeline_service.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_scan_confidence_banner.dart';
import 'package:raabta/providers/visa_providers.dart';

class BillReviewScreen extends ConsumerStatefulWidget {
  const BillReviewScreen({super.key, required this.pipelineResult});

  final BillScanPipelineResult pipelineResult;

  @override
  ConsumerState<BillReviewScreen> createState() => _BillReviewScreenState();
}

class _BillReviewScreenState extends ConsumerState<BillReviewScreen> {
  late String _pickedProvider;
  late String _pickedCategory;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _accountCtrl;
  late final TextEditingController _billTypeCtrl;
  late final TextEditingController _currencyCtrl;
  late DateTime _dueDate;
  DateTime? _billingStart;
  DateTime? _billingEnd;
  bool _isSaving = false;

  String get _locale =>
      AppLocale.normalize(ref.watch(userLanguageProvider));

  @override
  void initState() {
    super.initState();
    final data = widget.pipelineResult.data;
    final matched = _matchProvider(data.provider);
    _pickedProvider = matched.name;
    _pickedCategory = data.billType?.trim().isNotEmpty == true
        ? data.billType!.trim()
        : matched.category;
    _amountCtrl = TextEditingController(
      text: data.amount != null ? data.amount!.toStringAsFixed(2) : '',
    );
    _accountCtrl = TextEditingController(text: data.accountNumber ?? '');
    _billTypeCtrl = TextEditingController(text: _pickedCategory);
    _currencyCtrl = TextEditingController(
      text: (data.currency?.trim().toUpperCase().isNotEmpty == true)
          ? data.currency!.trim().toUpperCase()
          : 'QAR',
    );
    _dueDate = data.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _billingStart = data.billingPeriodStart;
    _billingEnd = data.billingPeriodEnd;
  }

  QatarBillProvider _matchProvider(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw.toLowerCase() == 'unknown') {
      return QatarBillProviders.kahramaa;
    }
    return QatarBillProviders.byName(raw) ??
        QatarBillProviders.all.firstWhere(
          (p) =>
              p.name.toLowerCase().contains(raw.toLowerCase()) ||
              raw.toLowerCase().contains(p.name.toLowerCase()),
          orElse: () => QatarBillProviders.other,
        );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accountCtrl.dispose();
    _billTypeCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  void _applyProvider(QatarBillProvider provider) {
    setState(() {
      _pickedProvider = provider.name;
      if (_billTypeCtrl.text.trim().isEmpty ||
          _billTypeCtrl.text == _pickedCategory) {
        _billTypeCtrl.text = provider.category;
      }
      _pickedCategory = _billTypeCtrl.text.trim();
    });
  }

  Future<void> _pickDate({
    required bool isDueDate,
    required bool isStart,
  }) async {
    final initial = isDueDate
        ? _dueDate
        : (isStart ? _billingStart : _billingEnd) ??
            DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.sharePurple,
            surface: AppColors.surfaceElevated,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isDueDate) {
        _dueDate = picked;
      } else if (isStart) {
        _billingStart = picked;
      } else {
        _billingEnd = picked;
      }
    });
  }

  Future<void> _save() async {
    final amt = double.tryParse(_amountCtrl.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(BillTrackerStrings.t('invalid_amount_snack', _locale)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final normalizedProvider = QatarBillProviders.normalizeStoredProviderName(
      _pickedProvider,
    );
    final providerMeta =
        QatarBillProviders.byName(normalizedProvider) ?? QatarBillProviders.other;
    final category = _billTypeCtrl.text.trim().isNotEmpty
        ? _billTypeCtrl.text.trim()
        : providerMeta.category;

    await BillTrackerBillActions.addBill(
      ref,
      context: context,
      provider: normalizedProvider,
      category: category,
      emoji: providerMeta.emoji,
      amount: amt,
      dueDate: _dueDate,
      accountNumber: _accountCtrl.text.trim(),
      billingPeriodStart: _billingStart,
      billingPeriodEnd: _billingEnd,
      currency: _currencyCtrl.text.trim().isNotEmpty
          ? _currencyCtrl.text.trim().toUpperCase()
          : 'QAR',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    context.go('/bill-tracker');
  }

  Widget _missingFieldNote(String labelKey) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        BillTrackerStrings.format('review_field_confirm', _locale, {
          'field': BillTrackerStrings.t(labelKey, _locale),
        }),
        style: TextStyle(
          color: AppColors.accentGold.withValues(alpha: 0.9),
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.pipelineResult.data;
    final isRtl = AppLocale.isRtl(_locale);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: BillTrackerStrings.t('review_title', _locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BillScanConfidenceBanner(data: data, locale: _locale),
              if (data.isLowConfidence) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  BillTrackerStrings.t('review_low_confidence', _locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                BillTrackerStrings.t('label_provider', _locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white54,
                ),
              ),
              const SizedBox(height: 6),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                borderRadius: 12,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _pickedProvider,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    style: TextStyle(
                      color: AppColors.isLight
                          ? AppColors.textPrimary
                          : Colors.white,
                      fontSize: 14,
                    ),
                    items: QatarBillProviders.all
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.name,
                            child: Text('${p.emoji}  ${p.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final p = QatarBillProviders.all
                          .firstWhere((item) => item.name == v);
                      _applyProvider(p);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassTextField(
                controller: _billTypeCtrl,
                label: BillTrackerStrings.t('review_bill_type', _locale),
                hint: BillTrackerStrings.t('review_bill_type_hint', _locale),
              ),
              if (data.billType == null && data.isLowConfidence)
                _missingFieldNote('review_bill_type'),
              const SizedBox(height: AppSpacing.md),
              GlassTextField(
                controller: _amountCtrl,
                label: BillTrackerStrings.t('label_amount', _locale),
                hint: BillTrackerStrings.t('hint_amount', _locale),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
              ),
              if (data.amount == null && data.isLowConfidence)
                _missingFieldNote('label_amount'),
              const SizedBox(height: AppSpacing.md),
              GlassTextField(
                controller: _currencyCtrl,
                label: BillTrackerStrings.t('review_currency', _locale),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                BillTrackerStrings.t('label_due_date', _locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white54,
                ),
              ),
              const SizedBox(height: 6),
              _DateRow(
                label: BillTrackerDateFormatter.formatPickerDate(
                  _dueDate,
                  _locale,
                ),
                onTap: () => _pickDate(isDueDate: true, isStart: false),
              ),
              if (data.dueDate == null && data.isLowConfidence)
                _missingFieldNote('label_due_date'),
              const SizedBox(height: AppSpacing.md),
              Text(
                BillTrackerStrings.t('review_billing_period', _locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white54,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _DateRow(
                      label: _billingStart != null
                          ? BillTrackerDateFormatter.formatPickerDate(
                              _billingStart!,
                              _locale,
                            )
                          : BillTrackerStrings.t(
                              'review_period_start',
                              _locale,
                            ),
                      onTap: () => _pickDate(isDueDate: false, isStart: true),
                      muted: _billingStart == null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DateRow(
                      label: _billingEnd != null
                          ? BillTrackerDateFormatter.formatPickerDate(
                              _billingEnd!,
                              _locale,
                            )
                          : BillTrackerStrings.t('review_period_end', _locale),
                      onTap: () => _pickDate(isDueDate: false, isStart: false),
                      muted: _billingEnd == null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GlassTextField(
                controller: _accountCtrl,
                hint: BillTrackerStrings.t('hint_account', _locale),
                icon: Icons.tag_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: BillTrackerStrings.t('review_save', _locale),
                expand: true,
                accentColor: AppColors.sharePurple,
                icon: Icons.check_rounded,
                onPressed: _isSaving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        borderRadius: 12,
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.sharePurple,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: muted
                      ? (AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white38)
                      : (AppColors.isLight
                          ? AppColors.textPrimary
                          : Colors.white),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
