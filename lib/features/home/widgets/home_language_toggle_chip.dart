import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/l10n/home_profile_strings.dart';
import 'package:raabta/features/home/widgets/home_header_tactile_control.dart';
import 'package:raabta/features/home/widgets/home_language_picker_sheet.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Home header language pill — opens the in-context language sheet.
class HomeLanguageToggleChip extends ConsumerWidget {
  const HomeLanguageToggleChip({super.key});

  /// Stable pill width so the header does not shift between locales.
  static const pillWidth = 88.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final code = AppLocale.chipLabel(locale);
    final semantics = HomeProfileStrings.t('header_language_semantics', locale)
        .replaceAll('{language}', AppLocale.normalize(locale));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: HomeHeaderTactileControl(
        key: ValueKey(code),
        controlKey: const Key('home_language_pill'),
        width: pillWidth,
        height: 44,
        borderRadius: 22,
        semanticsLabel: semantics,
        onTap: () => HomeLanguagePickerSheet.show(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.language_rounded,
                size: AppSpacing.iconSm + 2,
                color: AppColors.brandFamilyMain.withValues(alpha: 0.92),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                code,
                style: AppTypography.subtitle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandFamilyText,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.expand_more_rounded,
                size: 16,
                color: AppColors.textOnGlassSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
