import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/icons/raabta_icons.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/horizontal_scroll_fade.dart';
import 'package:raabta/data/mock/home_feed_data.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/home/widgets/raabta_core_service_chip.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Explore RAABTA — Core Services grid (≤8 tiles) plus full destination catalogue.
class HomeExploreZone extends ConsumerWidget {
  const HomeExploreZone({super.key});

  static const _routes = RaabtaIcons.exploreRoutes;
  static const _maxGridTiles = 8;
  static const _gridColumns = 3;

  static const _scrollHintKey = 'home_core_services_scroll_hint_shown';
  static const _railHeight = HomeCardTier.coreServiceChipHeight;
  static const _trailingPeek = AppSpacing.lg;

  /// Opens the complete Explore destination catalogue (all major product areas).
  static void showFullCatalog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _ExploreCatalogSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final useGrid = kHomeFeatureCards.length <= _maxGridTiles;
    final catalogLabel =
        AppShellStrings.t('home_browse_all_destinations', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          overline: AppShellStrings.t('home_explore_overline', locale),
          title: AppShellStrings.t('home_explore', locale),
          subtitle: AppShellStrings.t('home_explore_sub', locale),
          compact: true,
        ),
        const SizedBox(height: AppSpacing.md),
        if (useGrid)
          _CoreServicesGrid(locale: locale)
        else
          _CoreServicesRail(locale: locale),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          button: true,
          label: catalogLabel,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => showFullCatalog(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: const Size(0, 48),
                tapTargetSize: MaterialTapTargetSize.padded,
                foregroundColor: AppColors.brandFamilyMain,
                side: BorderSide(
                  color: AppColors.brandFamilyMain.withValues(alpha: 0.55),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              child: Text(
                catalogLabel,
                style: AppTypography.chipLabel.copyWith(
                  color: AppColors.brandFamilyMain,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoreServicesGrid extends StatelessWidget {
  const _CoreServicesGrid({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = HomeCardTier.coreServicesGridGap;
        final tileWidth = (constraints.maxWidth -
                spacing * (HomeExploreZone._gridColumns - 1)) /
            HomeExploreZone._gridColumns;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: HomeExploreZone._gridColumns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: HomeCardTier.coreServiceChipHeight,
          ),
          itemCount: kHomeFeatureCards.length,
          itemBuilder: (context, index) {
            final feature = kHomeFeatureCards[index];
            return _ExploreCoreServiceChip(
              feature: feature,
              locale: locale,
              index: index,
              width: tileWidth,
              onTap: () => context.push(HomeExploreZone._routes[index]),
            );
          },
        );
      },
    );
  }
}

class _ExploreCoreServiceChip extends StatelessWidget {
  const _ExploreCoreServiceChip({
    required this.feature,
    required this.locale,
    required this.index,
    required this.onTap,
    this.width = HomeCardTier.coreServiceChipWidth,
  });

  final HomeFeatureCard feature;
  final String locale;
  final int index;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return RaabtaCoreServiceChip(
      icon: feature.icon,
      label: AppShellStrings.t(feature.titleKey, locale),
      accentColor: AppColors.brandFamilyMain,
      entranceIndex: index,
      width: width,
      height: HomeCardTier.coreServiceChipHeight,
      iconBadgeSize: HomeCardTier.coreServiceIconBadge,
      iconSize: HomeCardTier.coreServiceIconSize,
      labelFontSize: HomeCardTier.coreServiceLabelFontSize,
      glowIntensity: HomeCardTier.coreServiceGlowIntensity,
      surfaceGlowColor: AppColors.brandFamilyMain,
      iconBadgeVariant: HomeIconBadgeVariant.exploreBrand,
      tileBorderRadius: HomeCardTier.coreServiceTileRadius,
      labelColor: AppColors.textPrimary,
      labelMaxLines: 2,
      labelMinLines: 2,
      topAlignedContent: true,
      centerLabelWhenTopAligned: true,
      contentPadding: HomeCardTier.coreServiceExploreTilePadding,
      iconLabelGap: HomeCardTier.coreServiceExploreIconLabelGap,
      onTap: onTap,
    );
  }
}

class _CoreServicesRail extends StatelessWidget {
  const _CoreServicesRail({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return HorizontalScrollFade(
      height: HomeExploreZone._railHeight,
      playScrollHintOnce: true,
      scrollHintPrefsKey: HomeExploreZone._scrollHintKey,
      builder: (controller) {
        return ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(
            end: HomeExploreZone._trailingPeek,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: kHomeFeatureCards.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: HomeCardTier.coreServicesGridGap),
          itemBuilder: (context, index) {
            final feature = kHomeFeatureCards[index];
            return _ExploreCoreServiceChip(
              feature: feature,
              locale: locale,
              index: index,
              onTap: () => context.push(HomeExploreZone._routes[index]),
            );
          },
        );
      },
    );
  }
}

class _ExploreCatalogSheet extends ConsumerWidget {
  const _ExploreCatalogSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

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
                            AppShellStrings.t('home_explore', locale),
                            style: AppTypography.headline2,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            AppShellStrings.t('home_explore_sub', locale),
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
                    mainAxisExtent: HomeCardTier.homeCatalogTileExtent,
                  ),
                  itemCount: kHomeFeatureCards.length,
                  itemBuilder: (context, index) {
                    final feature = kHomeFeatureCards[index];
                    return _ExploreServiceTile(
                      icon: feature.icon,
                      title: AppShellStrings.t(feature.titleKey, locale),
                      subtitle: AppShellStrings.t(feature.subtitleKey, locale),
                      onTap: () {
                        Navigator.pop(context);
                        context.push(HomeExploreZone._routes[index]);
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

class _ExploreServiceTile extends StatelessWidget {
  const _ExploreServiceTile({
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
    return Semantics(
      button: true,
      label: title,
      child: SizedBox(
        height: HomeCardTier.homeCatalogTileExtent,
        child: GlassCard(
          onTap: onTap,
          height: HomeCardTier.homeCatalogTileExtent,
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: HomeCardTier.coreServiceTileRadius,
          glowColor: AppColors.brandFamilyMain,
          glowIntensity: HomeCardTier.coreServiceGlowIntensity,
          backgroundColor: AppColors.brandFamilyMain.withValues(
            alpha: AppColors.isLight ? 0.05 : 0.08,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: HomeIconBadge(
                  icon: icon,
                  accentColor: AppColors.brandFamilyMain,
                  size: HomeCardTier.compactIconBadgeSize,
                  iconSize: HomeCardTier.coreServiceIconSize,
                  variant: HomeIconBadgeVariant.exploreBrand,
                  chipBorderRadius: HomeCardTier.coreServiceIconChipRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          title,
                          style: AppTypography.title.copyWith(
                            fontSize: HomeCardTier.toolTitleFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          subtitle,
                          style: AppTypography.caption.copyWith(
                            fontSize: 12,
                            height: 1.25,
                            color: AppColors.textOnGlassMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
