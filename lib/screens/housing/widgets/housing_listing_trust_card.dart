import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';
import 'package:raabta/widgets/housing/scam_safety_badge.dart';

/// Inline trust guidance on Housing listing detail — wires to existing engines only.
class HousingListingTrustCard extends StatelessWidget {
  const HousingListingTrustCard({
    super.key,
    required this.listing,
    required this.locale,
  });

  final HousingListing listing;
  final String locale;

  static bool showBrokerVerificationRow(HousingListing listing) {
    // No dedicated agency field on HousingListing — Qatar-side broker checks apply
    // to any property listing context (contactName is poster contact, not agency ID).
    return true;
  }

  static bool showRiskRow(HousingListing listing) {
    if (listing.scamFlagged) return true;
    if (listing.scamVerdict == ScamVerdict.suspicious ||
        listing.scamVerdict == ScamVerdict.likelyScam) {
      return true;
    }
    if (listing.scamFlags.isNotEmpty) return true;
    final score = listing.scamScore;
    return score != null && score >= 40;
  }

  static String tenancySummary(HousingListing listing, String locale) {
    final text = '${listing.title} ${listing.description}'.toLowerCase();
    if (text.contains('deposit') ||
        text.contains('advance') ||
        text.contains('security')) {
      return HousingStrings.t('trust_tenancy_summary_deposit', locale);
    }
    return HousingStrings.t('trust_tenancy_summary_registration', locale);
  }

  static String riskSummary(HousingListing listing, String locale) {
    if (listing.scamReason != null && listing.scamReason!.trim().isNotEmpty) {
      return listing.scamReason!.trim();
    }
    if (listing.scamFlags.isNotEmpty) {
      final label = scamFlagLabels[listing.scamFlags.first] ??
          listing.scamFlags.first.replaceAll('_', ' ');
      return HousingStrings.format(
        'trust_risk_summary_flag',
        locale,
        params: {'flag': label},
      );
    }
    if (listing.scamScore != null && listing.scamScore! >= 40) {
      return HousingStrings.format(
        'trust_risk_summary_score',
        locale,
        params: {'score': '${listing.scamScore}'},
      );
    }
    return HousingStrings.t('trust_risk_summary_generic', locale);
  }

  @override
  Widget build(BuildContext context) {
    final showBroker = showBrokerVerificationRow(listing);
    final showRisk = showRiskRow(listing);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight.isFinite &&
            constraints.maxHeight > 0 &&
            constraints.maxHeight < 520;
        final sectionGap =
            compact ? AppSpacing.sm : AppSpacing.md;
        final cardPadding =
            compact ? AppSpacing.md : AppSpacing.lg;

        return GlassCard(
      borderRadius: AppSpacing.radiusLg,
      padding: EdgeInsets.all(cardPadding),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.08,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            HousingStrings.t('trust_card_title', locale),
            style: AppTypography.subtitle,
          ),
          SizedBox(height: sectionGap),
          _TrustRow(
            compact: compact,
            icon: Icons.shield_outlined,
            title: HousingStrings.t('trust_listing_check_title', locale),
            summary: HousingStrings.t('trust_listing_check_summary', locale),
            buttonLabel: HousingStrings.t('trust_listing_check_button', locale),
            onPressed: () => context.push('/tenancy/listing-check'),
          ),
          SizedBox(height: sectionGap),
          _TrustRow(
            compact: compact,
            icon: Icons.gavel_outlined,
            title: HousingStrings.t('trust_tenancy_title', locale),
            summary: tenancySummary(listing, locale),
            buttonLabel: HousingStrings.t('trust_tenancy_button', locale),
            onPressed: () => context.push('/tenancy'),
          ),
          if (showBroker) ...[
            SizedBox(height: sectionGap),
            _TrustRow(
              compact: compact,
              icon: Icons.verified_user_outlined,
              title: HousingStrings.t('trust_broker_title', locale),
              summary: HousingStrings.t('trust_broker_summary', locale),
              buttonLabel: HousingStrings.t('trust_broker_button', locale),
              onPressed: () => context.push(
                AgencyVerificationScreen.route(
                  section: AgencyVerificationScreen.qatarRealEstateSection,
                ),
              ),
            ),
          ],
          if (showRisk) ...[
            SizedBox(height: sectionGap),
            _TrustRow(
              compact: compact,
              icon: Icons.shield_outlined,
              title: HousingStrings.t('trust_risk_title', locale),
              summary: riskSummary(listing, locale),
              buttonLabel: HousingStrings.t('trust_risk_button', locale),
              onPressed: () => context.push('/scam-shield'),
            ),
          ],
        ],
      ),
      ),
    );
      },
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({
    required this.icon,
    required this.title,
    required this.summary,
    required this.buttonLabel,
    required this.onPressed,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String summary;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.cyanGlow),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.subtitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    summary,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cyanGlow,
              visualDensity:
                  compact ? VisualDensity.compact : VisualDensity.standard,
              padding: compact
                  ? const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    )
                  : null,
              side: BorderSide(
                color: AppColors.cyanGlow.withValues(alpha: 0.45),
              ),
            ),
            child: Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}
