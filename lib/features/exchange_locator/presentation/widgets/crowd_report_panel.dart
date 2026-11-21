import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/exchange_locator/domain/exchange_queue_logic.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/exchange_locator/presentation/providers/exchange_locator_providers.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/queue_status_badge.dart';
import 'package:raabta/providers/visa_providers.dart';

/// One-tap crowdsourced queue reporting — deterministic, no AI.
class CrowdReportPanel extends ConsumerStatefulWidget {
  const CrowdReportPanel({
    super.key,
    required this.branch,
    this.onReported,
  });

  final ExchangeBranch branch;
  final VoidCallback? onReported;

  @override
  ConsumerState<CrowdReportPanel> createState() => _CrowdReportPanelState();
}

class _CrowdReportPanelState extends ConsumerState<CrowdReportPanel> {
  bool _submitting = false;

  Future<void> _submit(CrowdReportLevel level, String locale) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ExchangeLocatorStrings.t('sign_in_report_queue', locale),
          ),
        ),
      );
      return;
    }

    final recent =
        await ref.read(recentCrowdReportsProvider(widget.branch.id).future);
    if (ExchangeQueueLogic.shouldNudgeAccuracy(
      selected: level,
      recentReports: recent,
    )) {
      final agg = ExchangeQueueLogic.aggregateReports(recent);
      final recentLevel = agg?.level != null
          ? ExchangeLocatorStrings.crowdLevelLabel(agg!.level, locale)
              .toLowerCase()
          : ExchangeLocatorStrings.t('crowd_level_different', locale);
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ExchangeLocatorStrings.t('crowd_check_title', locale)),
          content: Text(
            ExchangeLocatorStrings.format(
              'crowd_check_message',
              locale,
              params: {
                'recentLevel': recentLevel,
                'selectedLevel':
                    ExchangeLocatorStrings.crowdLevelLabel(level, locale),
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ExchangeLocatorStrings.t('action_go_back', locale)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ExchangeLocatorStrings.t('action_yes_submit', locale)),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _submitting = true);
    try {
      final repo = await ref.read(exchangeLocatorRepositoryProvider.future);
      await repo.submitCrowdReport(
        branchId: widget.branch.id,
        userId: user.uid,
        level: level,
      );
      ref.invalidate(branchDetailProvider(widget.branch.id));
      ref.invalidate(recentCrowdReportsProvider(widget.branch.id));
      widget.onReported?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ExchangeLocatorStrings.t('crowd_report_thanks', locale),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ExchangeLocatorStrings.format(
                'crowd_report_error',
                locale,
                params: {'error': '$e'},
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final now = DateTime.now();
    final recency = ExchangeLocatorStrings.formatRecency(
      widget.branch.queueLastUpdated,
      locale,
      now: now,
    );
    final bestTime = ExchangeQueueLogic.bestTimeToGo(widget.branch.hourlyBusyCounts);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ExchangeLocatorStrings.t('how_busy_heading', locale),
                style: AppTypography.subtitle,
              ),
              const Spacer(),
              QueueStatusBadge(
                status: widget.branch.queueStatus,
                locale: locale,
                estimatedMinutes: widget.branch.estimatedWaitingMinutes,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            recency,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          if (bestTime != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ExchangeLocatorStrings.formatBestTimeHint(bestTime, locale),
              style: AppTypography.bodySmall.copyWith(
                color: bestTime.hasEnoughData
                    ? AppColors.cyanGlow
                    : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final level in CrowdReportLevel.values)
                ActionChip(
                  label: Text(
                    ExchangeLocatorStrings.crowdLevelLabel(level, locale),
                  ),
                  onPressed: _submitting ? null : () => _submit(level, locale),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
