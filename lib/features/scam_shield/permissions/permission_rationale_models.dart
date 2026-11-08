/// Shared pre-permission rationale (Phase 27).
enum PermissionRationaleKind {
  androidCallScreening,
  iosSmsFilterSettings,
  osSettingsDeepLink,
  localNotifications,
  sensitiveSafetyLock,
}

enum PermissionRationaleChoice {
  notNow,
  continueRequested,
}
