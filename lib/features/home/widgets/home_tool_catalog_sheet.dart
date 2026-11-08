import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_essential_tool_card.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_tool_rail_titles.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Bottom sheet listing a tool route catalogue (Qatar Life, etc.).
class HomeToolCatalogSheet extends ConsumerWidget {
  const HomeToolCatalogSheet({
    super.key,
    required this.routes,
    required this.titleKey,
    required this.subtitleKey,
  });

  final List<String> routes;
  final String titleKey;
  final String subtitleKey;

  static Future<void> show(
    BuildContext context, {
    required List<String> routes,
    required String titleKey,
    required String subtitleKey,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => HomeToolCatalogSheet(
        routes: routes,
        titleKey: titleKey,
        subtitleKey: subtitleKey,
      ),
    );
  }

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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: AppSpacing.radiusLg,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorderBright,
                      borderRadius: BorderRadius.circular(AppSpacing.xxs),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppShellStrings.t(titleKey, locale),
                            style: AppTypography.headline2,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            AppShellStrings.t(subtitleKey, locale),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textOnGlassMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GlassContainer(
                      onTap: () => Navigator.pop(context),
                      borderRadius: AppSpacing.radiusSm,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.close_rounded,
                        size: AppSpacing.iconSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    mainAxisExtent: 118,
                  ),
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    return HomeEssentialToolCard(
                      icon: tool.icon,
                      title: HomeToolRailTitles.forRoute(tool.route, locale),
                      accentColor: AppColors.tealFamilyMain,
                      surfaceGlowColor: AppColors.tealFamilyMain,
                      iconBadgeVariant: HomeIconBadgeVariant.tealBrand,
                      topAlignedContent: true,
                      expand: true,
                      rowHeight: 118,
                      cardWidth: 152,
                      glowIntensity: HomeCardTier.lifestyleChipGlowIntensity,
                      titleFontSize: HomeCardTier.toolTitleFontSize,
                      iconBadgeSize: HomeCardTier.compactIconBadgeSize,
                      onTap: () {
                        Navigator.pop(context);
                        context.push(tool.route);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
