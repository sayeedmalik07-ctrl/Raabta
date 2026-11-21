import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_models.dart';

abstract final class ReportPackRepository {
  static const _draftKey = 'ss_report_pack_draft_v1';

  @visibleForTesting
  static String? forcedUidForTests;

  static String? _uid([String? uid]) {
    if (uid != null && uid.isNotEmpty) return uid;
    if (forcedUidForTests != null) return forcedUidForTests;
    return UidScopedPreferences.resolveUid();
  }

  static Future<ReportPackDraft> loadDraft({String? uid}) async {
    final resolved = _uid(uid);
    if (resolved == null) return const ReportPackDraft();
    final prefs = await SharedPreferences.getInstance();
    final raw = UidScopedPreferences.getString(prefs, _draftKey, uid: resolved);
    if (raw == null || raw.isEmpty) return const ReportPackDraft();
    try {
      return ReportPackDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const ReportPackDraft();
    }
  }

  static Future<void> saveDraft(ReportPackDraft draft, {String? uid}) async {
    final resolved = _uid(uid);
    if (resolved == null) return;
    final prefs = await SharedPreferences.getInstance();
    await UidScopedPreferences.setString(
      prefs,
      _draftKey,
      jsonEncode(draft.toJson()),
      uid: resolved,
    );
  }
}
