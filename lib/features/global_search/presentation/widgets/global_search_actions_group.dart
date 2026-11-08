import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';

/// Dedicated ACTIONS group for high-intent search commands (S2).
class GlobalSearchActionsGroupView extends StatelessWidget {
  const GlobalSearchActionsGroupView({
    super.key,
    required this.actions,
    required this.locale,
    required this.onTapItem,
  });

  final List<GlobalSearchResultItem> actions;
  final String locale;
  final ValueChanged<GlobalSearchResultItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                Icon(
                  GlobalSearchCategory.actions.icon,
                  size: 20,
                  color: AppColors.amberGlow,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppShellStrings.t('global_search_actions_group', locale),
                  style: AppTypography.title,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final item in actions)
            Semantics(
              button: true,
              label: '${item.title}. ${item.subtitle}',
              child: GlassCard(
                onTap: () => onTapItem(item),
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      _iconForAction(item.actionId, item.resultKind),
                      size: 22,
                      color: AppColors.cyanGlow,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.subtitle.isNotEmpty)
                            Text(
                              item.subtitle,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    GlobalSearchDirectionalIcons.playContinue(context),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconForAction(
    SearchActionId? actionId,
    GlobalSearchResultKind kind,
  ) {
    if (kind == GlobalSearchResultKind.calculation) {
      return Icons.calculate_outlined;
    }
    return switch (actionId) {
      SearchActionId.verifyEmployer => Icons.business_center_outlined,
      SearchActionId.verifyAgency => Icons.verified_user_outlined,
      SearchActionId.calculateEosb => Icons.calculate_outlined,
      SearchActionId.scanDocument => Icons.document_scanner_outlined,
      SearchActionId.convertCurrency => Icons.currency_exchange_rounded,
      SearchActionId.askAi => Icons.auto_awesome_outlined,
      null => Icons.bolt_rounded,
    };
  }
}
