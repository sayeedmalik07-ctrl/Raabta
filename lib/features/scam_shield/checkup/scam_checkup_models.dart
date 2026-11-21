import 'dart:io';

enum ScamCheckupGroup { whatsapp, phone, raabta, money }

enum ScamCheckupPlatformFilter { ios, android, both }

enum ScamCheckupDeepLink {
  none,
  openAppSettings,
  officialDirectory,
  callScreeningGuide,
  smsFilterGuide,
  personalContextSettings,
}

enum ScamCheckupPhase7StatusKey {
  callScreeningActive,
  smsFilterUserConfirmed,
}

class ScamCheckupItem {
  const ScamCheckupItem({
    required this.id,
    required this.group,
    required this.platform,
    required this.titleKey,
    required this.whyKey,
    required this.stepKeys,
    required this.deepLink,
    required this.verified,
    this.lastVerified,
    this.phase7StatusKey,
  });

  final String id;
  final ScamCheckupGroup group;
  final ScamCheckupPlatformFilter platform;
  final String titleKey;
  final String whyKey;
  final List<String> stepKeys;
  final ScamCheckupDeepLink deepLink;
  final bool verified;
  final DateTime? lastVerified;
  final ScamCheckupPhase7StatusKey? phase7StatusKey;

  bool get isVisibleOnCurrentPlatform {
    if (!verified || stepKeys.isEmpty) return false;
    return switch (platform) {
      ScamCheckupPlatformFilter.both => true,
      ScamCheckupPlatformFilter.ios => Platform.isIOS,
      ScamCheckupPlatformFilter.android => Platform.isAndroid,
    };
  }
}

class ScamCheckupProgress {
  const ScamCheckupProgress({required this.done, required this.total});

  final int done;
  final int total;

  bool get isComplete => total > 0 && done >= total;
}

class ScamCheckupState {
  const ScamCheckupState({
    this.checkedIds = const {},
    this.lastReviewAt,
    this.recheckBannerDismissedAt,
  });

  final Set<String> checkedIds;
  final DateTime? lastReviewAt;
  final DateTime? recheckBannerDismissedAt;

  ScamCheckupState copyWith({
    Set<String>? checkedIds,
    DateTime? lastReviewAt,
    DateTime? recheckBannerDismissedAt,
  }) {
    return ScamCheckupState(
      checkedIds: checkedIds ?? this.checkedIds,
      lastReviewAt: lastReviewAt ?? this.lastReviewAt,
      recheckBannerDismissedAt:
          recheckBannerDismissedAt ?? this.recheckBannerDismissedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'checkedIds': checkedIds.toList(),
        'lastReviewAt': lastReviewAt?.toIso8601String(),
        'recheckBannerDismissedAt':
            recheckBannerDismissedAt?.toIso8601String(),
      };

  factory ScamCheckupState.fromJson(Map<String, dynamic> json) {
    return ScamCheckupState(
      checkedIds: (json['checkedIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toSet(),
      lastReviewAt: DateTime.tryParse(json['lastReviewAt']?.toString() ?? ''),
      recheckBannerDismissedAt: DateTime.tryParse(
        json['recheckBannerDismissedAt']?.toString() ?? '',
      ),
    );
  }
}
