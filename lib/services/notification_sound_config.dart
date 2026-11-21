/// Raabta signature notification sound configuration.
///
/// **Audio assets are NOT bundled yet.** Before custom sound plays on device,
/// follow [NOTIFICATION_SOUND_SETUP.md] at the project root.
class RaabtaNotificationSound {
  RaabtaNotificationSound._();

  /// Legacy FCM foreground channel — do not use for new notifications.
  static const legacyChannelId = 'raabta_push';

  /// Previous channel ID (v2) — kept for reference; do not reuse for sound changes.
  static const legacyDefaultChannelId = 'raabta_default_channel_v2';

  /// Primary Android channel (versioned — bump when sound asset changes).
  /// TODO(sayeed): drop custom sound asset here, see NOTIFICATION_SOUND_SETUP.md
  static const defaultChannelId = 'raabta_notifications_v1';
  static const defaultChannelName = 'Raabta Notifications';
  static const defaultChannelDescription =
      'Alerts from Raabta with the signature chime';

  /// Lower-importance channel for digest-style notifications.
  static const digestChannelId = 'raabta_digest_v1';
  static const digestChannelName = 'Raabta Digests';
  static const digestChannelDescription =
      'Batched group activity summaries';

  /// Set to `true` after adding assets per NOTIFICATION_SOUND_SETUP.md.
  static const useCustomSound = false;

  static const iosSoundFile = 'raabta_notification.caf';
  static const androidRawSound = 'raabta_notification';

  static const urgentChannelId = 'raabta_urgent_channel_v1';
  static const urgentChannelName = 'Raabta Urgent Alerts';
  static const urgentIosSoundFile = 'raabta_urgent.caf';
  static const urgentAndroidRawSound = 'raabta_urgent';

  /// Distinct channel for Scam & security alerts (Phase 30).
  static const securityChannelId = 'raabta_scam_security_v1';
  static const securityChannelName = 'Scam & security';
  static const securityChannelDescription =
      'Rare official scam alerts and monthly security tips';
  static const securityAndroidRawSound = 'raabta_security';

  static const assetSourcePath = 'assets/sounds/raabta_notification.mp3';
  static const assetSourcePathIos = 'assets/sounds/raabta_notification.caf';
}
