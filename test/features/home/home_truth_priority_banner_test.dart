import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_home_priority.dart';
import 'package:raabta/features/home/widgets/home_truth_priority_banner.dart';
import 'package:raabta/features/home/widgets/home_tool_rail_titles.dart';

void main() {
  const priority = TruthHomePriority.ready(
    TruthChipStatus(
      engine: TruthChipEngine.eosb,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: 'tool_eosb_title',
      statusText: 'Filing window · 9 days',
      freshnessText: '',
      deepLink: '/eosb',
    ),
  );

  testWidgets('RTL uses leading chevron', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomeTruthPriorityBanner(
            priority: priority,
            locale: 'Arabic',
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('semantics button with title and status', (tester) async {
    final title = HomeToolRailTitles.forRoute('/eosb', 'English');
    final label = HomeTruthPriorityBanner.accessibilityLabel(
      title: title,
      statusText: 'Filing window · 9 days',
    );
    final semanticsHandle = tester.ensureSemantics();
    final handle = find.bySemanticsLabel(label);
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeTruthPriorityBanner(
          priority: priority,
          locale: 'English',
        ),
      ),
    );
    try {
      expect(handle, findsOneWidget);
      final node = tester.getSemantics(handle);
      expect(node.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(node.label, contains('Filing window'));
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('hidden when not ready', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeTruthPriorityBanner(
          priority: TruthHomePriority.none(),
          locale: 'English',
        ),
      ),
    );
    expect(find.text('Filing window · 9 days'), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
  });
}
