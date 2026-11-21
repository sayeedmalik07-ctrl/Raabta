import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/marketplace/domain/marketplace_payment_phishing_detector.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';

class MarketplaceMessagePhishingAlert extends StatelessWidget {
  const MarketplaceMessagePhishingAlert({
    super.key,
    required this.scan,
    required this.onReport,
    required this.locale,
  });

  final MarketplacePhishingScanResult scan;
  final VoidCallback onReport;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (!scan.hasSignals) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        backgroundColor: AppColors.warning.withValues(alpha: 0.12),
        glowColor: AppColors.warning,
        glowIntensity: 0.1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MarketplaceStrings.t('mp_phishing_warning_title', locale),
              style: AppTypography.subtitle.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              MarketplaceStrings.t('mp_phishing_warning_body', locale),
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...scan.signals.map(
              (signal) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• ${_labelFor(signal)}'
                  '${signal.detailValue != null ? ': ${signal.detailValue}' : ''}',
                  style: AppTypography.caption.copyWith(color: AppColors.warning),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/scam-shield/incident'),
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: Text(
                      MarketplaceStrings.t('mp_incident_help_cta', locale),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                TextButton(
                  onPressed: onReport,
                  child: Text(
                    MarketplaceStrings.t('mp_report_conversation_cta', locale),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(MarketplacePhishingSignal signal) {
    return switch (signal.kind) {
      MarketplacePhishingSignalKind.suspiciousUrl =>
        MarketplaceStrings.t('mp_phish_signal_url', locale),
      MarketplacePhishingSignalKind.paymentAuthorizationLanguage =>
        MarketplaceStrings.t('mp_phish_signal_payment_language', locale),
      MarketplacePhishingSignalKind.qrCodeEmbedded =>
        MarketplaceStrings.t('mp_phish_signal_qr', locale),
    };
  }
}
