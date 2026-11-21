import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_context_note_submit.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class RumourContextNoteSourceBadge extends StatelessWidget {
  const RumourContextNoteSourceBadge({
    super.key,
    required this.officialSourceUrl,
    required this.locale,
  });

  final String? officialSourceUrl;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final display =
        RumourContextNoteSubmit.sourceDisplayForUrl(officialSourceUrl);
    if (display == RumourContextSourceDisplay.none) {
      return Text(
        CommunityStrings.t('community_rumour_source_not_proof', locale),
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    final (label, color, icon) = switch (display) {
      RumourContextSourceDisplay.officialAllowlisted => (
          CommunityStrings.t('community_rumour_note_official_source', locale),
          AppColors.success,
          Icons.verified_outlined,
        ),
      RumourContextSourceDisplay.sourceNotVerified => (
          CommunityStrings.t(
            'community_rumour_note_source_not_verified',
            locale,
          ),
          AppColors.warning,
          Icons.warning_amber_outlined,
        ),
      RumourContextSourceDisplay.none => ('', AppColors.textSecondary, Icons.link),
    };

    final url = officialSourceUrl!.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusBadge(label: label, color: color, icon: icon),
        const SizedBox(height: AppSpacing.xs),
        Text(
          CommunityStrings.t('community_rumour_source_not_proof', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: () async {
            final uri = Uri.tryParse(url);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            CommunityStrings.t('community_rumour_read_official_source', locale),
          ),
        ),
      ],
    );
  }
}
