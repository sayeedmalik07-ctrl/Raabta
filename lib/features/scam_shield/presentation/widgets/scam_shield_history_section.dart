import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';

class ScamShieldHistorySection extends StatelessWidget {
  const ScamShieldHistorySection({
    super.key,
    required this.entries,
    required this.locale,
    required this.onClear,
  });

  final List<ScamShieldHistoryEntry> entries;
  final String locale;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          overline: ScamShieldStrings.t('ss_scan_overline', locale),
          title: ScamShieldStrings.t('ss_recent_checks', locale),
          subtitle: ScamShieldStrings.t('ss_history_local_note', locale),
          actionText: entries.isNotEmpty
              ? ScamShieldStrings.t('ss_history_clear', locale)
              : null,
          onActionTap: entries.isNotEmpty ? onClear : null,
          leadingIcon: Icons.history,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entries.isEmpty)
          GlassEmptyState(
            icon: Icons.history,
            title: ScamShieldStrings.t('ss_history_empty_title', locale),
            description: ScamShieldStrings.t('ss_history_empty_desc', locale),
          )
        else
          ...entries.take(10).map((entry) => _HistoryRow(entry: entry, locale: locale)),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.locale,
  });

  final ScamShieldHistoryEntry entry;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final riskColor = scamShieldRiskColor(entry.riskLevel);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: riskColor,
        glowIntensity: 0.1,
        borderRadius: AppSpacing.radiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: riskColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ScamShieldStrings.t(
                      scamShieldRiskLabelKey(entry.riskLevel),
                      locale,
                    ),
                    style: AppTypography.chipLabel.copyWith(
                      fontWeight: FontWeight.w700,
                      color: riskColor,
                    ),
                  ),
                ),
                Text(
                  scamShieldRelativeUpdated(entry.scannedAt, locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              switch (entry.kind) {
                ScamShieldHistoryEntryKind.incident =>
                  ScamShieldStrings.t('ss_history_incident', locale),
                ScamShieldHistoryEntryKind.simSwap =>
                  ScamShieldStrings.t('ss_history_sim_swap', locale),
                ScamShieldHistoryEntryKind.scan => ScamShieldStrings.t(
                    entry.contentType!.labelKey,
                    locale,
                  ),
                ScamShieldHistoryEntryKind.proactiveCall =>
                  ScamShieldStrings.t('ss_history_proactive_call', locale),
              },
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              entry.inputPreview,
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (entry.redFlagSummary.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                ScamShieldStrings.format('ss_history_flags_count', locale, {
                  'count': entry.redFlagSummary.length.toString(),
                }),
                style: AppTypography.caption.copyWith(
                  color: AppColors.chipLease,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
