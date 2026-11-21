import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/horizontal_scroll_fade.dart';
import 'package:raabta/features/home/providers/home_chip_status_providers.dart';
import 'package:raabta/features/home/utils/home_responsive_layout.dart';
import 'package:raabta/features/home/providers/home_personalization_providers.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_essential_tools_zone.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/home/widgets/home_tool_catalog_sheet.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/raabta_core_service_chip.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Qatar Life — horizontal lifestyle capability rail on Home.
class HomeQatarLifeZone extends ConsumerWidget {
  const HomeQatarLifeZone({super.key});

  static const _scrollHintKey = 'home_qatar_life_scroll_hint_shown';
  static const _railHeight = HomeCardTier.qatarLifeRailChipHeight;
  static const _trailingPeek = AppSpacing.lg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final routes = ref.watch(homeQatarLifeRoutesProvider);
    final sectionTitle = AppShellStrings.t('home_qatar_life', locale);

    final tools = routes
        .map(
          (route) => QuickActionsHub.tools.firstWhere(
            (tool) => tool.route == route,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: sectionTitle,
          compact: true,
          actionText: AppShellStrings.t('home_see_all', locale),
          onActionTap: () => HomeToolCatalogSheet.show(
            context,
            routes: HomeEssentialToolsZone.qatarLifeRoutes,
            titleKey: 'home_qatar_life',
            subtitleKey: 'home_qatar_life_sub',
          ),
        ),
        Semantics(
          container: true,
          label: sectionTitle,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useScroll = HomeResponsiveLayout.qatarLifeUsesHorizontalScroll(
                constraints.maxWidth,
              );

              Widget buildChip(int index, double width) {
                final tool = tools[index];
                final shortLabel =
                    QuickActionsStrings.t(tool.shortLabelKey, locale);
                final status =
                    watchHomeChipStatus(ref, tool.route, locale);

                return RaabtaCoreServiceChip(
                  icon: tool.icon,
                  label: shortLabel,
                  accentColor: AppColors.tealFamilyMain,
                  entranceIndex: index,
                  enableEntranceAnimation: false,
                  width: width,
                  height: HomeCardTier.qatarLifeRailChipHeight,
                  tileBorderRadius: HomeCardTier.qatarLifeRailChipRadius,
                  iconBadgeSize: HomeCardTier.qatarLifeRailIconBadge,
                  iconSize: HomeCardTier.qatarLifeRailIconSize,
                  labelFontSize: HomeCardTier.qatarLifeRailLabelFontSize,
                  labelFontWeight: FontWeight.w700,
                  labelColor: AppColors.textPrimary,
                  labelMaxLines: 2,
                  topAlignedContent: true,
                  solidSurfaceFamily: RaabtaSolidSurfaceFamily.teal,
                  glowIntensity: 0,
                  surfaceGlowColor: AppColors.tealFamilyMain,
                  iconBadgeVariant: HomeIconBadgeVariant.tealBrand,
                  status: status,
                  onTap: () => QuickActionsHub.navigateTo(context, tool.route),
                );
              }

              if (!useScroll) {
                const gap = 10.0;
                final chipWidth = tools.length <= 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - gap * (tools.length - 1)) /
                        tools.length;
                return SizedBox(
                  height: _railHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < tools.length; i++) ...[
                        if (i > 0) const SizedBox(width: gap),
                        SizedBox(
                          width: chipWidth,
                          child: buildChip(i, chipWidth),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return HorizontalScrollFade(
                height: _railHeight,
                playScrollHintOnce: true,
                scrollHintPrefsKey: _scrollHintKey,
                builder: (controller) {
                  return ListView.separated(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsetsDirectional.only(end: _trailingPeek),
                    physics: const BouncingScrollPhysics(),
                    itemCount: tools.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => buildChip(
                      index,
                      HomeCardTier.qatarLifeRailChipWidth,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
