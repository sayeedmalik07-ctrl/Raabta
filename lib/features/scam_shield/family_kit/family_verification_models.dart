class FamilyKnownContact {
  const FamilyKnownContact({
    required this.displayName,
    required this.phoneNumber,
  });

  final String displayName;
  final String phoneNumber;

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'phoneNumber': phoneNumber,
      };

  factory FamilyKnownContact.fromJson(Map<String, dynamic> json) {
    return FamilyKnownContact(
      displayName: json['displayName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
    );
  }
}

class FamilyVerificationPrefs {
  const FamilyVerificationPrefs({
    this.reminderEnabled = false,
    this.knownNumbersEnabled = false,
  });

  final bool reminderEnabled;
  final bool knownNumbersEnabled;

  FamilyVerificationPrefs copyWith({
    bool? reminderEnabled,
    bool? knownNumbersEnabled,
  }) {
    return FamilyVerificationPrefs(
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      knownNumbersEnabled: knownNumbersEnabled ?? this.knownNumbersEnabled,
    );
  }
}

enum FamilyScenarioNodeId {
  start,
  afterHangUp,
  afterCallBack,
  complete,
}

enum FamilyScenarioChoiceId {
  sendMoney,
  stayOnLine,
  hangUp,
  textBack,
  callKnownNumber,
  askSecretWord,
  skipWordSend,
}
