import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/data/scam_authority_directory_config.dart';
import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_external_link_launcher.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';
import 'package:raabta/features/scam_shield/providers/scam_advisory_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldAdvisoryDetailScreen extends ConsumerWidget {
  const ScamShieldAdvisoryDetailScreen({super.key, required this.advisoryId});

  final String advisoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final advisoriesAsync = ref.watch(scamActiveAdvisoriesProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_advisories_detail_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: advisoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text(
            ScamShieldStrings.t('ss_advisories_empty', locale),
            style: AppTypography.bodySmall,
          ),
          data: (list) {
            ScamAdvisory? advisory;
            for (final a in list) {
              if (a.id == advisoryId) {
                advisory = a;
                break;
              }
            }
            if (advisory == null) {
              return Text(
                ScamShieldStrings.t('ss_advisories_empty', locale),
                style: AppTypography.bodySmall,
              );
            }
            ref
                .read(scamAdvisoryRepositoryProvider)
                .markSeen(advisory.id);
            return _DetailBody(advisory: advisory, locale: locale);
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.advisory, required this.locale});

  final ScamAdvisory advisory;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final accent = advisory.severity == ScamAdvisorySeverity.elevated
        ? scamShieldRiskColor(ScamShieldRiskLevel.high)
        : scamShieldRiskColor(ScamShieldRiskLevel.low);

    return ListView(
      children: [
        Text(
          advisory.title,
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            advisory.severity == ScamAdvisorySeverity.elevated
                ? ScamShieldStrings.t('ss_advisories_severity_elevated', locale)
                : ScamShieldStrings.t('ss_advisories_severity_info', locale),
            style: AppTypography.caption.copyWith(color: accent),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(advisory.summary, style: AppTypography.body),
        if (advisory.samplePattern.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_advisories_sample_pattern', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            advisory.samplePattern,
            style: AppTypography.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (advisory.redFlags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            ScamShieldStrings.t('ss_red_flags', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...advisory.redFlags.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('• $f', style: AppTypography.bodySmall),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          ScamShieldStrings.t('ss_advisories_what_to_do', locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          advisory.whatToDoForLocale(locale),
          style: AppTypography.bodySmall,
        ),
        if (advisory.authorityRefs.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_advisories_official_channels', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: advisory.authorityRefs.map((id) {
              final entry = ScamAuthorityDirectoryConfig.findById(id);
              if (entry == null) return const SizedBox.shrink();
              return OutlinedButton(
                onPressed: () =>
                    ScamExternalLinkLauncher.openUrl(entry.verifyUrl),
                child: Text(ScamShieldStrings.t(entry.nameKey, locale)),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: advisory.sourceUrl.isEmpty
              ? null
              : () => ScamExternalLinkLauncher.openUrl(advisory.sourceUrl),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: Text(
            ScamShieldStrings.t('ss_advisories_view_source', locale)
                .replaceAll('{source}', advisory.sourceName),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GlassPrimaryButton(
          label: ScamShieldStrings.t('ss_advisories_check_message_cta', locale),
          expand: true,
          accentColor: scamShieldAccent,
          icon: Icons.radar,
          onPressed: () => context.go('/scam-shield'),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          ScamShieldStrings.t('ss_advisories_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
