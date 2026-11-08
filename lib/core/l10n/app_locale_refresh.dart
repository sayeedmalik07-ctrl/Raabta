import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] to rebuild all stacked routes when app locale changes.
final appLocaleRefreshListenable = AppLocaleRefreshListenable();

class AppLocaleRefreshListenable extends ChangeNotifier {
  void refreshRoutes() => notifyListeners();
}
