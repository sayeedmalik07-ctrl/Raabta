import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/warranty_categories.dart';
import 'package:raabta/features/quick_actions/warranty_shield/data/warranty_storage.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/features/quick_actions/warranty_shield/services/warranty_notification_service.dart';
import 'package:raabta/features/quick_actions/warranty_shield/widgets/repair_shop_suggestions.dart';
import 'package:raabta/features/quick_actions/warranty_shield/widgets/warranty_scan_widget.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

enum _WarrantyEntryMode { manual, scan }

class WarrantyShieldScreen extends ConsumerStatefulWidget {
  const WarrantyShieldScreen({super.key});

  @override
  ConsumerState<WarrantyShieldScreen> createState() =>
      _WarrantyShieldScreenState();
}

class _WarrantyShieldScreenState extends ConsumerState<WarrantyShieldScreen> {
  final List<WarrantyItem> _warranties = [];
  bool _loading = true;
  _WarrantyEntryMode _entryMode = _WarrantyEntryMode.manual;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final items = await WarrantyStorage.load();
    if (!mounted) return;
    setState(() {
      _warranties
        ..clear()
        ..addAll(items);
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await WarrantyStorage.save(_warranties);
  }

  Future<void> _addWarranty(WarrantyItem item) async {
    setState(() => _warranties.insert(0, item));
    await _persist();
    await WarrantyNotificationService.scheduleFor(item);
    await DraftService.instance.clearDraft(DraftBoxKeys.warrantyShieldAdd);
    if (!mounted) return;
    final locale = ref.read(userLanguageProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(WarrantyStrings.t('warr_snack_activated', locale)),
        backgroundColor: AppColors.successBright,
      ),
    );
  }

  Future<void> _deleteWarranty(String id) async {
    setState(() => _warranties.removeWhere((w) => w.id == id));
    await _persist();
    await WarrantyNotificationService.cancelFor(id);
  }

