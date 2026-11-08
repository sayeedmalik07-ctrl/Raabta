import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_picker_sheet.dart';
import 'package:raabta/screens/businesses/widgets/business_hub_picker_sheets.dart';
import 'package:raabta/screens/services/data/service_taxonomy.dart';
import 'package:raabta/screens/services/l10n/services_strings.dart';
import 'package:raabta/screens/services/models/service_category.dart';

/// Hub category filter picker (all + top-level service categories).
Future<String?> showServiceCategoryFilterPicker({
  required BuildContext context,
  required String locale,
  String? selectedCategoryId,
}) {
  return HubPickerSheet.show<String>(
    context: context,
    title: ServicesStrings.t('hub_picker_category_title', locale),
    subtitle: ServicesStrings.t('hub_picker_category_subtitle', locale),
    child: Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        buildHubChoiceChip(
          label: Text(ServicesStrings.t('filter_all', locale)),
          selected: selectedCategoryId == null || selectedCategoryId.isEmpty,
          onSelected: (_) => Navigator.pop(context, ''),
        ),
        for (final category in kServiceCategories)
          buildHubChoiceChip(
            label: Text(category.name),
            selected: selectedCategoryId == category.id,
            onSelected: (_) => Navigator.pop(context, category.id),
          ),
      ],
    ),
  );
}

Future<String?> showServiceAreaFilterPicker({
  required BuildContext context,
  required String locale,
  String? selectedArea,
}) {
  return showBusinessAreaPicker(
    context: context,
    locale: locale,
    selectedArea: selectedArea,
  );
}

String serviceCategoryFilterLabel(String locale, String? categoryId) {
  if (categoryId == null || categoryId.isEmpty) {
    return ServicesStrings.t('filter_category', locale);
  }
  for (final category in kServiceCategories) {
    if (category.id == categoryId) return category.name;
  }
  return ServicesStrings.t('filter_category', locale);
}

ServiceCategory? serviceCategoryById(String? id) {
  if (id == null || id.isEmpty) return null;
  for (final category in kServiceCategories) {
    if (category.id == id) return category;
  }
  return null;
}
