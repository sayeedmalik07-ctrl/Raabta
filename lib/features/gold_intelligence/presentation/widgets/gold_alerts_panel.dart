import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_alert_models.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_section_header.dart';
import 'package:raabta/features/gold_intelligence/services/gold_qatar_service.dart';
import 'package:raabta/providers/visa_providers.dart';

class GoldAlertsPanel extends ConsumerStatefulWidget {
  const GoldAlertsPanel({super.key, required this.price24k});

  final double price24k;

  @override
  ConsumerState<GoldAlertsPanel> createState() => _GoldAlertsPanelState();
}

class _GoldAlertsPanelState extends ConsumerState<GoldAlertsPanel> {
  int _purity = 22;
  String _direction = 'below';
  final _thresholdCtrl = TextEditingController();
  final _gainCtrl = TextEditingController(text: '500');
  bool _saving = false;

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    _gainCtrl.dispose();
    super.dispose();
  }

  double get _livePurityPrice =>
      GoldQatarConstants.priceForPurity(widget.price24k, _purity);

  Future<void> _savePriceAlert(String uid, String locale) async {
    final threshold = double.tryParse(_thresholdCtrl.text);
    if (threshold == null) return;
    setState(() => _saving = true);
    final alert = GoldAlert(
      id: '',
      type: 'price_threshold',
      purity: _purity,
      thresholdQar: threshold,
      direction: _direction,
    );
    final ok = await ref.read(goldQatarServiceProvider).alertService.saveAlert(
          userId: uid,
          alert: alert,
        );
    if (ok) ref.invalidate(goldAlertsProvider(uid));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? GoldIntelligenceStrings.t('alerts_price_saved', locale)
                : GoldIntelligenceStrings.t('alerts_save_failed', locale),
          ),
        ),
      );
    }
  }

  Future<void> _saveGainAlert(String uid, String locale) async {
    final gain = double.tryParse(_gainCtrl.text);
    if (gain == null) return;
    setState(() => _saving = true);
    final alert = GoldAlert(
      id: '',
      type: 'locker_gain',
      gainQar: gain,
    );
    final ok = await ref.read(goldQatarServiceProvider).alertService.saveAlert(
          userId: uid,
          alert: alert,
        );
    if (ok) ref.invalidate(goldAlertsProvider(uid));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? GoldIntelligenceStrings.t('alerts_gain_saved', locale)
                : GoldIntelligenceStrings.t('alerts_save_failed', locale),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Center(
        child: Text(GoldIntelligenceStrings.t('alerts_sign_in', locale)),
      );
    }

    final alertsAsync = ref.watch(goldAlertsProvider(uid));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SmartEngineBanner(locale: locale),
        const SizedBox(height: AppSpacing.xl),
        GoldSectionHeader(
          title: GoldIntelligenceStrings.t('alerts_price_alert_title', locale),
          subtitle: GoldIntelligenceStrings.t('alerts_price_alert_subtitle', locale),
          icon: Icons.notifications_active_outlined,
        ),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                GoldIntelligenceStrings.format('alerts_live_rate', locale, params: {
                  'purity': '$_purity',
                  'price': _livePurityPrice.toStringAsFixed(2),
                }),
                style: AppTypography.caption.copyWith(color: AppColors.accentGold),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: GoldQatarConstants.purities.map((p) {
                  final sel = p == _purity;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: p != GoldQatarConstants.purities.last ? 4 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _purity = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: sel
                                ? AppColors.accentGold.withValues(alpha: 0.22)
                                : AppColors.surface.withValues(alpha: 0.4),
                            border: Border.all(
                              color: sel
                                  ? AppColors.accentGold
                                  : AppColors.glassBorder,
                            ),
                          ),
                          child: Text('${p}K', style: AppTypography.caption),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _DirectionChip(
                      label: GoldIntelligenceStrings.t('alerts_drops_below', locale),
                      selected: _direction == 'below',
                      onTap: () => setState(() => _direction = 'below'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _DirectionChip(
                      label: GoldIntelligenceStrings.t('alerts_rises_above', locale),
                      selected: _direction == 'above',
                      onTap: () => setState(() => _direction = 'above'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _thresholdCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: GoldIntelligenceStrings.t('alerts_target_label', locale),
                  hintText: _livePurityPrice.toStringAsFixed(2),
                  prefixIcon: Icon(Icons.price_change, color: AppColors.accentGold),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: _saving
                    ? GoldIntelligenceStrings.t('alerts_saving', locale)
                    : GoldIntelligenceStrings.t('alerts_enable_price', locale),
                onPressed: _saving ? null : () => _savePriceAlert(uid, locale),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GoldSectionHeader(
          title: GoldIntelligenceStrings.t('alerts_portfolio_gain_title', locale),
          subtitle: GoldIntelligenceStrings.t('alerts_portfolio_gain_subtitle', locale),
          icon: Icons.account_balance_wallet_outlined,
        ),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _gainCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: GoldIntelligenceStrings.t('alerts_gain_threshold_label', locale),
                  prefixIcon: const Icon(Icons.trending_up),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: GoldIntelligenceStrings.t('alerts_enable_gain', locale),
                onPressed: _saving ? null : () => _saveGainAlert(uid, locale),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GoldSectionHeader(
          title: GoldIntelligenceStrings.t('alerts_active_title', locale),
          subtitle: GoldIntelligenceStrings.t('alerts_active_subtitle', locale),
          icon: Icons.checklist_rounded,
          trailing: Text(
            '${alertsAsync.valueOrNull?.length ?? 0}',
            style: AppTypography.subtitle.copyWith(color: AppColors.accentGold),
          ),
        ),
        alertsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Text(
            GoldIntelligenceStrings.t('alerts_load_failed', locale),
          ),
          data: (alerts) {
            if (alerts.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  GoldIntelligenceStrings.t('alerts_empty', locale),
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: alerts.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          a.type == 'locker_gain'
                              ? Icons.savings_outlined
                              : Icons.notifications_outlined,
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.displayTitle, style: AppTypography.subtitle),
                              Text(
                                GoldIntelligenceStrings.t('alerts_smart_push_deduped', locale),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () async {
                            await ref
                                .read(goldQatarServiceProvider)
                                .alertService
                                .deleteAlert(userId: uid, alertId: a.id);
                            ref.invalidate(goldAlertsProvider(uid));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SmartEngineBanner extends StatelessWidget {
  const _SmartEngineBanner({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.08,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyanGlow.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.auto_awesome, color: AppColors.cyanGlow, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GoldIntelligenceStrings.t('alerts_smart_engine_title', locale),
                  style: AppTypography.subtitle,
                ),
                Text(
                  GoldIntelligenceStrings.t('alerts_smart_engine_body', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
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

class _DirectionChip extends StatelessWidget {
  const _DirectionChip({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? AppColors.accentGold.withValues(alpha: 0.2)
              : AppColors.surface.withValues(alpha: 0.4),
          border: Border.all(
            color: selected ? AppColors.accentGold : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
