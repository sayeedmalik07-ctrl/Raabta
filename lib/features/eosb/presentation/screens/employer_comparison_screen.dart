import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_comparison_widget.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/services/eosb_analytics_service.dart';

class EmployerComparisonScreen extends ConsumerWidget {
  const EmployerComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final comparison = ref.watch(eosbProvider).result?.comparison;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (comparison == null) {
          return GlassScreenScaffold(
            title: EosbStrings.t('eosb_comparison', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.compare_arrows,
              title: EosbStrings.t('eosb_empty_comparison_title', locale),
              description: EosbStrings.t('eosb_empty_comparison_desc', locale),
              actionLabel: EosbStrings.t('eosb_employee_info', locale),
              onAction: () => context.push('/eosb/employee-info'),
            ),
          );
        }

        EosbAnalyticsService().trackComparisonViewed(
          difference: comparison.difference,
        );

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_comparison', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              EosbComparisonWidget(comparison: comparison, locale: locale),
              const SizedBox(height: AppSpacing.lg),
              Text(
                EosbStrings.t('eosb_missing_payments', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...comparison.disputes.map(
                (d) => ListTile(
                  title: Text(EosbStrings.t(d.issueKey, locale)),
                  subtitle: Text(EosbStrings.t(d.explanationKey, locale)),
                  trailing: Text(formatEosbCurrency(d.amountGap)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                EosbStrings.t('eosb_next_steps', locale),
                style: AppTypography.title,
              ),
              ...comparison.suggestedStepsKeys.map(
                (key) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(EosbStrings.t(key, locale)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
