import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/theme/theme_notifier.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  static const _previewAnimation = Duration(milliseconds: 200);

  static String _headlineForMode(ThemeMode mode, String locale) {
    return switch (mode) {
      ThemeMode.system =>
        ProfileStrings.t('appearance_system_default', locale),
      ThemeMode.dark => ProfileStrings.t('appearance_headline_dark', locale),
      ThemeMode.light => ProfileStrings.t('appearance_headline_light', locale),
    };
  }

  static String _subtitleForMode(ThemeMode mode, bool isDark, String locale) {
    return switch (mode) {
      ThemeMode.system => isDark
          ? ProfileStrings.t('appearance_subtitle_system_dark', locale)
          : ProfileStrings.t('appearance_subtitle_system_light', locale),
      ThemeMode.dark => ProfileStrings.t('appearance_subtitle_dark', locale),
      ThemeMode.light => ProfileStrings.t('appearance_subtitle_light', locale),
    };
  }

  static String _taglineForMode(ThemeMode mode, String locale) {
    return switch (mode) {
      ThemeMode.system => ProfileStrings.t('appearance_tagline_system', locale),
      ThemeMode.dark => ProfileStrings.t('appearance_tagline_dark', locale),
      ThemeMode.light => ProfileStrings.t('appearance_tagline_light', locale),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final themeMode = ref.watch(themeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = resolveIsDark(themeMode, platformBrightness);

    return ProfileTabScaffold(
      child: GlassScreenScaffold(
        enableBackgroundAnimation: false,
        title: ProfileStrings.t('settings_appearance', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              RepaintBoundary(
                child: _PhoneMockup(
                  key: ValueKey(isDark),
                  isDark: isDark,
                  locale: locale,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AnimatedSwitcher(
                duration: _previewAnimation,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Column(
                  key: ValueKey(themeMode),
                  children: [
                    Text(
                      _headlineForMode(themeMode, locale),
                      style: AppTypography.headline1.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _subtitleForMode(themeMode, isDark, locale),
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _taglineForMode(themeMode, locale),
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GlassCard(
                  borderRadius: AppSpacing.radiusXl,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          ProfileStrings.t('appearance_theme_section', locale),
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ThemeModeSelector(
                        locale: locale,
                        selected: themeMode,
                        onSelected: (mode) {
                          if (mode == themeMode) return;
                          HapticFeedback.selectionClick();
                          ref.read(themeProvider.notifier).setThemeMode(mode);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  ProfileStrings.t('appearance_saved_note', locale),
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.locale,
    required this.selected,
    required this.onSelected,
  });

  final String locale;
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeModeChip(
            icon: Icons.light_mode_outlined,
            label: ProfileStrings.t('appearance_chip_light', locale),
            isSelected: selected == ThemeMode.light,
            onTap: () => onSelected(ThemeMode.light),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ThemeModeChip(
            icon: Icons.dark_mode_outlined,
            label: ProfileStrings.t('appearance_chip_dark', locale),
            isSelected: selected == ThemeMode.dark,
            onTap: () => onSelected(ThemeMode.dark),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ThemeModeChip(
            icon: Icons.smartphone_outlined,
            label: ProfileStrings.t('appearance_chip_system', locale),
            isSelected: selected == ThemeMode.system,
            onTap: () => onSelected(ThemeMode.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeModeChip extends StatelessWidget {
  const _ThemeModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: AnimatedContainer(
          duration: AppearanceScreen._previewAnimation,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyanGlow.withValues(alpha: 0.14)
                : AppColors.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.cyanGlow : AppColors.glassBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.cyanGlow : AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color:
                      isSelected ? AppColors.cyanGlow : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup({
    super.key,
    required this.isDark,
    required this.locale,
  });

  final bool isDark;
  final String locale;

  static const _previewAnimation = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final shellColor = isDark ? AppColors.surface : Colors.white;
    final bodyColor = isDark ? AppColors.background : const Color(0xFFF4F6FA);
    final borderColor = isDark
        ? AppColors.cyanGlow.withValues(alpha: 0.3)
        : const Color(0xFFBFDBFE);
    final mutedText =
        isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final lineColor =
        isDark ? AppColors.glassBorderBright : const Color(0xFFE2E8F0);

    return AnimatedContainer(
      duration: _previewAnimation,
      curve: Curves.easeOutCubic,
      width: 220,
      height: 340,
      decoration: BoxDecoration(
        color: shellColor,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.cyanGlow.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Column(
          children: [
            Container(
              height: 24,
              color: shellColor,
              alignment: Alignment.center,
              child: Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Container(
              color: bodyColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.cyanGlow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'R',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Raabta',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.search_rounded, color: mutedText, size: 15),
                ],
              ),
            ),
            Expanded(
              child: AnimatedContainer(
                duration: _previewAnimation,
                curve: Curves.easeOutCubic,
                color: bodyColor,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      height: 26,
                      decoration: BoxDecoration(
                        color: shellColor,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: lineColor),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ProfileStrings.t('appearance_mock_search', locale),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textTertiary
                              : const Color(0xFFCBD5E1),
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _MockIconRow(isDark: isDark, shellColor: shellColor),
                    const SizedBox(height: 8),
                    _MockIconRow(isDark: isDark, shellColor: shellColor, second: true),
                    const Spacer(),
                    Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: shellColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: lineColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.cyanGlow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 5,
                                  width: 72,
                                  decoration: BoxDecoration(
                                    color: lineColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  height: 4,
                                  width: 46,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.glassBorderBright
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockIconRow extends StatelessWidget {
  const _MockIconRow({
    required this.isDark,
    required this.shellColor,
    this.second = false,
  });

  final bool isDark;
  final Color shellColor;
  final bool second;

  @override
  Widget build(BuildContext context) {
    const firstIcons = [
      Icons.work_outline_rounded,
      Icons.home_outlined,
      Icons.local_hospital_outlined,
      Icons.account_balance_wallet_outlined,
    ];
    const secondIcons = [
      Icons.description_outlined,
      Icons.storefront_outlined,
      Icons.groups_outlined,
      Icons.auto_awesome_outlined,
    ];
    final icons = second ? secondIcons : firstIcons;
    final lineColor =
        isDark ? AppColors.glassBorderBright : const Color(0xFFE2E8F0);

    return Row(
      children: [
        for (final icon in icons) ...[
          Expanded(
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: shellColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: lineColor),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: AppColors.cyanGlow.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
