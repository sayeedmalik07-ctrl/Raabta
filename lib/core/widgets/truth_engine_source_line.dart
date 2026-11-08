import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

/// One-line source + last verified + official link on Truth Engine outputs.
class TruthEngineSourceLine extends StatelessWidget {
  const TruthEngineSourceLine({
    super.key,
    required this.locale,
    required this.sourceLabel,
    required this.lastVerifiedOn,
    required this.officialUrl,
  });

  final String locale;
  final String sourceLabel;
  final String lastVerifiedOn;
  final String officialUrl;

  @override
  Widget build(BuildContext context) {
    if (sourceLabel.isEmpty && lastVerifiedOn.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sourceLabel.isNotEmpty)
            Text(
              LegalReferenceStrings.format(
                'truth_engine_source_basis',
                locale,
                {'source': sourceLabel},
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          if (lastVerifiedOn.isNotEmpty)
            Text(
              LegalReferenceStrings.format(
                'truth_engine_last_verified',
                locale,
                {'date': lastVerifiedOn},
              ),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          if (officialUrl.isNotEmpty)
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () async {
                final uri = Uri.tryParse(officialUrl);
                if (uri == null) return;
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: Text(
                LegalReferenceStrings.t('truth_engine_official_link', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.cyanGlow,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
