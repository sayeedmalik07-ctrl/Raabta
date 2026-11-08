import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';

/// Shared glass row for autocomplete suggestions and recent searches.
class GlobalSearchSuggestionTile extends StatelessWidget {
  const GlobalSearchSuggestionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.locale,
    required this.onTap,
    this.trailing,
    this.semanticLabel,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final String locale;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? semanticLabel;

  factory GlobalSearchSuggestionTile.recent({
    required String query,
    required String locale,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return GlobalSearchSuggestionTile(
      title: query,
      subtitle: AppShellStrings.t('global_search_recent', locale),
      leadingIcon: Icons.history_rounded,
      locale: locale,
      onTap: onTap,
      semanticLabel: query,
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: onRemove,
        tooltip: AppShellStrings.t('global_search_remove_recent', locale),
      ),
    );
  }

  factory GlobalSearchSuggestionTile.suggestion({
    required String title,
    required String subtitle,
    required IconData icon,
    required String locale,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GlobalSearchSuggestionTile(
      title: title,
      subtitle: subtitle,
      leadingIcon: icon,
      locale: locale,
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      trailing: Icon(
        GlobalSearchDirectionalIcons.queryEnter(context),
        size: 16,
        color: AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? '$title. $subtitle',
      child: GlassCard(
        onTap: onTap,
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(leadingIcon, size: 20, color: AppColors.cyanGlow),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
