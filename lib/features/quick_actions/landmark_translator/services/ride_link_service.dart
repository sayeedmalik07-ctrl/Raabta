import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class RideLinkService {
  RideLinkService._();

  /// Google Maps search — works for navigation on iOS/Android/desktop browsers.
  static Future<bool> openInMaps(String destinationQuery) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${Uri.encodeComponent(destinationQuery)}',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> isUberInstalled() async {
    try {
      return await canLaunchUrl(Uri.parse('uber://'));
    } catch (_) {
      return false;
    }
  }

  /// Uber deep link when installed; otherwise copies Arabic for manual paste.
  static Future<RideLinkResult> openInUber({
    required String destinationQuery,
    required String arabicText,
  }) async {
    final uberUri = Uri.parse(
      'uber://?action=setPickup'
      '&dropoff[formatted_address]='
      '${Uri.encodeComponent(destinationQuery)}',
    );

    try {
      if (await canLaunchUrl(uberUri)) {
        await launchUrl(uberUri, mode: LaunchMode.externalApplication);
        return RideLinkResult.uberOpened;
      }
    } catch (_) {}

    await copyArabicAddress(arabicText);
    return RideLinkResult.copiedToClipboard;
  }

  static Future<void> copyArabicAddress(String arabicText) async {
    await Clipboard.setData(ClipboardData(text: arabicText));
  }
}

enum RideLinkResult {
  uberOpened,
  copiedToClipboard,
  mapsOpened,
}
