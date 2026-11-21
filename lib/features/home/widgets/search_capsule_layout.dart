import 'package:flutter/widgets.dart';

/// Layout hints for [AnimatedSearchEntry] in the Home header search row.
class SearchCapsuleLayout extends InheritedWidget {
  const SearchCapsuleLayout({
    super.key,
    this.embedded = false,
    this.hostedInAiRow = false,
    required this.localeTextDirection,
    required super.child,
  });

  /// Legacy unified-capsule embedding (search region inside one glass shell).
  final bool embedded;

  /// Standalone search pill in [HomeSearchWithAiRow] (no duplicate outer padding).
  final bool hostedInAiRow;

  /// App locale direction preserved while the orb slot stays on the physical right.
  final TextDirection localeTextDirection;

  static bool embeddedOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<SearchCapsuleLayout>()
            ?.embedded ??
        false;
  }

  static bool hostedInAiRowOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<SearchCapsuleLayout>()
            ?.hostedInAiRow ??
        false;
  }

  static TextDirection? localeTextDirectionOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SearchCapsuleLayout>()
        ?.localeTextDirection;
  }

  @override
  bool updateShouldNotify(SearchCapsuleLayout oldWidget) =>
      embedded != oldWidget.embedded ||
      hostedInAiRow != oldWidget.hostedInAiRow ||
      localeTextDirection != oldWidget.localeTextDirection;
}
