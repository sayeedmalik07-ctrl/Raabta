import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/core/connectivity/connectivity_status.dart';

/// Rolling latency samples used to detect degraded connectivity.
const int connectivityLatencyWindowSize = 3;

/// Reachability slower than this is treated as [ConnectivityStatus.slow].
const Duration connectivitySlowThreshold = Duration(milliseconds: 3500);

/// Minimum gap between consecutive reachability probes (debounce / anti-flap).
const Duration connectivityProbeInterval = Duration(seconds: 3);

/// Consecutive failed reachability checks required before declaring offline.
const int connectivityOfflineFailureThreshold = 2;

/// How long [ConnectivityStatus.reconnecting] is shown before [ConnectivityStatus.online].
const Duration connectivityReconnectingHold = Duration(milliseconds: 1800);

/// Lightweight reachability probe timeout.
const Duration connectivityReachabilityTimeout = Duration(seconds: 5);

/// App-wide connectivity singleton — one instance for the whole app lifetime.
final connectivityStatusProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  final notifier = ConnectivityNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Binary helper for widgets that only need online vs not-online.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStatusProvider).isOnline;
});

/// Increments whenever a full banner (offline/reconnecting) should be shown anew.
final connectivityBannerInstanceProvider = Provider<int>((ref) {
  ref.watch(connectivityStatusProvider);
  return ref.watch(connectivityStatusProvider.notifier).bannerInstanceId;
});

/// Whether the current banner instance was swipe-dismissed by the user.
final connectivityBannerDismissedProvider = Provider<bool>((ref) {
  ref.watch(connectivityStatusProvider);
  final notifier = ref.watch(connectivityStatusProvider.notifier);
  return notifier.isCurrentBannerDismissed;
});

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier({
    Connectivity? connectivity,
    http.Client? httpClient,
    Future<bool> Function()? reachabilityProbe,
    bool autoStart = true,
  })  : _connectivity = connectivity ?? Connectivity(),
        _httpClient = httpClient ?? http.Client(),
        _reachabilityProbe = reachabilityProbe,
        super(ConnectivityStatus.online) {
    if (autoStart) {
      unawaited(_start());
    }
  }

  final Connectivity _connectivity;
  final http.Client _httpClient;
  final Future<bool> Function()? _reachabilityProbe;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _probeTimer;
  Timer? _reconnectTimer;

  bool _osHasLink = true;
  int _consecutiveFailures = 0;
  final List<int> _recentLatenciesMs = [];
  DateTime? _lastProbeAt;

  int _bannerInstanceId = 0;
  int? _dismissedBannerInstanceId;

  int get bannerInstanceId => _bannerInstanceId;

  bool get isCurrentBannerDismissed =>
      _dismissedBannerInstanceId != null &&
      _dismissedBannerInstanceId == _bannerInstanceId;

  void dismissCurrentBanner() {
    _dismissedBannerInstanceId = _bannerInstanceId;
  }

  Future<void> _start() async {
    final initial = await _connectivity.checkConnectivity();
    _osHasLink = _deviceHasLink(initial);
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (Object e, StackTrace st) {
        debugPrint('[Connectivity] stream error: $e');
      },
    );
    await _scheduleProbe(immediate: true);
    _probeTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => unawaited(_scheduleProbe()),
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hadLink = _osHasLink;
    _osHasLink = _deviceHasLink(results);
    if (!hadLink && _osHasLink) {
      unawaited(_scheduleProbe(immediate: true));
      return;
    }
    if (!_osHasLink) {
      _registerFailure(forceOffline: true);
      return;
    }
    unawaited(_scheduleProbe(immediate: true));
  }

  Future<void> _scheduleProbe({bool immediate = false}) async {
    if (!_osHasLink) {
      _registerFailure(forceOffline: true);
      return;
    }

    final now = DateTime.now();
    if (!immediate &&
        _lastProbeAt != null &&
        now.difference(_lastProbeAt!) < connectivityProbeInterval) {
      return;
    }
    _lastProbeAt = now;

    final sw = Stopwatch()..start();
    final reachable = await _probeReachability();
    sw.stop();
    final latencyMs = sw.elapsedMilliseconds;

    if (!reachable) {
      _registerFailure();
      return;
    }

    _consecutiveFailures = 0;
    _recordLatency(latencyMs);
    _applyHealthySignal();
  }

  Future<bool> _probeReachability() async {
    final probe = _reachabilityProbe;
    if (probe != null) {
      return probe();
    }
    try {
      final uri = Uri.parse('${AppConfig.backendUrl}/health');
      final response = await _httpClient
          .head(uri)
          .timeout(connectivityReachabilityTimeout);
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  void _recordLatency(int latencyMs) {
    _recentLatenciesMs.add(latencyMs);
    while (_recentLatenciesMs.length > connectivityLatencyWindowSize) {
      _recentLatenciesMs.removeAt(0);
    }
  }

  bool _isRollingSlow() {
    if (_recentLatenciesMs.isEmpty) return false;
    final sum = _recentLatenciesMs.reduce((a, b) => a + b);
    final avg = sum / _recentLatenciesMs.length;
    return avg > connectivitySlowThreshold.inMilliseconds;
  }

  void _registerFailure({bool forceOffline = false}) {
    if (forceOffline) {
      _consecutiveFailures = connectivityOfflineFailureThreshold;
    } else {
      _consecutiveFailures++;
    }

    if (_consecutiveFailures >= connectivityOfflineFailureThreshold) {
      _setStatus(ConnectivityStatus.offline);
    }
  }

  void _applyHealthySignal() {
    if (_isRollingSlow()) {
      _setStatus(ConnectivityStatus.slow);
      return;
    }

    final previous = state;
    if (previous == ConnectivityStatus.offline ||
        previous == ConnectivityStatus.reconnecting) {
      _enterReconnecting();
      return;
    }

    _setStatus(ConnectivityStatus.online);
  }

  void _enterReconnecting() {
    _reconnectTimer?.cancel();
    _setStatus(ConnectivityStatus.reconnecting);
    _reconnectTimer = Timer(connectivityReconnectingHold, () {
      if (_consecutiveFailures > 0) return;
      if (state == ConnectivityStatus.reconnecting) {
        state = ConnectivityStatus.online;
      }
    });
  }

  void _setStatus(ConnectivityStatus next) {
    if (state == next) return;
    if (next.showsFullBanner) {
      _bannerInstanceId++;
    }
    state = next;
  }

  /// Test hook — triggers a reachability probe without waiting for timers.
  @visibleForTesting
  Future<void> runProbeForTest({bool immediate = true}) =>
      _scheduleProbe(immediate: immediate);

  static bool _deviceHasLink(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _probeTimer?.cancel();
    _reconnectTimer?.cancel();
    _httpClient.close();
    super.dispose();
  }
}
