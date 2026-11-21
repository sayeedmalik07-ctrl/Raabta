import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Glass-styled text field used across feature screens.
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.icon,
    this.suffix,
    this.maxLines = 1,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? hint;
  final String? label;
  final IconData? icon;
  final Widget? suffix;
  final int maxLines;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: AppSpacing.radiusSm,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.textTertiary, size: 20)
                  : null,
              suffix: suffix,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: icon != null ? AppSpacing.sm : AppSpacing.md,
                vertical: maxLines > 1 ? AppSpacing.md : AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
