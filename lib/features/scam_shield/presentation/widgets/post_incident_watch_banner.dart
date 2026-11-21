import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_providers.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_service.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

class PostIncidentWatchBanner extends ConsumerWidget {
  const PostIncidentWatchBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(postIncidentWatchActiveProvider);
    return active.when(
      data: (show) {
        if (!show) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.08,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ScamShieldStrings.t('ss_post_incident_banner', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showLearnMore(context),
                      child: Text(
                        ScamShieldStrings.t(
                          'ss_post_incident_learn_more',
                          locale,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await PostIncidentWatchService.dismissPermanently();
                        ref.invalidate(postIncidentWatchActiveProvider);
                      },
                      child: Text(
                        ScamShieldStrings.t('ss_post_incident_im_ok', locale),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showLearnMore(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ScamShieldStrings.t('ss_post_incident_sheet_title', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_post_incident_rule1', locale),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t('ss_post_incident_rule2', locale),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t('ss_post_incident_rule3', locale),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push('/scam-shield/directory');
              },
              child: Text(
                ScamShieldStrings.t('ss_post_incident_directory', locale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
