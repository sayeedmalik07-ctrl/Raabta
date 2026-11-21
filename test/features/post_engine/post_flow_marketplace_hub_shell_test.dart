import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_marketplace_hub_shell.dart';

void main() {
  testWidgets('PostFlowMarketplaceHubShell shows hub header', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PostFlowMarketplaceHubShell(
          locale: 'English',
          child: const Center(child: Text('step body')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(PostFlowMarketplaceHubShell.headerKey), findsOneWidget);
    expect(find.text('Post Item'), findsOneWidget);
    expect(find.text('step body'), findsOneWidget);
  });
}
