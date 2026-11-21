import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/data/home_all_services_catalog.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Quiet bottom-of-home entry to [HomeAllServicesScreen] (Part C).
class HomeServicesStripZone extends ConsumerWidget {
  const HomeServicesStripZone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final stripLabel = AppShellStrings.t('home_browse_all_destinations', locale);
    final semanticsLabel =
        AppShellStrings.t('home_services_strip_semantics', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: AppShellStrings.t('home_explore', locale),
          compact: true,
        ),
        Semantics(
          button: true,
          label: semanticsLabel,
          child: GlassCard(
            onTap: () => context.push('/home/all-services'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            borderRadius: HomeCardTier.homeCardRadius,
            glowIntensity: HomeCardTier.dailyEssentialsGlowIntensity,
            glowColor: AppColors.brandFamilyMain,
            backgroundColor: AppColors.brandFamilyMain.withValues(
              alpha: AppColors.isLight ? 0.04 : 0.06,
            ),
            child: Row(
              children: [
                _ServiceIconCluster(locale: locale),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    stripLabel,
                    style: AppTypography.title.copyWith(
                      fontSize: HomeCardTier.toolTitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: AppSpacing.iconMd,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceIconCluster extends StatelessWidget {
  const _ServiceIconCluster({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final entries = kHomeAllServiceEntries;
    final display = entries.length > 4 ? entries.sublist(0, 4) : entries;

    return SizedBox(
      width: 88,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < display.length; i++)
            Positioned(
              left: i * 18.0,
              child: HomeIconBadge(
                icon: display[i].icon,
                accentColor: AppColors.brandFamilyMain,
                size: 28,
                iconSize: 14,
                variant: HomeIconBadgeVariant.exploreBrand,
                chipBorderRadius: 10,
              ),
            ),
        ],
      ),
    );
  }
}