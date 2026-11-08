import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/trip_planner/data/trip_official_links_config.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/services/trip_planner_analytics_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TripOfficialLinksCard extends StatelessWidget {
  const TripOfficialLinksCard({
    super.key,
    required this.locale,
    required this.showStopoverRow,
  });

  final String locale;
  final bool showStopoverRow;

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
            TripStrings.t('trip_official_links_title', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.cyanGlow),
          ),
          subtitle: Text(
            TripStrings.t('trip_official_links_teaser', locale),
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
                children: [
                  _OfficialRow(
                    locale: locale,
                    titleKey: 'trip_official_row_visas',
                    bodyKey: 'trip_official_row_visas_body',
                    sourceNameKey: 'trip_official_source_visit_qatar',
                    url: TripOfficialLinksConfig.visitQatarVisas,
                    analyticsRow: TripOfficialLinksConfig.rowVisas,
                  ),
                  _OfficialRow(
                    locale: locale,
                    titleKey: 'trip_official_row_hayya',
                    bodyKey: 'trip_official_row_hayya_body',
                    sourceNameKey: 'trip_official_source_hayya',
                    url: TripOfficialLinksConfig.hayyaPortal,
                    analyticsRow: TripOfficialLinksConfig.rowHayya,
                  ),
                  _OfficialRow(
                    locale: locale,
                    titleKey: 'trip_official_row_events',
                    bodyKey: 'trip_official_row_events_body',
                    sourceNameKey: 'trip_official_source_visit_qatar',
                    url: TripOfficialLinksConfig.visitQatarEvents,
                    analyticsRow: TripOfficialLinksConfig.rowEvents,
                  ),
                  _OfficialRow(
                    locale: locale,
                    titleKey: 'trip_official_row_things_to_do',
                    bodyKey: 'trip_official_row_things_to_do_body',
                    sourceNameKey: 'trip_official_source_visit_qatar',
                    url: TripOfficialLinksConfig.visitQatarThingsToDo,
                    analyticsRow: TripOfficialLinksConfig.rowThingsToDo,
                  ),
                  if (showStopoverRow)
                    _OfficialRow(
                      locale: locale,
                      titleKey: 'trip_official_row_stopover',
                      bodyKey: 'trip_official_row_stopover_body',
                      sourceNameKey: 'trip_official_source_visit_qatar',
                      url: TripOfficialLinksConfig.visitQatarStopover,
                      analyticsRow: TripOfficialLinksConfig.rowStopover,
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

class _OfficialRow extends StatelessWidget {
  const _OfficialRow({
    required this.locale,
    required this.titleKey,
    required this.bodyKey,
    required this.sourceNameKey,
    required this.url,
    required this.analyticsRow,
  });

  final String locale;
  final String titleKey;
  final String bodyKey;
  final String sourceNameKey;
  final String url;
  final String analyticsRow;

  Future<void> _open() async {
    TripPlannerAnalyticsService.officialLinkTapped(analyticsRow);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceName = TripStrings.t(sourceNameKey, locale);
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
                verifiedDateIso: TripOfficialLinksConfig.lastVerifiedIso,
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
