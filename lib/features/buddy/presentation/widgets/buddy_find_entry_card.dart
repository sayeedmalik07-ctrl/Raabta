import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/buddy/presentation/l10n/buddy_strings.dart';
import 'package:raabta/features/buddy/services/buddy_entry_card_prefs.dart';

class BuddyFindEntryCard extends StatelessWidget {
  const BuddyFindEntryCard({
    super.key,
    required this.locale,
    required this.onDismissed,
  });

  final String locale;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BuddyStrings.t('buddy_entry_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            BuddyStrings.t('buddy_entry_body', locale),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  await BuddyEntryCardPrefs.dismiss();
                  onDismissed();
                },
                child: Text(BuddyStrings.t('buddy_entry_dismiss', locale)),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandFamilyMain,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => context.push('/community/buddy'),
                child: Text(BuddyStrings.t('buddy_entry_action', locale)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
