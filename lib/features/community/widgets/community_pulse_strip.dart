import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/features/community/models/community_pulse_snapshot.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Compact activity summary for Community hub landing (counts only).
class CommunityPulseStrip extends ConsumerWidget {
  const CommunityPulseStrip({super.key});

  static String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseAsync = ref.watch(communityPulseProvider);
    final locale = ref.watch(userLanguageProvider);

    return pulseAsync.when(
      loading: () => const _PulseSkeleton(),
      error: (_, _) => const _PulseSkeleton(),
      data: (snapshot) {
        if (snapshot.trendingDiscussions == 0 &&
            snapshot.eventsToday == 0 &&
            snapshot.openQuestions == 0) {
          return const _PulseSkeleton();
        }
        return _PulseRow(snapshot: snapshot, locale: locale);
      },
    );
  }
}

class _PulseRow extends StatelessWidget {
  const _PulseRow({required this.snapshot, required this.locale});

  final CommunityPulseSnapshot snapshot;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final segments = <Widget>[
      _segment(
        CommunityPulseStrip._formatCount(snapshot.trendingDiscussions),
        CommunityStrings.t('community_pulse_trending', locale),
      ),
      _dot(),
      _segment(
        CommunityPulseStrip._formatCount(snapshot.eventsToday),
        CommunityStrings.t('community_pulse_events_today', locale),
      ),
      _dot(),
      _segment(
        CommunityPulseStrip._formatCount(snapshot.openQuestions),
        CommunityStrings.t('community_pulse_open_questions', locale),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: communityHubAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: communityHubAccent.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: communityHubAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: segments),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        '·',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _segment(String count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: communityHubAccentText,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _PulseSkeleton extends StatelessWidget {
  const _PulseSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      width: double.infinity,
      child: HubLoadingPlaceholder(
        height: 40,
        width: 400,
        silhouette: HubLoadingSilhouette.formTool,
      ),
    );
  }
}
