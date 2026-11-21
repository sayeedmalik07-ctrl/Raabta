import 'package:flutter/material.dart';
import 'package:raabta/features/arabic_companion/presentation/arabic_companion_screen.dart';

/// Legacy wrapper — redirects to Arabic Companion in router; kept for imports/tests.
class ArabicPhrasesScreen extends StatelessWidget {
  const ArabicPhrasesScreen({
    super.key,
    this.initialCategoryId,
    this.initialPhraseId,
  });

  final String? initialCategoryId;
  final String? initialPhraseId;

  @override
  Widget build(BuildContext context) {
    return ArabicCompanionScreen(
      initialCategoryId: initialCategoryId,
      initialPhraseId: initialPhraseId,
    );
  }
}
