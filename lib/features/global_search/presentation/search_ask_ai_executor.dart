import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';

/// Opens the ASK AI answer surface on explicit user tap (S9).
abstract final class SearchAskAiExecutor {
  static const routePath = '/global-search/ask-ai';

  static void open(
    BuildContext context, {
    required SearchAskAiResult offer,
    required SearchAnalysis analysis,
  }) {
    context.push(
      routePath,
      extra: {
        'offer': offer,
        'analysis': analysis,
      },
    );
  }
}
