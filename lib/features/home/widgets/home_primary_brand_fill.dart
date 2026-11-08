import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';

/// Gradient fills for Home primary actions (setup CTA, search-row AI orb).
///
/// Light theme uses [AppColors.brandFamilyMain] / [AppColors.brandFamilyText].
/// Dark theme getters are both `#9B7BFF`, which fails WCAG 4.5:1 against white
/// foreground; dark fills use existing fixed purple tokens instead.
abstract final class HomePrimaryBrandFill {
  static List<Color> gradientColors() {
    if (AppColors.isLight) {
      return [AppColors.brandFamilyMain, AppColors.brandFamilyText];
    }
    return const [AppColors.sharePurple, AppColors.brandFamilyLightDeep];
  }
}
