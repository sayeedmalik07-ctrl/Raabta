import 'package:raabta/config/app_config.dart';

/// Shareable referral URLs — same host pattern as listing deep links.
abstract final class ReferralDeepLinks {
  static const invitePathPrefix = '/invite/';

  static String invite(String referralCode) =>
      '${AppConfig.publicWebsiteUrl}$invitePathPrefix$referralCode';

  static String? parseCodeFromUri(Uri uri) {
    if (uri.scheme == 'raabta' && uri.host == 'invite') {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) return _normalizeCode(segments.first);
      return _normalizeCode(uri.path.replaceFirst('/', ''));
    }

    if (uri.scheme == 'raabta' && uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.first == 'invite' && uri.pathSegments.length >= 2) {
        return _normalizeCode(uri.pathSegments[1]);
      }
    }

    final host = uri.host.toLowerCase();
    final isRaabtaHost = host == AppConfig.publicWebsiteHost ||
        host.endsWith('.${AppConfig.publicWebsiteHost}');

    if (isRaabtaHost && uri.path.startsWith(invitePathPrefix)) {
      final code = uri.path.substring(invitePathPrefix.length);
      if (code.isNotEmpty && !code.contains('/')) {
        return _normalizeCode(code);
      }
    }

    final ref = uri.queryParameters['ref'];
    if (ref != null && ref.trim().isNotEmpty) {
      return _normalizeCode(ref.trim());
    }

    return null;
  }

  static String? _normalizeCode(String raw) {
    final code = raw.trim().toUpperCase();
    if (code.length < 4 || code.length > 12) return null;
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(code)) return null;
    return code;
  }
}
