import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/models/scan_filter.dart';

class ScanFilterBar extends StatelessWidget {
  const ScanFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.locale = 'English',
  });

  final ScanFilter selected;
  final ValueChanged<ScanFilter> onSelected;
  final String locale;

  static const filters = [
    ScanFilter.original,
    ScanFilter.colorEnhance,
    ScanFilter.blackWhite,
    ScanFilter.grayscale,
    ScanFilter.magicColor,
    ScanFilter.highContrast,
    ScanFilter.documentMode,
    ScanFilter.receiptMode,
    ScanFilter.lowLight,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final active = filter == selected;
          return ChoiceChip(
            label: Text(
              ScannerStrings.filterLabel(filter, locale),
              style: TextStyle(
                fontSize: 11,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selected: active,
            selectedColor: AppColors.sharePurple,
            backgroundColor: AppColors.surfaceElevated,
            onSelected: (_) => onSelected(filter),
          );
        },
      ),
    );
  }
}
