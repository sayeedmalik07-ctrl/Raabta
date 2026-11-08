import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/hub_community_sheet.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

String communityRelativeTime(DateTime? date, String locale) {
  if (date == null) {
    return CommunityStrings.t('community_time_just_now', locale);
  }
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) {
    return CommunityStrings.t('community_time_just_now', locale);
  }
  if (diff.inHours < 1) {
    return CommunityStrings.format(
      'community_time_minutes',
      locale,
      params: {'count': '${diff.inMinutes}'},
    );
  }
  if (diff.inDays < 1) {
    return CommunityStrings.format(
      'community_time_hours',
      locale,
      params: {'count': '${diff.inHours}'},
    );
  }
  if (diff.inDays < 7) {
    return CommunityStrings.format(
      'community_time_days',
      locale,
      params: {'count': '${diff.inDays}'},
    );
  }
  return DateFormat.yMMMd().format(date);
}

Future<String?> showCommunityGroupPicker(
  BuildContext context,
  Set<int> joinedGroupIds, {
  required String locale,
}) {
  final groups = CommunityGroupRegistry.all
      .where((g) => joinedGroupIds.contains(g.intId))
      .toList();

  if (groups.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          CommunityStrings.t('community_err_join_first', locale),
        ),
      ),
    );
    return Future.value(null);
  }

  return HubCommunitySheet.show<String>(
    context: context,
    title: CommunityStrings.t('community_picker_title', locale),
    child: Builder(
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final group in groups)
              ListTile(
                leading: Text(group.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(group.name),
                onTap: () => Navigator.pop(sheetContext, group.id),
              ),
          ],
        );
      },
    ),
  );
}

class CommunityLiveDot extends StatefulWidget {
  const CommunityLiveDot({super.key, this.active = true, this.locale = 'English'});

  final bool active;
  final String locale;

  @override
  State<CommunityLiveDot> createState() => _CommunityLiveDotState();
}

class _CommunityLiveDotState extends State<CommunityLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: communityHubAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            CommunityStrings.t('community_live', widget.locale),
            style: AppTypography.caption.copyWith(color: communityHubAccentText),
          ),
        ],
      ),
    );
  }
}
