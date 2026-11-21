import 'package:mobile_scanner/mobile_scanner.dart';

/// On-device QR decode from a picked image — reuses [mobile_scanner].
abstract final class MarketplaceQrImageDecoder {
  static Future<String?> decodePayload(String imagePath) async {
    final controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );
    try {
      final capture = await controller.analyzeImage(imagePath);
      if (capture == null) return null;
      for (final barcode in capture.barcodes) {
        final raw = barcode.rawValue?.trim();
        if (raw != null && raw.isNotEmpty) return raw;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      await controller.dispose();
    }
  }
}
