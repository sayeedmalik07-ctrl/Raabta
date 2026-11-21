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
import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';
import 'package:raabta/features/scam_shield/providers/scam_advisory_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:shimmer/shimmer.dart';

class ScamShieldAdvisoriesScreen extends ConsumerWidget {
  const ScamShieldAdvisoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final advisoriesAsync = ref.watch(scamActiveAdvisoriesProvider);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_advisories_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: advisoriesAsync.when(
          loading: () => _AdvisoriesSkeleton(),
          error: (_, __) => _AdvisoriesBody(
            locale: locale,
            advisories: const [],
            loadFailed: true,
          ),
          data: (list) => _AdvisoriesBody(
            locale: locale,
            advisories: list,
          ),
        ),
      ),
    );
  }
}

class _AdvisoriesBody extends StatelessWidget {
  const _AdvisoriesBody({
    required this.locale,
    required this.advisories,
    this.loadFailed = false,
  });

  final String locale;
  final List<ScamAdvisory> advisories;
  final bool loadFailed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          ScamShieldStrings.t('ss_advisories_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (loadFailed) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamShieldStrings.t('ss_advisories_offline_hint', locale),
            style: AppTypography.caption.copyWith(color: AppColors.warning),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (advisories.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              ScamShieldStrings.t('ss_advisories_empty', locale),
              style: AppTypography.bodySmall,
            ),
          )
        else
          ...advisories.map(
            (a) => _AdvisoryListTile(
              advisory: a,
              locale: locale,
              onTap: () => context.push('/scam-shield/advisories/${a.id}'),
            ),
          ),
      ],
    );
  }
}

class _AdvisoryListTile extends StatelessWidget {
  const _AdvisoryListTile({
    required this.advisory,
    required this.locale,
    required this.onTap,
  });

  final ScamAdvisory advisory;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = advisory.severity == ScamAdvisorySeverity.elevated
        ? scamShieldRiskColor(ScamShieldRiskLevel.high)
        : scamShieldRiskColor(ScamShieldRiskLevel.low);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advisory.title,
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    advisory.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ScamShieldStrings.t('ss_advisories_source_line', locale)
                        .replaceAll('{source}', advisory.sourceName)
                        .replaceAll(
                          '{date}',
                          advisory.sourceDate
                                  ?.toIso8601String()
                                  .split('T')
                                  .first ??
                              '',
                        ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _AdvisoriesSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.glassBorder.withValues(alpha: 0.3),
      highlightColor: AppColors.glassBorder.withValues(alpha: 0.6),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
