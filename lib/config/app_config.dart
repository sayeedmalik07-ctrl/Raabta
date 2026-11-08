class AppConfig {
  /// Production API + public website (Railway custom domain).
  static const String backendUrl = 'https://raabtaone.com';
  static const String publicWebsiteUrl = 'https://raabtaone.com';
  static const String publicWebsiteHost = 'raabtaone.com';
  static const String privacyPolicyUrl = '$publicWebsiteUrl/privacy';
  static const String termsOfServiceUrl = '$publicWebsiteUrl/terms';

  /// Rate Raabta / in-app review — off until store listings exist.
  /// TODO: Re-enable once App Store Connect / Play Console IDs are issued at launch.
  static const bool showRateApp = false;

  /// Play Store package name (matches android/app/build.gradle.kts applicationId).
  static const String androidApplicationId = 'com.sayeed.raabta';

  /// App Store numeric ID — set when Raabta is published on iOS.
  static const String? iosAppStoreId = null;

  static bool get hasIosAppStoreListing =>
      iosAppStoreId != null && iosAppStoreId!.trim().isNotEmpty;

  static const int aiRequestTimeout = 30;
  static const int maxRetries = 2;
  static const int cacheExpiryMinutes = 60;
}
