import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Glass-styled dropdown field — visual language matches [GlassTextField].
class GlassDropdownField<T> extends StatelessWidget {
  const GlassDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.value,
    this.menuMaxHeight = 320,
    this.selectedItemBuilder,
  });

  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final double menuMaxHeight;
  final DropdownButtonBuilder? selectedItemBuilder;

  static const double _minTouchHeight = 48;

  TextStyle get _labelStyle => AppTypography.caption.copyWith(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  TextStyle get _valueStyle =>
      AppTypography.body.copyWith(color: AppColors.textPrimary);

  TextStyle get _hintStyle =>
      AppTypography.body.copyWith(color: AppColors.textTertiary);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(label!, style: _labelStyle),
          const SizedBox(height: AppSpacing.xs),
        ],
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: AppSpacing.radiusSm,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minTouchHeight),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<T>(
                key: ValueKey(value),
                isExpanded: true,
                initialValue: value,
                hint: hint == null
                    ? null
                    : Text(
                        hint!,
                        style: _hintStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                style: _valueStyle,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary,
                  size: AppSpacing.iconMd,
                ),
                dropdownColor: AppColors.surfaceElevated,
                menuMaxHeight: menuMaxHeight,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  isDense: true,
                ),
                items: items,
                selectedItemBuilder: selectedItemBuilder,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
