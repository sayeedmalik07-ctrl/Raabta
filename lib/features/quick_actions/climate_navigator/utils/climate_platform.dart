import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// True on macOS, Windows, or Linux — map uses taller layout.
bool get isClimateDesktop {
  if (kIsWeb) return false;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

/// Map panel height for cooling resources.
double climateMapHeight(BuildContext context) {
  if (isClimateDesktop) return 320;
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 600) return 280;
  return 220;
}
