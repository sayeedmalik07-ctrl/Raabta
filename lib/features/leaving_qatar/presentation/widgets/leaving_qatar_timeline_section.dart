import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/eosb/presentation/widgets/home_country_support_section.dart';
import 'package:raabta/features/leaving_qatar/data/leaving_qatar_catalog.dart';
import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';
import 'package:raabta/features/disruption_readiness/presentation/l10n/disruption_readiness_strings.dart';
import 'package:raabta/features/disruption_readiness/presentation/screens/disruption_readiness_screen.dart';
import 'package:raabta/features/disruption_readiness/presentation/screens/disruption_understand_alert_screen.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_readiness_models.dart';
import 'package:raabta/features/welcome_home/presentation/l10n/welcome_home_strings.dart';
import 'package:raabta/features/welcome_home/presentation/screens/welcome_home_screen.dart';
import 'package:raabta/features/welcome_home/services/welcome_home_analytics.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_departure_bundle_sheet.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_eosb_card.dart';
import 'package:raabta/features/leaving_qatar/presentation/widgets/leaving_qatar_timeline_progress.dart';
import 'package:raabta/features/leaving_qatar/providers/leaving_qatar_providers.dart';
import 'package:raabta/providers/auth_providers.dart';

class LeavingQatarTimelineSection extends ConsumerWidget {
  const LeavingQatarTimelineSection({
    super.key,
    required this.locale,
    required this.category,
  });

