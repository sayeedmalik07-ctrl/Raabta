import 'dart:async';
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
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/in_call/in_call_claimed_caller.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_self_report.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_incident_label_keys.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_incident_result.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_sim_self_report_questions.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_alert_ack_service.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_service.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_offer.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_delivery.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_spam_report_hint.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_notification_service.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldIncidentScreen extends ConsumerStatefulWidget {
  const ScamShieldIncidentScreen({super.key, this.prefill});

  final ScamIncidentPrefill? prefill;

  @override
  ConsumerState<ScamShieldIncidentScreen> createState() =>
      _ScamShieldIncidentScreenState();
}

class _ScamShieldIncidentScreenState
    extends ConsumerState<ScamShieldIncidentScreen> {
  ScamImpersonationCategory _impersonation = ScamImpersonationCategory.other;
  final _contactChannels = <ScamContactChannel>{};
  ScamIncidentTiming _timing = ScamIncidentTiming.unknown;
  final _shared = <ScamSharedDataCategory>{};
  final _outcomes = <ScamIncidentOutcome>{ScamIncidentOutcome.nothingYet};
  SimSwapSelfReportAnswers _simAnswers = const SimSwapSelfReportAnswers.empty();
  ScamIncidentAssessmentResult? _result;
  ScamIncidentInput? _lastInput;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill != null) {
      if (prefill.impersonationCategory != null) {
        _impersonation = prefill.impersonationCategory!;
      }
      if (prefill.sharedData.isNotEmpty) {
        _shared
          ..clear()
          ..addAll(prefill.sharedData);
      }
      if (prefill.outcomes != null && prefill.outcomes!.isNotEmpty) {
        _outcomes
          ..clear()
          ..addAll(prefill.outcomes!);
      }
      if (prefill.contactChannels.isNotEmpty) {
        _contactChannels.addAll(prefill.contactChannels);
      }
      if (prefill.timing != null) {
        _timing = prefill.timing!;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(scamShieldAcknowledgeOpenAlerts(ref));
    });
  }

  ScamIncidentInput _buildIncidentInput() {
    final base = ScamIncidentInput(
      impersonationCategory: _impersonation,
      contactChannels: _contactChannels,
      timing: _timing,
      occurredAt: _timing == ScamIncidentTiming.justNow ? DateTime.now() : null,
      sharedData: _shared,
      outcomes: _outcomes,
      evidenceStatus: ScamEvidenceStatus.reportedByUser,
    );

    return SimSwapSelfReportMapper.mergeIntoIncidentInput(
      base: base,
      simAnswers: _simAnswers.hasAnyAnswer ? _simAnswers : null,
    );
  }

  Future<void> _submit() async {
    final input = _buildIncidentInput();

    final history = await ref.read(scamShieldHistoryRepositoryProvider).loadAll();
    final service = ref.read(scamShieldIncidentServiceProvider);
    final result = service.assess(
      input: input,
      recentHistory: history,
    );

    final entry = ScamShieldHistoryEntry.fromIncident(
      result: result,
      input: input,
    );
    await ref.read(scamShieldHistoryRepositoryProvider).saveEntry(entry);
    ref.invalidate(scamShieldHistoryProvider);
    ref.invalidate(scamShieldActiveAlertProvider);

    await ScamShieldNotificationService.maybeNotifyIncidentResult(
      result: result,
      locale: AppLocale.normalize(ref.read(userLanguageProvider)),
    );
    await SecurityAlertDelivery.markPostIncidentCampaign();
    await PostIncidentWatchService.onIncidentFlowCompleted();

    if (mounted) {
      setState(() {
        _result = result;
        _lastInput = input;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_incident_entry_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_incident_local_only', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            ScamSpamReportHint(locale: locale),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_incident_step_a', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ScamSharedDataCategory.values.map((category) {
                final selected = _shared.contains(category);
                return FilterChip(
                  label: Text(
                    ScamShieldStrings.t(sharedDataLabelKey(category), locale),
                    style: AppTypography.caption,
                  ),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _shared.add(category);
                      } else {
                        _shared.remove(category);
                      }
                    });
                  },
                  selectedColor:
                      AppColors.errorBright.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_incident_step_b', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ScamIncidentOutcome.values.map((outcome) {
                final selected = _outcomes.contains(outcome);
                return FilterChip(
                  label: Text(
                    ScamShieldStrings.t(outcomeLabelKey(outcome), locale),
                    style: AppTypography.caption,
                  ),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (outcome == ScamIncidentOutcome.nothingYet) {
                        _outcomes
                          ..clear()
                          ..add(ScamIncidentOutcome.nothingYet);
                        return;
                      }
                      _outcomes.remove(ScamIncidentOutcome.nothingYet);
                      if (value) {
                        _outcomes.add(outcome);
                      } else {
                        _outcomes.remove(outcome);
                      }
                      if (_outcomes.isEmpty) {
                        _outcomes.add(ScamIncidentOutcome.nothingYet);
                      }
                    });
                  },
                  selectedColor:
                      AppColors.errorBright.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_incident_sim_section', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ScamShieldStrings.t('ss_incident_sim_section_sub', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldSimSelfReportQuestions(
              answers: _simAnswers,
              locale: locale,
              compact: true,
              onChanged: (answers) => setState(() => _simAnswers = answers),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push('/scam-shield/sim-swap'),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(
                  ScamShieldStrings.t('ss_incident_sim_full_check', locale),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_incident_step_c', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ScamContactChannel.values.map((channel) {
                final selected = _contactChannels.contains(channel);
                return FilterChip(
                  label: Text(
                    ScamShieldStrings.t(contactChannelLabelKey(channel), locale),
                    style: AppTypography.caption,
                  ),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _contactChannels.add(channel);
                      } else {
                        _contactChannels.remove(channel);
                      }
                    });
                  },
                  selectedColor:
                      AppColors.errorBright.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScamShieldStrings.t('ss_incident_who', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ScamImpersonationCategory.values.map((category) {
                return ChoiceChip(
                  label: Text(
                    ScamShieldStrings.t(impersonationLabelKey(category), locale),
                    style: AppTypography.caption,
                  ),
                  selected: _impersonation == category,
                  onSelected: (_) => setState(() => _impersonation = category),
                  selectedColor:
                      AppColors.errorBright.withValues(alpha: 0.25),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_incident_step_d', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ScamIncidentTiming.values.map((timing) {
                return ChoiceChip(
                  label: Text(
                    ScamShieldStrings.t(incidentTimingLabelKey(timing), locale),
                    style: AppTypography.caption,
                  ),
                  selected: _timing == timing,
                  onSelected: (_) => setState(() => _timing = timing),
                  selectedColor:
                      AppColors.errorBright.withValues(alpha: 0.25),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: ScamShieldStrings.t('ss_incident_assess', locale),
              expand: true,
              accentColor: AppColors.errorBright,
              icon: Icons.emergency_outlined,
              onPressed: _submit,
            ),
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.errorBright,
                glowIntensity: 0.12,
                child: ScamShieldIncidentResultView(
                  result: _result!,
                  locale: locale,
                  onSaveEvidence: _lastInput == null
                      ? null
                      : () async {
                          final record = await ref
                              .read(scamEvidenceLockerServiceProvider)
                              .saveFromIncident(
                                result: _result!,
                                input: _lastInput!,
                              );
                          if (context.mounted) {
                            await SensitiveSafetyLockOffer
                                .maybeOfferAfterFirstSensitiveSave(
                              context,
                              ref,
                              locale: locale,
                            );
                          }
                          return record;
                        },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
