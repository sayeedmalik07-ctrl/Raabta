import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_self_report.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_sim_self_report_questions.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_sim_swap_result.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/scam_shield/services/scam_sim_swap_service.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldSimSwapScreen extends ConsumerStatefulWidget {
  const ScamShieldSimSwapScreen({super.key});

  @override
  ConsumerState<ScamShieldSimSwapScreen> createState() =>
      _ScamShieldSimSwapScreenState();
}

class _ScamShieldSimSwapScreenState extends ConsumerState<ScamShieldSimSwapScreen> {
  ScamQatarTelecomProvider _provider = ScamQatarTelecomProvider.unknown;
  SimSwapSelfReportAnswers _answers = const SimSwapSelfReportAnswers.empty();
  final _notesController = TextEditingController();
  SimSwapAssessmentResult? _result;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = SimSwapSelfReportMapper.toAnalyzerInput(
      answers: _answers,
      provider: _provider,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final history = await ref.read(scamShieldHistoryRepositoryProvider).loadAll();
    final service = ref.read(scamSimSwapServiceProvider);
    final result = service.assess(input: input, recentHistory: history);

    final entry = ScamShieldHistoryEntry.fromSimSwap(
      result: result,
      provider: _provider,
      answers: _answers,
    );
    await ref.read(scamShieldHistoryRepositoryProvider).saveEntry(entry);
    ref.invalidate(scamShieldHistoryProvider);

    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_sim_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_sim_subtitle', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t('ss_sim_local_only', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_sim_provider_heading', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ScamQatarTelecomProvider.values.map((provider) {
                return ChoiceChip(
                  label: Text(ScamShieldStrings.t(provider.labelKey, locale)),
                  selected: _provider == provider,
                  onSelected: (_) => setState(() {
                    _provider = provider;
                    _result = null;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ScamShieldSimSelfReportQuestions(
              answers: _answers,
              locale: locale,
              onChanged: (answers) => setState(() {
                _answers = answers;
                _result = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: ScamShieldStrings.t('ss_sim_notes_label', locale),
                hintText: ScamShieldStrings.t('ss_sim_notes_hint', locale),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => _result = null),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: ScamShieldStrings.t('ss_sim_review_cta', locale),
              onPressed: _answers.isComplete ? _submit : null,
            ),
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ScamShieldSimSwapResultView(
                result: _result!,
                locale: locale,
                provider: _provider,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
