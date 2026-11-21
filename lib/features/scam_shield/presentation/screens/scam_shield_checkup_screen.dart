import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_catalog.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_models.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_providers.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_checkup_item_tile.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldCheckupScreen extends ConsumerWidget {
  const ScamShieldCheckupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final visibleAsync = ref.watch(scamCheckupVisibleProvider);
    final progressAsync = ref.watch(scamCheckupProgressProvider);
    final stateAsync = ref.watch(scamCheckupStateProvider);
    final proactiveAsync = ref.watch(scamProactiveProtectionStatusProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        enableBackgroundAnimation: false,
        title: ScamShieldStrings.t('ss_checkup_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: visibleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(ScamShieldStrings.t('ss_checkup_load_error', locale)),
          ),
          data: (visible) {
            if (visible.isEmpty) {
              return ListView(
                children: [
                  Text(
                    ScamShieldStrings.t('ss_checkup_subtitle', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ScamShieldStrings.t('ss_checkup_pending_verify', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }

            return stateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (state) {
                final proactive = proactiveAsync.valueOrNull;
                final progress = progressAsync.valueOrNull ??
                    ScamCheckupProgress(done: 0, total: visible.length);

                return ListView(
                  children: [
                    Text(
                      ScamShieldStrings.t('ss_checkup_subtitle', locale),
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      ScamShieldStrings.format(
                        'ss_checkup_progress',
                        locale,
                        {
                          'done': '${progress.done}',
                          'total': '${progress.total}',
                        },
                      ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                    if (progress.total > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: progress.done / progress.total,
                        backgroundColor: AppColors.glassBorder,
                        color: AppColors.cyanGlow,
                      ),
                    ],
                    if (progress.isComplete) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        ScamShieldStrings.t('ss_checkup_all_done', locale),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ..._groups(locale, visible, state, proactive, ref),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _groups(
    String locale,
    List<ScamCheckupItem> visible,
    ScamCheckupState state,
    proactive,
    WidgetRef ref,
  ) {
    final grouped = <ScamCheckupGroup, List<ScamCheckupItem>>{};
    for (final item in visible) {
      grouped.putIfAbsent(item.group, () => []).add(item);
    }

    final order = ScamCheckupGroup.values;
    return [
      for (final group in order)
        if (grouped[group]?.isNotEmpty == true) ...[
          Text(
            ScamShieldStrings.t(_groupTitleKey(group), locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in grouped[group]!)
            ScamCheckupItemTile(
              item: item,
              locale: locale,
              proactive: proactive,
              checked: state.checkedIds.contains(item.id),
              onCheckedChanged: (v) async {
                await ref
                    .read(scamCheckupRepositoryProvider)
                    .setChecked(item.id, v);
                ref.invalidate(scamCheckupStateProvider);
                ref.invalidate(scamCheckupProgressProvider);
              },
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
    ];
  }

  static String _groupTitleKey(ScamCheckupGroup group) {
    return switch (group) {
      ScamCheckupGroup.whatsapp => 'ss_checkup_group_whatsapp',
      ScamCheckupGroup.phone => 'ss_checkup_group_phone',
      ScamCheckupGroup.raabta => 'ss_checkup_group_raabta',
      ScamCheckupGroup.money => 'ss_checkup_group_money',
    };
  }
}
