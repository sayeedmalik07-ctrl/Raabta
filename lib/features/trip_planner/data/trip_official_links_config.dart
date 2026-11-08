/// Verified official outbound links for Trip Planner (link-out only).
abstract final class TripOfficialLinksConfig {
  static const lastVerifiedIso = '2026-10-16';

  static const visitQatarVisas =
      'https://visitqatar.com/intl-en/plan-your-trip/visas';
  static const hayyaPortal = 'https://hayya.qa/';
  static const visitQatarEvents =
      'https://visitqatar.com/intl-en/events-calendar';
  static const visitQatarThingsToDo =
      'https://visitqatar.com/intl-en/things-to-do';
  static const visitQatarStopover =
      'https://visitqatar.com/intl-en/qatar-stopover';

  /// Opaque analytics row ids — no URLs or trip data in event names.
  static const rowVisas = 'official_visas';
  static const rowHayya = 'official_hayya';
  static const rowEvents = 'official_events';
  static const rowThingsToDo = 'official_things_to_do';
  static const rowStopover = 'official_stopover';
}
