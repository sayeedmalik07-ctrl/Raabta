import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';

/// Local Hive only — never synced to a user id on the server.
class ForewarningStateRepository {
  ForewarningStateRepository();

  static const boxName = 'scam_forewarning_state_v1';
  static const tipsEnabledKey = 'forewarnings_enabled';

  static String? hivePathOverride;

  Box<dynamic>? _box;

  Future<void> _ensureOpen() async {
    if (_box != null && _box!.isOpen) return;
    if (hivePathOverride != null) {
      Hive.init(hivePathOverride!);
    } else {
      try {
        await Hive.initFlutter();
      } catch (_) {
        Hive.init('raabta_hive');
      }
    }
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<dynamic>(boxName);
    } else {
      _box = Hive.box(boxName);
    }
  }

  Future<bool> tipsEnabled() async {
    await _ensureOpen();
    return _box!.get(tipsEnabledKey, defaultValue: true) as bool;
  }

  Future<void> setTipsEnabled(bool value) async {
    await _ensureOpen();
    await _box!.put(tipsEnabledKey, value);
  }

  Future<ForewarningMomentState> loadState(ForewarningMomentId id) async {
    await _ensureOpen();
    final raw = _box!.get(id.storageKey);
    if (raw is Map) {
      return ForewarningMomentState.fromJson(Map<String, dynamic>.from(raw));
    }
    return const ForewarningMomentState();
  }

  Future<void> saveState(
    ForewarningMomentId id,
    ForewarningMomentState state,
  ) async {
    await _ensureOpen();
    await _box!.put(id.storageKey, state.toJson());
  }

  @visibleForTesting
  Future<void> clearAll() async {
    await _ensureOpen();
    await _box!.clear();
  }
}
