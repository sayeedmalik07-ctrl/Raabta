import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';

class ScanPageStrip extends StatelessWidget {
  const ScanPageStrip({
    super.key,
    required this.pagePaths,
    required this.selectedIndex,
    required this.onSelect,
    required this.onDelete,
    required this.onRotate,
    required this.onReorder,
    this.locale = 'English',
  });

  final List<String> pagePaths;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onRotate;
  final void Function(int oldIndex, int newIndex) onReorder;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (pagePaths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ScannerStrings.t('pages_title', locale),
          style: TextStyle(
            color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 108,
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            buildDefaultDragHandles: false,
            itemCount: pagePaths.length,
            onReorderItem: onReorder,
            itemBuilder: (context, index) {
              final selected = index == selectedIndex;
              return ReorderableDragStartListener(
                key: ValueKey(pagePaths[index]),
                index: index,
                child: GestureDetector(
                  onTap: () => onSelect(index),
                  child: Container(
                    width: 72,
                    margin: EdgeInsets.only(
                      right: index == pagePaths.length - 1 ? 0 : AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.sharePurple
                            : AppColors.isLight
                                ? AppColors.glassBorder
                                : Colors.white24,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(pagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Row(
                            children: [
                              _MiniIcon(
                                icon: Icons.rotate_right,
                                onTap: () => onRotate(index),
                              ),
                              const SizedBox(width: 2),
                              _MiniIcon(
                                icon: Icons.delete_outline,
                                onTap: () => onDelete(index),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 4,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 12, color: Colors.white),
      ),
    );
  }
}
