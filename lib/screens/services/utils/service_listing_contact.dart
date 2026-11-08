import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp for a service listing (provider offer or customer request).
Future<bool> contactServiceProviderWhatsApp({
  required String phone,
  required String serviceTitle,
  required String providerName,
  bool isServiceRequest = false,
}) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return false;

  final name = providerName.trim().isEmpty ? 'there' : providerName.trim();
  final plain = isServiceRequest
      ? 'Hi $name, I saw your "$serviceTitle" request on Raabta and would like to help.'
      : 'Hi $name, I saw your "$serviceTitle" listing on Raabta. Is it still available?';
  final message = Uri.encodeComponent(plain);
  final uri = Uri.parse('https://wa.me/$digits?text=$message');
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return false;
}

Future<bool> callServiceProvider(String phone) async {
  final uri = Uri.parse('tel:$phone');
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri);
  }
  return false;
}
