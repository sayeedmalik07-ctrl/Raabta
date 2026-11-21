import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/data/service_front_groups.dart';
import 'package:raabta/screens/services/data/service_taxonomy.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/utils/service_subcategory_visuals.dart';
import 'package:raabta/screens/services/widgets/service_hub_subscreen_scaffold.dart';
import 'package:raabta/screens/services/widgets/service_subcategory_tile.dart';

/// Searchable **12 front groups** with leaf previews — long tail via search (Decision D5).
class ServicesAllServicesScreen extends ConsumerStatefulWidget {
  const ServicesAllServicesScreen({super.key});

  static const screenKey = Key('services_all_services_screen');

  @override
  ConsumerState<ServicesAllServicesScreen> createState() =>
      _ServicesAllServicesScreenState();
}

class _ServicesAllServicesScreenState
    extends ConsumerState<ServicesAllServicesScreen> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final matchingGroups = matchingFrontGroupIds(_query);

    return KeyedSubtree(
      key: ServicesAllServicesScreen.screenKey,
      child: ServiceHubSubscreenScaffold(
        title: ServicesStrings.t('hub_all_services_title', locale),
        subtitle: ServicesStrings.t('hub_all_services_screen_subtitle', locale),
        onBack: () => Navigator.of(context).pop(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            GlassTextField(
              key: const Key('services_all_services_search'),
              controller: _queryController,
              label: ServicesStrings.t('hub_all_services_search_label', locale),
              hint: ServicesStrings.t('hub_all_services_search_hint', locale),
              icon: Icons.search_rounded,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppSpacing.md),
            HubNoticeBanner.hostNotice(locale: locale),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ServicesStrings.t('hub_all_services_groups_section', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (matchingGroups.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: GlassEmptyState(
                  accent: GlassEmptyStateAccent.brand,
                  icon: Icons.search_off_rounded,
                  title: ServicesStrings.t('hub_all_services_no_groups', locale),
                  description:
                      ServicesStrings.t('hub_all_services_no_groups_body', locale),
                ),
              )
            else
              ...matchingGroups.map((fgId) {
                final label =
                    ServiceFrontGroupLabels.labelEnglish(fgId) ?? fgId;
                final anchor =
                    ServiceFrontGroupLabels.anchorCategoryId(fgId) ?? '';
                final tapCategoryId =
                    primaryCategoryIdForFrontGroupTap(fgId, _query) ?? anchor;
                final icon = ServiceFrontGroupLabels.iconFor(fgId);
                final visualPaletteId =
                    tapCategoryId.isNotEmpty ? tapCategoryId : anchor;
                final visual = ServiceSubcategoryVisuals.forCategory(
                  categoryId: visualPaletteId.isNotEmpty
                      ? visualPaletteId
                      : 'home_cleaning',
                  icon: icon,
                );
                final preview = previewLeavesForFrontGroup(fgId, _query);
                final categories = categoriesForFrontGroup(fgId);
                final categoryCount = categories.length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ServiceSubcategoryTile(
                    label: label,
                    visual: visual,
                    compact: true,
                    onTap: () {
                      if (tapCategoryId.isEmpty) return;
                      HapticFeedback.selectionClick();
                      context.push('/services/category/$tapCategoryId');
                    },
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ServicesStrings.format(
                            'hub_all_services_category_count',
                            locale,
                            params: {'count': '$categoryCount'},
                          ),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.brandFamilyMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (preview.isNotEmpty)
                          SizedBox(
                            width: 160,
                            child: Text(
                              preview,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ServicesStrings.t('hub_all_services_long_tail_note', locale),
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
