import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/notification_preferences/presentation/screens/notification_preferences_screen.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/shared_something_sheet.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_delivery.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_awareness_models.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_awareness_providers.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_awareness_service.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_strings.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_monthly_tip_scheduler.dart';
import 'package:raabta/providers/notification_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class SecurityAwarenessTodayCard extends ConsumerWidget {
  const SecurityAwarenessTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final campaignAsync = ref.watch(securityAwarenessCampaignProvider);

    return campaignAsync.when(
      data: (campaign) {
        if (campaign == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _SecurityAwarenessCardBody(
            campaign: campaign,
            locale: locale,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SecurityAwarenessCardBody extends ConsumerWidget {
  const _SecurityAwarenessCardBody({
    required this.campaign,
    required this.locale,
  });

  final SecurityAwarenessCampaign campaign;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = SecurityAwarenessService.accentForCampaign(campaign);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: HomeCardTier.homeCardRadius,
      glowColor: accent,
      glowIntensity: HomeCardTier.contextualGlowIntensity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaign.headline,
                  style: AppTypography.title,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.close_rounded,
                  size: AppSpacing.iconSm,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                onPressed: () => dismissSecurityAwarenessCampaign(ref, campaign),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final step in campaign.steps) ...[
            Text(step, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            campaign.sourceLabel,
            style: AppTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: campaign.ctaLabel,
            expand: true,
            accentColor: accent,
            onPressed: () => _onPrimaryCta(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton(
                onPressed: () => dismissSecurityAwarenessCampaign(ref, campaign),
                child: Text(
                  SecurityGuidanceStrings.t('ss_sec_today_got_it', locale),
                ),
              ),
              TextButton(
                onPressed: () => _showWhy(context),
                child: Text(
                  SecurityGuidanceStrings.t('ss_sec_today_why', locale),
                ),
              ),
              TextButton(
                onPressed: () => _turnOffCards(ref),
                child: Text(
                  SecurityGuidanceStrings.t('ss_sec_today_turn_off', locale),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWhy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          SecurityGuidanceStrings.t('ss_sec_today_why', locale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(SecurityGuidanceStrings.t('ss_sec_today_got_it', locale)),
          ),
        ],
      ),
    );
  }

  Future<void> _turnOffCards(WidgetRef ref) async {
    final service =
        await ref.read(notificationPreferencesServiceProvider.future);
    final settings = await service.getSettings();
    await service.saveSettings(
      settings.copyWith(securityTodayCards: false),
    );
    ref.invalidate(notificationSettingsProvider);
    ref.invalidate(securityAwarenessCampaignProvider);
    await SecurityMonthlyTipScheduler.reconcile(locale: locale);
  }

  Future<void> _onPrimaryCta(BuildContext context, WidgetRef ref) async {
    await SecurityAlertDelivery.recordTipOpened();
    ref.invalidate(securityAwarenessCampaignProvider);

    if (campaign.ctaRoute == 'shared_something_sheet') {
      if (context.mounted) {
        await showSharedSomethingSheet(context, locale: locale);
      }
      return;
    }
    if (context.mounted) {
      context.push(campaign.ctaRoute);
    }
  }
}
