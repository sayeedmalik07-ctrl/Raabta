import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/app_locale_picker.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/screens/l10n/auth_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  static const String languageKey = 'selected_language';

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool _ready = false;

  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _brandFade;
  late final Animation<double> _buttonFade;
  late final Animation<double> _buttonScale;

  static final _languages = AppLocalePicker.primaryOptions;

  bool get _canContinue => _selectedIndex != null;

  AppLocalePickerOption? get _selectedLanguage =>
      _selectedIndex != null ? _languages[_selectedIndex!] : null;

  String get _displayLocale =>
      _selectedLanguage?.catalogLocale ?? AppLocale.normalize('English');

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    _brandFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.35, curve: Curves.easeOutCubic),
    );

    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.48, curve: Curves.easeOutCubic),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.12, 0.48, curve: Curves.easeOutCubic),
          ),
        );

    _buttonFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
    );

    _buttonScale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(LanguageScreen.languageKey);
    if (!mounted) return;
    setState(() {
      final idx = AppLocalePicker.indexForPickerLabel(saved);
      _selectedIndex = idx >= 0 ? idx : null;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _selectLanguage(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  Future<void> _onContinue() async {
    if (!_canContinue) return;
    HapticFeedback.lightImpact();
    final option = _languages[_selectedIndex!];
    await ref
        .read(appLocaleNotifierProvider.notifier)
        .setFromPickerLabel(option.pickerLabel);
    if (!mounted) return;
    context.go('/login');
  }

  Animation<double> _tileAnimation(int index) {
    final start = 0.18 + (index * 0.07);
    final end = (start + 0.28).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headline = _selectedLanguage?.headline ?? _languages.first.headline;
    final locale = _displayLocale;

    return GlassScreenScaffold(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          FadeTransition(opacity: _brandFade, child: _BrandAnchor()),
          const SizedBox(height: AppSpacing.xl),
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headline, style: AppTypography.headline2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AuthStrings.t('lang_screen_subtitle', locale),
                    style: AppTypography.subtitle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: !_ready
                ? const Center(
                    child: SizedBox(
                      width: AppSpacing.iconXl,
                      height: AppSpacing.iconXl,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          mainAxisExtent: 128,
                        ),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected = _selectedIndex == index;
                      return FadeTransition(
                        opacity: _tileAnimation(index),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(_tileAnimation(index)),
                          child: _LanguageTile(
                            language: language,
                            isSelected: isSelected,
                            onTap: () => _selectLanguage(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          FadeTransition(
            opacity: _buttonFade,
            child: ScaleTransition(
              scale: _buttonScale,
              child: AnimatedOpacity(
                duration: AppSpacing.contentAnimation,
                opacity: _canContinue ? 1 : 0.45,
                child: _GoldContinueButton(
                  enabled: _canContinue,
                  label: AuthStrings.t('lang_continue', locale),
                  onPressed: _onContinue,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _BrandAnchor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassContainer(
          borderRadius: AppSpacing.radiusSm,
          padding: const EdgeInsets.all(AppSpacing.sm),
          glowColor: AppColors.sharePurple,
          glowIntensity: 0.12,
          child: const Text(
            '🌙',
            style: TextStyle(fontSize: AppSpacing.iconLg),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raabta',
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'رابطہ',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final AppLocalePickerOption language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.03 : 1,
      duration: AppSpacing.contentAnimation,
      curve: Curves.easeOutCubic,
      child: GlassCard(
        onTap: onTap,
        glowColor: isSelected ? AppColors.accentGold : null,
        glowIntensity: isSelected ? 0.32 : 0,
        borderRadius: AppSpacing.radiusMd,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        backgroundColor: isSelected
            ? AppColors.accentGold.withValues(alpha: 0.08)
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language.flag,
              style: AppTypography.headline2.copyWith(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              language.pickerLabel,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.xxs),
              Container(
                width: AppSpacing.iconMd,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withValues(alpha: 0.4),
                      blurRadius: AppSpacing.sm,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoldContinueButton extends StatelessWidget {
  const _GoldContinueButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: enabled ? onPressed : null,
      borderRadius: AppSpacing.radiusSm,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      glowColor: AppColors.accentGold,
      glowIntensity: enabled ? 0.35 : 0.08,
      backgroundColor: AppColors.accentGold.withValues(
        alpha: enabled ? 0.22 : 0.06,
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.button.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
