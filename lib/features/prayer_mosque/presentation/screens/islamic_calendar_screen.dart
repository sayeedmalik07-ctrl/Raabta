import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/data/islamic_content_repository.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/ramadan/hijri_calendar.dart';

class IslamicCalendarScreen extends ConsumerStatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  ConsumerState<IslamicCalendarScreen> createState() =>
      _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends ConsumerState<IslamicCalendarScreen> {
  DateTime _focused = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final events = ref.watch(prayerCalendarEventsProvider);
    final hijri = gregorianToHijri(_focused);
    final monthName =
        IslamicContentRepository.hijriMonthNames[hijri.month] ?? '';

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_calendar', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  '$monthName ${hijri.day}, ${hijri.year} AH',
                  style: AppTypography.headline2,
                ),
                Text(
                  DateFormat.yMMMMd().format(_focused),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        _focused = DateTime(
                          _focused.year,
                          _focused.month - 1,
                          1,
                        );
                      }),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(DateFormat.yMMMM().format(_focused),
                        style: AppTypography.title),
                    IconButton(
                      onPressed: () => setState(() {
                        _focused = DateTime(
                          _focused.year,
                          _focused.month + 1,
                          1,
                        );
                      }),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Upcoming events', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          ...events.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(e.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PrayerStrings.t(e.titleKey, locale),
                            style: AppTypography.title,
                          ),
                          Text(
                            DateFormat.yMMMd().format(e.gregorianDate),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Date converter', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Gregorian ${_focused.day}/${_focused.month}/${_focused.year} → '
              'Hijri ${hijri.day}/${hijri.month}/${hijri.year}',
              style: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}
