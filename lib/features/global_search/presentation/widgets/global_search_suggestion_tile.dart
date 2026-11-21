import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';

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
    this.accent,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final String locale;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? semanticLabel;
  final Color? accent;

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
      accent: AppColors.brandFamilyMain,
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
      accent: AppColors.brandFamilyMain,
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      trailing: Icon(
        GlobalSearchDirectionalIcons.queryEnter(context),
        size: 16,
        color: AppColors.brandFamilyText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tone = accent ?? AppColors.brandFamilyMain;

    return Semantics(
      button: true,
      label: semanticLabel ?? '$title. $subtitle',
      child: GlobalSearchResultRow(
        icon: leadingIcon,
        accent: tone,
        title: title,
        subtitle: subtitle.isNotEmpty ? subtitle : null,
        semanticLabel: semanticLabel,
        onTap: onTap,
        trailing: trailing,
        glowIntensity: 0.04,
      ),
    );
  }
}
