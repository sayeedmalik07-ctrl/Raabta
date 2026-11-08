import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Phase 18 — only persisted value: watch-until timestamp (ISO8601). No incident details.
class PostIncidentWatchRepository {
  PostIncidentWatchRepository({Future<Box<String>> Function()? openBox})
      : _openBox = openBox ?? _defaultOpen;

  static const boxName = 'ss_post_incident_watch_v1';
  static const watchUntilKey = 'postIncidentWatchUntil';

  final Future<Box<String>> Function() _openBox;

  static Future<Box<String>> _defaultOpen() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
    return Hive.box<String>(boxName);
  }

  Future<DateTime?> readWatchUntil() async {
    final box = await _openBox();
    final raw = box.get(watchUntilKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> writeWatchUntil(DateTime? until) async {
    final box = await _openBox();
    if (until == null) {
      await box.delete(watchUntilKey);
    } else {
      await box.put(watchUntilKey, until.toIso8601String());
    }
  }

  @visibleForTesting
  static Future<void> resetForTest() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<String>(boxName).clear();
    }
  }
}
