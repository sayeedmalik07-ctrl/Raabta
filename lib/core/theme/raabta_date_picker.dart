import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// Dark sheet surface used by DocConfirm and legacy forced-dark pickers.
const Color _kDarkPickerSurface = Color(0xFF1A1035);

/// Wraps a [showDatePicker] child with theming aligned to effective app brightness.
///
/// Dark mode preserves the legacy dark calendar (purple primary, vault sheet surface).
/// Light mode derives from [Theme.of] with brand primary and elevated surface.
Widget raabtaDatePickerThemeBuilder(BuildContext context, Widget? child) {
  if (child == null) return const SizedBox.shrink();

  if (AppColors.isLight) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: AppColors.sharePurple,
          onPrimary: Colors.white,
          surface: AppColors.surfaceElevated,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child,
    );
  }

  return Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sharePurple,
        surface: _kDarkPickerSurface,
      ),
    ),
    child: child,
  );
}
