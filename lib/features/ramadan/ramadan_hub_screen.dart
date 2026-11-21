import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/animated_background.dart';
import 'package:raabta/features/ramadan/ramadan_season.dart';

/// Ramadan-specific companion — prayer times/Qibla use canonical `/prayer-mosque` routes.
class RamadanHubScreen extends StatelessWidget {
  const RamadanHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ramadan'),
      ),
      body: AnimatedAuroraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.purpleGlow,
                glowIntensity: 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌙 ${RamadanSeason.seasonalLabel()}',
                      style: AppTypography.headline2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Prayer times and Qibla live on your Home screen and in Prayer & Mosque — this hub focuses on Ramadan-specific tools.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Tools', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              _toolTile(
                context,
                emoji: '🕌',
                title: 'Prayer Times & Qibla',
                subtitle: 'Canonical prayer tools (Home strip + full schedule)',
                route: '/prayer-mosque/times',
              ),
              _toolTile(
                context,
                emoji: '🤲',
                title: 'Zakat Calculator',
                subtitle: 'Formula-based estimate (not a fatwa)',
                route: '/ramadan/zakat',
              ),
              _toolTile(
                context,
                emoji: '🍽️',
                title: 'Iftar Deals',
                subtitle: 'Restaurants with Ramadan offers',
                route: '/businesses?tag=ramadan_iftar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolTile(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: () => context.push(route),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.title),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
