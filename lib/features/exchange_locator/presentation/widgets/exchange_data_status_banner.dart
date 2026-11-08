import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_data_status.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

/// Surfaces honest directory completeness — partial listings, pending verification.
class ExchangeDataStatusBanner extends StatelessWidget {
  const ExchangeDataStatusBanner({
    super.key,
    required this.dataStatus,
    required this.locale,
    this.coverageNote,
  });

  final ExchangeDataStatus dataStatus;
  final String locale;
  final String? coverageNote;

  @override
  Widget build(BuildContext context) {
    if (dataStatus == ExchangeDataStatus.verified &&
        (coverageNote == null || coverageNote!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final (Color color, String label) = switch (dataStatus) {
      ExchangeDataStatus.pendingVerification => (
          AppColors.warning,
          ExchangeLocatorStrings.t('details_being_confirmed', locale),
        ),
      ExchangeDataStatus.partial => (
          AppColors.cyanGlow,
          ExchangeLocatorStrings.t('partial_listing', locale),
        ),
      ExchangeDataStatus.verified => (
          AppColors.textSecondary,
          ExchangeLocatorStrings.t('listing_note', locale),
        ),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(label: label, color: color),
          if (coverageNote != null && coverageNote!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(coverageNote!, style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}
