import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/models/scan_filter.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';

enum ScanMode {
  document,
  receipt,
  whiteboard,
  idCard,
  photo,
}

extension ScanModeExt on ScanMode {
  ScanFilter get filter {
    switch (this) {
      case ScanMode.document:
        return ScanFilter.documentMode;
      case ScanMode.receipt:
        return ScanFilter.receiptMode;
      case ScanMode.whiteboard:
        return ScanFilter.highContrast;
      case ScanMode.idCard:
        return ScanFilter.magicColor;
      case ScanMode.photo:
        return ScanFilter.colorEnhance;
    }
  }

  String get labelKey {
    switch (this) {
      case ScanMode.document:
        return 'scan_mode_document';
      case ScanMode.receipt:
        return 'scan_mode_receipt';
      case ScanMode.whiteboard:
        return 'scan_mode_whiteboard';
      case ScanMode.idCard:
        return 'scan_mode_id_card';
      case ScanMode.photo:
        return 'scan_mode_photo';
    }
  }

  String labelFor(String locale) => ScannerStrings.t(labelKey, locale);

  IconData get icon {
    switch (this) {
      case ScanMode.document:
        return Icons.description_outlined;
      case ScanMode.receipt:
        return Icons.receipt_long_outlined;
      case ScanMode.whiteboard:
        return Icons.dashboard_outlined;
      case ScanMode.idCard:
        return Icons.badge_outlined;
      case ScanMode.photo:
        return Icons.photo_outlined;
    }
  }
}

class ScanModeBar extends StatelessWidget {
  const ScanModeBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.locale = 'English',
  });

  final ScanMode selected;
  final ValueChanged<ScanMode> onSelected;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ScanMode.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final mode = ScanMode.values[index];
          final active = mode == selected;
          return GestureDetector(
            onTap: () {
              scannerSelectionHaptic();
              onSelected(mode);
            },
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: active
                    ? scannerAccent.withValues(alpha: 0.22)
                    : AppColors.surfaceElevated.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: active ? scannerAccent : AppColors.textOnGlassMuted,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mode.icon,
                    size: AppSpacing.iconSm,
                    color: active ? scannerAccent : AppColors.textOnGlassSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    mode.labelFor(locale),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      fontSize: 9,
                      color: active
                          ? AppColors.textPrimary
                          : AppColors.textOnGlassMuted,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
