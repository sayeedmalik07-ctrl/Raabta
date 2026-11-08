/// Honest summary of what Raabta stores for the signed-in user.
class UserDataSummary {
  const UserDataSummary({
    required this.profileStored,
    required this.documentCount,
    required this.aiConversationCount,
    required this.aiMessageCount,
    required this.eosbHistoryCount,
    required this.overtimeHistoryCount,
    this.advancedProfileFieldCount = 0,
  });

  final bool profileStored;
  final int documentCount;
  final int aiConversationCount;
  final int aiMessageCount;
  final int eosbHistoryCount;
  final int overtimeHistoryCount;
  final int advancedProfileFieldCount;

  bool get hasAnyData =>
      profileStored ||
      documentCount > 0 ||
      aiConversationCount > 0 ||
      eosbHistoryCount > 0 ||
      overtimeHistoryCount > 0 ||
      advancedProfileFieldCount > 0;
}
