import 'package:raabta/features/scam_shield/scam_shield_config.dart';
import 'package:share_handler/share_handler.dart';

/// OS share limits and parsing (no I/O).
abstract final class ScamShieldShareLimits {
  static const maxSharedImages = 3;
}

/// Synchronous parse plan before adopting images into app-owned temp files.
class ScamShieldShareMediaParsePlan {
  const ScamShieldShareMediaParsePlan({
    this.sharedText,
    this.textWasTruncated = false,
    this.imageSourcePaths = const [],
    this.droppedExtraImageCount = 0,
    this.unsupportedAttachmentCount = 0,
    this.unsupportedOnly = false,
  });

  final String? sharedText;
  final bool textWasTruncated;
  final List<String> imageSourcePaths;
  final int droppedExtraImageCount;
  final int unsupportedAttachmentCount;
  final bool unsupportedOnly;

  bool get hasText => sharedText != null && sharedText!.trim().isNotEmpty;

  bool get hasImages => imageSourcePaths.isNotEmpty;

  bool get isRoutable => hasText || hasImages || unsupportedOnly;
}

abstract final class ScamShieldShareMediaParser {
  static ScamShieldShareMediaParsePlan parse({
    required String? rawContent,
    required List<SharedAttachment?>? attachments,
  }) {
    final clamped = _clampSharedText(rawContent);

    final imagePaths = <String>[];
    var unsupported = 0;

    for (final attachment in attachments ?? const []) {
      if (attachment == null) continue;
      final path = attachment.path.trim();
      if (path.isEmpty) continue;

      switch (attachment.type) {
        case SharedAttachmentType.image:
          imagePaths.add(path);
        case SharedAttachmentType.file:
        case SharedAttachmentType.video:
        case SharedAttachmentType.audio:
          unsupported++;
      }
    }

    final keptImages = imagePaths.length > ScamShieldShareLimits.maxSharedImages
        ? imagePaths.sublist(0, ScamShieldShareLimits.maxSharedImages)
        : List<String>.from(imagePaths);
    final droppedImages = imagePaths.length - keptImages.length;

    final hasText = clamped.text != null && clamped.text!.isNotEmpty;
    final hasImages = keptImages.isNotEmpty;
    final unsupportedOnly = !hasText && !hasImages && unsupported > 0;

    return ScamShieldShareMediaParsePlan(
      sharedText: clamped.text,
      textWasTruncated: clamped.truncated,
      imageSourcePaths: keptImages,
      droppedExtraImageCount: droppedImages,
      unsupportedAttachmentCount: unsupported,
      unsupportedOnly: unsupportedOnly,
    );
  }

  static ({String? text, bool truncated}) _clampSharedText(String? raw) {
    if (raw == null) return (text: null, truncated: false);
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return (text: null, truncated: false);
    final max = ScamShieldConfig.maxInputChars;
    if (trimmed.length <= max) {
      return (text: trimmed, truncated: false);
    }
    return (text: trimmed.substring(0, max), truncated: true);
  }

  /// Applies the same cap when OCR or manual edits inject long text on share review.
  static ({String text, bool truncated}) clampTextForShareInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return (text: '', truncated: false);
    final max = ScamShieldConfig.maxInputChars;
    if (trimmed.length <= max) {
      return (text: trimmed, truncated: false);
    }
    return (text: trimmed.substring(0, max), truncated: true);
  }
}
