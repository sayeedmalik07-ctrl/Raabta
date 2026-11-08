/// How much autonomy Raabta has for a user-facing action.
enum PermissionLevel {
  /// Browse or display information only.
  read,

  /// Suggest an action without performing it.
  recommend,

  /// External send/submission — user must confirm before proceeding.
  confirm,

  /// Irreversible or payment action — explicit execute confirmation required.
  execute,
}
