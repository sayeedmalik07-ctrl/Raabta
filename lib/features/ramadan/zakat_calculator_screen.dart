import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:raabta/features/gold_intelligence/services/gold_qatar_service.dart';
import 'package:raabta/features/ramadan/domain/zakat_calculator.dart';
import 'package:raabta/features/ramadan/hijri_calendar.dart';
import 'package:raabta/features/ramadan/l10n/zakat_strings.dart';
import 'package:raabta/features/ramadan/presentation/widgets/zakat_animated_amount.dart';
import 'package:raabta/features/ramadan/presentation/widgets/zakat_breakdown_chart.dart';
import 'package:raabta/features/ramadan/presentation/widgets/zakat_disclaimer_banner.dart';
import 'package:raabta/features/ramadan/presentation/widgets/zakat_slider_field.dart';
import 'package:raabta/features/ramadan/providers/zakat_providers.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/smart_notification_engine.dart';

/// Premium in-place Zakat estimate — reactive, no AI, not a religious ruling.
class ZakatCalculatorScreen extends ConsumerStatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  ConsumerState<ZakatCalculatorScreen> createState() =>
      _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends ConsumerState<ZakatCalculatorScreen> {
  double _cash = 0;
  double _investments = 0;
  double _goldWeight = 0;
  int _goldPurity = 24;
  double _silverWeight = 0;
  final int _silverPurity = 999;
  double _silverPrice =
      ZakatCalculatorEngine.defaultSilverQarPerGram;
  double _business = 0;
  double _receivable = 0;
  double _payable = 0;
  NisabStandard _nisabStandard = NisabStandard.gold;
  bool _useLockerGold = false;
  bool _advancedOpen = false;
  bool _reminderEnabled = false;
  bool _saving = false;
  bool _lockerInitialized = false;

  void _rebuild([VoidCallback? fn]) {
    if (fn != null) fn();
    setState(() {});
  }

  ZakatInputs _buildInputs({
    required double goldRate,
    required double lockerValue,
    required bool hasLocker,
  }) {
    return ZakatInputs(
      cashQar: _cash,
      goldWeightGrams: _goldWeight,
      goldPurity: _goldPurity,
      useLockerGold: _useLockerGold && hasLocker,
      lockerGoldValueQar: lockerValue,
      silverWeightGrams: _silverWeight,
      silverPurity: _silverPurity,
      investmentsQar: _investments,
      businessInventoryQar: _business,
      debtsReceivableQar: _receivable,
      debtsPayableQar: _payable,
      nisabStandard: _nisabStandard,
      silverPricePerGramQar: _silverPrice,
    );
  }

  Future<void> _saveCalculation(ZakatResult result, ZakatInputs inputs) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ZakatStrings.t(
              'zakat_sign_in_save',
              _locale,
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(zakatRepositoryProvider).saveCalculation(
            result: result,
            inputs: inputs,
            goldRatePerGram: result.goldRatePerGram,
            reminderEnabled: _reminderEnabled,
          );

      if (_reminderEnabled) {
        final hijri = gregorianToHijri(DateTime.now());
        await SmartNotificationEngine.instance.maybeNotifyZakatAnnualReminder(
          hijriYear: hijri.year,
          zakatDueQar: result.zakatDue,
        );
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ZakatStrings.t('zakat_saved', _locale))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _locale =>
      ref.watch(userLanguageProvider);

  String _formatQar(double amount) => 'QAR ${amount.toStringAsFixed(2)}';

  String _formatRateTime(DateTime? updatedAt) {
    if (updatedAt == null) return '—';
    return DateFormat('d MMM, HH:mm').format(updatedAt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final locale = _locale;
    final isRtlLocale = AppLocale.isRtl(locale);
    final goldAsync = ref.watch(goldLatestProvider);
    final goldRate = goldAsync.valueOrNull?.gold24kQarPerGram ?? 280.0;
    final rateUpdatedAt = goldAsync.valueOrNull?.updatedAt;

    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final lockerAsync =
        uid.isEmpty ? const AsyncValue.data(<JewelryLockerItem>[]) : ref.watch(goldLockerProvider(uid));
    final lockerItems = lockerAsync.valueOrNull ?? const <JewelryLockerItem>[];
    final lockerValue =
        ZakatCalculatorEngine.lockerGoldValue(lockerItems, goldRate);
    final hasLocker = lockerItems.isNotEmpty && lockerValue > 0;

    if (hasLocker && !_lockerInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _useLockerGold = true;
            _lockerInitialized = true;
          });
        }
      });
    }

    final inputs = _buildInputs(
      goldRate: goldRate,
      lockerValue: lockerValue,
      hasLocker: hasLocker,
    );
    final result = ZakatCalculatorEngine.compute(
      inputs: inputs,
      gold24kQarPerGram: goldRate,
      rateUpdatedAt: rateUpdatedAt,
    );
    final hijriYear = gregorianToHijri(DateTime.now()).year;

    return Directionality(
      textDirection: isRtlLocale ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(ZakatStrings.t('zakat_title', locale)),
        ),
        body: AnimatedAuroraBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                ZakatDisclaimerBanner(locale: locale),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  glowColor: result.meetsNisab ? AppColors.accentGold : null,
                  glowIntensity: result.meetsNisab ? 0.18 : 0.06,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ZakatHeroResultCard(
                        meetsNisab: result.meetsNisab,
                        zakatDue: result.zakatDue,
                        dueLabel: ZakatStrings.t('zakat_due_label', locale),
                        belowNisabLabel:
                            ZakatStrings.t('zakat_below_nisab', locale),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        ZakatStrings.format(
                          'zakat_nisab_threshold',
                          locale,
                          params: {'amount': _formatQar(result.nisabThreshold)},
                        ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        result.nisabStandard == NisabStandard.gold
                            ? ZakatStrings.t('zakat_nisab_gold', locale)
                            : ZakatStrings.t('zakat_nisab_silver', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        ZakatStrings.format(
                          'zakat_rate_note',
                          locale,
                          params: {
                            'rate': goldRate.toStringAsFixed(2),
                            'time': _formatRateTime(rateUpdatedAt),
                          },
                        ),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ZakatStrings.t('zakat_net_wealth', locale),
                              style: AppTypography.bodySmall,
                            ),
                          ),
                          ZakatAnimatedAmount(
                            amount: result.zakatableWealth,
                            style: AppTypography.subtitle.copyWith(
                              color: AppColors.cyanGlow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ZakatBreakdownChart(
                  segments: result.segments,
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.lg),
                _nisabToggle(locale),
                const SizedBox(height: AppSpacing.md),
                ZakatSliderField(
                  label: ZakatStrings.t('zakat_cash', locale),
                  value: _cash,
                  min: 0,
                  max: 500000,
                  onChanged: (v) => _rebuild(() => _cash = v),
                ),
                const SizedBox(height: AppSpacing.sm),
                _goldSection(
                  locale: locale,
                  hasLocker: hasLocker,
                  lockerItems: lockerItems,
                  lockerValue: lockerValue,
                  goldRate: goldRate,
                ),
                const SizedBox(height: AppSpacing.sm),
                ZakatSliderField(
                  label: ZakatStrings.t('zakat_investments', locale),
                  value: _investments,
                  min: 0,
                  max: 500000,
                  onChanged: (v) => _rebuild(() => _investments = v),
                ),
                const SizedBox(height: AppSpacing.md),
                _advancedSection(locale),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  glowColor: _reminderEnabled ? AppColors.accentGold : null,
                  glowIntensity: _reminderEnabled ? 0.1 : 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ZakatStrings.t('zakat_reminder', locale),
                              style: AppTypography.subtitle.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ZakatStrings.t('zakat_reminder_sub', locale),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _reminderEnabled,
                        activeThumbColor: AppColors.accentGold,
                        onChanged: (v) => _rebuild(() => _reminderEnabled = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassPrimaryButton(
                  label: ZakatStrings.format(
                    'zakat_save',
                    locale,
                    params: {'year': '$hijriYear'},
                  ),
                  icon: Icons.save_outlined,
                  onPressed: _saving
                      ? null
                      : () => _saveCalculation(result, inputs),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  onTap: () => context.push('/ramadan'),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  glowColor: AppColors.purpleGlow,
                  glowIntensity: 0.1,
                  child: Row(
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              QuickActionsStrings.t(
                                'tool_ramadan_title',
                                locale,
                              ),
                              style: AppTypography.title,
                            ),
                            Text(
                              QuickActionsStrings.t(
                                'tool_ramadan_description',
                                locale,
                              ),
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nisabToggle(String locale) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _nisabChip(
              locale: locale,
              label: ZakatStrings.t('zakat_nisab_gold', locale),
              selected: _nisabStandard == NisabStandard.gold,
              onTap: () => _rebuild(
                () => _nisabStandard = NisabStandard.gold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _nisabChip(
              locale: locale,
              label: ZakatStrings.t('zakat_nisab_silver', locale),
              selected: _nisabStandard == NisabStandard.silver,
              onTap: () => _rebuild(
                () => _nisabStandard = NisabStandard.silver,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nisabChip({
    required String locale,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGold.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: selected ? AppColors.accentGold : AppColors.glassBorderBright,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: selected ? AppColors.accentGold : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  Widget _goldSection({
    required String locale,
    required bool hasLocker,
    required List<JewelryLockerItem> lockerItems,
    required double lockerValue,
    required double goldRate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLocker) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.accentGold,
            glowIntensity: _useLockerGold ? 0.12 : 0.04,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ZakatStrings.format(
                    'zakat_locker_import',
                    locale,
                    params: {
                      'count': '${lockerItems.length}',
                      'amount': _formatQar(lockerValue),
                    },
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => _rebuild(
                    () => _useLockerGold = !_useLockerGold,
                  ),
                  child: Text(
                    _useLockerGold
                        ? ZakatStrings.t('zakat_use_manual_gold', locale)
                        : ZakatStrings.t('zakat_use_locker', locale),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (!_useLockerGold || !hasLocker) ...[
          ZakatSliderField(
            label: ZakatStrings.t('zakat_weight_grams', locale),
            value: _goldWeight,
            min: 0,
            max: 500,
            prefix: '',
            suffix: 'g',
            onChanged: (v) => _rebuild(() => _goldWeight = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _purityChips(
            locale: locale,
            value: _goldPurity,
            options: GoldQatarConstants.purities,
            onChanged: (p) => _rebuild(() => _goldPurity = p),
          ),
          if (_goldWeight > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${ZakatStrings.t('zakat_gold', locale)}: ${_formatQar(GoldQatarConstants.priceForPurity(goldRate, _goldPurity) * _goldWeight)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _purityChips({
    required String locale,
    required int value,
    required List<int> options,
    required ValueChanged<int> onChanged,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ZakatStrings.t('zakat_purity', locale),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: options.map((p) {
              final selected = p == value;
              return Material(
                color: Colors.transparent,
                child: ChoiceChip(
                  label: Text('$p K'),
                  selected: selected,
                  selectedColor: AppColors.accentGold.withValues(alpha: 0.2),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    onChanged(p);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _advancedSection(String locale) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _rebuild(() => _advancedOpen = !_advancedOpen),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Text(
                    ZakatStrings.t('zakat_advanced', locale),
                    style: AppTypography.subtitle,
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _advancedOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_advancedOpen) ...[
            const SizedBox(height: AppSpacing.sm),
            ZakatSliderField(
              label: ZakatStrings.t('zakat_business', locale),
              value: _business,
              min: 0,
              max: 1000000,
              onChanged: (v) => _rebuild(() => _business = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            ZakatSliderField(
              label: ZakatStrings.t('zakat_receivable', locale),
              value: _receivable,
              min: 0,
              max: 500000,
              onChanged: (v) => _rebuild(() => _receivable = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            ZakatSliderField(
              label: ZakatStrings.t('zakat_payable', locale),
              value: _payable,
              min: 0,
              max: 500000,
              onChanged: (v) => _rebuild(() => _payable = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            ZakatSliderField(
              label: ZakatStrings.t('zakat_silver', locale),
              value: _silverWeight,
              min: 0,
              max: 2000,
              prefix: '',
              suffix: 'g',
              onChanged: (v) => _rebuild(() => _silverWeight = v),
            ),
            if (_nisabStandard == NisabStandard.silver) ...[
              const SizedBox(height: AppSpacing.sm),
              ZakatSliderField(
                label: ZakatStrings.t('zakat_silver_rate', locale),
                value: _silverPrice,
                min: 1,
                max: 20,
                prefix: 'QAR ',
                suffix: '/g',
                divisions: 190,
                onChanged: (v) => _rebuild(() => _silverPrice = v),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
