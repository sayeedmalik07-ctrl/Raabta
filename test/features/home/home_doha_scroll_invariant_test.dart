import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HomeScreen does not listen to scroll offset for setState', () {
    final src = File('lib/features/home/screens/home_screen.dart').readAsStringSync();
    expect(src.contains('_homeScrollController.addListener'), isFalse);
    expect(
      RegExp(r'NotificationListener<ScrollNotification>').hasMatch(src),
      isFalse,
    );
    expect(src.contains('NotificationListener<ScrollEndNotification>'), isTrue);
  });
}