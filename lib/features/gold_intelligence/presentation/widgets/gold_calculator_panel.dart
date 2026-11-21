import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_calculator.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Premium live-linked gold calculator — purchase, resale, and P/L in one flow.
class GoldCalculatorPanel extends ConsumerStatefulWidget {
  const GoldCalculatorPanel({
    super.key,
    required this.price24k,
    this.onSwitchToLocker,
  });

  final double price24k;
  final VoidCallback? onSwitchToLocker;

  @override
  ConsumerState<GoldCalculatorPanel> createState() =>
      _GoldCalculatorPanelState();
}

class _GoldCalculatorPanelState extends ConsumerState<GoldCalculatorPanel> {
  GoldCalculatorMode _mode = GoldCalculatorMode.purchase;
  GoldJewelryType _itemType = GoldJewelryType.necklace;
  GoldWeightUnit _weightUnit = GoldWeightUnit.gram;
  int _purity = 22;
  double _makingPct = GoldJewelryType.necklace.makingChargeRange.$1;
  bool _showAdvanced = false;
  bool _vatToggle = false;

  final _weightCtrl = TextEditingController(text: '10');
  final _purchaseCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _purchaseCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  double get _weightGrams =>
      _weightUnit.toGrams(double.tryParse(_weightCtrl.text) ?? 0);

  GoldCalculatorResult get _result {
    final purchase = double.tryParse(_purchaseCtrl.text);
    return GoldCalculator.compute(
      price24kQarPerGram: widget.price24k,
      weightGrams: _weightGrams,
      purity: _purity,
      itemType: _itemType,
      makingChargePct: _makingPct,
      applyVat: _vatToggle,
      userPurchasePriceQar: purchase,
    );
  }

  void _applyItemType(GoldJewelryType type) {
    setState(() {
      _itemType = type;
      _makingPct = type.makingChargeRange.$1;
    });
  }

  void _applyWeightPreset(double grams, {int purity = 22}) {
    HapticFeedback.selectionClick();
    setState(() {
      _purity = purity;
      _weightUnit = GoldWeightUnit.gram;
      _weightCtrl.text = grams == grams.roundToDouble()
          ? grams.toStringAsFixed(0)
          : grams.toStringAsFixed(2);
    });
  }

  void _nudgeWeight(double delta) {
    final current = double.tryParse(_weightCtrl.text) ?? 0;
    final next = (current + delta).clamp(0.0, 99999.0);
    _weightCtrl.text = next == next.roundToDouble()
        ? next.toStringAsFixed(0)
        : next.toStringAsFixed(2);
    _rebuild();
  }

