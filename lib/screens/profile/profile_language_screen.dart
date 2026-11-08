import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/app_locale_picker.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_list_section.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile settings language picker — saves preference and returns to Profile.
class ProfileLanguageScreen extends ConsumerStatefulWidget {
  const ProfileLanguageScreen({super.key});

  @override
  ConsumerState<ProfileLanguageScreen> createState() =>
      _ProfileLanguageScreenState();
}

class _ProfileLanguageScreenState extends ConsumerState<ProfileLanguageScreen> {
  static final _languages = AppLocalePicker.primaryOptions
      .map((o) => (o.flag, o.pickerLabel))
      .toList(growable: false);

  String? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selected = prefs.getString(LanguageScreen.languageKey);
      _loading = false;
    });
  }

  Future<void> _select(String name) async {
    HapticFeedback.selectionClick();
    setState(() => _selected = name);
    await ref.read(appLocaleNotifierProvider.notifier).setFromPickerLabel(name);

    if (!mounted) return;
    final locale = AppLocale.normalize(name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ProfileStrings.format(
            'snack_language_set',
            locale,
            params: {'name': name},
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    return ProfileTabScaffold(
      child: GlassScreenScaffold(
        title: ProfileStrings.t('settings_language', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Text(
                    ProfileStrings.t('language_intro', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassListSection(
                    children: [
                      for (var i = 0; i < _languages.length; i++) ...[
                        GlassSettingsTile(
                          title: '${_languages[i].$1} ${_languages[i].$2}',
                          trailing: _selected == _languages[i].$2
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppColors.cyanGlow,
                                )
                              : null,
                          onTap: () => _select(_languages[i].$2),
                        ),
                        if (i < _languages.length - 1)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: AppColors.glassBorder.withValues(alpha: 0.5),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
