import 'package:raabta/features/scam_shield/evidence_listen/evidence_listen_controller.dart';

/// Ensures climate status TTS stops when the navigator screen is popped.
abstract final class ClimateStatusListenSession {
  static EvidenceListenController? _active;

  static void register(EvidenceListenController controller) {
    if (!identical(_active, controller)) {
      _active?.stopForDispose();
    }
    _active = controller;
  }

  static void unregister(EvidenceListenController controller) {
    if (identical(_active, controller)) {
      _active = null;
    }
  }

  static void stopActiveForDispose() {
    _active?.stopForDispose();
    _active = null;
  }
}
