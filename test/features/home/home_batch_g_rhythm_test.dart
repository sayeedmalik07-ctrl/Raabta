import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/data/daily_essential_routes.dart';
import 'package:raabta/features/home/providers/daily_essentials_order_provider.dart';
import 'package:raabta/features/home/widgets/home_daily_essentials_zone.dart';
import 'package:raabta/features/home/widgets/home_for_you_inline_copy.dart';
import 'package:raabta/features/home/widgets/home_for_you_zone.dart';
import 'package:raabta/features/quick_actions/quick_actions_hub.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

class _TestDailyEssentialsOrderNotifier extends DailyEssentialsOrderNotifier {
  _TestDailyEssentialsOrderNotifier(super.ref, List<QuickActionTool> tools) {
    state = AsyncValue.data(tools);
  }

  @override
  Future<void> refresh() async {}
}

class _EmptyFeedNotifier extends AIFeedNotifier {
  @override
  Future<AIFeedResult> build() async {
    return AIFeedResult(cards: const [], generatedAt: DateTime(2020));
  }
}

void main() {
  group('HomeForYouInlineCopy', () {
    testWidgets('links Ask Raabta phrase', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeForYouInlineCopy(
              title: 'Your picks are on the way',
              body: 'Complete your profile or tap Ask Raabta.',
              linkPhrase: 'Ask Raabta',
              onLinkTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Raabta'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  testWidgets('Daily Essentials uses one grouped surface', (tester) async {
    final tools = DailyEssentialRoutes.catalogTools();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          dailyEssentialsOrderProvider.overrideWith(
            (ref) => _TestDailyEssentialsOrderNotifier(ref, tools),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeDailyEssentialsZone(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('home_daily_essentials_grouped_list')),
      findsOneWidget,
    );
    const homeVisible = 4;
    expect(find.byType(Divider), findsNWidgets(homeVisible - 1));
  });

  testWidgets('For you empty feed is inline copy', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userLanguageProvider.overrideWith((ref) => 'English'),
          userAIProfileProvider.overrideWith(
            (ref) => UserProfileAINotifier(ref.watch(userProfileAIServiceProvider)),
          ),
          aiFeedProvider.overrideWith(_EmptyFeedNotifier.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HomeForYouZone(
              onAiTap: () {},
              onBuildProfileTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_for_you_inline_empty')), findsOneWidget);
    expect(find.text('Your picks are on the way'), findsOneWidget);
    expect(find.text('Ask Raabta'), findsOneWidget);
    expect(
      find.textContaining('Sign in and complete your profile'),
      findsOneWidget,
    );
  });
}