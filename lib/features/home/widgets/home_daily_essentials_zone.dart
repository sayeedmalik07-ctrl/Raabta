import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/data/daily_essential_routes.dart';
import 'package:raabta/features/home/domain/home_chip_status.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/providers/daily_essentials_order_provider.dart';
import 'package:raabta/features/home/providers/home_chip_status_providers.dart';
import 'package:raabta/features/home/widgets/home_chip_status_line.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/quick_actions/l10n/quick_actions_strings.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Daily Essentials — design kit cmp stack (teal tiles, amber status dots).
class HomeDailyEssentialsZone extends ConsumerWidget {
  const HomeDailyEssentialsZone({super.key});

  static const _homeVisibleCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final essentialsAsync = ref.watch(dailyEssentialsOrderProvider);
    final tools = _visibleTools(essentialsAsync.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: AppShellStrings.t('home_daily_essentials', locale),
          compact: true,
          actionText: AppShellStrings.t('home_see_all', locale),
          onActionTap: () => QuickActionsHub.show(
            context,
            presentation: QuickActionsHubPresentation.dailyEssentialsTeal,
          ),
        ),
        _EssentialTileStack(
          tools: tools,
          locale: locale,
          onOpen: (route) => _openTool(context, ref, route),
        ),
      ],
    );
  }

  List<QuickActionTool> _visibleTools(List<QuickActionTool>? rankedAll) {
    final ranked = rankedAll ?? DailyEssentialRoutes.catalogTools();
    if (ranked.length <= _homeVisibleCount) return ranked;
    return ranked.take(_homeVisibleCount).toList(growable: false);
  }

  Future<void> _openTool(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) async {
    await ref.read(dailyEssentialsOrderProvider.notifier).recordOpen(route);
    if (context.mounted) {
      await context.push(route);
    }
  }
}

class _EssentialTileStack extends ConsumerWidget {
  const _EssentialTileStack({
    required this.tools,
    required this.locale,
    required this.onOpen,
  });

  final List<QuickActionTool> tools;
  final String locale;
  final Future<void> Function(String route) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final dividerColor = RaabtaSolidSurfaceTokens.hairline(
      RaabtaSolidSurfaceFamily.teal,
      brightness,
    );

    return GlassContainer(
      key: const Key('home_daily_essentials_grouped_list'),
      padding: EdgeInsets.zero,
      borderRadius: HomeCardTier.dailyEssentialTileRadius,
      glowIntensity: 0,
      solidSurfaceFamily: RaabtaSolidSurfaceFamily.teal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < tools.length; i++) ...[
            _DailyEssentialGroupedRow(
              tool: tools[i],
              locale: locale,
              status: watchHomeChipStatus(ref, tools[i].route, locale),
              onTap: () => onOpen(tools[i].route),
            ),
            if (i < tools.length - 1)
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

/// Single row inside the grouped list — no per-row surface.
class _DailyEssentialGroupedRow extends StatelessWidget {
  const _DailyEssentialGroupedRow({
    required this.tool,
    required this.locale,
    required this.status,
    required this.onTap,
  });

  final QuickActionTool tool;
  final String locale;
  final HomeChipStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = QuickActionsStrings.t(tool.shortLabelKey, locale);
    final semanticsLabel = status.isLoading || status.line.isEmpty
        ? label
        : '$label, ${status.line}';

    return Semantics(
      button: true,
      label: semanticsLabel,
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
                    icon: tool.icon,
                    accentColor: AppColors.tealFamilyMain,
                    size: HomeCardTier.dailyEssentialIconBadge,
                    iconSize: HomeCardTier.dailyEssentialIconSize,
                    variant: HomeIconBadgeVariant.tealBrand,
                    chipBorderRadius: HomeCardTier.dailyEssentialIconChipRadius,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: AppTypography.chipLabel.copyWith(
                            fontSize: HomeCardTier.dailyEssentialTitleFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _DailyEssentialMicroLine(status: status),
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

class _DailyEssentialMicroLine extends StatelessWidget {
  const _DailyEssentialMicroLine({required this.status});

  final HomeChipStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.isLoading) {
      return const SizedBox(height: HomeChipStatusLine.slotHeight);
    }
    if (status.line.isEmpty) {
      return const SizedBox.shrink();
    }

    final isAttention = status.tone == HomeChipStatusTone.attention;
    final textColor = isAttention
        ? AppColors.warning
        : AppColors.textOnGlassMuted;

    return SizedBox(
      height: HomeChipStatusLine.slotHeight,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAttention) ...[
              Container(
                key: const Key('daily_essential_status_dot'),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                status.line,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
