import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';

/// Trust framing for deterministic EOSB calculation results (no AI).
class EosbResultTruthBanners extends StatelessWidget {
  const EosbResultTruthBanners({
    super.key,
    required this.locale,
    required this.result,
    required this.isReferenceEstimate,
  });

  final String locale;
  final EosbResult result;
  final bool isReferenceEstimate;

  @override
  Widget build(BuildContext context) {
    final confidence = result.explanation.confidenceScore;
    final established = !isReferenceEstimate && confidence >= 0.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TruthConfidenceBanner(
          locale: locale,
          state: established
              ? TruthConfidenceState.known
              : TruthConfidenceState.unknown,
          text: established
              ? TruthPackageCatalog.eosbAssumptionDisplay(0, locale)
              : TruthPackageCatalog.eosbUnknownDisplay(0, locale),
        ),
        if (result.violations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            engine: TruthEngineFamily.eosb,
            text: EosbStrings.t(
              result.violations.first.explanationKey,
              locale,
            ),
          ),
        ] else if (result.comparison?.isUnderpaid == true) ...[
          const SizedBox(height: AppSpacing.sm),
          TruthConfidenceBanner(
            locale: locale,
            state: TruthConfidenceState.action,
            engine: TruthEngineFamily.eosb,
            text: EosbStrings.t('eosb_comparison_details', locale),
          ),
        ],
      ],
    );
  }
}
