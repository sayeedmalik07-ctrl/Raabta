import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/consumer_protection/presentation/l10n/consumer_protection_strings.dart';
import 'package:raabta/features/consumer_protection/presentation/widgets/moci_consumer_complaint_card.dart';
import 'package:raabta/features/telecom_decoder/data/models/telecom_decoder_models.dart';
import 'package:raabta/features/telecom_decoder/presentation/l10n/telecom_decoder_strings.dart';
import 'package:raabta/features/telecom_decoder/presentation/widgets/telecom_trap_callout.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Static telecom contract decoder — Ooredoo/Vodafone traps and CRA escalation.
class TelecomDecoderScreen extends ConsumerWidget {
  const TelecomDecoderScreen({super.key});

  static const route = '/telecom-contract-decoder';

  static const _craCriteriaKeys = [
    'td_cra_eligible_1',
    'td_cra_eligible_2',
    'td_cra_eligible_3',
    'td_cra_eligible_4',
    'td_cra_eligible_5',
    'td_cra_eligible_6',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: TelecomDecoderStrings.t('td_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.cyanGlow,
            glowIntensity: 0.12,
            child: Text(
              TelecomDecoderStrings.t('td_screen_intro', locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DisclaimerBanner(locale: locale),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    TelecomDecoderStrings.t('td_scope_note', locale),
                    style: AppTypography.bodySmall.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            TelecomDecoderStrings.t('td_traps_heading', locale),
            style: AppTypography.subtitle.copyWith(color: AppColors.warning),
          ),
          const SizedBox(height: AppSpacing.sm),
          TelecomTrapCallout(
            locale: locale,
            providerLabelKey: 'td_trap_ooredoo_provider',
            titleKey: 'td_trap_ooredoo_title',
            bodyKey: 'td_trap_ooredoo_body',
          ),
          TelecomTrapCallout(
            locale: locale,
            providerLabelKey: 'td_trap_vodafone_provider',
            titleKey: 'td_trap_vodafone_title',
            bodyKey: 'td_trap_vodafone_body',
          ),
          const SizedBox(height: AppSpacing.md),
          _ContentSection(
            titleKey: 'td_section_min_period_title',
            locale: locale,
            children: [
              _Subsection(
                titleKey: 'td_ooredoo_min_title',
                bodyKey: 'td_ooredoo_min_body',
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.md),
              _Subsection(
                titleKey: 'td_vodafone_min_title',
                bodyKey: 'td_vodafone_min_body',
                locale: locale,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContentSection(
            titleKey: 'td_section_other_facts_title',
            locale: locale,
            children: [
              _BulletLine(
                text: TelecomDecoderStrings.t('td_other_quarantine', locale),
              ),
              _BulletLine(
                text: TelecomDecoderStrings.t('td_other_rp_trigger', locale),
              ),
              _BulletLine(
                text: TelecomDecoderStrings.t('td_other_gigatv', locale),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ConsumerProtectionStrings.t('cp_telecom_context_note', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MociConsumerComplaintCard(
            locale: locale,
            showRegulatorContrast: false,
            showStandaloneLink: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ContentSection(
            titleKey: 'td_section_cra_title',
            locale: locale,
            children: [
              Text(
                TelecomDecoderStrings.t('td_cra_intro', locale),
                style: AppTypography.bodySmall.copyWith(height: 1.45),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                TelecomDecoderStrings.t('td_cra_eligible_heading', locale),
                style: AppTypography.subtitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...List.generate(_craCriteriaKeys.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}.',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.cyanGlow,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          TelecomDecoderStrings.t(_craCriteriaKeys[index], locale),
                          style: AppTypography.bodySmall.copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
              Text(
                TelecomDecoderStrings.t('td_cra_channels', locale),
                style: AppTypography.bodySmall.copyWith(height: 1.45),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openOfficialLink(
                    TelecomDecoderOfficialLinks.craWebsite,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(
                    TelecomDecoderStrings.t('td_cra_open_form', locale),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyanGlow,
                    side: BorderSide(
                      color: AppColors.cyanGlow.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _openOfficialLink(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              TelecomDecoderStrings.t('td_disclaimer', locale),
              style: AppTypography.caption.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.titleKey,
    required this.locale,
    required this.children,
  });

  final String titleKey;
  final String locale;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TelecomDecoderStrings.t(titleKey, locale),
            style: AppTypography.subtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _Subsection extends StatelessWidget {
  const _Subsection({
    required this.titleKey,
    required this.bodyKey,
    required this.locale,
  });

  final String titleKey;
  final String bodyKey;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TelecomDecoderStrings.t(titleKey, locale),
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          TelecomDecoderStrings.t(bodyKey, locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•', style: AppTypography.bodySmall),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
