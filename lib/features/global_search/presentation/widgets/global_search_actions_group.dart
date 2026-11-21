import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_row.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_section_header.dart';

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
      padding: const EdgeInsets.only(
        bottom: GlobalSearchPresentationTokens.sectionBottomGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalSearchSectionHeader(
            title: AppShellStrings.t('global_search_actions_group', locale),
            icon: GlobalSearchCategory.actions.icon,
            accent: AppColors.brandFamilyMain,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in actions)
            GlobalSearchResultRow(
              icon: _iconForAction(item.actionId, item.resultKind),
              accent: AppColors.brandFamilyMain,
              title: item.title,
              subtitle: item.subtitle.isNotEmpty ? item.subtitle : null,
              semanticLabel: '${item.title}. ${item.subtitle}',
              onTap: () => onTapItem(item),
              trailing: GlobalSearchDirectionalIcons.playContinue(context),
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
