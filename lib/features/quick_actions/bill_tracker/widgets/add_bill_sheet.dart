import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/qatar_bill_providers.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_date_formatter.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/bill_scan_widget.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';

typedef AddBillSubmit = Future<void> Function({
  required String provider,
  required String category,
  required String emoji,
  required double amount,
  required DateTime dueDate,
  String accountNumber,
});

class AddBillSheet extends StatefulWidget {
  const AddBillSheet({
    super.key,
    required this.locale,
    required this.onSubmit,
  });

  final String locale;
  final AddBillSubmit onSubmit;

  static Future<void> show(
    BuildContext context, {
    required String locale,
    required AddBillSubmit onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddBillSheet(locale: locale, onSubmit: onSubmit),
    );
  }

  @override
  State<AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends State<AddBillSheet> {
  late String _pickedProvider;
  late String _pickedCategory;
  late String _pickedEmoji;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _accountCtrl;
  late DateTime _dueDate;

  String get _s => widget.locale;

  @override
  void initState() {
    super.initState();
    final defaultProvider = QatarBillProviders.kahramaa;
    _pickedProvider = defaultProvider.name;
    _pickedCategory = defaultProvider.category;
    _pickedEmoji = defaultProvider.emoji;
    _amountCtrl = TextEditingController();
    _accountCtrl = TextEditingController();
    _dueDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  void _applyProvider(QatarBillProvider provider) {
    _pickedProvider = provider.name;
    _pickedCategory = provider.category;
    _pickedEmoji = provider.emoji;
  }

  void _normalizeDraftProvider(String? raw) {
    if (raw == null || raw.isEmpty) return;
    final resolved = QatarBillProviders.byName(raw);
    if (resolved != null) {
      _applyProvider(resolved);
      return;
    }
    _pickedProvider = raw;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (ctx, setSheet) => DraftAwareSheet(
        formId: DraftBoxKeys.billTrackerAdd,
        controllers: [_amountCtrl, _accountCtrl],
        serialize: () => {
          'provider': _pickedProvider,
          'category': _pickedCategory,
          'emoji': _pickedEmoji,
          'amount': _amountCtrl.text,
          'account': _accountCtrl.text,
          'dueDate': _dueDate.toIso8601String(),
        },
        applyDraft: (data) {
          setSheet(() {
            _normalizeDraftProvider(data['provider']?.toString());
            _pickedCategory =
                data['category']?.toString() ?? _pickedCategory;
            _pickedEmoji = data['emoji']?.toString() ?? _pickedEmoji;
            _amountCtrl.text = data['amount']?.toString() ?? '';
            _accountCtrl.text = data['account']?.toString() ?? '';
            final raw = data['dueDate']?.toString();
            if (raw != null) {
              _dueDate = DateTime.tryParse(raw) ?? _dueDate;
            }
          });
        },
        builder: (context, draft) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.isLight
                          ? AppColors.glassBorderBright
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  BillTrackerStrings.t('add_bill_title', _s),
                  style: AppTypography.headline2.copyWith(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                BillScanWidget(
                  locale: _s,
                  onPipelineComplete: (_) {
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.isLight
                            ? AppColors.glassBorder
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        BillTrackerStrings.t('or_fill_manually', _s),
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textOnGlassMuted
                              : Colors.white.withValues(alpha: 0.3),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.isLight
                            ? AppColors.glassBorder
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  BillTrackerStrings.t('label_provider', _s),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassSecondary
                        : Colors.white54,
                    fontWeight: FontWeight.w600,
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
                            .firstWhere((p) => p.name == v);
                        setSheet(() => _applyProvider(p));
                        draft.notifyChanged();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _amountCtrl,
                  label: BillTrackerStrings.t('label_amount', _s),
                  hint: BillTrackerStrings.t('hint_amount', _s),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (_) => draft.notifyChanged(),
                ),
                const SizedBox(height: 16),
                Text(
                  BillTrackerStrings.t('label_due_date', _s),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassSecondary
                        : Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: _dueDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
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
                    if (picked != null) {
                      setSheet(() => _dueDate = picked);
                      draft.notifyChanged();
                    }
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    borderRadius: 12,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.sharePurple,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          BillTrackerDateFormatter.formatPickerDate(
                            _dueDate,
                            _s,
                          ),
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textPrimary
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _accountCtrl,
                  hint: BillTrackerStrings.t('hint_account', _s),
                  icon: Icons.tag_rounded,
                  onChanged: (_) => draft.notifyChanged(),
                ),
                const SizedBox(height: 24),
                GlassPrimaryButton(
                  label: BillTrackerStrings.t('add_bill_button', _s),
                  expand: true,
                  accentColor: AppColors.sharePurple,
                  icon: Icons.add_rounded,
                  onPressed: () async {
                    final amt = double.tryParse(_amountCtrl.text.trim());
                    if (amt == null || amt <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            BillTrackerStrings.t('invalid_amount_snack', _s),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final normalizedProvider =
                        QatarBillProviders.normalizeStoredProviderName(
                      _pickedProvider,
                    );
                    final providerMeta = QatarBillProviders.byName(
                          normalizedProvider,
                        ) ??
                        QatarBillProviders.other;
                    Navigator.pop(ctx);
                    await widget.onSubmit(
                      provider: normalizedProvider,
                      category: providerMeta.category,
                      emoji: providerMeta.emoji,
                      amount: amt,
                      dueDate: _dueDate,
                      accountNumber: _accountCtrl.text.trim(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
