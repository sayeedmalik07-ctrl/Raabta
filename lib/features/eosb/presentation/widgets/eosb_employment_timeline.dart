import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class EosbEmploymentTimeline extends StatelessWidget {
  const EosbEmploymentTimeline({
    super.key,
    required this.input,
    required this.locale,
    this.calculatedAt,
  });

  final EosbEmployeeInput input;
  final String locale;
  final DateTime? calculatedAt;

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents();
    if (events.isEmpty) {
      return Text(
        EosbStrings.t('eosb_timeline_empty', locale),
        style: AppTypography.bodySmall,
      );
    }

    return Column(
      children: events.asMap().entries.map((entry) {
        final i = entry.key;
        final event = entry.value;
        final isLast = i == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: event.color),
                    ),
                    child: Icon(event.icon, color: event.color, size: 16),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EosbStrings.t(event.titleKey, locale),
                        style: AppTypography.title.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(event.date),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.cyanGlow,
                        ),
                      ),
                      if (event.subtitleKey != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          EosbStrings.t(event.subtitleKey!, locale),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<_TimelineEvent> _buildEvents() {
    final events = <_TimelineEvent>[];
    final join = input.joiningDate;
    final last = input.lastWorkingDate;

    if (join != null) {
      events.add(
        _TimelineEvent(
          date: join,
          titleKey: 'eosb_timeline_joining',
          subtitleKey: input.companyName.isNotEmpty
              ? null
              : 'eosb_timeline_joining_desc',
          icon: Icons.work_outline,
          color: AppColors.emeraldGlow,
        ),
      );

      final probationEnd = join.add(const Duration(days: 90));
      if (last == null || probationEnd.isBefore(last)) {
        events.add(
          _TimelineEvent(
            date: probationEnd,
            titleKey: 'eosb_timeline_probation',
            subtitleKey: 'eosb_timeline_probation_desc',
            icon: Icons.hourglass_bottom,
            color: AppColors.accentGold,
          ),
        );
      }

      events.add(
        _TimelineEvent(
          date: probationEnd.add(const Duration(days: 1)),
          titleKey: 'eosb_timeline_confirmation',
          subtitleKey: 'eosb_timeline_confirmation_desc',
          icon: Icons.verified_outlined,
          color: AppColors.cyanGlow,
        ),
      );
    }

    if (last != null) {
      events.add(
        _TimelineEvent(
          date: last,
          titleKey: 'eosb_timeline_last_day',
          subtitleKey: 'eosb_timeline_last_day_desc',
          icon: Icons.event_busy_outlined,
          color: AppColors.heatOrange,
        ),
      );

      events.add(
        _TimelineEvent(
          date: last.add(const Duration(days: 14)),
          titleKey: 'eosb_timeline_settlement',
          subtitleKey: 'eosb_timeline_settlement_desc',
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.sharePurple,
        ),
      );
    }

    if (calculatedAt != null) {
      events.add(
        _TimelineEvent(
          date: calculatedAt!,
          titleKey: 'eosb_timeline_eosb_calc',
          subtitleKey: 'eosb_timeline_eosb_calc_desc',
          icon: Icons.calculate_outlined,
          color: AppColors.successBright,
        ),
      );
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.date,
    required this.titleKey,
    required this.icon,
    required this.color,
    this.subtitleKey,
  });

  final DateTime date;
  final String titleKey;
  final String? subtitleKey;
  final IconData icon;
  final Color color;
}
