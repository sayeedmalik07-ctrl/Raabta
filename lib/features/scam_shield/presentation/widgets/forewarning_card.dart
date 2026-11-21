import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/screens/agency_verification_screen.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Inline, dismissible safety tip — never blocks underlying actions.
class ForewarningCard extends StatelessWidget {
  const ForewarningCard({
    super.key,
    required this.content,
    required this.locale,
    required this.onDismiss,
  });

  final ForewarningResolvedContent content;
  final String locale;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: content.body,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: AppColors.info,
          glowIntensity: 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_outlined,
                      size: 20, color: AppColors.info),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content.body, style: AppTypography.bodySmall),
                        if (content.advisoryLine != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            content.advisoryLine!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xs),
                        _SourceChip(label: content.sourceLabel),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                alignment: WrapAlignment.end,
                children: [
                  if (content.ctaTarget != ForewarningCtaTarget.none)
                    TextButton(
                      onPressed: () => _openCta(context, content.ctaTarget),
                      child: Text(_ctaLabel(content.ctaTarget, locale)),
                    ),
                  TextButton(
                    onPressed: onDismiss,
                    child: Text(
                      ScamShieldStrings.t('ss_forewarning_got_it', locale),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _ctaLabel(ForewarningCtaTarget target, String locale) {
    return switch (target) {
      ForewarningCtaTarget.paymentCheck =>
        ScamShieldStrings.t('ss_forewarning_cta_payment', locale),
      ForewarningCtaTarget.officialDirectory =>
        ScamShieldStrings.t('ss_forewarning_cta_directory', locale),
      ForewarningCtaTarget.agencyVerification =>
        ScamShieldStrings.t('ss_forewarning_cta_agency', locale),
      ForewarningCtaTarget.none => '',
    };
  }

  static void _openCta(BuildContext context, ForewarningCtaTarget target) {
    switch (target) {
      case ForewarningCtaTarget.paymentCheck:
        context.push('/scam-shield/payment-check');
      case ForewarningCtaTarget.officialDirectory:
        context.push('/scam-shield/official-directory');
      case ForewarningCtaTarget.agencyVerification:
        context.push(
          AgencyVerificationScreen.route(
            section: AgencyVerificationScreen.qatarRecruitmentSection,
          ),
        );
      case ForewarningCtaTarget.none:
        break;
    }
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.glassBorder.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: AppTypography.caption),
    );
  }
}
