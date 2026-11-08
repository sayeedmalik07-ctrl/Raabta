import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/router/ai_chat_entrance_orb.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';

void main() {
  test('AiChatEntranceOrbRectCodec round trip', () {
    const rect = Rect.fromLTWH(280, 120, 54, 54);
    final encoded = AiChatEntranceOrbRectCodec.encode(rect);
    expect(encoded, isNotNull);
    final decoded = AiChatEntranceOrbRectCodec.decode(encoded);
    expect(decoded, rect);
  });

  testWidgets('AiChatFlyingEntranceOrb builds mid transition', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 844,
            child: Stack(
              children: [
                AiChatFlyingEntranceOrb(
                  progress: 0.25,
                  screenSize: const Size(390, 844),
                  sourceRect: const Rect.fromLTWH(280, 120, 54, 54),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RaabtaOrb), findsOneWidget);
  });
}
