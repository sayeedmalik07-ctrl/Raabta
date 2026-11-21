import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/daily_utilities/driving/domain/qatar_traffic_fees.dart';
import 'package:raabta/features/daily_utilities/driving/widgets/unpaid_fines_banner.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class DrivingHubScreen extends ConsumerWidget {
  const DrivingHubScreen({super.key});

  Future<void> _openMoi() async {
    final uri = Uri.parse(QatarTrafficFees.moiPortalUrl);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: 'Driving & Traffic',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UnpaidFinesBanner(),
            LegalFreshnessIndicator(locale: locale),
            Text(
              'MOI Traffic reference & practice tools — not live Metrash data.',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _HubCard(
              emoji: '🧮',
              title: 'Fee Calculator',
              subtitle: 'Licence renewal, Istimara, penalty reference',
              color: AppColors.sharePurple,
              onTap: () => context.push('/driving/calculator'),
            ),
            const SizedBox(height: 10),
            _HubCard(
              emoji: '📋',
              title: 'Check Fine Status',
              subtitle: 'How to check via Metrash — not an in-app lookup',
              color: AppColors.cyanGlow,
              onTap: () => context.push('/driving/fine-status'),
            ),
            const SizedBox(height: 10),
            _HubCard(
              emoji: '📝',
              title: 'Theory Quiz',
              subtitle: 'Unofficial practice — not MOI certified',
              color: AppColors.accentGold,
              onTap: () => context.push('/driving/theory-quiz'),
            ),
            const SizedBox(height: 10),
            _HubCard(
              emoji: '⏰',
              title: 'Track renewal dates',
              subtitle: 'Driving licence & Istimara in Deadline Tracker',
              color: AppColors.emeraldGlow,
              onTap: () => context.push('/visa'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openMoi,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open MOI / Metrash portal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanGlow,
                side: const BorderSide(color: AppColors.cyanGlow),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      glowColor: color,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title.copyWith(fontSize: 16)),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }
}
