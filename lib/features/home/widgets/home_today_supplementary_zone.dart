import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/providers/home_intelligence_providers.dart';
import 'package:raabta/features/home/widgets/life_event_health_coverage_card.dart';
import 'package:raabta/features/home/widgets/life_event_shock_cluster_card.dart';
import 'package:raabta/features/home/widgets/life_intelligence_signal_card.dart';
import 'package:raabta/features/home/widgets/security_awareness_today_card.dart';
import 'package:raabta/features/home/widgets/todays_focus_card.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Life events and intelligence cards — below glance row on Home.
class HomeTodaySupplementaryZone extends ConsumerWidget {
  const HomeTodaySupplementaryZone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final intelligenceItems =
        ref.watch(homeIntelligenceFocusProvider).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intelligenceItems.isNotEmpty) ...[
          HomeTodayIntelligenceAlerts(
            items: intelligenceItems,
            locale: locale,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const LifeEventHealthCoverageCard(),
        const LifeEventShockClusterCard(),
        const LifeIntelligenceSignalCard(),
        const SecurityAwarenessTodayCard(),
      ],
    );
  }
}