import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/platform/scam_proactive_protection_platform.dart';

class ScamProactiveProtectionSection extends ConsumerWidget {
  const ScamProactiveProtectionSection({
    super.key,
    required this.locale,
    required this.status,
  });

  final String locale;
  final ScamProactiveProtectionStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          overline: ScamShieldStrings.t('ss_tools_overline', locale),
          title: ScamShieldStrings.t('ss_proactive_heading', locale),
          subtitle: ScamShieldStrings.t('ss_proactive_subtitle', locale),
          leadingIcon: Icons.security_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        if (Platform.isAndroid && status.supportsCallScreening)
          _StatusTile(
            label: ScamShieldStrings.t('ss_proactive_call_screening', locale),
            active: status.callScreeningActive,
            activeLabel: ScamShieldStrings.t('ss_proactive_active', locale),
            inactiveLabel:
                ScamShieldStrings.t('ss_proactive_not_enabled', locale),
            actionLabel: ScamShieldStrings.t('ss_proactive_enable', locale),
            onAction: () => context.push('/scam-shield/call-screening'),
          ),
        if (Platform.isIOS && status.supportsSmsFilterGuide) ...[
          _StatusTile(
            label: ScamShieldStrings.t('ss_proactive_sms_filter', locale),
            active: status.smsFilterUserConfirmed,
            activeLabel: ScamShieldStrings.t('ss_proactive_active', locale),
            inactiveLabel:
                ScamShieldStrings.t('ss_proactive_not_enabled', locale),
            actionLabel:
                ScamShieldStrings.t('ss_proactive_show_how', locale),
            onAction: () => context.push('/scam-shield/sms-filter-guide'),
          ),
          if (status.smsFilteredCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                ScamShieldStrings.format(
                  'ss_proactive_sms_filtered_count',
                  locale,
                  {'count': status.smsFilteredCount.toString()},
                ),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _StatusTile(
          label: ScamShieldStrings.t('ss_proactive_link_checking', locale),
          active: status.linkCheckingActive,
          activeLabel: ScamShieldStrings.t('ss_proactive_active', locale),
          inactiveLabel:
              ScamShieldStrings.t('ss_proactive_unavailable', locale),
          showAction: false,
        ),
        if (status.pendingFlaggedCalls.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamShieldStrings.format(
              'ss_proactive_recent_flagged_calls',
              locale,
              {'count': status.pendingFlaggedCalls.length.toString()},
            ),
            style: AppTypography.caption.copyWith(color: AppColors.chipLease),
          ),
        ],
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.active,
    required this.activeLabel,
    required this.inactiveLabel,
    this.actionLabel,
    this.onAction,
    this.showAction = true,
  });

  final String label;
  final bool active;
  final String activeLabel;
  final String inactiveLabel;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              color: active ? AppColors.chipEosb : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  Text(
                    active ? activeLabel : inactiveLabel,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (showAction && !active && actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
