import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/utils/home_directional_icons.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/intelligence/presentation/widgets/intelligence_insight_row.dart';
import 'package:raabta/models/intelligence/intelligence_priority.dart';
import 'package:raabta/services/intelligence/home_intelligence_focus_service.dart';

/// Premium single-focus recommendation card — presentation only.
class TodaysFocusCard extends StatelessWidget {
  const TodaysFocusCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.icon,
    required this.onTap,
    this.actionLabel = 'Continue',
    this.estimatedTime = '2 min',
    this.progress = 0,
    this.completed = false,
    this.highPriority = false,
    this.locale = 'English',
    this.intelligenceItems = const [],
  });

  final String category;
  final String title;
  final String description;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;
  final String actionLabel;
  final String estimatedTime;
  final double progress;
  final bool completed;
  final bool highPriority;
  final String locale;
  final List<HomeIntelligenceFocusItem> intelligenceItems;

  double get _clampedProgress => progress.clamp(0.0, 1.0);

  int get _progressPercent => (_clampedProgress * 100).round();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: accentColor,
      glowIntensity: completed ? 0 : HomeCardTier.contextualGlowIntensity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            category: category,
            accentColor: accentColor,
            estimatedTime: estimatedTime,
          ),
          const SizedBox(height: AppSpacing.md),
          _MainContent(
            icon: icon,
            accentColor: accentColor,
            title: title,
            description: description,
          ),
          if (intelligenceItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            HomeTodayIntelligenceAlerts(
              items: intelligenceItems,
              locale: locale,
            ),
          ],
          if (!completed && progress > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _ProgressSection(
              progress: _clampedProgress,
              progressPercent: _progressPercent,
              accentColor: accentColor,
              locale: locale,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (completed)
            _CompletedFooter(locale: locale)
          else
            _ActiveFooter(
              highPriority: highPriority,
              actionLabel: actionLabel,
              locale: locale,
            ),
        ],
      ),
    );
  }
}

/// Intelligence rows shown below the Today hero when focus alerts exist.
class HomeTodayIntelligenceAlerts extends StatelessWidget {
  const HomeTodayIntelligenceAlerts({
    super.key,
    required this.items,
    required this.locale,
  });

  final List<HomeIntelligenceFocusItem> items;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppShellStrings.t('home_intelligence_alerts', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map(
          (item) => _IntelligenceAlertRow(
            item: item,
            locale: locale,
            onTap: () => showIntelligenceExplanationSheet(
              context,
              title: item.title,
              explanation: item.explanation,
              actionCapability: item.capability,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntelligenceAlertRow extends StatelessWidget {
  const _IntelligenceAlertRow({
    required this.item,
    required this.locale,
    required this.onTap,
  });

  final HomeIntelligenceFocusItem item;
  final String locale;
  final VoidCallback onTap;

  Color get _priorityColor {
    return item.priority == IntelligencePriority.critical
        ? AppColors.roseGlow
        : AppColors.amberGlow;
  }

  @override
  Widget build(BuildContext context) {
    final priorityLabel = item.priority == IntelligencePriority.critical
        ? AppShellStrings.t('home_intelligence_critical', locale)
        : AppShellStrings.t('home_high_priority', locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppSpacing.radiusMd,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _priorityColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.title.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    priorityLabel,
                    style: AppTypography.caption.copyWith(color: _priorityColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              HomeDirectionalIcons.forwardChevronRounded(context),
              color: AppColors.textSecondary,
              size: AppSpacing.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.category,
    required this.accentColor,
    required this.estimatedTime,
  });

  final String category;
  final Color accentColor;
  final String estimatedTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          borderRadius: AppSpacing.radiusFull,
          child: Text(
            category,
            style: AppTypography.caption.copyWith(color: accentColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          borderRadius: AppSpacing.radiusFull,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: AppSpacing.iconXs,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                estimatedTime,
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.10),
          ),
          child: Icon(icon, color: accentColor, size: AppSpacing.iconLg),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
    required this.progressPercent,
    required this.accentColor,
    required this.locale,
  });

  final double progress;
  final int progressPercent;
  final Color accentColor;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.glassBorder,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppShellStrings.format(
            'focus_progress_completed',
            locale,
            params: {'percent': '$progressPercent'},
          ),
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _ActiveFooter extends StatelessWidget {
  const _ActiveFooter({
    required this.highPriority,
    required this.actionLabel,
    required this.locale,
  });

  final bool highPriority;
  final String actionLabel;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final priorityLabel = highPriority
        ? AppShellStrings.t('home_high_priority', locale)
        : AppShellStrings.t('home_todays_focus', locale);
    final priorityColor =
        highPriority ? AppColors.roseGlow : AppColors.cyanGlow;

    return Row(
      children: [
        Flexible(
          child: Text(
            priorityLabel,
            style: AppTypography.caption.copyWith(
              color: priorityColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          borderRadius: AppSpacing.radiusFull,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Center(
              child: Text(
                actionLabel,
                style: AppTypography.button,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedFooter extends StatelessWidget {
  const _CompletedFooter({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: AppSpacing.iconLg,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppShellStrings.t('focus_completed_title', locale),
                style: AppTypography.subtitle.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                AppShellStrings.t('focus_completed_message', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.success,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
