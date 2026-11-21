import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_tag.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_assistant_reply.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/services/islamic_faq_matcher.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_ai_service.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_routing_log.dart';

class PrayerAssistantScreen extends ConsumerStatefulWidget {
  const PrayerAssistantScreen({super.key});

  @override
  ConsumerState<PrayerAssistantScreen> createState() =>
      _PrayerAssistantScreenState();
}

class _PrayerAssistantScreenState extends ConsumerState<PrayerAssistantScreen> {
  final _controller = TextEditingController();
  PrayerAssistantReply? _reply;
  bool _loading = false;

  static const _examples = [
    'Nearest mosque?',
    'When is Jumu\'ah?',
    'Travel prayer rules?',
    'Can I combine prayers while travelling?',
    'Nearby prayer room?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask([String? question]) async {
    final q = (question ?? _controller.text).trim();
    if (q.isEmpty || _loading) return;

    final state = ref.read(prayerProvider);
    final locale = state.settings.locale;

    final instantFaq = IslamicFaqMatcher.tryMatch(q, locale);
    if (instantFaq != null) {
      PrayerRoutingLog.faqHit(
        entryId: instantFaq.entry.id,
        category: instantFaq.entry.category,
        confidence: instantFaq.confidence,
      );
      setState(() {
        _reply = instantFaq.toReply(locale);
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _reply = null;
    });

    final schedule = state.schedule;
    if (schedule == null) {
      if (!mounted) return;
      setState(() {
        _reply = PrayerAssistantReply(
          text: PrayerStrings.t('prayer_offline', locale),
          source: PrayerReplySource.claude,
        );
        _loading = false;
      });
      return;
    }

    final nearest =
        state.mosques.isNotEmpty ? state.mosques.first.name : null;
    try {
      final reply = await ref.read(prayerAiServiceProvider).ask(
            question: q,
            schedule: schedule,
            settings: state.settings,
            nearestMosqueName: nearest,
          );
      if (!mounted) return;
      setState(() {
        _reply = reply;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reply = PrayerAssistantReply(
          text: e.toString(),
          source: PrayerReplySource.claude,
        );
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(prayerProvider).settings.locale;
    final reply = _reply;

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_ai', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              PrayerStrings.t('prayer_ai_disclaimer', locale),
              style: AppTypography.caption,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _examples
                .map(
                  (e) => GlassTag(
                    label: e,
                    accentColor: AppColors.chipPrayer,
                    onTap: () => _ask(e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? const Center(child: GlassProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          reply?.text ??
                              PrayerStrings.t('prayer_ai_hint', locale),
                          style: AppTypography.body,
                        ),
                        if (reply?.deepLinkRoute case final faqRoute?) ...[
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () => context.push(faqRoute),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: Text(
                              PrayerStrings.t(
                                reply?.deepLinkLabelKey ?? 'prayer_faq_open',
                                locale,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          GlassTextField(
            controller: _controller,
            hint: PrayerStrings.t('prayer_ai_hint', locale),
            onSubmitted: (_) => _ask(),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassPrimaryButton(
            label: PrayerStrings.t('prayer_ai_ask', locale),
            icon: Icons.auto_awesome,
            expand: true,
            accentColor: AppColors.chipPrayer,
            onPressed: _loading ? null : () => _ask(),
          ),
        ],
      ),
    );
  }
}
