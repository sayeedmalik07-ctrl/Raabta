import 'package:flutter/material.dart';
import '../l10n/landmark_translator_strings.dart';
import '../models/saved_landmark.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';

class SaveLandmarkSheet extends StatefulWidget {
  final String locale;
  final String? userId;
  final String englishDescription;
  final String arabicDescription;
  final VoidCallback onSaved;

  const SaveLandmarkSheet({
    super.key,
    required this.locale,
    required this.userId,
    required this.englishDescription,
    required this.arabicDescription,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String locale,
    required String? userId,
    required String englishDescription,
    required String arabicDescription,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.isLight
          ? AppColors.surfaceElevated
          : const Color(0xFF1A1035),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => SaveLandmarkSheet(
        locale: locale,
        userId: userId,
        englishDescription: englishDescription,
        arabicDescription: arabicDescription,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<SaveLandmarkSheet> createState() =>
      _SaveLandmarkSheetState();
}

class _SaveLandmarkSheetState extends State<SaveLandmarkSheet> {
  String _selectedLabel = SavedLandmark.presetLabels.first;
  bool _isSaving = false;

  Future<void> _save() async {
    final uid = widget.userId;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LandmarkTranslatorStrings.t('sign_in_to_save', widget.locale),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() { _isSaving = true; });
    try {
      final landmark = SavedLandmark(
        id:                 '',
        label:              _selectedLabel,
        englishDescription: widget.englishDescription,
        arabicDescription:  widget.arabicDescription,
        lastUsed:           DateTime.now(),
      );
      await SavedLandmark.collectionForUser(uid).add(landmark.toFirestore());

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LandmarkTranslatorStrings.t('error_save', widget.locale),
            ),
            backgroundColor: AppColors.errorBright,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.isLight
                    ? AppColors.glassBorder
                    : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LandmarkTranslatorStrings.t('save_sheet_title', locale),
            style: AppTypography.title.copyWith(
              color: AppColors.isLight
                  ? AppColors.textPrimary
                  : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.englishDescription,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.isLight
                  ? AppColors.textOnGlassSecondary
                  : Colors.white.withValues(alpha: 0.4),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Text(
            LandmarkTranslatorStrings.t('choose_label', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.isLight
                  ? AppColors.textOnGlassSecondary
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SavedLandmark.presetLabels.map((label) {
              final selected = _selectedLabel == label;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedLabel = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.successBright
                        : AppColors.successBright
                            .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.successBright
                          .withValues(alpha: selected ? 1.0 : 0.25),
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.chipLabel.copyWith(
                      color: selected
                          ? Colors.white
                          : AppColors.successBright,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successBright,
                disabledBackgroundColor:
                    AppColors.successBright.withValues(alpha: 0.4),
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2,
                      ),
                    )
                  : Text(
                      LandmarkTranslatorStrings.t(
                        'save_destination_btn',
                        locale,
                      ),
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
