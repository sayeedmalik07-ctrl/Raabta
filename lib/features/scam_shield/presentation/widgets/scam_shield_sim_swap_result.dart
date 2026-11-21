import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_self_report.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_external_link_launcher.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/services/scam_sim_swap_service.dart';

class ScamShieldSimSwapResultView extends StatelessWidget {
  const ScamShieldSimSwapResultView({
    super.key,
    required this.result,
    required this.locale,
    required this.provider,
  });

  final SimSwapAssessmentResult result;
  final String locale;
  final ScamQatarTelecomProvider provider;

  @override
  Widget build(BuildContext context) {
    final analysis = result.analysis;
    final urgency = analysis.selfReportUrgency;
    final accent = _urgencyColor(urgency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ScamShieldStrings.t('ss_sim_result_your_answers', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ScamShieldStrings.t(urgency.summaryKey, locale),
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ScamShieldStrings.format(
                  'ss_sim_provider_selected',
                  locale,
                  {'provider': ScamShieldStrings.t(provider.labelKey, locale)},
                ),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        if (analysis.selfReportAnswers != null &&
            analysis.selfReportAnswers!.hasAnyAnswer) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_sim_reported_heading', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...analysis.selfReportAnswers!.answeredEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '• ${ScamShieldStrings.t(entry.key.labelKey, locale)} — ${_answerLabel(entry.value, locale)}',
                style: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
        if (analysis.textSignals.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_sim_notes_signals_heading', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...analysis.textSignals.map(
            (signal) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '• ${ScamShieldStrings.t(signal.labelKey, locale)}',
                style: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
        if (result.chainNarrative != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_ir_chain', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            result.chainNarrative!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.chipLease),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_sim_protective_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...analysis.actionKeys.map(
          (key) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ScamShieldStrings.t(key, locale),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_sim_carrier_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...analysis.telecomChannels.map(
          (channel) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _CarrierChannelButton(channel: channel, locale: locale),
          ),
        ),
        if (analysis.suggestIncidentMode) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.push('/scam-shield/incident'),
            icon: const Icon(Icons.emergency_outlined),
            label: Text(
              ScamShieldStrings.t('ss_sim_open_incident', locale),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_sim_self_report_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  static Color _urgencyColor(SimSwapSelfReportUrgency urgency) {
    return switch (urgency) {
      SimSwapSelfReportUrgency.calm => AppColors.success,
      SimSwapSelfReportUrgency.review => AppColors.warning,
      SimSwapSelfReportUrgency.promptAction => AppColors.errorBright,
    };
  }

  static String _answerLabel(SimSwapTriStateAnswer answer, String locale) {
    return ScamShieldStrings.t(
      switch (answer) {
        SimSwapTriStateAnswer.yes => 'ss_sim_answer_yes',
        SimSwapTriStateAnswer.no => 'ss_sim_answer_no',
        SimSwapTriStateAnswer.notSure => 'ss_sim_answer_not_sure',
      },
      locale,
    );
  }
}

class _CarrierChannelButton extends StatelessWidget {
  const _CarrierChannelButton({
    required this.channel,
    required this.locale,
  });

  final ScamTelecomChannel channel;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final hasPhone = channel.phoneNumber != null;
    final hasUrl = channel.url != null;

    return OutlinedButton.icon(
      onPressed: () async {
        if (hasPhone) {
          await ScamExternalLinkLauncher.dialPhone(channel.phoneNumber!);
        } else if (hasUrl) {
          await ScamExternalLinkLauncher.openUrl(channel.url!);
        }
      },
      icon: Icon(hasPhone ? Icons.phone_outlined : Icons.open_in_new, size: 16),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ScamShieldStrings.t(channel.labelKey, locale)),
            if (channel.detailKey != null)
              Text(
                ScamShieldStrings.t(channel.detailKey!, locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
