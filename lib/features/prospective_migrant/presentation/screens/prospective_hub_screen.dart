import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/presentation/providers/prospective_migrant_providers.dart';
import 'package:raabta/features/prospective_migrant/presentation/widgets/prospective_flow_actions.dart';

class ProspectiveHubScreen extends ConsumerWidget {
  const ProspectiveHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(prospectiveLocaleProvider);
    final profile = ref.watch(prospectiveProfileProvider).valueOrNull;

    return GlassScreenScaffold(
      title: ProspectiveMigrantStrings.t('pm_hub_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/login'),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.12,
            child: Text(
              ProspectiveMigrantStrings.t('pm_hub_subtitle', locale),
              style: AppTypography.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _NavTile(
            icon: Icons.verified_user_outlined,
            title: ProspectiveMigrantStrings.t('pm_agency_verify_nav', locale),
            subtitle: ProspectiveMigrantStrings.t('pm_agency_verify_desc', locale),
            onTap: () => context.push(
              AgencyVerificationScreen.route(
                countryId: profile?.countryId,
              ),
            ),
          ),
          _NavTile(
            icon: Icons.public,
            title: ProspectiveMigrantStrings.t('pm_country_heading', locale),
            subtitle: profile?.nationalityLabel.isNotEmpty == true
                ? profile!.nationalityLabel
                : ProspectiveMigrantStrings.t('pm_country_desc', locale),
            onTap: () => context.push('/prospective/country'),
          ),
          _NavTile(
            icon: Icons.description_outlined,
            title: ProspectiveMigrantStrings.t('pm_nav_contract', locale),
            subtitle: profile?.contractIntakeComplete == true
                ? profile!.contract.companyName
                : ProspectiveMigrantStrings.t('pm_contract_desc', locale),
            onTap: () {
              if (profile?.hasCountry != true) {
                _snack(context, ProspectiveMigrantStrings.t('pm_complete_country_first', locale));
                return;
              }
              context.push('/prospective/contract');
            },
          ),
          _NavTile(
            icon: Icons.calculate_outlined,
            title: ProspectiveMigrantStrings.t('pm_nav_preview', locale),
            subtitle: ProspectiveMigrantStrings.t('pm_preview_subtitle', locale),
            onTap: () {
              if (profile?.contractIntakeComplete != true) {
                _snack(context, ProspectiveMigrantStrings.t('pm_complete_contract_first', locale));
                return;
              }
              context.push('/prospective/preview');
            },
          ),
          _NavTile(
            icon: Icons.fact_check_outlined,
            title: ProspectiveMigrantStrings.t('pm_checklist_nav', locale),
            subtitle: EosbStrings.t('eosb_bys_section_subtitle', locale),
            onTap: () {
              if (profile?.hasCountry != true) {
                _snack(context, ProspectiveMigrantStrings.t('pm_complete_country_first', locale));
                return;
              }
              context.push('/prospective/checklist');
            },
          ),
          _NavTile(
            icon: Icons.flight_takeoff_outlined,
            title: ProspectiveMigrantStrings.t('pm_qvc_heading', locale),
            subtitle: ProspectiveMigrantStrings.t('pm_qvc_subtitle', locale),
            onTap: () => context.push('/prospective/qvc'),
          ),
          const SizedBox(height: AppSpacing.xl),
          const ProspectiveFlowActions(),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.purpleGlow),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.subtitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTypography.bodySmall, maxLines: 2),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
