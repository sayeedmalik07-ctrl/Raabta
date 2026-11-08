import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/scam_shield/data/scam_authority_directory_config.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/operator_reporting_section.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_spam_report_hint.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class ScamShieldDirectoryScreen extends ConsumerWidget {
  const ScamShieldDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    final grouped = <ScamAuthorityCategory, List<ScamAuthorityEntry>>{};
    for (final entry in ScamAuthorityDirectoryConfig.entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_directory_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_directory_subtitle', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t('ss_directory_disclaimer', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamSpamReportHint(locale: locale),
            const SizedBox(height: AppSpacing.lg),
            OperatorReportingSection(
              locale: locale,
              headingKey: 'ss_directory_operator_report',
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final category in ScamAuthorityCategory.values)
              if (grouped[category]?.isNotEmpty ?? false) ...[
                HomeSectionHeader(
                  title: ScamShieldStrings.t(category.labelKey, locale),
                  leadingIcon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...grouped[category]!.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: AppSpacing.radiusMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ScamShieldStrings.t(entry.nameKey, locale),
                            style: AppTypography.subtitle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TrustLabel(
                            type: TrustLabelType.official,
                            locale: locale,
                            sourceName: ScamShieldStrings.t(entry.nameKey, locale),
                            sourceUrl: entry.verifyUrl,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            entry.officialDomains.join(', '),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: () => _openUrl(entry.verifyUrl),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(
                              ScamShieldStrings.t(
                                'ss_directory_verify_cta',
                                locale,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
