/// App-wide connectivity states for [connectivityStatusProvider].
enum ConnectivityStatus {
  online,
  slow,
  offline,
  reconnecting,
}

extension ConnectivityStatusX on ConnectivityStatus {
  bool get isOnline =>
      this == ConnectivityStatus.online ||
      this == ConnectivityStatus.reconnecting;

  bool get showsFullBanner =>
      this == ConnectivityStatus.offline ||
      this == ConnectivityStatus.reconnecting;

  bool get showsSlowIndicator => this == ConnectivityStatus.slow;
}
