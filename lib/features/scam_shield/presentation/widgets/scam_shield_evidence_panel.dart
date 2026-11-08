import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_offer.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/services/scam_evidence_locker_service.dart';
import 'package:share_plus/share_plus.dart';

class ScamShieldEvidencePanel extends ConsumerStatefulWidget {
  const ScamShieldEvidencePanel({
    super.key,
    required this.locale,
    required this.onSave,
    this.responseLevel,
  });

  final String locale;
  final Future<ScamEvidenceRecord> Function() onSave;
  final ScamIncidentResponseLevel? responseLevel;

  @override
  ConsumerState<ScamShieldEvidencePanel> createState() =>
      _ScamShieldEvidencePanelState();
}

class _ScamShieldEvidencePanelState
    extends ConsumerState<ScamShieldEvidencePanel> {
  ScamEvidenceRecord? _saved;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final record = await widget.onSave();
      if (mounted) {
        setState(() => _saved = record);
        await SensitiveSafetyLockOffer.maybeOfferAfterFirstSensitiveSave(
          context,
          ref,
          locale: widget.locale,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    final record = _saved ?? await widget.onSave();
    if (!mounted) return;
    setState(() => _saved = record);
    await Share.share(ScamEvidenceLockerService.exportText(record));
  }

  @override
  Widget build(BuildContext context) {
    final showPreserve = widget.responseLevel == null ||
        widget.responseLevel!.rank >= ScamIncidentResponseLevel.level4.rank;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_evidence_heading', widget.locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_evidence_subtitle', widget.locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (showPreserve) ...[
          Text(
            ScamShieldStrings.t('ss_evidence_checklist_heading', widget.locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          _checklistRow('ss_evidence_item_screenshot', widget.locale),
          _checklistRow('ss_evidence_item_messages', widget.locale),
          _checklistRow('ss_evidence_item_numbers', widget.locale),
          _checklistRow('ss_evidence_item_timeline', widget.locale),
          const SizedBox(height: AppSpacing.md),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined, size: 16),
              label: Text(
                _saving
                    ? ScamShieldStrings.t('ss_evidence_saving', widget.locale)
                    : ScamShieldStrings.t('ss_evidence_save_local', widget.locale),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_outlined, size: 16),
              label: Text(
                ScamShieldStrings.t('ss_evidence_share', widget.locale),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/scanner'),
              icon: const Icon(Icons.document_scanner_outlined, size: 16),
              label: Text(
                ScamShieldStrings.t('ss_evidence_scan', widget.locale),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/document-vault'),
              icon: const Icon(Icons.folder_outlined, size: 16),
              label: Text(
                ScamShieldStrings.t('ss_evidence_vault', widget.locale),
              ),
            ),
          ],
        ),
        if (_saved != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamShieldStrings.t('ss_evidence_saved_local', widget.locale),
            style: AppTypography.caption.copyWith(color: AppColors.success),
          ),
        ],
      ],
    );
  }

  Widget _checklistRow(String key, String locale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_box_outlined, size: 16, color: AppColors.chipLease),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ScamShieldStrings.t(key, locale),
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
