import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/flight_checker/domain/corridor_flight_catalog.dart';
import 'package:raabta/features/flight_checker/domain/flight_deep_link_builder.dart';
import 'package:raabta/features/flight_checker/presentation/l10n/flight_checker_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class FlightProviderButtons extends StatelessWidget {
  const FlightProviderButtons({
    super.key,
    required this.destinationIata,
    required this.locale,
    this.compact = false,
  });

  final String destinationIata;
  final String locale;
  final bool compact;

  Future<void> _open(BuildContext context, FlightSearchProvider provider) async {
    final uri = FlightDeepLinkBuilder.forProvider(
      provider: provider,
      destinationIata: destinationIata,
    );
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        _snack(context, FlightCheckerStrings.t('fc_open_failed', locale));
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _open(context, FlightSearchProvider.googleFlights),
              icon: const Icon(Icons.travel_explore, size: 18),
              label: Text(
                FlightCheckerStrings.t('fc_search_google', locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanGlow,
                side: BorderSide(color: AppColors.cyanGlow.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _open(context, FlightSearchProvider.skyscanner),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(
                FlightCheckerStrings.t('fc_search_skyscanner', locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sharePurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _open(context, FlightSearchProvider.googleFlights),
          icon: const Icon(Icons.travel_explore, size: 20),
          label: Text(FlightCheckerStrings.t('fc_search_google', locale)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cyanGlow,
            side: BorderSide(color: AppColors.cyanGlow.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => _open(context, FlightSearchProvider.skyscanner),
          icon: const Icon(Icons.open_in_new, size: 20),
          label: Text(FlightCheckerStrings.t('fc_search_skyscanner', locale)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.sharePurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class FlightBookingTipsSection extends StatelessWidget {
  const FlightBookingTipsSection({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FlightCheckerStrings.t('fc_tips_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          FlightCheckerStrings.t('fc_tips_sub', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final key in CorridorFlightCatalog.bookingTipKeys)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.cyanGlow,
                  ),
                ),
                Expanded(
                  child: Text(
                    FlightCheckerStrings.t(key, locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
