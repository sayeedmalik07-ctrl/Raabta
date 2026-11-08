import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_widgets.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';

class TransferAiAssistantScreen extends ConsumerStatefulWidget {
  const TransferAiAssistantScreen({super.key});

  @override
  ConsumerState<TransferAiAssistantScreen> createState() =>
      _TransferAiAssistantScreenState();
}

class _TransferAiAssistantScreenState
    extends ConsumerState<TransferAiAssistantScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask(String question) async {
    await ref.read(sponsorshipTransferAiChatProvider.notifier).ask(question);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(sponsorshipTransferLocaleProvider);
    final chat = ref.watch(sponsorshipTransferAiChatProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        const prompts = [
          'st_ai_prompt_noc',
          'st_ai_prompt_notice',
          'st_ai_prompt_90day',
          'st_ai_prompt_employer_refuses',
        ];

        return GlassScreenScaffold(
          title: SponsorshipTransferStrings.t('st_ai_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SponsorshipTransferDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              ...() {
                final input = ref.watch(sponsorshipTransferProvider).input;
                final noticeUnknown =
                    input.formalNoticeStatus?.name == 'notSure';
                return [
                  TruthConfidenceBanner(
                    locale: locale,
                    state: noticeUnknown
                        ? TruthConfidenceState.action
                        : TruthConfidenceState.known,
                    text: TruthPackageCatalog.sponsorshipAssumptionDisplay(
                      0,
                      locale,
                      noticeUnknown: noticeUnknown,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TruthConfidenceBanner(
                    locale: locale,
                    state: TruthConfidenceState.unknown,
                    text: TruthPackageCatalog.sponsorshipUnknownDisplay(0, locale),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ];
              }(),
              Text(
                SponsorshipTransferStrings.t('st_ai_subtitle', locale),
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
                      label: Text(SponsorshipTransferStrings.t(key, locale)),
                      onPressed: () =>
                          _ask(SponsorshipTransferStrings.t(key, locale)),
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
                              ? AppColors.chipSponsorshipTransfer
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
                        hintText:
                            SponsorshipTransferStrings.t('st_ai_ask_hint', locale),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: _ask,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GlassPrimaryButton(
                    label: SponsorshipTransferStrings.t('st_ai_send', locale),
                    accentColor: AppColors.chipSponsorshipTransfer,
                    onPressed: chat.isLoading ? null : () => _ask(_controller.text),
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
