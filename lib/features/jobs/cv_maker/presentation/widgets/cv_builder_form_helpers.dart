import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

List<String> parseCommaList(String raw) => raw
    .split(',')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

List<String> parseBulletLines(String raw) => raw
    .split('\n')
    .map((l) => l.replaceFirst(RegExp(r'^[\s•\-*]+\s*'), '').trim())
    .where((l) => l.isNotEmpty)
    .toList();

String bulletsToText(List<String> bullets) => bullets.join('\n');

Widget cvBuilderSectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
    child: Text(
      text,
      style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

InputDecoration cvBuilderFieldDecoration({
  required String labelText,
  String? hintText,
}) {
  final enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    borderSide: BorderSide(color: AppColors.glassBorder),
  );
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    labelStyle: AppTypography.caption,
    filled: true,
    fillColor: AppColors.isLight ? AppColors.surface : AppColors.glassSurface,
    border: enabledBorder,
    enabledBorder: enabledBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(
        color: AppColors.brandFamilyMain.withValues(alpha: 0.45),
      ),
    ),
  );
}

/// Jobs CV tool chrome: brand switches and outline/text buttons.
Widget cvJobsToolTheme({required Widget child}) {
  return Builder(
    builder: (context) {
      final brand = AppColors.brandFamilyMain;
      return Theme(
        data: Theme.of(context).copyWith(
          switchTheme: SwitchThemeData(
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return brand.withValues(alpha: 0.35);
              }
              return null;
            }),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return brand;
              }
              return null;
            }),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: brand,
              side: BorderSide(color: brand.withValues(alpha: 0.5)),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: brand),
          ),
        ),
        child: child,
      );
    },
  );
}

Widget cvBuilderField({
  required String label,
  required TextEditingController controller,
  int maxLines = 1,
  String? hint,
  TextInputType? keyboardType,
  ValueChanged<String>? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: AppTypography.body,
      decoration: cvBuilderFieldDecoration(labelText: label, hintText: hint),
    ),
  );
}

Widget cvBuilderSubCard({required Widget child}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: child,
    ),
  );
}