  void _showAddWarrantySheet() {
    final locale = ref.read(userLanguageProvider);
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final retailerCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    DateTime purchaseDate = DateTime.now();
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));
    String category = 'General';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDate({required bool isPurchase}) async {
            final initial = isPurchase ? purchaseDate : expiryDate;
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2015),
              lastDate: DateTime(2040),
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
            setSheetState(() {
              if (isPurchase) {
                purchaseDate = picked;
                if (!expiryDate.isAfter(purchaseDate)) {
                  expiryDate = purchaseDate.add(const Duration(days: 365));
                }
              } else {
                expiryDate = picked;
              }
            });
          }

          String fmt(DateTime d) =>
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

          return DraftAwareSheet(
            formId: DraftBoxKeys.warrantyShieldAdd,
            controllers: [nameCtrl, brandCtrl, retailerCtrl, priceCtrl],
            serialize: () => {
              'name': nameCtrl.text,
              'brand': brandCtrl.text,
              'retailer': retailerCtrl.text,
              'price': priceCtrl.text,
              'category': category,
              'purchaseDate': purchaseDate.toIso8601String(),
              'expiryDate': expiryDate.toIso8601String(),
            },
            applyDraft: (data) {
              setSheetState(() {
                nameCtrl.text = data['name']?.toString() ?? '';
                brandCtrl.text = data['brand']?.toString() ?? '';
                retailerCtrl.text = data['retailer']?.toString() ?? '';
                priceCtrl.text = data['price']?.toString() ?? '';
                category = data['category']?.toString() ?? category;
                purchaseDate = DateTime.tryParse(
                      data['purchaseDate']?.toString() ?? '',
                    ) ??
                    purchaseDate;
                expiryDate = DateTime.tryParse(
                      data['expiryDate']?.toString() ?? '',
                    ) ??
                    expiryDate;
              });
            },
            builder: (context, draft) {
              Future<void> pickDateWithDraft({required bool isPurchase}) async {
                await pickDate(isPurchase: isPurchase);
                draft.notifyChanged();
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 30,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WarrantyStrings.t('warr_add_sheet_title', locale),
                        style: TextStyle(
                          color: AppColors.isLight
                              ? AppColors.textPrimary
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FormField(
                        controller: nameCtrl,
                        hint: WarrantyStrings.t('warr_hint_product', locale),
                        onChanged: (_) => draft.notifyChanged(),
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        controller: brandCtrl,
                        hint: WarrantyStrings.t('warr_hint_brand', locale),
                        onChanged: (_) => draft.notifyChanged(),
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        controller: retailerCtrl,
                        hint: WarrantyStrings.t('warr_field_retailer', locale),
                        onChanged: (_) => draft.notifyChanged(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        dropdownColor: AppColors.surfaceElevated,
                        decoration: InputDecoration(
                          labelText: WarrantyStrings.t(
                            'warr_field_category',
                            locale,
                          ),
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
                          ),
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
                          if (v == null) return;
                          setSheetState(() => category = v);
                          draft.notifyChanged();
                        },
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        controller: priceCtrl,
                        hint: WarrantyStrings.t('warr_hint_price', locale),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => draft.notifyChanged(),
                      ),
                      const SizedBox(height: 12),
                      _DatePickerRow(
                        label: WarrantyStrings.t(
                          'warr_label_purchase_date',
                          locale,
                        ),
                        value: fmt(purchaseDate),
                        onTap: () => pickDateWithDraft(isPurchase: true),
                      ),
                      const SizedBox(height: 8),
                      _DatePickerRow(
                        label: WarrantyStrings.t('warr_label_expiry', locale),
                        value: fmt(expiryDate),
                        onTap: () => pickDateWithDraft(isPurchase: false),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final item = WarrantyItem(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              productName: nameCtrl.text.isEmpty
                                  ? WarrantyStrings.t(
                                      'warr_fallback_product',
                                      locale,
                                    )
                                  : nameCtrl.text,
                              brand: brandCtrl.text.isEmpty
                                  ? WarrantyStrings.t(
                                      'warr_fallback_brand',
                                      locale,
                                    )
                                  : brandCtrl.text,
                              retailer: retailerCtrl.text.trim(),
                              category: category,
                              purchaseDate: purchaseDate,
                              expiryDate: expiryDate,
                              purchasePriceQar:
                                  double.tryParse(priceCtrl.text) ?? 0,
                              receiptImagePath: '',
                            );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                            await _addWarranty(item);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successBright,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            WarrantyStrings.t('warr_activate_button', locale),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _warrantyListTile(WarrantyItem w, String locale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WarrantyCard(
          warranty: w,
          locale: locale,
          onTap: () => context.push('/warranty-shield/item', extra: w),
          onDelete: () => _deleteWarranty(w.id),
        ),
        if (!w.isExpired && w.daysLeft <= 14 && w.daysLeft >= 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: RepairShopSuggestions(productCategory: w.category),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final active = _warranties.where((w) => !w.isExpired).toList();
    final expiringSoon = _warranties.where((w) => w.expiringsSoon).toList();
    final expired = _warranties.where((w) => w.isExpired).toList();

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            WarrantyStrings.t('warr_screen_title', locale),
            style: AppTypography.title.copyWith(color: AppColors.textPrimary),
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          actions: [
            if (_entryMode == _WarrantyEntryMode.manual)
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.successBright,
                ),
                onPressed: _showAddWarrantySheet,
                tooltip: WarrantyStrings.t('warr_add_tooltip', locale),
              ),
          ],
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.successBright,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EntryModeToggle(
                      locale: locale,
                      mode: _entryMode,
                      onChanged: (m) => setState(() => _entryMode = m),
                    ),
                    const SizedBox(height: 16),
                    if (_entryMode == _WarrantyEntryMode.scan) ...[
                      WarrantyScanWidget(
                        locale: locale,
                        onItemSaved: _addWarranty,
                      ),
                      const SizedBox(height: 24),
                    ],
                    Row(
                      children: [
                        _StatBox(
                          '${active.length}',
                          WarrantyStrings.t('warr_stat_active', locale),
                          AppColors.successBright,
                        ),
                        const SizedBox(width: 12),
                        _StatBox(
                          '${expiringSoon.length}',
                          WarrantyStrings.t('warr_stat_expiring', locale),
                          AppColors.accentGold,
                        ),
                        const SizedBox(width: 12),
                        _StatBox(
                          '${expired.length}',
                          WarrantyStrings.t('warr_stat_expired', locale),
                          AppColors.errorBright,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_warranties.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 56,
                                color: AppColors.isLight
                                    ? AppColors.textOnGlassMuted
                                    : Colors.white.withValues(alpha: 0.15),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                WarrantyStrings.t('warr_empty_title', locale),
                                style: TextStyle(
                                  color: AppColors.isLight
                                      ? AppColors.textOnGlassSecondary
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                              if (_entryMode == _WarrantyEntryMode.manual) ...[
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: _showAddWarrantySheet,
                                  child: Text(
                                    WarrantyStrings.t(
                                      'warr_add_tooltip',
                                      locale,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    if (expiringSoon.isNotEmpty) ...[
                      Text(
                        WarrantyStrings.t('warr_section_expiring', locale),
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...expiringSoon.map((w) => _warrantyListTile(w, locale)),
                      const SizedBox(height: 20),
                    ],
                    if (active.isNotEmpty) ...[
                      Text(
                        WarrantyStrings.t('warr_section_active', locale),
                        style: const TextStyle(
                          color: AppColors.successBright,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...active
                          .where((w) => !w.expiringsSoon)
                          .map((w) => _warrantyListTile(w, locale)),
                      const SizedBox(height: 20),
                    ],
                    if (expired.isNotEmpty) ...[
                      Text(
                        WarrantyStrings.t('warr_section_expired', locale),
                        style: const TextStyle(
                          color: AppColors.errorBright,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...expired.map(
                      (w) => _WarrantyCard(
                        warranty: w,
                        locale: locale,
                        onTap: () =>
                            context.push('/warranty-shield/item', extra: w),
                        onDelete: () => _deleteWarranty(w.id),
                      ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
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
  final _WarrantyEntryMode mode;
  final ValueChanged<_WarrantyEntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: WarrantyStrings.t('warr_entry_mode_manual', locale),
            selected: mode == _WarrantyEntryMode.manual,
            onTap: () => onChanged(_WarrantyEntryMode.manual),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeChip(
            label: WarrantyStrings.t('warr_entry_mode_scan', locale),
            selected: mode == _WarrantyEntryMode.scan,
            onTap: () => onChanged(_WarrantyEntryMode.scan),
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
              ? AppColors.successBright.withValues(alpha: 0.15)
              : AppColors.isLight
                  ? AppColors.glassSurface
                  : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.successBright.withValues(alpha: 0.5)
                : AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.successBright
                : AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: 12,
        glowColor: color,
        glowIntensity: 0.1,
        backgroundColor: color.withValues(alpha: 0.08),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassMuted
                    : Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard({
    required this.warranty,
    required this.locale,
    required this.onTap,
    required this.onDelete,
  });

  final WarrantyItem warranty;
  final String locale;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = warranty.isExpired
        ? AppColors.errorBright
        : warranty.expiringsSoon
            ? AppColors.accentGold
            : AppColors.successBright;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        borderRadius: 14,
        glowColor: statusColor,
        glowIntensity: 0.1,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shield_rounded, color: statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WarrantyStrings.displayProductName(
                    warranty.productName,
                    locale,
                  ),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  warranty.retailer.isNotEmpty
                      ? warranty.retailer
                      : WarrantyStrings.displayBrand(warranty.brand, locale),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  warranty.isExpired
                      ? WarrantyStrings.t('warr_card_expired', locale)
                      : warranty.expiringsSoon
                          ? WarrantyStrings.format(
                              'warr_card_days_left_act',
                              locale,
                              params: {'days': warranty.daysLeft.toString()},
                            )
                          : WarrantyStrings.format(
                              'warr_card_days_remaining',
                              locale,
                              params: {'days': warranty.daysLeft.toString()},
                            ),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${warranty.purchasePriceQar.toStringAsFixed(0)} ${warranty.currency}',
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassSecondary
                      : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              IconButton(
                icon: Icon(
                  Icons.ios_share_rounded,
                  color: AppColors.isLight
                      ? AppColors.textTertiary
                      : Colors.white38,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  final shareData = WarrantyAlertCardData(
                    productName: warranty.productName,
                    brand: warranty.brand,
                    category: warranty.category,
                    daysLeft: warranty.daysLeft,
                    expiryDate: warranty.expiryDate,
                    purchasePriceQar: warranty.purchasePriceQar,
                    isExpired: warranty.isExpired,
                    shareCaption:
                        '🛡️ Warranty '
                        '${warranty.isExpired ? "EXPIRED" : "Alert"}: '
                        '${warranty.productName}\n'
                        '${warranty.daysLeft.abs()} days '
                        '${warranty.isExpired ? "ago" : "remaining"}\n\n'
                        'Track warranties with RAABTA\n${CommonStrings.publicWebsiteHost}',
                  );
                  ShareCardSheet.show(context, shareData);
                },
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.isLight
                      ? AppColors.textTertiary
                      : Colors.white24,
                  size: 18,
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

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Text(
              label,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.isLight
              ? AppColors.textOnGlassMuted
              : Colors.white.withValues(alpha: 0.3),
          fontSize: 13,
        ),
        fillColor: AppColors.isLight
            ? AppColors.glassSurface
            : Colors.white.withValues(alpha: 0.06),
        filled: true,
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
      ),
    );
  }
}
