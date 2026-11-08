import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/domain/services/home_country_support_service.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/migrant_support_resource_tile.dart';
import 'package:raabta/features/eosb/presentation/widgets/offer_authenticity_section.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/presentation/providers/prospective_migrant_providers.dart';
import 'package:raabta/features/prospective_migrant/presentation/widgets/prospective_flow_actions.dart';

class ProspectiveChecklistScreen extends ConsumerWidget {
  const ProspectiveChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(prospectiveLocaleProvider);
    final profile = ref.watch(prospectiveProfileProvider).valueOrNull;

    if (profile == null || !profile.hasCountry) {
      return GlassScreenScaffold(
        title: ProspectiveMigrantStrings.t('pm_checklist_nav', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Text(
            ProspectiveMigrantStrings.t('pm_complete_country_first', locale),
          ),
        ),
      );
    }

    final view = const HomeCountrySupportService().resolveBeforeYouSign(
      HomeCountryUserContext(nationality: profile.nationalityLabel),
    );
    final checklist = view.checklist;
    final offerChecklist = view.offerAuthenticityChecklist;

    return GlassScreenScaffold(
      title: ProspectiveMigrantStrings.t('pm_checklist_nav', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: checklist == null
          ? Center(child: Text(EosbStrings.t('eosb_bys_section_subtitle', locale)))
          : ListView(
              children: [
                Text(
                  EosbStrings.t('eosb_bys_section_subtitle', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (offerChecklist != null)
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: OfferAuthenticitySection(
                      checklist: offerChecklist,
                      locale: locale,
                      checkedKeys: profile.beforeYouSignChecked,
                      onToggle: (key, value) =>
                          _toggle(ref, profile, key, value),
                    ),
                  ),
                if (offerChecklist != null) const SizedBox(height: AppSpacing.md),
                _CheckSection(
                  title: EosbStrings.t('eosb_bys_fee_heading', locale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EosbStrings.t(checklist.maxFeeRuleKey, locale),
                        style: AppTypography.bodySmall,
                      ),
                      if (checklist.staleWarningKey != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          EosbStrings.t(checklist.staleWarningKey!, locale),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CheckSection(
                  title: EosbStrings.t('eosb_bys_flags_heading', locale),
                  child: Column(
                    children: checklist.redFlagKeys.map((key) {
                      return _CheckTile(
                        label: EosbStrings.t(key, locale),
                        checked: profile.beforeYouSignChecked[key] == true,
                        onChanged: (v) => _toggle(ref, profile, key, v),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  EosbStrings.t('eosb_bys_origin_verify_heading', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.purpleGlow,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...checklist.originVerificationChannels.map(
                  (r) => MigrantSupportResourceTile(
                    resource: r,
                    locale: locale,
                    compact: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  EosbStrings.t('eosb_bys_qatar_verify_heading', locale),
                  style: AppTypography.subtitle.copyWith(color: AppColors.info),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...view.qatarVerificationChannels.map(
                  (r) => MigrantSupportResourceTile(
                    resource: r,
                    locale: locale,
                    compact: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const ProspectiveFlowActions(),
              ],
            ),
    );
  }

  Future<void> _toggle(
    WidgetRef ref,
    ProspectiveProfile profile,
    String key,
    bool value,
  ) async {
    final updated = Map<String, bool>.from(profile.beforeYouSignChecked);
    updated[key] = value;
    await ref
        .read(prospectiveProfileProvider.notifier)
        .save(profile.copyWith(beforeYouSignChecked: updated));
  }
}

class _CheckSection extends StatelessWidget {
  const _CheckSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: AppTypography.bodySmall),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
