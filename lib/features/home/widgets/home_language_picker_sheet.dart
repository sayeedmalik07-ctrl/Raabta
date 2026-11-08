import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/app_locale_picker.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/l10n/home_profile_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Home header language picker — bottom sheet over Home (reuses locale notifier).
class HomeLanguagePickerSheet extends ConsumerWidget {
  const HomeLanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const HomeLanguagePickerSheet(),
    );
  }

  static const _options = AppLocalePicker.primaryOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final current = AppLocale.normalize(locale);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        bottom + AppSpacing.md,
      ),
      child: GlassContainer(
        borderRadius: AppSpacing.radiusLg,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: 0.08,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.textOnGlassMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              HomeProfileStrings.t('language_sheet_title', locale),
              style: AppTypography.subtitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              HomeProfileStrings.t('language_sheet_subtitle', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnGlassSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < _options.length; i++) ...[
              _LanguageSheetRow(
                option: _options[i],
                selected: _options[i].catalogLocale == current,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await ref
                      .read(appLocaleNotifierProvider.notifier)
                      .setFromPickerLabel(_options[i].pickerLabel);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              if (i < _options.length - 1) const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageSheetRow extends StatelessWidget {
  const _LanguageSheetRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AppLocalePickerOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final englishName = option.catalogLocale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            color: selected
                ? AppColors.brandFamilyMain.withValues(
                    alpha: AppColors.isLight ? 0.12 : 0.18,
                  )
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? AppColors.brandFamilyMain.withValues(alpha: 0.45)
                  : AppColors.glassBorder.withValues(alpha: 0.65),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.pickerLabel,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        englishName,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnGlassSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.brandFamilyMain,
                    size: AppSpacing.iconMd,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
