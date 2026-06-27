import 'dart:async';

/// Delays execution until [delay] has passed without another call.
/// Used to batch rapid profile updates into a single Firestore write.
class Debouncer {
  Debouncer({this.delay = const Duration(seconds: 60)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      _timer = null;
      action();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }

  bool get isPending => _timer?.isActive ?? false;
}
