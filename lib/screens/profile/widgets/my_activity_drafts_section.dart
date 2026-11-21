import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/icons/post_vertical_icons.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/draft_restore_banner.dart';
import 'package:raabta/features/post_engine/presentation/post_flow_actions.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_draft_count_provider.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_engine_drafts_provider.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/my_activity_strings.dart';
import 'package:raabta/services/drafts/draft_service.dart';

class MyActivityDraftsSection extends ConsumerWidget {
  const MyActivityDraftsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final draftsAsync = ref.watch(postEngineDraftsProvider);

    return draftsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (drafts) {
        if (drafts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MyActivityStrings.t('my_activity_section_drafts', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final draft in drafts)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _DraftRow(
                  draft: draft,
                  locale: locale,
                  onResume: () => context.push(draft.resumeRoute),
                  onDelete: () => _confirmDelete(context, ref, draft, locale),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PostEngineDraftItem draft,
    String locale,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(MyActivityStrings.t('my_activity_draft_delete_title', locale)),
        content: Text(
          MyActivityStrings.t('my_activity_draft_delete_body', locale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MyActivityStrings.t('my_activity_draft_delete_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              MyActivityStrings.t('my_activity_draft_delete_confirm', locale),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await DraftService.instance.clearDraft(draft.formId);
    ref.invalidate(postEngineDraftsProvider);
    ref.invalidate(postEngineDraftCountProvider);
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.draft,
    required this.locale,
    required this.onResume,
    required this.onDelete,
  });

  final PostEngineDraftItem draft;
  final String locale;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final verticalLabel = PostFlowActions.flowTitle(draft.vertical, locale);
    final title = draft.title.trim().isEmpty ? verticalLabel : draft.title;
    final edited = DraftRestoreBanner.formatSavedAt(draft.savedAt);

    return Material(
      color: AppColors.glassSurface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              PostVerticalIcons.forVertical(draft.vertical),
              color: AppColors.amberGlow,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitle.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    MyActivityStrings.format(
                      'my_activity_draft_last_edited',
                      locale,
                      params: {'time': edited},
                    ),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onResume,
                  child: Text(
                    MyActivityStrings.t('my_activity_draft_resume', locale),
                  ),
                ),
                TextButton(
                  onPressed: onDelete,
                  child: Text(
                    MyActivityStrings.t('my_activity_draft_delete', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
