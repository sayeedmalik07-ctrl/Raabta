// PARKED FEATURE — NOT CURRENTLY LIVE IN THE APP (as of 2026-08-20).
//
// This flight price checker was built and tested, but removed from
// Daily Essential Tools because no free/self-serve flight-data API
// currently supports real multi-city search and filtration
// (Skyscanner-style). The version at removal time used simple deep-link
// buttons to Google Flights and Skyscanner — too thin to represent
// Raabta well next to features like EOSB/Overtime Truth Engine.
//
// Revisit when either becomes true:
// (1) Raabta crosses ~50,000 MAU, unlocking Travelpayouts' free
//     real-time Search API with genuine filtration, or
// (2) There's appetite to pay Duffel's per-search fee for native
//     structured search/filter results.
//
// This code is intentionally left in place, not deleted, so the
// feature can be re-wired in (re-add the route + Daily Essential
// Tools tile) without rebuilding from scratch.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/providers/home_country_support_providers.dart';
import 'package:raabta/features/flight_checker/domain/corridor_flight_catalog.dart';
import 'package:raabta/features/flight_checker/presentation/l10n/flight_checker_strings.dart';
import 'package:raabta/features/flight_checker/presentation/widgets/flight_checker_widgets.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';

class FlightCheckerScreen extends ConsumerStatefulWidget {
  const FlightCheckerScreen({super.key});

  @override
  ConsumerState<FlightCheckerScreen> createState() =>
      _FlightCheckerScreenState();
}

class _FlightCheckerScreenState extends ConsumerState<FlightCheckerScreen> {
  String? _expandedCountryId;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: FlightCheckerStrings.t('fc_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: moneyHubScreenPadding,
        body: ListView(
          children: [
            Text(
              FlightCheckerStrings.t('fc_subtitle', locale),
              style: AppTypography.body.copyWith(
                color: AppColors.textOnGlassMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              FlightCheckerStrings.t('fc_disclaimer', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _EmergencyTravelCard(locale: locale),
            const SizedBox(height: AppSpacing.xxl),
            HomeSectionHeader(
              overline: FlightCheckerStrings.t('fc_origin_label', locale),
              title: FlightCheckerStrings.t('fc_pick_destination', locale),
              leadingIcon: Icons.flight_takeoff_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            ...CorridorFlightCatalog.countries.map(
              (country) => _CountryTile(
                country: country,
                locale: locale,
                expanded: _expandedCountryId == country.id,
                onTap: () {
                  setState(() {
                    _expandedCountryId =
                        _expandedCountryId == country.id ? null : country.id;
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppSpacing.radiusLg,
              glowColor: AppColors.cyanGlow,
              glowIntensity: 0.1,
              child: FlightBookingTipsSection(locale: locale),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _EmergencyTravelCard extends ConsumerWidget {
  const _EmergencyTravelCard({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      onTap: () => context.push('/flight-checker/emergency'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.errorBright,
      glowIntensity: 0.14,
      child: Row(
        children: [
          const HomeIconBadge(
            icon: Icons.emergency_outlined,
            accentColor: AppColors.errorBright,
            size: 44,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FlightCheckerStrings.t('fc_emergency', locale),
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  FlightCheckerStrings.t('fc_emergency_sub', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.errorBright.withValues(alpha: 0.9)),
        ],
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.locale,
    required this.expanded,
    required this.onTap,
  });

  final CorridorFlightCountry country;
  final String locale;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: AppSpacing.radiusLg,
        glowColor: expanded ? AppColors.cyanGlow : null,
        glowIntensity: expanded ? 0.12 : 0,
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        FlightCheckerStrings.t(country.nameKey, locale),
                        style: AppTypography.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final dest in country.destinations) ...[
                      Text(
                        FlightCheckerStrings.t(dest.cityNameKey, locale),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnGlassMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FlightProviderButtons(
                        destinationIata: dest.airportIata,
                        locale: locale,
                        compact: true,
                      ),
                      if (dest != country.destinations.last)
                        const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Emergency path — nationality from profile, straight to external search.
class FlightEmergencyScreen extends ConsumerWidget {
  const FlightEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final contextAsync = ref.watch(homeCountryUserContextProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: FlightCheckerStrings.t('fc_emergency_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: moneyHubScreenPadding,
        body: contextAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _EmergencyBody(
            locale: locale,
            country: null,
            message: FlightCheckerStrings.t('fc_emergency_no_nationality', locale),
          ),
          data: (userContext) {
            final countryId =
                CorridorFlightCatalog.resolveCountryId(userContext.nationality);
            final country = countryId != null
                ? CorridorFlightCatalog.countryById(countryId)
                : null;
            if (country == null) {
              final msg = userContext.nationality.trim().isEmpty
                  ? FlightCheckerStrings.t('fc_emergency_no_nationality', locale)
                  : FlightCheckerStrings.t(
                      'fc_emergency_unsupported',
                      locale,
                    );
              return _EmergencyBody(locale: locale, country: null, message: msg);
            }
            return _EmergencyBody(locale: locale, country: country);
          },
        ),
      ),
    );
  }
}

class _EmergencyBody extends StatelessWidget {
  const _EmergencyBody({
    required this.locale,
    required this.country,
    this.message,
  });

  final String locale;
  final CorridorFlightCountry? country;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (country == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            message ?? '',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final primary = country!.primaryDestination;
    return ListView(
      children: [
        Row(
          children: [
            Text(country!.flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FlightCheckerStrings.t(country!.nameKey, locale),
                    style: AppTypography.headline2,
                  ),
                  Text(
                    '${FlightCheckerStrings.t('fc_origin_label', locale)} → '
                    '${FlightCheckerStrings.t(primary.cityNameKey, locale)}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        FlightProviderButtons(
          destinationIata: primary.airportIata,
          locale: locale,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          FlightCheckerStrings.t('fc_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
