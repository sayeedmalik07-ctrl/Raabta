import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/disruption_readiness/data/disruption_understand_alert_config.dart';
import 'package:raabta/features/disruption_readiness/presentation/l10n/disruption_readiness_strings.dart';
import 'package:raabta/features/disruption_readiness/services/disruption_readiness_analytics.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class DisruptionUnderstandAlertScreen extends ConsumerStatefulWidget {
  const DisruptionUnderstandAlertScreen({super.key});

  static const route = '/disruption-readiness/understand-alert';

  @override
  ConsumerState<DisruptionUnderstandAlertScreen> createState() =>
      _DisruptionUnderstandAlertScreenState();
}

class _DisruptionUnderstandAlertScreenState
    extends ConsumerState<DisruptionUnderstandAlertScreen> {
  @override
  void initState() {
    super.initState();
    DisruptionReadinessAnalytics.understandAlertOpened();
  }

  Future<void> _openMoiPortal() async {
    final uri = Uri.parse(DisruptionUnderstandAlertConfig.moiEarlyWarningUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: DisruptionReadinessStrings.t('dr_understand_alert_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            DisruptionReadinessStrings.t('dr_understand_alert_intro', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeading(
            DisruptionReadinessStrings.t(
              'dr_understand_alert_section_what',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              DisruptionReadinessStrings.t(
                'dr_understand_alert_ews_explanation',
                locale,
              ),
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeading(
            DisruptionReadinessStrings.t(
              'dr_understand_alert_section_example',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: DisruptionReadinessStrings.t(
              'dr_understand_alert_example_label',
              locale,
            ),
            child: GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: AppColors.textSecondary,
              glowIntensity: 0.06,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DisruptionReadinessStrings.t(
                      'dr_understand_alert_example_label',
                      locale,
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      DisruptionReadinessStrings.t(
                        'dr_understand_alert_example_caption',
                        locale,
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeading(
            DisruptionReadinessStrings.t(
              'dr_understand_alert_section_if_you_get_one',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              DisruptionReadinessStrings.t('dr_block_ews_channel_body', locale),
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.info,
            glowIntensity: 0.08,
            child: Text(
              DisruptionReadinessStrings.t(
                'dr_understand_alert_qna_follow',
                locale,
              ),
              style: AppTypography.bodySmall.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeading(
            DisruptionReadinessStrings.t(
              'dr_understand_alert_section_glossary',
              locale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DisruptionReadinessStrings.t(
                    'dr_understand_alert_glossary_all_clear_heading',
                    locale,
                  ),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  DisruptionReadinessStrings.t(
                    'dr_understand_alert_glossary_ar_label',
                    locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DisruptionUnderstandAlertConfig.allClearArabicMaster,
                  style: AppTypography.bodySmall.copyWith(height: 1.5),
                  textDirection: ui.TextDirection.rtl,
                ),
                Text(
                  DisruptionReadinessStrings.format(
                    'dr_understand_alert_glossary_ar_source',
                    locale,
                    {'date': DisruptionUnderstandAlertConfig.qnaAllClearArabicDate},
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  DisruptionReadinessStrings.t(
                    'dr_understand_alert_glossary_en_label',
                    locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DisruptionUnderstandAlertConfig.allClearEnglishReporting,
                  style: AppTypography.bodySmall.copyWith(height: 1.5),
                ),
                Text(
                  DisruptionReadinessStrings.format(
                    'dr_understand_alert_glossary_en_source',
                    locale,
                    {
                      'date':
                          DisruptionUnderstandAlertConfig.gulfTimesAllClearEnglishDate,
                    },
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SourceFooter(
            locale: locale,
            onOpenPortal: _openMoiPortal,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            DisruptionReadinessStrings.t('dr_needs_internet', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.title);
  }
}

class _SourceFooter extends StatelessWidget {
  const _SourceFooter({
    required this.locale,
    required this.onOpenPortal,
  });

  final String locale;
  final VoidCallback onOpenPortal;

  @override
  Widget build(BuildContext context) {
    final verified = DateFormat.yMMMd().format(
      DateTime.parse(DisruptionUnderstandAlertConfig.lastVerifiedIso),
    );
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DisruptionReadinessStrings.t(
              'dr_understand_alert_sources_title',
              locale,
            ),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            DisruptionReadinessStrings.format(
              'dr_understand_alert_sources_body',
              locale,
              {
                'date': DisruptionUnderstandAlertConfig.qnaEwsReportingDate,
                'verified': verified,
              },
            ),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onOpenPortal,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(
              DisruptionReadinessStrings.t('dr_link_moi_ews', locale),
            ),
          ),
        ],
      ),
    );
  }
}
