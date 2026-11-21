import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_manual_checks.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_models.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/presentation/screens/trip_subscreens.dart';
import 'package:raabta/features/trip_planner/presentation/widgets/trip_readiness_widgets.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/features/trip_planner/providers/trip_readiness_providers.dart';

class TripReadinessScreen extends ConsumerWidget {
  const TripReadinessScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripPlannerProvider);
    final trip = tripForId(state, tripId);
    final locale = state.preferences.locale;
    final readiness = ref.watch(tripReadinessProvider(tripId));

    if (trip == null) {
      return GlassScreenScaffold(
        title: TripStrings.t('readiness_title', locale),
        body: const Center(child: GlassProgressIndicator()),
      );
    }

    return GlassScreenScaffold(
      title: TripStrings.t('readiness_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          TripReadinessSummaryCard(
            tripId: tripId,
            locale: locale,
            result: readiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            TripStrings.t('readiness_breakdown', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...readiness.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ReadinessActionTile(
                item: item,
                locale: locale,
                manual: trip.readinessManualChecks,
                onChanged: (checks) => ref
                    .read(tripPlannerProvider.notifier)
                    .updateReadinessManualChecks(tripId, checks),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              TripStrings.t('readiness_disclaimer', locale),
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessActionTile extends StatelessWidget {
  const _ReadinessActionTile({
    required this.item,
    required this.locale,
    required this.manual,
    required this.onChanged,
  });

  final TripReadinessItem item;
  final String locale;
  final TripReadinessManualChecks manual;
  final ValueChanged<TripReadinessManualChecks> onChanged;

  @override
  Widget build(BuildContext context) {
    final title = TripStrings.t(_categoryKey(item.category), locale);
    final why = TripStrings.t(_whyKey(item.category), locale);
    final detail =
        item.detailKey == null ? '' : TripStrings.t(item.detailKey!, locale);

    final showManualToggle = _allowsManualToggle(item);

    return GlassCard(
      onTap: showManualToggle
          ? null
          : () => handleReadinessItemTap(
                context,
                item: item,
                onManualToggle: null,
              ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: AppTypography.title.copyWith(fontSize: 15)),
              ),
              if (showManualToggle)
                Switch(
                  value: _manualValue(manual),
                  onChanged: (v) => onChanged(_updateManual(manual, v)),
                )
              else if (!item.isComplete && item.actionRoute != null)
                TextButton(
                  onPressed: () => context.push(item.actionRoute!),
                  child: Text(TripStrings.t('readiness_open', locale)),
                ),
            ],
          ),
          Text(why, style: AppTypography.bodySmall),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(detail, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }

  bool _allowsManualToggle(TripReadinessItem item) {
    if (item.category == TripReadinessCategory.passportValidity ||
        item.category == TripReadinessCategory.visaEntry) {
      return item.status == TripReadinessItemStatus.attention;
    }
    return switch (item.category) {
      TripReadinessCategory.travelInsurance ||
      TripReadinessCategory.insuranceCancellationCoverage ||
      TripReadinessCategory.connectivity ||
      TripReadinessCategory.currencyReady ||
      TripReadinessCategory.emergencyContacts =>
        true,
      _ => false,
    };
  }

  bool _manualValue(TripReadinessManualChecks manual) {
    return switch (item.category) {
      TripReadinessCategory.passportValidity => manual.passportConfirmed,
      TripReadinessCategory.visaEntry => manual.visaConfirmed,
      TripReadinessCategory.travelInsurance => manual.travelInsurance,
      TripReadinessCategory.insuranceCancellationCoverage =>
        manual.insuranceCancellationCoverage,
      TripReadinessCategory.connectivity => manual.connectivity,
      TripReadinessCategory.currencyReady => manual.currencyReady,
      TripReadinessCategory.emergencyContacts => manual.emergencyContacts,
      _ => false,
    };
  }

  TripReadinessManualChecks _updateManual(
    TripReadinessManualChecks manual,
    bool value,
  ) {
    return switch (item.category) {
      TripReadinessCategory.passportValidity =>
        manual.copyWith(passportConfirmed: value),
      TripReadinessCategory.visaEntry => manual.copyWith(visaConfirmed: value),
      TripReadinessCategory.travelInsurance =>
        manual.copyWith(travelInsurance: value),
      TripReadinessCategory.insuranceCancellationCoverage =>
        manual.copyWith(insuranceCancellationCoverage: value),
      TripReadinessCategory.connectivity =>
        manual.copyWith(connectivity: value),
      TripReadinessCategory.currencyReady =>
        manual.copyWith(currencyReady: value),
      TripReadinessCategory.emergencyContacts =>
        manual.copyWith(emergencyContacts: value),
      _ => manual,
    };
  }

  String _categoryKey(TripReadinessCategory category) {
    return switch (category) {
      TripReadinessCategory.passportValidity => 'readiness_cat_passport',
      TripReadinessCategory.visaEntry => 'readiness_cat_visa',
      TripReadinessCategory.flightBooked => 'readiness_cat_flight',
      TripReadinessCategory.accommodationBooked => 'readiness_cat_hotel',
      TripReadinessCategory.travelInsurance => 'readiness_cat_insurance',
      TripReadinessCategory.insuranceCancellationCoverage =>
        'readiness_cat_insurance_cancellation',
      TripReadinessCategory.connectivity => 'readiness_cat_connectivity',
      TripReadinessCategory.currencyReady => 'readiness_cat_currency',
      TripReadinessCategory.emergencyContacts => 'readiness_cat_emergency',
    };
  }

  String _whyKey(TripReadinessCategory category) {
    return switch (category) {
      TripReadinessCategory.passportValidity => 'readiness_why_passport',
      TripReadinessCategory.visaEntry => 'readiness_why_visa',
      TripReadinessCategory.flightBooked => 'readiness_why_flight',
      TripReadinessCategory.accommodationBooked => 'readiness_why_hotel',
      TripReadinessCategory.travelInsurance => 'readiness_why_insurance',
      TripReadinessCategory.insuranceCancellationCoverage =>
        'readiness_why_insurance_cancellation',
      TripReadinessCategory.connectivity => 'readiness_why_connectivity',
      TripReadinessCategory.currencyReady => 'readiness_why_currency',
      TripReadinessCategory.emergencyContacts => 'readiness_why_emergency',
    };
  }
}
