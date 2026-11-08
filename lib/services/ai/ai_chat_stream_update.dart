class AiChatStreamMeta {
  const AiChatStreamMeta({
    this.model,
    this.modelTier,
    this.dailyRemaining,
    this.dailyLimit,
    this.isPremium = false,
  });

  final String? model;
  final String? modelTier;
  final int? dailyRemaining;
  final int? dailyLimit;
  final bool isPremium;
}

class AiChatStreamUpdate {
  const AiChatStreamUpdate({
    this.textDelta,
    this.meta,
    this.error,
  });

  final String? textDelta;
  final AiChatStreamMeta? meta;
  final String? error;

  bool get isMeta => meta != null;
  bool get isText => textDelta != null && textDelta!.isNotEmpty;
  bool get isError => error != null && error!.isNotEmpty;
}
