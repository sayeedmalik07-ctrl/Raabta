import 'package:flutter/material.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/heat_violation_report_config.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/heat_worker_rights_card.dart';

/// Part B1 static rights + Part B2 report shell (hidden until verified).
class HeatViolationRightsSection extends StatelessWidget {
  const HeatViolationRightsSection({
    super.key,
    required this.locale,
    this.now,
  });

  final String locale;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final showStatic =
        HeatViolationReportConfig.showStaticWorkerRightsCard;
    final showReport = HeatViolationReportConfig.showReportActions &&
        HeatViolationReportConfig.isReportVisible(
          evaluatedAtQatarLocal: now ?? DateTime.now(),
        );

    if (!showStatic && !showReport) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showStatic) ...[
          HomeSectionHeader(
            overline:
                ClimateStrings.t('section_worker_rights_overline', locale),
            title: ClimateStrings.t('section_worker_rights_title', locale),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppSpacing.radiusSm,
            child: HeatWorkerRightsCard(locale: locale),
          ),
        ],
        if (showReport) ...[
          const SizedBox(height: AppSpacing.md),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppSpacing.radiusSm,
            child: const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}
