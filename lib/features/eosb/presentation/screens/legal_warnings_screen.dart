import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_labour_dispute_escalation_section.dart';
import 'package:raabta/features/eosb/presentation/widgets/home_country_support_section.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';

class LegalWarningsScreen extends ConsumerWidget {
  const LegalWarningsScreen({super.key});

  Color _severityColor(EosbWarningSeverity s) {
    switch (s) {
      case EosbWarningSeverity.info:
        return AppColors.textSecondary;
      case EosbWarningSeverity.warning:
        return AppColors.accentGold;
      case EosbWarningSeverity.violation:
        return AppColors.errorBright;
      case EosbWarningSeverity.critical:
        return AppColors.errorBright;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final result = ref.watch(eosbProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final warnings = result?.warnings ?? [];
        final violations = result?.violations ?? [];

        if (warnings.isEmpty && violations.isEmpty) {
          return GlassScreenScaffold(
            title: EosbStrings.t('eosb_warnings', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.verified_outlined,
              title: EosbStrings.t('eosb_empty_warnings_title', locale),
              description: EosbStrings.t('eosb_empty_warnings_desc', locale),
              actionLabel: EosbStrings.t('eosb_calculate_cta', locale),
              onAction: () => context.push('/eosb/employee-info'),
            ),
          );
        }

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_warnings', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbLabourDisputeEscalationSection(locale: locale),
              const SizedBox(height: AppSpacing.md),
              HomeCountrySupportSection(locale: locale),
              const SizedBox(height: AppSpacing.md),
              ...warnings.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    glowColor: _severityColor(w.severity),
                    glowIntensity: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EosbStrings.t(w.titleKey, locale),
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          EosbStrings.t(w.explanationKey, locale),
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          EosbStrings.t(w.actionKey, locale),
                          style: AppTypography.link,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ...violations.map(
                (v) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    glowColor: AppColors.errorBright,
                    glowIntensity: 0.15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EosbStrings.t(v.titleKey, locale),
                          style: AppTypography.title.copyWith(
                            color: AppColors.errorBright,
                          ),
                        ),
                        Text(
                          EosbStrings.t(v.explanationKey, locale),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
