import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/theme/theme_notifier.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    if (compact) return _buildIconOnly(context, ref, isDark);
    return _buildPill(context, ref, isDark);
  }

  Widget _buildIconOnly(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
          key: ValueKey(isDark),
          color: isDark ? AppColors.warning : AppColors.secondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildPill(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          border: Border.all(
            color: isDark ? AppColors.border : Color(0xFFBFDBFE),
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: isDark ? 0.4 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.wb_sunny_rounded,
                size: 14,
                color: isDark ? AppColors.textMuted : AppColors.warning,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 16,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primary : AppColors.warning,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment:
                    isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedOpacity(
              opacity: isDark ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.nightlight_round,
                size: 14,
                color: isDark ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
