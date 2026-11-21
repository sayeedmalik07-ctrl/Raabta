import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/services/data/service_taxonomy.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/utils/service_subcategory_visuals.dart';
import 'package:raabta/screens/services/widgets/service_subcategory_tile.dart';

/// Top-level taxonomy grid on Services hub (24 categories → category T2 screens).
class ServicesHubCategoryBrowse extends StatelessWidget {
  const ServicesHubCategoryBrowse({super.key, required this.locale});

  final String locale;

  static const sectionKey = Key('services_hub_category_browse');

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: sectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ServicesStrings.t('hub_browse_categories', locale),
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
            itemCount: kServiceCategories.length,
            itemBuilder: (context, index) {
              final category = kServiceCategories[index];
              final visual = ServiceSubcategoryVisuals.forCategory(
                categoryId: category.id,
                icon: category.icon,
              );
              return ServiceSubcategoryTile(
                label: category.name,
                visual: visual,
                onTap: () => context.push('/services/category/${category.id}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
