import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_category.dart';

/// Leaf filter chips — ~7 visible + "More" (kit category screen).
abstract final class ServiceCategoryLeafChips {
  static const int visibleLeafCount = 7;

  static List<String> primaryLeaves(ServiceCategory category) {
    final subs = category.subServices;
    if (subs.length <= visibleLeafCount) return List<String>.from(subs);
    return subs.take(visibleLeafCount).toList();
  }

  static List<String> overflowLeaves(ServiceCategory category) {
    final subs = category.subServices;
    if (subs.length <= visibleLeafCount) return const [];
    return subs.skip(visibleLeafCount).toList();
  }

  static Future<void> showMoreSheet({
    required BuildContext context,
    required String locale,
    required ServiceCategory category,
    required String? selectedSubService,
    required ValueChanged<String?> onSelect,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Material(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        ServicesStrings.t(
                          'hub_category_more_sheet_title',
                          locale,
                        ),
                        style: AppTypography.subtitle,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        children: [
                          ListTile(
                            title: Text(
                              ServicesStrings.t('filter_all', locale),
                            ),
                            trailing: selectedSubService == null
                                ? Icon(
                                    Icons.check_rounded,
                                    color: Theme.of(ctx).colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onSelect(null);
                              Navigator.pop(ctx);
                            },
                          ),
                          ...overflowLeaves(category).map(
                            (leaf) => ListTile(
                              title: Text(leaf),
                              trailing: selectedSubService == leaf
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .primary,
                                    )
                                  : null,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onSelect(leaf);
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal row: All + up to [ServiceCategoryLeafChips.visibleLeafCount] leaves + More.
class ServiceCategoryLeafChipRow extends StatelessWidget {
  const ServiceCategoryLeafChipRow({
    super.key,
    required this.locale,
    required this.category,
    required this.selectedSubService,
    required this.onSelect,
  });

  final String locale;
  final ServiceCategory category;
  final String? selectedSubService;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final primary = ServiceCategoryLeafChips.primaryLeaves(category);
    final hasMore = ServiceCategoryLeafChips.overflowLeaves(category).isNotEmpty;

    return SizedBox(
      height: HubLayoutTokens.filterChipHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: [
          buildHubFilterChip(
            label: Text(ServicesStrings.t('filter_all', locale)),
            selected: selectedSubService == null,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              onSelect(null);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          ...primary.map(
            (leaf) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: buildHubFilterChip(
                label: Text(
                  leaf,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: selectedSubService == leaf,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onSelect(leaf);
                },
              ),
            ),
          ),
          if (hasMore)
            buildHubFilterChip(
              label: Text(
                ServicesStrings.t('hub_category_more_chips', locale),
              ),
              selected: false,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                ServiceCategoryLeafChips.showMoreSheet(
                  context: context,
                  locale: locale,
                  category: category,
                  selectedSubService: selectedSubService,
                  onSelect: onSelect,
                );
              },
            ),
        ],
      ),
    );
  }
}
