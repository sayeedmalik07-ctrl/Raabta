import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/constants/strings/common_strings.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_picker_sheet.dart';
import 'package:raabta/core/widgets/hub/hub_search_decoration.dart';
import 'package:raabta/data/categories/business_categories.dart';
import 'package:raabta/models/housing_models.dart' show qatarAreas;
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';

/// Hub-styled category picker (sub-screen kit sheet + choice chips).
Future<int?> showBusinessCategoryPicker({
  required BuildContext context,
  required String locale,
  required int selectedIndex,
}) {
  return HubPickerSheet.show<int>(
    context: context,
    title: BusinessesStrings.t('hub_picker_category_title', locale),
    subtitle: BusinessesStrings.t('hub_picker_category_subtitle', locale),
    child: Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var index = 0; index < kBusinessCategories.length; index++)
          buildHubChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  kBusinessCategories[index].emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(kBusinessCategories[index].label),
              ],
            ),
            selected: selectedIndex == index,
            onSelected: (_) => Navigator.pop(context, index),
          ),
      ],
    ),
  );
}

/// Hub-styled area picker with search + chips.
Future<String?> showBusinessAreaPicker({
  required BuildContext context,
  required String locale,
  String? selectedArea,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) {
      return _BusinessAreaPickerBody(
        locale: locale,
        selectedArea: selectedArea,
      );
    },
  );
}

class _BusinessAreaPickerBody extends StatefulWidget {
  const _BusinessAreaPickerBody({
    required this.locale,
    this.selectedArea,
  });

  final String locale;
  final String? selectedArea;

  @override
  State<_BusinessAreaPickerBody> createState() => _BusinessAreaPickerBodyState();
}

class _BusinessAreaPickerBodyState extends State<_BusinessAreaPickerBody> {
  late final TextEditingController _queryController;
  String? _highlighted;

  @override
  void initState() {
    super.initState();
    _highlighted = widget.selectedArea;
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<String> get _filteredAreas {
    final q = _queryController.text.trim().toLowerCase();
    if (q.isEmpty) return qatarAreas;
    return qatarAreas.where((a) => a.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final areas = _filteredAreas;

    return HubPickerSheet(
      title: BusinessesStrings.t('hub_picker_area_title', locale),
      subtitle: BusinessesStrings.t('hub_picker_area_subtitle', locale),
      footer: SizedBox(
        width: double.infinity,
        height: 46,
        child: FilledButton(
          onPressed: () => Navigator.pop(context, _highlighted ?? ''),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brandFamilyMain,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(23),
            ),
          ),
          child: Text(BusinessesStrings.t('hub_picker_apply', locale)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: HubLayoutTokens.searchMinHeight,
            ),
            child: TextField(
              key: const Key('business_hub_area_search'),
              controller: _queryController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.subtitle,
              decoration: hubSearchInputDecoration(
                hintText: BusinessesStrings.t('hub_picker_area_search_hint', locale),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          buildHubChoiceChip(
            label: Text(BusinessesStrings.t('hub_picker_all_areas', locale)),
            selected: _highlighted == null || _highlighted!.isEmpty,
            onSelected: (_) => setState(() => _highlighted = null),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final area in areas)
                buildHubChoiceChip(
                  label: Text(area),
                  selected: _highlighted == area,
                  onSelected: (_) => setState(() => _highlighted = area),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Advanced filters sheet (category, open now, area) — hub glass panel rows.
Future<void> showBusinessFiltersSheet({
  required BuildContext context,
  required String locale,
  required int selectedCategoryIndex,
  required bool openNowOnly,
  required String? areaFilter,
  required VoidCallback onClearAll,
  required ValueChanged<int> onCategoryChanged,
  required ValueChanged<bool> onOpenNowChanged,
  required ValueChanged<String?> onAreaChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) {
      return _BusinessFiltersSheetBody(
        locale: locale,
        initialCategoryIndex: selectedCategoryIndex,
        initialOpenNow: openNowOnly,
        initialArea: areaFilter,
        onClearAll: onClearAll,
        onCategoryChanged: onCategoryChanged,
        onOpenNowChanged: onOpenNowChanged,
        onAreaChanged: onAreaChanged,
      );
    },
  );
}

class _BusinessFiltersSheetBody extends StatefulWidget {
  const _BusinessFiltersSheetBody({
    required this.locale,
    required this.initialCategoryIndex,
    required this.initialOpenNow,
    required this.initialArea,
    required this.onClearAll,
    required this.onCategoryChanged,
    required this.onOpenNowChanged,
    required this.onAreaChanged,
  });

  final String locale;
  final int initialCategoryIndex;
  final bool initialOpenNow;
  final String? initialArea;
  final VoidCallback onClearAll;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<bool> onOpenNowChanged;
  final ValueChanged<String?> onAreaChanged;

  @override
  State<_BusinessFiltersSheetBody> createState() =>
      _BusinessFiltersSheetBodyState();
}

class _BusinessFiltersSheetBodyState extends State<_BusinessFiltersSheetBody> {
  late int _categoryIndex;
  late bool _openNow;
  late String? _area;

  @override
  void initState() {
    super.initState();
    _categoryIndex = widget.initialCategoryIndex;
    _openNow = widget.initialOpenNow;
    _area = widget.initialArea;
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return HubPickerSheet(
      title: BusinessesStrings.t('hub_filter_sheet_title', locale),
      subtitle: BusinessesStrings.t('hub_filter_sheet_subtitle', locale),
      footer: TextButton(
        onPressed: () {
          Navigator.pop(context);
          widget.onClearAll();
        },
        child: Text(CommonStrings.clearFilters),
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusMd,
        child: Column(
          children: [
            _FilterNavRow(
              key: const Key('business_hub_filter_sheet_category'),
              icon: Icons.category_outlined,
              label: BusinessesStrings.t('filter_category', locale),
              value: kBusinessCategories[_categoryIndex].label,
              onTap: () async {
                final picked = await showBusinessCategoryPicker(
                  context: context,
                  locale: locale,
                  selectedIndex: _categoryIndex,
                );
                if (picked == null) return;
                setState(() => _categoryIndex = picked);
                widget.onCategoryChanged(picked);
              },
            ),
            const Divider(height: AppSpacing.lg),
            _FilterSwitchRow(
              key: const Key('business_hub_filter_sheet_open_now'),
              icon: Icons.schedule,
              label: BusinessesStrings.t('filter_open_now', locale),
              value: _openNow,
              onChanged: (value) {
                setState(() => _openNow = value);
                widget.onOpenNowChanged(value);
              },
            ),
            const Divider(height: AppSpacing.lg),
            _FilterNavRow(
              key: const Key('business_hub_filter_sheet_area'),
              icon: Icons.place_outlined,
              label: BusinessesStrings.t('filter_area', locale),
              value: _area?.trim().isNotEmpty == true
                  ? _area!
                  : BusinessesStrings.t('hub_picker_all_areas', locale),
              onTap: () async {
                final picked = await showBusinessAreaPicker(
                  context: context,
                  locale: locale,
                  selectedArea: _area,
                );
                if (picked == null) return;
                final next = picked.isEmpty ? null : picked;
                setState(() => _area = next);
                widget.onAreaChanged(next);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterNavRow extends StatelessWidget {
  const _FilterNavRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brandFamilyMain, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.subtitle),
                  Text(
                    value,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _FilterSwitchRow extends StatelessWidget {
  const _FilterSwitchRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.brandFamilyMain, size: AppSpacing.iconMd),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label, style: AppTypography.subtitle)),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.brandFamilyMain,
        ),
      ],
    );
  }
}
