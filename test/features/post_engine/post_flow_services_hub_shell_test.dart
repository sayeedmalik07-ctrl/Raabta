import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_services_hub_shell.dart';

void main() {
  testWidgets('PostFlowServicesHubShell shows hub header', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PostFlowServicesHubShell(
          locale: 'English',
          child: const Center(child: Text('step body')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(PostFlowServicesHubShell.headerKey), findsOneWidget);
    expect(find.text('Post Service'), findsOneWidget);
    expect(find.text('step body'), findsOneWidget);
  });
}
