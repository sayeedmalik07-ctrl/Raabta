import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/spacing/app_spacing.dart';

/// Shared hub-styled form decoration for service quote flows (Batch C skin).
InputDecoration serviceHubQuoteFieldDecoration({
  required String hintText,
}) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: AppColors.textPrimary.withValues(alpha: 0.04),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.glassBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.glassBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: AppColors.brandFamilyMain),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  );
}

/// Composer field for service quote chat (hub-aligned).
InputDecoration serviceHubQuoteChatComposerDecoration({
  required String hintText,
}) {
  return serviceHubQuoteFieldDecoration(hintText: hintText).copyWith(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    ),
  );
}
