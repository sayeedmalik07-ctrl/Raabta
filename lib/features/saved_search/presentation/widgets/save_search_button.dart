import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/l10n/saved_search_strings.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Default [cyan] preserves legacy accent; [hubBrand] aligns with hub chrome.
enum SaveSearchButtonAccent {
  cyan,
  hubBrand,
}

class SaveSearchButton extends ConsumerWidget {
  const SaveSearchButton({
    super.key,
    required this.vertical,
    required this.criteria,
    this.accent = SaveSearchButtonAccent.cyan,
  });

  final SavedSearchVertical vertical;
  final SavedSearchCriteria criteria;
  final SaveSearchButtonAccent accent;

  Color get _accentColor => switch (accent) {
        SaveSearchButtonAccent.hubBrand => AppColors.brandFamilyMain,
        SaveSearchButtonAccent.cyan => AppColors.cyanGlow,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final accentColor = _accentColor;
    return TextButton.icon(
      onPressed: () => _save(context, ref, locale),
      icon: Icon(Icons.notifications_active_outlined, size: 18, color: accentColor),
      label: Text(
        SavedSearchStrings.t('save_search_action', locale),
        style: AppTypography.bodySmall.copyWith(color: accentColor),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    String locale,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SavedSearchStrings.t('save_search_sign_in', locale)),
        ),
      );
      return;
    }

    final nameController = TextEditingController(
      text: criteria.defaultName(vertical),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(SavedSearchStrings.t('save_search_title', locale)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: SavedSearchStrings.t('save_search_name_hint', locale),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final name = nameController.text.trim();
    if (name.isEmpty) return;

    await ref.read(savedSearchRepositoryProvider).create(
          uid: user.uid,
          vertical: vertical,
          name: name,
          criteria: criteria,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(SavedSearchStrings.t('save_search_saved', locale)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
