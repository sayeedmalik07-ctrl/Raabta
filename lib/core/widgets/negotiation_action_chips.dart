import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';

/// Accept / decline / optional counter chips shared by Marketplace offers and
/// Housing viewing negotiation flows.
class NegotiationActionChips extends StatelessWidget {
  const NegotiationActionChips({
    super.key,
    required this.acceptLabel,
    required this.declineLabel,
    required this.onAccept,
    required this.onDecline,
    this.counterLabel,
    this.onCounter,
  });

  final String acceptLabel;
  final String declineLabel;
  final String? counterLabel;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onCounter;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        ActionChip(label: Text(acceptLabel), onPressed: onAccept),
        ActionChip(label: Text(declineLabel), onPressed: onDecline),
        if (counterLabel != null && onCounter != null)
          ActionChip(label: Text(counterLabel!), onPressed: onCounter),
      ],
    );
  }
}
