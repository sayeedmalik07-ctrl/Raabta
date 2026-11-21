import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/widgets/community_moderation_block_banner.dart';
import 'package:raabta/features/community/widgets/community_moderation_rephrase_panel.dart';

/// Hard-block banner plus optional Part B rephrase panel.
class CommunityModerationBlockSection extends ConsumerWidget {
  const CommunityModerationBlockSection({
    super.key,
    required this.block,
    required this.locale,
    required this.sourceText,
    required this.rephraseAttemptsUsed,
    required this.onRephraseAttemptConsumed,
    required this.onApplySuggestion,
    this.compact = false,
  });

  final CommunityModerationBlockCopy block;
  final String locale;
  final String sourceText;
  final int rephraseAttemptsUsed;
  final VoidCallback onRephraseAttemptConsumed;
  final ValueChanged<String> onApplySuggestion;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersRephrase =
        CommunityModerationBlockPresentation.offersRephrase(block);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityModerationBlockBanner(
          message: block.message,
          guidelinesLine: block.guidelinesLine,
          compact: compact,
        ),
        if (offersRephrase)
          CommunityModerationRephrasePanel(
            locale: locale,
            sourceText: sourceText,
            attemptsUsed: rephraseAttemptsUsed,
            compact: compact,
            onAttemptConsumed: onRephraseAttemptConsumed,
            onApplySuggestion: onApplySuggestion,
            onRequestRephrase: () async {
              final uid = await ref.read(communityUserIdProvider.future);
              final service =
                  ref.read(communityModerationRephraseServiceProvider);
              return service.requestRephrase(
                text: sourceText,
                language: locale,
                blockedCategory: block.blockCategory!,
                userId: uid,
              );
            },
          ),
      ],
    );
  }
}
