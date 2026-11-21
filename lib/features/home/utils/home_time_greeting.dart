import 'package:raabta/core/l10n/app_shell_strings.dart';

/// Time-of-day bucket for the Home welcome header (device-local clock).
enum HomeTimeGreetingPeriod {
  morning,
  afternoon,
  evening,
  hello,
}

/// Maps [hour] (0–23, device local) to a greeting period.
///
/// 05:00–11:59 morning, 12:00–16:59 afternoon, 17:00–20:59 evening,
/// 21:00–04:59 neutral hello.
HomeTimeGreetingPeriod homeTimeGreetingPeriodForHour(int hour) {
  assert(hour >= 0 && hour <= 23, 'hour must be 0–23');
  if (hour >= 5 && hour < 12) return HomeTimeGreetingPeriod.morning;
  if (hour >= 12 && hour < 17) return HomeTimeGreetingPeriod.afternoon;
  if (hour >= 17 && hour < 21) return HomeTimeGreetingPeriod.evening;
  return HomeTimeGreetingPeriod.hello;
}

/// App shell l10n key for [hour].
String homeTimeGreetingKeyForHour(int hour) {
  return switch (homeTimeGreetingPeriodForHour(hour)) {
    HomeTimeGreetingPeriod.morning => 'greeting_morning',
    HomeTimeGreetingPeriod.afternoon => 'greeting_afternoon',
    HomeTimeGreetingPeriod.evening => 'greeting_evening',
    HomeTimeGreetingPeriod.hello => 'greeting_hello',
  };
}

/// Localized greeting for [locale] at [now] (defaults to device-local now).
String homeTimeGreetingForLocale(
  String locale, {
  DateTime? now,
}) {
  final hour = (now ?? DateTime.now()).hour;
  return AppShellStrings.t(homeTimeGreetingKeyForHour(hour), locale);
}
