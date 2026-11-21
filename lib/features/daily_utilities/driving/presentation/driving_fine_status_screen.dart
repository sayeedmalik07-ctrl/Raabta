import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/daily_utilities/driving/domain/qatar_traffic_fees.dart';
import 'package:raabta/features/daily_utilities/driving/widgets/unpaid_fines_banner.dart';
import 'package:url_launcher/url_launcher.dart';

/// Informational explainer — Raabta cannot pull live MOI fine data.
class DrivingFineStatusScreen extends StatelessWidget {
  const DrivingFineStatusScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScreenScaffold(
      title: 'Check Fine Status',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UnpaidFinesBanner(),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.cyanGlow),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Raabta cannot check your live fines',
                          style: AppTypography.title.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is not connected to MOI or Metrash systems. Use the official channels below to see your actual balance, pay fines, and unblock renewals or travel.',
                    style: AppTypography.bodySmall.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('How to check', style: AppTypography.title.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            _Step(n: '1', text: 'Open the Metrash app or MOI self-service portal.'),
            _Step(n: '2', text: 'Sign in with your QID credentials.'),
            _Step(
              n: '3',
              text: 'Go to Traffic Services → Fines / Violations to view unpaid amounts.',
            ),
            _Step(n: '4', text: 'Pay outstanding fines before licence, Istimara, QID renewal, or travel.'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _open(QatarTrafficFees.metrashUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open MOI / Metrash portal'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sharePurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _open('https://www.moi.gov.qa'),
              icon: const Icon(Icons.language),
              label: const Text('MOI Traffic website'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanGlow,
                side: const BorderSide(color: AppColors.cyanGlow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.text});

  final String n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.sharePurple.withValues(alpha: 0.3),
            child: Text(n, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
