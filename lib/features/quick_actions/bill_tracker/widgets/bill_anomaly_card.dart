import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

/// Inline dashboard card when one or more bills look unusually high (Part C).
class BillAnomalyCard extends StatelessWidget {
  const BillAnomalyCard({
    super.key,
    required this.anomalies,
    required this.locale,
  });

  final List<BillAnomaly> anomalies;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (anomalies.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 12,
      glowColor: AppColors.accentGold,
      glowIntensity: 0.1,
      backgroundColor: AppColors.accentGold.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.accentGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  BillTrackerStrings.t('anomaly_card_title', locale),
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            BillTrackerStrings.t('anomaly_card_intro', locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassSecondary
                  : Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          ...anomalies.map((a) => _AnomalyRow(anomaly: a, locale: locale)),
          const SizedBox(height: 6),
          Text(
            BillTrackerStrings.t('anomaly_card_disclaimer', locale),
            style: TextStyle(
              color: AppColors.isLight
                  ? AppColors.textOnGlassMuted
                  : Colors.white.withValues(alpha: 0.35),
              fontSize: 9,
              height: 1.35,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnomalyRow extends StatelessWidget {
  const _AnomalyRow({
    required this.anomaly,
    required this.locale,
  });

  final BillAnomaly anomaly;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        BillTrackerStrings.format('anomaly_card_row', locale, {
          'provider': anomaly.displayProvider,
          'amount': anomaly.currentAmount.toStringAsFixed(0),
          'average': anomaly.averageAmount.toStringAsFixed(0),
          'percent': '${anomaly.roundedPercentAbove}',
          'currency': anomaly.currency,
        }),
        style: TextStyle(
          color: AppColors.isLight
              ? AppColors.textPrimary
              : Colors.white.withValues(alpha: 0.85),
          fontSize: 11,
          height: 1.35,
        ),
      ),
    );
  }
}
