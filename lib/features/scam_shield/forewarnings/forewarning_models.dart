import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';

enum ForewarningCtaTarget {
  none,
  paymentCheck,
  officialDirectory,
  agencyVerification,
}

class ForewarningVariantRef {
  const ForewarningVariantRef({required this.reuseKey});

  final String reuseKey;
}

class ForewarningMomentDefinition {
  const ForewarningMomentDefinition({
    required this.id,
    required this.sourceLabel,
    required this.variants,
    this.requiresFlag,
    this.ctaTarget = ForewarningCtaTarget.none,
    this.advisoryCategory,
  });

  final ForewarningMomentId id;
  final String sourceLabel;
  final List<ForewarningVariantRef> variants;
  final String? requiresFlag;
  final ForewarningCtaTarget ctaTarget;
  final String? advisoryCategory;
}

class ForewarningMomentState {
  const ForewarningMomentState({
    this.lastShown,
    this.shownCount = 0,
    this.dismissCount = 0,
    this.lastVariantIndex = -1,
    this.snoozedUntil,
  });

  final DateTime? lastShown;
  final int shownCount;
  final int dismissCount;
  final int lastVariantIndex;
  final DateTime? snoozedUntil;

  ForewarningMomentState copyWith({
    DateTime? lastShown,
    int? shownCount,
    int? dismissCount,
    int? lastVariantIndex,
    DateTime? snoozedUntil,
    bool clearSnooze = false,
  }) {
    return ForewarningMomentState(
      lastShown: lastShown ?? this.lastShown,
      shownCount: shownCount ?? this.shownCount,
      dismissCount: dismissCount ?? this.dismissCount,
      lastVariantIndex: lastVariantIndex ?? this.lastVariantIndex,
      snoozedUntil: clearSnooze ? null : (snoozedUntil ?? this.snoozedUntil),
    );
  }

  Map<String, dynamic> toJson() => {
        'lastShown': lastShown?.toIso8601String(),
        'shownCount': shownCount,
        'dismissCount': dismissCount,
        'lastVariantIndex': lastVariantIndex,
        'snoozedUntil': snoozedUntil?.toIso8601String(),
      };

  factory ForewarningMomentState.fromJson(Map<String, dynamic> json) {
    return ForewarningMomentState(
      lastShown: _parse(json['lastShown']),
      shownCount: json['shownCount'] as int? ?? 0,
      dismissCount: json['dismissCount'] as int? ?? 0,
      lastVariantIndex: json['lastVariantIndex'] as int? ?? -1,
      snoozedUntil: _parse(json['snoozedUntil']),
    );
  }

  static DateTime? _parse(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }
}

class ForewarningResolvedContent {
  const ForewarningResolvedContent({
    required this.body,
    required this.sourceLabel,
    this.advisoryLine,
    this.ctaTarget = ForewarningCtaTarget.none,
  });

  final String body;
  final String sourceLabel;
  final String? advisoryLine;
  final ForewarningCtaTarget ctaTarget;
}
