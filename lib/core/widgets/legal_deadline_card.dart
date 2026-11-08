import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/legal_deadline_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/services/legal_deadline_reminder_prefs.dart';
import 'package:raabta/services/legal_deadline_service.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

/// Prominent legal filing / appeal deadline indicator for Truth Engine screens.
class LegalDeadlineCard extends StatefulWidget {
  const LegalDeadlineCard({
    super.key,
    required this.result,
    required this.locale,
    required this.reminderScope,
    this.nextStepsRoute,
    this.missingDateMessage,
    this.urgentBody,
    this.expiredBody,
    this.ctaLabel,
    this.titleKeys,
    this.infoBody,
  });

  /// When null, shows [missingDateMessage] prompt instead.
  final LegalDeadlineResult? result;
  final String locale;
  final LegalDeadlineReminderScope reminderScope;
  final String? nextStepsRoute;
  final String? missingDateMessage;
  final String? urgentBody;
  final String? expiredBody;
  final String? ctaLabel;

  /// Overrides default filing-deadline title keys (e.g. employer payment due).
  final Map<LegalDeadlineUrgency, String>? titleKeys;

  /// Optional branch-specific explanatory line (e.g. Art. 67 end-of-working-day).
  final String? infoBody;

  @override
  State<LegalDeadlineCard> createState() => _LegalDeadlineCardState();
}