  final String locale;
  final LeavingQatarWorkerCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionAsync = ref.watch(leavingQatarChecklistCompletionProvider);
    final completion = completionAsync.valueOrNull ?? const {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LeavingQatarTimelineProgress(
          locale: locale,
          completion: completion,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          LeavingQatarStrings.t('lq_checklist_note', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.md),
        ...LeavingQatarTimelineStage.values.map(
          (stage) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: _TimelineStageBlock(
              stage: stage,
              locale: locale,
              category: category,
              completion: completion,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStageBlock extends ConsumerWidget {
  const _TimelineStageBlock({
    required this.stage,
    required this.locale,
    required this.category,
    required this.completion,
  });

  final LeavingQatarTimelineStage stage;
  final String locale;
  final LeavingQatarWorkerCategory? category;
  final Map<String, bool> completion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = LeavingQatarCatalog.itemsForStage(stage).toList();
    final stageDone =
        items.where((item) => completion[item.id] == true).length;
    final stageColor = _stageColor(stage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: stageColor),
                    ),
                    child: Icon(_stageIcon(stage), color: stageColor, size: 16),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LeavingQatarStrings.t(
                        LeavingQatarCatalog.stageHeadingKey(stage),
                        locale,
                      ),
                      style: AppTypography.subtitle.copyWith(
                        color: stageColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LeavingQatarStrings.t(
                        LeavingQatarCatalog.stageSubtitleKey(stage),
                        locale,
                      ),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (items.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        LeavingQatarStrings.tf(
                          'lq_timeline_stage_progress',
                          locale,
                          {
                            'done': '$stageDone',
                            'total': '${items.length}',
                          },
                        ),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.cyanGlow,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._stageExtras(context, ref),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ChecklistTaskTile(
              item: item,
              locale: locale,
              completed: completion[item.id] == true,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _stageExtras(BuildContext context, WidgetRef ref) {
    switch (stage) {
      case LeavingQatarTimelineStage.early:
        return [
          HomeCountrySupportSection(locale: locale),
          const SizedBox(height: AppSpacing.sm),
          LeavingQatarEosbCard(locale: locale),
          const SizedBox(height: AppSpacing.sm),
        ];
      case LeavingQatarTimelineStage.mid:
        return [
          if (category != null) ...[
            _ExitPermitCard(category: category!, locale: locale),
            const SizedBox(height: AppSpacing.sm),
          ],
          _KahramaaCard(locale: locale),
          const SizedBox(height: AppSpacing.sm),
          _CrossLinkCard(
            icon: Icons.open_in_new_rounded,
            color: AppColors.warning,
            title: LeavingQatarStrings.t('lq_link_moi_exit_title', locale),
            body: LeavingQatarStrings.t('lq_link_moi_exit_body', locale),
            actionLabel:
                LeavingQatarStrings.t('lq_link_moi_exit_action', locale),
            onAction: () => openLeavingQatarOfficialLink(
              LeavingQatarOfficialLinks.metrashPortalUrl,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CrossLinkCard(
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.purpleGlow,
            title: LeavingQatarStrings.t('lq_link_eosb_mid_title', locale),
            body: LeavingQatarStrings.t('lq_link_eosb_mid_body', locale),
            actionLabel: LeavingQatarStrings.t('lq_eosb_view', locale),
            onAction: () => context.push('/eosb/result'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ];
      case LeavingQatarTimelineStage.late:
        return [
          _CrossLinkCard(
            icon: Icons.open_in_new_rounded,
            color: AppColors.cyanGlow,
            title: LeavingQatarStrings.t('lq_link_moi_status_title', locale),
            body: LeavingQatarStrings.t('lq_link_moi_status_body', locale),
            actionLabel:
                LeavingQatarStrings.t('lq_link_moi_status_action', locale),
            onAction: () => openLeavingQatarOfficialLink(
              LeavingQatarOfficialLinks.moiPortalUrl,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CrossLinkCard(
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.purpleGlow,
            title: LeavingQatarStrings.t('lq_link_eosb_late_title', locale),
            body: LeavingQatarStrings.t('lq_link_eosb_late_body', locale),
            actionLabel: LeavingQatarStrings.t('lq_eosb_view', locale),
            onAction: () => context.push('/eosb/result'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ];
      case LeavingQatarTimelineStage.departure:
        return [
          _TravelBanCard(locale: locale),
          const SizedBox(height: AppSpacing.sm),
          _CrossLinkCard(
            icon: Icons.home_work_outlined,
            color: AppColors.info,
            title: WelcomeHomeStrings.t('wh_lq_card_title', locale),
            body: WelcomeHomeStrings.t('wh_lq_card_body', locale),
            actionLabel: WelcomeHomeStrings.t('wh_lq_card_action', locale),
            onAction: () {
              WelcomeHomeAnalytics.cardOpened();
              context.push(WelcomeHomeScreen.route);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _CrossLinkCard(
            icon: Icons.travel_explore_outlined,
            color: AppColors.info,
            title: DisruptionReadinessStrings.t('dr_lq_card_title', locale),
            body: DisruptionReadinessStrings.t('dr_lq_card_body', locale),
            actionLabel:
                DisruptionReadinessStrings.t('dr_lq_card_action', locale),
            onAction: () => context.push(
              DisruptionReadinessScreen.route(
                profile: DisruptionEntryProfile.leavingQatar,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CrossLinkCard(
            icon: Icons.sms_outlined,
            color: AppColors.info,
            title: DisruptionReadinessStrings.t(
              'dr_understand_alert_entry_title',
              locale,
            ),
            body: DisruptionReadinessStrings.t(
              'dr_understand_alert_entry_body',
              locale,
            ),
            actionLabel: DisruptionReadinessStrings.t(
              'dr_understand_alert_title',
              locale,
            ),
            onAction: () =>
                context.push(DisruptionUnderstandAlertScreen.route),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.sharePurple,
            glowIntensity: 0.14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LeavingQatarStrings.t('lq_bundle_export_title', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.sharePurple,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LeavingQatarStrings.t('lq_bundle_export_subtitle', locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassPrimaryButton(
                  label: LeavingQatarStrings.t('lq_bundle_open_sheet', locale),
                  onPressed: () => LeavingQatarDepartureBundleSheet.show(
                    context,
                    locale: locale,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ];
    }
  }

  Color _stageColor(LeavingQatarTimelineStage stage) {
    switch (stage) {
      case LeavingQatarTimelineStage.early:
        return AppColors.emeraldGlow;
      case LeavingQatarTimelineStage.mid:
        return AppColors.accentGold;
      case LeavingQatarTimelineStage.late:
        return AppColors.heatOrange;
      case LeavingQatarTimelineStage.departure:
        return AppColors.cyanGlow;
    }
  }

  IconData _stageIcon(LeavingQatarTimelineStage stage) {
    switch (stage) {
      case LeavingQatarTimelineStage.early:
        return Icons.calendar_month_outlined;
      case LeavingQatarTimelineStage.mid:
        return Icons.event_note_outlined;
      case LeavingQatarTimelineStage.late:
        return Icons.warning_amber_outlined;
      case LeavingQatarTimelineStage.departure:
        return Icons.flight_takeoff;
    }
  }
}

class _ChecklistTaskTile extends ConsumerWidget {
  const _ChecklistTaskTile({
    required this.item,
    required this.locale,
    required this.completed,
  });

  final LeavingQatarChecklistItem item;
  final String locale;
  final bool completed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowIntensity: completed ? 0.1 : 0.04,
      glowColor: completed ? AppColors.emeraldGlow : AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: completed,
                onChanged: uid == null
                    ? null
                    : (value) async {
                        await ref
                            .read(leavingQatarChecklistServiceProvider)
                            .setCompleted(uid, item.id, value ?? false);
                        ref.invalidate(leavingQatarChecklistCompletionProvider);
                      },
                activeColor: AppColors.emeraldGlow,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LeavingQatarStrings.t(item.titleKey, locale),
                      style: AppTypography.subtitle.copyWith(
                        fontSize: 14,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                        color: completed
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      LeavingQatarStrings.t(item.bodyKey, locale),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (uid == null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                LeavingQatarStrings.t('lq_checklist_sign_in', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrossLinkCard extends StatelessWidget {
  const _CrossLinkCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: color,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.subtitle.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(actionLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExitPermitCard extends StatelessWidget {
  const _ExitPermitCard({
    required this.category,
    required this.locale,
  });

  final LeavingQatarWorkerCategory category;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final guidanceKey = LeavingQatarCatalog.guidanceKeyFor(category);
    final showApplyButton =
        category == LeavingQatarWorkerCategory.essentialDesignated;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.warning,
      glowIntensity: 0.14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LeavingQatarStrings.t('lq_exit_permit_heading', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            LeavingQatarStrings.t('lq_exit_permit_not_ban', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.t(guidanceKey, locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          if (showApplyButton) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => openLeavingQatarOfficialLink(
                  LeavingQatarOfficialLinks.exitPermitApplicationUrl,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(
                  LeavingQatarStrings.t('lq_exit_permit_apply', locale),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(
                    color: AppColors.warning.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TravelBanCard extends StatelessWidget {
  const _TravelBanCard({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flight_takeoff, color: AppColors.cyanGlow, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LeavingQatarStrings.t('lq_travel_ban_heading', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.cyanGlow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.t('lq_travel_ban_body', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => openLeavingQatarOfficialLink(
                LeavingQatarOfficialLinks.travelBanInquiryUrl,
              ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(
                LeavingQatarStrings.t('lq_travel_ban_cta', locale),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cyanGlow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.t('lq_travel_ban_fallback', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _KahramaaCard extends StatelessWidget {
  const _KahramaaCard({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.textSecondary,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.power_outlined, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LeavingQatarStrings.t('lq_kahramaa_heading', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.t('lq_kahramaa_body', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LeavingQatarStrings.t('lq_kahramaa_note', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
