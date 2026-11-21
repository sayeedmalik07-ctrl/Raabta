import 'dart:math' as math;

import 'package:flutter/material.dart';

double relativeLuminance(Color color) {
  double channel(double c) {
    c = c / 255.0;
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.red.toDouble());
  final g = channel(color.green.toDouble());
  final b = channel(color.blue.toDouble());
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color foreground, Color background) {
  final l1 = relativeLuminance(foreground);
  final l2 = relativeLuminance(background);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}
