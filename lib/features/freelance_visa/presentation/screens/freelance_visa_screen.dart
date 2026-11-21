import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/core/widgets/raabta_platform_notices_panel.dart';
import 'package:raabta/core/widgets/truth_engine_source_line.dart';
import 'package:raabta/config/truth_engine_source_metadata.dart';
import 'package:raabta/features/freelance_visa/presentation/l10n/freelance_visa_strings.dart';
import 'package:raabta/features/freelance_visa/presentation/widgets/freelance_visa_lead_callout.dart';
import 'package:raabta/features/freelance_visa/presentation/widgets/jusour_official_channel_card.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Static explainer correcting "Qatar Freelance Visa" misinformation — signpost only.
class FreelanceVisaScreen extends ConsumerWidget {
  const FreelanceVisaScreen({super.key});

  static const route = '/freelance-visa-qatar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return HubSubscreenScaffold(
      title: FreelanceVisaStrings.t('fv_screen_title', locale),
      subtitle: FreelanceVisaStrings.t('fv_screen_subtitle', locale),
      onBack: () => context.pop(),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TruthEngineSourceLine(
                    locale: locale,
                    sourceLabel: TruthEngineSourceMetadata.visaGuidesSource,
                    lastVerifiedOn:
                        TruthEngineSourceMetadata.visaGuidesLastVerified,
                    officialUrl:
                        TruthEngineSourceMetadata.visaGuidesOfficialUrl,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RaabtaPlatformNoticesPanel(locale: locale, dense: true),
                  const SizedBox(height: AppSpacing.md),
                  FreelanceVisaLeadCallout(locale: locale),
                  const SizedBox(height: AppSpacing.md),
                  _Section(
                    titleKey: 'fv_misinfo_title',
                    locale: locale,
                    child: Text(
                      FreelanceVisaStrings.t('fv_misinfo_body', locale),
                      style: AppTypography.bodySmall.copyWith(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _Section(
                    titleKey: 'fv_pathways_title',
                    locale: locale,
                    child: Text(
                      FreelanceVisaStrings.t('fv_pathways_body', locale),
                      style: AppTypography.bodySmall.copyWith(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  JusourOfficialChannelCard(locale: locale),
                  const SizedBox(height: AppSpacing.lg),
                  _RiskSection(locale: locale),
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: AppSpacing.radiusLg,
                    glowIntensity: 0.06,
                    child: Text(
                      FreelanceVisaStrings.t('fv_close_body', locale),
                      style: AppTypography.bodySmall.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: HubFeedFooterNotice(locale: locale),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.titleKey,
    required this.locale,
    required this.child,
  });

  final String titleKey;
  final String locale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FreelanceVisaStrings.t(titleKey, locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _RiskSection extends StatelessWidget {
  const _RiskSection({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.warning,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 20,
                color: AppColors.warning.withValues(alpha: 0.85),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  FreelanceVisaStrings.t('fv_risk_title', locale),
                  style: AppTypography.subtitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            FreelanceVisaStrings.t('fv_risk_body', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
