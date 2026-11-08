import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/data/community_content_labels.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

/// Optional multi-select of joined groups and content labels for composers (Part A).
class CommunityGroupTagSelector extends StatelessWidget {
  const CommunityGroupTagSelector({
    super.key,
    required this.joinedGroupIds,
    required this.selectedIds,
    required this.onChanged,
    required this.locale,
    this.suggestedContentLabelIds = const [],
    this.enabled = true,
  });

  final Set<int> joinedGroupIds;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final String locale;
  final List<String> suggestedContentLabelIds;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final groups = CommunityGroupRegistry.all
        .where((g) => joinedGroupIds.contains(g.intId))
        .toList();

    final contentLabels = suggestedContentLabelIds
        .map(CommunityContentLabels.byId)
        .whereType<CommunityContentLabelDefinition>()
        .toList();

    if (groups.isEmpty && contentLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          CommunityStrings.t('community_tag_selector_heading', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final label in contentLabels)
              FilterChip(
                label: Text('${label.emoji} ${label.displayName(locale)}'),
                selected: selectedIds.contains(label.id),
                onSelected: enabled
                    ? (selected) {
                        final next = Set<String>.from(selectedIds);
                        if (selected) {
                          next.add(label.id);
                        } else {
                          next.remove(label.id);
                        }
                        onChanged(next);
                      }
                    : null,
                selectedColor: AppColors.warning.withValues(alpha: 0.2),
                checkmarkColor: AppColors.warning,
                labelStyle: AppTypography.caption.copyWith(
                  color: selectedIds.contains(label.id)
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            for (final group in groups)
              FilterChip(
                label: Text('${group.emoji} ${group.name}'),
                selected: selectedIds.contains(group.id),
                onSelected: enabled
                    ? (selected) {
                        final next = Set<String>.from(selectedIds);
                        if (selected) {
                          next.add(group.id);
                        } else {
                          next.remove(group.id);
                        }
                        onChanged(next);
                      }
                    : null,
                selectedColor: AppColors.brandFamilyMain.withValues(alpha: 0.16),
                checkmarkColor: AppColors.brandFamilyMain,
                labelStyle: AppTypography.caption.copyWith(
                  color: selectedIds.contains(group.id)
                      ? AppColors.brandFamilyText
                      : AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          CommunityStrings.t('community_tag_selector_hint', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
