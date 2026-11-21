import 'dart:async';

/// Debounces rapid search input — only the last change fires after [delay].
class SearchDebouncer {
  SearchDebouncer({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();

  bool get isPending => _timer?.isActive ?? false;
}
