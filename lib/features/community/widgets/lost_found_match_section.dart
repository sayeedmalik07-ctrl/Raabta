import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/models/community_models.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';

class LostFoundMatchSection extends ConsumerWidget {
  const LostFoundMatchSection({
    super.key,
    required this.item,
    required this.locale,
    required this.isOwner,
  });

  final LostFoundItem item;
  final String locale;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOwner || !item.isOpen) return const SizedBox.shrink();

    final matchesAsync = ref.watch(
      lostFoundMatchesProvider(item.id),
    );

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              CommunityStrings.t('community_lf_matches_heading', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CommunityStrings.t('community_lf_matches_hint', locale),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final match in matches)
              _MatchTile(
                locale: locale,
                itemId: item.id,
                match: match,
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MatchTile extends ConsumerStatefulWidget {
  const _MatchTile({
    required this.locale,
    required this.itemId,
    required this.match,
  });

  final String locale;
  final String itemId;
  final LostFoundMatchSummary match;

  @override
  ConsumerState<_MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends ConsumerState<_MatchTile> {
  var _dismissing = false;

  Future<void> _dismiss() async {
    if (_dismissing) return;
    setState(() => _dismissing = true);
    try {
      await ref.read(communityRepositoryProvider).dismissLostFoundMatch(
            itemId: widget.itemId,
            pairId: widget.match.pairId,
            otherItemId: widget.match.otherItemId,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CommunityStrings.t('community_lf_match_dismiss_err', widget.locale),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dismissing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = widget.match.otherType == 'lost'
        ? CommunityStrings.t('community_lf_badge_lost', widget.locale)
        : CommunityStrings.t('community_lf_badge_found', widget.locale);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(widget.match.otherTitle),
        subtitle: Text('$typeLabel · ${widget.match.score}'),
        trailing: TextButton(
          onPressed: _dismissing ? null : _dismiss,
          child: Text(
            CommunityStrings.t('community_lf_match_not_mine', widget.locale),
          ),
        ),
      ),
    );
  }
}
