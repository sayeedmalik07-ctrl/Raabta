import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/screens/housing/l10n/housing_strings.dart';

/// Human-readable labels for scam flag IDs returned by the API.
const Map<String, String> scamFlagLabels = {
  'price_too_low': 'Price unusually low for this area',
  'deposit_before_viewing': 'Asks for deposit before viewing',
  'non_qatar_phone': 'Phone number not in Qatar (+974) format',
  'stolen_photos': 'Photos may be reused or stock images',
  'urgency_language': 'Uses high-pressure urgency language',
  'whatsapp_only': 'WhatsApp only — refuses phone calls',
  'grammar_inconsistency': 'Writing style inconsistent with claimed background',
  'duplicate_phone': 'Same phone used on multiple listings',
  'vague_description': 'Vague or incomplete description',
  'unrealistic_amenities': 'Amenities seem unrealistic for the price',
  'no_photos': 'No photos provided',
};

class ScamSafetyBadge extends StatelessWidget {
  const ScamSafetyBadge({
    super.key,
    required this.listing,
    this.locale = 'English',
    this.compact = false,
    this.showFlags = false,
  });

  final HousingListing listing;
  final String locale;
  final bool compact;
  final bool showFlags;

  ScamVerdict get _verdict {
    if (listing.scamVerdict != null) return listing.scamVerdict!;
    if (listing.scamFlagged) return ScamVerdict.likelyScam;
    if (listing.scamScore != null && listing.scamScore! >= 40) {
      return ScamVerdict.suspicious;
    }
    if (listing.scamScore != null) return ScamVerdict.safe;
    return ScamVerdict.safe;
  }

  @override
  Widget build(BuildContext context) {
    if (listing.scamVerdict == null &&
        listing.scamScore == null &&
        !listing.scamFlagged) {
      return const SizedBox.shrink();
    }

    final (label, color, icon) = switch (_verdict) {
      ScamVerdict.safe => (
          HousingStrings.scamVerdictLabel(ScamVerdict.safe, locale),
          AppColors.success,
          '✓',
        ),
      ScamVerdict.suspicious => (
          HousingStrings.scamVerdictLabel(ScamVerdict.suspicious, locale),
          AppColors.warning,
          '⚠',
        ),
      ScamVerdict.likelyScam => (
          HousingStrings.scamVerdictLabel(ScamVerdict.likelyScam, locale),
          AppColors.error,
          '🚫',
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.45)),
            borderRadius: BorderRadius.circular(AppRadius.circle.x),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (showFlags && listing.scamFlags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          ...listing.scamFlags.take(4).map(
                (flag) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• ${scamFlagLabels[flag] ?? flag.replaceAll('_', ' ')}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class ScamWarningModal {
  static Future<void> show(BuildContext context, HousingListing listing) {
    final flags = listing.scamFlags;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            const Text('🚫', style: TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Possible Scam Detected',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (listing.scamReason != null && listing.scamReason!.isNotEmpty)
                Text(listing.scamReason!, style: AppTextStyles.bodyMedium),
              if (flags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text('What we flagged:', style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                ...flags.map(
                  (flag) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🚩', style: AppTextStyles.bodySmall),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            scamFlagLabels[flag] ??
                                flag.replaceAll('_', ' '),
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to protect yourself',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      listing.scamRecommendation ??
                          'Never pay a deposit before viewing the property in person. '
                              'Verify the landlord\'s QID and tenancy documents. '
                              'Meet at the actual property — not a café or agent office. '
                              'Report suspicious listings to Raabta.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'I understand',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
