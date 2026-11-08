import 'dart:io';

import 'package:flutter/foundation.dart';

/// True on macOS, Windows, or Linux — camera scan is not offered.
bool get isScannerDesktop {
  if (kIsWeb) return false;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
