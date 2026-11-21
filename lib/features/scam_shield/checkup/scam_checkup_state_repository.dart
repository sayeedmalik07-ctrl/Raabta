import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_models.dart';

class ScamCheckupStateRepository {
  static const boxName = 'scam_checkup_state_v1';
  static const stateKey = 'state';

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

  Future<ScamCheckupState> load() async {
    await _ensureOpen();
    final raw = _box!.get(stateKey);
    if (raw is Map) {
      return ScamCheckupState.fromJson(Map<String, dynamic>.from(raw));
    }
    return const ScamCheckupState();
  }

  Future<void> save(ScamCheckupState state) async {
    await _ensureOpen();
    await _box!.put(stateKey, state.toJson());
  }

  Future<void> setChecked(String itemId, bool checked) async {
    final state = await load();
    final ids = {...state.checkedIds};
    if (checked) {
      ids.add(itemId);
    } else {
      ids.remove(itemId);
    }
    await save(
      state.copyWith(
        checkedIds: ids,
        lastReviewAt: DateTime.now(),
      ),
    );
  }

  Future<void> dismissRecheckBanner() async {
    final state = await load();
    await save(
      state.copyWith(recheckBannerDismissedAt: DateTime.now()),
    );
  }

  @visibleForTesting
  Future<void> clearAll() async {
    await _ensureOpen();
    await _box!.clear();
  }
}
