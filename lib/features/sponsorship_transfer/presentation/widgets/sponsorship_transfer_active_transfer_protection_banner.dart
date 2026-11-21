import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_reference_disclosure.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';

/// Proactive protection during an active transfer application (Part B) — shown early in the voluntary flow.
class SponsorshipTransferActiveTransferProtectionBanner extends StatelessWidget {
  const SponsorshipTransferActiveTransferProtectionBanner({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.warning,
      glowIntensity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  SponsorshipTransferStrings.t(
                    'st_qid_cancel_active_transfer_early_title',
                    locale,
                  ),
                  style: AppTypography.title.copyWith(
                    fontSize: 14,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            engine: TruthEngineFamily.sponsorshipTransfer,
            text: SponsorshipTransferStrings.t(
              'st_qid_cancel_active_transfer_action',
              locale,
            ),
          ),
          LegalReferenceDisclosure(
            locale: locale,
            sourceKind: TruthEngineSourceKind.sponsorshipTransfer,
            citationPreview: LegalReferenceStrings.format(
              'legal_reference_item_count',
              locale,
              {'count': '1'},
            ),
            children: [
              TruthConfidenceBanner(
                locale: locale,
                state: TruthConfidenceState.known,
                text: SponsorshipTransferStrings.t(
                  'st_qid_cancel_active_transfer_known',
                  locale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
