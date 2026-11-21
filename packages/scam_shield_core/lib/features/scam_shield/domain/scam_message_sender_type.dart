/// Optional user-selected sender channel — never read from OS/contacts.
enum ScamMessageSenderType {
  notSure,
  senderNameOrShortCode,
  localMobile,
  internationalNumber,
  whatsAppTelegramSocial,
  email,
}

extension ScamMessageSenderTypeX on ScamMessageSenderType {
  String get labelKey => switch (this) {
        ScamMessageSenderType.notSure => 'ss_sender_not_sure',
        ScamMessageSenderType.senderNameOrShortCode =>
          'ss_sender_short_code',
        ScamMessageSenderType.localMobile => 'ss_sender_local_mobile',
        ScamMessageSenderType.internationalNumber =>
          'ss_sender_international',
        ScamMessageSenderType.whatsAppTelegramSocial => 'ss_sender_chat_app',
        ScamMessageSenderType.email => 'ss_sender_email',
      };

  bool get isActionable => this != ScamMessageSenderType.notSure;
}
