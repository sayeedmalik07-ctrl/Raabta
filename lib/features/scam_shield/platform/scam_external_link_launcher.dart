import 'package:url_launcher/url_launcher.dart';

/// Small reusable launcher for ScamShield external links and phone numbers.
abstract final class ScamExternalLinkLauncher {
  static Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> dialPhone(String phoneNumber) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$normalized');
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri);
  }
}
