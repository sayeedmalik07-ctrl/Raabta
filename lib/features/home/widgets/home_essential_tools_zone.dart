import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/providers/home_chip_status_providers.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';
import 'package:raabta/features/home/domain/truth_home_priority_resolver.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';
import 'package:raabta/features/home/providers/truth_home_priority_provider.dart';
import 'package:raabta/features/home/utils/home_truth_chip_navigation.dart';
import 'package:raabta/features/home/widgets/home_essential_tool_card.dart';
import 'package:raabta/features/home/widgets/home_truth_chip_card.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/home/widgets/home_truth_engine_section_header.dart';
import 'package:raabta/features/home/widgets/home_tool_rail_titles.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/features/home/utils/home_responsive_layout.dart';
import 'package:raabta/providers/visa_providers.dart';

enum HomeToolsLayout { rail, grid }

/// Parameterized tool section for Home (Truth Engines, Qatar Life, etc.).
class HomeEssentialToolsZone extends ConsumerWidget {
  const HomeEssentialToolsZone({
    super.key,
    required this.routes,
    required this.overlineKey,
    required this.titleKey,
    required this.subtitleKey,
    this.cardWidth = 176,
    this.rowHeight = 132,
    this.cardSeparator = AppSpacing.md,
    this.glowIntensity = HomeCardTier.toolGlowIntensity,
    this.titleFontSize = HomeCardTier.toolTitleFontSize,
    this.trailingPeek = AppSpacing.lg,
    this.maxVisible,
    this.seeAllLabelKey,
    this.onSeeAllTap,
    this.layout = HomeToolsLayout.grid,
    this.compactHeader = true,
    this.accentColorOverride,
    this.surfaceGlowColorOverride,
    this.iconBadgeVariant,
    this.truthEngineSection = false,
  });

  final List<String> routes;
  final String overlineKey;
  final String titleKey;
  final String subtitleKey;
  final double cardWidth;
  final double rowHeight;
  final double cardSeparator;
  final double glowIntensity;
  final double titleFontSize;
  final double trailingPeek;
  final int? maxVisible;
  final String? seeAllLabelKey;
  final VoidCallback? onSeeAllTap;
  final HomeToolsLayout layout;
  final bool compactHeader;
  final Color? accentColorOverride;
  final Color? surfaceGlowColorOverride;
  final HomeIconBadgeVariant? iconBadgeVariant;
  final bool truthEngineSection;

  static double _truthEngineGridExtent(
    WidgetRef ref,
    List<QuickActionTool> tools,
  ) {
    var inviteOnly = true;
    for (final tool in tools) {
      final engine = TruthChipEngineRoutes.fromHomeRoute(tool.route);
      if (engine == null) continue;
      final status = ref.watch(truthChipWatchStatusProvider(engine));
      if (!status.isInvite ||
          status.showsProgressBar ||
          status.hasRevealableDetail) {
        inviteOnly = false;
        break;
      }
    }
    return inviteOnly
        ? HomeCardTier.truthEngineInviteGridExtent
        : HomeCardTier.truthEngineGridExtent;
  }

  static const truthEngineRoutes = [
    '/eosb',
    '/sponsorship-transfer',
    '/tenancy',
    '/health-insurance',
  ];

  static const qatarLifeRoutes = [
    '/trip-planner',
    '/climate-navigator',
    '/queue-avoidance',
    '/arabic-companion',
    '/know-qatar',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final tools = routes
        .map(
          (route) => QuickActionsHub.tools.firstWhere(
            (tool) => tool.route == route,
          ),
        )
        .toList();
    final visibleTools = maxVisible == null
        ? tools
        : tools.take(maxVisible!).toList(growable: false);

    final sectionTitle = AppShellStrings.t(titleKey, locale);
    final seeAllLabel = seeAllLabelKey == null
        ? null
        : AppShellStrings.t(seeAllLabelKey!, locale);
    final gridExtent = truthEngineSection
        ? _truthEngineGridExtent(ref, visibleTools)
        : HomeCardTier.toolGridExtent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (truthEngineSection)
          HomeTruthEngineSectionHeader(
            overline: AppShellStrings.t(overlineKey, locale),
            title: sectionTitle,
            subtitle: AppShellStrings.t(subtitleKey, locale),
            locale: locale,
            compact: compactHeader,
          )
        else
          HomeSectionHeader(
            overline: AppShellStrings.t(overlineKey, locale),
            title: sectionTitle,
            subtitle: AppShellStrings.t(subtitleKey, locale),
            actionText: seeAllLabel,
            onActionTap: onSeeAllTap,
            compact: compactHeader,
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = MediaQuery.sizeOf(context).width;
            final useGrid = layout == HomeToolsLayout.grid ||
                constraints.maxWidth >= HomeResponsiveLayout.compactMax;
            if (useGrid) {
              final crossAxisCount = truthEngineSection
                  ? HomeResponsiveLayout.truthEngineGridCrossAxisCount(
                      viewportWidth: viewportWidth,
                      itemCount: visibleTools.length,
                    )
                  : (constraints.maxWidth >= HomeResponsiveLayout.compactMax &&
                          visibleTools.length >= 4
                      ? 4
                      : 2);
              return Semantics(
                container: true,
                label: sectionTitle,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: cardSeparator,
                    mainAxisSpacing: cardSeparator,
                    mainAxisExtent: gridExtent,
                  ),
                  itemCount: visibleTools.length,
                  itemBuilder: (context, index) {
                    final tool = visibleTools[index];
                    return _HomeEssentialToolCardWithStatus(
                      tool: tool,
                      locale: locale,
                      expand: true,
                      rowHeight: gridExtent,
                      cardWidth: cardWidth,
                      glowIntensity: glowIntensity,
                      titleFontSize: titleFontSize,
                      iconBadgeSize: HomeCardTier.compactIconBadgeSize,
                      accentColorOverride: accentColorOverride,
                      surfaceGlowColorOverride: surfaceGlowColorOverride,
                      iconBadgeVariant: iconBadgeVariant,
                      truthEngineChip: truthEngineSection,
                    );
                  },
                ),
              );
            }

