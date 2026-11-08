import 'package:raabta/features/global_search/domain/search_voice_error.dart';

/// Voice input lifecycle for Global Search (S11).
enum SearchVoiceStatus {
  idle,
  initializing,
  listening,
  processing,
  error,
  unavailable,
}

/// Immutable voice state — no platform types (S11).
class SearchVoiceState {
  const SearchVoiceState({
    this.status = SearchVoiceStatus.idle,
    this.partialTranscript = '',
    this.finalTranscript = '',
    this.errorCode,
  });

  final SearchVoiceStatus status;
  final String partialTranscript;
  final String finalTranscript;
  final SearchVoiceErrorCode? errorCode;

  static const idle = SearchVoiceState();

  bool get isActive =>
      status == SearchVoiceStatus.initializing ||
      status == SearchVoiceStatus.listening ||
      status == SearchVoiceStatus.processing;

  bool get canStart => status == SearchVoiceStatus.idle;

  SearchVoiceState copyWith({
    SearchVoiceStatus? status,
    String? partialTranscript,
    String? finalTranscript,
    SearchVoiceErrorCode? errorCode,
    bool clearError = false,
    bool clearTranscripts = false,
  }) {
    return SearchVoiceState(
      status: status ?? this.status,
      partialTranscript: clearTranscripts
          ? ''
          : (partialTranscript ?? this.partialTranscript),
      finalTranscript: clearTranscripts
          ? ''
          : (finalTranscript ?? this.finalTranscript),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}
