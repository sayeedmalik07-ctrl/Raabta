import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/ai_suggestion_card.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_settings_tile.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/core/widgets/raabta_platform_notices_panel.dart';
import 'package:raabta/core/widgets/truth_engine_source_line.dart';
import 'package:raabta/config/truth_engine_source_metadata.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/ai_chat/ai_chat_context_builder.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';
import 'package:raabta/screens/visahelp/l10n/visa_strings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VisaGuideScreen extends ConsumerStatefulWidget {
  const VisaGuideScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  ConsumerState<VisaGuideScreen> createState() => _VisaGuideScreenState();
}

class _VisaGuideScreenState extends ConsumerState<VisaGuideScreen> {
  int? _expandedStep;

  String _guideHeaderSubtitle(String locale) {
    for (final c in visaCategories) {
      if (c.id == widget.categoryId) {
        final steps = VisaStrings.format(
          'visa_steps_count',
          locale,
          params: {'count': '${c.steps}'},
        );
        return VisaStrings.format(
          'visa_guide_meta',
          locale,
          params: {'steps': steps, 'eta': c.estimatedTime},
        );
      }
    }
    return VisaStrings.t('visa_hub_subtitle', locale);
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _askAiAboutStep(VisaGuide guide, VisaGuideStep step) {
    final language = ref.read(userLanguageProvider);
    final message =
        'I am following the "${guide.title}" guide in Raabta. '
        'Please explain Step ${step.stepNumber}: "${step.title}" in simple language. '
        'Documents needed: ${step.documents.join(", ")}. '
        'Respond in $language.';
    final ctx = AiChatContextBuilder.fromVisaGuide(
      guideTitle: guide.title,
      stepTitle: step.title,
      stepNumber: step.stepNumber,
      documents: step.documents,
    );

    context.push(
      '/ai-chat',
      extra: {
        'query': message,
        'contextSubtitle': AiChatStrings.t('ai_context_visa', language),
        'contextSource': ctx.source.routeValue,
        'contextBody': ctx.body,
      },
    );
  }

  Future<void> _shareGuide(VisaGuide guide) async {
    final buffer = StringBuffer('${guide.title}\n${guide.summary}\n\n');
    for (final step in guide.steps) {
      buffer.writeln('Step ${step.stepNumber}: ${step.title}');
      buffer.writeln(step.description);
      buffer.writeln('');
    }
    buffer.writeln('Official links:');
    for (final link in guide.officialLinks) {
      buffer.writeln('${link.name}: ${link.url}');
    }
    await Share.share(buffer.toString());
  }

  Widget _stepLeadingChip(int stepNumber) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.goldFamilyMain.withValues(alpha: 0.18),
      ),
      child: Text(
        '$stepNumber',
        style: AppTypography.subtitle.copyWith(
          color: AppColors.goldFamilyMain,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(visaGuideProvider(widget.categoryId));
    final languageLabel = ref.watch(userLanguageProvider);

    return guideAsync.when(
      loading: () {
        final w = MediaQuery.sizeOf(context).width;
        return HubSubscreenScaffold(
          title: VisaStrings.categoryTitle(widget.categoryId, languageLabel),
          subtitle: _guideHeaderSubtitle(languageLabel),
          onBack: () => Navigator.of(context).pop(),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: HubLoadingPlaceholder(
                width: (w - AppSpacing.xl * 2).clamp(200.0, 560.0),
                height: 320,
                silhouette: HubLoadingSilhouette.formTool,
              ),
            ),
          ),
        );
      },
      error: (error, _) => HubSubscreenScaffold(
        title: VisaStrings.categoryTitle(widget.categoryId, languageLabel),
        subtitle: _guideHeaderSubtitle(languageLabel),
        onBack: () => Navigator.of(context).pop(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: GlassErrorState(
              message: VisaStrings.t('visa_load_guide_error', languageLabel),
              retryLabel: CommonActionStrings.t('action_retry', languageLabel),
              onRetry: () =>
                  ref.invalidate(visaGuideProvider(widget.categoryId)),
            ),
          ),
        ),
      ),
      data: (guide) {
        return HubSubscreenScaffold(
          title: guide.title,
          subtitle: _guideHeaderSubtitle(languageLabel),
          onBack: () => Navigator.of(context).pop(),
          headerTrailing: IconButton(
            icon: const Icon(Icons.share_outlined),
            color: AppColors.textPrimary,
            tooltip: CommonActionStrings.t('action_share', languageLabel),
            onPressed: () => _shareGuide(guide),
          ),
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
                        locale: languageLabel,
                        sourceLabel:
                            TruthEngineSourceMetadata.visaGuidesSource,
                        lastVerifiedOn:
                            TruthEngineSourceMetadata.visaGuidesLastVerified,
                        officialUrl:
                            TruthEngineSourceMetadata.visaGuidesOfficialUrl,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RaabtaPlatformNoticesPanel(
                        locale: languageLabel,
                        dense: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        guide.summary,
                        style: AppTypography.body.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.categoryId == 'sponsor_transfer')
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AISuggestionCard(
                      title: KnowQatarStrings.t(
                        'kq_action_sponsorship_transfer',
                        languageLabel,
                      ),
                      description: KnowQatarStrings.t(
                        'kq_action_card_hint',
                        languageLabel,
                      ),
                      icon: Icons.swap_horiz,
                      accentColor: AppColors.brandFamilyMain,
                      actionLabel: KnowQatarStrings.t(
                        'kq_action_open',
                        languageLabel,
                      ),
                      onTap: () => context.push('/sponsorship-transfer'),
                    ),
                  ),
                ),
              if (widget.categoryId == 'exit_permit')
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AISuggestionCard(
                      title: LeavingQatarStrings.t(
                        'lq_screen_title',
                        languageLabel,
                      ),
                      description: KnowQatarStrings.t(
                        'kq_action_card_hint',
                        languageLabel,
                      ),
                      icon: Icons.flight_takeoff,
                      accentColor: AppColors.brandFamilyMain,
                      actionLabel: KnowQatarStrings.t(
                        'kq_action_open',
                        languageLabel,
                      ),
                      onTap: () => context.push('/leaving-qatar'),
                    ),
                  ),
                ),
              if (guide.officialLinks.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeSectionHeader(
                          title: VisaStrings.t(
                            'visa_guide_official_links',
                            languageLabel,
                          ),
                          leadingIcon: Icons.link,
                          compact: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: guide.officialLinks.map((link) {
                            return GlassCard(
                              onTap: () => _openLink(link.url),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              borderRadius: AppSpacing.radiusFull,
                              glowColor: AppColors.brandFamilyMain,
                              glowIntensity: 0.1,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.open_in_new,
                                    size: AppSpacing.iconSm,
                                    color: AppColors.brandFamilyMain,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    link.name,
                                    style: AppTypography.link.copyWith(
                                      color: AppColors.brandFamilyMain,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final step = guide.steps[index];
                      final isExpanded = _expandedStep == step.stepNumber;
                      final metaLine = VisaStrings.format(
                        'visa_guide_step_meta',
                        languageLabel,
                        params: {
                          'time': step.time,
                          'cost': step.cost,
                        },
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: GlassCard(
                          glowColor: AppColors.goldFamilyMain,
                          glowIntensity: isExpanded ? 0.14 : 0.06,
                          padding: EdgeInsets.zero,
                          borderRadius: AppSpacing.radiusLg,
                          backgroundColor:
                              AppColors.goldFamilyMain.withValues(alpha: 0.04),
                          child: Column(
                            children: [
                              GlassSettingsTile(
                                title: step.title,
                                subtitle: metaLine,
                                onTap: () {
                                  setState(() {
                                    _expandedStep = isExpanded
                                        ? null
                                        : step.stepNumber;
                                  });
                                },
                                leading: _stepLeadingChip(step.stepNumber),
                                trailing: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.md,
                                    0,
                                    AppSpacing.md,
                                    AppSpacing.md,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.description,
                                        style: AppTypography.body.copyWith(
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        VisaStrings.t(
                                          'visa_documents_needed',
                                          languageLabel,
                                        ),
                                        style:
                                            AppTypography.subtitle.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Wrap(
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.sm,
                                        children: step.documents
                                            .map(
                                              (doc) => StatusBadge(
                                                label: doc,
                                                color:
                                                    AppColors.goldFamilyMain,
                                                icon: Icons.description_outlined,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      GlassPrimaryButton(
                                        label: VisaStrings.t(
                                          'visa_ask_ai_about_step',
                                          languageLabel,
                                        ),
                                        icon: Icons.smart_toy_outlined,
                                        onPressed: () =>
                                            _askAiAboutStep(guide, step),
                                        accentColor: AppColors.brandFamilyMain,
                                        expand: true,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: guide.steps.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: HubFeedFooterNotice(locale: languageLabel),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),
        );
      },
    );
  }
}
