import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_constants.dart';
import 'package:raabta/features/gold_intelligence/domain/gold_qatar_models.dart';
import 'package:raabta/features/gold_intelligence/presentation/l10n/gold_intelligence_strings.dart';
import 'package:raabta/features/gold_intelligence/presentation/widgets/gold_section_header.dart';
import 'package:raabta/features/gold_intelligence/services/gold_qatar_service.dart';
import 'package:raabta/providers/visa_providers.dart';

class GoldLockerPanel extends ConsumerStatefulWidget {
  const GoldLockerPanel({super.key, required this.price24k});

  final double price24k;

  @override
  ConsumerState<GoldLockerPanel> createState() => _GoldLockerPanelState();
}

class _GoldLockerPanelState extends ConsumerState<GoldLockerPanel> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _SignInPrompt(locale: locale);

    final lockerAsync = ref.watch(goldLockerProvider(uid));

    return lockerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Text(GoldIntelligenceStrings.t('locker_load_failed', locale)),
      ),
      data: (items) {
        var totalPurchase = 0.0;
        var totalCurrent = 0.0;
        for (final item in items) {
          totalPurchase += item.purchasePriceQar;
          totalCurrent += item.estimatedValueQar(widget.price24k);
        }
        final gain = totalCurrent - totalPurchase;
        final gainPct =
            totalPurchase > 0 ? (gain / totalPurchase) * 100 : 0.0;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _PortfolioHero(
              locale: locale,
              totalCurrent: totalCurrent,
              totalPurchase: totalPurchase,
              gain: gain,
              gainPct: gainPct,
              itemCount: items.length,
            ),
            const SizedBox(height: AppSpacing.xl),
            GoldSectionHeader(
              title: GoldIntelligenceStrings.t('locker_your_pieces_title', locale),
              subtitle: GoldIntelligenceStrings.format(
                items.length == 1
                    ? 'locker_items_tracked'
                    : 'locker_items_tracked_plural',
                locale,
                params: {'count': '${items.length}'},
              ),
              icon: Icons.inventory_2_outlined,
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.accentGold,
                onPressed: () => _showAddSheet(uid, locale),
              ),
            ),
            if (items.isEmpty)
              _EmptyLocker(locale: locale, onAdd: () => _showAddSheet(uid, locale))
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LockerItemCard(
                    locale: locale,
                    item: item,
                    price24k: widget.price24k,
                    onDelete: () async {
                      await ref
                          .read(goldQatarServiceProvider)
                          .deleteLockerItem(item.id);
                      ref.invalidate(goldLockerProvider(uid));
                    },
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: GoldIntelligenceStrings.t('locker_add_piece', locale),
              onPressed: () => _showAddSheet(uid, locale),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddSheet(String uid, String locale) async {
    final nameCtrl = TextEditingController();
    final weightCtrl = TextEditingController(text: '8');
    final priceCtrl = TextEditingController();
    var purity = 22;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              GoldIntelligenceStrings.t('locker_add_sheet_title', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: GoldIntelligenceStrings.t('locker_item_name', locale),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: GoldIntelligenceStrings.t('locker_weight_label', locale),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: GoldIntelligenceStrings.t('locker_paid_label', locale),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              children: GoldQatarConstants.purities.map((p) {
                return ChoiceChip(
                  label: Text('${p}K'),
                  selected: purity == p,
                  onSelected: (_) => setState(() => purity = p),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: GoldIntelligenceStrings.t('locker_save_piece', locale),
              onPressed: () async {
                final ok = await ref.read(goldQatarServiceProvider).addLockerItem(
                      userId: uid,
                      itemName: nameCtrl.text.trim(),
                      weightGrams: double.tryParse(weightCtrl.text) ?? 0,
                      purchasePriceQar: double.tryParse(priceCtrl.text) ?? 0,
                      purity: purity,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (ok) ref.invalidate(goldLockerProvider(uid));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({
    required this.locale,
    required this.totalCurrent,
    required this.totalPurchase,
    required this.gain,
    required this.gainPct,
    required this.itemCount,
  });

  final String locale;
  final double totalCurrent;
  final double totalPurchase;
  final double gain;
  final double gainPct;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isUp = gain >= 0;
    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: AppColors.accentGold,
      glowIntensity: 0.14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GoldIntelligenceStrings.t('locker_portfolio_value', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                'QAR ${totalCurrent.toStringAsFixed(0)}',
                style: AppTypography.headline2.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (isUp ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: isUp ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isUp ? '+' : ''}${gain.toStringAsFixed(0)} (${gainPct.toStringAsFixed(1)}%)',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isUp ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    GoldIntelligenceStrings.format('locker_pieces_count', locale, params: {
                      'count': '$itemCount',
                    }),
                    style: AppTypography.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: GoldIntelligenceStrings.t('locker_paid', locale),
                      value: 'QAR ${totalPurchase.toStringAsFixed(0)}',
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.glassBorder),
                  Expanded(
                    child: _MiniStat(
                      label: GoldIntelligenceStrings.t('locker_live_est', locale),
                      value: 'QAR ${totalCurrent.toStringAsFixed(0)}',
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
        Text(value, style: AppTypography.subtitle.copyWith(fontSize: 13)),
      ],
    );
  }
}

class _LockerItemCard extends StatelessWidget {
  const _LockerItemCard({
    required this.locale,
    required this.item,
    required this.price24k,
    required this.onDelete,
  });

  final String locale;
  final JewelryLockerItem item;
  final double price24k;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final current = item.estimatedValueQar(price24k);
    final pl = item.gainLossQar(price24k);
    final isUp = pl >= 0;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentGold.withValues(alpha: 0.3),
                  AppColors.amberGlow.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Text(
              '${item.purity}',
              style: AppTypography.subtitle.copyWith(
                color: AppColors.accentGold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName, style: AppTypography.subtitle),
                Text(
                  GoldIntelligenceStrings.format('locker_item_detail', locale, params: {
                    'weight': item.weightGrams.toString(),
                    'purity': '${item.purity}',
                    'price': item.purchasePriceQar.toStringAsFixed(0),
                  }),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'QAR ${current.toStringAsFixed(0)}',
                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${isUp ? '+' : ''}${pl.toStringAsFixed(0)}',
                style: AppTypography.caption.copyWith(
                  color: isUp ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.textTertiary),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EmptyLocker extends StatelessWidget {
  const _EmptyLocker({required this.locale, required this.onAdd});

  final String locale;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: AppColors.accentGold.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            GoldIntelligenceStrings.t('locker_empty_title', locale),
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            GoldIntelligenceStrings.t('locker_empty_body', locale),
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: onAdd,
            child: Text(GoldIntelligenceStrings.t('locker_add_first', locale)),
          ),
        ],
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              GoldIntelligenceStrings.t('locker_sign_in', locale),
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
