import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/horizontal_scroll_fade.dart';
import 'package:raabta/data/mock/home_feed_data.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Post / sell / promote shortcuts — separate from Daily Essentials.
class HomeQuickActionsZone extends ConsumerWidget {
  const HomeQuickActionsZone({super.key});

  static const _routes = [
    '/jobs',
    '/housing',
    '/marketplace',
    '/services',
    '/business-advertise',
  ];

  int get _visibleActionCount =>
      MonetizationState.showPremiumTierUi ? _routes.length : _routes.length - 1;

  static const double _rowHeight = 104;
  static const double _trailingPeek = AppSpacing.lg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          overline: AppShellStrings.t('home_quick_actions_overline', locale),
          title: AppShellStrings.t('home_quick_actions', locale),
          subtitle: AppShellStrings.t('home_quick_actions_sub', locale),
        ),
        const SizedBox(height: AppSpacing.lg),
        HorizontalScrollFade(
          height: _rowHeight,
          builder: (controller) {
            return ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(end: _trailingPeek),
              physics: const BouncingScrollPhysics(),
              itemCount: _visibleActionCount,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final action = kHomeQuickActions[index];
                return _QuickActionTile(
                  icon: action.icon,
                  label: AppShellStrings.t(action.labelKey, locale),
                  accentColor: action.color,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(_routes[index]);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          GlassCard(
            onTap: onTap,
            width: 56,
            height: 56,
            borderRadius: AppSpacing.radiusFull,
            padding: EdgeInsets.zero,
            glowColor: accentColor,
            glowIntensity: 0.22,
            backgroundColor: accentColor.withValues(alpha: 0.14),
            child: Center(
              child: Icon(icon, size: 24, color: accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textOnGlassSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
