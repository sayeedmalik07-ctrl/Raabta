enum PrayerReplySource { faq, claude }

class PrayerAssistantReply {
  const PrayerAssistantReply({
    required this.text,
    required this.source,
    this.deepLinkRoute,
    this.deepLinkLabelKey,
  });

  final String text;
  final PrayerReplySource source;
  final String? deepLinkRoute;
  final String? deepLinkLabelKey;

  bool get isFaq => source == PrayerReplySource.faq;
}
