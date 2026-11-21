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
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_academy_config.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_academy_strings.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_academy_checkpoint_tile.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldAcademyScreen extends ConsumerStatefulWidget {
  const ScamShieldAcademyScreen({super.key});

  @override
  ConsumerState<ScamShieldAcademyScreen> createState() =>
      _ScamShieldAcademyScreenState();
}

class _ScamShieldAcademyScreenState
    extends ConsumerState<ScamShieldAcademyScreen> {
  Set<String> _completed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProgress());
  }

  Future<void> _loadProgress() async {
    final repo = ref.read(scamShieldAcademyProgressRepositoryProvider);
    final ids = await repo.loadCompletedIds();
    if (!mounted) return;
    setState(() {
      _completed = ids;
      _loading = false;
    });
  }

  Future<void> _markStage(ScamAttackStage stage) async {
    final repo = ref.read(scamShieldAcademyProgressRepositoryProvider);
    await repo.markStageRead(stage);
    if (!mounted) return;
    setState(() => _completed = {..._completed, stage.name});
  }

  Future<void> _markActionPanel() async {
    final repo = ref.read(scamShieldAcademyProgressRepositoryProvider);
    await repo.markActionPanelRead();
    if (!mounted) return;
    setState(() {
      _completed = {
        ..._completed,
        ScamShieldAcademyConfig.actionCheckpointId,
      };
    });
  }

  int _firstIncompleteIndex() {
    for (var i = 0; i < ScamShieldAcademyConfig.stageCheckpoints.length; i++) {
      final stage = ScamShieldAcademyConfig.stageCheckpoints[i];
      if (!_completed.contains(stage.name)) return i;
    }
    if (!_completed.contains(ScamShieldAcademyConfig.actionCheckpointId)) {
      return ScamShieldAcademyConfig.stageCheckpoints.length;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final stages = ScamShieldAcademyConfig.stageCheckpoints;
    final currentIndex = _firstIncompleteIndex();
    final total = stages.length + 1;
    final readCount = _completed
        .where(
          (id) =>
              id == ScamShieldAcademyConfig.actionCheckpointId ||
              stages.any((s) => s.name == id),
        )
        .length;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldAcademyStrings.t('ss_academy_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Text(
                    ScamShieldAcademyStrings.t('ss_academy_subtitle', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ScamShieldAcademyStrings.format(
                      'ss_academy_progress',
                      locale,
                      params: {
                        'current': readCount.toString(),
                        'total': total.toString(),
                      },
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.cyanGlow,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < stages.length; i++)
                    _stageTile(
                      context: context,
                      locale: locale,
                      stage: stages[i],
                      index: i,
                      isCurrent: currentIndex == i,
                    ),
                  _actionPanel(context, locale, currentIndex == stages.length),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.push('/scam-shield/scam-types'),
                    child: Text(
                      ScamShieldStrings.t('ss_scam_types_hub_title', locale),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _stageTile({
    required BuildContext context,
    required String locale,
    required ScamAttackStage stage,
    required int index,
    required bool isCurrent,
  }) {
    final done = _completed.contains(stage.name);
    final exampleLabel =
        ScamShieldAcademyStrings.t('ss_academy_example_label', locale);
    final whyLabel =
        ScamShieldAcademyStrings.t('ss_academy_why_label', locale);
    final markRead =
        ScamShieldAcademyStrings.t('ss_academy_mark_read', locale);

    Widget? extra;
    if (stage == ScamAttackStage.impersonation) {
      extra = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScamShieldAcademyStrings.t(
              'ss_academy_impersonation_heading',
              locale,
            ),
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final category in ScamShieldAcademyConfig.impersonationCategories)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• ${ScamShieldStrings.t(_impersonationKey(category), locale)}',
                style: AppTypography.bodySmall,
              ),
            ),
        ],
      );
    }

    return ScamShieldAcademyCheckpointTile(
      title: ScamShieldAcademyStrings.stageTitle(stage, locale),
      explain: ScamShieldAcademyStrings.stageExplain(stage, locale),
      exampleLabel: exampleLabel,
      example: ScamShieldAcademyStrings.stageExample(stage, locale),
      whyLabel: whyLabel,
      why: ScamShieldAcademyStrings.stageWhy(stage, locale),
      markReadLabel: markRead,
      completed: done,
      isCurrent: isCurrent,
      extra: extra,
      onMarkRead: done ? null : () => _markStage(stage),
      trailing: Text(
        '${index + 1}',
        style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
      ),
    );
  }

  Widget _actionPanel(BuildContext context, String locale, bool isCurrent) {
    final done = _completed.contains(ScamShieldAcademyConfig.actionCheckpointId);
    final markRead =
        ScamShieldAcademyStrings.t('ss_academy_mark_read', locale);
    final accent = done ? AppColors.chipEosb : AppColors.cyanGlow;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: isCurrent ? accent : null,
        glowIntensity: isCurrent ? 0.14 : 0.04,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    ScamShieldAcademyStrings.t('ss_academy_actions_title', locale),
                    style: AppTypography.subtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ScamShieldAcademyStrings.t('ss_academy_actions_body', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                TextButton(
                  onPressed: () => context.push('/scam-shield/incident'),
                  child: Text(
                    ScamShieldAcademyStrings.t('ss_academy_open_incident', locale),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/scam-shield/directory'),
                  child: Text(
                    ScamShieldAcademyStrings.t('ss_academy_open_directory', locale),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(
                    '/scam-shield/family-verification/practice',
                  ),
                  child: Text(
                    FamilyVerificationKitStrings.t('ss_fvk_academy_link', locale),
                  ),
                ),
              ],
            ),
            if (!done)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _markActionPanel,
                  child: Text(markRead),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _impersonationKey(ScamImpersonationCategory category) {
    return switch (category) {
      ScamImpersonationCategory.government => 'ss_impersonation_government',
      ScamImpersonationCategory.bank => 'ss_impersonation_bank',
      ScamImpersonationCategory.telecom => 'ss_impersonation_telecom',
      ScamImpersonationCategory.deliveryCompany => 'ss_impersonation_delivery',
      ScamImpersonationCategory.employer => 'ss_impersonation_employer',
      ScamImpersonationCategory.other => 'ss_impersonation_other',
    };
  }
}
