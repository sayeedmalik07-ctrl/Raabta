import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/data/qatar_labour_law_kb.dart';
import 'package:raabta/features/legal_sources/domain/models/legal_source.dart';
import 'package:raabta/features/legal_sources/providers/legal_sources_providers.dart';

/// Admin checklist for labour-law source freshness (manual maintenance moat).
class AdminLegalSourcesScreen extends ConsumerStatefulWidget {
  const AdminLegalSourcesScreen({super.key});

  @override
  ConsumerState<AdminLegalSourcesScreen> createState() =>
      _AdminLegalSourcesScreenState();
}

class _AdminLegalSourcesScreenState extends ConsumerState<AdminLegalSourcesScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(legalSourcesProvider);
      ref.invalidate(lastLegalUpdateProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourcesAsync = ref.watch(legalSourcesProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'Legal Sources'),
        body: sourcesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (sources) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (_busy)
                  const LinearProgressIndicator(color: AdminAppBar.adminAccent),
                Text(
                  'Track Qatar labour sources used by EOSB and AI. '
                  'Mark verified after checking Al Meezan / mol.gov.qa. '
                  'Also update matching KB prose in qatar_labour_law_kb.dart — '
                  'Firestore and KB are separate records.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final source in sources) _SourceTile(
                  source: source,
                  busy: _busy,
                  onMarkVerified: () => _run(() async {
                    final verifiedAt = DateTime.now();
                    await ref
                        .read(legalSourcesRepositoryProvider)
                        .markVerifiedNow(source.id);
                    await ref
                        .read(adminApiServiceProvider)
                        .notifyLegalSourceVerified(
                          sourceId: source.id,
                          verifiedAt: verifiedAt,
                        );
                  }),
                  onNeedsReview: () => _run(
                    () => ref
                        .read(legalSourcesRepositoryProvider)
                        .updateStatus(source.id, LegalSourceStatus.amended),
                  ),
                  onMarkCurrent: () => _run(
                    () => ref
                        .read(legalSourcesRepositoryProvider)
                        .updateStatus(source.id, LegalSourceStatus.active),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.source,
    required this.busy,
    required this.onMarkVerified,
    required this.onNeedsReview,
    required this.onMarkCurrent,
  });

  final LegalSource source;
  final bool busy;
  final VoidCallback onMarkVerified;
  final VoidCallback onNeedsReview;
  final VoidCallback onMarkCurrent;

  @override
  Widget build(BuildContext context) {
    final verified = source.dateLastVerified;
    final verifiedLabel = verified != null
        ? DateFormat.yMMMd().format(verified)
        : 'Never';
    final kbTouch = QatarLabourLawKB.latestKbTouchForLegalSource(source.id);
    final kbTouchLabel =
        kbTouch != null ? DateFormat.yMMMd().format(kbTouch) : 'N/A';
    final kbDrift = source.status == LegalSourceStatus.active &&
        QatarLabourLawKB.firestoreVerifiedNewerThanKb(source.id, verified);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(source.lawIdentifier, style: AppTypography.title),
            const SizedBox(height: 4),
            Text(source.shortDescription, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Text('Status: ${source.status.name}'),
            Text('Last verified (Firestore): $verifiedLabel'),
            Text('KB prose last touched: $kbTouchLabel',
                style: AppTypography.caption),
            if (kbDrift) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade700),
                ),
                child: Text(
                  'KB drift: Firestore verified newer than qatar_labour_law_kb.dart '
                  'prose — confirm the matching section was updated in the same pass.',
                  style: AppTypography.caption.copyWith(
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
            Text('URL: ${source.sourceUrl}', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: busy ? null : onMarkVerified,
                  child: const Text('Mark verified today'),
                ),
                TextButton(
                  onPressed: busy ? null : onNeedsReview,
                  child: const Text('Needs review'),
                ),
                TextButton(
                  onPressed: busy ? null : onMarkCurrent,
                  child: const Text('Mark current'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
