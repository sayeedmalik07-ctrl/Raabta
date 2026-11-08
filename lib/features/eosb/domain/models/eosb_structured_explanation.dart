class EosbAiInsightCard {
  const EosbAiInsightCard({
    required this.title,
    required this.body,
    this.isCritical = false,
  });

  final String title;
  final String body;
  final bool isCritical;
}

class EosbStructuredExplanation {
  const EosbStructuredExplanation({
    required this.summary,
    this.risks = const [],
    this.nextSteps = const [],
  });

  final String summary;
  final List<EosbAiInsightCard> risks;
  final List<String> nextSteps;
}
