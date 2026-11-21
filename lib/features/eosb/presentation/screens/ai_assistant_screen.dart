import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_loading_skeleton.dart';
import 'package:raabta/features/eosb/services/eosb_ai_service.dart';
import 'package:raabta/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';

class EosbAiAssistantScreen extends ConsumerStatefulWidget {
  const EosbAiAssistantScreen({super.key});

  @override
  ConsumerState<EosbAiAssistantScreen> createState() =>
      _EosbAiAssistantScreenState();
}

class _EosbAiAssistantScreenState extends ConsumerState<EosbAiAssistantScreen> {
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _openFollowUpInRaabtaAi(String locale, String contextBody) {
    final q = _questionController.text.trim();
    final prompt = q.isEmpty
        ? 'I just read my EOSB explanation. Can you help me understand if my employer offer is fair?'
        : 'Follow-up about my EOSB: $q';
    context.push(
      '/ai-chat',
      extra: {
        'query': prompt,
        'contextSubtitle': AiChatStrings.t('eosb_explanation_title', locale),
        'contextSource': 'eosb',
        'contextBody': contextBody,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final appLocale = ref.watch(userLanguageProvider);
    final structured = ref.watch(eosbStructuredExplanationProvider);
    final result = ref.watch(eosbProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: EosbResultSkeleton(),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        if (structured == null || result == null) {
          return GlassScreenScaffold(
            title: AiChatStrings.t('eosb_explanation_title', appLocale),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            body: Center(
              child: Text(
                EosbStrings.t('eosb_empty_result_desc', locale),
                style: AppTypography.body,
              ),
            ),
          );
        }

        final promptKeys = [
          'eosb_ai_prompt_fair',
          'eosb_ai_prompt_rights',
          'eosb_ai_prompt_dispute',
          'eosb_ai_prompt_breakdown',
        ];

        return GlassScreenScaffold(
          title: AiChatStrings.t('eosb_explanation_title', appLocale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EosbDisclaimerBanner(locale: locale),
              LegalFreshnessIndicator(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              Text(
                EosbStrings.t('eosb_ai_disclaimer', locale),
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  children: [
                    _SectionTitle(
                      EosbStrings.t('eosb_ai_summary', locale),
                      Icons.summarize_outlined,
                      AppColors.cyanGlow,
                    ),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      glowColor: AppColors.cyanGlow,
                      glowIntensity: 0.12,
                      child: Text(structured.summary, style: AppTypography.body),
                    ),
                    if (structured.risks.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _SectionTitle(
                        EosbStrings.t('eosb_ai_key_risks', locale),
                        Icons.warning_amber_rounded,
                        AppColors.accentGold,
                      ),
                      ...structured.risks.map(
                        (risk) => GlassCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          glowColor: risk.isCritical
                              ? AppColors.errorBright
                              : AppColors.accentGold,
                          glowIntensity: 0.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(risk.title, style: AppTypography.title),
                              const SizedBox(height: AppSpacing.xs),
                              Text(risk.body, style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (structured.nextSteps.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _SectionTitle(
                        EosbStrings.t('eosb_next_steps', locale),
                        Icons.checklist_rounded,
                        AppColors.emeraldGlow,
                      ),
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        glowColor: AppColors.emeraldGlow,
                        glowIntensity: 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: structured.nextSteps
                              .map(
                                (step) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: AppTypography.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      EosbStrings.t('eosb_ai_suggested_prompts', locale),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: promptKeys.map((key) {
                        return ActionChip(
                          label: Text(
                            EosbStrings.t(key, locale),
                            style: AppTypography.caption,
                          ),
                          onPressed: () {
                            _questionController.text = EosbStrings.t(key, locale);
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: AiChatStrings.t('eosb_follow_up_hint', appLocale),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => _openFollowUpInRaabtaAi(
                  appLocale,
                  structured.summary,
                ),
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  AiChatStrings.t('eosb_follow_up_cta', appLocale),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.title),
        ],
      ),
    );
  }
}
