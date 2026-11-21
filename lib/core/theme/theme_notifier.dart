import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart' as glass;
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/typography/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resolves whether the UI should render in dark mode.
bool resolveIsDark(ThemeMode mode, Brightness platformBrightness) {
  return switch (mode) {
    ThemeMode.light => false,
    ThemeMode.dark => true,
    ThemeMode.system => platformBrightness == Brightness.dark,
  };
}

/// Syncs the committed M1.5 glass palette to effective brightness.
void syncGlassPalette(bool isLight) {
  glass.AppColors.applyBrightness(isLight);
}

/// Syncs design and glass palettes to effective brightness for [mode].
void syncEffectivePalettes(ThemeMode mode, Brightness platformBrightness) {
  final isLight = !resolveIsDark(mode, platformBrightness);
  AppColors.applyThemeMode(isLight ? ThemeMode.light : ThemeMode.dark);
  syncGlassPalette(isLight);
}

Brightness _platformBrightness() {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
}

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
    _loadSaved();
  }

  static const _key = 'raabta_theme_mode';

  ThemeMode _parseStoredMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  String _serializeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
    };
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    final mode = _parseStoredMode(saved);
    syncEffectivePalettes(mode, _platformBrightness());
    state = mode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    syncEffectivePalettes(mode, _platformBrightness());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serializeMode(mode));
  }

  /// Toggle policy C: light ↔ dark; system → explicit opposite of effective OS theme.
  Future<void> toggleTheme() async {
    final platform = _platformBrightness();
    final next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => resolveIsDark(ThemeMode.system, platform)
          ? ThemeMode.light
          : ThemeMode.dark,
    };
    await setThemeMode(next);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

/// Forces subtree rebuild and syncs glass palette when effective brightness changes.
class ThemeRebuildScope extends ConsumerStatefulWidget {
  const ThemeRebuildScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ThemeRebuildScope> createState() => _ThemeRebuildScopeState();
}

class _ThemeRebuildScopeState extends ConsumerState<ThemeRebuildScope> {
  bool? _lastIsDark;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = resolveIsDark(mode, platformBrightness);

    if (_lastIsDark != isDark) {
      _lastIsDark = isDark;
      syncEffectivePalettes(mode, platformBrightness);
    }

    return widget.child;
  }
}

/// Syncs palettes and rebuilds subtree when theme preference or OS brightness changes.
class ThemeSyncScope extends ConsumerStatefulWidget {
  const ThemeSyncScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ThemeSyncScope> createState() => _ThemeSyncScopeState();
}

class _ThemeSyncScopeState extends ConsumerState<ThemeSyncScope> {
  bool? _lastIsDark;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeProvider);
    final locale = ref.watch(appLocaleProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = resolveIsDark(mode, platformBrightness);

    if (_lastIsDark != isDark) {
      _lastIsDark = isDark;
      syncEffectivePalettes(mode, platformBrightness);
    }

    final baseTheme = Theme.of(context);
    final textTheme = AppFonts.textThemeFor(baseTheme.textTheme, locale);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      child: DefaultTextStyle(
        style: AppFonts.primaryStyle(
          locale,
          color: glass.AppColors.textPrimary,
        ),
        child: IconTheme(
          data: IconThemeData(color: glass.AppColors.textSecondary),
          child: widget.child,
        ),
      ),
    );
  }
}
