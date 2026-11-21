import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Shared display helpers for profile-driven UI copy across screens.
abstract final class ProfileDisplayHelper {
  /// Two-letter initials from Firebase user display name or email.
  static String initials(User? user, {String fallback = 'R'}) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      final list = parts.toList();
      if (list.length >= 2) {
        return '${list.first[0]}${list[1][0]}'.toUpperCase();
      }
      if (list.first.length >= 2) {
        return list.first.substring(0, 2).toUpperCase();
      }
      return list.first[0].toUpperCase();
    }

    final email = user?.email?.trim();
    if (email != null && email.contains('@')) {
      final local = email.split('@').first;
      if (local.length >= 2) return local.substring(0, 2).toUpperCase();
      if (local.isNotEmpty) return local[0].toUpperCase();
    }

    return fallback;
  }

  /// First token of Firebase display name for concise AI greetings; empty if none.
  static String greetingName(User? user) {
    final displayName = user?.displayName?.trim();
    if (displayName == null || displayName.isEmpty) return '';
    final first = displayName.split(RegExp(r'\s+')).first.trim();
    return first.isEmpty ? '' : first;
  }

  /// Resolved hero/menu name: display name, else email local-part, else null.
  ///
  /// Never returns placeholder names like "Friend" — callers show prompts instead.
  static String? profileHeroName(User? user) {
    if (user == null) return null;

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user.email;
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first;
      final firstSegment = localPart.split(RegExp(r'[._-]')).first;
      if (firstSegment.isNotEmpty) {
        return firstSegment[0].toUpperCase() + firstSegment.substring(1);
      }
    }
    return null;
  }

  static String userName(User? user, {String fallback = ''}) {
    return profileHeroName(user) ?? fallback;
  }

  static String preferredAreaLabel(
    UserAIProfile? profile, {
    String fallback = 'Qatar',
  }) {
    final area = profile?.preferredArea.trim();
    if (area != null && area.isNotEmpty) return area;
    return fallback;
  }

  static String nationalityFlag(String nationality) {
    switch (nationality.toLowerCase().trim()) {
      case 'indian':
        return '🇮🇳';
      case 'pakistani':
        return '🇵🇰';
      case 'bangladeshi':
        return '🇧🇩';
      case 'filipino':
        return '🇵🇭';
      case 'nepali':
        return '🇳🇵';
      case 'kenyan':
        return '🇰🇪';
      case 'arabic':
      case 'qatari':
        return '🇶🇦';
      default:
        return '🌍';
    }
  }

  static String profileSubtitle(
    UserAIProfile? profile, {
    String locationFallback = 'Qatar',
  }) {
    final nationality = profile?.nationality.trim();
    final area = preferredAreaLabel(profile, fallback: locationFallback);
    final parts = <String>[];
    if (nationality != null && nationality.isNotEmpty) {
      parts.add('${nationalityFlag(nationality)} $nationality');
    }
    parts.add('$area, Qatar');
    return parts.join(' · ');
  }

  static String nearYouTitle(String area) {
    final trimmed = area.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'qatar') {
      return 'Near You';
    }
    return 'Near $trimmed';
  }

  static String coverageLabel(UserAIProfile? profile) {
    final area = profile?.preferredArea.trim();
    if (area != null && area.isNotEmpty) return '$area + Qatar';
    return 'Qatar';
  }

  static String formatCount(int value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      return thousands >= 10
          ? '${thousands.round()}K+'
          : '${thousands.toStringAsFixed(1).replaceAll('.0', '')}K+';
    }
    return value.toString();
  }

  static List<({String name, int count})> topAreasByCount(
    Iterable<String> areas, {
    int limit = 5,
  }) {
    final counts = <String, int>{};
    for (final raw in areas) {
      final name = raw.trim();
      if (name.isEmpty) continue;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(limit)
        .map((e) => (name: e.key, count: e.value))
        .toList();
  }
}
