import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/services/data/service_front_groups.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/utils/service_subcategory_visuals.dart';
import 'package:raabta/screens/services/widgets/service_subcategory_tile.dart';

/// Twelve kit front groups (Decision §5) — each opens the first mapped category T2.
class ServicesHubFrontGroupGrid extends StatelessWidget {
  const ServicesHubFrontGroupGrid({
    super.key,
    required this.locale,
  });

  final String locale;

  static const sectionKey = Key('services_hub_front_groups');

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: sectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ServicesStrings.t('hub_front_groups_section', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.82,
            ),
            itemCount: ServiceFrontGroupIds.orderedIds.length,
            itemBuilder: (context, index) {
              final fgId = ServiceFrontGroupIds.orderedIds[index];
              final label =
                  ServiceFrontGroupLabels.labelEnglish(fgId) ?? fgId;
              return _FrontGroupTile(
                frontGroupId: fgId,
                label: label,
                onTap: () => _openFirstCategory(context, fgId),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openFirstCategory(BuildContext context, String frontGroupId) {
    final anchor = ServiceFrontGroupLabels.anchorCategoryId(frontGroupId);
    if (anchor == null) return;
    context.push('/services/category/$anchor');
  }
}

class _FrontGroupTile extends StatelessWidget {
  const _FrontGroupTile({
    required this.frontGroupId,
    required this.label,
    required this.onTap,
  });

  final String frontGroupId;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final anchor = ServiceFrontGroupLabels.anchorCategoryId(frontGroupId);
    final icon = ServiceFrontGroupLabels.iconFor(frontGroupId);
    final visual = anchor != null
        ? ServiceSubcategoryVisuals.forCategory(
            categoryId: anchor,
            icon: icon,
          )
        : ServiceSubcategoryVisuals.forCategory(
            categoryId: 'home_cleaning',
            icon: icon,
          );
    return ServiceSubcategoryTile(
      label: label,
      visual: visual,
      onTap: onTap,
    );
  }
}
