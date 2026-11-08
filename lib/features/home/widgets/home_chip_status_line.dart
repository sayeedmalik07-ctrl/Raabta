import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/domain/home_chip_status.dart';

/// Reserved micro-line slot under Home chip titles (no spinner while loading).
abstract final class HomeChipStatusLine {
  HomeChipStatusLine._();

  static const double slotHeight = 14;

  static Widget build(HomeChipStatus status) {
    return SizedBox(
      height: slotHeight,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: status.isLoading
            ? const SizedBox.shrink()
            : Text(
                status.line,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  height: 1.2,
                  color: status.tone == HomeChipStatusTone.attention
                      ? AppColors.warning
                      : AppColors.textOnGlassMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  /// Center-aligned variant for vertical chips.
  static Widget buildCentered(HomeChipStatus status) {
    return SizedBox(
      height: slotHeight,
      width: double.infinity,
      child: status.isLoading
          ? const SizedBox.shrink()
          : Text(
              status.line,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: status.tone == HomeChipStatusTone.attention
                    ? AppColors.warning
                    : AppColors.textOnGlassMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
    );
  }
}
