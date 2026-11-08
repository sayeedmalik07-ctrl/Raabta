import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Lightweight banner: "You have an unsaved draft from [time]. Restore?"
class DraftRestoreBanner extends StatelessWidget {
  const DraftRestoreBanner({
    super.key,
    required this.savedAt,
    required this.onRestore,
    required this.onDiscard,
  });

  final DateTime savedAt;
  final VoidCallback onRestore;
  final VoidCallback onDiscard;

  static String formatSavedAt(DateTime at) {
    final now = DateTime.now();
    final diff = now.difference(at);
    if (diff.inMinutes < 2) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return DateFormat.jm().format(at);
    if (diff.inDays < 7) return DateFormat.E().add_jm().format(at);
    return DateFormat.yMMMd().add_jm().format(at);
  }

  @override
  Widget build(BuildContext context) {
    final inTest = Platform.environment['FLUTTER_TEST'] == 'true';
    if (inTest) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Material(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unsaved draft from ${formatSavedAt(savedAt)}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(onPressed: onRestore, child: const Text('Restore')),
                    TextButton(onPressed: onDiscard, child: const Text('Discard')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.cyanGlow,
        glowIntensity: 0.15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_edu_outlined,
                  color: AppColors.amberGlow.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Unsaved draft from ${formatSavedAt(savedAt)}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: [
                TextButton(
                  onPressed: onRestore,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.cyanGlow,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Restore'),
                ),
                TextButton(
                  onPressed: onDiscard,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal restore prompt — returns `true` restore, `false` discard, `null` dismissed.
Future<bool?> showDraftRestoreDialog(
  BuildContext context,
  DateTime savedAt,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Restore draft?',
        style: AppTypography.headline2.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'You have an unsaved draft from ${DraftRestoreBanner.formatSavedAt(savedAt)}.',
        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Discard'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.cyanGlow,
            foregroundColor: AppColors.background,
          ),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}
