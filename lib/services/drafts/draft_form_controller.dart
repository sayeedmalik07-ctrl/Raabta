import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raabta/services/drafts/draft_service.dart';

typedef DraftSavedCallback = void Function(DateTime savedAt);

/// Debounced auto-save helper for a single form instance.
class DraftFormController {
  DraftFormController({
    required this.formId,
    this.debounce = DraftService.defaultDebounce,
    DraftService? service,
    DraftSavedCallback? onSaved,
  })  : _service = service ?? DraftService.instance,
        _onSaved = onSaved;

  final String formId;
  final Duration debounce;
  final DraftService _service;
  DraftSavedCallback? _onSaved;

  Timer? _debounceTimer;
  final List<VoidCallback> _disposers = [];
  DateTime? lastSavedAt;

  void set onSaved(DraftSavedCallback? callback) => _onSaved = callback;

  Future<void> init() => _service.init();

  /// Loads a restorable draft (respects expiry / corruption handling).
  Future<DraftRecord?> loadRestorableDraft() => _service.getDraft(formId);

  void scheduleSave(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      unawaited(_persist(data));
    });
  }

  /// Flush pending debounced save immediately (e.g. before sheet close).
  Future<void> flushSave(Map<String, dynamic> data) async {
    _debounceTimer?.cancel();
    await _persist(data);
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    await _service.saveDraft(formId, data);
    lastSavedAt = DateTime.now();
    _onSaved?.call(lastSavedAt!);
  }

  Future<void> clear() async {
    _debounceTimer?.cancel();
    await _service.clearDraft(formId);
  }

  /// Attach [TextEditingController] listeners for debounced saves.
  void bindControllers(
    List<TextEditingController> controllers,
    Map<String, dynamic> Function() serialize,
  ) {
    for (final c in controllers) {
      void listener() => scheduleSave(serialize());
      c.addListener(listener);
      _disposers.add(() => c.removeListener(listener));
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    for (final d in _disposers) {
      d();
    }
    _disposers.clear();
  }
}
