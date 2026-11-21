import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_providers.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_recheck_banner.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

class ScamCheckupHubBanner extends ConsumerWidget {
  const ScamCheckupHubBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(scamCheckupStateProvider);
    return stateAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        if (!ScamCheckupRecheckBannerLogic.shouldShowHubBanner(
          state: state,
          now: DateTime.now(),
        )) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ScamShieldStrings.t('ss_checkup_recheck_banner', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.push('/scam-shield/checkup'),
                      child: Text(
                        ScamShieldStrings.t('ss_checkup_recheck_cta', locale),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(scamCheckupRepositoryProvider)
                            .dismissRecheckBanner();
                        ref.invalidate(scamCheckupStateProvider);
                      },
                      child: Text(
                        ScamShieldStrings.t('ss_checkup_recheck_dismiss', locale),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
