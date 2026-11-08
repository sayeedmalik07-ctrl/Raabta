import 'package:flutter/material.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/raabta_orb.dart';
import 'package:raabta/core/widgets/raabta_orb_kit_sizes.dart';
import 'package:raabta/core/widgets/raabta_orb_state.dart';
import 'package:raabta/providers/ai_chat_provider.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';

enum AiChatMenuAction { newChat, threads, research, voice, premium }

class AiChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AiChatAppBar({
    super.key,
    required this.locale,
    required this.chatState,
    required this.subtitle,
    required this.showBack,
    required this.onBack,
    required this.onMenuAction,
    this.orbState = RaabtaOrbState.idle,
  });

  final String locale;
  final AiChatState chatState;
  final RaabtaOrbState orbState;
  final String subtitle;
  final bool showBack;
  final VoidCallback onBack;
  final ValueChanged<AiChatMenuAction> onMenuAction;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leadingWidth: GlassBarControl.size + AppSpacing.md,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: GlassBarControl(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: onBack,
              ),
            )
          : const SizedBox.shrink(),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RaabtaOrb(
            state: orbState,
            size: RaabtaOrbKitSizes.appBar,
            animationsEnabled: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AiChatStrings.t('ai_title', locale),
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GlassBarControl(
            icon: Icons.more_horiz_rounded,
            tooltip: AiChatStrings.t('ai_menu_options', locale),
            onPressed: () => _openMenu(context),
          ),
        ),
      ],
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final action = await showModalBottomSheet<AiChatMenuAction>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_comment_outlined),
              title: Text(AiChatStrings.t('ai_new_chat', locale)),
              onTap: () => Navigator.pop(ctx, AiChatMenuAction.newChat),
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(AiChatStrings.t('ai_threads_title', locale)),
              onTap: () => Navigator.pop(ctx, AiChatMenuAction.threads),
            ),
            if (MonetizationState.showPremiumTierUi)
              ListTile(
                leading: Icon(
                  Icons.school_outlined,
                  color: chatState.isPremium ? null : Colors.white24,
                ),
                enabled: chatState.isPremium,
                title: Text(AiChatStrings.t('ai_research_mode', locale)),
                onTap: chatState.isPremium
                    ? () => Navigator.pop(ctx, AiChatMenuAction.research)
                    : null,
              ),
            if (chatState.ttsAvailable)
              ListTile(
                leading: Icon(
                  chatState.voiceEnabled
                      ? Icons.record_voice_over_rounded
                      : Icons.voice_over_off_rounded,
                ),
                title: Text(
                  chatState.voiceEnabled
                      ? AiChatStrings.t('ai_menu_voice_on', locale)
                      : AiChatStrings.t('ai_menu_voice_off', locale),
                ),
                onTap: () => Navigator.pop(ctx, AiChatMenuAction.voice),
              ),
            if (MonetizationState.showPremiumTierUi && !chatState.isPremium)
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(AiChatStrings.t('ai_quota_upgrade', locale)),
                onTap: () => Navigator.pop(ctx, AiChatMenuAction.premium),
              ),
          ],
        ),
      ),
    );
    if (action != null) onMenuAction(action);
  }
}
