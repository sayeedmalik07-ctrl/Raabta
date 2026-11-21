import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_repository.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_repository.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/legal_sources/domain/models/legal_source.dart';
import 'package:raabta/services/notifications/notification_copy_strings.dart';
import 'package:raabta/services/notifications/notification_preferences_service.dart';
import 'package:raabta/services/smart_notification_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side legal-source update alerts for locally cached calculations.
abstract final class LegalUpdateNotificationService {
  static const _lastNotifiedKey = 'legal_update_last_notified_key';

  static const _visaSourceIds = {
    'law_21_2015',
    'law_19_2020',
    'moi_decree_51_2020',
  };

  static const _healthSourceIds = {
    'law_22_2021',
    'moph_insurers',
  };

  static Future<void> checkAndNotifyIfNeeded({
    LegalSourcesRepository? legalRepo,
    EosbRepository? eosbRepo,
    HealthInsuranceRepository? healthRepo,
  }) async {
    final legal = legalRepo ?? LegalSourcesRepository();
    final sources = await legal.fetchAll();
    final latestKey = _latestVerifiedKey(sources);
    if (latestKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_lastNotifiedKey) == latestKey) return;

    final latestDate = await legal.latestVerifiedDate();
    final prefsService = await createNotificationPreferencesService();
    final lang = (await prefsService.getSettings()).notificationLanguage;

    var notified = false;

    if (await _eosbNeedsUpdate(latestDate, eosbRepo)) {
      await SmartNotificationEngine.instance.notifyLegalSourceUpdate(
        dedupKey: 'legal_update_eosb_$latestKey',
        title: NotificationCopyStrings.t('legal_source_update_title', lang),
        body: NotificationCopyStrings.t('legal_source_update_eosb_body', lang),
        route: '/eosb/result?legalUpdate=1',
        domain: 'eosb',
      );
      notified = true;
    }

    if (_sourcesChanged(sources, _healthSourceIds) &&
        (healthRepo?.loadCachedResult()?.checkedAt.isBefore(latestDate) ??
            false)) {
      await SmartNotificationEngine.instance.notifyLegalSourceUpdate(
        dedupKey: 'legal_update_hi_$latestKey',
        title: NotificationCopyStrings.t('legal_source_update_title', lang),
        body: NotificationCopyStrings.t('legal_source_update_hi_body', lang),
        route: '/health-insurance/compliance/results',
        domain: 'health',
      );
      notified = true;
    }

    if (_sourcesChanged(sources, _visaSourceIds)) {
      await SmartNotificationEngine.instance.notifyLegalSourceUpdate(
        dedupKey: 'legal_update_visa_$latestKey',
        title: NotificationCopyStrings.t('legal_source_update_title', lang),
        body: NotificationCopyStrings.t('legal_source_update_visa_body', lang),
        route: '/visa',
        domain: 'visa',
      );
      notified = true;
    }

    if (notified) {
      await prefs.setString(_lastNotifiedKey, latestKey);
    }
  }

  static String? _latestVerifiedKey(List<LegalSource> sources) {
    DateTime? latest;
    for (final s in sources) {
      if (s.status == LegalSourceStatus.superseded) continue;
      final v = s.dateLastVerified;
      if (v != null && (latest == null || v.isAfter(latest))) {
        latest = v;
      }
    }
    return latest?.toIso8601String().substring(0, 10);
  }

  static bool _sourcesChanged(List<LegalSource> sources, Set<String> ids) {
    for (final id in ids) {
      LegalSource? remote;
      for (final s in sources) {
        if (s.id == id) {
          remote = s;
          break;
        }
      }
      if (remote == null) continue;
      LegalSource? seed;
      for (final s in LegalSourcesSeedCatalog.defaults) {
        if (s.id == id) {
          seed = s;
          break;
        }
      }
      final seedDate = seed?.dateLastVerified;
      final remoteDate = remote.dateLastVerified;
      if (remoteDate != null &&
          seedDate != null &&
          remoteDate.isAfter(seedDate)) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _eosbNeedsUpdate(
    DateTime latestLegal,
    EosbRepository? eosbRepo,
  ) async {
    final repo =
        eosbRepo ?? EosbRepository(await SharedPreferences.getInstance());
    final history = await repo.loadHistory();
    if (history.isEmpty) return false;
    final latest = history.first.result.calculatedAt;
    return latest.isBefore(latestLegal);
  }
}
