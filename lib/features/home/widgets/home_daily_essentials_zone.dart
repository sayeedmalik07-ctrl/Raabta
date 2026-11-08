import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
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
          overline: AppShellStrings.t('home_daily_essentials_overline', locale),
          title: AppShellStrings.t('home_daily_essentials', locale),
          subtitle: AppShellStrings.t('home_daily_essentials_sub', locale),
          actionText: AppShellStrings.t('home_see_all', locale),
          onActionTap: () => QuickActionsHub.show(
            context,
            presentation: QuickActionsHubPresentation.dailyEssentialsTeal,
          ),
          compact: true,
        ),
        const SizedBox(height: AppSpacing.lg),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < tools.length; i++) ...[
          if (i > 0)
            const SizedBox(height: HomeCardTier.dailyEssentialTileGap),
          _DailyEssentialCmpTile(
            tool: tools[i],
            locale: locale,
            status: watchHomeChipStatus(ref, tools[i].route, locale),
            onTap: () => onOpen(tools[i].route),
          ),
        ],
      ],
    );
  }
}

/// Kit `.cmp .card` — horizontal row, 16 radius, teal family chip.
class _DailyEssentialCmpTile extends StatelessWidget {
  const _DailyEssentialCmpTile({
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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeCardTier.dailyEssentialTilePadding,
            vertical: HomeCardTier.dailyEssentialTilePaddingVertical,
          ),
          borderRadius: HomeCardTier.dailyEssentialTileRadius,
          glowColor: AppColors.tealFamilyMain,
          glowIntensity: HomeCardTier.dailyEssentialsGlowIntensity,
          backgroundColor: AppColors.tealFamilyMain.withValues(
            alpha: AppColors.isLight ? 0.06 : 0.08,
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
                  mainAxisSize: MainAxisSize.min,
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
            ],
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
    if (status.isLoading || status.line.isEmpty) {
      return const SizedBox(height: HomeChipStatusLine.slotHeight);
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
