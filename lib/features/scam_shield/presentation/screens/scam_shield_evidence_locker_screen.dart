import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/scam_shield/services/scam_evidence_locker_service.dart';
import 'package:share_plus/share_plus.dart';

class ScamShieldEvidenceLockerScreen extends ConsumerWidget {
  const ScamShieldEvidenceLockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final recordsAsync = ref.watch(scamEvidenceRecordsProvider);

    return GlassScreenScaffold(
      title: ScamShieldStrings.t('ss_evidence_heading', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: scamShieldScreenPadding,
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Text(
          ScamShieldStrings.t('ss_sensitive_locker_load_error', locale),
          style: AppTypography.body,
        ),
        data: (records) {
          if (records.isEmpty) {
            return GlassEmptyState(
              icon: Icons.inventory_2_outlined,
              title: ScamShieldStrings.t('ss_rp_no_evidence', locale),
              description: ScamShieldStrings.t('ss_evidence_subtitle', locale),
            );
          }
          return ListView(
            children: [
              Text(
                ScamShieldStrings.t('ss_evidence_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ...records.map(
                (r) => _EvidenceRow(record: r, locale: locale),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.record, required this.locale});

  final ScamEvidenceRecord record;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.sourceKind.name,
              style: AppTypography.chipLabel.copyWith(
                color: AppColors.cyanGlow,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              record.maskedSummary,
              style: AppTypography.bodySmall,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () =>
                  Share.share(ScamEvidenceLockerService.exportText(record)),
              icon: const Icon(Icons.share_outlined, size: 16),
              label: Text(ScamShieldStrings.t('ss_evidence_share', locale)),
            ),
          ],
        ),
      ),
    );
  }
}
