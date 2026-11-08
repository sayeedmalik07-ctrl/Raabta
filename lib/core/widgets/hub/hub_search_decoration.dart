import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';

InputDecoration hubSearchInputDecoration({required String hintText}) {
  final pill = OutlineInputBorder(
    borderRadius:
        BorderRadius.circular(HubLayoutTokens.searchPillRadius),
    borderSide: BorderSide(color: AppColors.glassBorder),
  );
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.isLight ? AppColors.surface : AppColors.glassSurface,
    // Hub kit §3.1 — search field 44pt min height (trailing filter lives beside field).
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    isDense: true,
    constraints: const BoxConstraints(minHeight: HubLayoutTokens.searchMinHeight),
    border: pill,
    enabledBorder: pill,
    focusedBorder: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(HubLayoutTokens.searchPillRadius),
      borderSide: BorderSide(
        color: AppColors.brandFamilyMain.withValues(alpha: 0.45),
      ),
    ),
  );
}
