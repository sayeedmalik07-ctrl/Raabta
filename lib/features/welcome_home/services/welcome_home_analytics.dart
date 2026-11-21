import 'package:flutter/foundation.dart';

abstract final class WelcomeHomeAnalytics {
  static void cardOpened() {
    debugPrint('[WelcomeHome] card_open');
  }

  static void screenOpened() {
    debugPrint('[WelcomeHome] screen_open');
  }

  static void programmeLinkTapped(String programmeId) {
    debugPrint('[WelcomeHome] link programme=$programmeId');
  }

  static void fallbackLinkTapped(String linkId) {
    debugPrint('[WelcomeHome] link fallback=$linkId');
  }
}
