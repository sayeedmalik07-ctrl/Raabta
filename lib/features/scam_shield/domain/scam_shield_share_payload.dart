/// Payload from OS share sheet, held until the review screen consumes it.
class ScamShieldSharePayload {
  const ScamShieldSharePayload({
    this.sharedText,
    List<String>? imagePaths,
    this.textWasTruncated = false,
    this.droppedExtraImageCount = 0,
    this.unsupportedAttachmentCount = 0,
    this.unsupportedOnly = false,
  }) : imagePaths = imagePaths ?? const [];

  final String? sharedText;
  final List<String> imagePaths;
  final bool textWasTruncated;
  final int droppedExtraImageCount;
  final int unsupportedAttachmentCount;
  final bool unsupportedOnly;

  /// First adopted image (legacy single-image consumers).
  String? get imagePath => imagePaths.isEmpty ? null : imagePaths.first;

  bool get hasText => sharedText != null && sharedText!.trim().isNotEmpty;

  bool get hasImage => imagePaths.isNotEmpty;

  bool get isEmpty => !hasText && !hasImage && !unsupportedOnly;
}

abstract final class ScamShieldSharePayloadStore {
  static ScamShieldSharePayload? _pending;

  static void set(ScamShieldSharePayload payload) {
    _pending = payload;
  }

  static ScamShieldSharePayload? peek() => _pending;

  static ScamShieldSharePayload? consume() {
    final payload = _pending;
    _pending = null;
    return payload;
  }
}
