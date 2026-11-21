/// How an evidence photo was attached — affects integrity labeling in UI/PDF.
enum EvidenceAttachmentCaptureSource {
  inAppCamera,
  gallery,
}

extension EvidenceAttachmentCaptureSourceJson on EvidenceAttachmentCaptureSource {
  String get storageValue => switch (this) {
        EvidenceAttachmentCaptureSource.inAppCamera => 'in_app_camera',
        EvidenceAttachmentCaptureSource.gallery => 'gallery',
      };

  static EvidenceAttachmentCaptureSource? fromStorage(String? value) {
    switch (value) {
      case 'in_app_camera':
        return EvidenceAttachmentCaptureSource.inAppCamera;
      case 'gallery':
        return EvidenceAttachmentCaptureSource.gallery;
      default:
        return null;
    }
  }
}

/// Plain capture metadata — honest labels, no cryptographic proofing.
class EvidenceAttachmentMetadata {
  const EvidenceAttachmentMetadata({
    this.captureSource,
    this.capturedAt,
    this.capturedLatitude,
    this.capturedLongitude,
    this.uploadedAt,
  });

  final EvidenceAttachmentCaptureSource? captureSource;
  final DateTime? capturedAt;
  final double? capturedLatitude;
  final double? capturedLongitude;
  final DateTime? uploadedAt;

  bool get hasLocation =>
      capturedLatitude != null && capturedLongitude != null;

  /// One-line label for UI and PDF export.
  String displayLine({DateTime? fallbackRecordedAt}) {
    if (captureSource == EvidenceAttachmentCaptureSource.gallery) {
      final when = uploadedAt ?? fallbackRecordedAt;
      if (when == null) {
        return 'Uploaded · capture time not verified';
      }
      return 'Uploaded ${_formatDateTime(when)} · capture time not verified';
    }

    if (captureSource == EvidenceAttachmentCaptureSource.inAppCamera) {
      if (capturedAt == null) return 'Captured · location not available';
      final location = hasLocation
          ? _formatCoordinates(capturedLatitude!, capturedLongitude!)
          : 'location not available';
      return 'Captured ${_formatDateTime(capturedAt!)} · $location';
    }

    return '';
  }

  static String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final date =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  static String _formatCoordinates(double lat, double lng) {
    final latHem = lat >= 0 ? 'N' : 'S';
    final lngHem = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}°$latHem, ${lng.abs().toStringAsFixed(4)}°$lngHem';
  }
}
