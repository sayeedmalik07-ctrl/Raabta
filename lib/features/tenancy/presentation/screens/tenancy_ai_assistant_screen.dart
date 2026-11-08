import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';

class TenancyAiAssistantScreen extends ConsumerStatefulWidget {
  const TenancyAiAssistantScreen({super.key});

  @override
  ConsumerState<TenancyAiAssistantScreen> createState() =>
      _TenancyAiAssistantScreenState();
}

class _TenancyAiAssistantScreenState
    extends ConsumerState<TenancyAiAssistantScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask(String question) async {
    await ref.read(tenancyAiChatProvider.notifier).ask(question);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final chat = ref.watch(tenancyAiChatProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final prompts = [
          'tenancy_ai_prompt_registration',
          'tenancy_ai_prompt_deposit',
          'tenancy_ai_prompt_committee',
        ];

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_ai_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              ...() {
                final input = ref.watch(tenancyProvider).input;
                final registrationUnknown =
                    input.registrationStatus == null ||
                        input.registrationStatus?.name == 'notSure';
                return [
                  TruthConfidenceBanner(
                    locale: locale,
                    state: registrationUnknown
                        ? TruthConfidenceState.action
                        : TruthConfidenceState.known,
                    text: TruthPackageCatalog.tenancyAssumptionDisplay(
                      0,
                      locale,
                      registrationUnknown: registrationUnknown,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.unknown,
                    text: TruthPackageCatalog.tenancyUnknownDisplay(0, locale),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ];
              }(),
              Text(
                TenancyStrings.t('tenancy_ai_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: prompts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final key = prompts[i];
                    return ActionChip(
                      label: Text(TenancyStrings.t(key, locale)),
                      onPressed: () => _ask(TenancyStrings.t(key, locale)),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  children: [
                    for (final msg in chat.messages)
                      Align(
                        alignment: msg.role == 'user'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          glowColor: msg.role == 'user'
                              ? AppColors.chipLease
                              : AppColors.cyanGlow,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                            ),
                            child: Text(
                              msg.text,
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    if (chat.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: TenancyStrings.t('tenancy_ai_ask_hint', locale),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: _ask,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GlassPrimaryButton(
                    label: TenancyStrings.t('tenancy_ai_send', locale),
                    accentColor: AppColors.chipLease,
                    onPressed: chat.isLoading
                        ? null
                        : () => _ask(_controller.text),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
