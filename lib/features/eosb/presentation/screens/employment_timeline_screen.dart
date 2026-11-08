import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_employment_timeline.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';

class EmploymentTimelineScreen extends ConsumerWidget {
  const EmploymentTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final input = ref.watch(eosbProvider).input;
    final result = ref.watch(eosbProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (input.joiningDate == null) {
          return GlassScreenScaffold(
            title: EosbStrings.t('eosb_timeline', locale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: GlassEmptyState(
              icon: Icons.timeline,
              title: EosbStrings.t('eosb_timeline_empty_title', locale),
              description: EosbStrings.t('eosb_timeline_empty_desc', locale),
              actionLabel: EosbStrings.t('eosb_employee_info', locale),
              onAction: () => context.push('/eosb/employee-info'),
            ),
          );
        }

        return GlassScreenScaffold(
          title: EosbStrings.t('eosb_timeline', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              EosbEmploymentTimeline(
                input: input,
                locale: locale,
                calculatedAt: result?.calculatedAt,
              ),
            ],
          ),
        );
      },
    );
  }
}
