import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/global_search/data/search_voice_service.dart';
import 'package:raabta/features/global_search/domain/search_voice_error.dart';
import 'package:raabta/features/global_search/domain/search_voice_state.dart';

/// Orchestrates Global Search voice input state (S11).
class SearchVoiceController extends StateNotifier<SearchVoiceState> {
  SearchVoiceController(this._service) : super(SearchVoiceState.idle);

  final SearchVoiceService _service;

  var _submitGuard = false;
  var _starting = false;

  Future<void> toggleListening({
    required String appLocale,
    required void Function(String finalTranscript) onSubmitFinal,
    void Function(String partialTranscript)? onPartialTranscript,
  }) async {
    if (state.status == SearchVoiceStatus.listening) {
      await cancel();
      return;
    }
    if (!state.canStart || _starting) return;

    _starting = true;
    state = state.copyWith(
      status: SearchVoiceStatus.initializing,
      clearTranscripts: true,
      clearError: true,
    );

    if (!_service.supportsPlatform) {
      state = const SearchVoiceState(status: SearchVoiceStatus.unavailable);
      _starting = false;
      return;
    }

    _submitGuard = false;
    _starting = false;

    state = state.copyWith(status: SearchVoiceStatus.listening);

    await _service.startListening(
      appLocale: appLocale,
      onPartial: (partial) {
        if (!mounted) return;
        state = state.copyWith(
          status: SearchVoiceStatus.listening,
          partialTranscript: partial,
        );
        onPartialTranscript?.call(partial);
      },
      onFinal: (finalText) {
        if (!mounted) return;
        _handleFinal(finalText, onSubmitFinal);
      },
      onError: (code) {
        if (!mounted) return;
        if (code == SearchVoiceErrorCode.cancelled) {
          state = SearchVoiceState.idle;
          return;
        }
        state = SearchVoiceState(
          status: SearchVoiceStatus.error,
          errorCode: code,
        );
      },
    );
  }

  void _handleFinal(
    String finalText,
    void Function(String finalTranscript) onSubmitFinal,
  ) {
    if (_submitGuard) return;
    _submitGuard = true;

    final trimmed = finalText.trim();
    if (trimmed.isEmpty) {
      state = const SearchVoiceState(
        status: SearchVoiceStatus.error,
        errorCode: SearchVoiceErrorCode.emptyTranscript,
      );
      return;
    }

    state = SearchVoiceState(
      status: SearchVoiceStatus.processing,
      finalTranscript: trimmed,
    );

    onSubmitFinal(trimmed);

    state = SearchVoiceState.idle;
    _submitGuard = false;
  }

  Future<void> stop() async {
    await _service.stopListening();
    if (mounted) {
      state = SearchVoiceState.idle;
    }
  }

  Future<void> cancel() async {
    await _service.cancelListening();
    _submitGuard = true;
    if (mounted) {
      state = SearchVoiceState.idle;
    }
    _submitGuard = false;
  }

  void clearError() {
    if (state.status == SearchVoiceStatus.error) {
      state = SearchVoiceState.idle;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  /// Test-only access.
  SearchVoiceService get serviceForTests => _service;
}

final searchVoiceServiceProvider = Provider<SearchVoiceService>((ref) {
  final service = SearchVoiceService();
  ref.onDispose(service.dispose);
  return service;
});

final searchVoiceControllerProvider =
    StateNotifierProvider.autoDispose<SearchVoiceController, SearchVoiceState>(
  (ref) {
    return SearchVoiceController(ref.watch(searchVoiceServiceProvider));
  },
);
