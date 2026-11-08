import 'package:flutter/material.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/domain/post_draft_publish_state.dart';
import 'package:raabta/services/drafts/draft_form_controller.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/services/drafts/draftable_form.dart';

/// Wraps existing draft infrastructure — no parallel Hive implementation.
class PostDraftManager {
  PostDraftManager({
    required PostVertical vertical,
    required String categoryPath,
    this._schemaVersion = PostDraftPublishState.schemaVersion,
    DraftFormController? controller,
    DraftSavedCallback? onSaved,
  })  : _vertical = vertical,
        _categoryPath = categoryPath,
        _controller = controller ??
            DraftFormController(
              formId: _buildFormId(vertical, categoryPath),
              onSaved: onSaved,
            );

  final PostVertical _vertical;
  final String _categoryPath;
  final int _schemaVersion;
  final DraftFormController _controller;

  DateTime? get lastSavedAt => _controller.lastSavedAt;

  set onSaved(DraftSavedCallback? callback) => _controller.onSaved = callback;

  static String _buildFormId(PostVertical vertical, String categoryPath) {
    final safePath = categoryPath.replaceAll('.', '_');
    return 'post_engine_${vertical.id}_$safePath';
  }

  String get formId => _controller.formId;

  DraftFormController get controller => _controller;

  Future<void> init() async {
    DraftableFormRegistry.markActive(formId);
    await _controller.init();
  }

  Future<DraftRecord?> loadRestorableDraft() => _controller.loadRestorableDraft();

  void scheduleSave(Map<String, dynamic> data) {
    _controller.scheduleSave(_wrapMeta(data));
  }

  Future<void> saveDraft(Map<String, dynamic> data) async {
    await _controller.flushSave(_wrapMeta(data));
  }

  Map<String, dynamic> _wrapMeta(Map<String, dynamic> data) => {
        ...data,
        '_vertical': _vertical.id,
        '_categoryPath': _categoryPath,
        '_schemaVersion': _schemaVersion,
      };

  Future<void> clearDraft() => _controller.clear();

  /// Perserves publish session meta alongside form field values.
  Future<void> savePublishState(Map<String, dynamic> dataWithMeta) async {
    await _controller.flushSave(_wrapMeta(dataWithMeta));
  }

  void bindControllers(
    List<TextEditingController> controllers,
    Map<String, dynamic> Function() serialize,
  ) {
    _controller.bindControllers(controllers, serialize);
  }

  void dispose() {
    _controller.dispose();
  }
}
