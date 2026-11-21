import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_readiness_models.dart';
import 'package:raabta/features/disruption_readiness/presentation/l10n/disruption_readiness_strings.dart';
import 'package:raabta/features/disruption_readiness/presentation/screens/disruption_readiness_screen.dart';
import 'package:raabta/features/disruption_readiness/services/disruption_readiness_analytics.dart';

class DisruptionTripReadinessCard extends StatefulWidget {
  const DisruptionTripReadinessCard({
    super.key,
    required this.tripId,
    required this.locale,
  });

  final String tripId;
  final String locale;

  @override
  State<DisruptionTripReadinessCard> createState() =>
      _DisruptionTripReadinessCardState();
}

class _DisruptionTripReadinessCardState extends State<DisruptionTripReadinessCard> {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      glowColor: AppColors.info,
      glowIntensity: 0.12,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (open) {
            if (open) {
              DisruptionReadinessAnalytics.moduleOpened(
                profile: DisruptionEntryProfile.tripPlanner.name,
                tripId: widget.tripId,
              );
            }
          },
          title: Text(
            DisruptionReadinessStrings.t('dr_trip_card_title', widget.locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.info),
          ),
          subtitle: Text(
            DisruptionReadinessStrings.t('dr_trip_card_teaser', widget.locale),
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
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    DisruptionReadinessScreen.route(
                      profile: DisruptionEntryProfile.tripPlanner,
                      tripId: widget.tripId,
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(
                    DisruptionReadinessStrings.t(
                      'dr_trip_card_open',
                      widget.locale,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
