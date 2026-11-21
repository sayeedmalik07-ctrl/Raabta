import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/trip_planner/data/trip_controlled_medicines_config.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Collapsed travel guidance for MoPH controlled medicines (static copy, external links).
class TripControlledMedicinesCard extends StatelessWidget {
  const TripControlledMedicinesCard({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.1,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          title: Text(
            TripStrings.t('trip_pack_medicines_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.cyanGlow),
          ),
          subtitle: Text(
            TripStrings.t('trip_pack_medicines_teaser', locale),
            style: AppTypography.bodySmall,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BodyParagraph(
                    locale: locale,
                    keyName: 'trip_pack_medicines_body_controlled',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _BodyParagraph(
                    locale: locale,
                    keyName: 'trip_pack_medicines_body_epermit',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _BodyParagraph(
                    locale: locale,
                    keyName: 'trip_pack_medicines_body_clearance',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _BodyParagraph(
                    locale: locale,
                    keyName: 'trip_pack_medicines_body_clinician',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _LinkRow(
                    locale: locale,
                    titleKey: 'trip_pack_moph_portal_title',
                    bodyKey: 'trip_pack_moph_portal_body',
                    url: TripControlledMedicinesConfig.mophPortal,
                  ),
                  _LinkRow(
                    locale: locale,
                    titleKey: 'trip_pack_moph_guidelines_title',
                    bodyKey: 'trip_pack_moph_guidelines_body',
                    url: TripControlledMedicinesConfig.travelerGuidelinesPdf,
                  ),
                  _LinkRow(
                    locale: locale,
                    titleKey: 'trip_pack_moph_userguide_title',
                    bodyKey: 'trip_pack_moph_userguide_body',
                    url: TripControlledMedicinesConfig.applicationUserGuidePdf,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    TripStrings.t('trip_official_links_offline_hint', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyParagraph extends StatelessWidget {
  const _BodyParagraph({required this.locale, required this.keyName});

  final String locale;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Text(
      TripStrings.t(keyName, locale),
      style: AppTypography.bodySmall.copyWith(height: 1.45),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.locale,
    required this.titleKey,
    required this.bodyKey,
    required this.url,
  });

  final String locale;
  final String titleKey;
  final String bodyKey;
  final String url;

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceName = TripStrings.t('trip_pack_source_moph', locale);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TripStrings.t(titleKey, locale), style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                TripStrings.t(bodyKey, locale),
                style: AppTypography.bodySmall.copyWith(height: 1.4),
              ),
              const SizedBox(height: AppSpacing.sm),
              TrustLabel(
                type: TrustLabelType.official,
                locale: locale,
                sourceName: sourceName,
                verifiedDateIso: TripControlledMedicinesConfig.lastVerifiedIso,
                sourceUrl: url,
                showDetail: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
