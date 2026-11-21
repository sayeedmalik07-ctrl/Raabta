/// Deterministic voice input error categories for Global Search (S11).
enum SearchVoiceErrorCode {
  permissionDenied,
  permissionPermanentlyDenied,
  notAvailable,
  initializationFailed,
  recognitionFailed,
  timeout,
  emptyTranscript,
  cancelled,
}

extension SearchVoiceErrorCodeL10n on SearchVoiceErrorCode {
  String get messageKey => switch (this) {
        SearchVoiceErrorCode.permissionDenied =>
          'global_search_voice_permission_denied',
        SearchVoiceErrorCode.permissionPermanentlyDenied =>
          'global_search_voice_permission_settings',
        SearchVoiceErrorCode.notAvailable => 'global_search_voice_unavailable',
        SearchVoiceErrorCode.initializationFailed =>
          'global_search_voice_unavailable',
        SearchVoiceErrorCode.recognitionFailed => 'global_search_voice_error',
        SearchVoiceErrorCode.timeout => 'global_search_voice_error',
        SearchVoiceErrorCode.emptyTranscript => 'global_search_voice_empty',
        SearchVoiceErrorCode.cancelled => 'global_search_voice_error',
      };
}
