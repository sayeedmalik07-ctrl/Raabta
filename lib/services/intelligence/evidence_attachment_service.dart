import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/features/quick_actions/scanner/repositories/scanned_document_repository.dart';
import 'package:raabta/models/intelligence/evidence_attachment_metadata.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

/// Result of attaching a photo to an evidence entry.
class EvidencePhotoAttachment {
  const EvidencePhotoAttachment({
    required this.documentId,
    required this.captureSource,
    this.capturedAt,
    this.capturedLatitude,
    this.capturedLongitude,
    this.uploadedAt,
    this.localImagePath,
  });

  final String documentId;
  final EvidenceAttachmentCaptureSource captureSource;
  final DateTime? capturedAt;
  final double? capturedLatitude;
  final double? capturedLongitude;
  final DateTime? uploadedAt;
  final String? localImagePath;

  String get captureSourceValue => captureSource.storageValue;
}

/// Camera/gallery capture for Evidence Trail — one-shot location only, zero AI.
class EvidenceAttachmentService {
  EvidenceAttachmentService({
    ImagePicker? picker,
    ScannedDocumentRepository? documentRepository,
  })  : _picker = picker ?? ImagePicker(),
        _documents = documentRepository ?? ScannedDocumentRepository();

  final ImagePicker _picker;
  final ScannedDocumentRepository _documents;

  /// Gallery pick — no capture-time metadata; upload time only.
  Future<EvidencePhotoAttachment?> pickFromGallery({DateTime? now}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return null;

    final uploadedAt = now ?? DateTime.now();
    final documentId = await _saveToVault(
      imagePath: picked.path,
      label: 'Evidence photo (gallery)',
    );

    return EvidencePhotoAttachment(
      documentId: documentId,
      captureSource: EvidenceAttachmentCaptureSource.gallery,
      uploadedAt: uploadedAt,
      localImagePath: picked.path,
    );
  }

  /// In-app camera — records device timestamp; optional one-shot location.
  Future<EvidencePhotoAttachment?> captureFromCamera({
    required bool requestLocation,
    DateTime? now,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (picked == null) return null;

    final capturedAt = now ?? DateTime.now();
    double? latitude;
    double? longitude;

    if (requestLocation) {
      final position = await _captureLocationOnce();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      }
    }

    final documentId = await _saveToVault(
      imagePath: picked.path,
      label: 'Evidence photo (captured)',
    );

    return EvidencePhotoAttachment(
      documentId: documentId,
      captureSource: EvidenceAttachmentCaptureSource.inAppCamera,
      capturedAt: capturedAt,
      capturedLatitude: latitude,
      capturedLongitude: longitude,
      localImagePath: picked.path,
    );
  }

  /// Location captured once at photo moment — never background tracked.
  Future<Position?> _captureLocationOnce() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _saveToVault({
    required String imagePath,
    required String label,
  }) {
    return _documents.save(
      ScannedDocumentSaveRequest(
        classification: DocClassificationResult(
          docType: DocType.unknown,
          holderName: label,
          confidence: 1,
        ),
        imagePath: imagePath,
        ocrText: '',
        category: ScannedDocumentRepository.evidenceCategory,
        tags: [ScannedDocumentRepository.evidenceTag],
      ),
    );
  }
}
