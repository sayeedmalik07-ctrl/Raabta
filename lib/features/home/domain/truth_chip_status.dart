import 'package:flutter/foundation.dart';

/// Truth Engine identity for Know your rights Home chips.
enum TruthChipEngine {
  eosb,
  sponsorshipTransfer,
  tenancy,
  healthInsurance,
}

/// Lifecycle state for a Truth chip (derived from saved engine data only).
enum TruthChipState {
  invite,
  tracked,
  attention,
  urgent,
  stale,

  /// Truth chip provider failed — not empty-data invite.
  unavailable,
}

/// Surface tone for status line, pill, and progress (not color-only semantics).
enum TruthChipTone {
  neutral,
  ok,
  amber,
  red,
}

extension TruthChipEngineRoutes on TruthChipEngine {
  String get homeRoute => switch (this) {
        TruthChipEngine.eosb => '/eosb',
        TruthChipEngine.sponsorshipTransfer => '/sponsorship-transfer',
        TruthChipEngine.tenancy => '/tenancy',
        TruthChipEngine.healthInsurance => '/health-insurance',
      };

  static TruthChipEngine? fromHomeRoute(String route) {
    return switch (route) {
      '/eosb' => TruthChipEngine.eosb,
      '/sponsorship-transfer' => TruthChipEngine.sponsorshipTransfer,
      '/tenancy' => TruthChipEngine.tenancy,
      '/health-insurance' => TruthChipEngine.healthInsurance,
      _ => null,
    };
  }
}

/// Immutable derived status for one Truth Engine chip on Home.
///
/// Built by per-engine pure mappers (Part A); consumed by [HomeEssentialToolCard]
/// after UI batch B extends the chip anatomy.
@immutable
class TruthChipStatus {
  const TruthChipStatus({
    required this.engine,
    required this.state,
    required this.tone,
    required this.titleKey,
    required this.statusText,
    required this.freshnessText,
    required this.deepLink,
    this.revealedText,
    this.pillText,
    this.progress,
    this.isLoading = false,
  });

  const TruthChipStatus.loading({
    required this.engine,
    required this.titleKey,
    required this.deepLink,
  })  : state = TruthChipState.invite,
        tone = TruthChipTone.neutral,
        statusText = '',
        freshnessText = '',
        revealedText = null,
        pillText = null,
        progress = null,
        isLoading = true;

  const TruthChipStatus.unavailable({
    required this.engine,
    required this.titleKey,
    required this.statusText,
    required this.deepLink,
  })  : state = TruthChipState.unavailable,
        tone = TruthChipTone.neutral,
        freshnessText = '',
        revealedText = null,
        pillText = null,
        progress = null,
        isLoading = false;

  final TruthChipEngine engine;
  final TruthChipState state;
  final TruthChipTone tone;
  final String titleKey;

  /// Hidden-safe primary status line (no salary, names, or exact money by default).
  final String statusText;

  /// Shown only when the section eye reveal is active.
  final String? revealedText;

  final String? pillText;

  /// Progress through a window (0.0–1.0), e.g. service year or lease term.
  final double? progress;

  /// One-line provenance, e.g. "From your lease entry".
  final String freshnessText;

  /// Primary navigation target ([TruthChipEngine.homeRoute] or a deeper engine path).
  final String deepLink;

  final bool isLoading;

  bool get isInvite =>
      state == TruthChipState.invite && !isLoading && !isUnavailable;

  bool get isUnavailable => state == TruthChipState.unavailable;

  bool get hasRevealableDetail =>
      revealedText != null && revealedText!.trim().isNotEmpty;

  bool get showsPill =>
      !isInvite &&
      !isUnavailable &&
      pillText != null &&
      pillText!.trim().isNotEmpty;

  bool get showsProgressBar =>
      !isInvite &&
      !isUnavailable &&
      progress != null &&
      state != TruthChipState.stale;

  /// Attention count for section header — urgent + attention, never stale-only.
  bool get countsTowardAttentionBadge =>
      state == TruthChipState.attention || state == TruthChipState.urgent;
}
