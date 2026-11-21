import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/landmark_translator/l10n/landmark_translator_strings.dart';
import 'package:raabta/features/quick_actions/landmark_translator/services/ride_link_service.dart';

/// Maps, Uber (if installed), and copy-Arabic for any ride/delivery app.
class NavigationRideSheet extends StatelessWidget {
  const NavigationRideSheet({
    super.key,
    required this.locale,
    required this.destinationQuery,
    required this.arabicText,
    required this.uberAvailable,
  });

  final String locale;
  final String destinationQuery;
  final String arabicText;
  final bool uberAvailable;

  static Future<void> show(
    BuildContext context, {
    required String locale,
    required String destinationQuery,
    required String arabicText,
    required bool uberAvailable,
    required void Function(String snackMessage) onSnack,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.isLight
          ? AppColors.surfaceElevated
          : const Color(0xFF1A1035),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => NavigationRideSheet(
        locale: locale,
        destinationQuery: destinationQuery,
        arabicText: arabicText,
        uberAvailable: uberAvailable,
      ),
    ).then((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              LandmarkTranslatorStrings.t('nav_sheet_title', locale),
              style: AppTypography.title.copyWith(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SheetAction(
              icon: Icons.map_outlined,
              label: LandmarkTranslatorStrings.t('open_maps', locale),
              color: AppColors.cyanGlow,
              onTap: () async {
                Navigator.pop(context);
                await RideLinkService.openInMaps(destinationQuery);
              },
            ),
            if (uberAvailable) ...[
              const SizedBox(height: AppSpacing.sm),
              _SheetAction(
                icon: Icons.local_taxi_outlined,
                label: LandmarkTranslatorStrings.t('open_uber', locale),
                color: Colors.white,
                onTap: () async {
                  Navigator.pop(context);
                  await RideLinkService.openInUber(
                    destinationQuery: destinationQuery,
                    arabicText: arabicText,
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _SheetAction(
              icon: Icons.copy_rounded,
              label: LandmarkTranslatorStrings.t('copy_for_ride_apps', locale),
              color: AppColors.successBright,
              onTap: () async {
                await RideLinkService.copyArabicAddress(arabicText);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        LandmarkTranslatorStrings.t('arabic_copied_apps', locale),
                      ),
                      backgroundColor: AppColors.sharePurple,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.isLight
          ? AppColors.glassSurface
          : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
