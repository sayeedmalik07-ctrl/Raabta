import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/admin/widgets/admin_widgets.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/data/moph_insurer_lookup_catalog.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_repository.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';

/// Admin maintenance for MOPH insurer + TPA/plan lookup catalogue.
class AdminMophInsurersScreen extends ConsumerStatefulWidget {
  const AdminMophInsurersScreen({super.key});

  @override
  ConsumerState<AdminMophInsurersScreen> createState() =>
      _AdminMophInsurersScreenState();
}

class _AdminMophInsurersScreenState extends ConsumerState<AdminMophInsurersScreen> {
  bool _busy = false;

  Future<void> _markVerifiedNow() async {
    setState(() => _busy = true);
    try {
      final repo = await ref.read(healthInsuranceRepositoryProvider.future);
      final current = await repo.fetchMophInsurerSnapshot();
      await repo.saveMophInsurerSnapshot(
        MophInsurerLookupSnapshot(
          insurers: current.insurers,
          insurerAliases: current.insurerAliases,
          tpaMappings: current.tpaMappings,
          lastVerified: DateTime.now(),
        ),
      );
      ref.invalidate(mophInsurerSnapshotProvider);
      ref.invalidate(insurerLookupServiceProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetToSeed() async {
    setState(() => _busy = true);
    try {
      final repo = await ref.read(healthInsuranceRepositoryProvider.future);
      await repo.saveMophInsurerSnapshot(
        MophInsurerLookupSnapshot(
          insurers: MophInsurerLookupCatalog.defaultInsurers,
          insurerAliases: Map<String, String>.from(
            MophInsurerLookupCatalog.defaultInsurerAliases,
          ),
          tpaMappings: MophInsurerLookupCatalog.defaultTpaMappings,
          lastVerified: DateTime.now(),
        ),
      );
      ref.invalidate(mophInsurerSnapshotProvider);
      ref.invalidate(insurerLookupServiceProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(mophInsurerSnapshotProvider);

    return AnimatedAuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminAppBar(title: 'MOPH Insurer Lookup'),
        body: snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (snapshot) {
            final verified = DateFormat.yMMMd().format(snapshot.lastVerified);
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (_busy)
                  const LinearProgressIndicator(color: AdminAppBar.adminAccent),
                Text(
                  'Maintain MOPH-licensed insurers and TPA/plan name mappings '
                  'used by the Health Insurance Truth Engine. Verify against '
                  'moph.gov.qa before marking verified.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Last verified: $verified', style: AppTypography.title),
                Text(
                  '${snapshot.insurers.length} insurers · '
                  '${snapshot.tpaMappings.length} TPA/plan mappings',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    FilledButton(
                      onPressed: _busy ? null : _markVerifiedNow,
                      child: const Text('Mark verified today'),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : _resetToSeed,
                      child: const Text('Reset to bundled seed'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Insurers', style: AppTypography.headline2),
                const SizedBox(height: AppSpacing.sm),
                for (final name in snapshot.insurers)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.business_outlined, size: 18),
                    title: Text(name, style: AppTypography.body),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text('TPA / branded plans', style: AppTypography.headline2),
                const SizedBox(height: AppSpacing.sm),
                for (final mapping in snapshot.tpaMappings)
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text(mapping.displayName),
                      subtitle: Text(
                        '${mapping.type.toUpperCase()}'
                        '${mapping.underlyingInsurers.isEmpty ? '' : ' → ${mapping.underlyingInsurers.join(', ')}'}'
                        '${mapping.notes != null ? '\n${mapping.notes}' : ''}',
                        style: AppTypography.caption,
                      ),
                      leading: Icon(
                        mapping.isTpa ? Icons.hub_outlined : Icons.card_membership_outlined,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Firestore doc: legal_sources/${MophInsurerLookupCatalog.firestoreDocId}',
                  style: AppTypography.caption,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
