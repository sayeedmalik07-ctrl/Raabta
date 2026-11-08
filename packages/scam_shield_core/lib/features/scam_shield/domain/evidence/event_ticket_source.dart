/// External notice metadata — hidden until [verified] is true.
class EventTicketSourceNotice {
  const EventTicketSourceNotice({
    required this.verified,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.noticeDateIso,
  });

  final bool verified;
  final String sourceLabel;
  final String sourceUrl;
  final String noticeDateIso;
}

abstract final class EventTicketSourceCatalog {
  static EventTicketSourceNotice notice = const EventTicketSourceNotice(
    verified: false,
    sourceLabel:
        'Qatar Calendar notice reported by The Peninsula, 17 Oct 2026',
    sourceUrl:
        'https://thepeninsulaqatar.com/article/17/10/2026/qatar-calendar-issues-notice-on-ticketing-scams',
    noticeDateIso: '2026-10-17',
  );

  static void installForTest(EventTicketSourceNotice value) {
    notice = value;
  }

  static void resetForTest() {
    notice = const EventTicketSourceNotice(
      verified: false,
      sourceLabel:
          'Qatar Calendar notice reported by The Peninsula, 17 Oct 2026',
      sourceUrl:
          'https://thepeninsulaqatar.com/article/17/10/2026/qatar-calendar-issues-notice-on-ticketing-scams',
      noticeDateIso: '2026-10-17',
    );
  }
}
