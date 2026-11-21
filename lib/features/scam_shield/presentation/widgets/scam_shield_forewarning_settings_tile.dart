import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_providers.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

class ScamShieldForewarningSettingsTile extends ConsumerWidget {
  const ScamShieldForewarningSettingsTile({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledAsync = ref.watch(forewarningTipsEnabledProvider);
    return enabledAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (enabled) {
        return GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ScamShieldStrings.t('ss_forewarning_settings_title', locale),
              style: AppTypography.subtitle,
            ),
            subtitle: Text(
              ScamShieldStrings.t('ss_forewarning_settings_sub', locale),
              style: AppTypography.caption,
            ),
            value: enabled,
            onChanged: (v) async {
              await ref.read(forewarningRepositoryProvider).setTipsEnabled(v);
              ref.invalidate(forewarningTipsEnabledProvider);
            },
          ),
        );
      },
    );
  }
}
