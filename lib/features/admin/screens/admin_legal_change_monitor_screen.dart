import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/models/legal_change_monitor_models.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Internal review queue for Qatar Legal Change Monitor (never auto-updates KB).
class AdminLegalChangeMonitorScreen extends ConsumerStatefulWidget {
  const AdminLegalChangeMonitorScreen({super.key});

  @override
  ConsumerState<AdminLegalChangeMonitorScreen> createState() =>
      _AdminLegalChangeMonitorScreenState();
}

class _AdminLegalChangeMonitorScreenState
    extends ConsumerState<AdminLegalChangeMonitorScreen> {
  bool _busy = false;

  Future<void> _refresh() async {
    ref.invalidate(legalMonitorQueueProvider);
    ref.invalidate(legalMonitorSourcesProvider);
    await ref.read(legalMonitorQueueProvider.future);
  }

  Future<void> _runMonitor({bool simulate = false}) async {
    setState(() => _busy = true);
    try {
      final summary = await ref.read(adminApiServiceProvider).runLegalMonitor(
            simulateChanges: simulate
                ? {
                    'almeezan_qa':
                        'SIMULATED CHANGE: Art. 67 final settlement payment period amended to 3 days for all cases.',
                  }
                : null,
            sourceIds: simulate ? ['almeezan_qa'] : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Monitor run complete — ${summary?.sourcesChecked ?? 0} sources, '
            '${summary?.totalAiCalls ?? 0} AI call(s)',
          ),
        ),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Run failed: $e'), backgroundColor: AppColors.errorBright),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(LegalMonitorReviewItem item, String decision) async {
    setState(() => _busy = true);
    try {
      await ref.read(adminApiServiceProvider).submitLegalMonitorReview(
            itemId: item.id,
            decision: decision,
          );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(legalMonitorQueueProvider);
    final sourcesAsync = ref.watch(legalMonitorSourcesProvider);
    final dateFmt = DateFormat.yMMMd().add_Hm();

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'Legal Change Monitor'),
        body: RefreshIndicator(
          color: AdminAppBar.adminAccent,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (_busy) const LinearProgressIndicator(color: AdminAppBar.adminAccent),
              Text(
                'Internal-only pipeline. Detects source page changes, triages against '
                'tracked KB facts, and queues items for your review. '
                'Never auto-updates legal_sources or user-facing content.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _runMonitor(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run check now'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _runMonitor(simulate: true),
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Simulate change (test)'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Monitored sources', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.sm),
              sourcesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Sources error: $e'),
                data: (sources) => Column(
                  children: [
                    for (final s in sources)
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.label, style: AppTypography.title),
                            Text(s.url, style: AppTypography.caption),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              s.lastCheckedAt != null
                                  ? 'Last checked: ${dateFmt.format(s.lastCheckedAt!)}'
                                  : 'Not checked yet (baseline on first run)',
                              style: AppTypography.caption,
                            ),
                            if (s.lastFetchError != null)
                              Text(
                                'Fetch error: ${s.lastFetchError}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Review queue (CHANGED / UNCLEAR)', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.sm),
              queueAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Queue error: $e'),
                data: (items) {
                  if (items.isEmpty) {
                    return GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'No pending items. Weekly job runs Sundays 06:00 (Asia/Qatar).',
                        style: AppTypography.bodySmall,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final item in items) _ReviewTile(
                        item: item,
                        busy: _busy,
                        onReview: _review,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.item,
    required this.busy,
    required this.onReview,
  });

  final LegalMonitorReviewItem item;
  final bool busy;
  final Future<void> Function(LegalMonitorReviewItem item, String decision)
      onReview;

  Color get _statusColor => switch (item.triageStatus) {
        'CHANGED' => AppColors.errorBright,
        _ => AppColors.accentGold,
      };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: _statusColor,
      glowIntensity: 0.12,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.triageStatus,
                  style: AppTypography.caption.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(item.engine, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.trackedFact, style: AppTypography.body),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.reasoning,
            style: AppTypography.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          if (item.excerpt.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SelectableText(
              item.excerpt,
              style: AppTypography.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.sourceLabel,
                  style: AppTypography.caption,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final uri = Uri.tryParse(item.sourceUrl);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Open source'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilledButton(
                onPressed: busy ? null : () => onReview(item, 'confirmed'),
                child: const Text('Confirmed'),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => onReview(item, 'false_positive'),
                child: const Text('False positive'),
              ),
              TextButton(
                onPressed:
                    busy ? null : () => onReview(item, 'needs_research'),
                child: const Text('Needs research'),
              ),
            ],
          ),
          Text(
            'Confirmed → manual to-do to update legal_sources & KB (outside this tool).',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
