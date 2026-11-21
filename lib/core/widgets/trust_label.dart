import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fixed trust categories — same meaning everywhere in Trip Planner.
///
/// **Sponsored** must never be stored on organic content models (`LocalLifeEntry`,
/// `FairPriceGuideItem`, etc.). Pass it only as a separate overlay when/if paid
/// placement exists — sponsorship must not affect relevance ranking or filtering.
enum TrustLabelType {
  official,
  verified,
  community,
  sponsored,
}

/// Shared trust badge + optional detail row for sourced Trip Planner content.
class TrustLabel extends StatelessWidget {
  const TrustLabel({
    super.key,
    required this.type,
    required this.locale,
    this.sourceName,
    this.verifiedDateIso,
    this.sourceUrl,
    this.showDetail = true,
  });

  final TrustLabelType type;
  final String locale;

  /// Required for [TrustLabelType.official] when [showDetail] is true.
  final String? sourceName;

  /// ISO date string for [TrustLabelType.verified] detail line.
  final String? verifiedDateIso;

  final String? sourceUrl;
  final bool showDetail;

  static Color colorFor(TrustLabelType type) {
    return switch (type) {
      TrustLabelType.official => AppColors.cyanGlow,
      TrustLabelType.verified => AppColors.successBright,
      TrustLabelType.community => AppColors.textSecondary,
      TrustLabelType.sponsored => AppColors.accentGold,
    };
  }

  static IconData iconFor(TrustLabelType type) {
    return switch (type) {
      TrustLabelType.official => Icons.account_balance_outlined,
      TrustLabelType.verified => Icons.verified_outlined,
      TrustLabelType.community => Icons.groups_outlined,
      TrustLabelType.sponsored => Icons.campaign_outlined,
    };
  }

  static String typeLabelKey(TrustLabelType type) {
    return switch (type) {
      TrustLabelType.official => 'trust_label_official',
      TrustLabelType.verified => 'trust_label_verified',
      TrustLabelType.community => 'trust_label_community',
      TrustLabelType.sponsored => 'trust_label_sponsored',
    };
  }

  static String? formatVerifiedDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat.yMMMd().format(parsed);
  }

  String? _detailText() {
    return switch (type) {
      TrustLabelType.official =>
        sourceName != null && sourceName!.isNotEmpty
            ? TripStrings.format('trust_label_official_source', locale, {
                'source': sourceName!,
              })
            : null,
      TrustLabelType.verified => () {
          final formatted = formatVerifiedDate(verifiedDateIso);
          if (formatted == null) return null;
          return TripStrings.format('trust_label_verified_date', locale, {
            'date': formatted,
          });
        }(),
      TrustLabelType.community =>
        TripStrings.t('trust_label_community_detail', locale),
      TrustLabelType.sponsored =>
        TripStrings.t('trust_label_sponsored_detail', locale),
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(type);
    final detail = showDetail ? _detailText() : null;
    final canLink = type == TrustLabelType.official &&
        sourceUrl != null &&
        sourceUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusBadge(
          label: TripStrings.t(typeLabelKey(type), locale),
          color: color,
          icon: iconFor(type),
        ),
        if (detail != null) ...[
          const SizedBox(height: AppSpacing.xs),
          canLink
              ? GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse(sourceUrl!),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    detail,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.cyanGlow,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  detail,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
        ],
      ],
    );
  }
}

/// Official + verified labels for a Local Life entry (when metadata exists).
class LocalLifeTrustLabels extends StatelessWidget {
  const LocalLifeTrustLabels({
    super.key,
    required this.locale,
    this.sourceLabelKey,
    this.sourceUrl,
    this.dateLastVerified,
  });

  final String locale;
  final String? sourceLabelKey;
  final String? sourceUrl;
  final String? dateLastVerified;

  @override
  Widget build(BuildContext context) {
    final hasOfficial = sourceLabelKey != null;
    final hasVerified =
        dateLastVerified != null && dateLastVerified!.isNotEmpty;

    if (!hasOfficial && !hasVerified) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasOfficial)
          TrustLabel(
            type: TrustLabelType.official,
            locale: locale,
            sourceName: TripStrings.t(sourceLabelKey!, locale),
            sourceUrl: sourceUrl,
          ),
        if (hasOfficial && hasVerified) const SizedBox(height: AppSpacing.sm),
        if (hasVerified)
          TrustLabel(
            type: TrustLabelType.verified,
            locale: locale,
            verifiedDateIso: dateLastVerified,
          ),
      ],
    );
  }
}
