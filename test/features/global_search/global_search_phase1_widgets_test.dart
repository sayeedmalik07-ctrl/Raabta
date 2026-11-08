import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_field.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_idle_body.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_loading_indicator.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_notice_banners.dart';

void main() {
  group('GlobalSearchField', () {
    testWidgets('renders 44px hub pill field with clear when text present',
        (tester) async {
      final controller = TextEditingController(text: 'jobs');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlobalSearchField(
              controller: controller,
              focusNode: focusNode,
              locale: 'English',
              onChanged: (_) {},
              onSubmitted: (_) {},
              onClear: () {},
            ),
          ),
        ),
      );

      final sized = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(GlobalSearchField),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sized.height, HubLayoutTokens.searchMinHeight);
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);
    });
  });

  group('GlobalSearchLoadingIndicator', () {
    testWidgets('uses hub skeletons not circular progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalSearchLoadingIndicator(locale: 'English'),
          ),
        ),
      );

      expect(find.byType(HubLoadingPlaceholder), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('GlobalSearchIdleBody', () {
    testWidgets('empty recent shows GlassEmptyState', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalSearchIdleBody(
              recent: [],
              locale: 'English',
              onTap: _noop,
              onRemove: _noop,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.manage_search_rounded), findsOneWidget);
    });
  });

  group('GlobalSearchOfflineBanner', () {
    testWidgets('uses HubNoticeBanner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalSearchOfflineBanner(locale: 'English'),
          ),
        ),
      );

      expect(find.byType(HubNoticeBanner), findsOneWidget);
    });
  });
}

void _noop(String _) {}
