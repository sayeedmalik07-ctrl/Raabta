import 'package:flutter/material.dart';
import '../l10n/landmark_translator_strings.dart';
import '../models/saved_landmark.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';

class SavedLandmarksList extends StatelessWidget {
  /// Restores English + cached Arabic without a new AI call.
  final void Function(SavedLandmark landmark) onSelect;

  final String locale;
  final List<SavedLandmark> landmarks;
  final bool isLoading;

  const SavedLandmarksList({
    super.key,
    required this.locale,
    required this.onSelect,
    required this.landmarks,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 36,
        child: Center(
          child: SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.successBright,
            ),
          ),
        ),
      );
    }

    if (landmarks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LandmarkTranslatorStrings.t('saved_destinations', locale),
          style: AppTypography.overline.copyWith(
            color: AppColors.isLight
                ? AppColors.textOnGlassMuted
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: landmarks.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final lm = landmarks[i];
              return GestureDetector(
                onTap: () => onSelect(lm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBright
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.successBright
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    lm.label,
                    style: AppTypography.chipLabel.copyWith(
                      color: AppColors.successBright,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
