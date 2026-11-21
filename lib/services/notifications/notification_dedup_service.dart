import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/services/notifications/notification_type.dart';

/// Rolling dedup store — survives app restarts (24–48h per type).
class NotificationDedupService {
  NotificationDedupService._();
  static final NotificationDedupService instance = NotificationDedupService._();

  static const _boxName = 'notification_dedup_v1';
  Box<dynamic>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await _ensureHiveInitialized();
        _box = await Hive.openBox<dynamic>(_boxName);
      } else {
        _box = Hive.box<dynamic>(_boxName);
      }
    } catch (e) {
      debugPrint('NotificationDedupService Hive init failed: $e');
    }
  }

  static bool _hiveCoreReady = false;

  static Future<void> _ensureHiveInitialized() async {
    if (_hiveCoreReady) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      Hive.init('raabta_hive');
    }
    _hiveCoreReady = true;
  }

  /// Key: `{type}|{referenceId}|{dayBucket}` per spec.
  String buildKey({
    required String notificationType,
    required String referenceId,
    DateTime? at,
  }) {
    final dt = at ?? DateTime.now();
    final bucket = '${dt.year}-${dt.month}-${dt.day}';
    return '$notificationType|$referenceId|$bucket';
  }

  Future<bool> isDuplicate({
    required String dedupKey,
    required Duration window,
  }) async {
    await init();
    final box = _box;
    if (box == null) return false;

    final raw = box.get(dedupKey);
    if (raw == null) return false;
    final last = DateTime.tryParse(raw.toString());
    if (last == null) return false;
    return DateTime.now().difference(last) < window;
  }

  Future<void> record(String dedupKey) async {
    await init();
    await _box?.put(dedupKey, DateTime.now().toIso8601String());
    await _purgeExpired();
  }

  Duration dedupWindowFor(String apiKey) {
    for (final m in NotificationTypeRegistry.all) {
      if (m.apiKey == apiKey) {
        return Duration(hours: m.dedupTtlHours);
      }
    }
    return const Duration(hours: 24);
  }

  Future<void> _purgeExpired() async {
    final box = _box;
    if (box == null) return;
    final now = DateTime.now();
    final toDelete = <dynamic>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      final ts = DateTime.tryParse(raw?.toString() ?? '');
      if (ts == null || now.difference(ts) > const Duration(hours: 48)) {
        toDelete.add(key);
      }
    }
    for (final k in toDelete) {
      await box.delete(k);
    }
  }
}
