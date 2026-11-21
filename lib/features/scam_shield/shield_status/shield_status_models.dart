enum ShieldRowState {
  on,
  off,
  notAvailable,
  needsAttention,
  selfReported,
  informational,
}

enum ShieldRowId {
  callScreening,
  smsFilterGuide,
  scamAdvisoryAlert,
  securityTip,
  todayCards,
  osNotifications,
  checkup,
  familyKit,
  myBank,
  directoryFreshness,
  advisoryFreshness,
  legalFreshness,
  offlineCoreChecks,
  inCallAssistant,
  shareToCheck,
}

enum ShieldStatusSectionId {
  onYourPhone,
  alerts,
  habits,
  dataFreshness,
  alwaysAvailable,
}

class ShieldStatusRow {
  const ShieldStatusRow({
    required this.id,
    required this.section,
    required this.state,
    required this.countsTowardTotal,
    this.detailKey,
    this.detailArgs,
  });

  final ShieldRowId id;
  final ShieldStatusSectionId section;
  final ShieldRowState state;
  final bool countsTowardTotal;
  final String? detailKey;
  final Map<String, String>? detailArgs;

  bool get countsAsOn {
    if (!countsTowardTotal) return false;
    return switch (state) {
      ShieldRowState.on => true,
      ShieldRowState.selfReported =>
        id == ShieldRowId.checkup || id == ShieldRowId.smsFilterGuide,
      _ => false,
    };
  }
}

class ShieldFreshnessSnapshot {
  const ShieldFreshnessSnapshot({
    this.directoryOldestVerified,
    this.latestAdvisoryPublished,
    this.legalSourcesUpdated,
    this.directoryMayBeStale = false,
    this.advisoryMayBeStale = false,
    this.legalMayBeStale = false,
  });

  final DateTime? directoryOldestVerified;
  final DateTime? latestAdvisoryPublished;
  final DateTime? legalSourcesUpdated;
  final bool directoryMayBeStale;
  final bool advisoryMayBeStale;
  final bool legalMayBeStale;
}

class ShieldStatusSnapshot {
  const ShieldStatusSnapshot({
    required this.rows,
    required this.protectionsOn,
    required this.protectionsTotal,
    required this.freshness,
  });

  final List<ShieldStatusRow> rows;
  final int protectionsOn;
  final int protectionsTotal;
  final ShieldFreshnessSnapshot freshness;

  Iterable<ShieldStatusRow> rowsInSection(ShieldStatusSectionId section) =>
      rows.where((r) => r.section == section);
}