class _LegalDeadlineCardState extends State<LegalDeadlineCard> {
  bool? _remindersEnabled;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final enabled = await LegalDeadlineReminderPrefs.isEnabled(
      widget.reminderScope,
    );
    if (mounted) {
      setState(() {
        _remindersEnabled = enabled;
        _loadingPrefs = false;
      });
    }
  }

  Future<void> _toggleReminders(bool value) async {
    setState(() => _remindersEnabled = value);
    await LegalDeadlineReminderPrefs.setEnabled(widget.reminderScope, value);

    final result = widget.result;
    if (result == null) return;

    if (value && !result.isExpired && result.isVerified) {
      await NotificationEngine.instance.scheduleLegalDeadlineReminders(
        scope: widget.reminderScope,
        deadlineDate: result.deadlineDate,
        titlePrefix: _titleFor(result, widget.locale, widget.titleKeys),
      );
    } else {
      await NotificationEngine.instance.cancelLegalDeadlineReminders(
        widget.reminderScope,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    if (result == null) {
      final msg = widget.missingDateMessage;
      if (msg == null || msg.isEmpty) return const SizedBox.shrink();
      return GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.textSecondary,
        glowIntensity: 0.06,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.event_busy_outlined, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(msg, style: AppTypography.bodySmall),
            ),
          ],
        ),
      );
    }

    final dateFmt = DateFormat.yMMMd().format(result.deadlineDate);
    final glow = _glowColor(result.urgency);
    final titleKey = widget.titleKeys?[result.urgency] ??
        switch (result.urgency) {
          LegalDeadlineUrgency.informational => 'ld_title_info',
          LegalDeadlineUrgency.approaching => 'ld_title_approaching',
          LegalDeadlineUrgency.urgent => 'ld_title_urgent',
          LegalDeadlineUrgency.expired => 'ld_title_expired',
        };

    final daysLabel = result.daysRemaining >= 0
        ? LegalDeadlineStrings.format(
            'ld_days_remaining',
            widget.locale,
            {'days': '${result.daysRemaining}'},
          )
        : LegalDeadlineStrings.format(
            'ld_days_overdue',
            widget.locale,
            {'days': '${-result.daysRemaining}'},
          );

    final showUrgentBody = result.urgency == LegalDeadlineUrgency.urgent &&
        widget.urgentBody != null;
    final showExpiredBody = result.isExpired && widget.expiredBody != null;
    final showCta = (result.urgency == LegalDeadlineUrgency.urgent ||
            result.isExpired) &&
        widget.nextStepsRoute != null;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: glow,
      glowIntensity: result.urgency == LegalDeadlineUrgency.urgent ? 0.22 : 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(result.urgency), color: glow, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LegalDeadlineStrings.format(
                        titleKey,
                        widget.locale,
                        {'date': dateFmt},
                      ),
                      style: AppTypography.title.copyWith(
                        color: glow,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(daysLabel, style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            LegalDeadlineStrings.format(
              'ld_basis_label',
              widget.locale,
              {
                'basis': result.basisLabel,
                'date': DateFormat.yMMMd().format(result.basisDate),
              },
            ),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${LegalDeadlineStrings.t('ld_citation_prefix', widget.locale)} '
            '${result.citation}',
            style: AppTypography.caption.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          if (widget.infoBody != null && widget.infoBody!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(widget.infoBody!, style: AppTypography.bodySmall),
          ],
          if (showUrgentBody) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(widget.urgentBody!, style: AppTypography.bodySmall),
          ],
          if (showExpiredBody) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(widget.expiredBody!, style: AppTypography.bodySmall),
          ],
          if (showCta) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => context.push(widget.nextStepsRoute!),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                widget.ctaLabel ??
                    LegalDeadlineStrings.t('ld_cta_eosb', widget.locale),
              ),
            ),
          ],
          if (!result.isExpired && result.isVerified && !_loadingPrefs) ...[
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                LegalDeadlineStrings.t('ld_remind_toggle', widget.locale),
                style: AppTypography.caption,
              ),
              value: _remindersEnabled ?? false,
              onChanged: _toggleReminders,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            LegalDeadlineStrings.t('ld_disclaimer', widget.locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

Color _glowColor(LegalDeadlineUrgency urgency) => switch (urgency) {
      LegalDeadlineUrgency.informational => AppColors.cyanGlow,
      LegalDeadlineUrgency.approaching => AppColors.accentGold,
      LegalDeadlineUrgency.urgent => AppColors.errorBright,
      LegalDeadlineUrgency.expired => AppColors.textSecondary,
    };

IconData _iconFor(LegalDeadlineUrgency urgency) => switch (urgency) {
      LegalDeadlineUrgency.informational => Icons.event_outlined,
      LegalDeadlineUrgency.approaching => Icons.schedule_outlined,
      LegalDeadlineUrgency.urgent => Icons.warning_amber_rounded,
      LegalDeadlineUrgency.expired => Icons.event_busy_outlined,
    };

String _titleFor(
  LegalDeadlineResult result,
  String locale,
  Map<LegalDeadlineUrgency, String>? titleKeys,
) {
  final dateFmt = DateFormat.yMMMd().format(result.deadlineDate);
  final key = titleKeys?[result.urgency] ??
      switch (result.urgency) {
        LegalDeadlineUrgency.informational => 'ld_title_info',
        LegalDeadlineUrgency.approaching => 'ld_title_approaching',
        LegalDeadlineUrgency.urgent => 'ld_title_urgent',
        LegalDeadlineUrgency.expired => 'ld_title_expired',
      };
  return LegalDeadlineStrings.format(key, locale, {'date': dateFmt});
}

/// Read-only timeline marker — non-deletable system milestone.
class LegalDeadlineTimelineMarker extends StatelessWidget {
  const LegalDeadlineTimelineMarker({
    super.key,
    required this.result,
    required this.locale,
    this.isLast = false,
  });

  final LegalDeadlineResult result;
  final String locale;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final glow = _glowColor(result.urgency);
    final dateFmt = DateFormat.yMMMd().format(result.deadlineDate);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: glow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.glassBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor: glow,
                glowIntensity: 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gavel_outlined, size: 16, color: glow),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          LegalDeadlineStrings.t(
                            'ld_timeline_marker',
                            locale,
                          ),
                          style: AppTypography.caption.copyWith(
                            color: glow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(dateFmt, style: AppTypography.caption),
                    Text(
                      LegalDeadlineStrings.format(
                        'ld_title_info',
                        locale,
                        {'date': dateFmt},
                      ),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(result.citation, style: AppTypography.caption),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
