import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_freshness_thresholds.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_status_providers.dart';

/// Read-only ScamShield data / flag health (Phase 31). No user PII.
class AdminShieldFreshnessScreen extends ConsumerWidget {
  const AdminShieldFreshnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(adminShieldFreshnessReportProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'ScamShield freshness'),
        body: RefreshIndicator(
          color: AdminAppBar.adminAccent,
          onRefresh: () async {
            ref.invalidate(adminShieldFreshnessReportProvider);
            await ref.read(adminShieldFreshnessReportProvider.future);
          },
          child: reportAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Failed to load: $e', style: AppTypography.body),
              ],
            ),
            data: (r) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _Section(
                  title: 'Official directory',
                  children: [
                    Text(
                      'Entries with lastVerified older than '
                      '${ShieldFreshnessThresholds.directoryAttentionDays} days: '
                      '${r.directoryOlderThanAttentionDays.length}',
                      style: AppTypography.body,
                    ),
                    for (final e in r.directoryOlderThanAttentionDays.take(20))
                      Text(
                        '• ${e.displayName} (${e.daysSinceVerified}d)',
                        style: AppTypography.bodySmall,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Older than '
                      '${ShieldFreshnessThresholds.directoryStaleDays} days: '
                      '${r.directoryOlderThanStaleDays.length}',
                      style: AppTypography.body,
                    ),
                    for (final e in r.directoryOlderThanStaleDays.take(20))
                      Text(
                        '• ${e.displayName} (${e.daysSinceVerified}d)',
                        style: AppTypography.bodySmall,
                      ),
                    Text(
                      'Hidden verified:false directory rows: '
                      '${r.directoryUnverifiedHiddenCount}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: 'Verification backlog (content cards)',
                  children: [
                    Text(
                      'verified:false content cards (bundled): '
                      '${r.contentCardUnverifiedCount}',
                      style: AppTypography.body,
                    ),
                  ],
                ),
                _Section(
                  title: 'Scam advisories (cached)',
                  children: [
                    Text('Active: ${r.activeAdvisoriesCount}'),
                    Text('Expired / inactive in cache: ${r.expiredAdvisoriesCount}'),
                    Text(
                      'Days since last publish: '
                      '${r.daysSinceLastAdvisoryPublish ?? '—'}',
                    ),
                  ],
                ),
                _Section(
                  title: 'Phrase / guidance assets',
                  children: [
                    Text(
                      'Latest lastReviewed in security_guidance.json: '
                      '${r.phraseDictionaryLastReviewed?.toIso8601String().split('T').first ?? '—'}',
                    ),
                    Text(
                      'Legal sources seed latest verified: '
                      '${r.legalSourcesLastUpdated.toIso8601String().split('T').first}',
                    ),
                  ],
                ),
                _Section(
                  title: 'Feature flags & endpoints',
                  children: [
                    for (final e in r.featureFlags.entries)
                      Text('${e.key}: ${e.value}'),
                    Text(
                      'Domain age endpoint flag: ${r.domainAgeEndpointEnabled}',
                    ),
                    Text(
                      'Link unroll endpoint flag: ${r.linkUnrollEndpointEnabled}',
                    ),
                    Text(
                      r.endpointHealthRecorded
                          ? 'Endpoint health checks: recorded'
                          : 'Endpoint health checks: not recorded in app',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: 'Decision 25 compliance (resolved)',
                  children: [
                    Text(
                      r.complianceFetchStale
                          ? 'Client config fetch is stale — flags fail-closed except job applications.'
                          : 'Client config fetch is fresh.',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final e in r.complianceFlagsResolved.entries)
                      Text('${e.key}: ${e.value}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headline2),
            const SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}
