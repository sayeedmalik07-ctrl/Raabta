import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/presentation/providers/prospective_migrant_providers.dart';
import 'package:raabta/features/prospective_migrant/presentation/widgets/prospective_flow_actions.dart';

class ProspectiveCountryScreen extends ConsumerWidget {
  const ProspectiveCountryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(prospectiveLocaleProvider);
    final profile = ref.watch(prospectiveProfileProvider).valueOrNull;

    return GlassScreenScaffold(
      title: ProspectiveMigrantStrings.t('pm_country_heading', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            ProspectiveMigrantStrings.t('pm_country_desc', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...MigrantSupportCatalog.countries.map((country) {
            final selected = profile?.countryId == country.countryId;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                onTap: () async {
                  final base = profile ??
                      const ProspectiveProfile();
                  await ref.read(prospectiveProfileProvider.notifier).save(
                        base.copyWith(countryId: country.countryId),
                      );
                  if (!context.mounted) return;
                  context.pop();
                },
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor: selected ? AppColors.accentGold : AppColors.glassBorder,
                glowIntensity: selected ? 0.2 : 0.06,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        EosbStrings.t(country.displayNameKey, locale),
                        style: AppTypography.subtitle,
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, color: AppColors.accentGold),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          const ProspectiveFlowActions(),
        ],
      ),
    );
  }
}
