import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Future hook for carrier-verified SIM/eSIM status.
///
/// **Current implementation:** stub only — no carrier API, no telecom data
/// access, no background monitoring, and no network calls.
abstract class SimSwapDetectionProvider {
  Future<SimSwapDetectionStatus> checkAvailability();
}

class SimSwapDetectionStatus {
  const SimSwapDetectionStatus({
    required this.isCarrierVerificationAvailable,
    required this.disclaimerKey,
  });

  /// Always false for the stub — Raabta has no carrier verification today.
  final bool isCarrierVerificationAvailable;
  final String disclaimerKey;
}

/// Stub provider — not wired into active UI behaviour.
class SimSwapDetectionProviderStub implements SimSwapDetectionProvider {
  @override
  Future<SimSwapDetectionStatus> checkAvailability() async {
    return const SimSwapDetectionStatus(
      isCarrierVerificationAvailable: false,
      disclaimerKey: 'ss_sim_detection_stub_disclaimer',
    );
  }
}

final simSwapDetectionProvider = Provider<SimSwapDetectionProvider>(
  (ref) => SimSwapDetectionProviderStub(),
);
