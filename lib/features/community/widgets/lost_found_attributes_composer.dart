import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

class LostFoundAttributesComposer extends StatelessWidget {
  const LostFoundAttributesComposer({
    super.key,
    required this.locale,
    required this.selectedCategory,
    required this.selectedColors,
    required this.brandController,
    required this.itemTypeController,
    required this.marksController,
    required this.enabled,
    required this.onCategoryChanged,
    required this.onColorsChanged,
  });

  final String locale;
  final String? selectedCategory;
  final Set<String> selectedColors;
  final TextEditingController brandController;
  final TextEditingController itemTypeController;
  final TextEditingController marksController;
  final bool enabled;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<Set<String>> onColorsChanged;

  @override
  Widget build(BuildContext context) {
    final isDocuments =
        LostFoundCategory.blocksPhoto(selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String?>(
          value: selectedCategory,
          decoration: InputDecoration(
            labelText: CommunityStrings.t(
              'community_lf_label_category',
              locale,
            ),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                CommunityStrings.t('community_lf_category_optional', locale),
              ),
            ),
            for (final cat in LostFoundCategory.all)
              DropdownMenuItem<String?>(
                value: cat,
                child: Text(
                  CommunityStrings.t(LostFoundCategory.labelKey(cat), locale),
                ),
              ),
          ],
          onChanged: enabled ? onCategoryChanged : null,
        ),
        if (isDocuments) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            CommunityStrings.t('community_lf_documents_notice', locale),
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          CommunityStrings.t('community_lf_label_colors', locale),
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final colorId in LostFoundColorPalette.all)
              FilterChip(
                label: Text(
                  CommunityStrings.t(
                    LostFoundColorPalette.labelKey(colorId),
                    locale,
                  ),
                ),
                selected: selectedColors.contains(colorId),
                onSelected: enabled
                    ? (selected) {
                        final next = Set<String>.from(selectedColors);
                        if (selected) {
                          if (next.length >= LostFoundColorPalette.maxSelected) {
                            return;
                          }
                          next.add(colorId);
                        } else {
                          next.remove(colorId);
                        }
                        onColorsChanged(next);
                      }
                    : null,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: itemTypeController,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: CommunityStrings.t(
              'community_lf_label_item_type',
              locale,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: brandController,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: CommunityStrings.t('community_lf_label_brand', locale),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: marksController,
          enabled: enabled,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: CommunityStrings.t('community_lf_label_marks', locale),
          ),
        ),
      ],
    );
  }
}