            return Semantics(
              container: true,
              label: '$sectionTitle. Swipe horizontally for more tools.',
              child: SizedBox(
                height: rowHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.only(end: trailingPeek),
                  physics: const BouncingScrollPhysics(),
                  itemCount: visibleTools.length,
                  separatorBuilder: (_, _) => SizedBox(width: cardSeparator),
                  itemBuilder: (context, index) {
                    final tool = visibleTools[index];
                    return _HomeEssentialToolCardWithStatus(
                      tool: tool,
                      locale: locale,
                      cardWidth: cardWidth,
                      rowHeight: rowHeight,
                      glowIntensity: glowIntensity,
                      titleFontSize: titleFontSize,
                      accentColorOverride: accentColorOverride,
                      surfaceGlowColorOverride: surfaceGlowColorOverride,
                      iconBadgeVariant: iconBadgeVariant,
                      truthEngineChip: truthEngineSection,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HomeEssentialToolCardWithStatus extends ConsumerWidget {
  const _HomeEssentialToolCardWithStatus({
    required this.tool,
    required this.locale,
    required this.rowHeight,
    required this.cardWidth,
    required this.glowIntensity,
    required this.titleFontSize,
    this.expand = false,
    this.iconBadgeSize = HomeCardTier.standardIconBadgeSize,
    this.accentColorOverride,
    this.surfaceGlowColorOverride,
    this.iconBadgeVariant,
    this.truthEngineChip = false,
  });

  final QuickActionTool tool;
  final String locale;
  final double rowHeight;
  final double cardWidth;
  final double glowIntensity;
  final double titleFontSize;
  final bool expand;
  final double iconBadgeSize;
  final Color? accentColorOverride;
  final Color? surfaceGlowColorOverride;
  final HomeIconBadgeVariant? iconBadgeVariant;
  final bool truthEngineChip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legacy = watchHomeChipStatus(ref, tool.route, locale);
    final title = HomeToolRailTitles.forRoute(tool.route, locale);

    if (truthEngineChip) {
      final engine = TruthChipEngineRoutes.fromHomeRoute(tool.route);
      if (engine != null) {
        final truthStatus = watchTruthChipStatus(ref, engine);
        final priority = ref.watch(truthHomePriorityProvider);
        final displayStatus = TruthHomePriorityResolver.forChipDisplay(
          chip: truthStatus,
          priority: priority,
        );
        final revealed = ref.watch(homeTruthEngineDetailsRevealedProvider);
        return HomeTruthChipCard(
          icon: tool.icon,
          title: title,
          accentColor: accentColorOverride ?? tool.accentColor,
          surfaceGlowColor:
              surfaceGlowColorOverride ?? AppColors.cyanGlow,
          iconBadgeVariant:
              iconBadgeVariant ?? HomeIconBadgeVariant.standard,
          expand: expand,
          rowHeight: rowHeight,
          cardWidth: cardWidth,
          glowIntensity: glowIntensity,
          titleFontSize: titleFontSize,
          iconBadgeSize: iconBadgeSize,
          status: displayStatus,
          locale: locale,
          detailsRevealed: revealed,
          onTap: () => QuickActionsHub.navigateTo(
            context,
            resolveTruthChipTapRoute(truthStatus),
          ),
        );
      }
    }

    return HomeEssentialToolCard(
      icon: tool.icon,
      title: title,
      accentColor: accentColorOverride ?? tool.accentColor,
      surfaceGlowColor:
          surfaceGlowColorOverride ?? AppColors.cyanGlow,
      iconBadgeVariant: iconBadgeVariant ?? HomeIconBadgeVariant.standard,
      expand: expand,
      rowHeight: rowHeight,
      cardWidth: cardWidth,
      glowIntensity: glowIntensity,
      titleFontSize: titleFontSize,
      iconBadgeSize: iconBadgeSize,
      status: legacy,
      onTap: () => QuickActionsHub.navigateTo(context, tool.route),
    );
  }
}
