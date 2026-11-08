import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_moment_models.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/services/know_qatar_moments_analytics.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/models/visa_models.dart';

class KnowQatarNextStepCard extends StatelessWidget {
  const KnowQatarNextStepCard({
    super.key,
    required this.locale,
    required this.step,
    this.deadlineExpiryLabel,
    required this.onDismiss,
  });

  final String locale;
  final NextStepRecommendation step;
  final String? deadlineExpiryLabel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(step.severity);
    final title = _titleLine(locale, step, deadlineExpiryLabel);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: accent,
        glowIntensity: step.severity == NextStepSeverity.neutral ? 0.08 : 0.16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flag_outlined, color: accent, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        KnowQatarStrings.t('kq_next_step_heading', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: KnowQatarStrings.t('kq_next_step_dismiss', locale),
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton(
                onPressed: () {
                  KnowQatarMomentsAnalytics.nextStepTapped(
                    actionCategory: _categoryFor(step.kind),
                  );
                  if (step.route.startsWith('/know-qatar')) {
                    context.push(step.route);
                  } else {
                    QuickActionsHub.navigateTo(context, step.route);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: accent.withValues(alpha: 0.85),
                  foregroundColor: AppColors.textPrimary,
                ),
                child: Text(KnowQatarStrings.t(step.actionKey, locale)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _categoryFor(NextStepKind kind) {
    switch (kind) {
      case NextStepKind.deadline:
        return 'deadline';
      case NextStepKind.momentItem:
        return 'moment';
      case NextStepKind.lastOpened:
        return 'resume';
      case NextStepKind.genericFallback:
        return 'fallback';
    }
  }

  static Color _accentFor(NextStepSeverity severity) {
    switch (severity) {
      case NextStepSeverity.critical:
        return AppColors.errorBright;
      case NextStepSeverity.amber:
        return AppColors.accentGold;
      case NextStepSeverity.neutral:
        return AppColors.cyanGlow;
    }
  }

  static String _titleLine(
    String locale,
    NextStepRecommendation step,
    String? deadlineExpiryLabel,
  ) {
    if (step.kind == NextStepKind.deadline) {
      final base = KnowQatarStrings.format(
        step.titleKey,
        locale,
        params: step.titleParams,
      );
      if (step.useDeadlineExpiryLabel &&
          deadlineExpiryLabel != null &&
          deadlineExpiryLabel.isNotEmpty) {
        return '$base · $deadlineExpiryLabel';
      }
      return base;
    }

    if (step.titleParams.containsKey('title')) {
      final nestedKey = step.titleParams['title']!;
      final nestedTitle = KnowQatarStrings.t(nestedKey, locale);
      return KnowQatarStrings.format(
        step.titleKey,
        locale,
        params: {'title': nestedTitle},
      );
    }

    return KnowQatarStrings.t(step.titleKey, locale);
  }
}

/// Pick expiry label for the deadline referenced by [step], if any.
String? nextStepDeadlineExpiryLabel(
  NextStepRecommendation step,
  List<DocumentDeadline> deadlines,
) {
  if (step.kind != NextStepKind.deadline) return null;
  final deadlineId =
      Uri.parse('https://raabta.local${step.route}').queryParameters['deadlineId'];
  if (deadlineId == null || deadlineId.isEmpty) return null;
  for (final d in deadlines) {
    if (d.id == deadlineId) return d.expiryLabel;
  }
  return null;
}
