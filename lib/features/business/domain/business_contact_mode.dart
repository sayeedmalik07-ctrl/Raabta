/// How a Business listing accepts customer contact.
enum BusinessContactMode {
  messageOnly,
  appointment,
  quote,
}

extension BusinessContactModeX on BusinessContactMode {
  String get storageValue => switch (this) {
        BusinessContactMode.messageOnly => 'message_only',
        BusinessContactMode.appointment => 'appointment',
        BusinessContactMode.quote => 'quote',
      };

  static BusinessContactMode fromStorage(String? raw) {
    return switch (raw) {
      'appointment' => BusinessContactMode.appointment,
      'quote' => BusinessContactMode.quote,
      _ => BusinessContactMode.messageOnly,
    };
  }

  bool get allowsStructuredAction =>
      this == BusinessContactMode.appointment ||
      this == BusinessContactMode.quote;
}
