import 'package:raabta/features/community/domain/rumour_check/rumour_check_config.dart';

/// Ask Qatar question kind — missing or unknown values map to [standard].
enum AskQatarQuestionKind {
  standard,
  rumourCheck,
}

enum RumourCategory {
  visa,
  labour,
  housing,
  fees,
  health,
  other,
}

enum RumourDisplayStatus {
  open,
  contextAdded,
  communityVerified,
}

/// Result of deterministic official-source URL validation (host only, no redirects).
enum RumourOfficialSourceOutcome {
  /// HTTPS host matches the official directory allowlist.
  officialAllowlisted,

  /// Parseable HTTPS URL but host is not allowlisted and not a known lookalike.
  unverified,

  /// Malformed URL, non-HTTPS, credentials, empty host, etc.
  rejectedInvalid,

  /// Known lookalike / deceptive host pattern (not allowlisted).
  rejectedDeceptive,
}

abstract final class RumourCheckModelParsing {
  static AskQatarQuestionKind questionKindFromStored(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return AskQatarQuestionKind.standard;
    if (trimmed == RumourCheckConfig.rumourCheckKind) {
      return AskQatarQuestionKind.rumourCheck;
    }
    return AskQatarQuestionKind.standard;
  }

  static String questionKindToStored(AskQatarQuestionKind kind) {
    return switch (kind) {
      AskQatarQuestionKind.standard => RumourCheckConfig.standardQuestionKind,
      AskQatarQuestionKind.rumourCheck => RumourCheckConfig.rumourCheckKind,
    };
  }

  static RumourCategory? categoryFromId(String? raw) {
    final id = raw?.trim().toLowerCase() ?? '';
    if (id.isEmpty) return null;
    for (final category in RumourCategory.values) {
      if (category.name == id) return category;
    }
    return null;
  }

  static String categoryToId(RumourCategory category) => category.name;

  static String displayStatusToToken(RumourDisplayStatus status) {
    return switch (status) {
      RumourDisplayStatus.open => RumourCheckConfig.statusOpen,
      RumourDisplayStatus.contextAdded => RumourCheckConfig.statusContextAdded,
      RumourDisplayStatus.communityVerified =>
        RumourCheckConfig.statusCommunityVerified,
    };
  }
}
