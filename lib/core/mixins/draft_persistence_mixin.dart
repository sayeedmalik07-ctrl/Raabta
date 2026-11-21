import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/draft_restore_banner.dart';
import 'package:raabta/services/drafts/draft_form_controller.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/services/drafts/draftable_form.dart';

/// Reusable mixin for full-screen multi-field forms.
///
/// Call [setupDraftPersistence] from [initState] (post-frame if controllers
/// are populated asynchronously), then place [draftRestoreBanner] at the top
/// of your form and call [notifyDraftChanged] from dropdowns / date pickers.
mixin DraftPersistenceMixin<T extends StatefulWidget> on State<T> {
  DraftFormController? _draftController;
  DraftRecord? _pendingDraft;
  bool _showRestoreBanner = false;

  Map<String, dynamic> Function()? _serializeDraft;
  void Function(Map<String, dynamic> data)? _applyDraft;

  /// Initialize draft auto-save for [formId].
  Future<void> setupDraftPersistence({
    required String formId,
    required Map<String, dynamic> Function() serialize,
    required void Function(Map<String, dynamic> data) applyDraft,
    List<TextEditingController>? controllers,
  }) async {
    _serializeDraft = serialize;
    _applyDraft = applyDraft;
    _draftController = DraftFormController(formId: formId);
    DraftableFormRegistry.markActive(formId);
    await _draftController!.init();

    if (controllers != null && controllers.isNotEmpty) {
      _draftController!.bindControllers(controllers, serialize);
    }

    final draft = await _draftController!.loadRestorableDraft();
    if (!mounted || draft == null) return;
    setState(() {
      _pendingDraft = draft;
      _showRestoreBanner = true;
    });
  }

  bool get hasPendingDraftRestore => _showRestoreBanner;

  Widget? get draftRestoreBanner {
    if (!_showRestoreBanner || _pendingDraft == null) return null;
    final savedAt = _pendingDraft!.savedAt;
    return DraftRestoreBanner(
      savedAt: savedAt,
      onRestore: () {
        _applyDraft?.call(Map<String, dynamic>.from(_pendingDraft!.data));
        setState(() {
          _showRestoreBanner = false;
          _pendingDraft = null;
        });
      },
      onDiscard: () {
        unawaited(clearFormDraft());
        setState(() {
          _showRestoreBanner = false;
          _pendingDraft = null;
        });
      },
    );
  }

  void notifyDraftChanged() {
    final serialize = _serializeDraft;
    if (serialize != null) {
      _draftController?.scheduleSave(serialize());
    }
  }

  Future<void> clearFormDraft() => _draftController?.clear() ?? Future.value();

  /// Call from the host [State.dispose] before `super.dispose()`.
  void disposeDraftMixin() {
    _draftController?.dispose();
  }
}

/// Stateful wrapper for modal bottom-sheet forms with draft persistence.
class DraftAwareSheet extends StatefulWidget {
  const DraftAwareSheet({
    super.key,
    required this.formId,
    required this.serialize,
    required this.applyDraft,
    required this.builder,
    this.controllers = const [],
  });

  final String formId;
  final Map<String, dynamic> Function() serialize;
  final void Function(Map<String, dynamic> data) applyDraft;
  final List<TextEditingController> controllers;
  final Widget Function(
    BuildContext context,
    DraftSheetHandle handle,
  ) builder;

  @override
  State<DraftAwareSheet> createState() => _DraftAwareSheetState();
}

class DraftSheetHandle {
  DraftSheetHandle(this._state);
  final _DraftAwareSheetState _state;

  void notifyChanged() => _state._onFieldChanged();

  Future<void> clearDraft() => _state._controller.clear();

  bool get showRestoreBanner => _state._showRestoreBanner;
  DateTime? get savedAt => _state._pendingDraft?.savedAt;

  void restoreDraft() => _state._restore();
  void discardDraft() => _state._discard();
}

class _DraftAwareSheetState extends State<DraftAwareSheet> {
  late final DraftFormController _controller;
  DraftRecord? _pendingDraft;
  bool _showRestoreBanner = false;

  @override
  void initState() {
    super.initState();
    DraftableFormRegistry.markActive(widget.formId);
    _controller = DraftFormController(formId: widget.formId);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _controller.init();
    if (widget.controllers.isNotEmpty) {
      _controller.bindControllers(widget.controllers, widget.serialize);
    }
    final draft = await _controller.loadRestorableDraft();
    if (!mounted || draft == null) return;
    setState(() {
      _pendingDraft = draft;
      _showRestoreBanner = true;
    });
  }

  void _onFieldChanged() => _controller.scheduleSave(widget.serialize());

  void _restore() {
    if (_pendingDraft == null) return;
    widget.applyDraft(Map<String, dynamic>.from(_pendingDraft!.data));
    setState(() {
      _showRestoreBanner = false;
      _pendingDraft = null;
    });
  }

  void _discard() {
    unawaited(_controller.clear());
    setState(() {
      _showRestoreBanner = false;
      _pendingDraft = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handle = DraftSheetHandle(this);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showRestoreBanner && _pendingDraft != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: DraftRestoreBanner(
                savedAt: _pendingDraft!.savedAt,
                onRestore: _restore,
                onDiscard: _discard,
              ),
            ),
          Flexible(
            fit: FlexFit.loose,
            child: widget.builder(context, handle),
          ),
        ],
      ),
    );
  }
}