  void _applyMakingPreset(String preset) {
    final range = _itemType.makingChargeRange;
    setState(() {
      _makingPct = switch (preset) {
        'low' => range.$2,
        'high' => range.$3,
        _ => range.$1,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final result = _result;
    final purchaseEntered = double.tryParse(_purchaseCtrl.text) != null;
    final heroValue = _mode == GoldCalculatorMode.purchase
        ? result.totalPurchaseQar
        : result.resaleEstimateQar;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _LiveTotalHero(
          locale: locale,
          mode: _mode,
          total: heroValue,
          price24k: widget.price24k,
          purity: _purity,
          grams: _weightGrams,
          onModeChanged: (m) => setState(() => _mode = m),
        ),
        const SizedBox(height: AppSpacing.xl),
        GoldSectionHeader(
          title: GoldIntelligenceStrings.t('calc_quick_weights_title', locale),
          subtitle: GoldIntelligenceStrings.t('calc_quick_weights_subtitle', locale),
          icon: Icons.bolt_rounded,
        ),
        _PopularWeightRow(
          locale: locale,
          price24k: widget.price24k,
          onSelect: _applyWeightPreset,
        ),
        const SizedBox(height: AppSpacing.xl),
        GoldSectionHeader(
          title: GoldIntelligenceStrings.t('calc_pricing_title', locale),
          subtitle: GoldIntelligenceStrings.t('calc_pricing_subtitle', locale),
          icon: Icons.category_outlined,
        ),
        _ItemTypeSelector(
          locale: locale,
          selected: _itemType,
          onSelected: _applyItemType,
        ),
        const SizedBox(height: AppSpacing.lg),
        GoldSectionHeader(
          title: GoldIntelligenceStrings.t('calc_purity_weight_title', locale),
          subtitle: GoldIntelligenceStrings.t('calc_purity_weight_subtitle', locale),
          icon: Icons.scale_outlined,
        ),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PuritySelector(
                selected: _purity,
                onSelected: (p) => setState(() => _purity = p),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                GoldIntelligenceStrings.t('calc_weight_label', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _StepperButton(
                    icon: Icons.remove,
                    onTap: () => _nudgeWeight(-1),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _weightCtrl,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTypography.headline2.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (_) => _rebuild(),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add,
                    onTap: () => _nudgeWeight(1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _UnitSelector(
                locale: locale,
                selected: _weightUnit,
                onSelected: (u) => setState(() => _weightUnit = u),
              ),
              if (_weightGrams > 0) ...[
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    GoldIntelligenceStrings.format('calc_weight_equiv', locale, params: {
                      'grams': _weightGrams.toStringAsFixed(2),
                      'price': result.pricePerGramQar.toStringAsFixed(2),
                      'purity': '$_purity',
                    }),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!_itemType.isInvestmentGrade) ...[
          const SizedBox(height: AppSpacing.lg),
          GoldSectionHeader(
            title: GoldIntelligenceStrings.t('calc_making_charge_title', locale),
            subtitle: GoldIntelligenceStrings.t('calc_making_charge_subtitle', locale),
            icon: Icons.handyman_outlined,
          ),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_makingPct.toStringAsFixed(1)}%',
                      style: AppTypography.headline2.copyWith(
                        fontSize: 28,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'QAR ${result.makingChargeQar.toStringAsFixed(0)}',
                      style: AppTypography.subtitle,
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.accentGold,
                    thumbColor: AppColors.accentGold,
                    overlayColor: AppColors.accentGold.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: _makingPct.clamp(
                      _itemType.makingChargeRange.$2,
                      _itemType.makingChargeRange.$3,
                    ),
                    min: _itemType.makingChargeRange.$2,
                    max: _itemType.makingChargeRange.$3,
                    divisions: 24,
                    onChanged: (v) => setState(() => _makingPct = v),
                  ),
                ),
                Row(
                  children: [
                    _PresetChip(
                      label: GoldIntelligenceStrings.t('calc_making_low', locale),
                      selected: _makingPct == _itemType.makingChargeRange.$2,
                      onTap: () => _applyMakingPreset('low'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _PresetChip(
                      label: GoldIntelligenceStrings.t('calc_making_typical', locale),
                      selected: _makingPct == _itemType.makingChargeRange.$1,
                      onTap: () => _applyMakingPreset('typical'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _PresetChip(
                      label: GoldIntelligenceStrings.t('calc_making_high', locale),
                      selected: _makingPct == _itemType.makingChargeRange.$3,
                      onTap: () => _applyMakingPreset('high'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    GoldIntelligenceStrings.t('calc_advanced_options', locale),
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showAdvanced
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showAdvanced) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                TextField(
                  controller: _purchaseCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: GoldIntelligenceStrings.t('calc_purchase_price_label', locale),
                    hintText: GoldIntelligenceStrings.t('calc_purchase_price_hint', locale),
                    prefixIcon: Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.accentGold.withValues(alpha: 0.8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  onChanged: (_) => _rebuild(),
                ),
                if (!_itemType.isInvestmentGrade) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(GoldIntelligenceStrings.t('calc_vat_toggle_title', locale)),
                    subtitle: Text(
                      GoldIntelligenceStrings.t('calc_vat_toggle_subtitle', locale),
                    ),
                    value: _vatToggle,
                    activeThumbColor: AppColors.accentGold,
                    onChanged: (v) => setState(() => _vatToggle = v),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _BreakdownCard(
          locale: locale,
          result: result,
          mode: _mode,
          itemType: _itemType,
          showPl: purchaseEntered,
        ),
        if (purchaseEntered) ...[
          const SizedBox(height: AppSpacing.md),
          _PlCard(locale: locale, result: result),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          GoldIntelligenceStrings.t('ai_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _LiveTotalHero extends StatelessWidget {
  const _LiveTotalHero({
    required this.locale,
    required this.mode,
    required this.total,
    required this.price24k,
    required this.purity,
    required this.grams,
    required this.onModeChanged,
  });

  final String locale;
  final GoldCalculatorMode mode;
  final double total;
  final double price24k;
  final int purity;
  final double grams;
  final ValueChanged<GoldCalculatorMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: AppColors.accentGold,
      glowIntensity: 0.16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Stack(
          children: [
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModeToggle(locale: locale, mode: mode, onChanged: onModeChanged),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    mode == GoldCalculatorMode.purchase
                        ? GoldIntelligenceStrings.t('calc_estimated_pay', locale)
                        : GoldIntelligenceStrings.t('calc_metal_value_today', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'QAR ${total.toStringAsFixed(2)}',
                    style: AppTypography.headline2.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _HeroChip(
                        label: GoldIntelligenceStrings.format('calc_live_purity_chip', locale, params: {
                          'purity': '$purity',
                        }),
                        icon: Icons.circle,
                        iconColor: AppColors.success,
                      ),
                      _HeroChip(
                        label: GoldIntelligenceStrings.format('calc_grams_chip', locale, params: {
                          'grams': grams.toStringAsFixed(2),
                        }),
                        icon: Icons.scale,
                      ),
                      _HeroChip(
                        label: GoldIntelligenceStrings.format('calc_spot_chip', locale, params: {
                          'price': price24k.toStringAsFixed(2),
                        }),
                        icon: Icons.show_chart,
                      ),
                    ],
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

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.locale,
    required this.mode,
    required this.onChanged,
  });

  final String locale;
  final GoldCalculatorMode mode;
  final ValueChanged<GoldCalculatorMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: GoldCalculatorMode.values.map((m) {
          final selected = m == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: selected
                      ? AppColors.accentGold.withValues(alpha: 0.28)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  m == GoldCalculatorMode.purchase
                      ? GoldIntelligenceStrings.t('calc_buy_price', locale)
                      : GoldIntelligenceStrings.t('calc_resale', locale),
                  style: AppTypography.caption.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.accentGold
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor ?? AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _PopularWeightRow extends StatelessWidget {
  const _PopularWeightRow({
    required this.locale,
    required this.price24k,
    required this.onSelect,
  });

  final String locale;
  final double price24k;
  final void Function(double grams, {int purity}) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: GoldQatarConstants.popularWeights.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final w = GoldQatarConstants.popularWeights[i];
          final price22 =
              GoldQatarConstants.priceForPurity(price24k, 22) * w.grams;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(w.grams),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Ink(
                width: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.14),
                      AppColors.surface.withValues(alpha: 0.5),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      GoldIntelligenceStrings.popularWeightLabel(w.key, locale),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentGold,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'QAR ${price22.toStringAsFixed(0)}',
                      style: AppTypography.subtitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '22K',
                      style: AppTypography.caption.copyWith(
                        fontSize: 9,
                        color: AppColors.textTertiary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ItemTypeSelector extends StatelessWidget {
  const _ItemTypeSelector({
    required this.locale,
    required this.selected,
    required this.onSelected,
  });

  final String locale;
  final GoldJewelryType selected;
  final ValueChanged<GoldJewelryType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: GoldJewelryType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final type = GoldJewelryType.values[i];
          final isSelected = type == selected;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 88,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                color: isSelected
                    ? AppColors.accentGold.withValues(alpha: 0.18)
                    : AppColors.surface.withValues(alpha: 0.45),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGold.withValues(alpha: 0.75)
                      : AppColors.glassBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon,
                    color: isSelected
                        ? AppColors.accentGold
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    GoldIntelligenceStrings.jewelryTypeLabel(type, locale),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PuritySelector extends StatelessWidget {
  const _PuritySelector({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: GoldQatarConstants.purities.map((p) {
        final isSelected = p == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != GoldQatarConstants.purities.last ? 6 : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelected(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  color: isSelected
                      ? AppColors.accentGold.withValues(alpha: 0.25)
                      : AppColors.surface.withValues(alpha: 0.4),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentGold
                        : AppColors.glassBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${p}K',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.accentGold
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({
    required this.locale,
    required this.selected,
    required this.onSelected,
  });

  final String locale;
  final GoldWeightUnit selected;
  final ValueChanged<GoldWeightUnit> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.center,
      children: GoldWeightUnit.values.map((u) {
        final isSelected = u == selected;
        return GestureDetector(
          onTap: () => onSelected(u),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isSelected
                  ? AppColors.accentGold.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGold.withValues(alpha: 0.6)
                    : AppColors.glassBorder,
              ),
            ),
            child: Text(
              GoldIntelligenceStrings.weightUnitLabel(u, locale),
              style: AppTypography.caption.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.accentGold
                    : AppColors.textTertiary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.accentGold),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            color: selected
                ? AppColors.accentGold.withValues(alpha: 0.12)
                : AppColors.surface.withValues(alpha: 0.35),
            border: Border.all(color: AppColors.glassBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.accentGold : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.locale,
    required this.result,
    required this.mode,
    required this.itemType,
    required this.showPl,
  });

  final String locale;
  final GoldCalculatorResult result;
  final GoldCalculatorMode mode;
  final GoldJewelryType itemType;
  final bool showPl;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            GoldIntelligenceStrings.t('calc_breakdown_title', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.md),
          _CompositionBar(locale: locale, result: result),
          const SizedBox(height: AppSpacing.lg),
          _BreakdownLine(
            label: GoldIntelligenceStrings.t('calc_breakdown_metal_value', locale),
            sublabel: GoldIntelligenceStrings.format('calc_breakdown_metal_sublabel', locale, params: {
              'purity': '${result.purity}',
              'grams': result.weightGrams.toStringAsFixed(2),
            }),
            value: result.goldValueQar,
            color: AppColors.accentGold,
          ),
          if (result.makingChargeQar > 0)
            _BreakdownLine(
              label: GoldIntelligenceStrings.t('calc_breakdown_making', locale),
              sublabel: GoldIntelligenceStrings.format('calc_breakdown_making_sublabel', locale, params: {
                'pct': result.makingChargePct.toStringAsFixed(1),
              }),
              value: result.makingChargeQar,
              color: AppColors.amberGlow,
            ),
          if (result.vatQar > 0)
            _BreakdownLine(
              label: GoldIntelligenceStrings.t('calc_breakdown_vat', locale),
              value: result.vatQar,
              color: AppColors.cyanGlow,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(height: 1),
          ),
          _BreakdownLine(
            label: mode == GoldCalculatorMode.purchase
                ? GoldIntelligenceStrings.t('calc_breakdown_total_pay', locale)
                : GoldIntelligenceStrings.t('calc_breakdown_resale_live', locale),
            value: mode == GoldCalculatorMode.purchase
                ? result.totalPurchaseQar
                : result.resaleEstimateQar,
            bold: true,
          ),
          if (mode == GoldCalculatorMode.purchase) ...[
            const SizedBox(height: AppSpacing.sm),
            _BreakdownLine(
              label: GoldIntelligenceStrings.t('calc_breakdown_resale_metal', locale),
              sublabel: GoldIntelligenceStrings.t('calc_breakdown_resale_sublabel', locale),
              value: result.resaleEstimateQar,
              color: AppColors.textSecondary,
            ),
          ],
          if (itemType.isInvestmentGrade) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      GoldIntelligenceStrings.t('calc_investment_grade_note', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompositionBar extends StatelessWidget {
  const _CompositionBar({required this.locale, required this.result});

  final String locale;
  final GoldCalculatorResult result;

  @override
  Widget build(BuildContext context) {
    final total = result.totalPurchaseQar;
    if (total <= 0) return const SizedBox.shrink();

    final metalFlex = result.metalSharePct.clamp(1, 100).round();
    final makingFlex = result.makingSharePct.round();
    final vatFlex = result.vatQar > 0
        ? (100 - metalFlex - makingFlex).clamp(0, 100)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(
                  flex: metalFlex,
                  child: Container(color: AppColors.accentGold),
                ),
                if (makingFlex > 0)
                  Expanded(
                    flex: makingFlex,
                    child: Container(color: AppColors.amberGlow),
                  ),
                if (vatFlex > 0)
                  Expanded(
                    flex: vatFlex,
                    child: Container(color: AppColors.cyanGlow),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          GoldIntelligenceStrings.format('calc_composition_summary', locale, params: {
            'metalPct': result.metalSharePct.toStringAsFixed(0),
            'premiumPct': result.premiumPct.toStringAsFixed(1),
          }),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _BreakdownLine extends StatelessWidget {
  const _BreakdownLine({
    required this.label,
    required this.value,
    this.sublabel,
    this.color,
    this.bold = false,
  });

  final String label;
  final String? sublabel;
  final double value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: (bold ? AppTypography.subtitle : AppTypography.body)
                      .copyWith(fontWeight: bold ? FontWeight.w700 : null),
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            'QAR ${value.toStringAsFixed(2)}',
            style: AppTypography.subtitle.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlCard extends StatelessWidget {
  const _PlCard({required this.locale, required this.result});

  final String locale;
  final GoldCalculatorResult result;

  @override
  Widget build(BuildContext context) {
    final pl = result.profitLossQar;
    final isGain = pl >= 0;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: isGain ? AppColors.success : AppColors.error,
      glowIntensity: 0.1,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isGain ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.15),
            ),
            child: Icon(
              isGain ? Icons.trending_up : Icons.trending_down,
              color: isGain ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GoldIntelligenceStrings.t('calc_unrealised_pl', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '${isGain ? '+' : ''}QAR ${pl.toStringAsFixed(2)}',
                  style: AppTypography.headline2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isGain ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
