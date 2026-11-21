import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_breakdown_row.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_hero_card.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/presentation/providers/prospective_migrant_providers.dart';
import 'package:raabta/features/prospective_migrant/presentation/widgets/prospective_flow_actions.dart';

class ProspectivePreviewScreen extends ConsumerWidget {
  const ProspectivePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(prospectiveLocaleProvider);
    final result = ref.watch(prospectivePreviewResultProvider);

    if (result == null) {
      return GlassScreenScaffold(
        title: ProspectiveMigrantStrings.t('pm_preview_heading', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Text(
            ProspectiveMigrantStrings.t('pm_complete_contract_first', locale),
          ),
        ),
      );
    }

    return GlassScreenScaffold(
      title: ProspectiveMigrantStrings.t('pm_preview_heading', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.12,
            child: Text(
              ProspectiveMigrantStrings.t('pm_preview_subtitle', locale),
              style: AppTypography.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          EosbDisclaimerBanner(locale: locale),
          const SizedBox(height: AppSpacing.lg),
          EosbHeroCard(
            amount: result.totalEntitlement,
            locale: locale,
            result: result,
            confidenceScore: result.explanation.confidenceScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...result.breakdown.map(
            (item) => EosbBreakdownRow(
              item: item,
              locale: locale,
              onExpand: () => showEosbBreakdownSheet(
                context,
                item: item,
                locale: locale,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const ProspectiveFlowActions(),
        ],
      ),
    );
  }
}
