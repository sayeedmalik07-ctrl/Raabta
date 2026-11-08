import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_community_sheet.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/utils/community_visibility_reasons.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// ⋯ affordance — opens a bottom sheet with deterministic visibility reasons.
class CommunityWhySeeingAffordance extends ConsumerWidget {
  const CommunityWhySeeingAffordance({
    super.key,
    required this.input,
  });

  final CommunityVisibilityInput input;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: CommunityHubIcons.actionGlyph(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
      ),
      tooltip: 'Why am I seeing this?',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => showForInput(context, ref, input),
    );
  }

  static void showForInput(
    BuildContext context,
    WidgetRef ref,
    CommunityVisibilityInput input,
  ) {
    final locale = ref.read(userLanguageProvider);
    final joinedGroupIds =
        ref.read(communityMembershipProvider).value ?? const {};
    final profile = ref.read(userAIProfileProvider);

    HubCommunitySheet.show<void>(
      context: context,
      title: CommunityStrings.t('community_why_seeing_link', locale),
      child: Consumer(
        builder: (context, ref, _) {
          final appLanguage = ref.watch(appLocaleProvider);
          final reasons = CommunityVisibilityReasons.build(
            content: input,
            joinedGroupIds: joinedGroupIds,
            userPreferredArea: profile?.preferredArea,
            appLanguage: appLanguage,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final reason in reasons)
                HubCommunitySheetBullet(text: reason),
            ],
          );
        },
      ),
    );
  }
}
