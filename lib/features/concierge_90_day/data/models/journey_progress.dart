import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';

class MilestoneProgressEntry {
  const MilestoneProgressEntry({
    required this.status,
    this.completedAt,
  });

  final MilestoneStatus status;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() => {
        'status': status.name,
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      };

  factory MilestoneProgressEntry.fromJson(Map<String, dynamic> json) {
    return MilestoneProgressEntry(
      status: MilestoneStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MilestoneStatus.pending,
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}

class JourneyProgress {
  const JourneyProgress({
    this.arrivalDate,
    this.arrivalDateSkipped = false,
    this.accountCreatedAt,
    this.conciergeDisabled = false,
    this.milestones = const {},
    this.lastNotifiedMilestoneId,
    this.journeyCompleted = false,
  });

  final DateTime? arrivalDate;
  final bool arrivalDateSkipped;
  final DateTime? accountCreatedAt;
  final bool conciergeDisabled;
  final Map<String, MilestoneProgressEntry> milestones;
  final String? lastNotifiedMilestoneId;
  final bool journeyCompleted;

  DateTime? get timelineAnchor =>
      arrivalDate ?? accountCreatedAt;

  MilestoneStatus statusFor(JourneyMilestoneId id) =>
      milestones[id.name]?.status ?? MilestoneStatus.pending;

  JourneyProgress copyWith({
    DateTime? arrivalDate,
    bool? arrivalDateSkipped,
    DateTime? accountCreatedAt,
    bool? conciergeDisabled,
    Map<String, MilestoneProgressEntry>? milestones,
    String? lastNotifiedMilestoneId,
    bool? journeyCompleted,
    bool clearArrivalDate = false,
  }) {
    return JourneyProgress(
      arrivalDate: clearArrivalDate ? null : (arrivalDate ?? this.arrivalDate),
      arrivalDateSkipped: arrivalDateSkipped ?? this.arrivalDateSkipped,
      accountCreatedAt: accountCreatedAt ?? this.accountCreatedAt,
      conciergeDisabled: conciergeDisabled ?? this.conciergeDisabled,
      milestones: milestones ?? this.milestones,
      lastNotifiedMilestoneId:
          lastNotifiedMilestoneId ?? this.lastNotifiedMilestoneId,
      journeyCompleted: journeyCompleted ?? this.journeyCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        if (arrivalDate != null) 'arrivalDate': arrivalDate!.toIso8601String(),
        'arrivalDateSkipped': arrivalDateSkipped,
        if (accountCreatedAt != null)
          'accountCreatedAt': accountCreatedAt!.toIso8601String(),
        'conciergeDisabled': conciergeDisabled,
        'milestones': milestones.map((k, v) => MapEntry(k, v.toJson())),
        if (lastNotifiedMilestoneId != null)
          'lastNotifiedMilestoneId': lastNotifiedMilestoneId,
        'journeyCompleted': journeyCompleted,
      };

  factory JourneyProgress.fromJson(Map<String, dynamic> json) {
    final raw = json['milestones'] as Map<String, dynamic>? ?? {};
    return JourneyProgress(
      arrivalDate: json['arrivalDate'] != null
          ? DateTime.tryParse(json['arrivalDate'] as String)
          : null,
      arrivalDateSkipped: json['arrivalDateSkipped'] as bool? ?? false,
      accountCreatedAt: json['accountCreatedAt'] != null
          ? DateTime.tryParse(json['accountCreatedAt'] as String)
          : null,
      conciergeDisabled: json['conciergeDisabled'] as bool? ?? false,
      milestones: raw.map(
        (k, v) => MapEntry(
          k,
          MilestoneProgressEntry.fromJson(v as Map<String, dynamic>),
        ),
      ),
      lastNotifiedMilestoneId: json['lastNotifiedMilestoneId'] as String?,
      journeyCompleted: json['journeyCompleted'] as bool? ?? false,
    );
  }
}
