import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/data/home_all_services_catalog.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Explore Raabta hubs — Daily Essentials–style grouped surface.
class HomeAllServicesGroupedList extends StatelessWidget {
  const HomeAllServicesGroupedList({
    super.key,
    required this.locale,
    required this.onOpenRoute,
  });

  final String locale;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dividerColor = RaabtaSolidSurfaceTokens.hairline(
      RaabtaSolidSurfaceFamily.teal,
      brightness,
    );
    final entries = kHomeAllServiceEntries;

    return GlassContainer(
      key: const Key('home_all_services_grouped_list'),
      padding: EdgeInsets.zero,
      borderRadius: HomeCardTier.dailyEssentialTileRadius,
      glowIntensity: 0,
      solidSurfaceFamily: RaabtaSolidSurfaceFamily.teal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _AllServicesGroupedRow(
              entry: entries[i],
              locale: locale,
              onTap: () => onOpenRoute(entries[i].route),
            ),
            if (i < entries.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: dividerColor,
                indent: HomeCardTier.dailyEssentialTilePadding +
                    HomeCardTier.dailyEssentialIconBadge +
                    10,
              ),
          ],
        ],
      ),
    );
  }
}

class _AllServicesGroupedRow extends StatelessWidget {
  const _AllServicesGroupedRow({
    required this.entry,
    required this.locale,
    required this.onTap,
  });

  final HomeAllServiceEntry entry;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = homeAllServiceTitle(entry, locale);
    final subtitle = homeAllServiceSubtitle(entry, locale);

    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: HomeCardTier.dailyEssentialGroupedRowHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HomeCardTier.dailyEssentialTilePadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HomeIconBadge(
                    icon: entry.icon,
                    accentColor: AppColors.brandFamilyMain,
                    size: HomeCardTier.dailyEssentialIconBadge,
                    iconSize: HomeCardTier.dailyEssentialIconSize,
                    variant: HomeIconBadgeVariant.exploreBrand,
                    chipBorderRadius: HomeCardTier.dailyEssentialIconChipRadius,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTypography.chipLabel.copyWith(
                            fontSize: HomeCardTier.dailyEssentialTitleFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textOnGlassMuted,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    HomeDirectionalIcons.forwardArrowRounded(context),
                    size: AppSpacing.iconSm,
                    color: AppColors.textOnGlassMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}