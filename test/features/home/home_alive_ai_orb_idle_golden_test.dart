import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/features/home/widgets/home_floating_ai_assistant.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';

/// Production Home search-row orb vs living refs 01 / 17 / 10.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => AppColors.applyBrightness(false));

  testWidgets('home alive AI orb idle golden', (tester) async {
    AppColors.applyBrightness(false);
    await tester.binding.setSurfaceSize(const Size(120, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: RepaintBoundary(
              key: const Key('home_ai_orb_idle_golden'),
              child: HomeAliveAiOrb(
                locale: 'English',
                persona: KnowQatarPersona.newResident,
                showProactiveDot: false,
                animationsEnabled: false,
                gestureKey: const Key('home_floating_ai_orb'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RaabtaOrb), findsOneWidget);
    expect(
      tester.getSize(find.byType(HomeAliveAiOrb)).height,
      HomeAiAssistantHost.aiOrbSize,
    );

    await expectLater(
      find.byKey(const Key('home_ai_orb_idle_golden')),
      matchesGoldenFile('goldens/home_alive_ai_orb_idle_dark_54.png'),
    );
  });
}