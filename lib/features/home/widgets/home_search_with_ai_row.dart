import 'package:flutter/material.dart';

/// Inline / sticky global search with optional Home AI orb on the outer edge.
class HomeSearchWithAiRow extends StatelessWidget {
  const HomeSearchWithAiRow({
    super.key,
    required this.search,
    this.aiOrb,
  });

  final Widget search;
  final Widget? aiOrb;

  /// Design kit v2.1 search ↔ orb gap (§10).
  static const orbGap = 10.0;

  @override
  Widget build(BuildContext context) {
    if (aiOrb == null) return search;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: search),
        const SizedBox(width: orbGap),
        aiOrb!,
      ],
    );
  }
}
