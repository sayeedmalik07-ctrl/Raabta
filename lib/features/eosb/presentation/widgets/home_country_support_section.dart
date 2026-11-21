import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/migrant_support_resource_tile.dart';
import 'package:raabta/features/eosb/providers/home_country_support_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dismissPrefsKey = 'eosb_home_country_support_dismissed';

class HomeCountrySupportSection extends ConsumerStatefulWidget {
  const HomeCountrySupportSection({super.key, required this.locale});

  final String locale;

  @override
  ConsumerState<HomeCountrySupportSection> createState() =>
      _HomeCountrySupportSectionState();
}

class _HomeCountrySupportSectionState
    extends ConsumerState<HomeCountrySupportSection> {
  bool _dismissed = false;
  bool _loadedDismiss = false;

  @override
  void initState() {
    super.initState();
    _loadDismissState();
  }

  Future<void> _loadDismissState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dismissed = prefs.getBool(_dismissPrefsKey) ?? false;
      _loadedDismiss = true;
    });
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissPrefsKey, true);
    if (!mounted) return;
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedDismiss || _dismissed) return const SizedBox.shrink();

    final viewAsync = ref.watch(homeCountrySupportViewProvider);
    return viewAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (view) {
        if (view.status == HomeCountrySupportStatus.hidden) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.public, color: AppColors.info, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            EosbStrings.t('eosb_hcs_section_title', widget.locale),
                            style: AppTypography.title.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            EosbStrings.t('eosb_hcs_section_subtitle', widget.locale),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: EosbStrings.t('eosb_hcs_dismiss', widget.locale),
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: _dismiss,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (view.status == HomeCountrySupportStatus.comingSoon)
                  Text(
                    EosbStrings.t('eosb_hcs_coming_soon', widget.locale)
                        .replaceAll('{country}', view.countryLabel ?? ''),
                    style: AppTypography.body,
                  )
                else ...[
                  ...view.nationalResources.map(
                    (resource) => MigrantSupportResourceTile(
                      resource: resource,
                      locale: widget.locale,
                    ),
                  ),
                  ...view.regionalSections.expand(
                    (region) => [
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        EosbStrings.t(region.titleKey, widget.locale),
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.purpleGlow,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...region.resources.map(
                        (resource) => MigrantSupportResourceTile(
                          resource: resource,
                          locale: widget.locale,
                        ),
                      ),
                    ],
                  ),
                ],
                if (view.qatarProcedureChannels.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    EosbStrings.t('eosb_qatar_section_title', widget.locale),
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    EosbStrings.t('eosb_qatar_section_subtitle', widget.locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...view.qatarProcedureChannels.map(
                    (resource) => MigrantSupportResourceTile(
                      resource: resource,
                      locale: widget.locale,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
