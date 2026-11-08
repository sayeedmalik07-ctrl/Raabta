import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/features/home/widgets/home_glance_anchor_shell.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/prayer_mosque/data/islamic_content_repository.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_schedule_providers.dart';
import 'package:raabta/features/ramadan/hijri_calendar.dart';

/// Glanceable prayer strip on Home — kit glance row (teal family).
class HomePrayerStrip extends ConsumerWidget {
  const HomePrayerStrip({
    super.key,
    this.compact = false,
    this.outerPadding = true,
  });

  final bool compact;
  final bool outerPadding;

  static Color get accent => AppColors.tealFamilyMain;

  static String nextCountdownLine({
    required String locale,
    required PrayerScheduleEntry? next,
    required Duration? remaining,
  }) {
    if (next == null || remaining == null) return '—';
    return PrayerStrings.format(
      'home_strip_next_countdown',
      locale,
      params: {
        'prayer': PrayerStrings.t(next.labelKey, locale),
        'time': formatPrayerDuration(remaining),
      },
    );
  }

  static String nextHeadingLine({
    required String locale,
    required PrayerScheduleEntry? next,
  }) {
    if (next == null) return '—';
    return PrayerStrings.format(
      'home_strip_next_heading',
      locale,
      params: {'prayer': PrayerStrings.t(next.labelKey, locale)},
    );
  }

  static String nextTimeLine({
    required String locale,
    required Duration? remaining,
  }) {
    if (remaining == null) return '—';
    return PrayerStrings.format(
      'home_strip_time_remaining',
      locale,
      params: {'time': formatPrayerDuration(remaining)},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocale = ref.watch(appLocaleProvider);
    final strip = ref.watch(prayerScheduleStripProvider);
    final locale = AppLocale.normalize(strip.settings.locale.isNotEmpty
        ? strip.settings.locale
        : appLocale);

    Widget content;
    if (strip.isLoading) {
      content = const SizedBox(
        height: 48,
        child: Center(child: GlassProgressIndicator()),
      );
    } else {
      final schedule = strip.schedule;
      if (schedule == null) {
        return const SizedBox.shrink();
      }
      content = _HomePrayerStripBody(
        schedule: schedule,
        locale: locale,
        compact: compact,
      );
    }

    if (!outerPadding) return content;
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.md,
      ),
      child: content,
    );
  }
}

class _HomePrayerStripBody extends ConsumerWidget {
  const _HomePrayerStripBody({
    required this.schedule,
    required this.locale,
    required this.compact,
  });

  final PrayerScheduleDay schedule;
  final String locale;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(prayerLiveClockProvider);
    final next = schedule.nextPrayerAt(now);
    final remaining = schedule.timeUntilNextAt(now);
    final hijri = gregorianToHijri(schedule.date);
    final hijriMonth =
        IslamicContentRepository.hijriMonthNames[hijri.month] ?? '';
    final hijriFull = '$hijriMonth ${hijri.day}, ${hijri.year} AH';

    final title = HomePrayerStrip.nextHeadingLine(locale: locale, next: next);
    final subtitle = HomePrayerStrip.nextTimeLine(
      locale: locale,
      remaining: remaining,
    );
    final semanticsLabel = [
      HomePrayerStrip.nextCountdownLine(
        locale: locale,
        next: next,
        remaining: remaining,
      ),
      hijriFull,
    ].join(', ');

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: HomeGlanceAnchorShell(
          familyMain: HomePrayerStrip.accent,
          icon: Icons.mosque_outlined,
          iconVariant: HomeIconBadgeVariant.tealBrand,
          title: title,
          subtitle: subtitle,
          showLivePulse: true,
          denseSingleLine: compact,
          onTap: () => context.push('/prayer-mosque/times'),
          trailing: !compact
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    hijriFull,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
