import 'package:raabta/features/scam_shield/domain/official_directory_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_proactive_protection_platform.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_freshness_thresholds.dart';
import 'package:raabta/features/scam_shield/shield_status/shield_status_models.dart';

/// Pure derivation for shield status rows (Phase 31).
abstract final class ShieldStatusDeriver {
  static ShieldStatusSnapshot derive({
    required ScamProactiveProtectionStatus proactive,
    required bool osNotificationsGranted,
    required bool scamAdvisoryAlertEnabled,
    required bool securityTipEnabled,
    required bool securityTodayCardsEnabled,
    required int checkupDone,
    required int checkupTotal,
    required bool familyKitConfigured,
    required bool myBankSaved,
    required List<OfficialDirectoryEntry> directoryEntries,
    required DateTime? latestAdvisoryPublished,
    required DateTime legalSourcesUpdated,
    required DateTime clock,
  }) {
    final freshness = _freshness(
      directoryEntries: directoryEntries,
      latestAdvisoryPublished: latestAdvisoryPublished,
      legalSourcesUpdated: legalSourcesUpdated,
      clock: clock,
    );

    final rows = <ShieldStatusRow>[];

    if (proactive.supportsCallScreening) {
      rows.add(
        ShieldStatusRow(
          id: ShieldRowId.callScreening,
          section: ShieldStatusSectionId.onYourPhone,
          state: proactive.callScreeningActive
              ? ShieldRowState.on
              : ShieldRowState.off,
          countsTowardTotal: true,
        ),
      );
    }

    if (proactive.supportsSmsFilterGuide) {
      rows.add(
        ShieldStatusRow(
          id: ShieldRowId.smsFilterGuide,
          section: ShieldStatusSectionId.onYourPhone,
          state: proactive.smsFilterUserConfirmed
              ? ShieldRowState.selfReported
              : ShieldRowState.off,
          countsTowardTotal: true,
        ),
      );
    }

    rows.addAll([
      ShieldStatusRow(
        id: ShieldRowId.scamAdvisoryAlert,
        section: ShieldStatusSectionId.alerts,
        state: scamAdvisoryAlertEnabled
            ? ShieldRowState.on
            : ShieldRowState.off,
        countsTowardTotal: true,
      ),
      ShieldStatusRow(
        id: ShieldRowId.securityTip,
        section: ShieldStatusSectionId.alerts,
        state:
            securityTipEnabled ? ShieldRowState.on : ShieldRowState.off,
        countsTowardTotal: true,
      ),
      ShieldStatusRow(
        id: ShieldRowId.todayCards,
        section: ShieldStatusSectionId.alerts,
        state: securityTodayCardsEnabled
            ? ShieldRowState.on
            : ShieldRowState.off,
        countsTowardTotal: true,
      ),
      ShieldStatusRow(
        id: ShieldRowId.osNotifications,
        section: ShieldStatusSectionId.alerts,
        state: _osNotificationState(
          granted: osNotificationsGranted,
          anyAlertEnabled: scamAdvisoryAlertEnabled ||
              securityTipEnabled ||
              securityTodayCardsEnabled,
        ),
        countsTowardTotal: scamAdvisoryAlertEnabled ||
            securityTipEnabled ||
            securityTodayCardsEnabled,
      ),
      ShieldStatusRow(
        id: ShieldRowId.checkup,
        section: ShieldStatusSectionId.habits,
        state: _checkupState(checkupDone, checkupTotal),
        countsTowardTotal: checkupTotal > 0,
        detailKey: 'ss_checkup_progress',
        detailArgs: {
          'done': '$checkupDone',
          'total': '$checkupTotal',
        },
      ),
      ShieldStatusRow(
        id: ShieldRowId.familyKit,
        section: ShieldStatusSectionId.habits,
        state: familyKitConfigured ? ShieldRowState.on : ShieldRowState.off,
        countsTowardTotal: true,
      ),
      ShieldStatusRow(
        id: ShieldRowId.myBank,
        section: ShieldStatusSectionId.habits,
        state: myBankSaved ? ShieldRowState.on : ShieldRowState.off,
        countsTowardTotal: true,
      ),
      ShieldStatusRow(
        id: ShieldRowId.directoryFreshness,
        section: ShieldStatusSectionId.dataFreshness,
        state: ShieldRowState.informational,
        countsTowardTotal: false,
      ),
      ShieldStatusRow(
        id: ShieldRowId.advisoryFreshness,
        section: ShieldStatusSectionId.dataFreshness,
        state: ShieldRowState.informational,
        countsTowardTotal: false,
      ),
      ShieldStatusRow(
        id: ShieldRowId.legalFreshness,
        section: ShieldStatusSectionId.dataFreshness,
        state: ShieldRowState.informational,
        countsTowardTotal: false,
      ),
      ShieldStatusRow(
        id: ShieldRowId.offlineCoreChecks,
        section: ShieldStatusSectionId.alwaysAvailable,
        state: ShieldRowState.informational,
        countsTowardTotal: false,
      ),
      ShieldStatusRow(
        id: ShieldRowId.inCallAssistant,
        section: ShieldStatusSectionId.alwaysAvailable,
        state: ShieldRowState.informational,
        countsTowardTotal: false,
      ),
      ShieldStatusRow(
        id: ShieldRowId.shareToCheck,
        section: ShieldStatusSectionId.alwaysAvailable,
        state: ShieldRowState.informational,
        countsTowardTotal: false,
      ),
    ]);

    final countable = rows.where((r) => r.countsTowardTotal);
    final on = countable.where((r) => r.countsAsOn).length;
    final total = countable.length;

    return ShieldStatusSnapshot(
      rows: rows,
      protectionsOn: on,
      protectionsTotal: total,
      freshness: freshness,
    );
  }

  static ShieldRowState _osNotificationState({
    required bool granted,
    required bool anyAlertEnabled,
  }) {
    if (!anyAlertEnabled) {
      return granted ? ShieldRowState.on : ShieldRowState.off;
    }
    if (granted) return ShieldRowState.on;
    return ShieldRowState.needsAttention;
  }

  static ShieldRowState _checkupState(int done, int total) {
    if (total <= 0) return ShieldRowState.notAvailable;
    if (done >= total) return ShieldRowState.selfReported;
    if (done > 0) return ShieldRowState.needsAttention;
    return ShieldRowState.off;
  }

  static ShieldFreshnessSnapshot _freshness({
    required List<OfficialDirectoryEntry> directoryEntries,
    required DateTime? latestAdvisoryPublished,
    required DateTime legalSourcesUpdated,
    required DateTime clock,
  }) {
    DateTime? oldestVerified;
    for (final entry in directoryEntries) {
      final v = entry.lastVerified;
      if (v == null) continue;
      if (oldestVerified == null || v.isBefore(oldestVerified)) {
        oldestVerified = v;
      }
    }

    final directoryStale = oldestVerified != null &&
        clock.difference(oldestVerified).inDays >
            ShieldFreshnessThresholds.directoryStaleDays;

    final advisoryStale = latestAdvisoryPublished == null ||
        clock.difference(latestAdvisoryPublished).inDays > 90;

    final legalStale = clock.difference(legalSourcesUpdated).inDays > 365;

    return ShieldFreshnessSnapshot(
      directoryOldestVerified: oldestVerified,
      latestAdvisoryPublished: latestAdvisoryPublished,
      legalSourcesUpdated: legalSourcesUpdated,
      directoryMayBeStale: directoryStale,
      advisoryMayBeStale: advisoryStale,
      legalMayBeStale: legalStale,
    );
  }
}
