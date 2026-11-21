/// Post-splash navigation — language onboarding vs returning user home.
String resolvePostSplashRoute({required bool languageSaved}) {
  return languageSaved ? '/home' : '/language';
}

/// Returning users with a saved language should not be sent to login on relaunch.
bool shouldSkipLoginOnRelaunch({
  required bool languageSaved,
  required bool hasRestoredAuthSession,
}) {
  return languageSaved && hasRestoredAuthSession;
}
